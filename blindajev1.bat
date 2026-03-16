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

set "USER_ALUMNO=Usuario"
set "ROOT_DIR=C:\Trabajos Alumnos"
set "DRIVE_LETTER=T:"
set "USER_HIVE=C:\Users\%USER_ALUMNO%\NTUSER.DAT"
set "TEMP_HIVE=HKU\AL_TEMP"
set "MODE_KEY=HKLM\SOFTWARE\Renggli\BlindajeV1"
set "BIN_CLSID={645FF040-5081-101B-9F08-00AA002F954E}"
set "SEC_DIR=%ROOT_DIR%\SECUNDARIA"

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
echo    [1] MENU BLINDAJE ESTRICTO
echo    [2] MENU ORGANIZACION CONTROLADA
echo    [3] DESHACER TODO ^(revertir cambios^)
echo    [4] VERIFICAR ESTADO ACTUAL
echo    [5] SALIR
echo.
echo    Manual exclusivo: blindajev1_MANUAL.md
echo.
set "opt="
set /p "opt=Seleccione una opcion [1-5]: "

if "%opt%"=="1" goto MENU_ESTRICTO
if "%opt%"=="2" goto MENU_CONTROLADA
if "%opt%"=="3" goto DESHACER
if "%opt%"=="4" goto VERIFICAR
if "%opt%"=="5" exit /b 0
goto MENU

:MENU_ESTRICTO
cls
color 0E
echo ========================================================
echo   VARIANTE 1 - BLINDAJE ESTRICTO
echo ========================================================
echo.
echo  Objetivo:
echo    - Bloquear borrado de archivos y carpetas dentro de Trabajos Alumnos.
echo    - Bloquear renombrado de carpetas de la estructura escolar.
echo    - Ocultar y bloquear C: para el alumno.
echo    - Bloquear vaciado de papelera desde Explorer.
echo.
echo  Impacto operativo:
echo    - Es la variante mas segura.
echo    - Tambien puede volver mas rigido mover o renombrar archivos.
echo.
echo    [1] APLICAR BLINDAJE ESTRICTO
echo    [0] VOLVER
echo.
set "strict_opt="
set /p "strict_opt=Seleccione una opcion [0-1]: "
if "%strict_opt%"=="1" (
    call :CONFIRMAR_Y_APLICAR STRICT
    pause
    goto MENU
)
if "%strict_opt%"=="0" goto MENU
goto MENU_ESTRICTO

:MENU_CONTROLADA
cls
color 0E
echo ========================================================
echo   VARIANTE 2 - ORGANIZACION CONTROLADA
echo ========================================================
echo.
echo  Objetivo:
echo    - Proteger la estructura de carpetas del aula.
echo    - Bloquear renombrado y borrado de carpetas escolares.
echo    - Mantener menos friccion para mover o renombrar archivos.
echo    - Ocultar y bloquear C: para el alumno.
echo.
echo  Impacto operativo:
echo    - Prioriza operatoria diaria sobre bloqueo NTFS total.
echo    - El borrado individual de archivos no se separa perfecto de mover archivo.
echo.
echo    [1] APLICAR ORGANIZACION CONTROLADA
echo    [0] VOLVER
echo.
set "ctrl_opt="
set /p "ctrl_opt=Seleccione una opcion [0-1]: "
if "%ctrl_opt%"=="1" (
    call :CONFIRMAR_Y_APLICAR CONTROLLED
    pause
    goto MENU
)
if "%ctrl_opt%"=="0" goto MENU
goto MENU_CONTROLADA

:CONFIRMAR_Y_APLICAR
set "TARGET_MODE=%~1"
call :PRECHECK
if errorlevel 1 exit /b 1

cls
color 0A
echo ========================================================
echo   CONFIRMACION DE APLICACION
echo ========================================================
echo.
if /I "%TARGET_MODE%"=="STRICT" (
    echo  Se aplicara BLINDAJE ESTRICTO.
    echo  Recomendado cuando queres priorizar que no se borre nada.
) else (
    echo  Se aplicara ORGANIZACION CONTROLADA.
    echo  Recomendado cuando queres proteger carpetas pero mover archivos con menos friccion.
)
echo.
echo  Requisitos:
echo    - La sesion del alumno debe estar cerrada.
echo    - Reiniciar o cerrar sesion despues de aplicar.
echo.
set "confirm_apply="
set /p "confirm_apply=Confirmar aplicacion (S/N): "
if /I not "%confirm_apply%"=="S" (
    echo [i] Operacion cancelada.
    exit /b 1
)

if /I "%TARGET_MODE%"=="STRICT" (
    call :APPLY_STRICT
    exit /b %errorlevel%
)

call :APPLY_CONTROLLED
exit /b %errorlevel%

:PRECHECK
if not exist "%USER_HIVE%" (
    color 0C
    echo [X] No existe NTUSER.DAT para %USER_ALUMNO%.
    echo [i] Ruta esperada: %USER_HIVE%
    exit /b 1
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

echo [OK] Estructura escolar lista.
exit /b 0

:APPLY_DRIVE_MAP
echo [.] Configurando disco virtual %DRIVE_LETTER%...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" /t REG_SZ /d "\??\%ROOT_DIR%" /f >nul
if errorlevel 1 (
    echo [X] No se pudo mapear %DRIVE_LETTER%.
    exit /b 1
)
echo [OK] %DRIVE_LETTER% apunta a %ROOT_DIR%.
exit /b 0

:CLEAR_ACL_RULES
echo [.] Limpiando reglas ACL previas para %USER_ALUMNO%...
icacls "%ROOT_DIR%" /remove:d %USER_ALUMNO% /T /C >nul 2>&1
icacls "%ROOT_DIR%" /remove:g %USER_ALUMNO% /T /C >nul 2>&1
exit /b 0

:APPLY_ACL_STRICT
echo [.] Aplicando ACL de blindaje estricto...
icacls "%ROOT_DIR%" /grant:r %USER_ALUMNO%:(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny %USER_ALUMNO%:(OI)(CI)(DE,DC) /T /C >nul
if errorlevel 1 exit /b 1
echo [OK] ACL estricta aplicada.
exit /b 0

:APPLY_ACL_CONTROLLED
echo [.] Aplicando ACL de organizacion controlada...
icacls "%ROOT_DIR%" /grant:r %USER_ALUMNO%:(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny %USER_ALUMNO%:(DE,DC) >nul
if errorlevel 1 exit /b 1
icacls "%ROOT_DIR%" /deny %USER_ALUMNO%:(CI)(IO)(DE,DC) /T /C >nul
if errorlevel 1 exit /b 1
echo [OK] ACL controlada aplicada.
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
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg add "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" /t REG_SZ /d "" /f >nul
if errorlevel 1 exit /b 1
echo [OK] Politicas de Explorer aplicadas.
exit /b 0

:WRITE_MODE_MARKER
reg add "%MODE_KEY%" /v "Mode" /t REG_SZ /d "%~1" /f >nul
reg add "%MODE_KEY%" /v "Student" /t REG_SZ /d "%USER_ALUMNO%" /f >nul
reg add "%MODE_KEY%" /v "RootDir" /t REG_SZ /d "%ROOT_DIR%" /f >nul
reg add "%MODE_KEY%" /v "Drive" /t REG_SZ /d "%DRIVE_LETTER%" /f >nul
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
call :LOAD_HIVE
if errorlevel 1 exit /b 1
call :APPLY_USER_POLICIES
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo aplicando politicas del alumno.
    exit /b 1
)
call :UNLOAD_HIVE
call :WRITE_MODE_MARKER STRICT
echo.
echo ========================================================
echo   BLINDAJE ESTRICTO ACTIVADO
echo ========================================================
echo   - Borrado NTFS bloqueado en archivos y carpetas.
echo   - Renombrado de carpetas bloqueado.
echo   - C: oculto y bloqueado en Explorer.
echo   - Papelera endurecida desde Explorer.
echo.
echo   Reinicia o cierra sesion para validar el resultado final.
exit /b 0

:APPLY_CONTROLLED
cls
color 0A
echo [+] INICIANDO ORGANIZACION CONTROLADA...
echo.
call :PREPARE_STRUCTURE
if errorlevel 1 exit /b 1
call :APPLY_DRIVE_MAP
if errorlevel 1 exit /b 1
call :CLEAR_ACL_RULES
call :APPLY_ACL_CONTROLLED
if errorlevel 1 (
    echo [X] Fallo aplicando ACL controlada.
    exit /b 1
)
call :LOAD_HIVE
if errorlevel 1 exit /b 1
call :APPLY_USER_POLICIES
if errorlevel 1 (
    call :UNLOAD_HIVE
    echo [X] Fallo aplicando politicas del alumno.
    exit /b 1
)
call :UNLOAD_HIVE
call :WRITE_MODE_MARKER CONTROLLED
echo.
echo ========================================================
echo   ORGANIZACION CONTROLADA ACTIVADA
echo ========================================================
echo   - Estructura de carpetas protegida.
echo   - Renombrado y borrado de carpetas bloqueado.
echo   - C: oculto y bloqueado en Explorer.
echo   - Menos friccion para mover archivos en operatoria diaria.
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

echo [1/4] Verificando disco %DRIVE_LETTER% ...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" | findstr /I /C:"\??\%ROOT_DIR%" >nul
if errorlevel 1 (
    echo [X] %DRIVE_LETTER% NO esta apuntando a %ROOT_DIR%
) else (
    echo [OK] %DRIVE_LETTER% apunta a %ROOT_DIR%
)
echo.

echo [2/4] Verificando modo registrado ...
echo [OK] MODO REGISTRADO: !DETECTED_MODE!
echo.

echo [3/4] Verificando ACL en %ROOT_DIR% ...
if /I "!DETECTED_MODE!"=="STRICT" (
    icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(OI)(CI)(DENY)(DE,DC)" >nul
    if errorlevel 1 (
        echo [X] No se detecto la ACL estricta esperada.
    ) else (
        echo [OK] ACL estricta detectada.
    )
) else (
    if /I "!DETECTED_MODE!"=="CONTROLLED" (
        icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(DENY)(DE,DC)" /C:"%USER_ALUMNO%:(CI)(IO)(DENY)(DE,DC)" >nul
        if errorlevel 1 (
            echo [X] No se detecto la ACL controlada esperada.
        ) else (
            echo [OK] ACL controlada detectada.
        )
    ) else (
        echo [!] No hay modo registrado. Revisar ACL manualmente.
    )
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
    call :CHECK_POLICY NoDeleteFiles 0x1
    call :CHECK_POLICY ConfirmFileDelete 0x1
    reg query "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Bloqueo visual de Papelera NO detectado.
    ) else (
        echo [OK] Bloqueo visual de Papelera detectado.
    )
    call :UNLOAD_HIVE
)
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

:DESHACER
cls
color 0E
echo [!] REVERTIENDO TODA LA CONFIGURACION...
echo.
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%DRIVE_LETTER%" /f >nul 2>&1
reg delete "%MODE_KEY%" /f >nul 2>&1

if exist "%ROOT_DIR%" (
    icacls "%ROOT_DIR%" /remove:d %USER_ALUMNO% /T /C >nul 2>&1
    icacls "%ROOT_DIR%" /remove:g %USER_ALUMNO% /T /C >nul 2>&1
)

call :LOAD_HIVE
if not errorlevel 1 (
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /f >nul 2>&1
    reg delete "%TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BIN_CLSID%" /f >nul 2>&1
    call :UNLOAD_HIVE
)

echo [OK] Configuracion revertida.
echo [i] Reinicia o cierra sesion para limpiar Explorer y la unidad virtual.
pause
goto MENU