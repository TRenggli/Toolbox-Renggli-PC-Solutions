# Core PowerShell (`Windows/toolbox.ps1`)

Motor orientado a **servidores y entornos gestionados**, complementario al kit de campo `toolbox.bat`.

| | `toolbox.bat` (kit de campo) | `toolbox.ps1` (core) |
|---|---|---|
| Uso | Técnico con las manos en el teclado | Servidores, flotas, automatización |
| Modo | Interactivo (menús, prompts) | Interactivo **y desatendido** |
| Salida | Log + reporte HTML | Log + **JSON estructurado** + **códigos de salida** |
| Activación (MAS) | Incluida (opción 13) | **No incluida** (núcleo limpio, apto para entornos regulados) |
| Firmable | No (Authenticode no firma `.bat`) | **Sí** (ver `sign.ps1`) |

Esto resuelve los 4 puntos para empujar la herramienta hacia arriba: **desatendido/JSON (#1)**, **motor PowerShell (#2)**, **firmable (#3)** y **activación separada (#4)**.

## Requisitos

- Windows PowerShell 5.1 (viene con Windows) o PowerShell 7+.
- Ejecutar como Administrador (salvo `-List`).

## Uso

```powershell
# Listar módulos disponibles (no requiere admin)
.\toolbox.ps1 -List
.\toolbox.ps1 -List -Json

# Interactivo (menú por perfil)
.\toolbox.ps1

# Desatendido con salida JSON y código de salida (para orquestar)
.\toolbox.ps1 -Perfil Diagnostico -Module smart -Json
.\toolbox.ps1 -Perfil Diagnostico -Module disk -Silent -Json

# Módulos que escriben requieren -Force en modo silent
.\toolbox.ps1 -Perfil Reparacion -Module dism-sfc -Silent -Force
```

### Códigos de salida

| Código | Significado |
|---|---|
| 0 | OK |
| 1 | El módulo falló |
| 2 | Uso inválido / sin permisos de administrador |
| 3 | El módulo no está permitido en ese perfil |

### Módulos incluidos

Solo lectura (`R`): `smart`, `hardware`, `os`, `resources`, `disk`, `network`, `ports`, `events`, `wu-status`, `battery`.
Escriben (`W`, requieren `-Force` en silent): `dism-sfc`, `cleanup`.

> Estos son los módulos críticos portados a PowerShell. El resto del catálogo sigue disponible en `toolbox.bat`; se pueden ir migrando agregando entradas al registro `$Modules` (ver el patrón en el script).

## Ejecución remota sobre una flota

El diseño desatendido + JSON permite orquestar sin instalar nada:

```powershell
# Un servidor
Invoke-Command -ComputerName SRV01 -FilePath .\toolbox.ps1 `
  -ArgumentList '-Perfil','Diagnostico','-Module','disk','-Json'

# Varios, en paralelo, agregando resultados
$srv = 'SRV01','SRV02','SRV03'
Invoke-Command -ComputerName $srv -FilePath .\toolbox.ps1 `
  -ArgumentList '-Perfil','Diagnostico','-Module','smart','-Json' |
  ConvertFrom-Json | Where-Object { $_.data.disks.Status -ne 'OK' }
```

También encadenable por SSH, Ansible (`win_shell`), Intune/SCCM o tareas programadas.

## Firma (Authenticode)

```powershell
# 1) (solo pruebas) crear certificado autofirmado
.\sign.ps1 -CreateSelfSigned
# 2) firmar con la huella que imprime el paso anterior
.\sign.ps1 -Thumbprint <THUMBPRINT>
```

**Producción:** necesitás un certificado de code-signing de una CA confiable (DigiCert, Sectigo…) o de la PKI/AD interna de tu empresa. El autofirmado solo sirve en el equipo que lo crea. Firmar permite correr bajo `ExecutionPolicy AllSigned` y pasar AppLocker/WDAC.

> Nota: Authenticode firma `.ps1`, no `.bat`. Por eso el motor firmable es este core, no `toolbox.bat`.
