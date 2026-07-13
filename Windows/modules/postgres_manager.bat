@echo off
REM ============================================================================
REM  Gestor de PostgreSQL - Modulo de Renggli PC Solution Toolbox
REM  - Detecta automaticamente las instancias PostgreSQL instaladas (servicio)
REM  - Enumera roles con login y permite cambiar sus passwords en lote
REM  - Modo DIRECTO: si conoces la password del superusuario (sin reinicios)
REM  - Modo RECUPERACION: si NADIE conoce la password (trust temporal + reload)
REM  - Reversion garantizada de pg_hba.conf ante cualquier error
REM
REM  Uso:
REM    postgres_manager.bat            -> modo interactivo
REM    postgres_manager.bat /detect    -> solo detecta instancias (solo lectura)
REM
REM  Variables opcionales que el Toolbox le pasa por entorno:
REM    LOG_FILE   -> ruta del log de auditoria de la suite (si existe se reutiliza)
REM ============================================================================

setlocal EnableDelayedExpansion
chcp 65001 >nul 2>&1
title Gestor de PostgreSQL - Renggli PC Solution

REM --- Log: reutiliza el de la suite si vino por entorno; si no, uno propio ---
if not defined LOG_FILE (
    set "LOG_DIR=%~dp0..\Logs"
    if not exist "!LOG_DIR!" mkdir "!LOG_DIR!" >nul 2>&1
    for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "ISO_DATE=%%a"
    set "LOG_FILE=!LOG_DIR!\Audit_!ISO_DATE!.log"
)

REM --- Estado global del modulo ---
set "PG_SVC="
set "PG_BINDIR="
set "PG_DATADIR="
set "PG_PORT=5432"
set "PG_HBA="
set "PG_HBA_BAK="
set "PG_SUPER=postgres"
set "PG_MODE="
set "TRUST_ACTIVE=0"
set "DETECT_FILE=%TEMP%\rpg_detect_%RANDOM%.txt"

REM --- Modo autotest de solo lectura (no toca nada) ---
if /I "%~1"=="/detect" (
    call :DETECT
    if not defined PG_SVC (
        echo   [i] No se detectaron instancias PostgreSQL como servicio de Windows.
    ) else (
        echo   [OK] Deteccion completada. Ver lista arriba.
    )
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 0
)

cls
color 0B
echo  ============================================================================
echo    GESTOR DE PASSWORDS - PostgreSQL (multi-version)
echo  ============================================================================
echo.
echo    Este modulo detecta las instancias PostgreSQL de este equipo y permite
echo    cambiar las passwords de sus roles con login.
echo.

REM --- FASE 0: Privilegios ---
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo   [X] Requiere permisos de Administrador.
    echo [%time%] PostgreSQL: acceso denegado ^(sin admin^) >> "!LOG_FILE!"
    pause
    endlocal
    exit /b 1
)

REM --- FASE 1: Deteccion de instancias ---
echo   [FASE 1/5] Detectando instancias PostgreSQL...
echo.
call :DETECT
if not defined PG_SVC (
    color 0C
    echo   [X] No se encontro ningun servicio PostgreSQL en este equipo.
    echo       ^(El servicio suele llamarse postgresql-x64-XX^)
    echo [%time%] PostgreSQL: no se detectaron instancias >> "!LOG_FILE!"
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 1
)

call :PICK_INSTANCE
if not defined PG_DATADIR (
    echo   [i] Operacion cancelada.
    del /f /q "%DETECT_FILE%" 2>nul
    endlocal
    exit /b 0
)

set "PG_HBA=%PG_DATADIR%\pg_hba.conf"
set "PG_HBA_BAK=%PG_DATADIR%\pg_hba.conf.renggliBak"
if not exist "%PG_BINDIR%\psql.exe" (
    color 0C
    echo   [X] No existe psql.exe en: %PG_BINDIR%
    echo [%time%] PostgreSQL: psql.exe no encontrado en %PG_BINDIR% >> "!LOG_FILE!"
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 1
)
if not exist "%PG_HBA%" (
    color 0C
    echo   [X] No existe pg_hba.conf en: %PG_HBA%
    echo [%time%] PostgreSQL: pg_hba.conf no encontrado en %PG_HBA% >> "!LOG_FILE!"
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 1
)

echo.
echo   Instancia objetivo:
echo     Servicio  : %PG_SVC%
echo     Binarios  : %PG_BINDIR%
echo     Data dir  : %PG_DATADIR%
echo     Puerto    : %PG_PORT%
echo.

REM --- FASE 2: Superusuario + intento de conexion directa ---
echo   [FASE 2/5] Autenticacion
echo.
set "PG_SUPER_INPUT="
set /p "PG_SUPER_INPUT=   Superusuario [postgres]: "
if not "!PG_SUPER_INPUT!"=="" set "PG_SUPER=!PG_SUPER_INPUT!"

set "PG_PWD="
set /p "PG_PWD=   Password del superusuario (Enter si no la conoces): "

set "PGPASSWORD=!PG_PWD!"
call :CONNECT_TEST
if !errorlevel! equ 0 (
    set "PG_MODE=DIRECTO"
    echo   [OK] Conexion directa establecida como '%PG_SUPER%'.
    echo [%time%] PostgreSQL: conexion directa OK ^(%PG_SVC%, super=%PG_SUPER%^) >> "!LOG_FILE!"
) else (
    echo.
    echo   [!] No se pudo conectar con esas credenciales.
    echo.
    echo   MODO RECUPERACION:
    echo     Puedo activar 'trust' temporal en pg_hba.conf solo para localhost,
    echo     recargar la config ^(sin reiniciar el servicio ni cortar conexiones^),
    echo     resetear las passwords y luego restaurar pg_hba.conf original.
    echo.
    echo   [!] Durante esa ventana, cualquier usuario LOCAL puede conectarse sin
    echo       password. No lo uses en un servidor con usuarios locales no confiables.
    echo.
    set "RC_GO="
    set /p "RC_GO=   Activar modo recuperacion? (S/N): "
    if /i not "!RC_GO!"=="S" (
        echo   [i] Operacion cancelada.
        echo [%time%] PostgreSQL: recuperacion rechazada por el usuario >> "!LOG_FILE!"
        del /f /q "%DETECT_FILE%" 2>nul
        endlocal
        exit /b 0
    )
    call :ENABLE_TRUST
    if !errorlevel! neq 0 (
        color 0C
        echo   [X] No se pudo activar el modo recuperacion.
        call :RESTORE_HBA
        del /f /q "%DETECT_FILE%" 2>nul
        pause
        endlocal
        exit /b 1
    )
    set "PGPASSWORD="
    call :CONNECT_TEST
    if !errorlevel! neq 0 (
        color 0C
        echo   [X] Aun con trust no se pudo conectar. Revisa el servicio.
        call :RESTORE_HBA
        del /f /q "%DETECT_FILE%" 2>nul
        pause
        endlocal
        exit /b 1
    )
    set "PG_MODE=RECUPERACION"
    echo   [OK] Modo recuperacion activo ^(trust temporal^).
    echo [%time%] PostgreSQL: modo recuperacion activado ^(%PG_SVC%^) >> "!LOG_FILE!"
)

REM --- FASE 3: Enumerar y seleccionar roles ---
echo.
echo   [FASE 3/5] Roles con login
echo.
call :GET_ROLES
if not defined PG_ROLES (
    color 0C
    echo   [X] No se pudieron obtener los roles.
    call :RESTORE_HBA
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 1
)
call :SHOW_ROLES
call :SELECT_ROLES
if not defined PG_SELECTED (
    echo   [i] No se selecciono ningun rol. Saliendo sin cambios.
    call :RESTORE_HBA
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 0
)

REM --- FASE 4: Password nueva + confirmacion ---
echo.
echo   [FASE 4/5] Nueva password (se aplica a TODOS los roles seleccionados)
echo.
call :ASK_NEW_PWD

echo.
echo   Roles a modificar:!PG_SELECTED_DISPLAY!
echo.
set "GO="
set /p "GO=   Proceder con el cambio? (S/N): "
if /i not "!GO!"=="S" (
    echo   [i] Operacion cancelada.
    call :RESTORE_HBA
    del /f /q "%DETECT_FILE%" 2>nul
    pause
    endlocal
    exit /b 0
)

REM --- FASE 5: Aplicar cambios ---
echo.
echo   [FASE 5/5] Aplicando cambios...
echo.
echo   [i] Nota: si el servidor tiene log_statement=ddl/all, el ALTER puede
echo       aparecer en los logs de PostgreSQL. Limpialos si es sensible.
echo.
set "PG_OK="
set "PG_FAIL="
for %%R in (!PG_SELECTED!) do (
    call :CHANGE_PWD "%%~R" "!NEWPWD!"
    if !errorlevel! equ 0 (
        set "PG_OK=!PG_OK! %%~R"
        echo      [+] %%~R  - OK
    ) else (
        set "PG_FAIL=!PG_FAIL! %%~R"
        echo      [X] %%~R  - FALLO
    )
)

REM --- Restaurar pg_hba si estaba en recuperacion ---
call :RESTORE_HBA

echo.
echo  ============================================================================
echo    RESUMEN
echo  ============================================================================
echo    Modo         : %PG_MODE%
echo    Exitos       :!PG_OK!
echo    Fallos       :!PG_FAIL!
echo  ============================================================================
echo    Conectar con un rol cambiado:
echo      "%PG_BINDIR%\psql.exe" -h 127.0.0.1 -p %PG_PORT% -U ^<rol^> -d postgres
echo.
echo    ANOTA LA PASSWORD EN UN LUGAR SEGURO ANTES DE CERRAR.
echo  ============================================================================
echo [%time%] PostgreSQL: cambios aplicados (OK:!PG_OK! ^| FAIL:!PG_FAIL!) >> "!LOG_FILE!"
del /f /q "%DETECT_FILE%" 2>nul
pause
endlocal
exit /b 0

REM ============================================================================
REM  FUNCIONES
REM ============================================================================

:DETECT
REM Detecta servicios postgresql* y extrae bindir, datadir y puerto a un temp file
powershell -NoProfile -Command ^
    "$Q=[char]34;" ^
    "$svcs = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'postgresql*' };" ^
    "foreach($s in $svcs){" ^
    "  $p=$s.PathName; $bin=''; $data='';" ^
    "  if($p -match ('^'+$Q+'([^'+$Q+']+)'+$Q)){ $bin=Split-Path $matches[1] } elseif($p -match '^(\S+)'){ $bin=Split-Path $matches[1] };" ^
    "  if($p -match ('-D\s+'+$Q+'([^'+$Q+']+)'+$Q)){ $data=$matches[1] } elseif($p -match '-D\s+(\S+)'){ $data=$matches[1] };" ^
    "  $port='5432'; if($data){ $conf=Join-Path $data 'postgresql.conf'; if(Test-Path -LiteralPath $conf){ $m=Select-String -Path $conf -Pattern '^\s*port\s*=\s*(\d+)' | Select-Object -First 1; if($m){ $port=$m.Matches[0].Groups[1].Value } } };" ^
    "  Write-Output ($s.Name+'|'+$bin+'|'+$data+'|'+$port)" ^
    "}" > "%DETECT_FILE%" 2>nul

set "PG_IDX=0"
echo   Instancias detectadas:
echo.
echo      #  Servicio                      Puerto  Data dir
echo      -- ----------------------------- ------- --------------------------------
for /f "usebackq tokens=1,2,3,4 delims=|" %%a in ("%DETECT_FILE%") do (
    set /a PG_IDX+=1
    set "SVC_!PG_IDX!=%%a"
    set "BIN_!PG_IDX!=%%b"
    set "DATA_!PG_IDX!=%%c"
    set "PORT_!PG_IDX!=%%d"
    if "!PG_IDX!"=="1" set "PG_SVC=%%a"
    echo      !PG_IDX!. %%a   %%d   %%c
)
echo.
exit /b 0

:PICK_INSTANCE
if "%PG_IDX%"=="0" exit /b 0
if "%PG_IDX%"=="1" (
    set "PG_SVC=!SVC_1!"
    set "PG_BINDIR=!BIN_1!"
    set "PG_DATADIR=!DATA_1!"
    set "PG_PORT=!PORT_1!"
    exit /b 0
)
set "SEL="
set /p "SEL=   Elegi instancia [1-%PG_IDX%] (Enter=cancelar): "
if "!SEL!"=="" exit /b 0
for /f "delims=0123456789" %%x in ("!SEL!") do set "SEL="
if not defined SEL exit /b 0
if !SEL! lss 1 exit /b 0
if !SEL! gtr %PG_IDX% exit /b 0
set "PG_SVC=!SVC_%SEL%!"
set "PG_BINDIR=!BIN_%SEL%!"
set "PG_DATADIR=!DATA_%SEL%!"
set "PG_PORT=!PORT_%SEL%!"
exit /b 0

:CONNECT_TEST
"%PG_BINDIR%\psql.exe" -h 127.0.0.1 -p %PG_PORT% -U %PG_SUPER% -d postgres -tA -w -c "SELECT 1;" >nul 2>&1
exit /b !errorlevel!

:ENABLE_TRUST
REM Prepende lineas trust para localhost al inicio de pg_hba.conf (primera coincidencia gana)
copy /Y "%PG_HBA%" "%PG_HBA_BAK%" >nul 2>&1
if errorlevel 1 (
    echo   [X] No se pudo respaldar pg_hba.conf
    exit /b 1
)
powershell -NoProfile -Command ^
    "$hba='%PG_HBA%';" ^
    "$trust=@('# === RENGGLI-TEMP-TRUST ===','local all all trust','host all all 127.0.0.1/32 trust','host all all ::1/128 trust','# === RENGGLI-TEMP-TRUST-END ===');" ^
    "$orig=Get-Content -LiteralPath $hba;" ^
    "Set-Content -LiteralPath $hba -Value ($trust + $orig) -Encoding ASCII" >nul 2>&1
if errorlevel 1 (
    echo   [X] No se pudo escribir pg_hba.conf
    exit /b 1
)
set "TRUST_ACTIVE=1"
call :RELOAD
REM Dar un instante a que el postmaster relea la config
timeout /t 2 /nobreak >nul 2>&1
exit /b 0

:RESTORE_HBA
if "%TRUST_ACTIVE%"=="1" (
    if exist "%PG_HBA_BAK%" (
        copy /Y "%PG_HBA_BAK%" "%PG_HBA%" >nul 2>&1
        del /f /q "%PG_HBA_BAK%" >nul 2>&1
        call :RELOAD
        echo   [OK] pg_hba.conf original restaurado.
        echo [%time%] PostgreSQL: pg_hba.conf restaurado >> "!LOG_FILE!"
    )
    set "TRUST_ACTIVE=0"
)
exit /b 0

:RELOAD
"%PG_BINDIR%\pg_ctl.exe" reload -D "%PG_DATADIR%" >nul 2>&1
if errorlevel 1 (
    REM Fallback: recargar via reinicio del servicio (mas invasivo)
    powershell -NoProfile -Command "Restart-Service -Name '%PG_SVC%' -Force -ErrorAction SilentlyContinue" >nul 2>&1
)
exit /b 0

:GET_ROLES
set "PG_ROLES="
set "ROLES_OUT=%TEMP%\rpg_roles_%RANDOM%.txt"
"%PG_BINDIR%\psql.exe" -h 127.0.0.1 -p %PG_PORT% -U %PG_SUPER% -d postgres -tA -w -c "SELECT rolname FROM pg_authid WHERE rolcanlogin = true ORDER BY 1;" > "%ROLES_OUT%" 2>nul
if errorlevel 1 (
    del /f /q "%ROLES_OUT%" 2>nul
    exit /b 1
)
REM CRLF -> LF para que for /f no arrastre el retorno de carro
powershell -NoProfile -Command "$c=Get-Content -LiteralPath '%ROLES_OUT%' -Raw; if($c){[System.IO.File]::WriteAllText('%ROLES_OUT%', $c.Replace([char]13,''), (New-Object System.Text.ASCIIEncoding))}" >nul 2>&1
set "PG_ROLE_IDX=0"
for /f "usebackq tokens=* delims=" %%r in ("%ROLES_OUT%") do (
    if not "%%r"=="" (
        set /a PG_ROLE_IDX+=1
        set "ROLE_!PG_ROLE_IDX!=%%r"
        set "PG_ROLES=!PG_ROLES!%%r;"
    )
)
del /f /q "%ROLES_OUT%" 2>nul
if "!PG_ROLE_IDX!"=="0" set "PG_ROLES="
exit /b 0

:SHOW_ROLES
echo   Roles con login detectados:
echo.
for /l %%i in (1,1,%PG_ROLE_IDX%) do (
    echo      %%i. !ROLE_%%i!
)
echo.
exit /b 0

:SELECT_ROLES
set "PG_SELECTED="
set "PG_SELECTED_DISPLAY="
set "INPUT="
set /p "INPUT=   Numeros a cambiar (ej: 1,3) o 'todos' (Enter=cancelar): "
if "!INPUT!"=="" exit /b 0
if /i "!INPUT!"=="todos" (
    for /l %%i in (1,1,%PG_ROLE_IDX%) do (
        set "PG_SELECTED=!PG_SELECTED! "!ROLE_%%i!""
        set "PG_SELECTED_DISPLAY=!PG_SELECTED_DISPLAY! !ROLE_%%i!"
    )
    exit /b 0
)
set "INPUT_CLEAN=!INPUT:,= !"
for %%n in (!INPUT_CLEAN!) do (
    set "VALIDNUM=%%n"
    for /f "delims=0123456789" %%z in ("%%n") do set "VALIDNUM="
    if defined VALIDNUM (
        if %%n geq 1 if %%n leq %PG_ROLE_IDX% (
            set "PG_SELECTED=!PG_SELECTED! "!ROLE_%%n!""
            set "PG_SELECTED_DISPLAY=!PG_SELECTED_DISPLAY! !ROLE_%%n!"
        )
    )
)
exit /b 0

:ASK_NEW_PWD
set "NEWPWD="
set "NEWPWD2="
:ASK_PWD_AGAIN
set /p "NEWPWD=   Nueva password (visible al tipear): "
if "!NEWPWD!"=="" (
    echo   [X] La password no puede estar vacia.
    goto :ASK_PWD_AGAIN
)
set /p "NEWPWD2=   Confirma la password: "
if not "!NEWPWD!"=="!NEWPWD2!" (
    echo   [X] No coinciden. Intenta de nuevo.
    goto :ASK_PWD_AGAIN
)
exit /b 0

:CHANGE_PWD
REM %1 = rol, %2 = password. Usa archivo SQL temporal y escapa comillas simples.
set "CP_ROLE=%~1"
set "CP_PWD=%~2"
set "CP_PWD_ESC=!CP_PWD:'=''!"
set "CP_SQL=%TEMP%\rpg_alter_%RANDOM%.sql"
> "%CP_SQL%" echo ALTER USER "%CP_ROLE%" WITH PASSWORD '%CP_PWD_ESC%';
"%PG_BINDIR%\psql.exe" -h 127.0.0.1 -p %PG_PORT% -U %PG_SUPER% -d postgres -tA -w -f "%CP_SQL%" >nul 2>nul
set "CP_RC=!errorlevel!"
del /f /q "%CP_SQL%" 2>nul
exit /b !CP_RC!
