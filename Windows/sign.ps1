#Requires -Version 5.1
<#
.SYNOPSIS
    Firma Authenticode para el core PowerShell (toolbox.ps1 / sign.ps1).

.DESCRIPTION
    Firmar los scripts permite ejecutarlos en entornos con AppLocker/WDAC o con
    ExecutionPolicy AllSigned/RemoteSigned sin bloqueos, y prueba integridad.

    NOTA IMPORTANTE:
    - Authenticode firma .ps1 / .psm1 / .exe / .msi. NO firma .bat / .cmd
      (por eso el motor firmable es toolbox.ps1, no toolbox.bat).
    - Para PRODUCCION necesitas un certificado de code-signing de una CA confiable
      (DigiCert, Sectigo, etc.) o uno emitido por la PKI/AD interna de tu empresa.
      Un certificado autofirmado (-CreateSelfSigned) SOLO sirve para pruebas en este
      equipo: otros equipos no confiaran en el a menos que lo importes en su
      almacen "Publicadores de confianza" y "Entidades de certificacion raiz".

.PARAMETER CreateSelfSigned
    Crea un certificado de code-signing autofirmado en CurrentUser\My (solo pruebas).

.PARAMETER Thumbprint
    Huella del certificado de code-signing a usar (de Cert:\CurrentUser\My o LocalMachine\My).

.PARAMETER Files
    Archivos a firmar. Por defecto toolbox.ps1 y sign.ps1 junto a este script.

.PARAMETER TimestampUrl
    Servidor de timestamp (para que la firma siga siendo valida tras vencer el cert).

.EXAMPLE
    # 1) (solo pruebas) crear cert autofirmado
    .\sign.ps1 -CreateSelfSigned
    # 2) firmar con ese cert (usa la huella que imprime el paso 1)
    .\sign.ps1 -Thumbprint <THUMBPRINT>

.EXAMPLE
    # Produccion: firmar con un cert real ya instalado
    .\sign.ps1 -Thumbprint 1A2B3C...  -TimestampUrl http://timestamp.digicert.com
#>
[CmdletBinding(DefaultParameterSetName = 'Sign')]
param(
    [Parameter(ParameterSetName = 'Create')]
    [switch]$CreateSelfSigned,

    [Parameter(ParameterSetName = 'Sign')]
    [string]$Thumbprint,

    [string[]]$Files,

    [string]$TimestampUrl = 'http://timestamp.digicert.com'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $Files) { $Files = @((Join-Path $root 'toolbox.ps1'), (Join-Path $root 'sign.ps1')) }

if ($CreateSelfSigned) {
    Write-Host 'Creando certificado de code-signing AUTOFIRMADO (solo pruebas)...' -ForegroundColor Yellow
    $cert = New-SelfSignedCertificate `
        -Subject 'CN=Renggli PC Solution (Test Code Signing)' `
        -Type CodeSigningCert `
        -KeyUsage DigitalSignature `
        -KeyExportPolicy Exportable `
        -CertStoreLocation 'Cert:\CurrentUser\My' `
        -NotAfter (Get-Date).AddYears(3)
    Write-Host ''
    Write-Host "  [OK] Certificado creado." -ForegroundColor Green
    Write-Host "  Thumbprint: $($cert.Thumbprint)"
    Write-Host ''
    Write-Host '  Para firmar:  .\sign.ps1 -Thumbprint ' -NoNewline
    Write-Host $cert.Thumbprint
    Write-Host '  (Recorda: autofirmado NO es de confianza en otros equipos.)' -ForegroundColor Yellow
    return
}

if (-not $Thumbprint) {
    Write-Host 'Falta -Thumbprint. Certificados de code-signing disponibles:' -ForegroundColor Yellow
    $found = Get-ChildItem Cert:\CurrentUser\My, Cert:\LocalMachine\My -ErrorAction SilentlyContinue |
        Where-Object { $_.EnhancedKeyUsageList.FriendlyName -contains 'Code Signing' }
    if ($found) { $found | Format-Table Thumbprint, Subject, NotAfter -AutoSize }
    else { Write-Host '  (ninguno. Usa -CreateSelfSigned para pruebas o instala uno de una CA.)' }
    exit 1
}

$cert = Get-ChildItem Cert:\CurrentUser\My, Cert:\LocalMachine\My -ErrorAction SilentlyContinue |
    Where-Object { $_.Thumbprint -eq $Thumbprint } | Select-Object -First 1
if (-not $cert) { Write-Error "No se encontro un certificado con Thumbprint $Thumbprint"; exit 1 }

$fail = 0
foreach ($f in $Files) {
    if (-not (Test-Path -LiteralPath $f)) { Write-Warning "No existe: $f"; continue }
    try {
        $sig = Set-AuthenticodeSignature -FilePath $f -Certificate $cert -TimestampServer $TimestampUrl -HashAlgorithm SHA256
        if ($sig.Status -eq 'Valid') { Write-Host "  [OK] Firmado: $([IO.Path]::GetFileName($f))" -ForegroundColor Green }
        else { Write-Host "  [X] $([IO.Path]::GetFileName($f)) -> $($sig.Status): $($sig.StatusMessage)" -ForegroundColor Red; $fail++ }
    }
    catch { Write-Host "  [X] Error firmando $f : $($_.Exception.Message)" -ForegroundColor Red; $fail++ }
}
exit ([int]($fail -gt 0))
