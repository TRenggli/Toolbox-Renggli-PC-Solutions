param(
    [string]$RootDir = "C:\Trabajos Alumnos",
    [string]$StudentUser = "Usuario",
    [switch]$CreateLog
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$secPath = Join-Path $RootDir "SECUNDARIA"
$priPath = Join-Path $RootDir "PRIMARIA"

$script:FailCount = 0
$script:WarnCount = 0
$script:Rows = New-Object System.Collections.Generic.List[object]

function Add-Result {
    param(
        [string]$Area,
        [string]$Check,
        [string]$Status,
        [string]$Detail
    )

    $script:Rows.Add([pscustomobject]@{
        Time   = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
        Area   = $Area
        Check  = $Check
        Status = $Status
        Detail = $Detail
    })

    switch ($Status) {
        "FAIL" { $script:FailCount++ }
        "WARN" { $script:WarnCount++ }
    }
}

function Test-PathExists {
    param(
        [string]$Path,
        [string]$Area
    )

    if (Test-Path -LiteralPath $Path) {
        Add-Result -Area $Area -Check "Path exists" -Status "OK" -Detail $Path
        return $true
    }

    Add-Result -Area $Area -Check "Path exists" -Status "FAIL" -Detail "Missing path: $Path"
    return $false
}

function Get-AclText {
    param([string]$Path)

    $tmp = New-TemporaryFile
    try {
        & icacls $Path | Out-File -FilePath $tmp.FullName -Encoding ascii
        return Get-Content -LiteralPath $tmp.FullName -Raw
    }
    finally {
        Remove-Item -LiteralPath $tmp.FullName -Force -ErrorAction SilentlyContinue
    }
}

function Test-AcademicAcl {
    param(
        [string]$Path,
        [string]$Area,
        [string]$UserName
    )

    try {
        $aclText = Get-AclText -Path $Path
    }
    catch {
        Add-Result -Area $Area -Check "Read ACL" -Status "FAIL" -Detail $_.Exception.Message
        return
    }

    $normalized = $aclText.ToUpperInvariant()
    $u = $UserName.ToUpperInvariant()

    if ($normalized -match [regex]::Escape($u + ":(DENY")) {
        Add-Result -Area $Area -Check "No DENY for student" -Status "FAIL" -Detail "Found explicit DENY for $UserName"
    }
    else {
        Add-Result -Area $Area -Check "No DENY for student" -Status "OK" -Detail "No explicit DENY detected for $UserName"
    }

    if ($normalized -match [regex]::Escape($u + ":(OI)(CI)(M)")) {
        Add-Result -Area $Area -Check "Student has Modify" -Status "OK" -Detail "Modify ACE found"
    }
    else {
        Add-Result -Area $Area -Check "Student has Modify" -Status "WARN" -Detail "Modify ACE not detected in plain text output"
    }
}

function Test-SaveFlow {
    param(
        [string]$Path,
        [string]$Area
    )

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $workDir = Join-Path $Path ("_BV1_TEST_" + $stamp)
    $tmpFile = Join-Path $workDir ("~$tmp_{0}.tmp" -f $stamp)
    $finalFile = Join-Path $workDir ("guardado_{0}.txt" -f $stamp)

    try {
        New-Item -Path $workDir -ItemType Directory -Force | Out-Null
        "tmp content" | Set-Content -LiteralPath $tmpFile -Encoding utf8

        # Simula flujo comun de apps: temporal -> archivo final
        Move-Item -LiteralPath $tmpFile -Destination $finalFile -Force

        "linea extra" | Add-Content -LiteralPath $finalFile -Encoding utf8

        Remove-Item -LiteralPath $finalFile -Force
        Remove-Item -LiteralPath $workDir -Force

        Add-Result -Area $Area -Check "Save/replace flow" -Status "OK" -Detail "Create, rename, append and delete succeeded"
    }
    catch {
        Add-Result -Area $Area -Check "Save/replace flow" -Status "FAIL" -Detail $_.Exception.Message

        if (Test-Path -LiteralPath $finalFile) {
            Remove-Item -LiteralPath $finalFile -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath $tmpFile) {
            Remove-Item -LiteralPath $tmpFile -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path -LiteralPath $workDir) {
            Remove-Item -LiteralPath $workDir -Force -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "=== Verificacion Blindaje V1 (guardado academico) ===" -ForegroundColor Cyan
Write-Host "RootDir: $RootDir"
Write-Host "StudentUser: $StudentUser"
Write-Host ""

$rootOk = Test-PathExists -Path $RootDir -Area "ROOT"
$secOk = Test-PathExists -Path $secPath -Area "SECUNDARIA"
$priOk = Test-PathExists -Path $priPath -Area "PRIMARIA"

if ($rootOk) {
    try {
        $rootAcl = Get-AclText -Path $RootDir
        $rootNorm = $rootAcl.ToUpperInvariant()
        $u = $StudentUser.ToUpperInvariant()
        if ($rootNorm -match [regex]::Escape($u + ":(DENY")) {
            Add-Result -Area "ROOT" -Check "Root keeps strict deny" -Status "OK" -Detail "Strict deny still present on root"
        }
        else {
            Add-Result -Area "ROOT" -Check "Root keeps strict deny" -Status "WARN" -Detail "No explicit DENY detected on root"
        }
    }
    catch {
        Add-Result -Area "ROOT" -Check "Read ACL" -Status "FAIL" -Detail $_.Exception.Message
    }
}

if ($secOk) {
    Test-AcademicAcl -Path $secPath -Area "SECUNDARIA" -UserName $StudentUser
    Test-SaveFlow -Path $secPath -Area "SECUNDARIA"
}

if ($priOk) {
    Test-AcademicAcl -Path $priPath -Area "PRIMARIA" -UserName $StudentUser
    Test-SaveFlow -Path $priPath -Area "PRIMARIA"
}

$rows = $script:Rows.ToArray()
$rows | Format-Table -AutoSize

if ($CreateLog) {
    $logDir = Join-Path $PSScriptRoot "..\Windows\Logs"
    if (-not (Test-Path -LiteralPath $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $logPath = Join-Path $logDir ("Verificacion_Blindaje_{0}.csv" -f (Get-Date -Format "yyyy-MM-dd_HHmmss"))
    $rows | Export-Csv -LiteralPath $logPath -NoTypeInformation -Encoding UTF8
    Write-Host ""
    Write-Host "Log CSV: $logPath" -ForegroundColor Yellow
}

Write-Host ""
Write-Host ("Resumen -> FAIL: {0} | WARN: {1}" -f $script:FailCount, $script:WarnCount)

if ($script:FailCount -gt 0) {
    exit 1
}

if ($script:WarnCount -gt 0) {
    exit 2
}

exit 0
