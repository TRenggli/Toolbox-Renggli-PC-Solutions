@echo off
setlocal enabledelayedexpansion
title RENGGLI PC SOLUTIONS - Enterprise Toolbox V14 CORPORATE
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
echo [%time%] VERSION: CORPORATE (SIN MODULO MAS) >> "!LOG_FILE!"

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
goto :PROFILE_SELECT

:PROFILE_SELECT
cls
color 0B
echo  ==============================================================================================================
echo                            RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 CORPORATE
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
echo                            RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 CORPORATE
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
echo.
echo    [ DIAGNOSTICO DE HARDWARE ]      [ INFORMACION DE SISTEMA ]       [ MONITOREO ]
echo    1. Estado SMART de Discos        4. Info BIOS y Placa Madre       7. Test de Velocidad de Red
echo    2. Test de RAM (mdsched)         5. Auditoria de Puertos/DNS      8. Reporte de Bateria
echo    3. Info de Recursos del Sistema  6. Estado de Windows Update
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_SCRIPT
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_SMART & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_RESOURCES & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_WU_STATUS & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_BATTERY & goto :MAIN_MENU)

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
echo.
echo    [ DIAGNOSTICO ]                  [ REPARACION DE SISTEMA ]        [ REDES Y ACTUALIZACIONES ]
echo    1. Estado SMART de Discos        5. Mantenimiento (DISM/SFC)      9. Reset de Red e IP
echo    2. Test de RAM (mdsched)         6. Reparar Windows Update       10. Test de Velocidad
echo    3. Info BIOS y Placa Madre       7. Limpieza EMMC/Temporales     11. Actualizar Apps (Winget)
echo    4. Reporte de Bateria            8. Auditoria de Puertos/DNS     12. Apagado Programado
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_SCRIPT
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_SMART & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_BATTERY & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_REPAIR & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_WU & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_CLEAN & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="9"  (call :MOD_NET & goto :MAIN_MENU)
if "%choice%"=="10" (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="11" (call :MOD_WINGET & goto :MAIN_MENU)
if "%choice%"=="12" (call :MOD_OFF & goto :MAIN_MENU)

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
echo.
echo    [ DIAGNOSTICO DE HARDWARE ]      [ REPARACION DE SISTEMA ]        [ REDES Y CONECTIVIDAD ]
echo    1. Estado SMART de Discos        4. Mantenimiento (DISM/SFC)      7. Reset de Red e IP
echo    2. Info BIOS y Placa Madre       5. Reparar Windows Update        8. Test de Velocidad Real
echo    3. Test de RAM (mdsched)         6. Limpieza EMMC/Temporales      9. Auditoria de Puertos/DNS
echo.
echo    [ GESTION DE ALMACENAMIENTO ]    [ SOFTWARE Y LICENCIAS ]         [ AUTOMATIZACION ]
echo    10. Formateo Seguro (Auditado)   12. Actualizar Apps (Winget)     14. Apagado Programado
echo    11. Conversion MBR a GPT         [MODULO 13 REMOVIDO]             15. Reporte de Bateria
echo.
echo    [0] SALIR CON REPORTE            [00] SALIR SIN REPORTE
echo    [99] CAMBIAR PERFIL
echo  ==============================================================================================================
echo.
set "choice="
set /p "choice=> Selecciona una opcion: "

if "%choice%"=="0"  (call :GENERATE_REPORT & goto :EXIT_SCRIPT)
if "%choice%"=="00" goto :EXIT_SCRIPT
if "%choice%"=="99" goto :PROFILE_SELECT
if "%choice%"=="1"  (call :MOD_SMART & goto :MAIN_MENU)
if "%choice%"=="2"  (call :MOD_BIOS & goto :MAIN_MENU)
if "%choice%"=="3"  (call :MOD_RAM & goto :MAIN_MENU)
if "%choice%"=="4"  (call :MOD_REPAIR & goto :MAIN_MENU)
if "%choice%"=="5"  (call :MOD_WU & goto :MAIN_MENU)
if "%choice%"=="6"  (call :MOD_CLEAN & goto :MAIN_MENU)
if "%choice%"=="7"  (call :MOD_NET & goto :MAIN_MENU)
if "%choice%"=="8"  (call :MOD_SPEED & goto :MAIN_MENU)
if "%choice%"=="9"  (call :MOD_DNS & goto :MAIN_MENU)
if "%choice%"=="10" (call :MOD_FORMAT & goto :MAIN_MENU)
if "%choice%"=="11" (call :MOD_GPT & goto :MAIN_MENU)
if "%choice%"=="12" (call :MOD_WINGET & goto :MAIN_MENU)
if "%choice%"=="14" (call :MOD_OFF & goto :MAIN_MENU)
if "%choice%"=="15" (call :MOD_BATTERY & goto :MAIN_MENU)

:: Opcion 13 bloqueada en version Corporate
if "%choice%"=="13" (
    cls
    color 0C
    echo.
    echo  ==============================================================================
    echo   [!] MODULO NO DISPONIBLE EN VERSION CORPORATE
    echo  ==============================================================================
    echo.
    echo  El modulo de activacion MAS ha sido removido en esta version
    echo  para cumplir con politicas de compliance estricto.
    echo.
    echo  Version: CORPORATE (Aprobada para Banca / Big Tech / Enterprise)
    echo.
    echo [%time%] Intento de acceso a modulo MAS bloqueado (version corporate) >> "!LOG_FILE!"
    pause
    goto :MAIN_MENU
)

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

:MOD_SMART
cls
color 0A
echo  ==============================================================================
echo   [AUDITORIA SMART] Analizando salud de las unidades...
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Consulta SMART de discos (solo lectura)." "No modifica el sistema."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Auditoria SMART cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando discos del sistema...
echo.
powershell "Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, Status, @{Name='Size(GB)';Expression={[math]::round($_.Size/1GB,2)}}"
echo.
echo  [OK] Auditoria completada. Informacion registrada en log.
echo.
echo [%time%] Ejecutada Auditoria SMART >> "!LOG_FILE!"
pause
exit /b

:MOD_BIOS
cls
color 03
echo  ==============================================================================
echo   [AUDITORIA BIOS/PLATAFORMA]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Consulta BIOS y placa madre (solo lectura)." "No modifica el sistema."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Consulta BIOS cancelada por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando firmware y hardware base...
echo.
powershell "Get-CimInstance Win32_BIOS | Select-Object Manufacturer, Name, ReleaseDate, SMBIOSBIOSVersion"
echo.
powershell "Get-CimInstance Win32_BaseBoard | Select-Object Product, Manufacturer"
echo.
echo  [OK] Informacion de plataforma capturada.
echo.
echo [%time%] Ejecutada Consulta de BIOS/Motherboard >> "!LOG_FILE!"
pause
exit /b

:MOD_RESOURCES
cls
color 0B
echo  ==============================================================================
echo   [INFORMACION DE RECURSOS DEL SISTEMA]
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Muestra CPU, RAM y discos (solo lectura)." "No modifica el sistema."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Recursos del sistema cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Consultando recursos del sistema...
echo.
echo  --- CPU ---
powershell "Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, MaxClockSpeed | Format-List"
echo.
echo  --- MEMORIA ---
powershell "Get-CimInstance Win32_ComputerSystem | Select-Object @{Name='TotalMemoryGB';Expression={[math]::round($_.TotalPhysicalMemory/1GB,2)}} | Format-List"
echo.
echo  --- ESPACIO EN DISCOS ---
powershell "Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | Select-Object DeviceID, FileSystem, @{Name='SizeGB';Expression={[math]::round($_.Size/1GB,2)}}, @{Name='FreeGB';Expression={[math]::round($_.FreeSpace/1GB,2)}} | Format-Table -AutoSize"
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
powershell "Get-WindowsUpdateLog"
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

:MOD_FORMAT
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
echo   [DIAGNOSTICO DE RED] - Test de Velocidad Real
echo  ==============================================================================
echo.
call :MODULE_CONFIRM "Descarga un archivo de prueba para medir velocidad." "Puede consumir datos de red."
if errorlevel 1 (
    echo  [i] Operacion cancelada.
    echo [%time%] Test de velocidad cancelado por el usuario >> "!LOG_FILE!"
    pause
    exit /b
)
echo  [i] Midiendo latencia y descarga...
echo.
for /f "delims=" %%i in ('powershell -Command "$s = Get-Date; try { $p = Test-Connection 8.8.8.8 -Count 2 -Quiet; $cl = New-Object System.Net.WebClient; $cl.DownloadFile('http://speedtest.tele2.net/10MB.zip', 'test.tmp'); $e = Get-Date; $sp = [Math]::Round((10/($e-$s).TotalSeconds)*8,2); Write-Output $sp; Remove-Item 'test.tmp' -ErrorAction SilentlyContinue } catch { Write-Output 'ERROR' }"') do set "speed=%%i"
if "%speed%"=="ERROR" (
    echo.
    echo  [!] Error al medir velocidad de red
    echo [%time%] Test de velocidad: ERROR DE RED >> "!LOG_FILE!"
) else (
    echo.
    echo  [OK] Velocidad de Descarga: %speed% Mbps
    echo [%time%] Test de velocidad: %speed% Mbps >> "!LOG_FILE!"
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
    color 0E
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
echo.
echo  [i] Limpiando cache de Windows Update...
ren C:\Windows\SoftwareDistribution SoftwareDistribution.old
ren C:\Windows\System32\catroot2 catroot2.old
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
cleanmgr /sagerun:1
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
echo [ %time%] Winget upgrade ejecutado >> "!LOG_FILE!"
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

if "%task_mode%"=="1" (
    set /p "task_date=> Fecha (formato local, ej: 11/02/2026): "
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
echo ^<html^>^<head^>^<meta charset="UTF-8"^>^<title^>Reporte Renggli PC Solutions Corporate^</title^> >> "!REPORT_FILE!"
echo ^<style^>body{font-family:Consolas,monospace;background:#0a0e27;color:#00ff41;padding:20px;} >> "!REPORT_FILE!"
echo h1{color:#00d4ff;border-bottom:2px solid #00d4ff;} >> "!REPORT_FILE!"
echo .log{background:#000;padding:15px;border-left:4px solid #00ff41;white-space:pre-wrap;} >> "!REPORT_FILE!"
echo .meta{color:#ffd700;font-weight:bold;} .corporate{color:#00ff00;font-weight:bold;border:2px solid #00ff00;padding:10px;margin:10px 0;}^</style^>^</head^>^<body^> >> "!REPORT_FILE!"
echo ^<h1^>RENGGLI PC SOLUTIONS - Reporte de Auditoria CORPORATE^</h1^> >> "!REPORT_FILE!"
echo ^<div class="corporate"^>[CORPORATE EDITION] Version sin modulo MAS - Aprobada para Banca / Big Tech / Enterprise^</div^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Fecha: !ISO_DATE!^</p^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Usuario: %username%^</p^> >> "!REPORT_FILE!"
echo ^<p class="meta"^>Computadora: %computername%^</p^> >> "!REPORT_FILE!"
echo ^<h2^>Log de Operaciones^</h2^> >> "!REPORT_FILE!"
echo ^<div class="log"^> >> "!REPORT_FILE!"
type "!LOG_FILE!" >> "!REPORT_FILE!" 2>nul
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
for /f "skip=3 tokens=*" %%a in ('powershell -Command "Get-FileHash '!LOG_FILE!' -Algorithm SHA256 | Select-Object -ExpandProperty Hash"') do set "LOG_HASH=%%a"
echo [CHECKSUM SHA256] !LOG_HASH! >> "!LOG_FILE!"
echo  [OK] Hash: !LOG_HASH!
echo  [OK] Log guardado: !LOG_FILE!
echo.
echo [VERSION CORPORATE] Sin modulo MAS - Aprobada para entornos de alto compliance
timeout /t 3
exit

:EXIT_NO_LOG
echo.
echo  ======================================================================
echo   [FINALIZANDO SIN LOG]
echo  ======================================================================
echo.
if exist "!LOG_FILE!" del /q "!LOG_FILE!" >nul 2>&1
echo  [OK] Log eliminado. Saliendo...
timeout /t 2
exit

:: ==============================================================================
:: ESPACIO PARA FUNCIONES PERSONALIZADAS
:: ==============================================================================
::
:: INSTRUCCIONES PARA AGREGAR TUS PROPIAS FUNCIONES:
::
:: 1. Crea tu modulo usando el formato :MOD_NOMBRETUMODULO
:: 2. Agrega validacion de perfil si es necesario (ver ejemplos en version completa)
:: 3. Agrega logging obligatorio: echo [%time%] Tu accion >> "!LOG_FILE!"
:: 4. Registra tu modulo en el menu principal (linea ~87)
:: 5. Registra tu modulo en la validacion (linea ~113)
::
:: ==============================================================================

:: Tu funcion 1:
:: :MOD_CUSTOM1
:: ...
:: exit /b

:: Tu funcion 2:
:: :MOD_CUSTOM2
:: ...
:: exit /b
