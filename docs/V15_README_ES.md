# Toolbox V15 — Documentación (Español)

> Renggli PC Solution — Enterprise Toolbox V15
> Suite híbrida multiplataforma de diagnóstico, reparación y gestión clínico-dental.

[README (English)](./V15_README_EN.md) · [README (简体中文)](./V15_README_CN.md) · [README raíz](../README.md)

---

## 1. Visión general del rediseño V15

Toolbox V15 es una reescritura completa de la suite V14. Abandona el modelo basado
únicamente en scripts `.bat`/`.ps1`/`.sh` y se reorganiza en torno a un motor
multiplataforma escrito en **.NET 10**, con un catálogo de módulos declarado mediante
**manifests JSON** y una arquitectura orientada a servicios para entornos productivos.

Los pilares del rediseño son:

- **Núcleo compartido (`ToolboxCore`)** independiente del sistema operativo, con
  abstracciones de plataforma para Windows, Linux y macOS.
- **Motor causal**: un triage no se limita a ejecutar comprobaciones; correlaciona
  hallazgos (`Finding`) para producir un `HealthScore` y recomendaciones.
- **Manifests obligatorios**: ningún módulo se ejecuta sin un manifestfirmado que
  declare su riesgo, permisos, OS soportados, esquema de salida y rollback.
- **Servicios desplegables**: API operacional, servicio clínico aislado y panel web,
  orquestados con Docker Compose.
- **Agente remoto**: proceso ligero capaz de enrolarse, enviar latidos y ejecutar
  jobs encolados por el servidor.
- **Dominio dental (`artec`)**: un área nueva orientada al flujo CAD/CAM y a la
  gestión de producción de laboratorios dentales, con trazabilidad clínica.

V15 convive con los scripts V14 durante la migración mediante un *legacy bridge*.

---

## 2. Arquitectura

```
                        +--------------------------+
                        |        ToolboxCLI        |  (dotnet run, CLI interactiva)
                        +------------+-------------+
                                     |
                                     v
                        +--------------------------+
                        |        ToolboxCore       |  (motor, manifests, causal)
                        +---+----------+-----------+
                            |          |
       +--------------------+          +--------------------+
       | ToolboxAgent       |          | ToolboxServer     |
       | (enrolado, latido, |          |  + ToolboxApi     |
       |  polling de jobs)  |          |  + ToolboxClinical|
       +---------+----------+          +---+----------+---+
                 |                          |          |
                 |  mTLS / API Key           |          | red aislada
                 v                           v          v
        +----------------+         +----------------+   +----------------+
        |  db-operational|         |   panel (Vite) |   |  db-clinical   |
        |  (Postgres 16) |         +----------------+   | (Postgres 16)  |
        +----------------+                              +----------------+
                                                         |
                                                  +----------------+
                                                  | storage-clinical|
                                                  | (MinIO/S3)      |
                                                  +----------------+
```

| Componente             | Rol                                                                                                  | Tecnología                              |
|------------------------|------------------------------------------------------------------------------------------------------|-----------------------------------------|
| `ToolboxCLI`           | Interfaz de línea de comandos: triage, symptom, catalog, run, report, agent, artec.                  | .NET 10, `System.CommandLine`          |
| `ToolboxCore`          | Motor causal, registro de módulos, runner, calculadora de salud, abstracción de OS, export de reportes. | .NET 10 (librería compartida)          |
| `ToolboxAgent`         | Agente desplegable en endpoints. Enrolamiento, latido, poll de jobs, ejecución remota.               | .NET 10, `HttpClient`                   |
| `ToolboxServer.Api`    | API operacional: agentes, módulos, jobs, triage, audit, backup. Autenticación JWT + ApiKey.          | ASP.NET Core 10, PostgreSQL            |
| `ToolboxServer.Clinical` | Servicio clínico aislado: registros, producción, adjuntos, retención, auditoría con MFA.         | ASP.NET Core 10, PostgreSQL, MinIO     |
| `ToolboxPanel`         | Panel web administrativo.                                                                            | Vite + React                            |
| `docker-compose.yml`   | Orquestación: proxy Caddy, api, db-operacional, servicio clínico, db-clínica, storage, panel.        | Docker Compose                          |

Redes separadas:

- `operational-net`: api, db-operacional, panel, proxy.
- `clinical-net`: servicio clínico, db-clínica, storage clínico.

El servicio clínico **no** comparte red con la API operacional; el proxy Caddy es el
único punto que publica rutas hacia `/clinical/*`.

---

## 3. Instalación

### Requisitos

- **.NET 10 SDK** (obligatorio para compilar / `dotnet run`).
- Para despliegues de servidor: **Docker** con soporte de **Compose v2**.
- Para el agente: los binarios publicados son self-contained para Win x64, Linux x64 y macOS.
- PostgreSQL 16 (provisto por el stack Compose).
- Privilegios de administrador/root para módulos marcados como `admin`/`root`.

### Compilación desde origen

```bash
git clone <repo>
cd Toolbox-Renggli-PC-Solutions
dotnet build src/ToolboxV15/ToolboxV15.slnx -c Release
```

### Ejecución con `dotnet run`

```bash
dotnet run --project src/ToolboxV15/ToolboxCLI -- triage --area system --guided
```

Los manifests se cargan por defecto desde `./modules/manifests` relativo al directorio
de trabajo actual. Puedes ejecutar el CLI desde la raíz del repositorio para que
encuentre el catálogo completo.

### Publicación de binarios

```bash
dotnet publish src/ToolboxV15/ToolboxCLI -c Release -r win-x64 --self-contained -o publish/cli
dotnet publish src/ToolboxV15/ToolboxAgent -c Release -r linux-x64 --self-contained -o publish/agent
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxApi -c Release -o publish/api
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxClinical -c Release -o publish/clinical
```

El binario publicado (`toolbox`/`toolbox.exe` para el CLI, `toolbox-agent` para el
agente) puede distribuirse sin el SDK instalado.

### Pruebas

```bash
dotnet test src/ToolboxV15/ToolboxV15.slnx
```

El proyecto `tests/ToolboxTests` cubre el motor causal, registro de módulos,
cargador de manifests, registry de síntomas, calculadora de salud y resultados
de ejecución.

---

## 4. Referencia de comandos del CLI

Uso general:

```
toolbox <command> [options]
```

### `triage`

Ejecuta un triage completo sobre un área, cargando los módulos `baseline` y
`diagnostic` compatibles con el OS actual y produciendo hallazgos, `HealthScore`,
recomendaciones y un `RunId`.

```
toolbox triage --area <system|network|server|artec> [--json] [--guided]
```

- `--area` (por defecto `system`).
- `--json` envía el `TriageResult` serializado a stdout (consume el archivo
  `schemas/triage-result.schema.json`).
- `--guided` añade ayuda contextual para continuar manualmente.

El último `TriageResult` queda cacheado en el proceso para su uso inmediato por
`report export`.

### `symptom`

Consulta el registro de síntomas y devuelve posibles causas y módulos recomendados.

```
toolbox symptom <id> [--json]
```

### `catalog`

Lista y filtra el catálogo cargado desde `modules/manifests/`.

```
toolbox catalog [--area <area>] [--os <windows|linux|macos>] [--risk <R|WR|WL|Critical>] [--json]
```

### `run`

Ejecuta un módulo puntual por nombre.

```
toolbox run <module-id> [--json] [--force] [--params k=v;k2=v2]
```

- `--force` omite la verificación de elevación de privilegios (útil en pipelines).
- `--params` permite pasar parámetros en línea al executor del módulo.

### `report`

Exporta el último triage cacheado (o un placeholder si no existe).

```
toolbox report export --format <html|json|csv> --path <archivo>
```

### `agent`

Subcomandos del agente:

```
toolbox agent install
toolbox agent enroll --token <t> --server <url>
toolbox agent status
```

El agente *standalone* (`toolbox-agent`) añade además `run` para arrancar el loop
de polling y `install` para mostrar las instrucciones de registro como servicio
(Windows `sc.exe` o systemd en Linux).

### `artec`

Subcomandos del dominio dental:

```
toolbox artec workflow
toolbox artec production [--action <status|queue|advance|block|cancel|rework>]
toolbox artec incident
```

- `workflow` guía el flujo de trabajo CAD/CAM.
- `production` actúa sobre el estado de un job de producción.
- `incident` registra y triangular una incidencia de equipo.

---

## 5. Manifests de módulos

Cada módulo está descrito por un JSON validado contra
`schemas/module-manifest.schema.json`. Campos clave:

| Campo              | Descripción                                                              |
|--------------------|--------------------------------------------------------------------------|
| `id`               | UUID único del módulo.                                                   |
| `name`             | Identificador estable usado por `run`, `catalog` y el agente.            |
| `area`             | `system` · `network` · `server` · `artec`.                              |
| `os`               | Lista de OS soportados: `windows`, `linux`, `macos`.                     |
| `category`         | `diagnostic` · `repair` · `admin` · `production` · `baseline`.          |
| `risk`             | Nivel de riesgo (ver abajo).                                             |
| `reversible`       | `true` si la acción puede deshacerse.                                    |
| `timeout_ms`       | Timeout máximo de ejecución.                                             |
| `permissions`      | `admin`, `root`, etc.                                                    |
| `remote_support`   | `none` · `readonly` · `full`.                                           |
| `rollback_module`  | Nombre del módulo de reversión opcional.                                 |
| `associated_repair`| Módulo de reparación sugerido tras un hallazgo.                          |
| `version`          | SemVer del módulo.                                                       |

### Niveles de riesgo (`risk`)

| Código | Significado                                            | Ejemplo típico                         |
|--------|--------------------------------------------------------|----------------------------------------|
| `R`    | Solo lectura. No modifica el sistema.                 | `hardware-smart`, `network-dns`.        |
| `W-R`  | Escritura reversible. Cambios que pueden deshacerse.   | `repair-temp-cleanup`, `repair-wu-reset`. |
| `W-L`  | Escritura con impacto limitado/latente.                | `system-services`, `system-autostart`.  |
| `!`    | Crítico. Operación irreversible o de alto impacto.     | `admin-format`, `admin-mbr-gpt`, `artec-scanner-calibration`. |

### Estados de ejecución

`ExecutionResult.Status` puede ser:

- `Success` — ejecutado sin errores.
- `Partial` — completado con hallazgos parciales.
- `Cancelled` — cancelado por token o usuario.
- `Skipped` — omitido por filtrado del catálogo.
- `Blocked` — falta de elevación o permisos.
- `Failed` — error o excepción durante la ejecución.
- `Unsupported` — no existe executor registrado para el módulo/OS.

El `ModuleRunner` aplica un timeout de 30 segundos por defecto y marca `TIMEOUT`
como `ErrorDetail.Code` cuando se cancela.

---

## 6. Modo guiado vs modo técnico

El CLI admite dos estilos de salida:

- **Modo guiado** (por defecto): texto coloreado pensado para un operador humano,
  con resumen, hallazgos numerados y sugerencias de siguiente paso. Es el que usan
  `triage`, `symptom`, `catalog`, `run` y `report` sin flags.
- **Modo técnico**: con `--json` se serializa el objetoresultante (`TriageResult`,
  `ExecutionResult`, `SymptomResult`, etc.) a stdout, ideal para automatización,
  CI/CD y consumo desde el panel o el agente.

El comando `triage --guided` combina ambos: produce la salida guiada pero añade
pistas de comandos para inspección manual posterior.

---

## 7. Despliegue con Docker

El archivo `docker-compose.yml` levanta el stack productivo completo:

```bash
docker compose up -d --build
```

Servicios incluidos:

| Servicio            | Imagen/Dockerfile            | Puerto expuesto | Red                |
|---------------------|------------------------------|------------------|--------------------|
| `proxy` (Caddy)     | `caddy:2-alpine`             | 80, 443          | operational, clinical |
| `api`               | `docker/Dockerfile.api`      | 8080 (interno)   | operational        |
| `db-operational`    | `postgres:16-alpine`         | —                | operational        |
| `service-clinical`  | `docker/Dockerfile.clinical`  | 8081 (interno)   | clinical           |
| `db-clinical`       | `postgres:16-alpine`         | —                | clinical           |
| `storage-clinical`  | `minio/minio`                | 9001 (consola)   | clinical           |
| `panel`             | `docker/Dockerfile.panel`     | 80 (interno)     | operational        |

Caddy publica tres rutas:

- `/api/*` → `api:8080`
- `/clinical/*` → `service-clinical:8081`
- `/panel/*` → `panel:80`

Todo lo no enrutado responde 404 y el puerto 80 redirige a HTTPS con TLS interno.

### Configuración sensible

Las credenciales por defecto (`tbx_operational_pw`, `tbx_clinical_pw`, claves JWT,
ApiKey, MfaToken) son **valores de desarrollo** y deben reemplazarse mediante
variables de entorno o secretos antes de un despliegue real.

---

## 8. Artec Invent / CAD-CAM Dental

El área `artec` cubre el flujo de trabajo de **Artec / CAD-CAM dental** con foco en
escáneres y fresadoras UP3D y la línea de producción del laboratorio.

### Módulos disponibles

| Módulo                        | Descripción                                                                 | Riesgo |
|-------------------------------|-----------------------------------------------------------------------------|--------|
| `artec-scanner-detect`         | Detección de escáner UP3D: presencia, conexión y drivers.                  | `R`    |
| `artec-scanner-calibration`    | Verificación de calibración, fecha y precisión.                            | `!`    |
| `artec-mill-detect`            | Detección de fresadora P52/P53: presencia, conexión y firmware.            | `R`    |
| `artec-mill-network`            | Conectividad de red de la fresadora: ping, latencia, puerto y enlace.      | `R`    |
| `artec-air-extraction`         | Sistema de aire y extracción: presión, filtros, bomba, alertas.            | `R`    |
| `artec-software-versions`       | Auditoría de software CAD/CAM: versiones, licencias y actualizaciones.     | `R`    |
| `artec-workflow-guide`          | Guía interactiva del flujo de trabajo dental.                              | `R`    |

### Flujo de trabajo CAD/CAM

1. **Recepción** del caso/pieza dental.
2. **Escaneado** con escáneres UP3D (verificación previa con `artec-scanner-detect`
   y `artec-scanner-calibration`).
3. **Diseño CAD** en la estación de diseño.
4. **CAM** y generación de trayectorias.
5. **Cola** de producción y asignación de fresadora.
6. **Fresado** en fresadoras P52/P53 (con `artec-mill-detect` y `artec-mill-network`).
7. **Control de calidad (QC)** y validación de la pieza producida.
8. **Completado** y entrega.

Los pasos de escaneado y fresado requieren verificación de equipo; los módulos de
`artec` exponen las comprobaciones automáticas, mientras que el comando `toolbox
artec workflow` ofrece la guía paso a paso.

---

## 9. Gestión de producción

El servicio clínico modela los jobs de producción con estados y roles definidos en
`ToolboxCore.Artec` y replicados en `ToolboxClinical`.

### Estados (`ProductionState`)

`Received` → `Scanning` → `Cad` → `Cam` → `Queued` → `Milling` → `QC` →
`Completed`

Ramas laterales: `Blocked`, `Cancelled`, `Rework`.

| Estado       | Significado                                                       |
|--------------|-------------------------------------------------------------------|
| `Received`   | Caso ingresado al laboratorio.                                    |
| `Scanning`   | Escaneo en progreso con escáner UP3D.                            |
| `Cad`        | Diseño CAD en curso.                                               |
| `Cam`        | Generación de trayectorias CAM.                                   |
| `Queued`     | Esperando asignación de fresadora.                                 |
| `Milling`    | Fresado en P52/P53.                                                |
| `QC`         | Control de calidad.                                                |
| `Completed`  | Pieza terminada y validada.                                        |
| `Blocked`    | Detenido por dependencia o requerimiento pendiente.               |
| `Cancelled`  | Anulado.                                                           |
| `Rework`     | Revisión/retrabajo sobre una pieza rechazada en QC.               |

### Roles (`ProductionRole`)

`Reception`, `Scanning`, `CadDesign`, `Cam`, `MachineOperator`, `Quality`,
`Administrator`.

Las transiciones de estado se realizan a través del endpoint
`PUT /clinical/production/{id}/state` y cada acción queda registrada en el
audit trail con `actor`, `target` y `details`.

---

## 10. Registros clínicos

El servicio `ToolboxClinical` gestiona registros clínicos y adjuntos con
trazabilidad exigida por la normativa argentina.

### Acceso

- **Autenticación JWT** validada (issuer, audience, signing key, lifetime).
- **MFA obligatorio**: el header `X-MFA-Token` se verifica en cada operación que
  toca datos clínicos; sin él se responde `401 Unauthorized`.
- **Motivo obligatorio**: las lecturas (`record.read`, `patient.history`) exigen el
  header `X-Access-Reason`.

### Tiempo limitado

- `RecordService.Create` fija `AccessExpiresAt = ahora + 15 min` por defecto.
- `ClinicalAccessManager` permite sesiones de **30 minutos** (`DefaultAccessDuration`)
  para acceso solicitado explícitamente con `requesterId`, `patientId`, `reason`
  y `mfaToken`.
- Las solicitudes pueden **sellarse** (`Seal`) para impedir accesos futuros.

### Auditoría y retención

- `ClinicalAuditService` almacena entradas `Action`, `Actor`, `Target`, `Details`.
- Trazabilidad consultable vía `GET /clinical/records/{id}/audit`.
- Los adjuntos (uploads a `storage-clinical`) **se eliminan 90 días después del
  cierre del incidente** (`RetentionService`), con `deleteAfter` registrado en cada
  adjunto.

### Cumplimiento legal

El `ComplianceNote` del `ClinicalAccessManager` declara explícitamente:

> El acceso a registros clínicos respeta la **Ley 25.326** (Protección de Datos
> Personales) y la **Ley 26.529** (Derechos del Paciente). El acceso es limitado
> en el tiempo, protegido con MFA, condicionado a un motivo y auditado. Los
> adjuntos de soporte se eliminan 90 días después del cierre del incidente.

---

## 11. Seguridad

### Módulos firmados

Los manifests pueden transportarse firmados; el cargador valida el formato y, en
despliegues locked-down, puede exigir una firma conocida antes de registrar el
módulo. Los módulos `!` (críticos) requieren confirmación explícita o `--force`.

### mTLS y ApiKey

- El **agente** se enrola con un token y recibe un certificado de cliente
  (`agent-{id}.cert`) que se persiste en el `AgentConfig`.
- La **API operacional** admite un esquema *Hybrid* (JWT o ApiKey por header
  `X-API-Key`), seleccionado en runtime por `ForwardDefaultSelector`.
- El **servicio clínico** se mantiene en una red aislada (`clinical-net`) y solo
  es alcanzable vía el proxy Caddy con TLS interno.

### Cadena de auditoría

Cada acción relevante (enrollment, upload de módulo, creación de job, triage,
backup, transition de producción, acceso a registro o adjunto) genera una entrada
en `AuditService` / `ClinicalAuditService` con actor, objetivo, detalles y
timestamp. El endpoint `GET /api/audit?limit=N` permite reconstruir la cadena.

### Base clínica aislada

La base clínica (`db-clinical` con base `clinical`) es **independiente** de la base
operacional (`toolbox`), reside en otra red y no comparte credenciales. Los adjuntos
se almacenan en **MinIO** (`storage-clinical`), accesible únicamente desde
`clinical-net`.

---

## 12. Migración desde V14

V15 mantiene un **legacy bridge** para convivir con los scripts V14 durante la
transición:

- Los scripts legacy (`Windows/toolbox.bat`, `Windows/toolbox.ps1`, `Linux/toolbox.sh`,
  `Mac/toolbox.sh`) siguen disponibles bajo sus respectivas carpetas y son los
  recomendados mientras el catálogo de ejecutores V15 se completa.
- El CLI V15 puede ejecutarse en paralelo: sus módulos son declarativos y no
  sobrescriben los artefactos V14.
- La migración recomendada es incremental: primero adoptar `triage` y `catalog`
  para auditoría, después `run` para módulos ya portados a `ToolboxCore`, y por
  último el agente y el servidor cuando la flota esté lista.
- Los manifests V15 reemplazan al “catálogo de opciones” en texto plano de V14;
  el catálogo V14 sigue siendo referencia semántica durante la migración.

---

## 13. Estado — pendientes y fase piloto

V15 está en **fase piloto** y algunos elementos aún no son productivos:

- **Perfiles de hyperDENT**: los perfiles de fresado para hyperDENT **no están
  validados todavía**. Hasta completar la validación deben usarse los perfiles
  heredados y el módulo CAM del fabricante.
- **Placa de fresado en húmedo** (wet mill board): la detección y monitoreo del
  módulo de fresado en húmedo está **pendiente de confirmación**; los módulos
  `artec-mill-*` actuales cubren el fresado en seco.
- **Executors del catálogo**: varios módulos del catálogo V15 exponen la interfaz
  pero su executor concreto es un *stub*; el estado reportado es `Unsupported`
  hasta su implementación completa.
- **Piloto clínico**: el servicio clínico y la retención de adjuntos deben
  validarse contra el equipo legal antes de cargarse datos reales de pacientes.
- **Servicio del agente**: la instalación como servicio (`sc.exe` / systemd) está
  documentada pero el enrolamiento productivo debe hacerse contra un servidor con
  TLS y ApiKey/JWT reales.

Cualquier uso clínico en esta fase es responsabilidad de la organización piloto.

---

## 14. Soporte y licencia

- Soporte: **tomasrenggli@gmail.com**
- Documentación completa: carpeta `docs/` y manuales históricos en `Manuales/`.
- Licencia: © 2024-2026 Renggli PC Solution. Enterprise Toolbox V15. All rights reserved.