@echo off
setlocal enabledelayedexpansion
title Sistema de Gestion Renggli V5.1 - Colegio San Jose
mode con: cols=90 lines=38

:: Requiere privilegios de administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    color 0C
    echo [X] Este script debe ejecutarse como ADMINISTRADOR.
    echo [i] Clic derecho ^> Ejecutar como administrador.
    pause
    exit /b 1
)

:: ==========================================
:: CONFIGURACION
:: ==========================================
set "USER_ALUMNO=Usuario"
set "ROOT_DIR=C:\Trabajos Alumnos"
:: ==========================================

:MENU
cls
color 0B
echo ======================================================================
echo           SISTEMA DE GESTION DE GABINETE - COLEGIO SAN JOSE
echo ======================================================================
echo.
echo    [1] APLICAR BLINDAJE ESTRICTO (No borrar en Trabajos Alumnos)
echo    [2] APLICAR ORGANIZACION CONTROLADA (Prioriza mover/renombrar)
echo    [3] DESHACER TODO (Revertir cambios)
echo    [4] VERIFICAR ESTADO ACTUAL
echo    [5] SALIR
echo.
set /p opt="Seleccione una opcion [1-5]: "

if "%opt%"=="1" goto APLICAR
if "%opt%"=="2" goto APLICAR_CONTROLADA
if "%opt%"=="3" goto DESHACER
if "%opt%"=="4" goto VERIFICAR
if "%opt%"=="5" exit
goto MENU

:VERIFICAR
cls
color 0B
echo ========================================================
echo   VERIFICACION DE ESTADO DEL BLINDAJE
echo ========================================================
echo.

echo [1/4] Verificando disco T: ...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "T:" | findstr /I /C:"\??\%ROOT_DIR%" >nul
if %errorlevel% equ 0 (
    echo [OK] T: apunta a %ROOT_DIR%
) else (
    echo [X] T: NO esta apuntando a %ROOT_DIR%
)
echo.

echo [2/4] Verificando permisos NTFS en %ROOT_DIR% ...
icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(DENY)" | findstr /I /C:"DE" >nul
if %errorlevel% equ 0 (
    echo [OK] MODO DETECTADO: ESTRICTO ^(deny de borrado activo^)
) else (
    icacls "%ROOT_DIR%" | findstr /I /C:"%USER_ALUMNO%:(M)" >nul
    if !errorlevel! equ 0 (
        echo [OK] MODO DETECTADO: ORGANIZACION CONTROLADA ^(sin deny duro de borrado^)
    ) else (
        echo [!] No se detecto una regla clara de M o DENY para %USER_ALUMNO%.
    )
)
echo.

echo [3/4] Verificando politicas del usuario %USER_ALUMNO% ...
reg load "HKU\AL_TEMP" "C:\Users\%USER_ALUMNO%\NTUSER.DAT" >nul 2>&1
if %errorlevel% neq 0 (
    echo [!] No se pudo cargar NTUSER.DAT. Cierra la sesion de %USER_ALUMNO% para verificar politicas offline.
) else (
    reg query "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" | findstr /I /C:"0x4" >nul
    if !errorlevel! equ 0 (echo [OK] NoDrives=4) else (echo [X] NoDrives no esta en 4)

    reg query "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" | findstr /I /C:"0x4" >nul
    if !errorlevel! equ 0 (echo [OK] NoViewOnDrive=4) else (echo [X] NoViewOnDrive no esta en 4)

    reg query "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" | findstr /I /C:"0x1" >nul
    if !errorlevel! equ 0 (echo [OK] NoEmptyRecycleBin=1) else (echo [X] NoEmptyRecycleBin no esta en 1)

    reg query "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" | findstr /I /C:"0x1" >nul
    if !errorlevel! equ 0 (echo [OK] NoDeleteFiles=1) else (echo [X] NoDeleteFiles no esta en 1)

    reg unload "HKU\AL_TEMP" >nul
)
echo.

echo [4/4] Verificacion finalizada.
echo.
pause
goto MENU

:APLICAR
cls
color 0A
echo [+] INICIANDO NORMALIZACION (MODO GUION) Y BLINDAJE...
echo.

:: --- FASE 0: NORMALIZACION DE NOMBRES ---
echo [.] Unificando nombres al formato con guion...

:: Corregir carpetas con espacio a nombres con guion (Ej: 6to ECONOMIA -> 6to-Economia)
set "SEC=%ROOT_DIR%\SECUNDARIA"
for %%a in (4to 5to 6to) do (
    if exist "%SEC%\%%a ECONOMIA" move "%SEC%\%%a ECONOMIA" "%SEC%\%%a-Economia" >nul 2>&1
    if exist "%SEC%\%%a SOCIALES" move "%SEC%\%%a SOCIALES" "%SEC%\%%a-Sociales" >nul 2>&1
)

:: Limpiar posibles restos de "-Anio" si quedaron de pruebas viejas
for /D %%d in ("%ROOT_DIR%\PRIMARIA\*-Anio") do (
    set "folder=%%~nd"
    move "%%d" "%ROOT_DIR%\PRIMARIA\!folder:-Anio=!" >nul 2>&1
)

echo [OK] Carpetas normalizadas.

:: --- FASE 1: VERIFICACION Y CREACION ---
echo [.] Verificando estructura final...

if not exist "%ROOT_DIR%" mkdir "%ROOT_DIR%"
if not exist "%ROOT_DIR%\PRIMARIA" mkdir "%ROOT_DIR%\PRIMARIA"
for %%n in (1ro 2do 3ro 4to 5to 6to) do if not exist "%ROOT_DIR%\PRIMARIA\%%n" mkdir "%ROOT_DIR%\PRIMARIA\%%n"

if not exist "%ROOT_DIR%\SECUNDARIA" mkdir "%ROOT_DIR%\SECUNDARIA"
for %%n in (1ro 2do 3ro) do if not exist "%ROOT_DIR%\SECUNDARIA\%%n" mkdir "%ROOT_DIR%\SECUNDARIA\%%n"

for %%a in (4to 5to 6to) do (
    if not exist "%SEC%\%%a-Economia" mkdir "%SEC%\%%a-Economia"
    if not exist "%SEC%\%%a-Sociales" mkdir "%SEC%\%%a-Sociales"
)

:: --- FASE 2: DISCO T ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "T:" /t REG_SZ /d "\??\%ROOT_DIR%" /f >nul

:: --- FASE 3: PERMISOS NTFS ---
echo [.] Aplicando candados NTFS...
icacls "%ROOT_DIR%" /grant %USER_ALUMNO%:(OI)(CI)(M) /T /C >nul
icacls "%ROOT_DIR%" /deny %USER_ALUMNO%:(OI)(CI)(DE,DC) /T /C >nul

:: --- FASE 4: REGISTRO DEL ALUMNO ---
echo [.] Cargando perfil del alumno...
reg load "HKU\AL_TEMP" "C:\Users\%USER_ALUMNO%\NTUSER.DAT" >nul
if %errorLevel% neq 0 (
    color 0C
    echo [X] ERROR: La sesion del alumno debe estar CERRADA.
    pause
    goto MENU
)

reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /t REG_DWORD /d 4 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /t REG_DWORD /d 4 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /t REG_DWORD /d 1 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /t REG_DWORD /d 1 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_SZ /d "" /f >nul

reg unload "HKU\AL_TEMP" >nul

echo.
echo ========================================================
echo   ¡BLINDAJE V5.1 (MODO GUION) COMPLETADO!
echo   REINICIA la PC para ver los cambios.
echo ========================================================
pause
goto MENU

:APLICAR_CONTROLADA
cls
color 0A
echo [+] INICIANDO NORMALIZACION (MODO GUION) Y ORGANIZACION CONTROLADA...
echo.

:: --- FASE 0: NORMALIZACION DE NOMBRES ---
echo [.] Unificando nombres al formato con guion...

set "SEC=%ROOT_DIR%\SECUNDARIA"
for %%a in (4to 5to 6to) do (
    if exist "%SEC%\%%a ECONOMIA" move "%SEC%\%%a ECONOMIA" "%SEC%\%%a-Economia" >nul 2>&1
    if exist "%SEC%\%%a SOCIALES" move "%SEC%\%%a SOCIALES" "%SEC%\%%a-Sociales" >nul 2>&1
)

for /D %%d in ("%ROOT_DIR%\PRIMARIA\*-Anio") do (
    set "folder=%%~nd"
    move "%%d" "%ROOT_DIR%\PRIMARIA\!folder:-Anio=!" >nul 2>&1
)

echo [OK] Carpetas normalizadas.

:: --- FASE 1: VERIFICACION Y CREACION ---
echo [.] Verificando estructura final...

if not exist "%ROOT_DIR%" mkdir "%ROOT_DIR%"
if not exist "%ROOT_DIR%\PRIMARIA" mkdir "%ROOT_DIR%\PRIMARIA"
for %%n in (1ro 2do 3ro 4to 5to 6to) do if not exist "%ROOT_DIR%\PRIMARIA\%%n" mkdir "%ROOT_DIR%\PRIMARIA\%%n"

if not exist "%ROOT_DIR%\SECUNDARIA" mkdir "%ROOT_DIR%\SECUNDARIA"
for %%n in (1ro 2do 3ro) do if not exist "%ROOT_DIR%\SECUNDARIA\%%n" mkdir "%ROOT_DIR%\SECUNDARIA\%%n"

for %%a in (4to 5to 6to) do (
    if not exist "%SEC%\%%a-Economia" mkdir "%SEC%\%%a-Economia"
    if not exist "%SEC%\%%a-Sociales" mkdir "%SEC%\%%a-Sociales"
)

:: --- FASE 2: DISCO T ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "T:" /t REG_SZ /d "\??\%ROOT_DIR%" /f >nul

:: --- FASE 3: PERMISOS NTFS (SIN BLOQUEO DURO DE DELETE) ---
echo [.] Aplicando permisos para organizacion controlada...
icacls "%ROOT_DIR%" /remove:d %USER_ALUMNO% /T /C >nul
icacls "%ROOT_DIR%" /grant %USER_ALUMNO%:(OI)(CI)(M) /T /C >nul

:: --- FASE 4: REGISTRO DEL ALUMNO ---
echo [.] Cargando perfil del alumno...
reg load "HKU\AL_TEMP" "C:\Users\%USER_ALUMNO%\NTUSER.DAT" >nul
if %errorLevel% neq 0 (
    color 0C
    echo [X] ERROR: La sesion del alumno debe estar CERRADA.
    pause
    goto MENU
)

reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /t REG_DWORD /d 4 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /t REG_DWORD /d 4 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /t REG_DWORD /d 1 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /t REG_DWORD /d 1 /f >nul
reg add "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_SZ /d "" /f >nul

reg unload "HKU\AL_TEMP" >nul

echo.
echo ========================================================
echo   ¡ORGANIZACION CONTROLADA ACTIVADA!
echo   Permite organizar/mover con menos friccion.
echo   REINICIA la PC para ver los cambios.
echo ========================================================
pause
goto MENU

:DESHACER
cls
color 0E
echo [!] REVERTIENDO TODA LA CONFIGURACION...
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "T:" /f >nul
icacls "%ROOT_DIR%" /remove:d %USER_ALUMNO% /T /C >nul
icacls "%ROOT_DIR%" /reset /t /c >nul
reg load "HKU\AL_TEMP" "C:\Users\%USER_ALUMNO%\NTUSER.DAT" >nul
if %errorLevel% equ 0 (
    reg delete "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /f >nul
    reg delete "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /f >nul
    reg delete "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /f >nul
    reg delete "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul
    reg delete "HKU\AL_TEMP\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /f >nul
    reg unload "HKU\AL_TEMP" >nul
)
echo [OK] Sistema restaurado. Reinicia la PC.
pause
goto MENU