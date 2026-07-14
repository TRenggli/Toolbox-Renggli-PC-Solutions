#Requires -Version 5.1
<#
.SYNOPSIS
    Renggli PC Solution - Core PowerShell (motor automatizable y limpio).

.DESCRIPTION
    Motor orientado a servidores y entornos gestionados. A diferencia de toolbox.bat
    (kit de campo interactivo), este core esta pensado para:
      - Ejecucion DESATENDIDA (sin prompts) para orquestar por PSRemoting/SSH/Ansible/Intune.
      - Salida ESTRUCTURADA (JSON) y CODIGOS DE SALIDA para encadenar en pipelines.
      - Ser FIRMABLE con Authenticode (ver sign.ps1).
      - Nucleo LIMPIO: no incluye modulos de activacion (MAS). Apto para entornos regulados.

    Navegacion interactiva (modo menu, sin -Module/-Silent):
      - Menu principal por CATEGORIAS (Hardware, Almacenamiento, Red, Sistema, Mantenimiento).
      - Breadcrumb ("Ruta: Inicio > Categoria") siempre visible.
      - Controles universales en cualquier pantalla:
          [numero]  entra/ejecuta la opcion
          V         volver un nivel
          M         ir al menu principal
          ?N        ver ayuda de la opcion N (que hace, cuando usarla, riesgo, reversible)
          99        cambiar de perfil
          0         salir
      - Antes de ejecutar un modulo [W]/[!] se muestra una confirmacion con el riesgo
        y (salvo -NoSafetyNet) se intenta crear un punto de restauracion del sistema.

.PARAMETER Perfil
    Diagnostico | Reparacion | Administracion. Determina que modulos se permiten.

.PARAMETER Module
    Id del modulo a ejecutar de forma no interactiva (ej: smart, hardware, dism-sfc).
    Si se omite y no es -Silent, se abre el menu interactivo.

.PARAMETER List
    Lista los modulos disponibles (respeta -Perfil si se indica) y sale.

.PARAMETER Silent
    Modo desatendido: sin menu, sin prompts, sin pausas. Requiere -Module.

.PARAMETER Json
    Emite el resultado como JSON por stdout (util para parsear en automatizacion).

.PARAMETER Force
    Autoriza modulos que escriben/critical ([W]/[!]) en modo -Silent. Sin esto, se rechazan.

.PARAMETER NoSafetyNet
    Omite la creacion automatica de punto de restauracion antes de modulos [W]/[!].

.PARAMETER LogDir
    Carpeta de logs. Por defecto <script>\Logs.

.PARAMETER LogRetentionDays
    Dias de retencion de logs antes de comprimirlos a Logs\Archive\*.zip. Por defecto 30.

.PARAMETER ExportPath
    Ruta de archivo para exportar el resultado del modulo 'passport' (pasaporte del
    sistema). El formato se toma de -ExportFormat (por defecto html).

.PARAMETER ExportFormat
    Formato de exportacion para 'passport': html | json | csv. Por defecto html.

.PARAMETER SelfTest
    Corre las verificaciones internas (health score, etc.) y sale. No requiere admin.

.EXAMPLE
    .\toolbox.ps1 -Perfil Diagnostico -Module smart -Json
    Corre SMART y devuelve JSON. Exit 0 si ok.

.EXAMPLE
    .\toolbox.ps1 -Perfil Reparacion -Module dism-sfc -Silent -Force
    Repara imagen y archivos de sistema desatendido (crea punto de restauracion antes).

.EXAMPLE
    .\toolbox.ps1 -Perfil Diagnostico -Module passport -Silent -ExportPath C:\Reportes\srv01.html
    Genera el pasaporte del sistema (inventario + health score) y lo exporta a HTML.

.EXAMPLE
    Invoke-Command -ComputerName SRV01 -FilePath .\toolbox.ps1 -ArgumentList @{Perfil='Diagnostico';Module='disk';Json=$true}
    (patron de ejecucion remota sobre una flota)
#>
[CmdletBinding()]
param(
    [ValidateSet('Diagnostico', 'Reparacion', 'Administracion')]
    [string]$Perfil,

    [string]$Module,

    [switch]$List,

    [switch]$Silent,

    [switch]$Json,

    [switch]$Force,

    [switch]$NoSafetyNet,

    [string]$LogDir,

    [int]$LogRetentionDays = 30,

    [string]$ExportPath,

    [ValidateSet('html', 'json', 'csv')]
    [string]$ExportFormat = 'html',

    [switch]$SelfTest
)

# ============================================================================
#  Estado global / setup
# ============================================================================
$ErrorActionPreference = 'Stop'
$script:ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $LogDir) { $LogDir = Join-Path $script:ScriptRoot 'Logs' }
if (-not (Test-Path -LiteralPath $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
$script:LogFile = Join-Path $LogDir ("Audit_PS_{0}.log" -f (Get-Date -Format 'yyyy-MM-dd'))
$script:CurrentModule = $null

# Rotacion de logs: comprime a Logs\Archive\*.zip los logs mas viejos que -LogRetentionDays.
# Best-effort: nunca bloquea el arranque si falla (permisos, disco, etc.).
try {
    $cutoff = (Get-Date).AddDays(-$LogRetentionDays)
    $oldLogs = Get-ChildItem -LiteralPath $LogDir -Filter 'Audit_PS_*.log' -File -ErrorAction SilentlyContinue |
        Where-Object { $_.LastWriteTime -lt $cutoff -and $_.FullName -ne $script:LogFile }
    if ($oldLogs) {
        $archiveDir = Join-Path $LogDir 'Archive'
        if (-not (Test-Path -LiteralPath $archiveDir)) { New-Item -ItemType Directory -Path $archiveDir -Force | Out-Null }
        foreach ($f in $oldLogs) {
            $zipPath = Join-Path $archiveDir ($f.BaseName + '.zip')
            Compress-Archive -LiteralPath $f.FullName -DestinationPath $zipPath -Force -ErrorAction Stop
            Remove-Item -LiteralPath $f.FullName -Force -ErrorAction Stop
        }
    }
}
catch {
    # silencioso a proposito: la rotacion de logs nunca debe impedir que la herramienta arranque
}

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')
    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format 'HH:mm:ss'), $Level, $Message
    Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8
    if (-not $Silent) {
        $color = switch ($Level) { 'ERROR' { 'Red' } 'WARN' { 'Yellow' } 'OK' { 'Green' } default { 'Gray' } }
        Write-Host "  $Message" -ForegroundColor $color
    }
}

function Test-Admin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ============================================================================
#  Helpers de riesgo / reversibilidad (para menus, ayuda y confirmaciones)
# ============================================================================
function Get-RiskLabel {
    param([string]$Risk)
    switch ($Risk) {
        'R' { '[R] Solo lectura' }
        'W' { '[W] Escribe/cambia el sistema' }
        '!' { '[!] Critico / potencialmente irreversible' }
        default { $Risk }
    }
}

function Get-RiskColor {
    param([string]$Risk)
    switch ($Risk) {
        'R' { 'Green' }
        'W' { 'Yellow' }
        '!' { 'Red' }
        default { 'Gray' }
    }
}

function Get-ReversibleLabel {
    param([string]$Reversible)
    switch ($Reversible) {
        'si' { 'Si' }
        'no' { 'No' }
        default { 'N/A (solo lectura, no cambia nada)' }
    }
}

# ============================================================================
#  Red de seguridad: punto de restauracion antes de operaciones que escriben
# ============================================================================
function New-SafetyNet {
    param([string]$Reason)
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "RenggliToolbox: $Reason" -RestorePointType MODIFY_SETTINGS -ErrorAction Stop
        Write-Log "Punto de restauracion creado antes de: $Reason" 'OK'
        return $true
    }
    catch {
        Write-Log "No se pudo crear punto de restauracion (se continua igual): $($_.Exception.Message)" 'WARN'
        return $false
    }
}

function Confirm-Action {
    # Devuelve $true si se debe continuar. En silent, exige -Force para acciones que escriben.
    # Antes de autorizar una escritura (interactiva confirmada o silent+Force), intenta crear
    # un punto de restauracion (salvo -NoSafetyNet o que el modulo pase -SafetyNet:$false para
    # acciones que no cambian el estado del sistema, ej. exportar/leer algo ya existente).
    param([string]$Prompt, [bool]$Writes, [bool]$SafetyNet = $true)
    if ($Silent) {
        if ($Writes -and -not $Force) {
            Write-Log "Bloqueado en modo silent sin -Force: $Prompt" 'WARN'
            return $false
        }
        if ($Writes -and $SafetyNet -and -not $NoSafetyNet) { New-SafetyNet -Reason $Prompt | Out-Null }
        return $true
    }

    $mod = $script:CurrentModule
    Write-Host ''
    Write-Host '  +-- CONFIRMACION ------------------------------------------------------' -ForegroundColor Yellow
    Write-Host "  | Accion     : $Prompt"
    if ($mod) {
        Write-Host "  | Riesgo     : $(Get-RiskLabel $mod.Risk)" -ForegroundColor (Get-RiskColor $mod.Risk)
        Write-Host "  | Reversible : $(Get-ReversibleLabel $mod.Reversible)"
    }
    Write-Host '  +------------------------------------------------------------------------' -ForegroundColor Yellow
    $ans = Read-Host '  Escriba S para continuar (cualquier otra tecla cancela)'
    if ($ans -notmatch '^(s|si|y|yes)$') { return $false }
    if ($Writes -and $SafetyNet -and -not $NoSafetyNet) { New-SafetyNet -Reason $Prompt | Out-Null }
    return $true
}

# ============================================================================
#  Categorias (orden de presentacion en el menu principal)
# ============================================================================
$script:Categories = [ordered]@{
    'hardware'    = 'Hardware y sensores'
    'storage'     = 'Almacenamiento y discos'
    'network'     = 'Red y conectividad'
    'system'      = 'Windows / Sistema'
    'security'    = 'Seguridad y forense'
    'servers'     = 'Servidores'
    'database'    = 'Bases de datos'
    'maintenance' = 'Mantenimiento y reparacion'
    'reports'     = 'Reportes e inventario'
}

# ============================================================================
#  Definicion de modulos
#  Cada modulo:
#    Name       - texto para menus/ayuda
#    Category   - clave de $script:Categories
#    Perfiles   - perfiles donde se permite
#    Risk       - R (solo lectura) | W (escribe) | ! (critico/irreversible)
#    Reversible - 'si' | 'no' | 'na' (na = solo lectura, no aplica)
#    Help       - @{ Que=...; Cuando=...; Recaudos=... } (texto de la pantalla ?N)
#    Run        - scriptblock -> devuelve objeto de datos. Los [W]/[!] deben llamar
#                 Confirm-Action antes de escribir algo.
# ============================================================================
$script:Modules = [ordered]@{

    'smart' = @{
        Name       = 'Estado SMART de discos'
        Category   = 'storage'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Lee el estado/salud reportado por cada disco fisico (modelo, estado, tamano, interfaz).'
            Cuando   = 'Diagnostico inicial de hardware o sospecha de falla de disco.'
            Recaudos = 'Solo lectura. Para atributos SMART detallados (sectores reasignados, horas de uso) usa un modulo de diagnostico profundo si esta disponible.'
        }
        Run        = { return Get-PassportDisks }
    }

    'hardware' = @{
        Name       = 'Info de hardware (CPU/RAM/placa)'
        Category   = 'hardware'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Muestra fabricante/modelo del equipo, CPU, cantidad de nucleos, RAM total, placa base y version de BIOS.'
            Cuando   = 'Inventario tecnico o soporte remoto.'
            Recaudos = 'Solo lectura.'
        }
        Run        = { return Get-PassportHardware }
    }

    'os' = @{
        Name       = 'Info del sistema operativo'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Version de Windows, build, arquitectura, fecha de instalacion y tiempo desde el ultimo arranque.'
            Cuando   = 'Verificar compatibilidad, soporte o antiguedad de la instalacion.'
            Recaudos = 'Solo lectura.'
        }
        Run        = { return Get-PassportOS }
    }

    'resources' = @{
        Name       = 'Recursos: CPU, RAM y top procesos'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Porcentaje de memoria en uso y los 5 procesos que mas RAM consumen en este momento.'
            Cuando   = 'Diagnostico de lentitud o consumo anormal.'
            Recaudos = 'Solo lectura; es una foto del instante, no un monitoreo continuo.'
        }
        Run        = {
            $os = Get-CimInstance Win32_OperatingSystem
            $memUsedPct = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
            $top = Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 5 |
                ForEach-Object { [pscustomobject]@{ Name = $_.Name; RAM_MB = [math]::Round($_.WorkingSet64 / 1MB, 1) } }
            return @{
                MemUsedPct   = $memUsedPct
                MemFreeMB    = [math]::Round($os.FreePhysicalMemory / 1KB, 0)
                TopProcesses = @($top)
            }
        }
    }

    'disk' = @{
        Name       = 'Espacio y volumenes'
        Category   = 'storage'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Espacio total, libre y porcentaje libre de cada volumen local.'
            Cuando   = 'Falta de espacio o mantenimiento preventivo.'
            Recaudos = 'Solo lectura.'
        }
        Run        = { return Get-PassportVolumes }
    }

    'network' = @{
        Name       = 'Configuracion de red (IP/DNS)'
        Category   = 'network'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Adaptadores con IP activa: direccion IP, gateway, servidores DNS y si usan DHCP.'
            Cuando   = 'Problemas de conectividad o verificacion de configuracion de red.'
            Recaudos = 'Solo lectura.'
        }
        Run        = { return Get-PassportNetwork }
    }

    'ports' = @{
        Name       = 'Puertos TCP en escucha'
        Category   = 'network'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Puertos TCP en estado LISTEN y el proceso que los tiene abiertos.'
            Cuando   = 'Auditoria de exposicion de servicios o investigacion de incidentes.'
            Recaudos = 'Solo lectura.'
        }
        Run        = {
            $rows = Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
                Select-Object LocalAddress, LocalPort, OwningProcess -Unique |
                Sort-Object LocalPort | ForEach-Object {
                    $pname = (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
                    [pscustomobject]@{ Address = $_.LocalAddress; Port = $_.LocalPort; Process = $pname }
                }
            return @{ listening = @($rows) }
        }
    }

    'events' = @{
        Name       = 'Eventos criticos recientes (System)'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Ultimos 20 eventos de error/critico del log System.'
            Cuando   = 'Analisis post-fallo o investigacion de estabilidad.'
            Recaudos = 'Solo lectura.'
        }
        Run        = {
            $ev = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1, 2 } -MaxEvents 20 -ErrorAction SilentlyContinue |
                ForEach-Object { [pscustomobject]@{ Time = $_.TimeCreated; Id = $_.Id; Provider = $_.ProviderName; Message = ($_.Message -split "`n")[0] } }
            return @{ events = @($ev) }
        }
    }

    'wu-status' = @{
        Name       = 'Estado de Windows Update'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Estado del servicio Windows Update y fecha de la ultima actualizacion instalada.'
            Cuando   = 'Antes de decidir si hace falta reparar Windows Update.'
            Recaudos = 'Solo lectura.'
        }
        Run        = {
            $svc = Get-Service wuauserv -ErrorAction SilentlyContinue
            $lastInstall = $null
            try {
                $session = New-Object -ComObject Microsoft.Update.Session
                $searcher = $session.CreateUpdateSearcher()
                $count = $searcher.GetTotalHistoryCount()
                if ($count -gt 0) { $lastInstall = ($searcher.QueryHistory(0, 1) | Select-Object -First 1).Date }
            } catch {}
            return @{
                ServiceStatus = if ($svc) { "$($svc.Status)" } else { 'not-found' }
                StartType     = if ($svc) { "$($svc.StartType)" } else { $null }
                LastHistory   = $lastInstall
            }
        }
    }

    'battery' = @{
        Name       = 'Estado de bateria (portatiles)'
        Category   = 'hardware'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Porcentaje de carga, estado y autonomia estimada de la bateria.'
            Cuando   = 'Equipos portatiles con sintomas de autonomia o desgaste de bateria.'
            Recaudos = 'Solo lectura. No aplica (o no reporta datos) en equipos de escritorio.'
        }
        Run        = {
            $bat = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $bat) { return @{ present = $false } }
            return @{
                present        = $true
                ChargePct      = $bat.EstimatedChargeRemaining
                Status         = $bat.BatteryStatus
                RuntimeMinutes = $bat.EstimatedRunTime
            }
        }
    }

    'dism-sfc' = @{
        Name       = 'Reparar imagen y archivos (DISM + SFC)'
        Category   = 'maintenance'
        Perfiles   = @('Reparacion', 'Administracion')
        Risk       = 'W'
        Reversible = 'no'
        Help       = @{
            Que      = 'Repara la imagen de Windows (DISM /RestoreHealth) y verifica/repara archivos de sistema (SFC /scannow).'
            Cuando   = 'Errores de integridad de Windows, actualizaciones que fallan repetidamente, archivos de sistema corruptos.'
            Recaudos = 'Puede tardar 20-60 minutos; no interrumpir el proceso. No hay "deshacer" directo, pero se crea un punto de restauracion antes de empezar (salvo -NoSafetyNet).'
        }
        Run        = {
            if (-not (Confirm-Action 'Ejecutar DISM /RestoreHealth y SFC /scannow (puede tardar)?' $true)) {
                return @{ skipped = $true; reason = 'no confirmado' }
            }
            Write-Log 'Ejecutando DISM /RestoreHealth...' 'INFO'
            $dism = Start-Process -FilePath 'DISM.exe' -ArgumentList '/Online', '/Cleanup-Image', '/RestoreHealth' -Wait -PassThru -NoNewWindow
            Write-Log 'Ejecutando SFC /scannow...' 'INFO'
            $sfc = Start-Process -FilePath 'sfc.exe' -ArgumentList '/scannow' -Wait -PassThru -NoNewWindow
            return @{ dismExit = $dism.ExitCode; sfcExit = $sfc.ExitCode }
        }
    }

    'cleanup' = @{
        Name       = 'Limpieza de temporales'
        Category   = 'maintenance'
        Perfiles   = @('Reparacion', 'Administracion')
        Risk       = 'W'
        Reversible = 'no'
        Help       = @{
            Que      = 'Borra archivos de %TEMP% y C:\Windows\Temp.'
            Cuando   = 'Falta de espacio en disco o mantenimiento rutinario.'
            Recaudos = 'Los archivos borrados no se pueden recuperar. Se crea un punto de restauracion antes de empezar (salvo -NoSafetyNet).'
        }
        Run        = {
            if (-not (Confirm-Action 'Borrar temporales de %TEMP% y C:\Windows\Temp?' $true)) {
                return @{ skipped = $true; reason = 'no confirmado' }
            }
            $targets = @($env:TEMP, "$env:SystemRoot\Temp")
            $freed = 0; $deleted = 0; $failed = 0
            foreach ($t in $targets) {
                if (-not (Test-Path -LiteralPath $t)) { continue }
                Get-ChildItem -LiteralPath $t -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
                    try { $sz = $_.Length; Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction Stop; $deleted++; $freed += $sz }
                    catch { $failed++ }
                }
            }
            return @{ deleted = $deleted; failed = $failed; freedMB = [math]::Round($freed / 1MB, 1) }
        }
    }

    'passport' = @{
        Name       = 'Pasaporte del sistema (inventario completo)'
        Category   = 'reports'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Junta en un solo reporte: hardware, discos y su salud, sistema operativo, hotfixes, reinicio pendiente, red y software instalado, mas un "health score" (0-100) calculado con reglas fijas.'
            Cuando   = 'Al llegar a un equipo/servidor por primera vez, o para dejar un reporte completo adjunto a un ticket.'
            Recaudos = 'Solo lectura. Con -ExportPath (o respondiendo la pregunta en modo interactivo) se genera un archivo HTML/JSON/CSV en disco.'
        }
        Run        = {
            $passport = New-SystemPassport
            $exportTo = $ExportPath
            $exportFmt = $ExportFormat
            if (-not $exportTo -and -not $Silent) {
                $ans = Read-Host '  Exportar reporte a archivo? (html/json/csv, Enter=no)'
                if ($ans -match '^(html|json|csv)$') {
                    $exportFmt = $ans
                    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
                    $exportTo = Join-Path $LogDir ("Passport_{0}_{1}.{2}" -f $env:COMPUTERNAME, $ts, $ans)
                }
            }
            if ($exportTo) {
                Export-SystemPassport -Passport $passport -Path $exportTo -Format $exportFmt
                $passport.exportedTo = $exportTo
                Write-Log "Pasaporte exportado a: $exportTo" 'OK'
            }
            return $passport
        }
    }

    'autostart' = @{
        Name       = 'Auditor de autostart y persistencia'
        Category   = 'security'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Enumera TODOS los puntos de arranque automatico: registro Run/RunOnce (HKLM/HKCU/32-bit), carpetas de Inicio, tareas programadas con disparador de logon/boot, servicios en Automatico (marcando los no firmados o no-Microsoft) y dos mecanismos que casi nadie revisa: suscripciones de eventos WMI (persistencia "fileless" usada por malware avanzado) e IFEO Debugger (hijacking de ejecutables via Image File Execution Options).'
            Cuando   = 'Sospecha de malware, PC "rara" o lenta sin causa clara, o auditoria de hardening.'
            Recaudos = 'Solo lectura. Revisa manualmente cualquier item marcado como sospechoso antes de decidir eliminarlo (esta herramienta no borra nada aca).'
        }
        Run        = { return New-AutostartAudit }
    }

    'smart-deep' = @{
        Name       = 'Atributos SMART reales (fiabilidad de disco)'
        Category   = 'storage'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Lee los contadores de fiabilidad reales de cada disco: horas de encendido, temperatura, errores de lectura/escritura corregidos y NO corregidos, y desgaste (SSD). A diferencia del "OK/No-OK" generico, estos numeros predicen una falla antes de que ocurra.'
            Cuando   = 'Sospecha de disco degradandose, o auditoria periodica de almacenamiento en servidores.'
            Recaudos = 'Solo lectura. Requiere el modulo Storage de Windows (incluido desde Windows 8.1 / Server 2012 R2). Algunos discos (USB, ciertas VMs) no exponen estos contadores y quedan en null.'
        }
        Run        = { return Get-SmartDeep }
    }

    'event-intel' = @{
        Name       = 'Inteligencia de Event Log (apagados/disco/servicios)'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Busca los patrones especificos que revisa un tecnico senior en vez de "eventos criticos" genericos: apagados inesperados (Kernel-Power 41, EventLog 6008), señales de disco fallando (IDs 7/11/51/153), bugchecks/pantallazos azules (BugCheck 1001) y servicios que fallaron al iniciar (Service Control Manager). Ventana de 14 dias.'
            Cuando   = 'Investigar reinicios inexplicados, sospecha de disco degradado, o post-mortem de un incidente de estabilidad.'
            Recaudos = 'Solo lectura. Los eventos de disco se filtran al proveedor clasico "disk" (evita falsos positivos de otros componentes que reusan los mismos IDs numericos, ej. Kernel-General); controladores RAID/NVMe propietarios pueden registrar bajo otro proveedor y no aparecer aca.'
        }
        Run        = { return Get-EventIntelligence }
    }

    'driver-audit' = @{
        Name       = 'Auditoria de drivers (errores y sin firmar)'
        Category   = 'hardware'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Lista dispositivos con codigo de error (con el significado de cada codigo) y drivers instalados sin firma digital valida.'
            Cuando   = 'Hardware que "no anda", dispositivos con el simbolo de advertencia en Administrador de dispositivos, o auditoria antes de una migracion.'
            Recaudos = 'Solo lectura.'
        }
        Run        = { return Get-DriverAudit }
    }

    'driver-backup' = @{
        Name       = 'Backup de drivers de terceros'
        Category   = 'maintenance'
        Perfiles   = @('Reparacion', 'Administracion')
        Risk       = 'W'
        Reversible = 'si'
        Help       = @{
            Que      = 'Exporta (copia) todos los drivers de terceros instalados a una carpeta, via DISM /Export-Driver.'
            Cuando   = 'Antes de reinstalar Windows, migrar de equipo, o como respaldo preventivo en un servidor con hardware poco comun.'
            Recaudos = 'Escribe archivos en disco (no modifica el sistema ni requiere punto de restauracion). Usa -ExportPath para elegir la carpeta destino; si no se indica, se crea una dentro de Logs.'
        }
        Run        = {
            $dest = $ExportPath
            if (-not $dest) {
                $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
                $dest = Join-Path $LogDir ("DriverBackup_{0}_{1}" -f $env:COMPUTERNAME, $ts)
            }
            return Invoke-DriverBackup -Destination $dest
        }
    }

    'wu-reset' = @{
        Name       = 'Reset del stack de Windows Update'
        Category   = 'maintenance'
        Perfiles   = @('Reparacion', 'Administracion')
        Risk       = 'W'
        Reversible = 'si'
        Help       = @{
            Que      = 'Detiene wuauserv/bits/cryptsvc/msiserver, renombra SoftwareDistribution y catroot2 (Windows los recrea vacios), y reinicia los servicios.'
            Cuando   = 'Windows Update atascado, errores repetidos al buscar/instalar actualizaciones, o el reparador generico (DISM/SFC) no resolvio el problema.'
            Recaudos = 'Las carpetas viejas se renombran (no se borran) con sufijo .bak_<fecha>, asi que es reversible restaurando el nombre original con los servicios detenidos. Se pierden descargas de actualizaciones a medio bajar (se vuelven a descargar solas).'
        }
        Run        = { return Invoke-WindowsUpdateReset }
    }

    'wmi-repair' = @{
        Name       = 'Verificar/reparar repositorio WMI'
        Category   = 'maintenance'
        Perfiles   = @('Reparacion', 'Administracion')
        Risk       = 'W'
        Reversible = 'no'
        Help       = @{
            Que      = 'Verifica la consistencia del repositorio WMI (winmgmt /verifyrepository); si esta inconsistente y se confirma, lo repara con /salvagerepository (no destructivo, no equivale a un reset).'
            Cuando   = 'Errores "WMI no disponible", scripts/monitoreo que fallan con errores de proveedor WMI, o Get-CimInstance devolviendo vacio en clases que deberian existir.'
            Recaudos = 'La verificacion es de solo lectura; la reparacion (salvagerepository) es la via oficial y no borra namespaces personalizados. Si sigue inconsistente despues, el paso siguiente (resetrepository) es destructivo y NO lo hace este modulo automaticamente.'
        }
        Run        = { return Invoke-WmiRepositoryCheck }
    }

    'bitlocker-status' = @{
        Name       = 'BitLocker: estado de cifrado'
        Category   = 'security'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Muestra el estado de cifrado BitLocker de cada volumen (cifrado/descifrado, % de progreso, tipo de protector de clave).'
            Cuando   = 'Auditoria de cumplimiento (equipos deben estar cifrados) o diagnostico de un volumen que pide la clave de recuperacion.'
            Recaudos = 'Solo lectura. No expone claves (ver "bitlocker-keys" para eso).'
        }
        Run        = { return Get-BitLockerStatus }
    }

    'bitlocker-keys' = @{
        Name       = 'BitLocker: claves de recuperacion'
        Category   = 'security'
        Perfiles   = @('Administracion')
        Risk       = '!'
        Reversible = 'na'
        Help       = @{
            Que      = 'Muestra las claves de recuperacion (recovery password) de BitLocker de cada volumen cifrado.'
            Cuando   = 'Equipo bloqueado pidiendo la clave de recuperacion, o para respaldarla antes de un cambio de hardware/firmware que puede disparar el pedido.'
            Recaudos = 'CRITICO: expone secretos que permiten descifrar el disco. Solo perfil Administracion. Esta herramienta NUNCA escribe la clave en el log de auditoria, solo en la salida que pediste explicitamente (pantalla/JSON/archivo) - guardala en un lugar seguro.'
        }
        Run        = {
            if (-not (Confirm-Action 'Mostrar las claves de recuperacion de BitLocker de este equipo (dato sensible)?' $true $false)) {
                return @{ skipped = $true; reason = 'no confirmado' }
            }
            return Get-BitLockerRecoveryKeys
        }
    }

    'cert-scan' = @{
        Name       = 'Escaner de vencimiento de certificados'
        Category   = 'security'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Recorre los almacenes de certificados de la maquina (Personal, WebHosting, Remote Desktop) y marca los vencidos o por vencer en los proximos 30 dias.'
            Cuando   = 'El asesino silencioso: "se cayo el sitio/servicio porque vencio un certificado" que nadie monitoreaba. Revisar periodicamente en servidores.'
            Recaudos = 'Solo lectura. No incluye almacenes de otros usuarios ni certificados de aplicaciones que gestionen los suyos por fuera del almacen de Windows.'
        }
        Run        = { return Get-CertificateExpiryScan }
    }

    'svc-health' = @{
        Name       = 'Salud de servicios (automaticos caidos)'
        Category   = 'system'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Lista los servicios configurados como Automatico que NO estan corriendo ahora mismo.'
            Cuando   = 'Servidor "raro" sin causa obvia; muchas veces se explica por un servicio critico que broken silenciosamente.'
            Recaudos = 'Solo lectura. Ya excluye los servicios "Automatico (Trigger Start)" nativos de Windows (se detienen solos hasta su evento disparador). Actualizadores de terceros (navegadores, etc.) pueden seguir apareciendo aunque tambien sean auto-stop por diseno; revisa el nombre antes de asumir que es un problema.'
        }
        Run        = { return Get-ServiceHealth }
    }

    'ad-health' = @{
        Name       = 'Chequeo rapido de Active Directory'
        Category   = 'servers'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'En un equipo unido a un dominio: verifica el canal seguro con el DC (Test-ComputerSecureChannel), estado del servicio Netlogon, y si el recurso compartido SYSVOL del dominio es alcanzable.'
            Cuando   = 'Sospecha de problemas de autenticacion, replicacion o confianza con el dominio.'
            Recaudos = 'Solo lectura. Si el equipo no esta unido a un dominio, lo reporta y no hace nada mas.'
        }
        Run        = { return Get-AdHealth }
    }

    'iis-health' = @{
        Name       = 'Estado de IIS (sitios y application pools)'
        Category   = 'servers'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Lista los sitios y application pools de IIS con su estado (Started/Stopped).'
            Cuando   = 'Un sitio web en un servidor Windows no responde y hay que confirmar si el sitio o el pool estan detenidos.'
            Recaudos = 'Solo lectura. Requiere el modulo WebAdministration (rol IIS instalado); si no esta, lo reporta con claridad.'
        }
        Run        = { return Get-IisHealth }
    }

    'db-status' = @{
        Name       = 'Estado de motores de base de datos (Postgres/MySQL/MSSQL)'
        Category   = 'database'
        Perfiles   = @('Diagnostico', 'Reparacion', 'Administracion')
        Risk       = 'R'
        Reversible = 'na'
        Help       = @{
            Que      = 'Detecta instancias de PostgreSQL, MySQL y SQL Server via servicio de Windows y reporta version, puerto (Postgres) y estado del servicio.'
            Cuando   = 'Inventario de servidores, o para saber de un vistazo que motores de base de datos corren en un equipo y si estan activos.'
            Recaudos = 'Solo lectura. Para cambiar passwords de PostgreSQL usa el modulo "postgres-password"; MySQL/MSSQL por ahora son solo deteccion (sin gestion de password en esta version).'
        }
        Run        = { return Get-DbEngineStatus }
    }

    'postgres-password' = @{
        Name       = 'PostgreSQL: gestor de passwords'
        Category   = 'database'
        Perfiles   = @('Administracion')
        Risk       = 'W'
        Reversible = 'no'
        Help       = @{
            Que      = 'Detecta la instancia de PostgreSQL, permite cambiar la password de uno o varios roles. Si no conoces la password del superusuario, ofrece modo recuperacion (trust temporal en pg_hba.conf + reload, sin reiniciar el servicio) que siempre se revierte al terminar.'
            Cuando   = 'Reset de credenciales o recuperar acceso perdido a un servidor PostgreSQL.'
            Recaudos = 'Solo modo interactivo (no acepta -Silent, para no pasar passwords en texto plano por parametro/automatizacion). Restaura pg_hba.conf siempre, incluso ante error.'
        }
        Run        = { return Invoke-PostgresPasswordManager }
    }
}

# ============================================================================
#  Ejecucion de un modulo (con resultado estructurado + codigo de salida)
# ============================================================================
function Invoke-Module {
    param([string]$Id, [string]$ActivePerfil)

    $result = [ordered]@{
        module    = $Id
        computer  = $env:COMPUTERNAME
        perfil    = $ActivePerfil
        timestamp = (Get-Date -Format 's')
        status    = 'error'
        data      = $null
        message   = $null
    }

    if (-not $script:Modules.Contains($Id)) {
        $result.message = "Modulo desconocido: $Id"
        Write-Log $result.message 'ERROR'
        return @{ result = $result; exit = 2 }
    }
    $mod = $script:Modules[$Id]

    if ($mod.Perfiles -notcontains $ActivePerfil) {
        $result.status = 'blocked'
        $result.message = "El modulo '$Id' no esta permitido en el perfil $ActivePerfil (permitido en: $($mod.Perfiles -join ', '))"
        Write-Log $result.message 'WARN'
        return @{ result = $result; exit = 3 }
    }

    Write-Log "Ejecutando modulo: $Id ($($mod.Name))" 'INFO'
    $script:CurrentModule = $mod
    try {
        $data = & $mod.Run
        $result.status = 'ok'
        $result.data = $data
        Write-Log "Modulo '$Id' OK" 'OK'
        return @{ result = $result; exit = 0 }
    }
    catch {
        $result.message = $_.Exception.Message
        Write-Log "Modulo '$Id' fallo: $($_.Exception.Message)" 'ERROR'
        return @{ result = $result; exit = 1 }
    }
    finally {
        $script:CurrentModule = $null
    }
}

function Get-CategoryModules {
    param([string]$CategoryId, [string]$ActivePerfil)
    $script:Modules.GetEnumerator() | Where-Object {
        $_.Value.Category -eq $CategoryId -and $_.Value.Perfiles -contains $ActivePerfil
    } | ForEach-Object { [pscustomobject]@{ Id = $_.Key; Mod = $_.Value } }
}

function Show-ModuleList {
    param([string]$FilterPerfil)
    $script:Modules.GetEnumerator() | ForEach-Object {
        $m = $_.Value
        if ($FilterPerfil -and ($m.Perfiles -notcontains $FilterPerfil)) { return }
        [pscustomobject]@{
            Id       = $_.Key
            Nombre   = $m.Name
            Categoria = $script:Categories[$m.Category]
            Riesgo   = $m.Risk
            Perfiles = ($m.Perfiles -join '/')
        }
    }
}

# ============================================================================
#  Navegacion interactiva: menu principal (categorias) + submenu (modulos)
# ============================================================================
function Get-Breadcrumb {
    param([string]$View)
    if ($View -eq 'root') { return 'Inicio' }
    return "Inicio > $($script:Categories[$View])"
}

function Show-Banner {
    param([string]$ActivePerfil, [string]$View)
    Write-Host ''
    Write-Host '  Renggli PC Solution - Core PowerShell' -ForegroundColor Cyan
    Write-Host "  Equipo: $env:COMPUTERNAME   Usuario: $env:USERNAME   Perfil: $($ActivePerfil.ToUpper())"
    Write-Host "  Ruta: $(Get-Breadcrumb $View)" -ForegroundColor DarkCyan
    Write-Host '  ------------------------------------------------------------------------'
}

function Show-Help {
    param($Item)
    $m = $Item.Mod
    Write-Host ''
    Write-Host "  -- AYUDA: $($m.Name) " -ForegroundColor Cyan
    Write-Host "  Que hace   : $($m.Help.Que)"
    Write-Host "  Cuando     : $($m.Help.Cuando)"
    Write-Host "  Riesgo     : $(Get-RiskLabel $m.Risk)" -ForegroundColor (Get-RiskColor $m.Risk)
    Write-Host "  Reversible : $(Get-ReversibleLabel $m.Reversible)"
    Write-Host "  Recaudos   : $($m.Help.Recaudos)"
    Write-Host ''
}

function Select-Profile {
    Write-Host ''
    Write-Host '  Perfil de ejecucion:'
    Write-Host '   1. Diagnostico (solo lectura)'
    Write-Host '   2. Reparacion'
    Write-Host '   3. Administracion (acceso completo)'
    $sel = Read-Host '  Elegi [1-3]'
    $chosen = switch ($sel) { '1' { 'Diagnostico' } '2' { 'Reparacion' } '3' { 'Administracion' } default { 'Diagnostico' } }
    return $chosen
}

function Read-MenuChoice {
    param([string]$Raw)
    $t = $Raw.Trim()
    if ($t -eq '') { return @{ Type = 'none' } }
    if ($t -eq '0') { return @{ Type = 'exit' } }
    if ($t -eq '99') { return @{ Type = 'profile' } }
    if ($t -match '^(?i:v)$') { return @{ Type = 'back' } }
    if ($t -match '^(?i:m)$') { return @{ Type = 'root' } }
    if ($t -match '^(?i:\?)(\d+)$') { return @{ Type = 'help'; Index = [int]$Matches[1] } }
    $n = 0
    if ([int]::TryParse($t, [ref]$n)) { return @{ Type = 'select'; Index = $n } }
    return @{ Type = 'invalid' }
}

function Start-InteractiveMenu {
    param([string]$InitialPerfil)

    $activePerfil = $InitialPerfil
    if (-not $activePerfil) { $activePerfil = Select-Profile }
    Write-Log "Perfil activo: $activePerfil" 'INFO'

    $view = 'root'
    :menuLoop while ($true) {
        Clear-Host
        Show-Banner -ActivePerfil $activePerfil -View $view

        if ($view -eq 'root') {
            $cats = @($script:Categories.Keys | Where-Object { @(Get-CategoryModules $_ $activePerfil).Count -gt 0 })
            if ($cats.Count -eq 0) {
                Write-Host '  (Sin modulos disponibles para este perfil)' -ForegroundColor Yellow
            }
            for ($i = 0; $i -lt $cats.Count; $i++) {
                $cnt = @(Get-CategoryModules $cats[$i] $activePerfil).Count
                Write-Host ("   {0,2}. {1} ({2})" -f ($i + 1), $script:Categories[$cats[$i]], $cnt)
            }
            Write-Host ''
            Write-Host '   [99] cambiar perfil   [0] salir'
            $raw = Read-Host '  Opcion'
            $cmd = Read-MenuChoice $raw

            switch ($cmd.Type) {
                'exit' { break menuLoop }
                'profile' { $activePerfil = Select-Profile; $view = 'root' }
                'select' {
                    if ($cmd.Index -ge 1 -and $cmd.Index -le $cats.Count) { $view = $cats[$cmd.Index - 1] }
                    else { Write-Host '  Opcion invalida.' -ForegroundColor Yellow; Start-Sleep -Milliseconds 900 }
                }
                default { Write-Host '  Opcion invalida.' -ForegroundColor Yellow; Start-Sleep -Milliseconds 900 }
            }
        }
        else {
            $mods = @(Get-CategoryModules $view $activePerfil)
            for ($i = 0; $i -lt $mods.Count; $i++) {
                $m = $mods[$i].Mod
                Write-Host ("   {0,2}. [{1}] {2}" -f ($i + 1), $m.Risk, $m.Name) -ForegroundColor (Get-RiskColor $m.Risk)
            }
            Write-Host ''
            Write-Host '   [V] volver   [M] menu principal   [?N] ayuda   [99] cambiar perfil   [0] salir'
            $raw = Read-Host '  Opcion'
            $cmd = Read-MenuChoice $raw

            switch ($cmd.Type) {
                'exit' { break menuLoop }
                'back' { $view = 'root' }
                'root' { $view = 'root' }
                'profile' { $activePerfil = Select-Profile; $view = 'root' }
                'help' {
                    if ($cmd.Index -ge 1 -and $cmd.Index -le $mods.Count) { Show-Help $mods[$cmd.Index - 1] }
                    else { Write-Host '  No existe esa opcion.' -ForegroundColor Yellow }
                    Read-Host '  Enter para continuar' | Out-Null
                }
                'select' {
                    if ($cmd.Index -ge 1 -and $cmd.Index -le $mods.Count) {
                        $r = Invoke-Module -Id $mods[$cmd.Index - 1].Id -ActivePerfil $activePerfil
                        if ($r.result.data) { $r.result.data | Format-List | Out-Host }
                        if ($r.result.message) { Write-Host "  $($r.result.message)" -ForegroundColor Yellow }
                        Read-Host '  Enter para continuar' | Out-Null
                    }
                    else {
                        Write-Host '  Opcion invalida.' -ForegroundColor Yellow
                        Start-Sleep -Milliseconds 900
                    }
                }
                default { Write-Host '  Opcion invalida.' -ForegroundColor Yellow; Start-Sleep -Milliseconds 900 }
            }
        }
    }
    Write-Log 'Fin de sesion.' 'INFO'
}

# ============================================================================
#  FASE 1: Reportes e inventario - pasaporte del sistema
#  Funciones colectoras (compartidas por los modulos individuales y por
#  'passport'), health score, aplanado generico y exportadores HTML/JSON/CSV.
# ============================================================================

function Get-PassportHardware {
    $cs = Get-CimInstance Win32_ComputerSystem
    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
    $bb = Get-CimInstance Win32_BaseBoard -ErrorAction SilentlyContinue | Select-Object -First 1
    $bios = Get-CimInstance Win32_BIOS -ErrorAction SilentlyContinue | Select-Object -First 1
    return @{
        Manufacturer = $cs.Manufacturer
        Model        = $cs.Model
        CPU          = $cpu.Name
        Cores        = $cpu.NumberOfCores
        LogicalCPUs  = $cpu.NumberOfLogicalProcessors
        RAM_GB       = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        Board        = if ($bb) { "$($bb.Manufacturer) $($bb.Product)" } else { $null }
        BIOS         = if ($bios) { $bios.SMBIOSBIOSVersion } else { $null }
    }
}

function Get-PassportOS {
    $os = Get-CimInstance Win32_OperatingSystem
    return @{
        Caption     = $os.Caption
        Version     = $os.Version
        Build       = $os.BuildNumber
        Arch        = $os.OSArchitecture
        InstallDate = $os.InstallDate
        LastBoot    = $os.LastBootUpTime
        UptimeHours = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 1)
    }
}

function Get-PassportDisks {
    $disks = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction SilentlyContinue
    $pd = @{}
    try { Get-PhysicalDisk -ErrorAction Stop | ForEach-Object { $pd[$_.DeviceId] = $_.HealthStatus } } catch {}
    $rows = foreach ($d in $disks) {
        [pscustomobject]@{
            Model     = $d.Model
            Status    = $d.Status
            Health    = if ($pd.ContainsKey("$($d.Index)")) { $pd["$($d.Index)"] } else { $d.Status }
            SizeGB    = [math]::Round($d.Size / 1GB, 2)
            Interface = $d.InterfaceType
        }
    }
    return @{ disks = @($rows) }
}

function Get-PassportVolumes {
    $vols = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
        [pscustomobject]@{
            Drive   = $_.DeviceID
            FS      = $_.FileSystem
            SizeGB  = [math]::Round($_.Size / 1GB, 2)
            FreeGB  = [math]::Round($_.FreeSpace / 1GB, 2)
            FreePct = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } else { 0 }
        }
    }
    return @{ volumes = @($vols) }
}

function Get-PassportNetwork {
    $ifaces = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=True' | ForEach-Object {
        [pscustomobject]@{
            Description = $_.Description
            IP          = @($_.IPAddress)
            Gateway     = @($_.DefaultIPGateway)
            DNS         = @($_.DNSServerSearchOrder)
            DHCP        = $_.DHCPEnabled
        }
    }
    return @{ adapters = @($ifaces) }
}

function Get-PassportSoftware {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    $rows = foreach ($p in $paths) {
        Get-ItemProperty -Path $p -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -and -not $_.SystemComponent } |
            Select-Object @{N = 'Name'; E = { $_.DisplayName } },
                          @{N = 'Version'; E = { $_.DisplayVersion } },
                          @{N = 'Publisher'; E = { $_.Publisher } },
                          @{N = 'InstallDate'; E = { $_.InstallDate } }
    }
    return @($rows | Sort-Object Name -Unique)
}

function Get-PassportHotfixes {
    try {
        return @(Get-HotFix -ErrorAction Stop | Sort-Object InstalledOn -Descending | Select-Object -First 15 HotFixID, Description, InstalledOn)
    }
    catch { return @() }
}

function Get-PendingRebootInfo {
    # Chequea 5 indicadores conocidos de "requiere reinicio" en Windows.
    $reasons = @()
    try {
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending') { $reasons += 'ComponentBasedServicing' }
    } catch {}
    try {
        if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { $reasons += 'WindowsUpdate' }
    } catch {}
    try {
        $pfro = Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Name 'PendingFileRenameOperations' -ErrorAction SilentlyContinue
        if ($pfro -and $pfro.PendingFileRenameOperations) { $reasons += 'PendingFileRename' }
    } catch {}
    try {
        $cn = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' -Name 'ComputerName' -ErrorAction SilentlyContinue).ComputerName
        $acn = (Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' -Name 'ComputerName' -ErrorAction SilentlyContinue).ComputerName
        if ($cn -and $acn -and $cn -ne $acn) { $reasons += 'ComputerRename' }
    } catch {}
    try {
        $sccm = Invoke-CimMethod -Namespace 'root\ccm\clientsdk' -ClassName 'CCM_ClientUtilities' -MethodName 'DetermineIfRebootPending' -ErrorAction Stop
        if ($sccm -and ($sccm.RebootPending -or $sccm.IsHardRebootPending)) { $reasons += 'SCCM' }
    } catch {}
    return @{ pending = ($reasons.Count -gt 0); reasons = @($reasons) }
}

function Get-HealthScore {
    # Reglas fijas y deterministicas (ver Test-Fase1SelfChecks para casos de prueba).
    param($Passport)
    $deductions = @()

    foreach ($d in @($Passport.disks)) {
        if ($d.Health -and $d.Health -notin @('Healthy', 'OK')) {
            $deductions += @{ reason = "Disco con salud degradada: $($d.Model)"; points = 25 }
        }
        elseif ($d.Status -and $d.Status -ne 'OK') {
            $deductions += @{ reason = "Disco con estado anormal: $($d.Model)"; points = 25 }
        }
    }

    foreach ($v in @($Passport.volumes)) {
        if ($null -ne $v.FreePct) {
            if ($v.FreePct -lt 5) {
                $deductions += @{ reason = "Volumen $($v.Drive) con menos de 5% libre"; points = 25 }
            }
            elseif ($v.FreePct -lt 10) {
                $deductions += @{ reason = "Volumen $($v.Drive) con menos de 10% libre"; points = 15 }
            }
        }
    }

    if ($Passport.pendingReboot -and $Passport.pendingReboot.pending) {
        $deductions += @{ reason = 'Reinicio pendiente'; points = 10 }
    }

    if ($Passport.os -and $Passport.os.UptimeHours -and (($Passport.os.UptimeHours / 24) -gt 30)) {
        $deductions += @{ reason = 'Mas de 30 dias sin reiniciar'; points = 5 }
    }

    $totalDeduction = 0
    foreach ($d in $deductions) { $totalDeduction += $d.points }
    $score = 100 - $totalDeduction
    if ($score -lt 0) { $score = 0 }

    $rating = 'Critico'
    if ($score -ge 90) { $rating = 'Excelente' }
    elseif ($score -ge 75) { $rating = 'Bueno' }
    elseif ($score -ge 50) { $rating = 'Regular' }

    return @{ score = $score; rating = $rating; deductions = @($deductions) }
}

function New-SystemPassport {
    $hw = Get-PassportHardware
    $os = Get-PassportOS
    $disksInfo = Get-PassportDisks
    $volsInfo = Get-PassportVolumes
    $netInfo = Get-PassportNetwork
    $software = Get-PassportSoftware
    $hotfixes = Get-PassportHotfixes
    $reboot = Get-PendingRebootInfo

    $passport = [ordered]@{
        generatedAt   = (Get-Date -Format 's')
        computer      = $env:COMPUTERNAME
        hardware      = $hw
        os            = $os
        disks         = $disksInfo.disks
        volumes       = $volsInfo.volumes
        network       = $netInfo.adapters
        software      = $software
        softwareCount = @($software).Count
        hotfixes      = $hotfixes
        pendingReboot = $reboot
    }
    $passport.health = Get-HealthScore -Passport $passport
    return $passport
}

function ConvertTo-HtmlEscaped {
    param($Text)
    if ($null -eq $Text) { return '' }
    return [System.Net.WebUtility]::HtmlEncode("$Text")
}

function ConvertTo-FlatRows {
    # Aplana un objeto/hashtable/array anidado a filas Campo/Valor (para CSV generico).
    param($Obj, [string]$Prefix = '')
    $rows = @()
    if ($null -eq $Obj) { return $rows }
    if ($Obj -is [System.Collections.IDictionary]) {
        foreach ($k in $Obj.Keys) {
            $newPrefix = if ($Prefix) { "$Prefix.$k" } else { "$k" }
            $rows += ConvertTo-FlatRows -Obj $Obj[$k] -Prefix $newPrefix
        }
    }
    elseif (($Obj -is [System.Collections.IEnumerable]) -and -not ($Obj -is [string])) {
        $i = 0
        foreach ($item in $Obj) {
            $rows += ConvertTo-FlatRows -Obj $item -Prefix "$Prefix[$i]"
            $i++
        }
    }
    elseif ($Obj -is [System.Management.Automation.PSCustomObject]) {
        foreach ($p in $Obj.PSObject.Properties) {
            $newPrefix = if ($Prefix) { "$Prefix.$($p.Name)" } else { "$($p.Name)" }
            $rows += ConvertTo-FlatRows -Obj $p.Value -Prefix $newPrefix
        }
    }
    else {
        $rows += [pscustomobject]@{ Campo = $Prefix; Valor = "$Obj" }
    }
    return $rows
}

function Build-PassportHtml {
    param($Passport)

    $scoreColor = '#e74c3c'
    if ($Passport.health.score -ge 90) { $scoreColor = '#2ecc71' }
    elseif ($Passport.health.score -ge 75) { $scoreColor = '#8bc34a' }
    elseif ($Passport.health.score -ge 50) { $scoreColor = '#f1c40f' }

    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('<!DOCTYPE html>')
    [void]$sb.AppendLine('<html><head><meta charset="UTF-8">')
    [void]$sb.AppendLine("<title>Pasaporte del sistema - $(ConvertTo-HtmlEscaped $Passport.computer)</title>")
    [void]$sb.AppendLine(@'
<style>
body{font-family:Consolas,monospace;background:#0a0e27;color:#00ff41;padding:20px;}
h1{color:#00d4ff;border-bottom:2px solid #00d4ff;}
.meta{color:#ffd700;font-weight:bold;}
.score{font-size:52px;font-weight:bold;}
.rating{font-size:20px;margin-bottom:10px;}
details{background:#0f1330;border-left:4px solid #00d4ff;margin:12px 0;padding:10px 18px;border-radius:4px;}
summary{cursor:pointer;font-weight:bold;color:#00d4ff;font-size:16px;}
table{width:100%;border-collapse:collapse;margin-top:8px;}
td,th{padding:4px 10px;border-bottom:1px solid #23284a;text-align:left;font-size:13px;}
th{color:#ffd700;}
.badge{padding:2px 10px;border-radius:4px;font-weight:bold;font-size:12px;}
.badge-ok{background:#12401d;color:#7ee38b;}
.badge-warn{background:#4a3a00;color:#ffd76b;}
.badge-crit{background:#4a0f0f;color:#ff8a80;}
ul{margin:4px 0;}
</style>
'@)
    [void]$sb.AppendLine('</head><body>')
    [void]$sb.AppendLine('<h1>Renggli PC Solution - Pasaporte del sistema</h1>')
    [void]$sb.AppendLine("<p class='meta'>Equipo: $(ConvertTo-HtmlEscaped $Passport.computer) | Generado: $(ConvertTo-HtmlEscaped $Passport.generatedAt)</p>")

    [void]$sb.AppendLine("<div class='score' style='color:$scoreColor'>$($Passport.health.score)/100</div>")
    [void]$sb.AppendLine("<div class='rating' style='color:$scoreColor'>$(ConvertTo-HtmlEscaped $Passport.health.rating)</div>")
    if (@($Passport.health.deductions).Count -gt 0) {
        [void]$sb.AppendLine('<ul>')
        foreach ($d in $Passport.health.deductions) {
            [void]$sb.AppendLine("<li>-$($d.points) : $(ConvertTo-HtmlEscaped $d.reason)</li>")
        }
        [void]$sb.AppendLine('</ul>')
    }
    else {
        [void]$sb.AppendLine('<p>Sin hallazgos que penalicen el score.</p>')
    }

    [void]$sb.AppendLine('<details open><summary>Hardware</summary><table>')
    foreach ($k in @('Manufacturer', 'Model', 'CPU', 'Cores', 'LogicalCPUs', 'RAM_GB', 'Board', 'BIOS')) {
        [void]$sb.AppendLine("<tr><th>$k</th><td>$(ConvertTo-HtmlEscaped $Passport.hardware.$k)</td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine('<details open><summary>Sistema operativo</summary><table>')
    foreach ($k in @('Caption', 'Version', 'Build', 'Arch', 'InstallDate', 'LastBoot', 'UptimeHours')) {
        [void]$sb.AppendLine("<tr><th>$k</th><td>$(ConvertTo-HtmlEscaped $Passport.os.$k)</td></tr>")
    }
    $rebootBadge = 'badge-ok'; $rebootTxt = 'No'
    if ($Passport.pendingReboot.pending) { $rebootBadge = 'badge-warn'; $rebootTxt = "Si ($($Passport.pendingReboot.reasons -join ', '))" }
    [void]$sb.AppendLine("<tr><th>Reinicio pendiente</th><td><span class='badge $rebootBadge'>$(ConvertTo-HtmlEscaped $rebootTxt)</span></td></tr>")
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine('<details open><summary>Discos</summary><table><tr><th>Modelo</th><th>Estado</th><th>Salud</th><th>Tamano (GB)</th></tr>')
    foreach ($d in @($Passport.disks)) {
        $badge = 'badge-ok'
        if ($d.Health -and $d.Health -notin @('Healthy', 'OK')) { $badge = 'badge-crit' }
        [void]$sb.AppendLine("<tr><td>$(ConvertTo-HtmlEscaped $d.Model)</td><td>$(ConvertTo-HtmlEscaped $d.Status)</td><td><span class='badge $badge'>$(ConvertTo-HtmlEscaped $d.Health)</span></td><td>$($d.SizeGB)</td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine('<details><summary>Volumenes</summary><table><tr><th>Unidad</th><th>FS</th><th>Tamano (GB)</th><th>Libre (GB)</th><th>% Libre</th></tr>')
    foreach ($v in @($Passport.volumes)) {
        $badge = 'badge-ok'
        if ($v.FreePct -lt 5) { $badge = 'badge-crit' } elseif ($v.FreePct -lt 10) { $badge = 'badge-warn' }
        [void]$sb.AppendLine("<tr><td>$(ConvertTo-HtmlEscaped $v.Drive)</td><td>$(ConvertTo-HtmlEscaped $v.FS)</td><td>$($v.SizeGB)</td><td>$($v.FreeGB)</td><td><span class='badge $badge'>$($v.FreePct)%</span></td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine('<details><summary>Red</summary><table><tr><th>Adaptador</th><th>IP</th><th>Gateway</th><th>DNS</th><th>DHCP</th></tr>')
    foreach ($n in @($Passport.network)) {
        [void]$sb.AppendLine("<tr><td>$(ConvertTo-HtmlEscaped $n.Description)</td><td>$(ConvertTo-HtmlEscaped ($n.IP -join ', '))</td><td>$(ConvertTo-HtmlEscaped ($n.Gateway -join ', '))</td><td>$(ConvertTo-HtmlEscaped ($n.DNS -join ', '))</td><td>$($n.DHCP)</td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine("<details><summary>Ultimos hotfixes ($(@($Passport.hotfixes).Count))</summary><table><tr><th>ID</th><th>Descripcion</th><th>Instalado</th></tr>")
    foreach ($h in @($Passport.hotfixes)) {
        [void]$sb.AppendLine("<tr><td>$(ConvertTo-HtmlEscaped $h.HotFixID)</td><td>$(ConvertTo-HtmlEscaped $h.Description)</td><td>$(ConvertTo-HtmlEscaped $h.InstalledOn)</td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine("<details><summary>Software instalado ($($Passport.softwareCount))</summary><table><tr><th>Nombre</th><th>Version</th><th>Publisher</th></tr>")
    foreach ($s in @($Passport.software)) {
        [void]$sb.AppendLine("<tr><td>$(ConvertTo-HtmlEscaped $s.Name)</td><td>$(ConvertTo-HtmlEscaped $s.Version)</td><td>$(ConvertTo-HtmlEscaped $s.Publisher)</td></tr>")
    }
    [void]$sb.AppendLine('</table></details>')

    [void]$sb.AppendLine('</body></html>')
    return $sb.ToString()
}

function Export-SystemPassport {
    param($Passport, [string]$Path, [string]$Format)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    switch ($Format) {
        'json' { $Passport | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $Path -Encoding UTF8 }
        'csv' { ConvertTo-FlatRows -Obj $Passport | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8 }
        default { Build-PassportHtml -Passport $Passport | Set-Content -LiteralPath $Path -Encoding UTF8 }
    }
}

function Test-Fase1SelfChecks {
    # Verificacion minima corrible (ver PARAMETER SelfTest): valida Get-HealthScore
    # y ConvertTo-FlatRows con casos sinteticos, sin tocar el sistema real.
    $allOk = $true

    function Assert-Equal($actual, $expected, $label) {
        if ("$actual" -eq "$expected") {
            Write-Host "  [PASS] $label" -ForegroundColor Green
            return $true
        }
        Write-Host "  [FAIL] $label (esperado: $expected, obtenido: $actual)" -ForegroundColor Red
        return $false
    }

    $p1 = @{ disks = @(@{ Model = 'D1'; Status = 'OK'; Health = 'Healthy' }); volumes = @(@{ Drive = 'C:'; FreePct = 50 }); pendingReboot = @{ pending = $false }; os = @{ UptimeHours = 10 } }
    $h1 = Get-HealthScore -Passport $p1
    $allOk = (Assert-Equal $h1.score 100 'Caso sano: score 100') -and $allOk
    $allOk = (Assert-Equal $h1.rating 'Excelente' 'Caso sano: rating Excelente') -and $allOk

    $p2 = @{ disks = @(@{ Model = 'D1'; Status = 'OK'; Health = 'Degraded' }); volumes = @(@{ Drive = 'C:'; FreePct = 50 }); pendingReboot = @{ pending = $false }; os = @{ UptimeHours = 10 } }
    $h2 = Get-HealthScore -Passport $p2
    $allOk = (Assert-Equal $h2.score 75 'Disco degradado: score 75') -and $allOk

    $p3 = @{ disks = @(@{ Model = 'D1'; Status = 'OK'; Health = 'Healthy' }); volumes = @(@{ Drive = 'C:'; FreePct = 8 }); pendingReboot = @{ pending = $false }; os = @{ UptimeHours = 10 } }
    $h3 = Get-HealthScore -Passport $p3
    $allOk = (Assert-Equal $h3.score 85 'Volumen <10% libre: score 85') -and $allOk

    $p4 = @{ disks = @(@{ Model = 'D1'; Status = 'OK'; Health = 'Healthy' }); volumes = @(@{ Drive = 'C:'; FreePct = 50 }); pendingReboot = @{ pending = $true }; os = @{ UptimeHours = 10 } }
    $h4 = Get-HealthScore -Passport $p4
    $allOk = (Assert-Equal $h4.score 90 'Reinicio pendiente: score 90') -and $allOk
    $allOk = (Assert-Equal $h4.rating 'Excelente' 'Reinicio pendiente: aun Excelente en el limite') -and $allOk

    $p5 = @{ disks = @(@{ Model = 'D1'; Status = 'OK'; Health = 'Degraded' }); volumes = @(@{ Drive = 'C:'; FreePct = 3 }); pendingReboot = @{ pending = $true }; os = @{ UptimeHours = (31 * 24) } }
    $h5 = Get-HealthScore -Passport $p5
    $allOk = (Assert-Equal $h5.score 35 'Combinado (disco+volumen+reboot+uptime): score 35') -and $allOk
    $allOk = (Assert-Equal $h5.rating 'Critico' 'Combinado: rating Critico') -and $allOk

    $flat = ConvertTo-FlatRows -Obj @{ a = 1; b = @{ c = 2 } }
    $allOk = (Assert-Equal $flat.Count 2 'ConvertTo-FlatRows: aplana anidados') -and $allOk

    return $allOk
}

# ============================================================================
#  FASE 2: Diagnostico profundo
#  Auditor de autostart/persistencia, atributos SMART reales e inteligencia
#  de Event Log (patrones especificos, no "eventos criticos" genericos).
# ============================================================================

function Get-AutostartRegistry {
    $keys = @(
        @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'; Scope = 'HKLM' },
        @{ Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'; Scope = 'HKLM' },
        @{ Path = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Scope = 'HKLM32' },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'; Scope = 'HKCU' },
        @{ Path = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'; Scope = 'HKCU' }
    )
    $ignoreProps = @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')
    $rows = foreach ($k in $keys) {
        $props = Get-ItemProperty -Path $k.Path -ErrorAction SilentlyContinue
        if (-not $props) { continue }
        foreach ($p in $props.PSObject.Properties) {
            if ($p.Name -in $ignoreProps) { continue }
            [pscustomobject]@{ Source = "Registry:$($k.Scope)"; Name = $p.Name; Command = "$($p.Value)"; Path = $k.Path }
        }
    }
    return @($rows)
}

function Get-AutostartFolders {
    $folders = @(
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Startup'),
        (Join-Path $env:AppData 'Microsoft\Windows\Start Menu\Programs\Startup')
    )
    $rows = foreach ($f in $folders) {
        if (-not (Test-Path -LiteralPath $f)) { continue }
        Get-ChildItem -LiteralPath $f -File -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{ Source = 'StartupFolder'; Name = $_.Name; Command = $_.FullName; Path = $f }
        }
    }
    return @($rows)
}

function Get-AutostartTasks {
    try {
        $tasks = Get-ScheduledTask -ErrorAction Stop | Where-Object {
            $_.State -ne 'Disabled' -and ($_.Triggers | Where-Object { $_.CimClass.CimClassName -match 'Logon|Boot|Registration' })
        }
    }
    catch { return @() }
    $rows = foreach ($t in $tasks) {
        $cmd = ($t.Actions | ForEach-Object {
                if ($_.Execute) { "$($_.Execute) $($_.Arguments)".Trim() } else { "$($_.CimClass.CimClassName)" }
            }) -join '; '
        [pscustomobject]@{
            Source     = 'ScheduledTask'
            Name       = $t.TaskName
            Command    = $cmd
            Path       = $t.TaskPath
            NonDefault = ($t.TaskPath -notlike '\Microsoft\Windows\*')
        }
    }
    return @($rows)
}

function Get-AutostartServices {
    $rows = Get-CimInstance Win32_Service -Filter "StartMode='Auto'" -ErrorAction SilentlyContinue | ForEach-Object {
        $exePath = $null
        if ($_.PathName -match '^"([^"]+)"') { $exePath = $Matches[1] }
        elseif ($_.PathName -match '^(\S+)') { $exePath = $Matches[1] }
        $signed = $false; $signer = $null
        if ($exePath -and (Test-Path -LiteralPath $exePath -ErrorAction SilentlyContinue)) {
            try {
                $sig = Get-AuthenticodeSignature -LiteralPath $exePath -ErrorAction Stop
                $signed = ($sig.Status -eq 'Valid')
                if ($sig.SignerCertificate) { $signer = $sig.SignerCertificate.Subject }
            }
            catch {}
        }
        [pscustomobject]@{
            Source       = 'Service'
            Name         = $_.DisplayName
            Command      = $_.PathName
            Signed       = $signed
            Signer       = $signer
            NonMicrosoft = -not ($signer -and $signer -match 'Microsoft')
        }
    }
    return @($rows)
}

function Get-WmiPersistence {
    # Suscripciones de eventos WMI: mecanismo de persistencia "fileless" poco revisado.
    $rows = @()
    try {
        Get-CimInstance -Namespace 'root\subscription' -ClassName '__EventFilter' -ErrorAction Stop | ForEach-Object {
            $rows += [pscustomobject]@{ Source = 'WMI-EventFilter'; Name = $_.Name; Command = $_.Query }
        }
    }
    catch {}
    try {
        Get-CimInstance -Namespace 'root\subscription' -ClassName 'CommandLineEventConsumer' -ErrorAction Stop | ForEach-Object {
            $rows += [pscustomobject]@{ Source = 'WMI-CommandLineConsumer'; Name = $_.Name; Command = $_.CommandLineTemplate }
        }
    }
    catch {}
    try {
        Get-CimInstance -Namespace 'root\subscription' -ClassName '__FilterToConsumerBinding' -ErrorAction Stop | ForEach-Object {
            $rows += [pscustomobject]@{ Source = 'WMI-Binding'; Name = "$($_.Filter) -> $($_.Consumer)"; Command = $null }
        }
    }
    catch {}
    return @($rows)
}

function Get-IfeoDebuggers {
    # Image File Execution Options con 'Debugger': tecnica clasica de hijacking
    # (ej. reemplazar sethc.exe/utilman.exe por una backdoor via "sticky keys").
    $base = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options'
    $rows = @()
    if (Test-Path -LiteralPath $base) {
        Get-ChildItem -Path $base -ErrorAction SilentlyContinue | ForEach-Object {
            $dbg = (Get-ItemProperty -Path $_.PSPath -Name 'Debugger' -ErrorAction SilentlyContinue).Debugger
            if ($dbg) { $rows += [pscustomobject]@{ Source = 'IFEO'; Name = $_.PSChildName; Command = $dbg } }
        }
    }
    return @($rows)
}

function New-AutostartAudit {
    $registry = Get-AutostartRegistry
    $folders = Get-AutostartFolders
    $tasks = Get-AutostartTasks
    $services = Get-AutostartServices
    $wmi = Get-WmiPersistence
    $ifeo = Get-IfeoDebuggers

    $suspicious = @()
    foreach ($r in $registry) {
        if ($r.Command -match '\\(AppData\\Local\\Temp|Temp\\|Users\\Public)\\') {
            $suspicious += "Registro '$($r.Name)' arranca desde una carpeta temporal: $($r.Command)"
        }
    }
    foreach ($s in $services) {
        if ($s.NonMicrosoft -and -not $s.Signed) {
            $suspicious += "Servicio automatico sin firma valida: $($s.Name) ($($s.Command))"
        }
    }
    if (@($wmi).Count -gt 0) {
        $suspicious += "Hay $(@($wmi).Count) elemento(s) de suscripcion WMI (root\subscription) - mecanismo de persistencia poco comun, revisar manualmente"
    }
    foreach ($i in $ifeo) {
        $suspicious += "IFEO Debugger en '$($i.Name)': $($i.Command)"
    }

    return [ordered]@{
        registry   = $registry
        folders    = $folders
        tasks      = $tasks
        services   = $services
        wmi        = $wmi
        ifeo       = $ifeo
        totalCount = (@($registry).Count + @($folders).Count + @($tasks).Count + @($services).Count + @($wmi).Count + @($ifeo).Count)
        suspicious = @($suspicious)
    }
}

function Get-SmartDeep {
    try {
        $disks = Get-PhysicalDisk -ErrorAction Stop
    }
    catch {
        return @{ supported = $false; reason = 'Get-PhysicalDisk no disponible en este equipo (falta el modulo Storage).'; disks = @() }
    }
    $rows = foreach ($d in $disks) {
        $counter = $null
        try { $counter = $d | Get-StorageReliabilityCounter -ErrorAction Stop } catch {}
        [pscustomobject]@{
            FriendlyName           = $d.FriendlyName
            Health                 = "$($d.HealthStatus)"
            OperationalStatus      = "$($d.OperationalStatus)"
            MediaType              = "$($d.MediaType)"
            SizeGB                 = [math]::Round($d.Size / 1GB, 2)
            PowerOnHours           = if ($counter) { $counter.PowerOnHours } else { $null }
            Temperature            = if ($counter) { $counter.Temperature } else { $null }
            TemperatureMax         = if ($counter) { $counter.TemperatureMax } else { $null }
            ReadErrorsTotal        = if ($counter) { $counter.ReadErrorsTotal } else { $null }
            ReadErrorsUncorrected  = if ($counter) { $counter.ReadErrorsUncorrected } else { $null }
            WriteErrorsTotal       = if ($counter) { $counter.WriteErrorsTotal } else { $null }
            WriteErrorsUncorrected = if ($counter) { $counter.WriteErrorsUncorrected } else { $null }
            Wear                   = if ($counter) { $counter.Wear } else { $null }
        }
    }
    $rows = @($rows)
    $atRisk = @($rows | Where-Object {
            ($_.ReadErrorsUncorrected -and $_.ReadErrorsUncorrected -gt 0) -or
            ($_.WriteErrorsUncorrected -and $_.WriteErrorsUncorrected -gt 0) -or
            ($_.Wear -and $_.Wear -gt 90) -or
            ($_.Health -and $_.Health -ne 'Healthy')
        })
    return @{ supported = $true; disks = $rows; atRiskCount = $atRisk.Count }
}

function Get-EventIntelligence {
    param([int]$Days = 14)
    $since = (Get-Date).AddDays(-$Days)

    function Get-EventsFor {
        param([string]$LogName, [string]$ProviderMatch, [int[]]$Ids)
        try {
            $filter = @{ LogName = $LogName; StartTime = $since }
            if ($Ids) { $filter.Id = $Ids }
            $ev = Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
            if ($ProviderMatch) { $ev = $ev | Where-Object { $_.ProviderName -match $ProviderMatch } }
            return @($ev | Select-Object TimeCreated, Id, ProviderName, @{N = 'Message'; E = { ($_.Message -split "`n")[0] } })
        }
        catch { return @() }
    }

    $unexpectedShutdowns = @()
    $unexpectedShutdowns += Get-EventsFor -LogName 'System' -ProviderMatch 'Microsoft-Windows-Kernel-Power' -Ids @(41)
    $unexpectedShutdowns += Get-EventsFor -LogName 'System' -ProviderMatch 'EventLog' -Ids @(6008)

    $diskWarnings = Get-EventsFor -LogName 'System' -ProviderMatch '^[Dd]isk$' -Ids @(7, 11, 51, 153)
    $bugchecks = Get-EventsFor -LogName 'System' -ProviderMatch 'BugCheck' -Ids @(1001)
    $serviceFails = Get-EventsFor -LogName 'System' -ProviderMatch 'Service Control Manager' -Ids @(7000, 7001, 7009, 7011, 7026, 7031, 7034)

    return [ordered]@{
        periodDays          = $Days
        unexpectedShutdowns = @($unexpectedShutdowns | Sort-Object TimeCreated -Descending)
        diskWarnings        = @($diskWarnings | Sort-Object TimeCreated -Descending)
        bugchecks           = @($bugchecks | Sort-Object TimeCreated -Descending)
        serviceFailures     = @($serviceFails | Sort-Object TimeCreated -Descending)
        summary             = "Ultimos $Days dias: $(@($unexpectedShutdowns).Count) apagado(s) inesperado(s), $(@($diskWarnings).Count) evento(s) de disco, $(@($bugchecks).Count) bugcheck(s), $(@($serviceFails).Count) fallo(s) de servicio."
    }
}

# ============================================================================
#  FASE 3: Reparacion (poco conocidas)
#  Reset real de Windows Update, verificar/reparar repositorio WMI, auditoria
#  y backup de drivers, y BitLocker (estado + clave de recuperacion).
# ============================================================================

function Get-PnpErrorMeaning {
    param([int]$Code)
    $map = @{
        1  = 'Dispositivo mal configurado (falta driver o configuracion incorrecta)'
        3  = 'Driver corrupto o falta memoria para cargarlo'
        10 = 'El dispositivo no pudo iniciar'
        12 = 'No hay suficientes recursos libres (IRQ/memoria)'
        14 = 'El dispositivo requiere reinicio para funcionar'
        18 = 'Reinstalar los drivers de este dispositivo'
        19 = 'Registro corrupto (configuracion del dispositivo)'
        21 = 'Windows esta quitando el dispositivo (esperar o reiniciar)'
        22 = 'Dispositivo deshabilitado'
        24 = 'Dispositivo no presente, no funciona o le faltan drivers'
        28 = 'Los drivers no estan instalados'
        31 = 'Windows no pudo cargar los drivers para este dispositivo'
        32 = 'Driver deshabilitado (inicio de servicio deshabilitado)'
        37 = 'Windows no pudo inicializar los drivers'
        39 = 'Windows no pudo cargar el driver (posible corrupcion o falta de archivo)'
        41 = 'Windows cargo los drivers pero no puede encontrar el dispositivo'
        43 = 'Windows detuvo el dispositivo por reportar problemas'
        45 = 'Dispositivo no conectado actualmente (hardware removido)'
    }
    if ($map.ContainsKey($Code)) { return $map[$Code] }
    return "Codigo $Code (ver 'Device Manager Error Codes' de Microsoft)"
}

function Get-DriverAudit {
    $errorDevices = Get-CimInstance Win32_PnPEntity -ErrorAction SilentlyContinue | Where-Object { $_.ConfigManagerErrorCode -ne 0 } | ForEach-Object {
        [pscustomobject]@{
            Name         = $_.Name
            DeviceId     = $_.DeviceID
            ErrorCode    = $_.ConfigManagerErrorCode
            ErrorMeaning = Get-PnpErrorMeaning $_.ConfigManagerErrorCode
        }
    }
    $unsigned = Get-CimInstance Win32_PnPSignedDriver -ErrorAction SilentlyContinue | Where-Object { $_.IsSigned -eq $false } | ForEach-Object {
        [pscustomobject]@{ Device = $_.DeviceName; Manufacturer = $_.Manufacturer; DriverVersion = $_.DriverVersion; InfName = $_.InfName }
    }
    $errorDevices = @($errorDevices)
    $unsigned = @($unsigned)
    return @{
        devicesWithErrors = $errorDevices
        unsignedDrivers   = $unsigned
        errorCount        = $errorDevices.Count
        unsignedCount     = $unsigned.Count
    }
}

function Invoke-DriverBackup {
    param([string]$Destination)
    if (-not (Confirm-Action "Exportar todos los drivers de terceros a: $Destination ?" $true $false)) {
        return @{ skipped = $true; reason = 'no confirmado' }
    }
    if (-not (Test-Path -LiteralPath $Destination)) { New-Item -ItemType Directory -Path $Destination -Force | Out-Null }
    $proc = Start-Process -FilePath 'dism.exe' -ArgumentList '/Online', '/Export-Driver', "/Destination:$Destination" -Wait -PassThru -NoNewWindow
    $count = @(Get-ChildItem -LiteralPath $Destination -Filter '*.inf' -Recurse -ErrorAction SilentlyContinue).Count
    return @{ destination = $Destination; exitCode = $proc.ExitCode; infCount = $count }
}

function Invoke-WindowsUpdateReset {
    if (-not (Confirm-Action 'Reiniciar el stack de Windows Update (detiene servicios, renombra caches, reinicia servicios)?' $true)) {
        return @{ skipped = $true; reason = 'no confirmado' }
    }
    $services = @('wuauserv', 'bits', 'cryptsvc', 'msiserver')
    $stopped = @()
    foreach ($s in $services) {
        try { Stop-Service -Name $s -Force -ErrorAction Stop; $stopped += $s }
        catch { Write-Log "No se pudo detener $s`: $($_.Exception.Message)" 'WARN' }
    }

    $ts = Get-Date -Format 'yyyyMMdd_HHmmss'
    $targets = @(
        @{ Path = "$env:SystemRoot\SoftwareDistribution"; Name = 'SoftwareDistribution' },
        @{ Path = "$env:SystemRoot\System32\catroot2"; Name = 'catroot2' }
    )
    $renamed = @()
    foreach ($t in $targets) {
        if (Test-Path -LiteralPath $t.Path) {
            $bakName = "$($t.Name).bak_$ts"
            try {
                Rename-Item -LiteralPath $t.Path -NewName $bakName -ErrorAction Stop
                $renamed += @{ original = $t.Path; backup = (Join-Path (Split-Path $t.Path -Parent) $bakName) }
            }
            catch { Write-Log "No se pudo renombrar $($t.Path): $($_.Exception.Message)" 'WARN' }
        }
    }

    $started = @()
    foreach ($s in $services) {
        try { Start-Service -Name $s -ErrorAction Stop; $started += $s }
        catch { Write-Log "No se pudo iniciar $s`: $($_.Exception.Message)" 'WARN' }
    }

    return @{
        stoppedServices = @($stopped)
        startedServices = @($started)
        renamedFolders  = @($renamed)
        note            = 'Las carpetas viejas se conservaron con sufijo .bak_<fecha> por si hace falta revertir; Windows recreara SoftwareDistribution/catroot2 automaticamente.'
    }
}

function Invoke-WmiRepositoryCheck {
    # winmgmt puede devolver 3 estados: consistente, inconsistente, o "no se pudo
    # determinar" (ej. acceso denegado, servicio WMI ocupado). Solo se ofrece
    # reparar cuando esta CONFIRMADO inconsistente; el estado indeterminado nunca
    # dispara una reparacion a ciegas.
    $verify = (& winmgmt.exe /verifyrepository 2>&1 | Out-String).Trim()
    $isConsistent = ($verify -match 'consistent' -and $verify -notmatch 'inconsistent')
    $isInconsistent = ($verify -match 'inconsistent')
    $result = [ordered]@{ verifyOutput = $verify; consistent = $isConsistent; repaired = $false; salvageOutput = $null }

    if ($isConsistent) { return $result }

    if (-not $isInconsistent) {
        # No se pudo determinar el estado real (ej. acceso denegado). No se ofrece reparar.
        $result.consistent = $null
        $result.undetermined = $true
        return $result
    }

    if (-not (Confirm-Action 'El repositorio WMI aparece INCONSISTENTE. Ejecutar reparacion (winmgmt /salvagerepository)?' $true)) {
        $result.skipped = $true
        return $result
    }

    $salvage = (& winmgmt.exe /salvagerepository 2>&1 | Out-String).Trim()
    $result.salvageOutput = $salvage
    $result.repaired = $true

    $reverify = (& winmgmt.exe /verifyrepository 2>&1 | Out-String).Trim()
    $result.consistentAfterRepair = ($reverify -match 'consistent' -and $reverify -notmatch 'inconsistent')
    return $result
}

function Get-BitLockerStatus {
    try {
        $vols = Get-BitLockerVolume -ErrorAction Stop
    }
    catch {
        return @{ supported = $false; reason = 'BitLocker no disponible en este equipo (modulo no encontrado o feature no instalada).'; volumes = @() }
    }
    $rows = foreach ($v in $vols) {
        [pscustomobject]@{
            MountPoint           = $v.MountPoint
            VolumeStatus         = "$($v.VolumeStatus)"
            ProtectionStatus     = "$($v.ProtectionStatus)"
            EncryptionPercentage = $v.EncryptionPercentage
            KeyProtectorTypes    = @($v.KeyProtector | ForEach-Object { "$($_.KeyProtectorType)" })
        }
    }
    return @{ supported = $true; volumes = @($rows) }
}

function Get-BitLockerRecoveryKeys {
    try {
        $vols = Get-BitLockerVolume -ErrorAction Stop
    }
    catch {
        return @{ supported = $false; reason = 'BitLocker no disponible en este equipo.'; volumes = @() }
    }
    $rows = foreach ($v in $vols) {
        $recoveryProtectors = @($v.KeyProtector | Where-Object { $_.KeyProtectorType -eq 'RecoveryPassword' })
        [pscustomobject]@{
            MountPoint   = $v.MountPoint
            RecoveryKeys = @($recoveryProtectors | ForEach-Object { [pscustomobject]@{ Id = $_.KeyProtectorId; RecoveryPassword = $_.RecoveryPassword } })
        }
    }
    return @{ supported = $true; volumes = @($rows) }
}

# ============================================================================
#  FASE 4: Servidores / empresa
#  Certificados, salud de servicios, AD/IIS, y motores de base de datos
#  (Postgres/MySQL/MSSQL: deteccion cross-engine; gestion de password solo
#  para PostgreSQL en esta version).
# ============================================================================

function Get-CertificateExpiryScan {
    param([int]$WarnDays = 30)
    $stores = @('Cert:\LocalMachine\My', 'Cert:\LocalMachine\WebHosting', 'Cert:\LocalMachine\Remote Desktop')
    $now = Get-Date
    $rows = foreach ($s in $stores) {
        if (-not (Test-Path -LiteralPath $s)) { continue }
        Get-ChildItem -Path $s -ErrorAction SilentlyContinue | ForEach-Object {
            $daysLeft = [math]::Round(($_.NotAfter - $now).TotalDays, 0)
            $status = 'OK'
            if ($daysLeft -lt 0) { $status = 'Expired' } elseif ($daysLeft -le $WarnDays) { $status = 'ExpiringSoon' }
            [pscustomobject]@{
                Store      = $s
                Subject    = $_.Subject
                Thumbprint = $_.Thumbprint
                NotAfter   = $_.NotAfter
                DaysLeft   = $daysLeft
                Status     = $status
            }
        }
    }
    $rows = @($rows)
    $expiring = @($rows | Where-Object { $_.Status -ne 'OK' } | Sort-Object DaysLeft)
    return @{ warnDays = $WarnDays; total = $rows.Count; expiringCount = $expiring.Count; expiring = $expiring; all = $rows }
}

function Get-ServiceHealth {
    # Excluye servicios "Automatico (Trigger Start)" nativos de Windows: se detienen
    # solos hasta que ocurre su evento disparador, y eso es normal, no una falla.
    # No cubre actualizadores de terceros (Brave/Google/etc.) que se autodetienen por
    # logica propia sin usar el mecanismo de trigger de Windows; esos quedan listados
    # igual, con la advertencia correspondiente en la ayuda del modulo.
    $rows = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object {
        $_.StartMode -eq 'Auto' -and $_.State -ne 'Running'
    } | Where-Object {
        -not (Test-Path -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Services\$($_.Name)\TriggerInfo")
    } | ForEach-Object {
        [pscustomobject]@{ Name = $_.DisplayName; ServiceName = $_.Name; State = $_.State; StartMode = $_.StartMode; ExitCode = $_.ExitCode }
    }
    $rows = @($rows)
    return @{ downCount = $rows.Count; down = $rows }
}

function Get-AdHealth {
    $cs = Get-CimInstance Win32_ComputerSystem
    if (-not $cs.PartOfDomain) {
        return @{ domainJoined = $false; domain = $null }
    }
    $result = [ordered]@{ domainJoined = $true; domain = $cs.Domain }
    try { $result.secureChannelOk = Test-ComputerSecureChannel -ErrorAction Stop }
    catch { $result.secureChannelOk = $null; $result.secureChannelError = $_.Exception.Message }
    $netlogon = Get-Service -Name Netlogon -ErrorAction SilentlyContinue
    $result.netlogonStatus = if ($netlogon) { "$($netlogon.Status)" } else { 'not-found' }
    $sysvolPath = "\\$($cs.Domain)\SYSVOL"
    $result.sysvolReachable = Test-Path -LiteralPath $sysvolPath -ErrorAction SilentlyContinue
    return $result
}

function Get-IisHealth {
    if (-not (Get-Module -ListAvailable -Name WebAdministration)) {
        return @{ supported = $false; reason = 'Modulo WebAdministration no disponible (IIS no instalado o feature de administracion no presente).' }
    }
    try { Import-Module WebAdministration -ErrorAction Stop }
    catch { return @{ supported = $false; reason = "No se pudo cargar WebAdministration: $($_.Exception.Message)" } }

    $sites = @(Get-Website -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; State = "$($_.State)"; PhysicalPath = $_.PhysicalPath }
        })
    $pools = @(Get-ChildItem 'IIS:\AppPools' -ErrorAction SilentlyContinue | ForEach-Object {
            [pscustomobject]@{ Name = $_.Name; State = "$($_.State)" }
        })
    $stoppedSites = @($sites | Where-Object { $_.State -ne 'Started' })
    $stoppedPools = @($pools | Where-Object { $_.State -ne 'Started' })
    return @{ supported = $true; sites = $sites; appPools = $pools; stoppedSitesCount = $stoppedSites.Count; stoppedPoolsCount = $stoppedPools.Count }
}

function Get-PostgresInstances {
    # Detecta TODAS las instancias postgresql-x64-* via servicio de Windows.
    # Compartida por 'db-status' y 'postgres-password' para no duplicar el
    # parseo de PathName (mismo patron ya probado en modules\postgres_manager.bat).
    $svcs = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'postgresql-x64-*' }
    $rows = foreach ($s in $svcs) {
        $binDir = $null; $dataDir = $null; $port = '5432'
        if ($s.PathName -match '"([^"]+)"') { $binDir = Split-Path $Matches[1] } elseif ($s.PathName -match '^(\S+)') { $binDir = Split-Path $Matches[1] }
        if ($s.PathName -match '-D\s+"([^"]+)"') { $dataDir = $Matches[1] } elseif ($s.PathName -match '-D\s+(\S+)') { $dataDir = $Matches[1] }
        if ($dataDir) {
            $conf = Join-Path $dataDir 'postgresql.conf'
            if (Test-Path -LiteralPath $conf) {
                $m = Select-String -LiteralPath $conf -Pattern '^\s*port\s*=\s*(\d+)' -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($m) { $port = $m.Matches[0].Groups[1].Value }
            }
        }
        [pscustomobject]@{ ServiceName = $s.Name; State = "$($s.State)"; BinDir = $binDir; DataDir = $dataDir; Port = $port }
    }
    return @($rows)
}

function Get-DbEngineStatus {
    $rows = @()

    foreach ($pg in Get-PostgresInstances) {
        $version = $null
        if ($pg.BinDir) {
            $exe = Join-Path $pg.BinDir 'postgres.exe'
            if (Test-Path -LiteralPath $exe) { try { $version = (Get-Item -LiteralPath $exe -ErrorAction Stop).VersionInfo.ProductVersion } catch {} }
        }
        $rows += [pscustomobject]@{ Engine = 'PostgreSQL'; ServiceName = $pg.ServiceName; State = $pg.State; Port = $pg.Port; Version = $version }
    }

    $mysqlSvcs = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -like 'MySQL*' }
    foreach ($s in $mysqlSvcs) {
        $exePath = $null
        if ($s.PathName -match '"([^"]+)"') { $exePath = $Matches[1] } elseif ($s.PathName -match '^(\S+)') { $exePath = $Matches[1] }
        $version = $null
        if ($exePath -and (Test-Path -LiteralPath $exePath -ErrorAction SilentlyContinue)) { try { $version = (Get-Item -LiteralPath $exePath -ErrorAction Stop).VersionInfo.ProductVersion } catch {} }
        $rows += [pscustomobject]@{ Engine = 'MySQL'; ServiceName = $s.Name; State = "$($s.State)"; Port = $null; Version = $version }
    }

    $mssqlSvcs = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object { $_.Name -eq 'MSSQLSERVER' -or $_.Name -like 'MSSQL$*' }
    foreach ($s in $mssqlSvcs) {
        $exePath = $null
        if ($s.PathName -match '"([^"]+)"') { $exePath = $Matches[1] } elseif ($s.PathName -match '^(\S+)') { $exePath = $Matches[1] }
        $version = $null
        if ($exePath -and (Test-Path -LiteralPath $exePath -ErrorAction SilentlyContinue)) { try { $version = (Get-Item -LiteralPath $exePath -ErrorAction Stop).VersionInfo.ProductVersion } catch {} }
        $rows += [pscustomobject]@{ Engine = 'MSSQL'; ServiceName = $s.Name; State = "$($s.State)"; Port = $null; Version = $version }
    }

    $rows = @($rows)
    return @{ instances = $rows; count = $rows.Count }
}

function Invoke-PostgresPasswordManager {
    if ($Silent) {
        return @{ skipped = $true; reason = 'Este modulo requiere modo interactivo; no acepta password por parametro/automatizacion, por seguridad.' }
    }

    $instances = Get-PostgresInstances
    if (-not $instances) {
        return @{ supported = $false; reason = 'No se detecto ninguna instancia de PostgreSQL en este equipo.' }
    }
    $inst = $instances[0]
    if ($instances.Count -gt 1) {
        Write-Host '  Instancias detectadas:'
        for ($i = 0; $i -lt $instances.Count; $i++) { Write-Host "    $($i+1). $($instances[$i].ServiceName)  (puerto $($instances[$i].Port))" }
        $sel = Read-Host '  Elegi instancia [1..N] (Enter=1)'
        $n = 0
        if ([int]::TryParse($sel, [ref]$n) -and $n -ge 1 -and $n -le $instances.Count) { $inst = $instances[$n - 1] }
    }
    if (-not $inst.BinDir -or -not (Test-Path -LiteralPath (Join-Path $inst.BinDir 'psql.exe'))) {
        return @{ supported = $false; reason = "No se encontro psql.exe para la instancia $($inst.ServiceName)." }
    }
    $psql = Join-Path $inst.BinDir 'psql.exe'
    $pgCtl = Join-Path $inst.BinDir 'pg_ctl.exe'
    $hbaPath = Join-Path $inst.DataDir 'pg_hba.conf'

    Write-Host "  Instancia: $($inst.ServiceName)  |  Data dir: $($inst.DataDir)  |  Puerto: $($inst.Port)"

    $superuser = Read-Host '  Superusuario [postgres]'
    if (-not $superuser) { $superuser = 'postgres' }
    $securePwd = Read-Host '  Password del superusuario (Enter si no la conoces)' -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)
    $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)

    & $psql -h 127.0.0.1 -p $inst.Port -U $superuser -d postgres -tA -w -c 'SELECT 1;' *> $null
    $testOk = ($LASTEXITCODE -eq 0)

    $mode = 'DIRECTO'
    $trustActive = $false
    $hbaBackup = $null

    if (-not $testOk) {
        Write-Host '  [!] No se pudo conectar. Modo RECUPERACION disponible (trust temporal en pg_hba, sin reiniciar el servicio).' -ForegroundColor Yellow
        if (-not (Confirm-Action 'Activar modo recuperacion (trust temporal en pg_hba.conf)?' $true)) {
            return @{ skipped = $true; reason = 'no confirmado (recuperacion)' }
        }
        if (-not (Test-Path -LiteralPath $hbaPath)) { return @{ supported = $false; reason = "No se encontro pg_hba.conf en $hbaPath" } }

        $hbaBackup = "$hbaPath.renggliBak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
        Copy-Item -LiteralPath $hbaPath -Destination $hbaBackup -Force
        $trustLines = @('# === RENGGLI-TEMP-TRUST ===', 'local all all trust', 'host all all 127.0.0.1/32 trust', 'host all all ::1/128 trust', '# === RENGGLI-TEMP-TRUST-END ===')
        $orig = Get-Content -LiteralPath $hbaPath
        Set-Content -LiteralPath $hbaPath -Value ($trustLines + $orig) -Encoding ASCII
        $trustActive = $true
        & $pgCtl reload -D $inst.DataDir *> $null
        Start-Sleep -Seconds 2

        $env:PGPASSWORD = ''
        & $psql -h 127.0.0.1 -p $inst.Port -U $superuser -d postgres -tA -w -c 'SELECT 1;' *> $null
        $testOk = ($LASTEXITCODE -eq 0)
        if (-not $testOk) {
            Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force
            & $pgCtl reload -D $inst.DataDir *> $null
            return @{ supported = $false; reason = 'Ni siquiera con trust se pudo conectar. Revisa el servicio.' }
        }
        $mode = 'RECUPERACION'
    }

    $rolesRaw = & $psql -h 127.0.0.1 -p $inst.Port -U $superuser -d postgres -tA -w -c "SELECT rolname FROM pg_authid WHERE rolcanlogin = true ORDER BY 1;" 2>$null
    $roles = @($rolesRaw | Where-Object { $_ -and $_.Trim() } | ForEach-Object { $_.Trim() })
    if (-not $roles) {
        if ($trustActive) { Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force; & $pgCtl reload -D $inst.DataDir *> $null }
        return @{ supported = $false; reason = 'No se pudieron enumerar los roles.' }
    }

    Write-Host '  Roles con login:'
    for ($i = 0; $i -lt $roles.Count; $i++) { Write-Host "    $($i+1). $($roles[$i])" }
    $sel = Read-Host '  Numeros a cambiar separados por coma, o "todos" (Enter=cancelar)'
    $selectedRoles = @()
    if ($sel -match '^(?i:todos)$') { $selectedRoles = $roles }
    elseif ($sel) {
        foreach ($tok in ($sel -split ',')) {
            $n = 0
            if ([int]::TryParse($tok.Trim(), [ref]$n) -and $n -ge 1 -and $n -le $roles.Count) { $selectedRoles += $roles[$n - 1] }
        }
    }
    if (-not $selectedRoles) {
        if ($trustActive) { Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force; & $pgCtl reload -D $inst.DataDir *> $null }
        return @{ skipped = $true; reason = 'ningun rol seleccionado' }
    }

    $newSecure1 = Read-Host '  Nueva password' -AsSecureString
    $newSecure2 = Read-Host '  Confirma' -AsSecureString
    $b1 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($newSecure1)
    $new1 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b1)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b1)
    $b2 = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($newSecure2)
    $new2 = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b2)
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b2)

    if ($new1 -ne $new2 -or -not $new1) {
        if ($trustActive) { Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force; & $pgCtl reload -D $inst.DataDir *> $null }
        return @{ skipped = $true; reason = 'las passwords no coinciden o estan vacias' }
    }

    if (-not (Confirm-Action "Cambiar la password de $($selectedRoles.Count) rol(es): $($selectedRoles -join ', ')?" $true)) {
        if ($trustActive) { Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force; & $pgCtl reload -D $inst.DataDir *> $null }
        return @{ skipped = $true; reason = 'no confirmado (cambio de password)' }
    }

    $ok = @(); $fail = @()
    foreach ($r in $selectedRoles) {
        $escaped = $new1 -replace "'", "''"
        $sqlFile = [System.IO.Path]::GetTempFileName()
        "ALTER USER `"$r`" WITH PASSWORD '$escaped';" | Set-Content -LiteralPath $sqlFile -Encoding ASCII
        & $psql -h 127.0.0.1 -p $inst.Port -U $superuser -d postgres -tA -w -f $sqlFile *> $null
        if ($LASTEXITCODE -eq 0) { $ok += $r } else { $fail += $r }
        Remove-Item -LiteralPath $sqlFile -Force -ErrorAction SilentlyContinue
    }

    if ($trustActive) {
        Copy-Item -LiteralPath $hbaBackup -Destination $hbaPath -Force
        Remove-Item -LiteralPath $hbaBackup -Force -ErrorAction SilentlyContinue
        & $pgCtl reload -D $inst.DataDir *> $null
    }
    $env:PGPASSWORD = ''

    return @{ mode = $mode; succeeded = @($ok); failed = @($fail) }
}

# ============================================================================
#  MAIN
# ============================================================================

# --selftest: corre las verificaciones internas y sale (no requiere admin)
if ($SelfTest) {
    Write-Host ''
    Write-Host '  Renggli PC Solution - Self-test' -ForegroundColor Cyan
    Write-Host ''
    $ok = Test-Fase1SelfChecks
    Write-Host ''
    if ($ok) { Write-Host '  TODO OK' -ForegroundColor Green; exit 0 }
    else { Write-Host '  HAY FALLOS' -ForegroundColor Red; exit 1 }
}

# --list: enumerar y salir (no requiere admin ni perfil)
if ($List) {
    $items = Show-ModuleList -FilterPerfil $Perfil
    if ($Json) { $items | ConvertTo-Json -Depth 5 } else { $items | Format-Table -AutoSize }
    exit 0
}

if (-not (Test-Admin)) {
    Write-Log 'Requiere permisos de Administrador.' 'ERROR'
    if ($Json) { @{ status = 'error'; message = 'admin required' } | ConvertTo-Json }
    exit 2
}

# Modo no interactivo: se especifico -Module (o -Silent)
if ($Module -or $Silent) {
    if (-not $Module) { Write-Log '-Silent requiere -Module.' 'ERROR'; exit 2 }
    if (-not $Perfil) { $Perfil = 'Administracion' }  # sin perfil explicito en no-interactivo => acceso completo
    $r = Invoke-Module -Id $Module -ActivePerfil $Perfil
    if ($Json) { $r.result | ConvertTo-Json -Depth 8 }
    elseif (-not $Silent) { $r.result.data | Format-List }
    exit $r.exit
}

# ----------------------------------------------------------------------------
#  Modo interactivo (menu por categorias, con navegacion y ayuda)
# ----------------------------------------------------------------------------
Start-InteractiveMenu -InitialPerfil $Perfil
exit 0
