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

.PARAMETER LogDir
    Carpeta de logs. Por defecto <script>\Logs.

.EXAMPLE
    .\toolbox.ps1 -Perfil Diagnostico -Module smart -Json
    Corre SMART y devuelve JSON. Exit 0 si ok.

.EXAMPLE
    .\toolbox.ps1 -Perfil Reparacion -Module dism-sfc -Silent -Force
    Repara imagen y archivos de sistema desatendido.

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

function Confirm-Action {
    # Devuelve $true si se debe continuar. En silent, exige -Force para acciones que escriben.
    param([string]$Prompt, [bool]$Writes)
    if ($Silent) {
        if ($Writes -and -not $Force) {
            Write-Log "Bloqueado en modo silent sin -Force: $Prompt" 'WARN'
            return $false
        }
        return $true
    }
    $ans = Read-Host "  $Prompt (S/N)"
    return ($ans -match '^(s|si|y|yes)$')
}

# ============================================================================
#  Definicion de modulos
#  Cada modulo: Name, Perfiles (donde se permite), Risk (R/W/!), Run (scriptblock ->
#  devuelve objeto; puede escribir en log). Los modulos [W]/[!] usan Confirm-Action.
# ============================================================================
$script:Modules = [ordered]@{

    'smart' = @{
        Name = 'Estado SMART de discos'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
            $disks = Get-CimInstance -ClassName Win32_DiskDrive -ErrorAction SilentlyContinue
            $pd = @{}
            try { Get-PhysicalDisk -ErrorAction Stop | ForEach-Object { $pd[$_.DeviceId] = $_.HealthStatus } } catch {}
            $rows = foreach ($d in $disks) {
                [pscustomobject]@{
                    Model      = $d.Model
                    Status     = $d.Status
                    Health     = if ($pd.ContainsKey("$($d.Index)")) { $pd["$($d.Index)"] } else { $d.Status }
                    SizeGB     = [math]::Round($d.Size / 1GB, 2)
                    Interface  = $d.InterfaceType
                }
            }
            return @{ disks = @($rows) }
        }
    }

    'hardware' = @{
        Name = 'Info de hardware (CPU/RAM/placa)'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Info del sistema operativo'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Recursos: CPU, RAM y top procesos'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Espacio y volumenes'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
            $vols = Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | ForEach-Object {
                [pscustomobject]@{
                    Drive     = $_.DeviceID
                    FS        = $_.FileSystem
                    SizeGB    = [math]::Round($_.Size / 1GB, 2)
                    FreeGB    = [math]::Round($_.FreeSpace / 1GB, 2)
                    FreePct   = if ($_.Size) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) } else { 0 }
                }
            }
            return @{ volumes = @($vols) }
        }
    }

    'network' = @{
        Name = 'Configuracion de red (IP/DNS)'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Puertos TCP en escucha'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Eventos criticos recientes (System)'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
            $ev = Get-WinEvent -FilterHashtable @{ LogName = 'System'; Level = 1, 2 } -MaxEvents 20 -ErrorAction SilentlyContinue |
                ForEach-Object { [pscustomobject]@{ Time = $_.TimeCreated; Id = $_.Id; Provider = $_.ProviderName; Message = ($_.Message -split "`n")[0] } }
            return @{ events = @($ev) }
        }
    }

    'wu-status' = @{
        Name = 'Estado de Windows Update'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Estado de bateria (portatiles)'; Perfiles = @('Diagnostico', 'Reparacion', 'Administracion'); Risk = 'R'
        Run  = {
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
        Name = 'Reparar imagen y archivos (DISM + SFC)'; Perfiles = @('Reparacion', 'Administracion'); Risk = 'W'
        Run  = {
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
        Name = 'Limpieza de temporales'; Perfiles = @('Reparacion', 'Administracion'); Risk = 'W'
        Run  = {
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
}

function Show-ModuleList {
    param([string]$FilterPerfil)
    $script:Modules.GetEnumerator() | ForEach-Object {
        $m = $_.Value
        if ($FilterPerfil -and ($m.Perfiles -notcontains $FilterPerfil)) { return }
        [pscustomobject]@{ Id = $_.Key; Nombre = $m.Name; Riesgo = $m.Risk; Perfiles = ($m.Perfiles -join '/') }
    }
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
#  Modo interactivo (menu)
# ----------------------------------------------------------------------------
if (-not $Perfil) {
    Write-Host ''
    Write-Host '  Renggli PC Solution - Core PowerShell' -ForegroundColor Cyan
    Write-Host '  Perfil de ejecucion:'
    Write-Host '   1. Diagnostico (solo lectura)'
    Write-Host '   2. Reparacion'
    Write-Host '   3. Administracion (acceso completo)'
    $sel = Read-Host '  Elegi [1-3]'
    $Perfil = switch ($sel) { '1' { 'Diagnostico' } '2' { 'Reparacion' } '3' { 'Administracion' } default { 'Diagnostico' } }
}
Write-Log "Perfil activo: $Perfil" 'INFO'

while ($true) {
    Write-Host ''
    Write-Host "  === Core PowerShell - Perfil $Perfil ===" -ForegroundColor Cyan
    $avail = @(Show-ModuleList -FilterPerfil $Perfil)
    for ($i = 0; $i -lt $avail.Count; $i++) {
        Write-Host ("   {0,2}. [{1}] {2}" -f ($i + 1), $avail[$i].Riesgo, $avail[$i].Nombre)
    }
    Write-Host '    0. Salir'
    $choice = Read-Host '  Opcion'
    if ($choice -eq '0' -or [string]::IsNullOrWhiteSpace($choice)) { break }
    $idx = 0
    if (-not [int]::TryParse($choice, [ref]$idx) -or $idx -lt 1 -or $idx -gt $avail.Count) {
        Write-Host '  Opcion invalida.' -ForegroundColor Yellow
        continue
    }
    $r = Invoke-Module -Id $avail[$idx - 1].Id -ActivePerfil $Perfil
    if ($r.result.data) { $r.result.data | Format-List }
    if ($r.result.message) { Write-Host "  $($r.result.message)" -ForegroundColor Yellow }
    Read-Host '  Enter para continuar' | Out-Null
}
Write-Log 'Fin de sesion.' 'INFO'
exit 0
