@echo off
setlocal enabledelayedexpansion
title Sistema de Gestion Renggli V5.2 - Colegio San Jose
mode con: cols=90 lines=40

net session >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] Este script debe ejecutarse como ADMINISTRADOR.
    echo [i] Clic derecho ^> Ejecutar como administrador.
    pause
    exit /b 1
)

set "TARGET_USER_ALUMNO=Usuario"
set "DEFAULT_ROOT_DIR=C:\Trabajos Alumnos"
set "DEFAULT_DRIVE_LETTER=T:"
set "USER_ALUMNO=%TARGET_USER_ALUMNO%"
set "ROOT_DIR=%DEFAULT_ROOT_DIR%"
set "DRIVE_LETTER=%DEFAULT_DRIVE_LETTER%"
set "USER_HIVE="
set "TEMP_HIVE=HKU\AL_TEMP"
set "MODE_KEY=HKLM\SOFTWARE\Renggli\BlindajeV1"
set "BIN_CLSID={645FF040-5081-101B-9F08-00AA002F954E}"
set "SEC_DIR="
set "PROFILE_DIR="
set "CONFIG_KEY=%MODE_KEY%\Config"
set "LOGON_MAP_VALUE=RenggliDriveMap"

call :LOAD_SAVED_CONFIG
call :REFRESH_DERIVED_PATHS

:MENU
cls
color 0B
echo ======================================================================
echo           SISTEMA DE GESTION DE GABINETE - COLEGIO SAN JOSE
echo ======================================================================
echo.
echo    Alumno objetivo: %USER_ALUMNO%
echo    Carpeta raiz:    %ROOT_DIR%
echo    Unidad virtual:  %DRIVE_LETTER%
echo.
echo    [1] APLICAR BLINDAJE ESTRICTO
echo    [2] DESHACER TODO ^(revertir cambios^)
echo    [3] VERIFICAR ESTADO ACTUAL
echo    [4] CONFIGURAR RUTA/UNIDAD
echo    [5] SALIR
echo.
echo    Manual exclusivo: blindajev1_MANUAL.md
echo.
set "opt="
set /p "opt=Seleccione una opcion [1-5]: "

if "%opt%"=="1" (
    call :CONFIRMAR_Y_APLICAR
    pause
    goto MENU
)
if "%opt%"=="2" goto DESHACER
if "%opt%"=="3" goto VERIFICAR
if "%opt%"=="4" (
    call :CONFIGURAR_PARAMETROS
    pause
    goto MENU
)
if "%opt%"=="5" exit /b 0
goto MENU

:CONFIRMAR_Y_APLICAR
set "USER_ALUMNO=%TARGET_USER_ALUMNO%"
call :REFRESH_DERIVED_PATHS
cls
color 0A
echo ========================================================
echo   CONFIRMACION DE APLICACION
echo ========================================================
echo.
echo  Configuracion actual:
echo    - Alumno:  %TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %ROOT_DIR%
echo    - Unidad:  %DRIVE_LETTER%
echo.
echo  Alcance de cambios:
echo    - Politicas de Explorer: solo para %TARGET_USER_ALUMNO%.
echo    - ACL en %ROOT_DIR% y mapeo de %DRIVE_LETTER%: impacto a nivel equipo.
echo.
set "edit_cfg="
set /p "edit_cfg=Editar parametros antes de aplicar (S/N): "
if /I "%edit_cfg%"=="S" (
    call :CONFIGURAR_PARAMETROS
    if errorlevel 1 (
        echo [i] Aplicacion cancelada.
        exit /b 1
    )
)

call :PRECHECK
if errorlevel 1 exit /b 1

echo.
echo  Se aplicara BLINDAJE ESTRICTO.
echo  Recomendado cuando queres priorizar que no se borre nada.
echo.
echo  Este modo tambien mantiene acceso diario a:
echo    - Escritorio
echo    - Documentos
echo    - Descargas
echo    - Musica
echo    - Imagenes
echo    - Videos
echo.
echo  Requisitos:
echo    - La sesion del alumno debe estar cerrada.
echo    - Reiniciar o cerrar sesion despues de aplicar.
echo    - No se modifica contenido existente de Escritorio.
echo.

set "confirm_apply="
set /p "confirm_apply=Confirmar aplicacion (S/N): "
if /I not "%confirm_apply%"=="S" (
    echo [i] Operacion cancelada.
    exit /b 1
)

call :APPLY_STRICT
exit /b %errorlevel%

:PRECHECK
if not exist "%USER_HIVE%" (
    color 0C
    echo [X] No existe NTUSER.DAT para %USER_ALUMNO%.
    echo [i] Ruta esperada: %USER_HIVE%
    exit /b 1
)

echo [.] Validando que la sesion de %USER_ALUMNO% este cerrada...
reg unload "%TEMP_HIVE%" >nul 2>&1
reg load "%TEMP_HIVE%" "%USER_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] La sesion de %USER_ALUMNO% debe estar CERRADA para aplicar cambios.
    echo [i] Cierra la sesion del usuario objetivo y reintenta.
    exit /b 1
)
reg unload "%TEMP_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] No se pudo descargar el hive temporal de %USER_ALUMNO%.
    echo [i] Reinicia el equipo y vuelve a intentar.
    exit /b 1
)
echo [OK] Sesion del usuario objetivo validada.
exit /b 0

:CONFIGURAR_PARAMETROS
cls
color 0E
echo ========================================================
echo   CONFIGURAR RUTA Y UNIDAD
echo ========================================================
echo.
echo  [i] Enter mantiene el valor actual.
echo  [i] Usuario objetivo fijo: %TARGET_USER_ALUMNO%
echo  [i] Formato carpeta:
echo      - Recomendado: C:\Trabajos Alumnos
echo      - Si escribis solo un nombre ^(ej: Trabajos Alumnos^), se usara C:\<nombre>
echo  [i] Formato unidad:
echo      - Letra sola o con : ^(ej: T o T:^)
echo.
echo  Valores actuales:
echo    - Alumno:  %TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %ROOT_DIR%
echo    - Unidad:  %DRIVE_LETTER%
echo.

set "OLD_ROOT_DIR=%ROOT_DIR%"
set "OLD_DRIVE_LETTER=%DRIVE_LETTER%"

set "new_root="
set /p "new_root=Carpeta raiz [%ROOT_DIR%]: "
if not "%new_root%"=="" (
    set "ROOT_DIR=%new_root%"
    call :NORMALIZE_ROOT_DIR
    if errorlevel 1 (
        color 0C
        echo [X] Ruta invalida. Ejemplos validos: C:\Trabajos Alumnos o Trabajos Alumnos.
        set "ROOT_DIR=%OLD_ROOT_DIR%"
        set "DRIVE_LETTER=%OLD_DRIVE_LETTER%"
        call :REFRESH_DERIVED_PATHS
        exit /b 1
    )
)

set "new_drive="
set /p "new_drive=Unidad virtual [%DRIVE_LETTER%]: "
if not "%new_drive%"=="" (
    set "DRIVE_LETTER=%new_drive%"
    call :NORMALIZE_DRIVE_LETTER
    if errorlevel 1 (
        color 0C
        echo [X] Letra de unidad invalida. Usa formato como T o T:
        set "ROOT_DIR=%OLD_ROOT_DIR%"
        set "DRIVE_LETTER=%OLD_DRIVE_LETTER%"
        call :REFRESH_DERIVED_PATHS
        exit /b 1
    )
)

call :REFRESH_DERIVED_PATHS

echo.
echo  Configuracion propuesta:
echo    - Alumno:  %TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %ROOT_DIR%
echo    - Unidad:  %DRIVE_LETTER%
echo.
set "cfg_confirm="
set /p "cfg_confirm=Confirmar estos valores (S/N): "
if /I not "%cfg_confirm%"=="S" (
    set "ROOT_DIR=%OLD_ROOT_DIR%"
    set "DRIVE_LETTER=%OLD_DRIVE_LETTER%"
    call :REFRESH_DERIVED_PATHS
    echo [i] Configuracion cancelada.
    exit /b 1
)

call :SAVE_CONFIG
if errorlevel 1 (
    color 0C
    echo [X] No se pudo guardar la configuracion en registro.
    exit /b 1
)
echo [OK] Configuracion guardada.
exit /b 0

:SAVE_CONFIG
reg add "%CONFIG_KEY%" /v "RootDir" /t REG_SZ /d "%ROOT_DIR%" /f >nul
if errorlevel 1 exit /b 1
reg add "%CONFIG_KEY%" /v "Drive" /t REG_SZ /d "%DRIVE_LETTER%" /f >nul
if errorlevel 1 exit /b 1
exit /b 0

:LOAD_SAVED_CONFIG
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%CONFIG_KEY%" /v "RootDir" 2^>nul') do set "ROOT_DIR=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%CONFIG_KEY%" /v "Drive" 2^>nul') do set "DRIVE_LETTER=%%C"
call :NORMALIZE_ROOT_DIR >nul 2>&1
if errorlevel 1 set "ROOT_DIR=%DEFAULT_ROOT_DIR%"
call :NORMALIZE_DRIVE_LETTER >nul 2>&1
if errorlevel 1 set "DRIVE_LETTER=%DEFAULT_DRIVE_LETTER%"
set "USER_ALUMNO=%TARGET_USER_ALUMNO%"
exit /b 0

:REFRESH_DERIVED_PATHS
set "USER_HIVE=C:\Users\%USER_ALUMNO%\NTUSER.DAT"
set "SEC_DIR=%ROOT_DIR%\SECUNDARIA"
set "PROFILE_DIR=%ROOT_DIR%\PERFIL\%USER_ALUMNO%"
exit /b 0

:LOAD_MARKER_CONTEXT
set "MARKER_STUDENT="
set "MARKER_ROOT="
set "MARKER_DRIVE="

for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%MODE_KEY%" /v "Student" 2^>nul') do set "MARKER_STUDENT=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%MODE_KEY%" /v "RootDir" 2^>nul') do set "MARKER_ROOT=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%MODE_KEY%" /v "Drive" 2^>nul') do set "MARKER_DRIVE=%%C"

if defined MARKER_STUDENT set "USER_ALUMNO=%MARKER_STUDENT%"
if defined MARKER_ROOT set "ROOT_DIR=%MARKER_ROOT%"
if defined MARKER_DRIVE set "DRIVE_LETTER=%MARKER_DRIVE%"

call :NORMALIZE_ROOT_DIR >nul 2>&1
if errorlevel 1 set "ROOT_DIR=%DEFAULT_ROOT_DIR%"
call :NORMALIZE_DRIVE_LETTER >nul 2>&1
if errorlevel 1 set "DRIVE_LETTER=%DEFAULT_DRIVE_LETTER%"
call :REFRESH_DERIVED_PATHS
exit /b 0

:NORMALIZE_DRIVE_LETTER
set "TMP_DRIVE=%DRIVE_LETTER%"
set "TMP_DRIVE=%TMP_DRIVE: =%"
set "TMP_DRIVE=%TMP_DRIVE::=%"
set "TMP_DRIVE=%TMP_DRIVE:~0,1%"
echo(%TMP_DRIVE%| findstr /R /I "^[A-Z]$" >nul
if errorlevel 1 exit /b 1
for %%L in (%TMP_DRIVE%) do set "DRIVE_LETTER=%%L:"
exit /b 0

:NORMALIZE_ROOT_DIR
set "TMP_ROOT=%ROOT_DIR%"
set "TMP_ROOT=%TMP_ROOT:"=%"
set "TMP_ROOT=%TMP_ROOT:/=\%"
if "%TMP_ROOT%"=="" exit /b 1

if "%TMP_ROOT:~1,1%"==":" (
    set "ROOT_DIR=%TMP_ROOT%"
) else (
    set "ROOT_DIR=C:\%TMP_ROOT%"
)

echo(%ROOT_DIR%| findstr /R /I "^[A-Z]:\\.*" >nul
if errorlevel 1 exit /b 1

if "%ROOT_DIR:~-1%"=="\" (
    if not "%ROOT_DIR:~3,1%"=="" set "ROOT_DIR=%ROOT_DIR:~0,-1%"
)
exit /b 0

:PREPARE_STRUCTURE
echo [.] Unificando nombres al formato con guion...
set "SEC_DIR=%ROOT_DIR%\SECUNDARIA"

for %%a in (4to 5to 6to) do (
    if exist "%SEC_DIR%\%%a ECONOMIA" move "%SEC_DIR%\%%a ECONOMIA" "%SEC_DIR%\%%a-Economia" >nul 2>&1
    if exist "%SEC_DIR%\%%a SOCIALES" move "%SEC_DIR%\%%a SOCIALES" "%SEC_DIR%\%%a-Sociales" >nul 2>&1
)

for /D %%d in ("%ROOT_DIR%\PRIMARIA\*-Anio") do (
    set "folder=%%~nd"
    move "%%d" "%ROOT_DIR%\PRIMARIA\!folder:-Anio=!" >nul 2>&1
)

echo [OK] Carpetas normalizadas.
echo [.] Verificando estructura final...

if not exist "%ROOT_DIR%" mkdir "%ROOT_DIR%"
if not exist "%ROOT_DIR%\PRIMARIA" mkdir "%ROOT_DIR%\PRIMARIA"
for %%n in (1ro 2do 3ro 4to 5to 6to) do if not exist "%ROOT_DIR%\PRIMARIA\%%n" mkdir "%ROOT_DIR%\PRIMARIA\%%n"

if not exist "%ROOT_DIR%\SECUNDARIA" mkdir "%ROOT_DIR%\SECUNDARIA"
for %%n in (1ro 2do 3ro) do if not exist "%ROOT_DIR%\SECUNDARIA\%%n" mkdir "%ROOT_DIR%\SECUNDARIA\%%n"

for %%a in (4to 5to 6to) do (
    if not exist "%SEC_DIR%\%%a-Economia" mkdir "%SEC_DIR%\%%a-Economia"
    if not exist "%SEC_DIR%\%%a-Sociales" mkdir "%SEC_DIR%\%%a-Sociales"
)

if not exist "%ROOT_DIR%\PERFIL" mkdir "%ROOT_DIR%\PERFIL"
if not exist "%PROFILE_DIR%" mkdir "%PROFILE_DIR%"
for %%p in (Desktop Documents Downloads Music Pictures Videos) do if not exist "%PROFILE_DIR%\%%p" mkdir "%PROFILE_DIR%\%%p"

echo [OK] Estructura escolar lista.
exit /b 0

:EXPOSE_BGINFO
if exist "C:\BGInfo" (
    if exist "%ROOT_DIR%\BGInfo" (
        echo [OK] BGInfo ya esta disponible en %DRIVE_LETTER%\BGInfo.
    ) else (
        mklink /J "%ROOT_DIR%\BGInfo" "C:\BGInfo" >nul 2>&1
        if errorlevel 1 (
            echo [!] No se pudo exponer BGInfo en %DRIVE_LETTER%\BGInfo.
        ) else (
            echo [OK] BGInfo disponible en %DRIVE_LETTER%\BGInfo.
        )
    )
) else (
    echo [i] C:\BGInfo no existe; se omite exposicion.
)
exit /b 0

:APPLY_DRIVE_MAP
echo [.] Configurando disco virtual %DRIVE_LETTER%...
set "EXPECTED_DOS=\??\%ROOT_DIR%"
set "CURRENT_DOS="
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" 2^>nul') do set "CURRENT_DOS=%%C"

if defined CURRENT_DOS (
    if /I not "%CURRENT_DOS%"=="%EXPECTED_DOS%" (
        echo [X] %DRIVE_LETTER% ya esta asignada a otra ruta: %CURRENT_DOS%
        echo [i] Cambia la letra desde la opcion Configurar ruta/unidad.
        exit /b 1
    )
) else (
    if exist "%DRIVE_LETTER%\" (
        echo [X] %DRIVE_LETTER% ya esta en uso por otra unidad.
        echo [i] Cambia la letra desde la opcion Configurar ruta/unidad.
        exit /b 1
    )
)

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" /t REG_SZ /d "%EXPECTED_DOS%" /f >nul
if errorlevel 1 (
    echo [X] No se pudo mapear %DRIVE_LETTER%.
    exit /b 1
)

if not exist "%DRIVE_LETTER%\" subst %DRIVE_LETTER% "%ROOT_DIR%" >nul 2>&1

if defined CURRENT_DOS (
    echo [OK] %DRIVE_LETTER% ya estaba mapeada correctamente.
) else (
    echo [OK] %DRIVE_LETTER% apunta a %ROOT_DIR%.
)
exit /b 0

:CLEAR_ACL_RULES
echo [.] Limpiando reglas ACL previas para %USER_ALUMNO%...
icacls "%ROOT_DIR%" /remove:d "%USER_ALUMNO%" /T /C >nul 2>&1
icacls "%ROOT_DIR%" /remove:g "%USER_ALUMNO%" /T /C >nul 2>&1
exit /b 0

:APPLY_ACL_STRICT
echo [.] Aplicando ACL de blindaje estricto...
icacls "%ROOT_DIR%" /inheritance:e /T /C >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /grant:r "%USER_ALUMNO%":(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny "%USER_ALUMNO%":(DE,DC) >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny "%USER_ALUMNO%":(CI)(IO)(DC) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny "%USER_ALUMNO%":(OI)(CI)(DE) /T /C >nul
if errorlevel 1 exit /b 1
echo [OK] ACL estricta aplicada.
exit /b 0

:LOAD_HIVE
echo [.] Cargando perfil offline del alumno...
reg load "%TEMP_HIVE%" "%USER_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] ERROR: La sesion del alumno debe estar CERRADA.
    exit /b 1
)
echo [OK] Hive cargado.
exit /b 0

:UNLOAD_HIVE
reg unload "%TEMP_HIVE%" >nul 2>&1
exit /b 0

:APPLY_USER_POLICIES
echo [.] Aplicando politicas del alumno...
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /t REG_DWORD /d 4 /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /t REG_DWORD /d 4 /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul 2>&1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" /t REG_SZ /d "" /f >nul
if errorlevel 1 exit /b 1
echo [OK] Politicas de Explorer aplicadas.
exit /b 0

:APPLY_PROFILE_NORMAL_ACL
echo [.] Habilitando permisos normales en carpetas diarias del perfil...
if not exist "%PROFILE_DIR%" (
    echo [i] Perfil diario no encontrado; se omite ajuste ACL del perfil.
    exit /b 0
)

icacls "%PROFILE_DIR%" /inheritance:d /T /C >nul
if errorlevel 1 exit /b 1
icacls "%PROFILE_DIR%" /remove:d "%USER_ALUMNO%" /T /C >nul 2>&1
icacls "%PROFILE_DIR%" /grant:r "%USER_ALUMNO%":(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1

echo [OK] Perfil diario con permisos normales para %USER_ALUMNO%.
exit /b 0

:APPLY_DAILY_FOLDERS_EXCEPTION
echo [.] Aplicando excepcion para carpetas diarias del alumno...
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Personal" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Music" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Pictures" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Video" /t REG_EXPAND_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Videos" /f >nul
if errorlevel 1 exit /b 1

reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Music" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Pictures" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Video" /t REG_SZ /d "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Videos" /f >nul
if errorlevel 1 exit /b 1

echo [OK] Excepcion de carpetas diarias aplicada.
exit /b 0

:SYNC_VISIBLE_FOLDERS
echo [.] Copiando contenido actual de Escritorio y Musica ^(sin borrar origen^)...
call :SYNC_FOLDER "C:\Users\%USER_ALUMNO%\Desktop" "%PROFILE_DIR%\Desktop" "Escritorio"
if errorlevel 1 exit /b 1
call :SYNC_FOLDER "C:\Users\%USER_ALUMNO%\Music" "%PROFILE_DIR%\Music" "Musica"
if errorlevel 1 exit /b 1
echo [OK] Copia inicial completada.
exit /b 0

:SYNC_FOLDER
set "SRC_PATH=%~1"
set "DST_PATH=%~2"
set "FOLDER_NAME=%~3"

if not exist "%SRC_PATH%" (
    echo [i] %FOLDER_NAME%: origen no encontrado, se omite.
    exit /b 0
)

if not exist "%DST_PATH%" mkdir "%DST_PATH%" >nul 2>&1
robocopy "%SRC_PATH%" "%DST_PATH%" /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >nul
set "ROBO_RC=%errorlevel%"
if %ROBO_RC% GEQ 8 (
    echo [!] %FOLDER_NAME%: error al copiar ^(codigo %ROBO_RC%^).
    exit /b 1
)

echo [OK] %FOLDER_NAME% copiada.
exit /b 0

:APPLY_LOGON_DRIVE_REMAP
echo [.] Configurando re-mapeo automatico de %DRIVE_LETTER% al iniciar sesion...
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%LOGON_MAP_VALUE%" /t REG_SZ /d "cmd /c if not exist %DRIVE_LETTER%\ subst %DRIVE_LETTER% ""%ROOT_DIR%""" /f >nul
if errorlevel 1 exit /b 1
echo [OK] Re-mapeo automatico configurado.
exit /b 0

:WRITE_MODE_MARKER
reg add "%MODE_KEY%" /v "Mode" /t REG_SZ /d "%~1" /f >nul
if errorlevel 1 exit /b 1
reg add "%MODE_KEY%" /v "Student" /t REG_SZ /d "%USER_ALUMNO%" /f >nul
if errorlevel 1 exit /b 1
reg add "%MODE_KEY%" /v "RootDir" /t REG_SZ /d "%ROOT_DIR%" /f >nul
if errorlevel 1 exit /b 1
reg add "%MODE_KEY%" /v "Drive" /t REG_SZ /d "%DRIVE_LETTER%" /f >nul
if errorlevel 1 exit /b 1
exit /b 0

:APPLY_STRICT
cls
color 0A
echo [+] INICIANDO BLINDAJE ESTRICTO...
echo.
call :PREPARE_STRUCTURE
if errorlevel 1 exit /b 1
call :APPLY_DRIVE_MAP
if errorlevel 1 exit /b 1
call :CLEAR_ACL_RULES
call :APPLY_ACL_STRICT
if errorlevel 1 (
    echo [X] Fallo aplicando ACL estricta.
    exit /b 1
)
call :APPLY_PROFILE_NORMAL_ACL
if errorlevel 1 (
    echo [X] Fallo aplicando permisos normales al perfil diario.
    exit /b 1
)
call :EXPOSE_BGINFO
call :LOAD_HIVE
if errorlevel 1 exit /b 1
call :APPLY_USER_POLICIES
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo aplicando politicas del alumno.
    exit /b 1
)
call :APPLY_DAILY_FOLDERS_EXCEPTION
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo aplicando excepcion de carpetas diarias.
    exit /b 1
)
call :APPLY_LOGON_DRIVE_REMAP
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo configurando re-mapeo automatico de unidad.
    exit /b 1
)
call :SYNC_VISIBLE_FOLDERS
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo copiando contenido de Escritorio/Musica.
    exit /b 1
)

call :UNLOAD_HIVE
call :WRITE_MODE_MARKER STRICT
if errorlevel 1 (
    echo [X] Fallo guardando marcador de modo.
    exit /b 1
)
call :SAVE_CONFIG
if errorlevel 1 (
    echo [!] No se pudo guardar la configuracion para futuras ejecuciones.
)
echo.
echo ========================================================
echo   BLINDAJE ESTRICTO ACTIVADO
echo ========================================================
echo   - Borrado NTFS bloqueado en archivos y carpetas.
echo   - Renombrado de carpetas bloqueado.
echo   - C: oculto y bloqueado en Explorer.
echo   - Excepcion diaria activa: Escritorio/Documentos/Descargas/Musica/Imagenes/Videos.
echo   - En carpetas diarias se permite borrado normal del alumno.
echo   - Re-mapeo automatico al iniciar sesion: activo.
echo   - Papelera endurecida desde Explorer.
echo   - Copia inicial de Escritorio/Musica: sin borrar origen.
echo   - BGInfo: disponible dentro de %DRIVE_LETTER%\BGInfo si existe C:\BGInfo.
echo.
echo   Reinicia o cierra sesion para validar el resultado final.
exit /b 0

:VERIFICAR
cls
color 0B
echo ========================================================
echo   VERIFICACION DE ESTADO DEL BLINDAJE
echo ========================================================
echo.

set "DETECTED_MODE=NO REGISTRADO"
for /f "tokens=3" %%A in ('reg query "%MODE_KEY%" /v Mode 2^>nul ^| findstr /I "Mode"') do set "DETECTED_MODE=%%A"

if /I "!DETECTED_MODE!"=="STRICT" call :LOAD_MARKER_CONTEXT

echo [1/4] Verificando disco %DRIVE_LETTER% ...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" | findstr /I /C:"\??\%ROOT_DIR%" >nul
if errorlevel 1 (
    echo [X] %DRIVE_LETTER% NO esta apuntando a %ROOT_DIR%
) else (
    echo [OK] %DRIVE_LETTER% apunta a %ROOT_DIR%
)
echo.

echo [2/4] Verificando modo registrado ...
if /I "!DETECTED_MODE!"=="STRICT" (
    echo [OK] MODO REGISTRADO: !DETECTED_MODE!
) else (
    echo [!] MODO REGISTRADO: !DETECTED_MODE! ^(esperado: STRICT^)
)
echo.

echo [3/4] Verificando ACL en %ROOT_DIR% ...
set "ACL_DE_OK=0"
set "ACL_DC_OK=0"
icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(DENY)(OI)(CI)(DE)" /C:"%USER_ALUMNO%:(OI)(CI)(DENY)(DE)" /C:"%USER_ALUMNO%:(DENY)(DE,DC)" /C:"%USER_ALUMNO%:(DENY)(DE)" >nul
if not errorlevel 1 set "ACL_DE_OK=1"
icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(DENY)(CI)(IO)(DC)" /C:"%USER_ALUMNO%:(CI)(IO)(DENY)(DC)" /C:"%USER_ALUMNO%:(DENY)(DE,DC)" /C:"%USER_ALUMNO%:(DENY)(DC)" >nul
if not errorlevel 1 set "ACL_DC_OK=1"
if "%ACL_DE_OK%"=="1" (
    if "%ACL_DC_OK%"=="1" (
        echo [OK] ACL estricta detectada ^(bloqueo DE/DC^).
    ) else (
        echo [X] No se detecto la ACL estricta esperada.
    )
) else (
    echo [X] No se detecto la ACL estricta esperada.
)
echo.

echo [4/4] Verificando politicas del usuario %USER_ALUMNO% ...
call :LOAD_HIVE
if errorlevel 1 (
    echo [!] No se pudo cargar NTUSER.DAT. Cierra la sesion de %USER_ALUMNO% para verificar politicas offline.
) else (
    call :CHECK_POLICY NoDrives 0x4
    call :CHECK_POLICY NoViewOnDrive 0x4
    call :CHECK_POLICY NoEmptyRecycleBin 0x1
    call :CHECK_POLICY ConfirmFileDelete 0x1
    reg query "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Bloqueo visual de Papelera NO detectado.
    ) else (
        echo [OK] Bloqueo visual de Papelera detectado.
    )
    call :CHECK_REDIRECT "Desktop" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Desktop"
    call :CHECK_REDIRECT "Personal" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Documents"
    call :CHECK_REDIRECT "{374DE290-123F-4565-9164-39C4925E467B}" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Downloads"
    call :CHECK_REDIRECT "My Music" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Music"
    call :CHECK_REDIRECT "My Pictures" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Pictures"
    call :CHECK_REDIRECT "My Video" "%DRIVE_LETTER%\PERFIL\%USER_ALUMNO%\Videos"
    reg query "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%LOGON_MAP_VALUE%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Re-mapeo automatico de %DRIVE_LETTER% NO detectado.
    ) else (
        echo [OK] Re-mapeo automatico de %DRIVE_LETTER% detectado.
    )
    if exist "%PROFILE_DIR%" (
        icacls "%PROFILE_DIR%" | findstr /I /C:"%USER_ALUMNO%:(DENY)" >nul
        if errorlevel 1 (
            echo [OK] Perfil diario sin denegaciones ACL del alumno.
        ) else (
            echo [!] Perfil diario con denegaciones ACL. Puede bloquear borrado en carpetas diarias.
        )
    ) else (
        echo [i] Perfil diario no encontrado para verificar ACL de excepcion.
    )
    call :UNLOAD_HIVE
)
call :LOAD_SAVED_CONFIG
call :REFRESH_DERIVED_PATHS
echo.
pause
goto MENU

:CHECK_POLICY
reg query "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "%~1" | findstr /I /C:"%~2" >nul
if errorlevel 1 (
    echo [X] %~1 no esta en %~2
) else (
    echo [OK] %~1=%~2
)
exit /b 0

:CHECK_REDIRECT
reg query "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "%~1" | findstr /I /C:"%~2" >nul
if errorlevel 1 (
    echo [X] Redireccion %~1 no detectada hacia %~2
) else (
    echo [OK] Redireccion %~1=%~2
)
exit /b 0

:RESTORE_DAILY_FOLDERS_DEFAULTS
echo [.] Restaurando carpetas diarias por defecto...
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Personal" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Music" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Pictures" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Video" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Videos" /f >nul
if errorlevel 1 exit /b 1

reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Music" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Pictures" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Video" /t REG_SZ /d "C:\Users\%USER_ALUMNO%\Videos" /f >nul
if errorlevel 1 exit /b 1

echo [OK] Carpetas diarias restauradas al perfil local.
exit /b 0

:REMOVE_CREATED_FOLDERS
echo [.] Eliminando carpetas creadas por el blindaje...

rd "%ROOT_DIR%\BGInfo" >nul 2>&1
if exist "%ROOT_DIR%" icacls "%ROOT_DIR%" /grant:r *S-1-5-32-544:(OI)(CI)F /T /C >nul 2>&1

for %%p in (Desktop Documents Downloads Music Pictures Videos) do rd "%PROFILE_DIR%\%%p" >nul 2>&1
rd "%PROFILE_DIR%" >nul 2>&1
rd "%ROOT_DIR%\PERFIL" >nul 2>&1

for %%a in (4to 5to 6to) do (
    rd "%SEC_DIR%\%%a-Economia" >nul 2>&1
    rd "%SEC_DIR%\%%a-Sociales" >nul 2>&1
)

for %%n in (1ro 2do 3ro) do rd "%ROOT_DIR%\SECUNDARIA\%%n" >nul 2>&1
rd "%ROOT_DIR%\SECUNDARIA" >nul 2>&1

for %%n in (1ro 2do 3ro 4to 5to 6to) do rd "%ROOT_DIR%\PRIMARIA\%%n" >nul 2>&1
rd "%ROOT_DIR%\PRIMARIA" >nul 2>&1

rd "%ROOT_DIR%" >nul 2>&1

if exist "%ROOT_DIR%" (
    echo [i] Aun existe %ROOT_DIR% porque tiene contenido.
    set "force_delete_opt="
    set /p "force_delete_opt=Forzar borrado TOTAL de %ROOT_DIR% y todo su contenido (S/N): "
    if /I "%force_delete_opt%"=="S" (
        call :FORCE_DELETE_ROOT
        exit /b %errorlevel%
    )
    echo [i] Se conservaron datos existentes en %ROOT_DIR%.
    exit /b 0
)

echo [OK] Carpetas creadas removidas.
exit /b 0

:FORCE_DELETE_ROOT
if not exist "%ROOT_DIR%" exit /b 0
echo [.] Intentando borrado forzado de %ROOT_DIR%...

if /I "%ROOT_DIR%"=="C:\" (
    echo [X] Seguridad: no se permite borrado forzado de C:\
    exit /b 1
)

takeown /F "%ROOT_DIR%" /R /D Y >nul 2>&1
icacls "%ROOT_DIR%" /inheritance:e /T /C >nul 2>&1
icacls "%ROOT_DIR%" /grant:r *S-1-5-32-544:(OI)(CI)F /T /C >nul 2>&1
attrib -R -S -H "%ROOT_DIR%\*" /S /D >nul 2>&1

rd /s /q "%ROOT_DIR%" >nul 2>&1
if exist "%ROOT_DIR%" (
    set "EMPTY_MIRROR=%TEMP%\renggli_empty_%RANDOM%%RANDOM%"
    mkdir "%EMPTY_MIRROR%" >nul 2>&1
    robocopy "%EMPTY_MIRROR%" "%ROOT_DIR%" /MIR /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >nul
    rd "%EMPTY_MIRROR%" >nul 2>&1
    rd /s /q "%ROOT_DIR%" >nul 2>&1
)

if exist "%ROOT_DIR%" (
    echo [X] No se pudo borrar completamente %ROOT_DIR%.
    echo [i] Causa probable: archivos en uso o bloqueados por otro proceso.
    exit /b 1
)

echo [OK] %ROOT_DIR% eliminado completamente.
exit /b 0

:DESHACER
cls
color 0E
echo [!] REVERTIENDO TODA LA CONFIGURACION...
echo.
set "REVERT_WARN=0"
call :LOAD_MARKER_CONTEXT
subst %DRIVE_LETTER% /D >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" /f >nul 2>&1
reg delete "%MODE_KEY%" /v "Mode" /f >nul 2>&1
reg delete "%MODE_KEY%" /v "Student" /f >nul 2>&1
reg delete "%MODE_KEY%" /v "RootDir" /f >nul 2>&1
reg delete "%MODE_KEY%" /v "Drive" /f >nul 2>&1

if exist "%ROOT_DIR%" (
    icacls "%ROOT_DIR%" /remove:d "%USER_ALUMNO%" /T /C >nul 2>&1
    icacls "%ROOT_DIR%" /remove:g "%USER_ALUMNO%" /T /C >nul 2>&1
)

call :LOAD_HIVE
if errorlevel 1 (
    echo [!] No se pudo cargar NTUSER.DAT. Cierra la sesion de %USER_ALUMNO% para restaurar politicas y carpetas del perfil.
    set "REVERT_WARN=1"
) else (
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%LOGON_MAP_VALUE%" /f >nul 2>&1
    call :RESTORE_DAILY_FOLDERS_DEFAULTS
    if errorlevel 1 set "REVERT_WARN=1"
    call :UNLOAD_HIVE
)

set "remove_dirs_opt="
set /p "remove_dirs_opt=Eliminar carpetas creadas por el blindaje en %ROOT_DIR% (S/N): "
if /I "%remove_dirs_opt%"=="S" (
    call :REMOVE_CREATED_FOLDERS
    if errorlevel 1 set "REVERT_WARN=1"
)

if "%REVERT_WARN%"=="1" (
    echo [!] Reversion parcial completada.
    echo [i] Reintenta con la sesion del alumno cerrada para completar la restauracion.
) else (
    echo [OK] Configuracion revertida.
)
call :LOAD_SAVED_CONFIG
call :REFRESH_DERIVED_PATHS
echo [i] Reinicia o cierra sesion para limpiar Explorer y la unidad virtual.
pause
goto MENU