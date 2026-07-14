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

.EXAMPLE
    .\toolbox.ps1 -Perfil Diagnostico -Module smart -Json
    Corre SMART y devuelve JSON. Exit 0 si ok.

.EXAMPLE
    .\toolbox.ps1 -Perfil Reparacion -Module dism-sfc -Silent -Force
    Repara imagen y archivos de sistema desatendido (crea punto de restauracion antes).

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

    [string]$LogDir
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
    # un punto de restauracion (salvo -NoSafetyNet).
    param([string]$Prompt, [bool]$Writes)
    if ($Silent) {
        if ($Writes -and -not $Force) {
            Write-Log "Bloqueado en modo silent sin -Force: $Prompt" 'WARN'
            return $false
        }
        if ($Writes -and -not $NoSafetyNet) { New-SafetyNet -Reason $Prompt | Out-Null }
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
    if ($Writes -and -not $NoSafetyNet) { New-SafetyNet -Reason $Prompt | Out-Null }
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
    'maintenance' = 'Mantenimiento y reparacion'
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
        Run        = {
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
        Run        = {
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
        Run        = {
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
        Run        = {
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
        Run        = {
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
#  MAIN
# ============================================================================

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
