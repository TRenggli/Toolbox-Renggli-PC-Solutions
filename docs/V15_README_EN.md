# Toolbox V15 — Documentation (English)

> Renggli PC Solution — Enterprise Toolbox V15
> Hybrid cross-platform diagnostics, repair and dental clinical management suite.

[README (Español)](./V15_README_ES.md) · [README (简体中文)](./V15_README_CN.md) · [Root README](../README.md)

---

## 1. Overview of the V15 Redesign

Toolbox V15 is a full rewrite of the V14 suite. It drops the script-only model
(`.bat`/`.ps1`/`.sh`) and reorganizes the platform around a **.NET 10** core engine,
a declarative **JSON manifest** module catalog, and a service-oriented deployment
for production environments.

Design pillars:

- **Shared core (`ToolboxCore`)** independent of the operating system, with platform
  abstractions for Windows, Linux and macOS.
- **Causal engine**: a triage does more than run checks — it correlates findings to
  produce a `HealthScore` and recommendations.
- **Mandatory manifests**: no module runs without a signed manifest declaring its
  risk, permissions, supported OS, output schema and rollback strategy.
- **Deployable services**: operational API, isolated clinical service and a web
  panel, orchestrated with Docker Compose.
- **Remote agent**: a lightweight process able to enroll, send heartbeats and execute
  jobs queued by the server.
- **Dental domain (`artec`)**: a new area targeting CAD/CAM workflows and dental
  lab production management, with clinical traceability.

V15 coexists with the V14 scripts during migration through a *legacy bridge*.

---

## 2. Architecture

```
                        +--------------------------+
                        |        ToolboxCLI        |  (dotnet run, interactive CLI)
                        +------------+-------------+
                                     |
                                     v
                        +--------------------------+
                        |        ToolboxCore       |  (engine, manifests, causal)
                        +---+----------+-----------+
                            |          |
       +--------------------+          +--------------------+
       | ToolboxAgent       |          | ToolboxServer     |
       | (enrolled, heartbeat,|         |  + ToolboxApi     |
       |  job polling)       |          |  + ToolboxClinical|
       +---------+----------+          +---+----------+---+
                 |                          |          |
                 |  mTLS / API Key           |          | isolated network
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

| Component              | Role                                                                                          | Stack                                   |
|------------------------|-----------------------------------------------------------------------------------------------|-----------------------------------------|
| `ToolboxCLI`           | Command-line interface: triage, symptom, catalog, run, report, agent, artec.                 | .NET 10, `System.CommandLine`           |
| `ToolboxCore`          | Causal engine, module registry, runner, health calculator, OS abstraction, report export.   | .NET 10 (shared library)                |
| `ToolboxAgent`         | Deployable agent on endpoints. Enrollment, heartbeat, job polling, remote execution.         | .NET 10, `HttpClient`                   |
| `ToolboxServer.Api`    | Operational API: agents, modules, jobs, triage, audit, backup. JWT + ApiKey authentication.   | ASP.NET Core 10, PostgreSQL             |
| `ToolboxServer.Clinical` | Isolated clinical service: records, production, attachments, retention, MFA audit.       | ASP.NET Core 10, PostgreSQL, MinIO      |
| `ToolboxPanel`         | Administrative web panel.                                                                     | Vite + React                            |
| `docker-compose.yml`   | Orchestration: Caddy proxy, api, db-operational, clinical service, clinical db, storage, panel. | Docker Compose                          |

Separated networks:

- `operational-net`: api, db-operational, panel, proxy.
- `clinical-net`: clinical service, clinical db, clinical storage.

The clinical service does **not** share a network with the operational API; Caddy
is the only component that publishes routes to `/clinical/*`.

---

## 3. Installation

### Requirements

- **.NET 10 SDK** (required to build / `dotnet run`).
- For server deployments: **Docker** with **Compose v2** support.
- For the agent: published self-contained binaries for Win x64, Linux x64, macOS.
- PostgreSQL 16 (provided by the Compose stack).
- Administrator/root privileges for modules marked `admin`/`root`.

### Build from source

```bash
git clone <repo>
cd Toolbox-Renggli-PC-Solutions
dotnet build src/ToolboxV15/ToolboxV15.slnx -c Release
```

### Run with `dotnet run`

```bash
dotnet run --project src/ToolboxV15/ToolboxCLI -- triage --area system --guided
```

Manifests are loaded by default from `./modules/manifests` relative to the current
working directory. Run the CLI from the repository root to pick up the full catalog.

### Publish binaries

```bash
dotnet publish src/ToolboxV15/ToolboxCLI -c Release -r win-x64 --self-contained -o publish/cli
dotnet publish src/ToolboxV15/ToolboxAgent -c Release -r linux-x64 --self-contained -o publish/agent
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxApi -c Release -o publish/api
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxClinical -c Release -o publish/clinical
```

The published binary (`toolbox`/`toolbox.exe` for the CLI, `toolbox-agent` for the
agent) can be distributed without the SDK installed.

### Tests

```bash
dotnet test src/ToolboxV15/ToolboxV15.slnx
```

The `tests/ToolboxTests` project covers the causal engine, module registry, manifest
loader, symptom registry, health calculator and execution results.

---

## 4. CLI Command Reference

General usage:

```
toolbox <command> [options]
```

### `triage`

Runs a full triage on an area, executing `baseline` and `diagnostic` modules
compatible with the current OS, and producing findings, a `HealthScore`,
recommendations and a `RunId`.

```
toolbox triage --area <system|network|server|artec> [--json] [--guided]
```

- `--area` (default `system`).
- `--json` emits the serialized `TriageResult` to stdout
  (conforms to `schemas/triage-result.schema.json`).
- `--guided` adds contextual hints for manual follow-up.

The last `TriageResult` is cached in-process for immediate use by `report export`.

### `symptom`

Queries the symptom registry and returns possible causes and recommended modules.

```
toolbox symptom <id> [--json]
```

### `catalog`

Lists and filters the catalog loaded from `modules/manifests/`.

```
toolbox catalog [--area <area>] [--os <windows|linux|macos>] [--risk <R|WR|WL|Critical>] [--json]
```

### `run`

Runs a single module by name.

```
toolbox run <module-id> [--json] [--force] [--params k=v;k2=v2]
```

- `--force` skips the privilege-elevation check (useful in CI pipelines).
- `--params` passes inline parameters to the module executor.

### `report`

Exports the last cached triage (or a placeholder if none exists).

```
toolbox report export --format <html|json|csv> --path <file>
```

### `agent`

Agent subcommands:

```
toolbox agent install
toolbox agent enroll --token <t> --server <url>
toolbox agent status
```

The standalone `toolbox-agent` binary additionally supports `run` to start the polling
loop and `install` to print service-registration instructions (Windows `sc.exe` or
systemd on Linux).

### `artec`

Dental-domain subcommands:

```
toolbox artec workflow
toolbox artec production [--action <status|queue|advance|block|cancel|rework>]
toolbox artec incident
```

- `workflow` guides the CAD/CAM workflow.
- `production` acts on a production job state.
- `incident` logs and triages an equipment incident.

---

## 5. Module Manifests

Each module is described by a JSON file validated against
`schemas/module-manifest.schema.json`. Key fields:

| Field               | Description                                                              |
|---------------------|--------------------------------------------------------------------------|
| `id`                | Module UUID.                                                             |
| `name`              | Stable identifier used by `run`, `catalog` and the agent.                |
| `area`              | `system` · `network` · `server` · `artec`.                              |
| `os`                | List of supported OSes: `windows`, `linux`, `macos`.                     |
| `category`          | `diagnostic` · `repair` · `admin` · `production` · `baseline`.          |
| `risk`              | Risk level (see below).                                                  |
| `reversible`        | `true` if the action can be undone.                                      |
| `timeout_ms`        | Maximum execution timeout.                                               |
| `permissions`       | `admin`, `root`, etc.                                                    |
| `remote_support`    | `none` · `readonly` · `full`.                                            |
| `rollback_module`   | Optional rollback module name.                                           |
| `associated_repair` | Suggested repair module after a finding.                                   |
| `version`           | Module SemVer.                                                           |

### Risk levels (`risk`)

| Code | Meaning                                          | Typical example                          |
|------|--------------------------------------------------|------------------------------------------|
| `R`  | Read-only. Does not modify the system.          | `hardware-smart`, `network-dns`.         |
| `W-R`| Reversible write. Changes can be undone.        | `repair-temp-cleanup`, `repair-wu-reset`.|
| `W-L`| Limited/latent impact write.                    | `system-services`, `system-autostart`.   |
| `!`  | Critical. Irreversible or high-impact action.  | `admin-format`, `admin-mbr-gpt`, `artec-scanner-calibration`. |

### Execution states

`ExecutionResult.Status` can be:

- `Success` — executed without errors.
- `Partial` — completed with partial findings.
- `Cancelled` — cancelled by token or user.
- `Skipped` — skipped by catalog filtering.
- `Blocked` — missing elevation or permissions.
- `Failed` — error or exception during execution.
- `Unsupported` — no executor registered for the module/OS.

The `ModuleRunner` applies a 30-second default timeout and sets the
`ErrorDetail.Code` to `TIMEOUT` on cancellation.

---

## 6. Guided vs Technical Mode

The CLI supports two output styles:

- **Guided mode** (default): colored text intended for a human operator, with a
  summary, numbered findings and next-step suggestions. Used by `triage`,
  `symptom`, `catalog`, `run` and `report` without flags.
- **Technical mode**: with `--json` the resulting object (`TriageResult`,
  `ExecutionResult`, `SymptomResult`, etc.) is serialized to stdout, ideal for
  automation, CI/CD and consumption from the panel or the agent.

The `triage --guided` command combines both: it produces guided output but adds
command hints for manual follow-up.

---

## 7. Docker Deployment

The `docker-compose.yml` file brings up the full production stack:

```bash
docker compose up -d --build
```

Included services:

| Service            | Image/Dockerfile            | Exposed port   | Network            |
|--------------------|------------------------------|-----------------|--------------------|
| `proxy` (Caddy)    | `caddy:2-alpine`             | 80, 443         | operational, clinical |
| `api`              | `docker/Dockerfile.api`      | 8080 (internal) | operational        |
| `db-operational`   | `postgres:16-alpine`         | —               | operational        |
| `service-clinical` | `docker/Dockerfile.clinical`  | 8081 (internal) | clinical           |
| `db-clinical`      | `postgres:16-alpine`         | —               | clinical           |
| `storage-clinical` | `minio/minio`                | 9001 (console)  | clinical           |
| `panel`            | `docker/Dockerfile.panel`     | 80 (internal)   | operational        |

Caddy publishes three routes:

- `/api/*` → `api:8080`
- `/clinical/*` → `service-clinical:8081`
- `/panel/*` → `panel:80`

Anything else responds 404; port 80 redirects to HTTPS with internal TLS.

### Sensitive configuration

The default credentials (`tbx_operational_pw`, `tbx_clinical_pw`, JWT keys, ApiKey,
MfaToken) are **development values** and must be replaced via environment variables
or secrets before a real deployment.

---

## 8. Artec Invent / Dental CAD-CAM

The `artec` area covers the **Artec / dental CAD-CAM** workflow, focused on UP3D
scanners and mills as well as lab production lines.

### Available modules

| Module                        | Description                                                              | Risk |
|-------------------------------|-------------------------------------------------------------------------|------|
| `artec-scanner-detect`         | UP3D scanner detection: presence, connection and drivers.              | `R`  |
| `artec-scanner-calibration`    | Calibration verification, date and accuracy.                           | `!`  |
| `artec-mill-detect`            | P52/P53 mill detection: presence, connection and firmware.             | `R`  |
| `artec-mill-network`            | Mill network connectivity: ping, latency, port and link state.         | `R`  |
| `artec-air-extraction`         | Air and extraction system: pressure, filters, pump, alerts.            | `R`  |
| `artec-software-versions`       | CAD/CAM software audit: versions, licenses and updates.                | `R`  |
| `artec-workflow-guide`          | Interactive dental workflow guide.                                     | `R`  |

### CAD/CAM workflow

1. **Receipt** of the case/dental piece.
2. **Scanning** with UP3D scanners (validated via `artec-scanner-detect` and
   `artec-scanner-calibration`).
3. **CAD design** at the design station.
4. **CAM** and toolpath generation.
5. **Queue** production and assign a mill.
6. **Milling** on P52/P53 units (with `artec-mill-detect` and `artec-mill-network`).
7. **Quality control (QC)** and validation of the produced piece.
8. **Completion** and delivery.

The scanning and milling stages require equipment verification; the `artec` modules
expose automated checks while the `toolbox artec workflow` command provides the
step-by-step guide.

---

## 9. Production Management

The clinical service models production jobs with states and roles defined in
`ToolboxCore.Artec` and mirrored in `ToolboxClinical`.

### States (`ProductionState`)

`Received` → `Scanning` → `Cad` → `Cam` → `Queued` → `Milling` → `QC` →
`Completed`

Side branches: `Blocked`, `Cancelled`, `Rework`.

| State       | Meaning                                                       |
|-------------|---------------------------------------------------------------|
| `Received`  | Case entered the lab.                                          |
| `Scanning`  | Scanning in progress with a UP3D scanner.                     |
| `Cad`       | CAD design in progress.                                        |
| `Cam`       | CAM toolpath generation.                                      |
| `Queued`    | Waiting for mill assignment.                                   |
| `Milling`   | Milling on P52/P53.                                            |
| `QC`        | Quality control.                                               |
| `Completed` | Piece finished and validated.                                   |
| `Blocked`   | Stopped by a dependency or pending requirement.               |
| `Cancelled` | Cancelled.                                                     |
| `Rework`    | Rework on a piece rejected at QC.                              |

### Roles (`ProductionRole`)

`Reception`, `Scanning`, `CadDesign`, `Cam`, `MachineOperator`, `Quality`,
`Administrator`.

State transitions go through `PUT /clinical/production/{id}/state` and every action
is recorded in the audit trail with `actor`, `target` and `details`.

---

## 10. Clinical Records

The `ToolboxClinical` service manages clinical records and attachments with
traceability required by Argentine regulation.

### Access

- **JWT authentication** validated (issuer, audience, signing key, lifetime).
- **Mandatory MFA**: the `X-MFA-Token` header is verified on every operation that
  touches clinical data; without it the response is `401 Unauthorized`.
- **Reason required**: reads (`record.read`, `patient.history`) require the
  `X-Access-Reason` header.

### Time-limited

- `RecordService.Create` sets `AccessExpiresAt = now + 15 min` by default.
- `ClinicalAccessManager` allows **30-minute** sessions
  (`DefaultAccessDuration`) for access explicitly requested with `requesterId`,
  `patientId`, `reason` and `mfaToken`.
- Requests can be **sealed** (`Seal`) to prevent any future access.

### Audit and retention

- `ClinicalAuditService` stores `Action`, `Actor`, `Target`, `Details` entries.
- Auditable via `GET /clinical/records/{id}/audit`.
- Attachments (uploads to `storage-clinical`) are **deleted 90 days after the
  incident closure** (`RetentionService`), with `deleteAfter` recorded on each
  attachment.

### Compliance

The `ClinicalAccessManager.ComplianceNote` explicitly states:

> Clinical record access respects **Argentina Ley 25.326** (Personal Data
> Protection) and **Ley 26.529** (Patient Rights). Access is time-limited,
> MFA-protected, reason-bound and audit-logged. Support attachments are deleted
> 90 days after incident closure.

---

## 11. Security

### Signed modules

Manifests can be transported signed; the loader validates the shape and, in
locked-down deployments, can require a known signature before registering the
module. `!` (critical) modules require explicit confirmation or `--force`.

### mTLS and ApiKey

- The **agent** enrolls with a token and receives a client certificate
  (`agent-{id}.cert`) persisted in `AgentConfig`.
- The **operational API** uses a *Hybrid* scheme (JWT or ApiKey via the
  `X-API-Key` header), selected at runtime by `ForwardDefaultSelector`.
- The **clinical service** stays on an isolated network (`clinical-net`) and is
  only reachable through the Caddy proxy with internal TLS.

### Audit chaining

Every relevant action (enrollment, module upload, job creation, triage, backup,
production transition, record or attachment access) generates an entry in
`AuditService` / `ClinicalAuditService` with actor, target, details and timestamp.
The `GET /api/audit?limit=N` endpoint allows reconstructing the chain.

### Isolated clinical database

The clinical database (`db-clinical`, database `clinical`) is **independent** of
the operational database (`toolbox`), lives on a separate network and does not
share credentials. Attachments are stored in **MinIO** (`storage-clinical`),
reachable only from `clinical-net`.

---

## 12. Migration from V14

V15 keeps a **legacy bridge** to coexist with V14 scripts during the transition:

- Legacy scripts (`Windows/toolbox.bat`, `Windows/toolbox.ps1`, `Linux/toolbox.sh`,
  `Mac/toolbox.sh`) remain available under their respective folders and are the
  recommended path while the V15 executor catalog is being completed.
- The V15 CLI can run in parallel: its modules are declarative and do not overwrite
  V14 artifacts.
- The recommended migration is incremental: first adopt `triage` and `catalog` for
  auditing, then `run` for modules already ported to `ToolboxCore`, and finally the
  agent and the server once the fleet is ready.
- V15 manifests replace the V14 plain-text "option catalog"; the V14 catalog
  remains a semantic reference during migration.

---

## 13. Status — Pending Items and Pilot Phase

V15 is in a **pilot phase** and some items are not yet production-ready:

- **hyperDENT profiles**: milling profiles for hyperDENT are **not yet validated**.
  Until validation is complete, keep using the inherited profiles and the vendor's
  CAM module.
- **Wet mill board**: detection and monitoring of the wet-milling board is
  **pending confirmation**; current `artec-mill-*` modules cover dry milling only.
- **Catalog executors**: several V15 catalog modules expose the interface but their
  concrete executor is a *stub*; the reported status is `Unsupported` until full
  implementation.
- **Clinical pilot**: the clinical service and attachment retention must be
  validated with the legal team before loading real patient data.
- **Agent service**: installing the agent as a service (`sc.exe` / systemd) is
  documented, but production enrollment must be done against a server with real TLS
  and ApiKey/JWT.

Any clinical use during this phase is the responsibility of the pilot organization.

---

## 14. Support and License

- Support: **tomasrenggli@gmail.com**
- Full documentation: `docs/` folder and historical manuals in `Manuales/`.
- License: © 2024-2026 Renggli PC Solution. Enterprise Toolbox V15. All rights reserved.