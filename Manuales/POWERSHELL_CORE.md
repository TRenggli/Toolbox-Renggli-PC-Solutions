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
Windows / Sistema · Seguridad y forense · Servidores · Bases de datos · Mantenimiento
y reparación · Reportes e inventario. Una categoría solo aparece en el menú si tiene
al menos un módulo permitido para el perfil activo.

**Antes de ejecutar un módulo `[W]`/`[!]`** se muestra una confirmación con el riesgo
y la reversibilidad. Si el módulo realmente cambia el estado del sistema, además
(salvo `-NoSafetyNet`) se intenta crear un punto de restauración antes de aplicar el
cambio; los módulos que solo exportan/leen algo ya existente (`driver-backup`,
`bitlocker-keys`) piden confirmación pero no generan un punto de restauración
innecesario, ya que no modifican nada:

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
| Hardware y sensores | `hardware`, `battery`, `driver-audit` |
| Almacenamiento y discos | `smart`, `smart-deep`, `disk` |
| Red y conectividad | `network`, `ports` |
| Windows / Sistema | `os`, `resources`, `events`, `event-intel`, `wu-status`, `svc-health` |
| Seguridad y forense | `autostart`, `bitlocker-status`, `bitlocker-keys` [!], `cert-scan` |
| Servidores | `ad-health`, `iis-health` |
| Bases de datos | `db-status`, `postgres-password` [W], `mssql-password` [W], `mysql-password` [W] |
| Mantenimiento y reparación | `dism-sfc` [W], `cleanup` [W], `driver-backup` [W], `wu-reset` [W], `wmi-repair` [W] |
| Reportes e inventario | `passport` |

Todos `[R]` (solo lectura) salvo los marcados `[W]`/`[!]`, que requieren `-Force` en modo
silent y disparan la confirmación con riesgo (y punto de restauración, salvo excepción
señalada arriba) en modo interactivo.

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

### Reparación (`wu-reset`, `wmi-repair`, `driver-audit`/`driver-backup`, BitLocker)

- **`wu-reset`** — el reset real de Windows Update: detiene `wuauserv`/`bits`/`cryptsvc`/
  `msiserver`, **renombra** (no borra) `SoftwareDistribution` y `catroot2` con sufijo
  `.bak_<fecha>`, y reinicia los servicios. Windows recrea las carpetas vacías solo;
  como las viejas quedan renombradas en el mismo lugar, es reversible restaurando el
  nombre con los servicios detenidos.

- **`wmi-repair`** — verifica el repositorio WMI (`winmgmt /verifyrepository`) y, solo
  si está **confirmado inconsistente**, ofrece repararlo (`/salvagerepository`, no
  destructivo). Distingue tres estados — consistente / inconsistente / indeterminado
  (ej. acceso denegado por falta de privilegios) — y **nunca ofrece reparar ante un
  estado indeterminado**; esto se corrigió durante la validación real, donde correr
  la verificación sin privilegios de administrador devolvía "Acceso denegado" y una
  versión anterior del código lo interpretaba erróneamente como inconsistencia.

- **`driver-audit`** [R] lista dispositivos con código de error (con el significado
  de cada código) y drivers sin firma digital. **`driver-backup`** [W] exporta los
  drivers de terceros a una carpeta vía `dism /export-driver` — no modifica el
  sistema, solo copia archivos, por lo que no dispara punto de restauración. Usa
  `-ExportPath` para la carpeta destino (si no se indica, se crea una dentro de `Logs`).

- **`bitlocker-status`** [R] muestra el estado de cifrado por volumen.
  **`bitlocker-keys`** [!] muestra las claves de recuperación — **solo perfil
  Administración**, nunca se escribe la clave en el log de auditoría (solo aparece
  en la salida que pediste explícitamente: pantalla, JSON o archivo).

### Servidores / empresa (`cert-scan`, `svc-health`, `ad-health`, `iis-health`, `db-status`, gestores de password)

- **`cert-scan`** — recorre los almacenes de certificados de la máquina y marca los
  vencidos o por vencer en 30 días. El "asesino silencioso": un sitio/servicio que se
  cae porque nadie vigilaba el vencimiento de un certificado.

- **`svc-health`** — servicios `Automatic` que no están corriendo, con dos señales
  combinadas sin ocultar datos: los "Automatic (Trigger Start)" **nativos de
  Windows** (`sppsvc`, `edgeupdate`) se excluyen del todo (hecho técnico inequívoco:
  el propio servicio declara que se arranca/detiene por evento disparador). Para el
  resto, se clasifica según si el servicio tiene configurada alguna acción de
  recuperación ante fallo (`FailureActions` en el registro, independiente de
  idioma): sin eso configurado (`RecoveryConfigured=false`), se marca
  `LikelyNormal=true` — típico de actualizadores de terceros (Brave/Google) que se
  autodetienen por diseño sin usar el mecanismo de trigger de Windows — y no cuenta
  en `downCountLikelyReal`, pero **sigue apareciendo en la lista completa** para no
  esconder un servicio realmente roto que por mala instalación tampoco tenga
  recuperación configurada. Validado en la práctica: en esta máquina, de 6 servicios
  "caídos" iniciales, el filtro deja 4 (elimina los 2 nativos) y clasifica los 4
  restantes como `LikelyNormal` (`downCountLikelyReal=0`).

- **`ad-health`** / **`iis-health`** — chequeos rápidos de Active Directory (canal
  seguro con el DC, Netlogon, SYSVOL) e IIS (sitios/application pools). Ambos se
  degradan con claridad cuando no aplican (equipo no unido a dominio, IIS no
  instalado) en vez de fallar.

- **`db-status`** — detección cross-engine (PostgreSQL, MySQL, SQL Server) vía
  servicio de Windows: motor, estado, puerto (Postgres) y versión. Solo lectura.

- **Gestores de password** — un módulo por motor, cada uno con su propio mecanismo
  de recuperación oficial (no son intercambiables, cada base de datos resuelve
  "olvidé la contraseña" de forma distinta):

  - **`postgres-password`** [W] — trust temporal en `pg_hba.conf` + reload (sin
    reiniciar el servicio). Portado del módulo ya probado en
    `toolbox.bat`/`modules\postgres_manager.bat`.
  - **`mssql-password`** [W] — modo de un solo usuario (`sqlservr.exe -m`), donde
    `BUILTIN\Administrators` obtiene sysadmin implícito. Detecta tanto "no conecta"
    como "conecta pero esa cuenta no es sysadmin" (un login explícito de Windows
    puede tapar el acceso heredado del grupo — encontrado validando este módulo
    contra una instancia real). También detecta servidores en modo "solo
    autenticación de Windows" (`SERVERPROPERTY('IsIntegratedSecurityOnly')`) y en
    ese caso ofrece otorgar sysadmin a una cuenta de Windows en vez de resetear un
    login SQL que jamás podría conectar.
  - **`mysql-password`** [W] — `--init-file` (mecanismo oficial de MySQL): detiene
    el servicio, arranca `mysqld` una vez con un archivo que fija la password de la
    cuenta indicada, reinicia el servicio. A diferencia de Postgres/SQL Server, este
    mecanismo no da una sesión interactiva — la password nueva se pide *antes* de
    entrar en modo recuperación, no después.

  Todos: solo modo interactivo (rechazan `-Silent`, para no pasar passwords en texto
  plano por parámetro/automatización), solo perfil Administración, `Read-Host
  -AsSecureString` para no mostrar las passwords en pantalla.

  > **Validado contra instancias reales, no solo revisión de código.** Al probar
  > `mssql-password` contra una instancia real, un intento de otorgar sysadmin
  > explícito a una cuenta ya-administradora terminó **tapando** su acceso heredado
  > del grupo `BUILTIN\Administrators` (un login explícito de Windows tiene
  > precedencia sobre la pertenencia a grupo) — se solucionó usando el propio modo
  > recuperación del módulo (single-user mode), confirmando que el mecanismo
  > funciona de verdad ante un bloqueo real. Al probar `mysql-password`, matar el
  > proceso standalone de recuperación con `Stop-Process -Force` y reiniciar el
  > servicio real casi inmediatamente después causó un fallo real (`ibdata1 must be
  > writable`, InnoDB con el archivo aún bloqueado) — se corrigió con
  > `Stop-RecoveryProcess`, que **espera activamente** (`Process.WaitForExit`) a que
  > el proceso termine de verdad en vez de un `sleep` fijo; el fix se aplicó también
  > retroactivamente a `mssql-password`, que tenía el mismo patrón de riesgo.

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
