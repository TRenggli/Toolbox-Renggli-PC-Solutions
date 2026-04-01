@echo off
setlocal enabledelayedexpansion
title Renggli PC Solution - Enterprise Toolbox V14
mode con: cols=130 lines=50

:: ==============================================================================
:: CONFIGURACION DE LOGS Y ENTORNO
:: ==============================================================================
set "LOG_DIR=%~dp0Logs"
if not exist "!LOG_DIR!" mkdir "!LOG_DIR!"

:: Fecha ISO (independiente de regionalizacion)
for /f "tokens=*" %%a in ('powershell -Command "Get-Date -Format 'yyyy-MM-dd'"') do set "ISO_DATE=%%a"
set "LOG_FILE=!LOG_DIR!\Audit_!ISO_DATE!.log"

echo [%time%] --- INICIO DE SESION: %username% --- >> "!LOG_FILE!"

:: Parametros opcionales para ejecucion asistida:
::   toolbox.bat /perfil:2 /mod:5
set "CLI_PROFILE="
set "CLI_MOD="
for %%A in (%*) do (
    set "ARG_RAW=%%~A"
    if /I "!ARG_RAW:~0,8!"=="/perfil:" set "CLI_PROFILE=!ARG_RAW:~8!"
    if /I "!ARG_RAW:~0,5!"=="/mod:" set "CLI_MOD=!ARG_RAW:~5!"
)

:: ==============================================================================
:: SEGURIDAD SENIOR: VALIDACION DE PRIVILEGIOS (PRIMERA BARRERA)
:: ==============================================================================
net session >nul 2>&1
if errorlevel 1 (
    color 0C
    echo.
    echo  [!] ERROR: PRIVILEGIOS INSUFICIENTES
    echo  -----------------------------------------------------------------------
    echo  Esta suite requiere permisos de ADMINISTRADOR.
    echo  Audit Log: Se registro intento fallido por %username%.
    echo [%time%] Acceso denegado: Privilegios insuficientes >> "!LOG_FILE!"
    pause
    exit
)

:: ==============================================================================
:: SELECCION DE PERFIL DE EJECUCION (SEGUNDA BARRERA)
:: ==============================================================================
set "PROFILE_MODE="
if defined CLI_PROFILE (
    set "PROFILE_MODE=%CLI_PROFILE%"
    if not "%PROFILE_MODE%"=="1" if not "%PROFILE_MODE%"=="2" if not "%PROFILE_MODE%"=="3" (
        color 0C
        echo.
        echo  [!] Parametro invalido: /perfil:%CLI_PROFILE%
        echo  [i] Usa /perfil:1, /perfil:2 o /perfil:3
        echo [%time%] ERROR parametro /perfil invalido: %CLI_PROFILE% >> "!LOG_FILE!"
        pause
        exit /b 1
    )
    echo [%time%] Perfil preseleccionado por parametro: %PROFILE_MODE% >> "!LOG_FILE!"
    if defined CLI_MOD goto :RUN_NONINTERACTIVE
    goto :MAIN_MENU
)
goto :PROFILE_SELECT

:RUN_NONINTERACTIVE
set "choice=%CLI_MOD%"
set "EXEC_OK=0"
echo [%time%] Ejecucion por parametro: perfil=%PROFILE_MODE% mod=%choice% >> "!LOG_FILE!"
if "%PROFILE_MODE%"=="1" goto :MENU_DIAGNOSTICO_EXEC
if "%PROFILE_MODE%"=="2" goto :MENU_REPARACION_EXEC
if "%PROFILE_MODE%"=="3" goto :MENU_ADMINISTRACION_EXEC
goto :PROFILE_SELECT

:MENU_DIAGNOSTICO_EXEC
if "%choice%"=="1"  (call :MOD_RAM & set "EXEC_OK=1")
if "%choice%"=="2"  (call :MOD_RESOURCES & set "EXEC_OK=1")
if "%choice%"=="3"  (call :MOD_BIOS & set "EXEC_OK=1")
if "%choice%"=="4"  (call :MOD_WU_STATUS & set "EXEC_OK=1")
if "%choice%"=="5"  (call :MOD_DNS & set "EXEC_OK=1")
if "%choice%"=="6"  (call :MOD_SPEED & set "EXEC_OK=1")
if "%choice%"=="7"  (call :MOD_BATTERY & set "EXEC_OK=1")
if "%choice%"=="8"  (call :MOD_EVENT_CRITICAL & set "EXEC_OK=1")
if "%choice%"=="9"  (call :MOD_BSOD_ANALYZER & set "EXEC_OK=1")
if "%choice%"=="10" (call :MOD_PROCESS_AUDIT & set "EXEC_OK=1")
if "%choice%"=="11" (call :MOD_RAID_STATUS & set "EXEC_OK=1")
goto :CHECK_NONINTERACTIVE_RESULT

:MENU_REPARACION_EXEC
if "%choice%"=="1"  (call :MOD_RAM & set "EXEC_OK=1")
if "%choice%"=="2"  (call :MOD_RESOURCES & set "EXEC_OK=1")
if "%choice%"=="3"  (call :MOD_BIOS & set "EXEC_OK=1")
if "%choice%"=="4"  (call :MOD_REPAIR & set "EXEC_OK=1")
if "%choice%"=="5"  (call :MOD_WU & set "EXEC_OK=1")
if "%choice%"=="6"  (call :MOD_CLEAN & set "EXEC_OK=1")
if "%choice%"=="7"  (call :MOD_NET & set "EXEC_OK=1")
if "%choice%"=="8"  (call :MOD_SPEED & set "EXEC_OK=1")
if "%choice%"=="9"  (call :MOD_DNS & set "EXEC_OK=1")
if "%choice%"=="10" (call :MOD_OFF & set "EXEC_OK=1")
if "%choice%"=="11" (call :MOD_WINGET & set "EXEC_OK=1")
if "%choice%"=="12" (call :MOD_BATTERY & set "EXEC_OK=1")
if "%choice%"=="13" (call :MOD_DRIVER_BACKUP & set "EXEC_OK=1")
if "%choice%"=="14" (call :MOD_EVENT_CRITICAL & set "EXEC_OK=1")
if "%choice%"=="15" (call :MOD_BSOD_ANALYZER & set "EXEC_OK=1")
if "%choice%"=="16" (call :MOD_PROCESS_AUDIT & set "EXEC_OK=1")
if "%choice%"=="17" (call :MOD_RAID_STATUS & set "EXEC_OK=1")
goto :CHECK_NONINTERACTIVE_RESULT

:MENU_ADMINISTRACION_EXEC
if "%choice%"=="1"  (call :MOD_BIOS & set "EXEC_OK=1")
if "%choice%"=="2"  (call :MOD_RAM & set "EXEC_OK=1")
if "%choice%"=="3"  (call :MOD_RESOURCES & set "EXEC_OK=1")
if "%choice%"=="4"  (call :MOD_REPAIR & set "EXEC_OK=1")
if "%choice%"=="5"  (call :MOD_WU & set "EXEC_OK=1")
if "%choice%"=="6"  (call :MOD_CLEAN & set "EXEC_OK=1")
if "%choice%"=="7"  (call :MOD_NET & set "EXEC_OK=1")
if "%choice%"=="8"  (call :MOD_SPEED & set "EXEC_OK=1")
if "%choice%"=="9"  (call :MOD_DNS & set "EXEC_OK=1")
if "%choice%"=="10" (call :MOD_FORMAT & set "EXEC_OK=1")
if "%choice%"=="11" (call :MOD_GPT & set "EXEC_OK=1")
if "%choice%"=="12" (call :MOD_WINGET & set "EXEC_OK=1")
if "%choice%"=="13" (call :MOD_MAS & set "EXEC_OK=1")
if "%choice%"=="14" (call :MOD_OFF & set "EXEC_OK=1")
if "%choice%"=="15" (call :MOD_BATTERY & set "EXEC_OK=1")
if "%choice%"=="16" (call :MOD_DRIVER_BACKUP & set "EXEC_OK=1")
if "%choice%"=="17" (call :MOD_EVENT_CRITICAL & set "EXEC_OK=1")
if "%choice%"=="18" (call :MOD_BSOD_ANALYZER & set "EXEC_OK=1")
if "%choice%"=="19" (call :MOD_PROCESS_AUDIT & set "EXEC_OK=1")
if "%choice%"=="20" (call :MOD_RAID_STATUS & set "EXEC_OK=1")
if "%choice%"=="21" (call :MOD_CLASSROOM_SECURITY & goto :MAIN_MENU)
goto :CHECK_NONINTERACTIVE_RESULT

:CHECK_NONINTERACTIVE_RESULT
if "%EXEC_OK%"=="1" goto :EXIT_SCRIPT
color 0C
echo.
echo  [!] Modulo invalido para el perfil %PROFILE_MODE%: /mod:%choice%
echo [%time%] ERROR parametro /mod invalido para perfil %PROFILE_MODE%: %choice% >> "!LOG_FILE!"
pause
exit /b 1

:PROFILE_SELECT
cls
color 0B
echo  ==============================================================================================================
echo                                   Renggli PC Solution - SUITE ENTERPRISE V14
echo  ==============================================================================================================
echo   Log Actual: !LOG_FILE!
echo.
echo   [SELECCION DE PERFIL]
echo.
echo   1. DIAGNOSTICO     - Solo lectura, auditoria y consultas (sin modificaciones)
echo   2. REPARACION      - Mantenimiento y reparaciones automatizadas
echo   3. ADMINISTRACION  - Acceso completo (incluye formateo y conversiones)
echo.
set /p "PROFILE_MODE=> Seleccione perfil [1-3]: "

if "%PROFILE_MODE%"=="1" (
    echo [%time%] Perfil seleccionado: DIAGNOSTICO >> "!LOG_FILE!"
    goto :MAIN_MENU
)
if "%PROFILE_MODE%"=="2" (
    echo [%time%] Perfil seleccionado: REPARACION >> "!LOG_FILE!"
    goto :MAIN_MENU
)
if "%PROFILE_MODE%"=="3" (
    echo [%time%] Perfil seleccionado: ADMINISTRACION >> "!LOG_FILE!"
    goto :MAIN_MENU
)
goto :PROFILE_SELECT

:MAIN_MENU
color 0B
cls
echo  ==============================================================================================================
echo                                   Renggli PC Solution - SUITE ENTERPRISE V14
echo  ==============================================================================================================
echo   Log Actual: !LOG_FILE!

:: Mostrar menu segun perfil seleccionado
if "%PROFILE_MODE%"=="1" goto :MENU_DIAGNOSTICO
if "%PROFILE_MODE%"=="2" goto :MENU_REPARACION
if "%PROFILE_MODE%"=="3" goto :MENU_ADMINISTRACION
goto :MAIN_MENU

:: ==============================================================================
:: MENU PERFIL 1: DIAGNOSTICO (SOLO LECTURA)
:: ==============================================================================
:MENU_DIAGNOSTICO
echo   Perfil Activo: [DIAGNOSTICO] - Solo Lectura
echo.
echo   Este menu es solo de consulta. No realiza cambios en el sistema.
echo   Ideal para auditar hardware, recursos, red y estado de Windows Update.
echo   Nota: El reporte de bateria solo aplica en equipos portatiles.
echo   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible
echo.
echo    [ DIAGNOSTICO BASE ]
echo    1. [R] Test de RAM (mdsched)
echo    2. [R] Info de Recursos del Sistema
echo    3. [R] Info BIOS y Placa Madre
echo    4. [R] Estado de Windows Update
echo    5. [R] Auditoria de Puertos/DNS
echo    6. [R] Test de Velocidad de Red
echo    7. [R] Reporte de Bateria
echo.
echo    [ ANALISIS AVANZADO - SOLO LECTURA ]
echo    8. [R] Eventos Criticos (Sistema)
echo    9. [R] Analisis BSOD (Minidump)
echo    10. [R] Auditoria Forense de Procesos
echo    11. [R] Estado RAID/Storage
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_NO_LOG
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_RESOURCES & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_WU_STATUS & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_BATTERY & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_EVENT_CRITICAL & goto :MAIN_MENU)
if "%choice%"=="9"  (call :MOD_BSOD_ANALYZER & goto :MAIN_MENU)
if "%choice%"=="10" (call :MOD_PROCESS_AUDIT & goto :MAIN_MENU)
if "%choice%"=="11" (call :MOD_RAID_STATUS & goto :MAIN_MENU)

goto :VALIDATE_CHOICE

:: ==============================================================================
:: MENU PERFIL 2: REPARACION (DIAGNOSTICO + MANTENIMIENTO)
:: ==============================================================================
:MENU_REPARACION
echo   Perfil Activo: [REPARACION] - Mantenimiento y Reparaciones
echo.
echo   Incluye diagnostico y tareas que modifican el sistema.
echo   Recomendado para mantenimiento, limpieza y reparaciones guiadas.
echo   Nota: El reporte de bateria solo aplica en equipos portatiles.
echo   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible
echo.
echo    [ REPARACION Y MANTENIMIENTO ]
echo    1. [R] Test de RAM (mdsched)
echo    2. [R] Info de Recursos del Sistema
echo    3. [R] Info BIOS y Placa Madre
echo    4. [W] Mantenimiento (DISM/SFC)
echo    5. [W] Reparar Windows Update
echo    6. [W] Limpieza EMMC/Temporales
echo    7. [W] Reset de Red e IP
echo    8. [R] Test de Velocidad
echo    9. [R] Auditoria de Puertos/DNS
echo    10. [W] Apagado Programado
echo    11. [W] Actualizar Apps (Winget)
echo    12. [R] Reporte de Bateria
echo    13. [W] Backup de Drivers (ESCRIBE EN DISCO)
echo.
echo    [ ANALISIS AVANZADO - SOLO LECTURA ]
echo    14. [R] Eventos Criticos
echo    15. [R] Analisis BSOD
echo    16. [R] Auditoria Forense de Procesos
echo    17. [R] Estado RAID/Storage
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_NO_LOG
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_RESOURCES & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_REPAIR & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_WU & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_CLEAN & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_NET & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="9"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="10" (call :MOD_OFF & goto :MAIN_MENU)
if "%choice%"=="11" (call :MOD_WINGET & goto :MAIN_MENU)
if "%choice%"=="12" (call :MOD_BATTERY & goto :MAIN_MENU)
if "%choice%"=="13" (call :MOD_DRIVER_BACKUP & goto :MAIN_MENU)
if "%choice%"=="14" (call :MOD_EVENT_CRITICAL & goto :MAIN_MENU)
if "%choice%"=="15" (call :MOD_BSOD_ANALYZER & goto :MAIN_MENU)
if "%choice%"=="16" (call :MOD_PROCESS_AUDIT & goto :MAIN_MENU)
if "%choice%"=="17" (call :MOD_RAID_STATUS & goto :MAIN_MENU)

goto :VALIDATE_CHOICE

:: ==============================================================================
:: MENU PERFIL 3: ADMINISTRACION (ACCESO COMPLETO)
:: ==============================================================================
:MENU_ADMINISTRACION
echo   Perfil Activo: [ADMINISTRACION] - Acceso Completo
echo.
echo   Acceso total. Incluye acciones irreversibles y cambios criticos.
echo   Usa este perfil solo si comprendes el impacto de cada operacion.
echo   Nota: El reporte de bateria solo aplica en equipos portatiles.
echo   Leyenda: [R] Solo lectura  [W] Escribe/cambia sistema  [!] Critico/irreversible
echo.
echo    [ ADMINISTRACION OPERATIVA ]
echo    1. [R] Info BIOS y Placa Madre
echo    2. [R] Test de RAM (mdsched)
echo    3. [R] Info de Recursos del Sistema
echo    4. [W] Mantenimiento (DISM/SFC)
echo    5. [W] Reparar Windows Update
echo    6. [W] Limpieza EMMC/Temporales
echo    7. [W] Reset de Red e IP
echo    8. [R] Test de Velocidad Real
echo    9. [R] Auditoria de Puertos/DNS
echo    10. [!] Formateo Seguro (Auditado)
echo    11. [!] Conversion MBR a GPT
echo    12. [W] Actualizar Apps (Winget)
echo    13. [W] ACTIVACION MASTER (MAS)
echo    14. [W] Apagado Programado
echo    15. [R] Reporte de Bateria
echo    16. [W] Backup de Drivers (ESCRIBE EN DISCO)
echo.
echo    [ ANALISIS AVANZADO - SOLO LECTURA ]
echo    17. [R] Eventos Criticos
echo    18. [R] Analisis BSOD
echo    19. [R] Auditoria Forense de Procesos
echo    20. [R] Estado RAID/Storage
echo    21. [W] Perfil Seguridad Alta (Blindaje V1 integrado)
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE Y SIN LOG
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_NO_LOG
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_RESOURCES & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_REPAIR & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_WU & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_CLEAN & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_NET & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="9"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="10" (call :MOD_FORMAT & goto :MAIN_MENU)
if "%choice%"=="11" (call :MOD_GPT & goto :MAIN_MENU)
if "%choice%"=="12" (call :MOD_WINGET & goto :MAIN_MENU)
if "%choice%"=="13" (call :MOD_MAS & goto :MAIN_MENU)
if "%choice%"=="14" (call :MOD_OFF & goto :MAIN_MENU)
if "%choice%"=="15" (call :MOD_BATTERY & goto :MAIN_MENU)
if "%choice%"=="16" (call :MOD_DRIVER_BACKUP & goto :MAIN_MENU)
if "%choice%"=="17" (call :MOD_EVENT_CRITICAL & goto :MAIN_MENU)
if "%choice%"=="18" (call :MOD_BSOD_ANALYZER & goto :MAIN_MENU)
if "%choice%"=="19" (call :MOD_PROCESS_AUDIT & goto :MAIN_MENU)
if "%choice%"=="20" (call :MOD_RAID_STATUS & goto :MAIN_MENU)
if "%choice%"=="21" (call :MOD_CLASSROOM_SECURITY & goto :MAIN_MENU)

goto :VALIDATE_CHOICE

:VALIDATE_CHOICE
:: Si la opcion no es valida:
if not defined choice (goto :MAIN_MENU)
echo.
color 0E
echo [!] Opcion "%choice%" no valida.
echo [!] Opcion %choice% no valida. >> "!LOG_FILE!"
timeout /t 2 >nul
goto :MAIN_MENU

:: ==============================================================================
:: BLOQUE DE MODULOS SENIOR
:: ==============================================================================

:MODULE_CONFIRM
set "MC_TITLE=%~1"
set "MC_WARN=%~2"
set "MC_GO="
echo  [i] %MC_TITLE%
if not "%MC_WARN%"=="" echo  [!] %MC_WARN%
echo.
set /p "MC_GO=Iniciar? (S/N): "
if /i not "%MC_GO%"=="S" exit /b 1
exit /b 0

:WAIT_SERVICE_STOP
set "WS_SVC=%~1"
set "WS_TRIES=0"
:WAIT_SERVICE_STOP_LOOP
sc query "%WS_SVC%" | findstr /I "STOPPED" >nul
if not errorlevel 1 exit /b 0
set /a WS_TRIES+=1
if %WS_TRIES% geq 20 exit /b 1
timeout /t 1 >nul
goto :WAIT_SERVICE_STOP_LOOP

:MOD_BIOS
cls
color 03
echo  ==============================================================================
echo   [INFORMACION DEL SISTEMA] BIOS y Placa Madre
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Abre ventana de Informacion del Sistema." "Se abrira la ventana nativa de Windows."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Informacion del Sistema cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Abriendo Informacion del Sistema...
echo.
echo [%time%] Abierta ventana Informacion del Sistema >> "!LOG_FILE!"
timeout /t 2 >nul
start "" msinfo32.exe
echo  [OK] Ventana abierta. Presiona Enter cuando cierres la ventana para volver al menu.
echo.
pause
exit /b

:MOD_FORMAT
if not "%PROFILE_MODE%"=="3" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Este modulo solo se permite en perfil ADMINISTRACION.
    echo [%time%] Formateo bloqueado: perfil insuficiente >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0C
echo  ==============================================================================
echo   [!] PROTOCOLO DE BORRADO AUDITADO
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Borrado total del disco seleccionado." "Operacion irreversible. Respalda antes."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Formateo cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Listado de discos disponibles:
echo.
(echo list disk) | diskpart
echo.
set /p "dnum=Seleccione numero de disco (Ojo!): "
for /f "delims=0123456789" %%x in ("%dnum%") do set "dnum="
if not defined dnum (
    echo.
    echo [BLOQUEADO] Numero de disco invalido.
    echo ACCION BLOQUEADA: Numero de disco invalido. >> "!LOG_FILE!"
    pause
    exit /b
)
powershell -NoProfile -Command "$n=[int]'%dnum%'; if(Get-Disk -ErrorAction SilentlyContinue | Where-Object Number -eq $n){exit 0}else{exit 1}" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [BLOQUEADO] El disco %dnum% no existe en este equipo.
    echo ACCION BLOQUEADA: Disco inexistente (%dnum%). >> "!LOG_FILE!"
    pause
    exit /b
)
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "$sys=(Get-CimInstance Win32_OperatingSystem).SystemDrive.TrimEnd(':'); $p=Get-Partition -DriveLetter $sys -ErrorAction SilentlyContinue; if($p){$p.DiskNumber}"') do set "SYS_DISK=%%a"
if defined SYS_DISK if "%dnum%"=="!SYS_DISK!" (
    echo.
    echo [BLOQUEADO] No se permite formatear el disco del sistema (Disco !SYS_DISK!).
    echo ACCION BLOQUEADA: Intento de formatear disco de sistema !SYS_DISK!. >> "!LOG_FILE!"
    pause
    exit /b
)
if "%dnum%"=="0" (
    echo.
    echo [BLOQUEADO] No se permite formatear disco de sistema.
    echo ACCION BLOQUEADA: Disco de sistema. >> "!LOG_FILE!"
    pause
    exit /b
)

:: Doble Confirmacion (Mejora Senior)
cls
echo  ==============================================================================
echo   [REVISION DE DISCO SELECCIONADO]
echo  ==============================================================================
echo.
(echo select disk %dnum% & echo detail disk) | diskpart
echo.
echo  [!] ADVERTENCIA: Los datos se perderan permanentemente.
echo.
set /p "confirm=  ¿ESTA SEGURO? Escriba 'CONFIRMO' para continuar: "
if /i "%confirm%"=="CONFIRMO" (
    echo.
    echo  [i] Ejecutando formateo...
    echo [%time%] INICIANDO FORMATEO DISCO %dnum% >> "!LOG_FILE!"
    (echo select disk %dnum% & echo clean & echo create partition primary & echo format fs=fat32 quick & echo assign) | diskpart
    echo.
    echo  [OK] Formateo completado exitosamente.
    echo [OK] Operacion exitosa. >> "!LOG_FILE!"
) else (
    echo.
    echo  [i] Operacion cancelada por el usuario.
    echo [%time%] Formateo cancelado por el usuario. >> "!LOG_FILE!"
)
pause
exit /b

:MOD_SPEED
cls
color 0B
echo  ==============================================================================
echo   [DIAGNOSTICO DE RED] - Test de Velocidad y Conectividad
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Mide latencia y velocidad de descarga." "Puede consumir datos de red."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Test de velocidad cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Midiendo conectividad y velocidad...
echo.

REM Test de ping a Google DNS
echo  [*] Midiendo latencia a 8.8.8.8...
for /f "tokens=4 delims==" %%a in ('ping -n 1 8.8.8.8 ^| findstr "time="') do set "ping_result=%%a"
if not defined ping_result set "ping_result=NO DISPONIBLE"
echo  [OK] Latencia: %ping_result%
echo.

REM Test de velocidad con múltiples URLs
echo  [*] Midiendo velocidad de descarga...
set "speed=NOT_MEASURED"
set "test_urls=https://speed.cloudflare.com/__down?bytes=10485760 https://www.wikipedia.org/static/images/project-logos/en-wikipedia-1.35.0.png https://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"

for %%u in (!test_urls!) do (
    if "!speed!"=="NOT_MEASURED" (
        echo    Intentando: %%u
        for /f "delims=" %%i in ('powershell -Command "try { $s = Get-Date; $tmp = Join-Path $env:TEMP 'toolbox_speed_test.tmp'; $cl = New-Object System.Net.WebClient; $cl.DownloadFile('%%u', $tmp); $e = Get-Date; $bytes = (Get-Item $tmp).Length; $seconds = [math]::max(($e-$s).TotalSeconds, 0.1); $mbps = [Math]::Round(($bytes/1024/1024 * 8 / $seconds), 2); Write-Output $mbps; Remove-Item $tmp -ErrorAction SilentlyContinue } catch { Write-Output 'FAIL' }"') do set "speed=%%i"
        
        if not "!speed!"=="FAIL" (
            if not "!speed!"=="NOT_MEASURED" goto :SPEED_SUCCESS
        )
        set "speed=NOT_MEASURED"
    )
)

:SPEED_SUCCESS
if "!speed!"=="NOT_MEASURED" (
    echo.
    echo  [!] No se pudo medir velocidad de descarga
    echo  [i] Verifica tu conexion a internet
    echo [%time%] Test de velocidad: NO MEDIDO >> "!LOG_FILE!"
) else (
    echo    Velocidad: !speed! Mbps
    echo.
    echo  [OK] Test de velocidad completado
    echo [%time%] Test de velocidad: !speed! Mbps >> "!LOG_FILE!"
)
echo.
pause
exit /b

:MOD_RAM
cls
color 0D
echo  ==============================================================================
echo   [DIAGNOSTICO MEMORIA RAM]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Lanza el diagnostico de memoria de Windows." "El sistema puede reiniciarse. Guarda tu trabajo."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Diagnostico de RAM cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Ejecutando Windows Memory Diagnostic...
echo  [!] El sistema se reiniciara para realizar la prueba.
echo.
echo [%time%] Lanzado diagnostico de RAM (mdsched) >> "!LOG_FILE!"
pause
mdsched.exe
exit /b

:MOD_REPAIR
:: Validacion de perfil
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion modifica el sistema.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Reparacion bloqueada: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0E
echo  ==============================================================================
echo   [REPARACION DE SISTEMA] DISM + SFC
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Repara imagen del sistema y archivos (DISM/SFC)." "No interrumpir el proceso."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] DISM/SFC cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Paso 1/3: Verificando salud del sistema...
echo [%time%] Iniciando DISM >> "!LOG_FILE!"
DISM /Online /Cleanup-Image /CheckHealth
echo.
echo  [i] Paso 2/3: Reparando imagen del sistema...
DISM /Online /Cleanup-Image /RestoreHealth
if errorlevel 1 (
    echo.
    echo  [X] DISM /RestoreHealth fallo. Se cancela SFC para evitar reparacion sobre imagen inconsistente.
    echo [%time%] ERROR: DISM /RestoreHealth fallo. SFC cancelado. >> "!LOG_FILE!"
    pause
    exit /b
)
echo.
echo  [i] Paso 3/3: Verificando archivos de sistema...
echo [%time%] Iniciando SFC >> "!LOG_FILE!"
sfc /scannow
echo.
echo  [OK] Proceso de reparacion completado.
echo [%time%] DISM/SFC completado >> "!LOG_FILE!"
pause
exit /b

:MOD_WU
:: Validacion de perfil
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion modifica servicios y archivos del sistema.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Windows Update bloqueado: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0B
echo  ==============================================================================
echo   [REPARACION WINDOWS UPDATE]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Repara componentes de Windows Update." "Se reiniciaran servicios del sistema."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Windows Update cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Deteniendo servicios...
net stop wuauserv
net stop cryptSvc
net stop bits
net stop msiserver
for %%s in (wuauserv cryptSvc bits msiserver) do (
    call :WAIT_SERVICE_STOP %%s
    if errorlevel 1 (
        echo.
        echo  [X] El servicio %%s no se detuvo a tiempo. Se cancela reparacion de Windows Update.
        echo [%time%] ERROR: servicio %%s no se detuvo en MOD_WU >> "!LOG_FILE!"
        pause
        exit /b
    )
)
echo.
echo  [i] Limpiando cache de Windows Update...
if exist C:\Windows\SoftwareDistribution (
    if exist C:\Windows\SoftwareDistribution.old rd /s /q C:\Windows\SoftwareDistribution.old
    ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
    if errorlevel 1 (
        echo  [!] No se pudo renombrar SoftwareDistribution ^(probablemente en uso^).
        echo [%time%] ADVERTENCIA: No se pudo renombrar SoftwareDistribution >> "!LOG_FILE!"
    )
)
if exist C:\Windows\System32\catroot2 (
    if exist C:\Windows\System32\catroot2.old rd /s /q C:\Windows\System32\catroot2.old
    ren C:\Windows\System32\catroot2 catroot2.old
    if errorlevel 1 (
        echo  [!] No se pudo renombrar catroot2 ^(probablemente en uso^).
        echo [%time%] ADVERTENCIA: No se pudo renombrar catroot2 >> "!LOG_FILE!"
    )
)
echo.
echo  [i] Reiniciando servicios...
net start wuauserv
net start cryptSvc
net start bits
net start msiserver
echo.
echo  [OK] Windows Update reparado.
echo [%time%] Windows Update reparado >> "!LOG_FILE!"
pause
exit /b

:MOD_CLEAN
:: Validacion de perfil
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion elimina archivos temporales.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Limpieza bloqueada: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0A
echo  ==============================================================================
echo   [LIMPIEZA DE ARCHIVOS TEMPORALES]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Elimina archivos temporales y ejecuta limpieza." "Puede borrar cache y temporales."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Limpieza cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Limpiando carpetas temporales...
del /q /f /s %TEMP%\* 2>nul
del /q /f /s C:\Windows\Temp\* 2>nul
echo.
echo  [i] Ejecutando Disk Cleanup...
reg query "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches" /s /f "StateFlags0001" >nul 2>&1
if errorlevel 1 (
    echo  [i] Preset de limpieza ^(/sagerun:1^) no configurado. Ejecutando limpieza rapida automatica...
    cleanmgr /verylowdisk
) else (
    cleanmgr /sagerun:1
)
echo.
echo  [OK] Limpieza completada.
echo [%time%] Limpieza de temporales ejecutada >> "!LOG_FILE!"
pause
exit /b

:MOD_NET
:: Validacion de perfil
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion modifica la configuracion de red.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Reset de red bloqueado: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0B
echo  ==============================================================================
echo   [RESET DE RED E IP]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Resetea IP, DNS y Winsock." "La red puede desconectarse temporalmente."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Reset de red cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Liberando configuracion IP...
ipconfig /release
echo  [i] Renovando IP...
ipconfig /renew
echo  [i] Limpiando cache DNS...
ipconfig /flushdns
echo  [i] Reseteando Winsock...
netsh winsock reset
echo  [i] Reseteando IP...
netsh int ip reset
echo.
echo  [OK] Reset de red completado.
echo [%time%] Reset de red ejecutado >> "!LOG_FILE!"
pause
exit /b

:MOD_DNS
cls
color 03
echo  ==============================================================================
echo   [AUDITORIA DNS Y PUERTOS]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Muestra DNS en cache y puertos en escucha." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Auditoria DNS/Puertos cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Configuracion DNS actual:
ipconfig /displaydns | findstr /i "Record Name"
echo.
echo  [i] Puertos en escucha:
netstat -ano | findstr LISTENING
echo.
echo [%time%] Auditoria DNS/Puertos >> "!LOG_FILE!"
pause
exit /b

:MOD_GPT
if not "%PROFILE_MODE%"=="3" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Este modulo solo se permite en perfil ADMINISTRACION.
    echo [%time%] Conversion GPT bloqueada: perfil insuficiente >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0C
echo  ==============================================================================
echo   [CONVERSION MBR A GPT]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Convierte un disco de MBR a GPT." "Operacion avanzada. Respalda antes."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Conversion MBR->GPT cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [!] ADVERTENCIA: Esta operacion es irreversible.
echo  [!] Respalda tus datos antes de continuar.
echo.
(echo list disk) | diskpart
echo.
set /p "gdisk=Seleccione numero de disco a convertir: "
for /f "delims=0123456789" %%x in ("%gdisk%") do set "gdisk="
if not defined gdisk (
    echo.
    echo [BLOQUEADO] Numero de disco invalido.
    echo ACCION BLOQUEADA: Numero de disco invalido para GPT. >> "!LOG_FILE!"
    pause
    exit /b
)
powershell -NoProfile -Command "$n=[int]'%gdisk%'; if(Get-Disk -ErrorAction SilentlyContinue | Where-Object Number -eq $n){exit 0}else{exit 1}" >nul 2>&1
if errorlevel 1 (
    echo.
    echo [BLOQUEADO] El disco %gdisk% no existe en este equipo.
    echo ACCION BLOQUEADA: Disco inexistente para GPT (%gdisk%). >> "!LOG_FILE!"
    pause
    exit /b
)
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "$sys=(Get-CimInstance Win32_OperatingSystem).SystemDrive.TrimEnd(':'); $p=Get-Partition -DriveLetter $sys -ErrorAction SilentlyContinue; if($p){$p.DiskNumber}"') do set "SYS_DISK=%%a"
if defined SYS_DISK if "%gdisk%"=="!SYS_DISK!" (
    echo.
    echo [BLOQUEADO] No se permite convertir el disco del sistema (Disco !SYS_DISK!).
    echo ACCION BLOQUEADA: Intento de convertir disco de sistema !SYS_DISK!. >> "!LOG_FILE!"
    pause
    exit /b
)
set /p "gconfirm=Escriba 'GPT-OK' para confirmar: "
if /i "%gconfirm%"=="GPT-OK" (
    echo  [i] Convirtiendo disco %gdisk%...
    echo [%time%] Conversion MBR->GPT disco %gdisk% >> "!LOG_FILE!"
    mbr2gpt /convert /disk:%gdisk% /allowfullOS
    echo  [OK] Conversion completada.
) else (
    echo  [i] Operacion cancelada.
)
pause
exit /b

:MOD_WINGET
:: Validacion de perfil
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Esta operacion instala y actualiza aplicaciones.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Winget bloqueado: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0A
echo  ==============================================================================
echo   [ACTUALIZACION DE APLICACIONES - WINGET]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Busca y aplica actualizaciones con Winget." "Puede tardar y reiniciar apps."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Winget cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Listando actualizaciones disponibles...
winget upgrade
echo.
echo  [i] Actualizando todas las aplicaciones...
winget upgrade --all
echo.
echo  [OK] Actualizaciones completadas.
echo [%time%] Winget upgrade ejecutado >> "!LOG_FILE!"
pause
exit /b

:MOD_OFF
cls
color 0E
echo  ==============================================================================
echo   [APAGADO PROGRAMADO]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Configura apagado programado o tareas." "Guarda tu trabajo antes de continuar."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Apagado programado cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  1. Apagar en X minutos (rapido)
echo  2. Programar tarea (una vez / diario / semanal)
echo  3. Cancelar apagado o tarea programada
echo.
set /p "off_mode=> Selecciona una opcion [1-3]: "

if "%off_mode%"=="1" goto :OFF_MINUTES
if "%off_mode%"=="2" goto :OFF_TASK
if "%off_mode%"=="3" goto :OFF_CANCEL

echo.
echo  [!] Opcion no valida.
timeout /t 2 >nul
goto :MOD_OFF

:OFF_MINUTES
set /p "mins=Ingrese minutos para apagar el sistema: "
set /a secs=%mins%*60
echo.
echo  [i] Sistema se apagara en %mins% minutos.
shutdown /s /t %secs%
echo  [i] Para cancelar ejecuta: shutdown /a
echo [%time%] Apagado programado: %mins% min >> "!LOG_FILE!"
goto :OFF_DONE

:OFF_TASK
call :CHECK_EXISTING_SHUTDOWN_TASK
if errorlevel 1 exit /b
if not defined OFF_TASK_NAME set "OFF_TASK_NAME=Toolbox_Shutdown"
echo.
echo  Tipo de programacion:
echo  1. Una vez
echo  2. Diario
echo  3. Semanal
echo.
set /p "task_mode=> Selecciona tipo [1-3]: "
set /p "task_time=> Hora de ejecucion (HH:MM): "

powershell -NoProfile -Command "if ('%task_time%' -match '^([01][0-9]|2[0-3]):[0-5][0-9]$') { exit 0 } else { exit 1 }" >nul 2>&1
if errorlevel 1 (
    echo.
    echo  [!] Hora invalida. Usa formato HH:MM de 24 horas. Ejemplo: 09:05 o 18:30
    timeout /t 2 >nul
    goto :OFF_TASK
)

if "%task_mode%"=="1" (
    set /p "task_date=> Fecha (formato local, ej: 11/02/2026): "
    powershell -NoProfile -Command "$d='%task_date%'; $ok=$false; foreach($f in 'dd/MM/yyyy','d/M/yyyy','MM/dd/yyyy','M/d/yyyy','yyyy-MM-dd'){ try { [datetime]::ParseExact($d,$f,[System.Globalization.CultureInfo]::InvariantCulture) | Out-Null; $ok=$true; break } catch {} }; if($ok){exit 0}else{exit 1}" >nul 2>&1
    if errorlevel 1 (
        echo.
        echo  [!] Fecha invalida. Usa formato local valido. Ejemplo: 11/02/2026
        timeout /t 2 >nul
        goto :OFF_TASK
    )
    schtasks /delete /tn "%OFF_TASK_NAME%" /f >nul 2>&1
    schtasks /create /tn "%OFF_TASK_NAME%" /sc once /sd "%task_date%" /st "%task_time%" /tr "shutdown /s /t 0" /f
    echo [%time%] Apagado programado (una vez): %task_date% %task_time% >> "!LOG_FILE!"
    goto :OFF_DONE
)

if "%task_mode%"=="2" (
    schtasks /delete /tn "%OFF_TASK_NAME%" /f >nul 2>&1
    schtasks /create /tn "%OFF_TASK_NAME%" /sc daily /st "%task_time%" /tr "shutdown /s /t 0" /f
    echo [%time%] Apagado programado (diario): %task_time% >> "!LOG_FILE!"
    goto :OFF_DONE
)

if "%task_mode%"=="3" (
    set /p "task_day=> Dia (MON,TUE,WED,THU,FRI,SAT,SUN): "
    schtasks /delete /tn "%OFF_TASK_NAME%" /f >nul 2>&1
    schtasks /create /tn "%OFF_TASK_NAME%" /sc weekly /d "%task_day%" /st "%task_time%" /tr "shutdown /s /t 0" /f
    echo [%time%] Apagado programado (semanal): %task_day% %task_time% >> "!LOG_FILE!"
    goto :OFF_DONE
)

echo.
echo  [!] Tipo de programacion no valido.
timeout /t 2 >nul
goto :OFF_TASK

:OFF_CANCEL
set "OFF_TASK_NAME=Toolbox_Shutdown"
shutdown /a >nul 2>&1
schtasks /delete /tn "%OFF_TASK_NAME%" /f >nul 2>&1
echo.
echo  [OK] Apagado cancelado y tarea eliminada si existia.
echo [%time%] Cancelacion de apagado/tarea >> "!LOG_FILE!"

:OFF_DONE
pause
exit /b

:CHECK_EXISTING_SHUTDOWN_TASK
set "OFF_TASK_NAME="
set "OFF_EXISTING_NAME="
set "OFF_EXISTING_PATH="
set "OFF_EXISTING_ACTION="
for /f "usebackq tokens=1-3 delims=|" %%a in (`powershell -NoProfile -Command "$t = Get-ScheduledTask | Where-Object { $_.Actions -match 'shutdown' } | Select-Object -First 1; if ($t) { $a = ($t.Actions | ForEach-Object { $_.Execute + ' ' + $_.Arguments }) -join '; '; Write-Output ($t.TaskName + '|' + $t.TaskPath + '|' + $a) }"`) do (
    set "OFF_EXISTING_NAME=%%a"
    set "OFF_EXISTING_PATH=%%b"
    set "OFF_EXISTING_ACTION=%%c"
)

if not defined OFF_EXISTING_NAME exit /b 0

echo.
echo  [!] Ya existe una tarea de apagado:
echo      Nombre: %OFF_EXISTING_PATH%%OFF_EXISTING_NAME%
echo      Accion: %OFF_EXISTING_ACTION%
echo.
echo  1. Modificar esa tarea
echo  2. Borrar esa tarea
echo  3. Crear otra tarea nueva
echo  0. Cancelar
echo.
set /p "off_task_choice=> Selecciona una opcion [0-3]: "

if "%off_task_choice%"=="1" (
    set "OFF_TASK_NAME=%OFF_EXISTING_NAME%"
    schtasks /delete /tn "%OFF_EXISTING_NAME%" /f >nul 2>&1
    exit /b 0
)
if "%off_task_choice%"=="2" (
    schtasks /delete /tn "%OFF_EXISTING_NAME%" /f >nul 2>&1
    echo  [OK] Tarea eliminada.
    pause
    exit /b 1
)
if "%off_task_choice%"=="3" (
    for /f "tokens=*" %%t in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "OFF_TASK_NAME=Toolbox_Shutdown_%%t"
    exit /b 0
)

echo  [i] Operacion cancelada.
pause
exit /b 1

:MOD_BATTERY
cls
color 0B
echo  ==============================================================================
echo   [REPORTE DE BATERIA]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Genera un reporte de bateria en HTML." "Solo aplica a equipos portatiles."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Reporte de bateria cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
set "BATTERY_REPORT=%~dp0battery-report.html"
del /q "%BATTERY_REPORT%" >nul 2>&1
echo  [i] Generando reporte de bateria...
powercfg /batteryreport /output "%BATTERY_REPORT%" >nul 2>&1
echo.
if not exist "%BATTERY_REPORT%" (
    echo  [!] No se detecta bateria o el sistema no soporta este reporte.
    echo  [i] Esto es normal en equipos de escritorio.
    echo [%time%] Reporte de bateria no disponible >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [OK] Reporte generado: battery-report.html
echo  [i] Abriendo reporte...
start "" "%BATTERY_REPORT%"
echo [%time%] Reporte de bateria generado >> "!LOG_FILE!"
pause
exit /b

:MOD_EVENT_CRITICAL
cls
color 0B
echo  ==============================================================================
echo   [ANALISIS DE EVENTOS CRITICOS]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Consulta errores criticos de Sistema (disco/energia)." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Eventos criticos cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando eventos criticos recientes...
echo  [i] Esto puede tardar unos segundos segun la cantidad de eventos del sistema.
echo.
powershell -NoProfile -Command "$ids=7,11,41,51,55,157,6008; Get-WinEvent -FilterHashtable @{LogName='System'; Id=$ids; Level=1,2} -MaxEvents 25 | Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message | Format-Table -Wrap -AutoSize"
echo.
echo  [OK] Consulta completada.
echo [%time%] Analisis de eventos criticos ejecutado >> "!LOG_FILE!"
pause
exit /b

:MOD_BSOD_ANALYZER
cls
color 0B
echo  ==============================================================================
echo   [ANALIZADOR BSOD - MINIDUMP]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Lista minidumps y eventos de bugcheck." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] BSOD analyzer cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
set "DUMP_FOUND=0"
for %%F in ("%SystemRoot%\Minidump\*.dmp") do if exist "%%~fF" set "DUMP_FOUND=1"
echo  [i] Ruta Minidump: %SystemRoot%\Minidump
echo.
if "!DUMP_FOUND!"=="0" (
    echo  [i] No se encontraron archivos .dmp en Minidump.
) else (
    echo  [i] Ultimos minidumps detectados:
    dir /b /o-d "%SystemRoot%\Minidump\*.dmp"
)
echo.
echo  [i] Ultimos eventos de bugcheck (Event ID 1001):
echo  [i] Esto puede tardar unos segundos segun el historial de eventos.
powershell -NoProfile -Command "Get-WinEvent -FilterHashtable @{LogName='System'; Id=1001} -MaxEvents 10 | Select-Object TimeCreated, ProviderName, Id, Message | Format-Table -Wrap -AutoSize"
echo.
if "!DUMP_FOUND!"=="1" (
    echo  [i] Abriendo carpeta Minidump...
    start "" "%SystemRoot%\Minidump"
)
echo  [OK] Analisis BSOD completado.
echo [%time%] Analisis BSOD/Minidump ejecutado >> "!LOG_FILE!"
pause
exit /b

:MOD_PROCESS_AUDIT
cls
color 0B
echo  ==============================================================================
echo   [AUDITORIA FORENSE DE PROCESOS]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Detecta procesos desde rutas temporales y firma digital." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Auditoria forense de procesos cancelada >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Analizando procesos sospechosos...
echo  [i] Esto puede tardar unos segundos en equipos con muchos procesos.
echo.
powershell -NoProfile -Command "$rx='\\AppData\\Local\\Temp\\|\\Windows\\Temp\\|\\Temp\\|\\tmp\\'; $rows=Get-CimInstance Win32_Process | Where-Object { $_.ExecutablePath -and ($_.ExecutablePath -match $rx) } | ForEach-Object { $sig='N/A'; try { $sig=(Get-AuthenticodeSignature -FilePath $_.ExecutablePath -ErrorAction Stop).Status } catch { $sig='UNAVAILABLE' }; [pscustomobject]@{ Process=$_.Name; PID=$_.ProcessId; Signature=$sig; Path=$_.ExecutablePath } }; if ($rows) { $rows | Sort-Object Signature,Process | Format-Table -Wrap -AutoSize } else { Write-Host '[i] No se detectaron procesos en rutas temporales.' }"
echo.
echo  [OK] Auditoria forense completada.
echo [%time%] Auditoria forense de procesos ejecutada >> "!LOG_FILE!"
pause
exit /b

:MOD_RAID_STATUS
cls
color 0B
echo  ==============================================================================
echo   [ESTADO RAID / STORAGE]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Consulta subsistema de almacenamiento y estado de discos." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Estado RAID/Storage cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando estado de almacenamiento...
echo  [i] Esto puede tardar unos segundos si hay muchos discos o arreglos.
echo.
powershell -NoProfile -Command "$hasStorage=(Get-Command Get-StorageSubSystem -ErrorAction SilentlyContinue); if ($hasStorage) { Write-Host '--- STORAGE SUBSYSTEM ---'; Get-StorageSubSystem | Select-Object FriendlyName,HealthStatus,OperationalStatus | Format-Table -AutoSize; Write-Host ''; Write-Host '--- VIRTUAL DISKS ---'; Get-VirtualDisk | Select-Object FriendlyName,ResiliencySettingName,OperationalStatus,HealthStatus,@{Name='SizeGB';Expression={[math]::round($_.Size/1GB,2)}} | Format-Table -AutoSize; Write-Host ''; Write-Host '--- PHYSICAL DISKS ---'; Get-PhysicalDisk | Select-Object FriendlyName,MediaType,OperationalStatus,HealthStatus,@{Name='SizeGB';Expression={[math]::round($_.Size/1GB,2)}} | Format-Table -AutoSize } else { Write-Host '[i] Cmdlets de Storage no disponibles en este sistema.' }; Write-Host ''; Write-Host '--- WMI FALLBACK ---'; Get-CimInstance Win32_DiskDrive | Select-Object Model,Status,InterfaceType,@{Name='SizeGB';Expression={[math]::round($_.Size/1GB,2)}} | Format-Table -AutoSize"
echo.
echo  [OK] Consulta RAID/Storage completada.
echo [%time%] Estado RAID/Storage consultado >> "!LOG_FILE!"
pause
exit /b

:MOD_DRIVER_BACKUP
if "%PROFILE_MODE%"=="1" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Este modulo escribe backups en disco.
    echo  El perfil DIAGNOSTICO es solo lectura.
    echo.
    echo [%time%] Backup de drivers bloqueado: modo diagnostico >> "!LOG_FILE!"
    pause
    exit /b
)
cls
color 0A
echo  ==============================================================================
echo   [BACKUP DE DRIVERS]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Exporta drivers de terceros con DISM." "Requiere espacio en disco."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Backup de drivers cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
for /f "tokens=*" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'yyyyMMdd_HHmmss'"') do set "DRV_TS=%%a"
set "DRV_BACKUP_DIR=%~dp0DriverBackups\Drivers_!DRV_TS!"
if not exist "%~dp0DriverBackups" mkdir "%~dp0DriverBackups"
mkdir "!DRV_BACKUP_DIR!" >nul 2>&1
echo  [i] Exportando drivers a: !DRV_BACKUP_DIR!
echo [%time%] Iniciando backup de drivers: !DRV_BACKUP_DIR! >> "!LOG_FILE!"
dism /online /export-driver /destination:"!DRV_BACKUP_DIR!"
echo.
for /f %%c in ('dir /b /a:-d /s "!DRV_BACKUP_DIR!" ^| find /c /v ""') do set "DRV_COUNT=%%c"
if "!DRV_COUNT!"=="0" (
    echo  [!] No se exportaron drivers o la operacion fallo.
    echo [%time%] Backup de drivers sin archivos exportados >> "!LOG_FILE!"
) else (
    echo  [OK] Backup de drivers completado. Archivos exportados: !DRV_COUNT!
    echo [%time%] Backup de drivers completado. Archivos: !DRV_COUNT! >> "!LOG_FILE!"
)
pause
exit /b

:MOD_RESOURCES
cls
color 0B
echo  ==============================================================================
echo   [INFORMACION DE RECURSOS DEL SISTEMA]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Muestra CPU, RAM, discos y estado SMART (solo lectura)." "No modifica el sistema."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Recursos del sistema cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando recursos del sistema...
echo  [i] Esto puede tardar unos segundos en equipos con inventario amplio.
echo.
echo  --- CPU ---
powershell "Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-List"
echo.
echo  --- MEMORIA ---
powershell "Get-CimInstance Win32_ComputerSystem | Select-Object @{Name='TotalMemoryGB';Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} | Format-List"
echo.
echo  --- ESPACIO Y ESTADO DE DISCOS ---
powershell "$disks = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3}; $smart = @{}; Get-CimInstance Win32_DiskDrive | ForEach-Object { $status = 'OK'; if ($_.Status -match 'Degraded|Pred Fail|Error|Unknown|NonRecover') { $status = 'EN RIESGO' }; if ($_.Status -match 'Error|NonRecover') { $status = 'MAL' }; $smart[$_.DeviceID] = $status }; $overall='N/D'; if($smart.Values -contains 'MAL'){ $overall='MAL' } elseif($smart.Values -contains 'EN RIESGO'){ $overall='EN RIESGO' } elseif($smart.Count -gt 0){ $overall='OK' }; $disks | Select-Object DeviceID, FileSystem, @{Name='SizeGB';Expression={[math]::round($_.Size/1GB,2)}}, @{Name='FreeGB';Expression={[math]::round($_.FreeSpace/1GB,2)}}, @{Name='Estado';Expression={$overall}} | Format-Table -AutoSize; echo ''; echo '--- ESTADO SMART DE DISCOS ---'; Get-CimInstance Win32_DiskDrive | ForEach-Object { $s = 'OK'; if ($_.Status -match 'Degraded|Pred Fail|Error') { $s = 'EN RIESGO' }; if ($_.Status -match 'Error|NonRecover') { $s = 'MAL' }; Write-Host ('  ' + $_.Model.Trim() + ' (' + ([math]::round($_.Size/1GB,0)) + 'GB) -> ' + $s) }"
echo.
echo  [OK] Consulta completada.
echo [%time%] Ejecutada consulta de recursos del sistema >> "!LOG_FILE!"
pause
exit /b

:MOD_WU_STATUS
cls
color 0B
echo  ==============================================================================
echo   [ESTADO DE WINDOWS UPDATE - SOLO LECTURA]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Consulta estado de Windows Update." "Solo lectura."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Estado de Windows Update cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando estado de Windows Update...
echo.
echo  [i] Actualizaciones pendientes detectadas:
powershell -NoProfile -Command "try { $s=(New-Object -ComObject Microsoft.Update.Session).CreateUpdateSearcher(); $r=$s.Search('IsInstalled=0 and Type=''Software'''); Write-Output ('Pendientes: ' + $r.Updates.Count); exit 0 } catch { Write-Output '[!] No se pudo consultar WU via COM. Verifica politicas GPO.'; exit 2 }"
if errorlevel 1 echo [%time%] ADVERTENCIA: Consulta WU via COM no disponible o bloqueada por politica >> "!LOG_FILE!"
echo.
echo  [i] Ultimas actualizaciones instaladas:
powershell "Get-HotFix | Select-Object -First 10 HotFixID, Description, InstalledOn | Format-Table -AutoSize"
echo.
echo  [OK] Consulta completada.
echo  [i] NOTA: Esta es solo una consulta, no realiza reparaciones.
echo.
echo [%time%] Consultado estado de Windows Update >> "!LOG_FILE!"
pause
exit /b

:MOD_MAS
cls
echo [LICENCIAMIENTO] Se recomienda usar solo en entornos autorizados.
echo [%time%] Acceso a modulo de activacion MAS >> "!LOG_FILE!"
call :MODULE_CONFIRM "Lanza el modulo de activacion MAS." "Usar solo con licencias autorizadas."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] MAS cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
call :MAS_LOGIC
exit /b

:MOD_CLASSROOM_SECURITY
if not "%PROFILE_MODE%"=="3" (
    cls
    color 0C
    echo.
    echo  [!] ACCESO RESTRINGIDO
    echo.
    echo  Este modulo solo se permite en perfil ADMINISTRACION.
    echo [%time%] Seguridad Aula bloqueada: perfil insuficiente >> "!LOG_FILE!"
    pause
    exit /b
)
echo [%time%] Blindaje V1: ingreso al modulo de Seguridad Alta >> "!LOG_FILE!"
:: *** CONFIGURAR: usuario del alumno en laboratorio ***
set "BL_TARGET_USER_ALUMNO=Usuario"
set "BL_DEFAULT_ROOT_DIR=C:\Trabajos Alumnos"
set "BL_DEFAULT_DRIVE_LETTER=T:"
set "BL_USER_ALUMNO=%BL_TARGET_USER_ALUMNO%"
set "BL_ROOT_DIR=%BL_DEFAULT_ROOT_DIR%"
set "BL_DRIVE_LETTER=%BL_DEFAULT_DRIVE_LETTER%"
set "BL_USER_HIVE="
set "BL_TEMP_HIVE=HKU\AL_TEMP"
set "BL_MODE_KEY=HKLM\SOFTWARE\Renggli\BlindajeV1"
set "BL_BIN_CLSID={645FF040-5081-101B-9F08-00AA002F954E}"
set "BL_SEC_DIR="
set "BL_PROFILE_DIR="
set "BL_CONFIG_KEY=%BL_MODE_KEY%\Config"
set "BL_LOGON_MAP_VALUE=RenggliDriveMap"

call :BL_LOAD_SAVED_CONFIG
call :BL_REFRESH_DERIVED_PATHS

:BL_MENU
cls
color 0B
echo ======================================================================
echo           PERFIL SEGURIDAD ALTA - BLINDAJE V1 INTEGRADO
echo ======================================================================
echo.
echo    Alumno objetivo: %BL_USER_ALUMNO%
echo    Carpeta raiz:    %BL_ROOT_DIR%
echo    Unidad virtual:  %BL_DRIVE_LETTER%
echo.
echo    Diferencias rapidas:
echo    - ESTRICTO: evita borrado de archivos y carpetas academicas ^(maxima proteccion^).
echo    - SUAVE: protege estructura de carpetas y permite guardado/borrado normal de archivos.
echo.
echo    [1] APLICAR BLINDAJE ESTRICTO
echo    [2] APLICAR BLOQUEO SUAVE ^(protege carpetas, permite borrar archivos^)
echo    [3] DESHACER TODO ^(revertir cambios^)
echo    [4] VERIFICAR ESTADO ACTUAL
echo    [5] CONFIGURAR RUTA/UNIDAD
echo    [6] VOLVER AL MENU PRINCIPAL
echo    [7] REVISION/LIMPIEZA TEMPORALES ^(manual^)
echo    [8] PROGRAMAR LIMPIEZA AUTOMATICA ^(tarea local^)
echo    [9] GUIA DESPLIEGUE MASIVO ^(dominio/sin dominio^)
echo    [10] DESACTIVAR LIMPIEZA AUTOMATICA
echo.
echo    Documentacion: Manuales\README_ES.md + CATALOGO_OPCIONES_ES.md
echo.
set "opt="
set /p "opt=Seleccione una opcion [1-10]: "

if "%opt%"=="1" (
    call :BL_CONFIRMAR_Y_APLICAR STRICT
    set "BL_LAST_RC=!errorlevel!"
    if "!BL_LAST_RC!"=="0" (
        echo [OK] BLINDAJE ESTRICTO aplicado correctamente.
    ) else (
        echo [X] No se aplico BLINDAJE ESTRICTO ^(cancelado o con error !BL_LAST_RC!^).
        echo [i] Revisa el log: !LOG_FILE!
    )
    pause
    goto BL_MENU
)
if "%opt%"=="2" (
    call :BL_CONFIRMAR_Y_APLICAR SOFT
    set "BL_LAST_RC=!errorlevel!"
    if "!BL_LAST_RC!"=="0" (
        echo [OK] BLOQUEO SUAVE aplicado correctamente.
    ) else (
        echo [X] No se aplico BLOQUEO SUAVE ^(cancelado o con error !BL_LAST_RC!^).
        echo [i] Revisa el log: !LOG_FILE!
    )
    pause
    goto BL_MENU
)
if "%opt%"=="3" goto BL_DESHACER
if "%opt%"=="4" goto BL_VERIFICAR
if "%opt%"=="5" (
    call :BL_CONFIGURAR_PARAMETROS
    pause
    goto BL_MENU
)
if "%opt%"=="6" (
    echo [%time%] Blindaje V1: salida del modulo Seguridad Alta >> "!LOG_FILE!"
    exit /b 0
)
if "%opt%"=="7" (
    call :BL_CLEAN_TEMP_FILES_SAFE
    pause
    goto BL_MENU
)
if "%opt%"=="8" (
    call :BL_SETUP_AUTO_CLEAN_TASK
    pause
    goto BL_MENU
)
if "%opt%"=="9" (
    call :BL_SHOW_MASS_DEPLOY_GUIDE
    pause
    goto BL_MENU
)
if "%opt%"=="10" (
    call :BL_REMOVE_AUTO_CLEAN_TASK
    pause
    goto BL_MENU
)
goto BL_MENU

:BL_CONFIRMAR_Y_APLICAR
set "BL_REQUESTED_MODE=%~1"
if /I "%BL_REQUESTED_MODE%"=="SOFT" (
    set "BL_MODE_TITLE=BLINDAJE SUAVE"
    set "BL_MODE_DESC=Protege carpetas academicas y permite borrar archivos dentro de ellas."
    set "BL_MODE_WARN=Ventaja: Office/Adobe guardan normal. Desventaja: un archivo individual si puede borrarse."
) else (
    set "BL_REQUESTED_MODE=STRICT"
    set "BL_MODE_TITLE=BLINDAJE ESTRICTO"
    set "BL_MODE_DESC=Prioriza que no se borren archivos ni carpetas dentro de Trabajos Alumnos."
    set "BL_MODE_WARN=Ventaja: maxima proteccion. Desventaja: algunas apps pueden fallar al guardar por temporales/reemplazos."
)
set "BL_USER_ALUMNO=%BL_TARGET_USER_ALUMNO%"
call :BL_REFRESH_DERIVED_PATHS
cls
color 0A
echo ========================================================
echo   CONFIRMACION DE APLICACION
echo ========================================================
echo.
echo  Configuracion actual:
echo    - Alumno:  %BL_TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %BL_ROOT_DIR%
echo    - Unidad:  %BL_DRIVE_LETTER%
echo.
echo  Alcance de cambios:
echo    - Politicas de Explorer: solo para %BL_TARGET_USER_ALUMNO%.
echo    - ACL en %BL_ROOT_DIR% y mapeo de %BL_DRIVE_LETTER%: impacto a nivel equipo.
echo.
set "edit_cfg="
set /p "edit_cfg=Editar parametros antes de aplicar (S/N): "
if /I "%edit_cfg%"=="S" (
    call :BL_CONFIGURAR_PARAMETROS
    if errorlevel 1 (
        echo [i] Aplicacion cancelada.
        exit /b 1
    )
)

call :BL_PRECHECK
if errorlevel 1 exit /b 1

echo.
echo  Se aplicara !BL_MODE_TITLE!.
echo  !BL_MODE_DESC!
echo  !BL_MODE_WARN!
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

if /I "%BL_REQUESTED_MODE%"=="SOFT" (
    call :BL_APPLY_SOFT
) else (
    call :BL_APPLY_STRICT
)
exit /b %errorlevel%

:BL_PRECHECK
if not exist "%BL_USER_HIVE%" (
    color 0C
    echo [X] No existe NTUSER.DAT para %BL_USER_ALUMNO%.
    echo [i] Ruta esperada: %BL_USER_HIVE%
    exit /b 1
)

echo [.] Validando que la sesion de %BL_USER_ALUMNO% este cerrada...
reg unload "%BL_TEMP_HIVE%" >nul 2>&1
reg load "%BL_TEMP_HIVE%" "%BL_USER_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] La sesion de %BL_USER_ALUMNO% debe estar CERRADA para aplicar cambios.
    echo [i] Cierra la sesion del usuario objetivo y reintenta.
    exit /b 1
)
reg unload "%BL_TEMP_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] No se pudo descargar el hive temporal de %BL_USER_ALUMNO%.
    echo [i] Reinicia el equipo y vuelve a intentar.
    exit /b 1
)
echo [OK] Sesion del usuario objetivo validada.
exit /b 0

:BL_CONFIGURAR_PARAMETROS
cls
color 0E
echo ========================================================
echo   CONFIGURAR RUTA Y UNIDAD
echo ========================================================
echo.
echo  [i] Enter mantiene el valor actual.
echo  [i] Usuario objetivo fijo: %BL_TARGET_USER_ALUMNO%
echo  [i] Formato carpeta:
echo      - Recomendado: C:\Trabajos Alumnos
echo      - Si escribis solo un nombre ^(ej: Trabajos Alumnos^), se usara C:\^<nombre^>
echo  [i] Formato unidad:
echo      - Letra sola o con : ^(ej: T o T:^)
echo.
echo  Valores actuales:
echo    - Alumno:  %BL_TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %BL_ROOT_DIR%
echo    - Unidad:  %BL_DRIVE_LETTER%
echo.

set "OLD_ROOT_DIR=%BL_ROOT_DIR%"
set "OLD_DRIVE_LETTER=%BL_DRIVE_LETTER%"

set "new_root="
set /p "new_root=Carpeta raiz [%BL_ROOT_DIR%]: "
if not "%new_root%"=="" (
    set "BL_ROOT_DIR=%new_root%"
    call :BL_NORMALIZE_ROOT_DIR
    if errorlevel 1 (
        color 0C
        echo [X] Ruta invalida. Ejemplos validos: C:\Trabajos Alumnos o Trabajos Alumnos.
        set "BL_ROOT_DIR=%OLD_ROOT_DIR%"
        set "BL_DRIVE_LETTER=%OLD_DRIVE_LETTER%"
        call :BL_REFRESH_DERIVED_PATHS
        exit /b 1
    )
)

set "new_drive="
set /p "new_drive=Unidad virtual [%BL_DRIVE_LETTER%]: "
if not "%new_drive%"=="" (
    set "BL_DRIVE_LETTER=%new_drive%"
    call :BL_NORMALIZE_DRIVE_LETTER
    if errorlevel 1 (
        color 0C
        echo [X] Letra de unidad invalida. Usa formato como T o T:
        set "BL_ROOT_DIR=%OLD_ROOT_DIR%"
        set "BL_DRIVE_LETTER=%OLD_DRIVE_LETTER%"
        call :BL_REFRESH_DERIVED_PATHS
        exit /b 1
    )
)

call :BL_REFRESH_DERIVED_PATHS

echo.
echo  Configuracion propuesta:
echo    - Alumno:  %BL_TARGET_USER_ALUMNO% ^(fijo^)
echo    - Carpeta: %BL_ROOT_DIR%
echo    - Unidad:  %BL_DRIVE_LETTER%
echo.
set "cfg_confirm="
set /p "cfg_confirm=Confirmar estos valores (S/N): "
if /I not "%cfg_confirm%"=="S" (
    set "BL_ROOT_DIR=%OLD_ROOT_DIR%"
    set "BL_DRIVE_LETTER=%OLD_DRIVE_LETTER%"
    call :BL_REFRESH_DERIVED_PATHS
    echo [i] Configuracion cancelada.
    exit /b 1
)

call :BL_SAVE_CONFIG
if errorlevel 1 (
    color 0C
    echo [X] No se pudo guardar la configuracion en registro.
    exit /b 1
)
echo [OK] Configuracion guardada.
echo [%time%] Blindaje V1: parametros guardados (Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
exit /b 0

:BL_SAVE_CONFIG
reg add "%BL_CONFIG_KEY%" /v "RootDir" /t REG_SZ /d "%BL_ROOT_DIR%" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_CONFIG_KEY%" /v "Drive" /t REG_SZ /d "%BL_DRIVE_LETTER%" /f >nul
if errorlevel 1 exit /b 1
exit /b 0

:BL_LOAD_SAVED_CONFIG
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%BL_CONFIG_KEY%" /v "RootDir" 2^>nul') do set "BL_ROOT_DIR=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%BL_CONFIG_KEY%" /v "Drive" 2^>nul') do set "BL_DRIVE_LETTER=%%C"
call :BL_NORMALIZE_ROOT_DIR >nul 2>&1
if errorlevel 1 set "BL_ROOT_DIR=%BL_DEFAULT_ROOT_DIR%"
call :BL_NORMALIZE_DRIVE_LETTER >nul 2>&1
if errorlevel 1 set "BL_DRIVE_LETTER=%BL_DEFAULT_DRIVE_LETTER%"
set "BL_USER_ALUMNO=%BL_TARGET_USER_ALUMNO%"
exit /b 0

:BL_REFRESH_DERIVED_PATHS
set "BL_USER_HIVE=C:\Users\%BL_USER_ALUMNO%\NTUSER.DAT"
set "BL_SEC_DIR=%BL_ROOT_DIR%\SECUNDARIA"
set "BL_PROFILE_DIR=%BL_ROOT_DIR%\PERFIL\%BL_USER_ALUMNO%"
exit /b 0

:BL_LOAD_MARKER_CONTEXT
set "BL_MARKER_STUDENT="
set "BL_MARKER_ROOT="
set "BL_MARKER_DRIVE="

for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%BL_MODE_KEY%" /v "Student" 2^>nul') do set "BL_MARKER_STUDENT=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%BL_MODE_KEY%" /v "RootDir" 2^>nul') do set "BL_MARKER_ROOT=%%C"
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "%BL_MODE_KEY%" /v "Drive" 2^>nul') do set "BL_MARKER_DRIVE=%%C"

if defined BL_MARKER_STUDENT set "BL_USER_ALUMNO=%BL_MARKER_STUDENT%"
if defined BL_MARKER_ROOT set "BL_ROOT_DIR=%BL_MARKER_ROOT%"
if defined BL_MARKER_DRIVE set "BL_DRIVE_LETTER=%BL_MARKER_DRIVE%"

call :BL_NORMALIZE_ROOT_DIR >nul 2>&1
if errorlevel 1 set "BL_ROOT_DIR=%BL_DEFAULT_ROOT_DIR%"
call :BL_NORMALIZE_DRIVE_LETTER >nul 2>&1
if errorlevel 1 set "BL_DRIVE_LETTER=%BL_DEFAULT_DRIVE_LETTER%"
call :BL_REFRESH_DERIVED_PATHS
exit /b 0

:BL_NORMALIZE_DRIVE_LETTER
set "BL_TMP_DRIVE=%BL_DRIVE_LETTER%"
set "BL_TMP_DRIVE=%BL_TMP_DRIVE: =%"
set "BL_TMP_DRIVE=%BL_TMP_DRIVE::=%"
set "BL_TMP_DRIVE=%BL_TMP_DRIVE:~0,1%"
echo(%BL_TMP_DRIVE%| findstr /R /I "^[A-Z]$" >nul
if errorlevel 1 exit /b 1
for %%L in (%BL_TMP_DRIVE%) do set "BL_DRIVE_LETTER=%%L:"
exit /b 0

:BL_NORMALIZE_ROOT_DIR
set "BL_TMP_ROOT=%BL_ROOT_DIR%"
set "BL_TMP_ROOT=%BL_TMP_ROOT:"=%"
set "BL_TMP_ROOT=%BL_TMP_ROOT:/=\%"
if "%BL_TMP_ROOT%"=="" exit /b 1

if "%BL_TMP_ROOT:~1,1%"==":" (
    set "BL_ROOT_DIR=%BL_TMP_ROOT%"
) else (
    set "BL_ROOT_DIR=C:\%BL_TMP_ROOT%"
)

echo(%BL_ROOT_DIR%| findstr /R /I "^[A-Z]:\\.*" >nul
if errorlevel 1 exit /b 1

if "%BL_ROOT_DIR:~-1%"=="\" (
    if not "%BL_ROOT_DIR:~3,1%"=="" set "BL_ROOT_DIR=%BL_ROOT_DIR:~0,-1%"
)
exit /b 0

:BL_PREPARE_STRUCTURE
echo [.] Unificando nombres al formato escolar...
set "BL_SEC_DIR=%BL_ROOT_DIR%\SECUNDARIA"
set "BL_PRI_DIR=%BL_ROOT_DIR%\PRIMARIA"

for %%a in (4to 5to 6to) do (
    if exist "%BL_SEC_DIR%\%%a-Economia" if not exist "%BL_SEC_DIR%\%%a Economia" move "%BL_SEC_DIR%\%%a-Economia" "%BL_SEC_DIR%\%%a Economia" >nul 2>&1
    if exist "%BL_SEC_DIR%\%%a-Sociales" if not exist "%BL_SEC_DIR%\%%a Sociales" move "%BL_SEC_DIR%\%%a-Sociales" "%BL_SEC_DIR%\%%a Sociales" >nul 2>&1
    if exist "%BL_SEC_DIR%\%%a ECONOMIA" move "%BL_SEC_DIR%\%%a ECONOMIA" "%BL_SEC_DIR%\%%a Economia" >nul 2>&1
    if exist "%BL_SEC_DIR%\%%a SOCIALES" move "%BL_SEC_DIR%\%%a SOCIALES" "%BL_SEC_DIR%\%%a Sociales" >nul 2>&1
)

for /D %%d in ("%BL_ROOT_DIR%\PRIMARIA\*-Anio") do (
    set "folder=%%~nd"
    set "grade=!folder:-Anio=!"
    if not exist "%BL_PRI_DIR%\!grade! A" if not exist "%BL_PRI_DIR%\!grade! B" (
        move "%%d" "%BL_PRI_DIR%\!grade! A" >nul 2>&1
    ) else (
        move "%%d" "%BL_PRI_DIR%\!grade!" >nul 2>&1
    )
)

for %%n in (1ro 2do 3ro 4to 5to 6to) do (
    if exist "%BL_PRI_DIR%\%%n" if not exist "%BL_PRI_DIR%\%%n A" if not exist "%BL_PRI_DIR%\%%n B" move "%BL_PRI_DIR%\%%n" "%BL_PRI_DIR%\%%n A" >nul 2>&1
)

for %%n in (1ro 2do 3ro) do (
    if exist "%BL_SEC_DIR%\%%n" if not exist "%BL_SEC_DIR%\%%n A" if not exist "%BL_SEC_DIR%\%%n B" move "%BL_SEC_DIR%\%%n" "%BL_SEC_DIR%\%%n A" >nul 2>&1
)

echo [OK] Carpetas normalizadas.
echo [.] Verificando estructura final...

if not exist "%BL_ROOT_DIR%" mkdir "%BL_ROOT_DIR%"
if not exist "%BL_PRI_DIR%" mkdir "%BL_PRI_DIR%"
for %%n in (1ro 2do 3ro 4to 5to 6to) do (
    if not exist "%BL_PRI_DIR%\%%n A" mkdir "%BL_PRI_DIR%\%%n A"
    if not exist "%BL_PRI_DIR%\%%n B" mkdir "%BL_PRI_DIR%\%%n B"
)

if not exist "%BL_ROOT_DIR%\SECUNDARIA" mkdir "%BL_ROOT_DIR%\SECUNDARIA"
for %%n in (1ro 2do 3ro) do (
    if not exist "%BL_SEC_DIR%\%%n A" mkdir "%BL_SEC_DIR%\%%n A"
    if not exist "%BL_SEC_DIR%\%%n B" mkdir "%BL_SEC_DIR%\%%n B"
)

for %%a in (4to 5to 6to) do (
    if not exist "%BL_SEC_DIR%\%%a Economia" mkdir "%BL_SEC_DIR%\%%a Economia"
    if not exist "%BL_SEC_DIR%\%%a Sociales" mkdir "%BL_SEC_DIR%\%%a Sociales"
)

if not exist "%BL_ROOT_DIR%\PERFIL" mkdir "%BL_ROOT_DIR%\PERFIL"
if not exist "%BL_PROFILE_DIR%" mkdir "%BL_PROFILE_DIR%"
for %%p in (Desktop Documents Downloads Music Pictures Videos) do if not exist "%BL_PROFILE_DIR%\%%p" mkdir "%BL_PROFILE_DIR%\%%p"

echo [OK] Estructura escolar lista.
exit /b 0

:BL_EXPOSE_BGINFO
if exist "C:\BGInfo" (
    if exist "%BL_ROOT_DIR%\BGInfo" (
        echo [OK] BGInfo ya esta disponible en %BL_DRIVE_LETTER%\BGInfo.
    ) else (
        mklink /J "%BL_ROOT_DIR%\BGInfo" "C:\BGInfo" >nul 2>&1
        if errorlevel 1 (
            echo [!] No se pudo exponer BGInfo en %BL_DRIVE_LETTER%\BGInfo.
        ) else (
            echo [OK] BGInfo disponible en %BL_DRIVE_LETTER%\BGInfo.
        )
    )
) else (
    echo [i] C:\BGInfo no existe; se omite exposicion.
)
exit /b 0

:BL_APPLY_DRIVE_MAP
echo [.] Configurando disco virtual %BL_DRIVE_LETTER%...
set "BL_EXPECTED_DOS=\??\%BL_ROOT_DIR%"
set "BL_CURRENT_DOS="
for /f "skip=2 tokens=1,2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%BL_DRIVE_LETTER%" 2^>nul') do set "BL_CURRENT_DOS=%%C"

if defined BL_CURRENT_DOS (
    if /I not "%BL_CURRENT_DOS%"=="%BL_EXPECTED_DOS%" (
        echo [X] %BL_DRIVE_LETTER% ya esta asignada a otra ruta: %BL_CURRENT_DOS%
        echo [i] Cambia la letra desde la opcion Configurar ruta/unidad.
        exit /b 1
    )
) else (
    if exist "%BL_DRIVE_LETTER%\" (
        echo [X] %BL_DRIVE_LETTER% ya esta en uso por otra unidad.
        echo [i] Cambia la letra desde la opcion Configurar ruta/unidad.
        exit /b 1
    )
)

reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%BL_DRIVE_LETTER%" /t REG_SZ /d "%BL_EXPECTED_DOS%" /f >nul
if errorlevel 1 (
    echo [X] No se pudo mapear %BL_DRIVE_LETTER%.
    exit /b 1
)

if not exist "%BL_DRIVE_LETTER%\" subst %BL_DRIVE_LETTER% "%BL_ROOT_DIR%" >nul 2>&1

if defined BL_CURRENT_DOS (
    echo [OK] %BL_DRIVE_LETTER% ya estaba mapeada correctamente.
) else (
    echo [OK] %BL_DRIVE_LETTER% apunta a %BL_ROOT_DIR%.
)
exit /b 0

:BL_CLEAR_ACL_RULES
echo [.] Limpiando reglas ACL previas para %BL_USER_ALUMNO%...
icacls "%BL_ROOT_DIR%" /remove:d "%BL_USER_ALUMNO%" /T /C >nul 2>&1
icacls "%BL_ROOT_DIR%" /remove:g "%BL_USER_ALUMNO%" /T /C >nul 2>&1
exit /b 0

:BL_APPLY_ACL_STRICT
echo [.] Aplicando ACL de blindaje estricto...
icacls "%BL_ROOT_DIR%" /inheritance:e /T /C >nul
if errorlevel 1 exit /b 1
icacls "%BL_ROOT_DIR%" /grant:r "%BL_USER_ALUMNO%":(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%BL_ROOT_DIR%" /deny "%BL_USER_ALUMNO%":(DE,DC) >nul
if errorlevel 1 exit /b 1
icacls "%BL_ROOT_DIR%" /deny "%BL_USER_ALUMNO%":(CI)(IO)(DC) /T /C >nul
if errorlevel 1 exit /b 1
icacls "%BL_ROOT_DIR%" /deny "%BL_USER_ALUMNO%":(OI)(CI)(DE) /T /C >nul
if errorlevel 1 exit /b 1
echo [OK] ACL estricta aplicada.
exit /b 0

:BL_LOAD_HIVE
echo [.] Cargando perfil offline del alumno...
reg load "%BL_TEMP_HIVE%" "%BL_USER_HIVE%" >nul 2>&1
if errorlevel 1 (
    color 0C
    echo [X] ERROR: La sesion del alumno debe estar CERRADA.
    exit /b 1
)
echo [OK] Hive cargado.
exit /b 0

:BL_UNLOAD_HIVE
reg unload "%BL_TEMP_HIVE%" >nul 2>&1
exit /b 0

:BL_APPLY_USER_POLICIES
echo [.] Aplicando politicas del alumno...
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /t REG_DWORD /d 4 /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /t REG_DWORD /d 4 /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul 2>&1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /t REG_DWORD /d 1 /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BL_BIN_CLSID%" /t REG_SZ /d "" /f >nul
if errorlevel 1 exit /b 1
echo [OK] Politicas de Explorer aplicadas.
exit /b 0

:BL_APPLY_PROFILE_NORMAL_ACL
echo [.] Habilitando permisos normales en carpetas diarias del perfil...
if not exist "%BL_PROFILE_DIR%" (
    echo [i] Perfil diario no encontrado; se omite ajuste ACL del perfil.
    exit /b 0
)

icacls "%BL_PROFILE_DIR%" /inheritance:d /T /C >nul
if errorlevel 1 exit /b 1
icacls "%BL_PROFILE_DIR%" /remove:d "%BL_USER_ALUMNO%" /T /C >nul 2>&1
icacls "%BL_PROFILE_DIR%" /grant:r "%BL_USER_ALUMNO%":(OI)(CI)(M) /T /C >nul
if errorlevel 1 exit /b 1

echo [OK] Perfil diario con permisos normales para %BL_USER_ALUMNO%.
exit /b 0

:BL_APPLY_ACL_ACADEMIC_NORMAL
echo [.] Habilitando permisos normales en carpetas academicas detectadas...
set "BL_ACL_TARGET_COUNT=0"
for /d %%R in ("%BL_ROOT_DIR%\*") do (
    if /I not "%%~nxR"=="PERFIL" if /I not "%%~nxR"=="BGInfo" (
        set /a BL_ACL_TARGET_COUNT+=1
        icacls "%%~fR" /inheritance:d /T /C >nul
        if errorlevel 1 exit /b 1
        icacls "%%~fR" /remove:d "%BL_USER_ALUMNO%" /T /C >nul 2>&1
        icacls "%%~fR" /grant:r "%BL_USER_ALUMNO%":(OI)(CI)(M) /T /C >nul
        if errorlevel 1 exit /b 1
    )
)
if "%BL_ACL_TARGET_COUNT%"=="0" (
    echo [i] No se detectaron carpetas academicas para ajustar ACL.
) else (
    echo [OK] ACL normal aplicada en !BL_ACL_TARGET_COUNT! carpetas academicas.
)
exit /b 0

:BL_PROTECT_ACADEMIC_ROOTS
echo [.] Protegiendo estructura academica contra borrado de carpetas...
set "BL_PROTECT_TARGET_COUNT=0"
for /d %%R in ("%BL_ROOT_DIR%\*") do (
    if /I not "%%~nxR"=="PERFIL" if /I not "%%~nxR"=="BGInfo" (
        set /a BL_PROTECT_TARGET_COUNT+=1
        icacls "%%~fR" /remove:d "%BL_USER_ALUMNO%" >nul 2>&1
        icacls "%%~fR" /deny "%BL_USER_ALUMNO%":(DE,DC) >nul
        if errorlevel 1 exit /b 1
        for /d %%D in ("%%~fR\*") do (
            icacls "%%~D" /remove:d "%BL_USER_ALUMNO%" >nul 2>&1
            icacls "%%~D" /deny "%BL_USER_ALUMNO%":(DE) >nul
            if errorlevel 1 exit /b 1
        )
    )
)
if "%BL_PROTECT_TARGET_COUNT%"=="0" (
    echo [i] No se detectaron carpetas academicas para proteger.
) else (
    echo [OK] Estructura protegida en !BL_PROTECT_TARGET_COUNT! carpetas academicas.
)
exit /b 0

:BL_APPLY_DAILY_FOLDERS_EXCEPTION
echo [.] Aplicando excepcion para carpetas diarias del alumno...
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Personal" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Music" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Pictures" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Video" /t REG_EXPAND_SZ /d "%BL_PROFILE_DIR%\Videos" /f >nul
if errorlevel 1 exit /b 1

reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop" /t REG_SZ /d "%BL_PROFILE_DIR%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal" /t REG_SZ /d "%BL_PROFILE_DIR%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_SZ /d "%BL_PROFILE_DIR%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Music" /t REG_SZ /d "%BL_PROFILE_DIR%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Pictures" /t REG_SZ /d "%BL_PROFILE_DIR%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Video" /t REG_SZ /d "%BL_PROFILE_DIR%\Videos" /f >nul
if errorlevel 1 exit /b 1

echo [OK] Excepcion de carpetas diarias aplicada.
exit /b 0

:BL_SYNC_VISIBLE_FOLDERS
echo [.] Copiando contenido actual de Escritorio y Musica ^(sin borrar origen^)...
call :BL_SYNC_FOLDER "C:\Users\%BL_USER_ALUMNO%\Desktop" "%BL_PROFILE_DIR%\Desktop" "Escritorio"
if errorlevel 1 exit /b 1
call :BL_SYNC_FOLDER "C:\Users\%BL_USER_ALUMNO%\Music" "%BL_PROFILE_DIR%\Music" "Musica"
if errorlevel 1 exit /b 1
echo [OK] Copia inicial completada.
exit /b 0

:BL_SYNC_FOLDER
set "BL_SRC_PATH=%~1"
set "BL_DST_PATH=%~2"
set "BL_FOLDER_NAME=%~3"

if not exist "%BL_SRC_PATH%" (
    echo [i] %BL_FOLDER_NAME%: origen no encontrado, se omite.
    exit /b 0
)

if not exist "%BL_DST_PATH%" mkdir "%BL_DST_PATH%" >nul 2>&1
robocopy "%BL_SRC_PATH%" "%BL_DST_PATH%" /E /COPY:DAT /DCOPY:DAT /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >nul
set "BL_ROBO_RC=%errorlevel%"
if %BL_ROBO_RC% GEQ 8 (
    echo [!] %BL_FOLDER_NAME%: error al copiar ^(codigo %BL_ROBO_RC%^).
    exit /b 1
)

echo [OK] %BL_FOLDER_NAME% copiada.
exit /b 0

:BL_APPLY_LOGON_DRIVE_REMAP
echo [.] Configurando re-mapeo automatico de %BL_DRIVE_LETTER% al iniciar sesion...
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%BL_LOGON_MAP_VALUE%" /t REG_SZ /d "cmd /c if not exist %BL_DRIVE_LETTER%\ subst %BL_DRIVE_LETTER% \\\"%BL_ROOT_DIR%\\\"" /f >nul
if errorlevel 1 exit /b 1
echo [OK] Re-mapeo automatico configurado.
exit /b 0

:BL_WRITE_MODE_MARKER
reg add "%BL_MODE_KEY%" /v "Mode" /t REG_SZ /d "%~1" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_MODE_KEY%" /v "Student" /t REG_SZ /d "%BL_USER_ALUMNO%" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_MODE_KEY%" /v "RootDir" /t REG_SZ /d "%BL_ROOT_DIR%" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_MODE_KEY%" /v "Drive" /t REG_SZ /d "%BL_DRIVE_LETTER%" /f >nul
if errorlevel 1 exit /b 1
exit /b 0

:BL_APPLY_STRICT
cls
color 0A
echo [+] INICIANDO BLINDAJE ESTRICTO...
echo.
call :BL_PREPARE_STRUCTURE
if errorlevel 1 exit /b 1
call :BL_APPLY_DRIVE_MAP
if errorlevel 1 exit /b 1
call :BL_CLEAR_ACL_RULES
call :BL_APPLY_ACL_STRICT
if errorlevel 1 (
    echo [X] Fallo aplicando ACL estricta.
    echo [%time%] Blindaje V1: ERROR aplicando ACL estricta >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_PROFILE_NORMAL_ACL
if errorlevel 1 (
    echo [X] Fallo aplicando permisos normales al perfil diario.
    echo [%time%] Blindaje V1: ERROR aplicando ACL de perfil diario >> "!LOG_FILE!"
    exit /b 1
)
call :BL_EXPOSE_BGINFO
call :BL_LOAD_HIVE
if errorlevel 1 exit /b 1
call :BL_APPLY_USER_POLICIES
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo aplicando politicas del alumno.
    echo [%time%] Blindaje V1: ERROR aplicando politicas offline >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_DAILY_FOLDERS_EXCEPTION
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo aplicando excepcion de carpetas diarias.
    echo [%time%] Blindaje V1: ERROR aplicando redireccion de carpetas diarias >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_LOGON_DRIVE_REMAP
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo configurando re-mapeo automatico de unidad.
    echo [%time%] Blindaje V1: ERROR configurando remapeo de unidad >> "!LOG_FILE!"
    exit /b 1
)
call :BL_SYNC_VISIBLE_FOLDERS
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo copiando contenido de Escritorio/Musica.
    echo [%time%] Blindaje V1: ERROR en copia inicial de carpetas visibles >> "!LOG_FILE!"
    exit /b 1
)

call :BL_UNLOAD_HIVE
call :BL_WRITE_MODE_MARKER STRICT
if errorlevel 1 (
    echo [X] Fallo guardando marcador de modo.
    echo [%time%] Blindaje V1: ERROR guardando marcador de modo >> "!LOG_FILE!"
    exit /b 1
)
call :BL_SAVE_CONFIG
if errorlevel 1 (
    echo [!] No se pudo guardar la configuracion para futuras ejecuciones.
)
echo.
echo ========================================================
echo   BLINDAJE ESTRICTO ACTIVADO
echo ========================================================
echo   - Borrado NTFS bloqueado en toda la estructura academica.
echo   - Renombrado de carpetas bloqueado.
echo   - C: oculto y bloqueado en Explorer.
echo   - Perfil diario redirigido a %BL_PROFILE_DIR% ^(no depende de T: al iniciar^).
echo   - En carpetas diarias se permite borrado normal del alumno.
echo   - Puede afectar guardado de Office/Adobe si usan temporales/reemplazos en carpetas academicas.
echo   - Re-mapeo automatico al iniciar sesion: activo.
echo   - Papelera endurecida desde Explorer.
echo   - Copia inicial de Escritorio/Musica: sin borrar origen.
echo   - BGInfo: disponible dentro de %BL_DRIVE_LETTER%\BGInfo si existe C:\BGInfo.
echo.
echo   Reinicia o cierra sesion para validar el resultado final.
echo [%time%] Blindaje V1: aplicado correctamente (Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
exit /b 0

:BL_APPLY_SOFT
cls
color 0A
echo [+] INICIANDO BLOQUEO SUAVE...
echo.
call :BL_PREPARE_STRUCTURE
if errorlevel 1 exit /b 1
call :BL_APPLY_DRIVE_MAP
if errorlevel 1 exit /b 1
call :BL_CLEAR_ACL_RULES
call :BL_APPLY_ACL_STRICT
if errorlevel 1 (
    echo [X] Fallo aplicando ACL base.
    echo [%time%] Blindaje V1: ERROR aplicando ACL base suave >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_PROFILE_NORMAL_ACL
if errorlevel 1 (
    echo [X] Fallo aplicando permisos normales al perfil diario.
    echo [%time%] Blindaje V1: ERROR aplicando ACL de perfil diario >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_ACL_ACADEMIC_NORMAL
if errorlevel 1 (
    echo [X] Fallo aplicando permisos normales en carpetas academicas.
    echo [%time%] Blindaje V1: ERROR aplicando ACL academica >> "!LOG_FILE!"
    exit /b 1
)
call :BL_PROTECT_ACADEMIC_ROOTS
if errorlevel 1 (
    echo [X] Fallo protegiendo estructura academica contra borrado de carpetas.
    echo [%time%] Blindaje V1: ERROR protegiendo raiz academica >> "!LOG_FILE!"
    exit /b 1
)
call :BL_EXPOSE_BGINFO
call :BL_LOAD_HIVE
if errorlevel 1 exit /b 1
call :BL_APPLY_USER_POLICIES
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo aplicando politicas del alumno.
    echo [%time%] Blindaje V1: ERROR aplicando politicas offline >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_DAILY_FOLDERS_EXCEPTION
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo aplicando excepcion de carpetas diarias.
    echo [%time%] Blindaje V1: ERROR aplicando redireccion de carpetas diarias >> "!LOG_FILE!"
    exit /b 1
)
call :BL_APPLY_LOGON_DRIVE_REMAP
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo configurando re-mapeo automatico de unidad.
    echo [%time%] Blindaje V1: ERROR configurando remapeo de unidad >> "!LOG_FILE!"
    exit /b 1
)
call :BL_SYNC_VISIBLE_FOLDERS
if errorlevel 1 (
    call :BL_UNLOAD_HIVE
    echo [X] Fallo copiando contenido de Escritorio/Musica.
    echo [%time%] Blindaje V1: ERROR en copia inicial de carpetas visibles >> "!LOG_FILE!"
    exit /b 1
)

call :BL_UNLOAD_HIVE
call :BL_WRITE_MODE_MARKER SOFT
if errorlevel 1 (
    echo [X] Fallo guardando marcador de modo.
    echo [%time%] Blindaje V1: ERROR guardando marcador de modo suave >> "!LOG_FILE!"
    exit /b 1
)
call :BL_SAVE_CONFIG
if errorlevel 1 (
    echo [!] No se pudo guardar la configuracion para futuras ejecuciones.
)
echo.
echo ========================================================
echo   BLOQUEO SUAVE ACTIVADO
echo ========================================================
echo   - Estructura de carpetas academicas protegida.
echo   - Archivos dentro de SECUNDARIA/PRIMARIA se pueden guardar y borrar normal.
echo   - C: oculto y bloqueado en Explorer.
echo   - Perfil diario redirigido a %BL_PROFILE_DIR% ^(no depende de T: al iniciar^).
echo   - Office/Adobe y apps con temporales funcionan mejor en carpetas academicas.
echo   - Re-mapeo automatico al iniciar sesion: activo.
echo   - Papelera endurecida desde Explorer.
echo   - Copia inicial de Escritorio/Musica: sin borrar origen.
echo   - BGInfo: disponible dentro de %BL_DRIVE_LETTER%\BGInfo si existe C:\BGInfo.
echo.
echo   Reinicia o cierra sesion para validar el resultado final.
echo [%time%] Blindaje V1: modo suave aplicado correctamente (Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
exit /b 0

:BL_VERIFICAR
cls
color 0B
echo ========================================================
echo   VERIFICACION DE ESTADO DEL BLINDAJE
echo ========================================================
echo.

set "BL_DETECTED_MODE=NO REGISTRADO"
for /f "tokens=3" %%A in ('reg query "%BL_MODE_KEY%" /v Mode 2^>nul ^| findstr /I "Mode"') do set "BL_DETECTED_MODE=%%A"

if /I not "!BL_DETECTED_MODE!"=="NO REGISTRADO" call :BL_LOAD_MARKER_CONTEXT

echo [1/4] Verificando disco %BL_DRIVE_LETTER% ...
reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%BL_DRIVE_LETTER%" | findstr /I /C:"\??\%BL_ROOT_DIR%" >nul
if errorlevel 1 (
    echo [X] %BL_DRIVE_LETTER% NO esta apuntando a %BL_ROOT_DIR%
) else (
    echo [OK] %BL_DRIVE_LETTER% apunta a %BL_ROOT_DIR%
)
echo.

echo [2/4] Verificando modo registrado ...
if /I "!BL_DETECTED_MODE!"=="STRICT" (
    echo [OK] MODO REGISTRADO: !BL_DETECTED_MODE!
) else if /I "!BL_DETECTED_MODE!"=="SOFT" (
    echo [OK] MODO REGISTRADO: !BL_DETECTED_MODE!
) else (
    echo [!] MODO REGISTRADO: !BL_DETECTED_MODE! ^(esperado: STRICT o SOFT^)
)
echo.

echo [3/4] Verificando ACL en %BL_ROOT_DIR% ...
set "BL_ACL_DE_OK=0"
set "BL_ACL_DC_OK=0"
icacls "%BL_ROOT_DIR%" | findstr /I /C:"%BL_USER_ALUMNO%:(DENY)(OI)(CI)(DE)" /C:"%BL_USER_ALUMNO%:(OI)(CI)(DENY)(DE)" /C:"%BL_USER_ALUMNO%:(DENY)(DE,DC)" /C:"%BL_USER_ALUMNO%:(DENY)(DE)" >nul
if not errorlevel 1 set "BL_ACL_DE_OK=1"
icacls "%BL_ROOT_DIR%" | findstr /I /C:"%BL_USER_ALUMNO%:(DENY)(CI)(IO)(DC)" /C:"%BL_USER_ALUMNO%:(CI)(IO)(DENY)(DC)" /C:"%BL_USER_ALUMNO%:(DENY)(DE,DC)" /C:"%BL_USER_ALUMNO%:(DENY)(DC)" >nul
if not errorlevel 1 set "BL_ACL_DC_OK=1"
if /I "!BL_DETECTED_MODE!"=="SOFT" (
    if "%BL_ACL_DE_OK%"=="1" (
        if "%BL_ACL_DC_OK%"=="1" (
            echo [OK] ACL base detectada para modo suave.
        ) else (
            echo [X] No se detecto la ACL base esperada para modo suave.
        )
    ) else (
        echo [X] No se detecto la ACL base esperada para modo suave.
    )
    if exist "%BL_ROOT_DIR%\SECUNDARIA" (
        icacls "%BL_ROOT_DIR%\SECUNDARIA" | findstr /I /C:"%BL_USER_ALUMNO%:(DENY)(DE,DC)" /C:"%BL_USER_ALUMNO%:(DENY)(DE)" >nul
        if errorlevel 1 (
            echo [X] SECUNDARIA no muestra proteccion estructural esperada.
        ) else (
            echo [OK] SECUNDARIA protegida contra borrado de carpeta.
        )
    )
    if exist "%BL_ROOT_DIR%\PRIMARIA" (
        icacls "%BL_ROOT_DIR%\PRIMARIA" | findstr /I /C:"%BL_USER_ALUMNO%:(DENY)(DE,DC)" /C:"%BL_USER_ALUMNO%:(DENY)(DE)" >nul
        if errorlevel 1 (
            echo [X] PRIMARIA no muestra proteccion estructural esperada.
        ) else (
            echo [OK] PRIMARIA protegida contra borrado de carpeta.
        )
    )
) else (
    if "%BL_ACL_DE_OK%"=="1" (
        if "%BL_ACL_DC_OK%"=="1" (
            echo [OK] ACL estricta detectada ^(bloqueo DE/DC^).
        ) else (
            echo [X] No se detecto la ACL estricta esperada.
        )
    ) else (
        echo [X] No se detecto la ACL estricta esperada.
    )
)
echo.

echo [4/4] Verificando politicas del usuario %BL_USER_ALUMNO% ...
call :BL_LOAD_HIVE
if errorlevel 1 (
    echo [!] No se pudo cargar NTUSER.DAT. Cierra la sesion de %BL_USER_ALUMNO% para verificar politicas offline.
) else (
    call :BL_CHECK_POLICY NoDrives 0x4
    call :BL_CHECK_POLICY NoViewOnDrive 0x4
    call :BL_CHECK_POLICY NoEmptyRecycleBin 0x1
    call :BL_CHECK_POLICY ConfirmFileDelete 0x1
    reg query "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BL_BIN_CLSID%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Bloqueo visual de Papelera NO detectado.
    ) else (
        echo [OK] Bloqueo visual de Papelera detectado.
    )
    call :BL_CHECK_REDIRECT "Desktop" "%BL_PROFILE_DIR%\Desktop"
    call :BL_CHECK_REDIRECT "Personal" "%BL_PROFILE_DIR%\Documents"
    call :BL_CHECK_REDIRECT "{374DE290-123F-4565-9164-39C4925E467B}" "%BL_PROFILE_DIR%\Downloads"
    call :BL_CHECK_REDIRECT "My Music" "%BL_PROFILE_DIR%\Music"
    call :BL_CHECK_REDIRECT "My Pictures" "%BL_PROFILE_DIR%\Pictures"
    call :BL_CHECK_REDIRECT "My Video" "%BL_PROFILE_DIR%\Videos"
    reg query "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%BL_LOGON_MAP_VALUE%" >nul 2>&1
    if errorlevel 1 (
        echo [X] Re-mapeo automatico de %BL_DRIVE_LETTER% NO detectado.
    ) else (
        echo [OK] Re-mapeo automatico de %BL_DRIVE_LETTER% detectado.
    )
    if exist "%BL_PROFILE_DIR%" (
        icacls "%BL_PROFILE_DIR%" | findstr /I /C:"%BL_USER_ALUMNO%:(DENY)" >nul
        if errorlevel 1 (
            echo [OK] Perfil diario sin denegaciones ACL del alumno.
        ) else (
            echo [!] Perfil diario con denegaciones ACL. Puede bloquear borrado en carpetas diarias.
        )
    ) else (
        echo [i] Perfil diario no encontrado para verificar ACL de excepcion.
    )
    call :BL_UNLOAD_HIVE
)
call :BL_LOAD_SAVED_CONFIG
call :BL_REFRESH_DERIVED_PATHS
echo [%time%] Blindaje V1: verificacion ejecutada (Mode=!BL_DETECTED_MODE!, Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
echo.
pause
goto BL_MENU

:BL_CHECK_POLICY
reg query "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "%~1" | findstr /I /C:"%~2" >nul
if errorlevel 1 (
    echo [X] %~1 no esta en %~2
) else (
    echo [OK] %~1=%~2
)
exit /b 0

:BL_CHECK_REDIRECT
reg query "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "%~1" | findstr /I /C:"%~2" >nul
if errorlevel 1 (
    echo [X] Redireccion %~1 no detectada hacia %~2
) else (
    echo [OK] Redireccion %~1=%~2
)
exit /b 0

:BL_RESTORE_DAILY_FOLDERS_DEFAULTS
echo [.] Restaurando carpetas diarias por defecto...
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Desktop" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "Personal" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Music" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Pictures" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" /v "My Video" /t REG_EXPAND_SZ /d "%%USERPROFILE%%\Videos" /f >nul
if errorlevel 1 exit /b 1

reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Desktop" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Desktop" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "Personal" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Documents" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "{374DE290-123F-4565-9164-39C4925E467B}" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Downloads" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Music" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Music" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Pictures" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Pictures" /f >nul
if errorlevel 1 exit /b 1
reg add "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "My Video" /t REG_SZ /d "C:\Users\%BL_USER_ALUMNO%\Videos" /f >nul
if errorlevel 1 exit /b 1

echo [OK] Carpetas diarias restauradas al perfil local.
exit /b 0

:BL_REMOVE_CREATED_FOLDERS
echo [.] Eliminando carpetas creadas por el blindaje...
set "BL_SEC_DIR=%BL_ROOT_DIR%\SECUNDARIA"
set "BL_PRI_DIR=%BL_ROOT_DIR%\PRIMARIA"

rd "%BL_ROOT_DIR%\BGInfo" >nul 2>&1
if exist "%BL_ROOT_DIR%" icacls "%BL_ROOT_DIR%" /grant:r *S-1-5-32-544:(OI)(CI)F /T /C >nul 2>&1

for %%p in (Desktop Documents Downloads Music Pictures Videos) do rd "%BL_PROFILE_DIR%\%%p" >nul 2>&1
rd "%BL_PROFILE_DIR%" >nul 2>&1
rd "%BL_ROOT_DIR%\PERFIL" >nul 2>&1

for %%a in (4to 5to 6to) do (
    rd "%BL_SEC_DIR%\%%a-Economia" >nul 2>&1
    rd "%BL_SEC_DIR%\%%a-Sociales" >nul 2>&1
    rd "%BL_SEC_DIR%\%%a Economia" >nul 2>&1
    rd "%BL_SEC_DIR%\%%a Sociales" >nul 2>&1
)

for %%n in (1ro 2do 3ro) do (
    rd "%BL_SEC_DIR%\%%n A" >nul 2>&1
    rd "%BL_SEC_DIR%\%%n B" >nul 2>&1
    rd "%BL_SEC_DIR%\%%n" >nul 2>&1
)
rd "%BL_ROOT_DIR%\SECUNDARIA" >nul 2>&1

for %%n in (1ro 2do 3ro 4to 5to 6to) do (
    rd "%BL_PRI_DIR%\%%n A" >nul 2>&1
    rd "%BL_PRI_DIR%\%%n B" >nul 2>&1
    rd "%BL_PRI_DIR%\%%n" >nul 2>&1
)
rd "%BL_ROOT_DIR%\PRIMARIA" >nul 2>&1

rd "%BL_ROOT_DIR%" >nul 2>&1

if exist "%BL_ROOT_DIR%" (
    echo [i] Aun existe %BL_ROOT_DIR% porque tiene contenido.
    set "force_delete_opt="
    set /p "force_delete_opt=Forzar borrado TOTAL de %BL_ROOT_DIR% y todo su contenido (S/N): "
    if /I "%force_delete_opt%"=="S" (
        call :BL_FORCE_DELETE_ROOT
        exit /b %errorlevel%
    )
    echo [i] Se conservaron datos existentes en %BL_ROOT_DIR%.
    exit /b 0
)

echo [OK] Carpetas creadas removidas.
exit /b 0

:BL_FORCE_DELETE_ROOT
if not exist "%BL_ROOT_DIR%" exit /b 0
echo [.] Intentando borrado forzado de %BL_ROOT_DIR%...

if /I "%BL_ROOT_DIR%"=="C:\" (
    echo [X] Seguridad: no se permite borrado forzado de C:\
    exit /b 1
)

takeown /F "%BL_ROOT_DIR%" /R /D Y >nul 2>&1
icacls "%BL_ROOT_DIR%" /inheritance:e /T /C >nul 2>&1
icacls "%BL_ROOT_DIR%" /grant:r *S-1-5-32-544:(OI)(CI)F /T /C >nul 2>&1
attrib -R -S -H "%BL_ROOT_DIR%\*" /S /D >nul 2>&1

rd /s /q "%BL_ROOT_DIR%" >nul 2>&1
if exist "%BL_ROOT_DIR%" (
    set "BL_EMPTY_MIRROR=%TEMP%\renggli_empty_%RANDOM%%RANDOM%"
    mkdir "%BL_EMPTY_MIRROR%" >nul 2>&1
    robocopy "%BL_EMPTY_MIRROR%" "%BL_ROOT_DIR%" /MIR /R:0 /W:0 /NFL /NDL /NJH /NJS /NP >nul
    rd "%BL_EMPTY_MIRROR%" >nul 2>&1
    rd /s /q "%BL_ROOT_DIR%" >nul 2>&1
)

if exist "%BL_ROOT_DIR%" (
    echo [X] No se pudo borrar completamente %BL_ROOT_DIR%.
    echo [i] Causa probable: archivos en uso o bloqueados por otro proceso.
    exit /b 1
)

echo [OK] %BL_ROOT_DIR% eliminado completamente.
exit /b 0

:BL_DESHACER
cls
color 0E
echo [!] REVERTIENDO TODA LA CONFIGURACION...
echo.
set "BL_REVERT_WARN=0"
call :BL_LOAD_MARKER_CONTEXT
subst %BL_DRIVE_LETTER% /D >nul 2>&1
reg delete "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DOS Devices" /v "%BL_DRIVE_LETTER%" /f >nul 2>&1
reg delete "%BL_MODE_KEY%" /v "Mode" /f >nul 2>&1
reg delete "%BL_MODE_KEY%" /v "Student" /f >nul 2>&1
reg delete "%BL_MODE_KEY%" /v "RootDir" /f >nul 2>&1
reg delete "%BL_MODE_KEY%" /v "Drive" /f >nul 2>&1

if exist "%BL_ROOT_DIR%" (
    icacls "%BL_ROOT_DIR%" /remove:d "%BL_USER_ALUMNO%" /T /C >nul 2>&1
    icacls "%BL_ROOT_DIR%" /remove:g "%BL_USER_ALUMNO%" /T /C >nul 2>&1
)

call :BL_LOAD_HIVE
if errorlevel 1 (
    echo [!] No se pudo cargar NTUSER.DAT. Cierra la sesion de %BL_USER_ALUMNO% para restaurar politicas y carpetas del perfil.
    set "BL_REVERT_WARN=1"
) else (
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDrives" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoViewOnDrive" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoEmptyRecycleBin" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "NoDeleteFiles" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "ConfirmFileDelete" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" /v "%BL_BIN_CLSID%" /f >nul 2>&1
    reg delete "%BL_TEMP_HIVE%\Software\Microsoft\Windows\CurrentVersion\Run" /v "%BL_LOGON_MAP_VALUE%" /f >nul 2>&1
    call :BL_RESTORE_DAILY_FOLDERS_DEFAULTS
    if errorlevel 1 set "BL_REVERT_WARN=1"
    call :BL_UNLOAD_HIVE
)

set "remove_dirs_opt="
set /p "remove_dirs_opt=Eliminar carpetas creadas por el blindaje en %BL_ROOT_DIR% (S/N): "
if /I "%remove_dirs_opt%"=="S" (
    call :BL_REMOVE_CREATED_FOLDERS
    if errorlevel 1 set "BL_REVERT_WARN=1"
)

if "%BL_REVERT_WARN%"=="1" (
    echo [!] Reversion parcial completada.
    echo [i] Reintenta con la sesion del alumno cerrada para completar la restauracion.
    echo [%time%] Blindaje V1: reversion parcial (Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
) else (
    echo [OK] Configuracion revertida.
    echo [%time%] Blindaje V1: reversion completa (Root=%BL_ROOT_DIR%, Drive=%BL_DRIVE_LETTER%) >> "!LOG_FILE!"
)
call :BL_LOAD_SAVED_CONFIG
call :BL_REFRESH_DERIVED_PATHS
echo [i] Reinicia o cierra sesion para limpiar Explorer y la unidad virtual.
echo [i] IMPORTANTE: despues de deshacer y reiniciar, revisa C:\ y confirma si %BL_ROOT_DIR% se elimino por completo.
echo [i] Si la carpeta sigue presente, puede haber archivos bloqueados; borra manualmente o repite Deshacer.
pause
goto BL_MENU

:: ==============================================================================
:: SISTEMA DE REPORTES ENTERPRISE
:: ==============================================================================

:GENERATE_REPORT
cls
color 0B
echo  ==============================================================================
echo   [GENERANDO REPORTE EJECUTIVO]
echo  ==============================================================================
echo.
set "REPORT_FILE=!LOG_DIR!\Report_!ISO_DATE!_!time::=-!.html"
set "REPORT_FILE=!REPORT_FILE: =!"

echo ^<!DOCTYPE html^> > "!REPORT_FILE!"
echo ^<html^>^<head^>^<meta charset="UTF-8"^>^<title^>Reporte Renggli PC Solution^</title^> >> "!REPORT_FILE!"
echo ^<style^>body{font-family:Consolas,monospace;background:#0a0e27;color:#00ff41;padding:20px;} >> "!REPORT_FILE!"
echo h1{color:#00d4ff;border-bottom:2px solid #00d4ff;} >> "!REPORT_FILE!"
echo .log{background:#000;padding:15px;border-left:4px solid #00ff41;white-space:pre-wrap;} >> "!REPORT_FILE!"
echo .meta{color:#ffd700;font-weight:bold;}^</style^>^</head^>^<body^> >> "!REPORT_FILE!"
echo ^<h1^>Renggli PC Solution - Reporte de Auditoria^</h1^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Fecha: !ISO_DATE!^</p^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Usuario: %username%^</p^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Computadora: %computername%^</p^> >> "!REPORT_FILE!"
echo ^<h2^>Log de Operaciones^</h2^> >> "!REPORT_FILE!"
echo ^<div class="log"^> >> "!REPORT_FILE!"
powershell -NoProfile -Command "Get-Content -LiteralPath '!LOG_FILE!' -ErrorAction SilentlyContinue | ForEach-Object { $_.Replace('&','&amp;').Replace('<','&lt;').Replace('>','&gt;') }" >> "!REPORT_FILE!"
echo ^</div^>^</body^>^</html^> >> "!REPORT_FILE!"

echo  [OK] Reporte generado: !REPORT_FILE!
echo  [i] Abriendo reporte...
echo [%time%] Reporte HTML generado >> "!LOG_FILE!"
start "" "!REPORT_FILE!"
pause
exit /b

:EXIT_SCRIPT
echo [%time%] --- FIN DE SESION --- >> "!LOG_FILE!"
echo.
echo  ==============================================================================
echo   [FINALIZANDO Y GENERANDO CHECKSUM]
echo  ==============================================================================
echo.
echo  [i] Calculando hash SHA256 del log...
for /f "tokens=*" %%a in ('powershell -Command "Get-FileHash '!LOG_FILE!' -Algorithm SHA256 | Select-Object -ExpandProperty Hash"') do set "LOG_HASH=%%a"
set "LOG_HASH_FILE=!LOG_FILE!.sha256"
echo !LOG_HASH! *!LOG_FILE!> "!LOG_HASH_FILE!"
echo  [OK] Hash: !LOG_HASH!
echo  [OK] Log guardado: !LOG_FILE!
echo  [OK] Hash guardado: !LOG_HASH_FILE!
echo.
timeout /t 3 /nobreak
exit

:EXIT_NO_LOG
echo.
echo  ======================================================================
echo   [FINALIZANDO SIN LOG]
echo  ======================================================================
echo.
if exist "!LOG_FILE!" del /q "!LOG_FILE!" >nul 2>&1
echo  [OK] Log eliminado. Saliendo...
timeout /t 2 /nobreak
exit

:MAS_LOGIC
cls
color 0D
echo  ==============================================================================
echo   [ACTIVACION MASTER - MAS v3.10]
echo  ==============================================================================
echo.
echo  [i] Redirigiendo a Microsoft Activation Scripts (MAS)...
echo  [i] Herramienta de activacion profesional integrada.
echo.
echo  [!] IMPORTANTE: Usa esta herramienta solo en entornos autorizados.
echo  [!] Recuerda que la activacion debe ser legal y conforme a licencias.
echo.
echo  [i] Detectando archivo MAS_AIO.cmd...
echo.

:: Verificar si MAS_AIO.cmd existe
if not exist "%~dp0MAS_AIO.cmd" (
    color 0C
    echo  [ERROR] No se encuentra MAS_AIO.cmd en el directorio Windows/
    echo.
    echo  [i] Asegurate de que MAS_AIO.cmd este en la misma carpeta que toolbox.bat
    echo.
    echo [%time%] ERROR: MAS_AIO.cmd no encontrado >> "!LOG_FILE!"
    pause
    exit /b
)

echo  [OK] MAS_AIO.cmd encontrado. Iniciando...
echo.
echo [%time%] Ejecutando MAS (Microsoft Activation Scripts) >> "!LOG_FILE!"
echo.
timeout /t 2 >nul

:: Ejecutar MAS_AIO.cmd
call "%~dp0MAS_AIO.cmd"

:: Retorno al toolbox
cls
color 0B
echo  ==============================================================================
echo   [RETORNO AL TOOLBOX]
echo  ==============================================================================
echo.
echo  [OK] Proceso MAS finalizado.
echo  [i] Regresando al menu principal de Toolbox...
echo.
echo [%time%] Retorno desde MAS al menu principal >> "!LOG_FILE!"
timeout /t 2 >nul
exit /b

:: ==============================================================================
:: ESPACIO PARA FUNCIONES PERSONALIZADAS
:: ==============================================================================
::
:: INSTRUCCIONES PARA AGREGAR TUS PROPIAS FUNCIONES:
::
:: 1. Crea tu modulo usando el formato :MOD_NOMBRETUMODULO
:: 2. Agrega validacion de perfil si es necesario (ver ejemplos abajo)
:: 3. Agrega logging obligatorio: echo [%time%] Tu accion >> "!LOG_FILE!"
:: 4. Registra tu modulo en el menu principal (linea ~87)
:: 5. Registra tu modulo en la validacion (linea ~113)
::
:: ==============================================================================

:: EJEMPLO 1: Funcion simple (solo lectura - cualquier perfil)
:: ==============================================================================
:MOD_EJEMPLO_SIMPLE
::cls
::color 0B
::echo  ==============================================================================
::echo   [MI FUNCION] Descripcion de mi funcion
::echo  ==============================================================================
::echo.
::echo  [i] Ejecutando mi operacion personalizada...
::echo.
::
:: REM Aqui va tu codigo
:: REM Ejemplo: explorer "C:\Users\%username%\Downloads"
::
::echo  [OK] Operacion completada.
::echo [%time%] Ejecutado: MI_FUNCION_PERSONALIZADA >> "!LOG_FILE!"
::pause
::exit /b

:BL_CLEAN_TEMP_FILES_SAFE
cls
color 0B
echo ========================================================
echo   REVISION / LIMPIEZA SEGURA DE TEMPORALES
echo ========================================================
echo.
echo  Paso 1/3 - Alcance del analisis
echo    %BL_ROOT_DIR%\SECUNDARIA
echo    %BL_ROOT_DIR%\PRIMARIA
echo.
echo  Paso 2/3 - Patrones temporales permitidos
echo    - Nombre que empieza con ^"~$^"
echo    - Extension .tmp
echo    - Extension .temp
echo.
echo  No se tocan archivos de proyectos ^(.psd, .prproj, .aep, etc.^).
echo.
echo  Paso 3/3 - Elegi modo
echo    1. SOLO REVISAR ^(no borra nada^)
echo    2. REVISAR Y LIMPIAR ^(borra solo temporales permitidos^)
echo.
set "BL_TMP_MODE="
set /p "BL_TMP_MODE=> Selecciona modo [1-2]: "
if not "%BL_TMP_MODE%"=="1" if not "%BL_TMP_MODE%"=="2" (
    echo [!] Opcion no valida.
    exit /b 1
)

if "%BL_TMP_MODE%"=="2" (
    call :MODULE_CONFIRM "Borrar solo temporales permitidos en SECUNDARIA/PRIMARIA." "No borra formatos de proyecto."
    if errorlevel 1 (
        echo [i] Operacion cancelada.
        echo [%time%] Blindaje V1: limpieza segura de temporales cancelada >> "!LOG_FILE!"
        exit /b 1
    )
)

if not exist "%BL_ROOT_DIR%" (
    echo [X] No existe la ruta objetivo: %BL_ROOT_DIR%
    echo [%time%] Blindaje V1: limpieza segura fallida (ruta no existe) >> "!LOG_FILE!"
    exit /b 1
)

set "BL_TMP_FOUND="
set "BL_TMP_DELETED="
set "BL_TMP_FAILED="
set "BL_TMP_SEC_FOUND="
set "BL_TMP_PRI_FOUND="
set "BL_TMP_TARGETS="
if "%BL_TMP_MODE%"=="1" (set "BL_TMP_ACTION=review") else (set "BL_TMP_ACTION=clean")
for /f "tokens=1,2,3,4,5,6 delims=|" %%A in ('powershell -NoProfile -Command "$root='%BL_ROOT_DIR%'; $action='%BL_TMP_ACTION%'; $targets=@(); $sec=Join-Path $root 'SECUNDARIA'; $pri=Join-Path $root 'PRIMARIA'; if(Test-Path -LiteralPath $sec){$targets += $sec}; if(Test-Path -LiteralPath $pri){$targets += $pri}; $found=0; $deleted=0; $failed=0; $secFound=0; $priFound=0; foreach($t in $targets){ Get-ChildItem -LiteralPath $t -Recurse -Force -File -ErrorAction SilentlyContinue | Where-Object { $_.Name -like '~$*' -or $_.Extension -ieq '.tmp' -or $_.Extension -ieq '.temp' } | ForEach-Object { $found++; if($_.FullName -like '*\\SECUNDARIA\\*'){ $secFound++ } elseif($_.FullName -like '*\\PRIMARIA\\*'){ $priFound++ }; if($action -eq 'clean'){ try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop; $deleted++ } catch { $failed++ } } } }; Write-Output ($found.ToString()+'|'+$deleted.ToString()+'|'+$failed.ToString()+'|'+$secFound.ToString()+'|'+$priFound.ToString()+'|'+$targets.Count.ToString())"') do (
    set "BL_TMP_FOUND=%%A"
    set "BL_TMP_DELETED=%%B"
    set "BL_TMP_FAILED=%%C"
    set "BL_TMP_SEC_FOUND=%%D"
    set "BL_TMP_PRI_FOUND=%%E"
    set "BL_TMP_TARGETS=%%F"
)

if not defined BL_TMP_FOUND set "BL_TMP_FOUND=0"
if not defined BL_TMP_DELETED set "BL_TMP_DELETED=0"
if not defined BL_TMP_FAILED set "BL_TMP_FAILED=0"
if not defined BL_TMP_SEC_FOUND set "BL_TMP_SEC_FOUND=0"
if not defined BL_TMP_PRI_FOUND set "BL_TMP_PRI_FOUND=0"
if not defined BL_TMP_TARGETS set "BL_TMP_TARGETS=0"

echo.
if "%BL_TMP_TARGETS%"=="0" (
    echo  [i] No existe SECUNDARIA ni PRIMARIA dentro de %BL_ROOT_DIR%.
    echo [%time%] Blindaje V1: limpieza/revision temporales sin rutas objetivo >> "!LOG_FILE!"
    exit /b 0
)

if "%BL_TMP_MODE%"=="1" (
    echo  [OK] Revision completada.
) else (
    echo  [OK] Limpieza completada.
)
echo  [i] Temporales detectados: %BL_TMP_FOUND%
echo  [i]  - En SECUNDARIA: %BL_TMP_SEC_FOUND%
echo  [i]  - En PRIMARIA:   %BL_TMP_PRI_FOUND%
echo  [i] Temporales eliminados: %BL_TMP_DELETED%
echo  [i] No eliminados ^(en uso/bloqueados^): %BL_TMP_FAILED%
echo [%time%] Blindaje V1: temporales modo=%BL_TMP_ACTION% (det=%BL_TMP_FOUND%, sec=%BL_TMP_SEC_FOUND%, pri=%BL_TMP_PRI_FOUND%, del=%BL_TMP_DELETED%, fail=%BL_TMP_FAILED%) >> "!LOG_FILE!"
exit /b 0

:BL_SETUP_AUTO_CLEAN_TASK
cls
color 0B
echo ========================================================
echo   PROGRAMAR LIMPIEZA AUTOMATICA ^(TAREA LOCAL^)
echo ========================================================
echo.
echo  Esto crea una tarea en ESTE equipo para limpiar automaticamente
echo  solo temporales permitidos en:
echo    - %BL_ROOT_DIR%\SECUNDARIA
echo    - %BL_ROOT_DIR%\PRIMARIA
echo.
echo  Paso 1/3 - Hora diaria
set "BL_TASK_TIME=18:30"
set /p "BL_TASK_TIME_INPUT=Hora diaria [18:30]: "
if not "%BL_TASK_TIME_INPUT%"=="" set "BL_TASK_TIME=%BL_TASK_TIME_INPUT%"

echo  Paso 2/3 - Confirmacion
call :MODULE_CONFIRM "Crear/actualizar tarea programada local de limpieza de temporales." "Se ejecuta todos los dias a la hora indicada."
if errorlevel 1 (
    echo [i] Operacion cancelada.
    exit /b 1
)

echo  Paso 3/3 - Creacion de tarea
set "BL_TASK_NAME=Renggli_Blindaje_TempClean"
set "BL_TASK_BASE=%ProgramData%\Renggli\BlindajeV1"
set "BL_TASK_SCRIPT=%BL_TASK_BASE%\TempClean_Task.cmd"
if not exist "%BL_TASK_BASE%" mkdir "%BL_TASK_BASE%" >nul 2>&1

(
    echo @echo off
    echo powershell -NoProfile -ExecutionPolicy Bypass -Command "$roots=@('%BL_ROOT_DIR%\SECUNDARIA','%BL_ROOT_DIR%\PRIMARIA'); $found=0; $deleted=0; $failed=0; foreach($r in $roots){ if(Test-Path -LiteralPath $r){ Get-ChildItem -LiteralPath $r -Recurse -Force -File -ErrorAction SilentlyContinue ^| Where-Object { $_.Name -like '~$*' -or $_.Extension -ieq '.tmp' -or $_.Extension -ieq '.temp' } ^| ForEach-Object { $found++; try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop; $deleted++ } catch { $failed++ } } } }; $logDir='%ProgramData%\\Renggli\\BlindajeV1\\Logs'; if(-not (Test-Path -LiteralPath $logDir)){ New-Item -ItemType Directory -Path $logDir -Force ^| Out-Null }; $stamp=Get-Date -Format 'yyyy-MM-dd HH:mm:ss'; Add-Content -Path ($logDir+'\\TempClean.log') -Value ($stamp+' found='+$found+' deleted='+$deleted+' failed='+$failed)"
) > "%BL_TASK_SCRIPT%"

schtasks /create /tn "%BL_TASK_NAME%" /sc daily /st "%BL_TASK_TIME%" /ru "SYSTEM" /rl HIGHEST /tr "\"%BL_TASK_SCRIPT%\"" /f >nul 2>&1
if errorlevel 1 (
    echo [X] No se pudo crear la tarea programada.
    echo [i] Verifica formato de hora ^(HH:MM^) y permisos de administrador.
    echo [%time%] Blindaje V1: error creando tarea automatica de temporales >> "!LOG_FILE!"
    exit /b 1
)

echo [OK] Tarea creada/actualizada: %BL_TASK_NAME%
echo [i] Hora diaria: %BL_TASK_TIME%
echo [i] Script local: %BL_TASK_SCRIPT%
echo [%time%] Blindaje V1: tarea automatica temporales creada (%BL_TASK_NAME% %BL_TASK_TIME%) >> "!LOG_FILE!"
exit /b 0

:BL_SHOW_MASS_DEPLOY_GUIDE
cls
color 0B
echo ========================================================
echo   GUIA RAPIDA - DESPLIEGUE MASIVO
echo ========================================================
echo.
echo  OPCION A ^(Dominio / GPO^) - Recomendado
echo   1. Crear GPO nueva: LimpiezaTemporales_BV1
echo   2. Ir a: Configuracion de Equipo ^> Preferencias ^> Tareas Programadas
echo   3. Crear tarea diaria como SYSTEM con privilegios altos
echo   4. Accion: ejecutar el script de limpieza segura
echo   5. Alcance: solo %BL_ROOT_DIR%\SECUNDARIA y %BL_ROOT_DIR%\PRIMARIA
echo.
echo  OPCION B ^(Sin dominio^) - Script remoto desde PC admin
echo   1. Preparar lista de PCs
echo   2. Ejecutar script remoto que cree la tarea local en cada equipo
echo   3. Verificar con: schtasks /query /tn Renggli_Blindaje_TempClean
echo.
echo  [TIP] En este equipo primero usa la opcion 7, valida resultados,
echo        y luego replica el mismo modelo al resto.
echo.
set "BL_GUIDE_FILE=%~dp0Logs\Guia_Despliegue_Masivo_Temporales.txt"
(
    echo GUIA DESPLIEGUE MASIVO - LIMPIEZA SEGURA TEMPORALES
    echo Fecha: %date% %time%
    echo.
    echo Objetivo:
    echo - Limpiar solo temporales ^(~$*, .tmp, .temp^) en:
    echo   %BL_ROOT_DIR%\SECUNDARIA y %BL_ROOT_DIR%\PRIMARIA
    echo - No tocar archivos de proyecto ^(.psd, .prproj, .aep, etc.^)
    echo.
    echo OPCION A - Dominio/GPO:
    echo 1. Crear GPO nueva
    echo 2. Configuracion de Equipo ^> Preferencias ^> Tareas Programadas
    echo 3. Ejecutar como SYSTEM, privilegios altos, diario
    echo 4. Accion: script de limpieza segura
    echo.
    echo OPCION B - Sin dominio:
    echo 1. Script remoto desde equipo administrador
    echo 2. Crear tarea Renggli_Blindaje_TempClean en cada PC
    echo 3. Verificar con schtasks /query
) > "%BL_GUIDE_FILE%"
echo [OK] Guia guardada en: %BL_GUIDE_FILE%
exit /b 0

:BL_REMOVE_AUTO_CLEAN_TASK
cls
color 0E
echo ========================================================
echo   DESACTIVAR LIMPIEZA AUTOMATICA
echo ========================================================
echo.
echo  Esta opcion elimina la tarea programada local:
echo    - Renggli_Blindaje_TempClean
echo.
set "BL_TASK_NAME=Renggli_Blindaje_TempClean"
set "BL_TASK_BASE=%ProgramData%\Renggli\BlindajeV1"
set "BL_TASK_SCRIPT=%BL_TASK_BASE%\TempClean_Task.cmd"

call :MODULE_CONFIRM "Eliminar la tarea automatica de limpieza de temporales." "No borra datos escolares ni proyectos."
if errorlevel 1 (
    echo [i] Operacion cancelada.
    exit /b 1
)

schtasks /query /tn "%BL_TASK_NAME%" >nul 2>&1
if errorlevel 1 (
    echo [i] La tarea %BL_TASK_NAME% no existe en este equipo.
) else (
    schtasks /delete /tn "%BL_TASK_NAME%" /f >nul 2>&1
    if errorlevel 1 (
        echo [X] No se pudo eliminar la tarea %BL_TASK_NAME%.
        echo [%time%] Blindaje V1: error al eliminar tarea automatica de temporales >> "!LOG_FILE!"
        exit /b 1
    )
    echo [OK] Tarea eliminada: %BL_TASK_NAME%
)

if exist "%BL_TASK_SCRIPT%" del /q "%BL_TASK_SCRIPT%" >nul 2>&1
echo [OK] Limpieza automatica desactivada en este equipo.
echo [%time%] Blindaje V1: tarea automatica de temporales desactivada >> "!LOG_FILE!"
exit /b 0

:: EJEMPLO 2: Funcion con validacion de perfil (requiere REPARACION)
:: ==============================================================================
:MOD_EJEMPLO_AVANZADO
:: Validacion de perfil
::if "%PROFILE_MODE%"=="1" (
::    cls
::    color 0C
::    echo.
::    echo  [!] ACCESO RESTRINGIDO
::    echo.
::    echo  Esta operacion requiere perfil REPARACION o superior.
::    echo  Perfil actual: !PROFILE_MODE!
::    echo.
::    echo [%time%] Funcion bloqueada: perfil insuficiente >> "!LOG_FILE!"
::    pause
::    exit /b
::)
::
::cls
::color 0A
::echo  ==============================================================================
::echo   [MI FUNCION AVANZADA] Descripcion
::echo  ==============================================================================
::echo.
::echo  [i] Ejecutando operacion que modifica el sistema...
::echo.
::
:: REM Aqui va tu codigo avanzado
::
::echo  [OK] Operacion completada.
::echo [%time%] Ejecutado: MI_FUNCION_AVANZADA >> "!LOG_FILE!"
::pause
::exit /b

:: EJEMPLO 3: Funcion CRITICA (requiere ADMINISTRACION)
:: ==============================================================================
:MOD_EJEMPLO_CRITICO
:: Validacion de perfil
::if not "%PROFILE_MODE%"=="3" (
::    cls
::    color 0C
::    echo.
::    echo  [!] ACCESO DENEGADO
::    echo.
::    echo  Esta operacion requiere perfil ADMINISTRACION.
::    echo  Perfil actual: !PROFILE_MODE!
::    echo.
::    echo [%time%] Funcion critica bloqueada: perfil insuficiente >> "!LOG_FILE!"
::    pause
::    exit /b
::)
::
::cls
::color 0C
::echo  ==============================================================================
::echo   [!] MI FUNCION CRITICA - ADVERTENCIA
::echo  ==============================================================================
::echo.
::echo  [!] ATENCION: Esta operacion es irreversible.
::echo.
::set /p "confirmacion=Escriba 'CONFIRMO' para continuar: "
::if /i "%confirmacion%"=="CONFIRMO" (
::    echo  [i] Ejecutando operacion critica...
::    echo [%time%] INICIANDO OPERACION CRITICA >> "!LOG_FILE!"
::
::    REM Aqui va tu codigo critico
::
::    echo  [OK] Operacion critica completada.
::    echo [OK] Operacion exitosa. >> "!LOG_FILE!"
::) else (
::    echo  [i] Operacion cancelada por el usuario.
::    echo [%time%] Operacion critica cancelada >> "!LOG_FILE!"
::)
::pause
::exit /b

:: ==============================================================================
:: TUS FUNCIONES PERSONALIZADAS DEBAJO DE ESTA LINEA
:: ==============================================================================
:: Descomenta los ejemplos de arriba o crea tus propias funciones aqui
:: Recuerda siempre incluir logging y feedback visual al usuario
:: ==============================================================================

:: Tu funcion 1:
:: :MOD_CUSTOM1
:: ...
:: exit /b

:: Tu funcion 2:
:: :MOD_CUSTOM2
:: ...
:: exit /b
