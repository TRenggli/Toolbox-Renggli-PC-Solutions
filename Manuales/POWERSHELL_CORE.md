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

# Pasaporte del sistema (inventario + health score), exportado a HTML/JSON/CSV
.\toolbox.ps1 -Perfil Diagnostico -Module passport -Silent -ExportPath C:\Reportes\srv01.html
.\toolbox.ps1 -Perfil Diagnostico -Module passport -Silent -ExportPath C:\Reportes\srv01.json -ExportFormat json

# Verificaciones internas (health score, aplanado CSV) sin tocar el sistema
.\toolbox.ps1 -SelfTest
```

## Navegación interactiva

El menú interactivo (sin `-Module`/`-Silent`) está organizado por **categorías**, con
breadcrumb, ayuda por opción y control total de ida y vuelta — pensado para saber
siempre dónde estás y qué hace cada cosa antes de tocarla:

```
  Renggli PC Solution - Core PowerShell
  Equipo: SRV01   Usuario: admin   Perfil: ADMINISTRACION
  Ruta: Inicio > Almacenamiento y discos
  ------------------------------------------------------------------------
    1. [R] Estado SMART de discos
    2. [R] Espacio y volumenes

   [V] volver   [M] menu principal   [?N] ayuda   [99] cambiar perfil   [0] salir
```

Controles disponibles en cualquier pantalla:

| Tecla | Acción |
|---|---|
| `[número]` | Entra a la categoría / ejecuta el módulo |
| `V` | Volver un nivel (de categoría a menú principal) |
| `M` | Ir directo al menú principal desde cualquier categoría |
| `?N` | Ver la ayuda del módulo N: qué hace, cuándo usarlo, riesgo, si es reversible |
| `99` | Cambiar de perfil sin reiniciar (recalcula qué categorías/módulos se ven) |
| `0` | Salir |

**Categorías:** Hardware y sensores · Almacenamiento y discos · Red y conectividad ·
Windows / Sistema · Seguridad y forense · Mantenimiento y reparación · Reportes e
inventario. Una categoría solo aparece en el menú si tiene al menos un módulo
permitido para el perfil activo.

**Antes de ejecutar un módulo `[W]`/`[!]`** se muestra una confirmación con el riesgo
y la reversibilidad, y (salvo `-NoSafetyNet`) se intenta crear un punto de restauración
del sistema antes de aplicar el cambio:

```
  +-- CONFIRMACION ------------------------------------------------------
  | Accion     : Borrar temporales de %TEMP% y C:\Windows\Temp?
  | Riesgo     : [W] Escribe/cambia el sistema
  | Reversible : No
  +------------------------------------------------------------------------
```

### Códigos de salida

| Código | Significado |
|---|---|
| 0 | OK |
| 1 | El módulo falló |
| 2 | Uso inválido / sin permisos de administrador |
| 3 | El módulo no está permitido en ese perfil |

### Módulos incluidos

| Categoría | Módulos (`id`) |
|---|---|
| Hardware y sensores | `hardware`, `battery` |
| Almacenamiento y discos | `smart`, `smart-deep`, `disk` |
| Red y conectividad | `network`, `ports` |
| Windows / Sistema | `os`, `resources`, `events`, `event-intel`, `wu-status` |
| Seguridad y forense | `autostart` |
| Mantenimiento y reparación | `dism-sfc` [W], `cleanup` [W] |
| Reportes e inventario | `passport` |

Todos `[R]` (solo lectura) salvo `dism-sfc` y `cleanup`, que requieren `-Force` en modo silent
y disparan la confirmación con riesgo + punto de restauración en modo interactivo.

> Estos son los módulos críticos portados a PowerShell. El resto del catálogo sigue disponible en `toolbox.bat`; se pueden ir migrando agregando entradas al registro `$Modules` (ver el patrón en el script — cada módulo define `Category`, `Risk`, `Reversible` y `Help` para que la navegación y la ayuda salgan solas).

### Pasaporte del sistema (`passport`)

Un solo módulo junta en un reporte: hardware, discos (con salud), volúmenes, sistema
operativo, últimos hotfixes, **reinicio pendiente** (chequea 5 indicadores conocidos:
Component Based Servicing, Windows Update, PendingFileRenameOperations, rename de
computadora pendiente, y cliente SCCM si existe), red y software instalado (leído del
registro, nunca `Win32_Product` — evita el side-effect de reconfiguración de MSI que
esa clase WMI dispara en cada consulta).

**Health score (0-100):** arranca en 100 y se descuenta por regla fija —
disco con salud degradada (-25 c/u), volumen con <10% libre (-15) o <5% libre (-25),
reinicio pendiente (-10), más de 30 días sin reiniciar (-5). Rating: Excelente (≥90),
Bueno (≥75), Regular (≥50), Crítico (<50). Las reglas están cubiertas por `-SelfTest`.

**Exportación:** `-ExportPath archivo.ext` (formato por `-ExportFormat html|json|csv`,
default `html`). En modo interactivo, si no se pasó `-ExportPath`, se pregunta si
exportar. El HTML reutiliza la estética oscura de la suite, con secciones plegables
nativas (`<details>`, sin JavaScript) y badges de severidad; todo el contenido variable
(nombres de software, etc.) pasa por un escape HTML explícito. El CSV es un volcado
genérico `Campo,Valor` (aplanado recursivo), útil para abrir en Excel o grepear.

### Diagnóstico profundo (`autostart`, `smart-deep`, `event-intel`)

Tres módulos que buscan lo que revisa un técnico senior en vez de lo genérico:

- **`autostart`** — auditor de persistencia: registro Run/RunOnce (HKLM/HKCU/32-bit),
  carpetas de Inicio, tareas programadas con disparador de logon/boot, servicios
  automáticos (verifica firma Authenticode del ejecutable y marca los no firmados),
  **suscripciones de eventos WMI** (`root\subscription` — mecanismo de persistencia
  "fileless" que casi ninguna herramienta revisa) e **IFEO Debugger** (hijacking de
  ejecutables vía Image File Execution Options, la técnica clásica del backdoor de
  "sticky keys"). Devuelve una lista `suspicious` con lo que amerita revisión manual.
  Validado en una máquina real: encontró 161 puntos de autostart, verificó la firma
  de 100 servicios y señaló correctamente 3 sin firma válida y 2 suscripciones WMI.

- **`smart-deep`** — atributos de fiabilidad reales (`Get-StorageReliabilityCounter`):
  horas de encendido, temperatura, errores de lectura/escritura corregidos y NO
  corregidos, desgaste (SSD). A diferencia del `[R]` genérico de `smart`, esto predice
  una falla antes de que el disco reporte "no OK". Se degrada con gracia (`disks`
  vacío con `supported=$false`) si el equipo no expone el módulo Storage, o con
  campos en `null` si un disco puntual no reporta contadores (común en NVMe/USB de
  consumo en Windows cliente).

- **`event-intel`** — en vez de "eventos críticos" genéricos, busca patrones
  específicos: apagados inesperados (Kernel-Power 41 + EventLog 6008), fallas reales
  de disco (IDs 7/11/51/153 filtrados al proveedor clásico `disk`, para no confundir
  con otros componentes que reusan esos mismos números — validado en la práctica:
  sin el filtro de proveedor aparecían 36 falsos positivos de Kernel-General/TxR),
  bugchecks (BugCheck 1001) y servicios que fallaron al iniciar (Service Control
  Manager). Ventana de 14 días.

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
