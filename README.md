<!-- markdownlint-disable MD034 MD041 -->

# Renggli PC Solution - Enterprise Toolbox V15

A hybrid cross-platform platform for **IT diagnostics, repair, server fleet
management and dental CAD/CAM production**, built on a **.NET 10** core engine
with a declarative JSON module catalog and a service-oriented Docker deployment.

![License](https://img.shields.io/badge/License-Enterprise-blue)
![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux%20%7C%20macOS-green)
![Version](https://img.shields.io/badge/Version-V15-orange)
![Build](https://img.shields.io/badge/Build-Stable-success)
[![CI Smoke Checks](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-smoke.yml/badge.svg)](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-smoke.yml)
[![CI Matrix Regression](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-matrix-regression.yml/badge.svg)](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-matrix-regression.yml)

Toolbox V15 replaces the V14 script-only model with a multi-tier architecture:
- a cross-platform **CLI** (`ToolboxCLI`),
- a shared **core engine** (`ToolboxCore`) with platform abstractions and a causal
  triage engine,
- a deployable **remote agent** (`ToolboxAgent`),
- a Docker-based **server** stack (`ToolboxApi` + `ToolboxClinical` + `ToolboxPanel`),
- and a new **dental domain** (`artec`) for CAD/CAM and clinical production.

The legacy V14 scripts remain available during migration through a legacy bridge.

---

## V15 Documentation (Multilingual)

| Language | Document |
|----------|----------|
| 🇪🇸 Español | [docs/V15_README_ES.md](docs/V15_README_ES.md) |
| 🇬🇧 English | [docs/V15_README_EN.md](docs/V15_README_EN.md) |
| 🇨🇳 简体中文 | [docs/V15_README_CN.md](docs/V15_README_CN.md) |

Historical V14 manuals (ES/EN/CN) remain in the [`Manuales/`](Manuales/) directory,
including the option catalogs and PowerShell core guide.

---

## Architecture Overview

| Component              | Role                                                                                | Stack                          |
|------------------------|-------------------------------------------------------------------------------------|--------------------------------|
| `ToolboxCLI`           | Command-line interface: `triage`, `symptom`, `catalog`, `run`, `report`, `agent`, `artec`. | .NET 10, `System.CommandLine` |
| `ToolboxCore`          | Causal engine, module registry, runner, health score, OS abstraction, report export. | .NET 10 (shared library)       |
| `ToolboxAgent`         | Deployable agent: enroll, heartbeat, job polling, remote execution.                 | .NET 10, `HttpClient`          |
| `ToolboxServer.Api`    | Operational API: agents, modules, jobs, triage, audit, backup. Hybrid JWT + ApiKey. | ASP.NET Core 10, PostgreSQL    |
| `ToolboxServer.Clinical` | Isolated clinical service: records, production, attachments, retention, MFA audit. | ASP.NET Core 10, PostgreSQL, MinIO |
| `ToolboxPanel`         | Administrative web panel.                                                           | Vite + React                   |
| `docker-compose.yml`   | Orchestration: Caddy proxy, api, db, clinical service, clinical db, storage, panel. | Docker Compose                 |

Network isolation:

- `operational-net` — api, db-operational, panel, proxy.
- `clinical-net` — clinical service, clinical db, clinical storage (MinIO).

The clinical service is only reachable through the Caddy reverse proxy (`/clinical/*`).

---

## Quick Start

### Requirements

- **.NET 10 SDK** to build and run the CLI / agent / services.
- Recommended: run from the repository root so the CLI finds `modules/manifests/`.
- For server deployments: Docker with Compose v2.
- Administrator/root for modules marked `admin`/`root`.

### Build and run

```bash
git clone <repo>
cd Toolbox-Renggli-PC-Solutions

# Build everything
dotnet build src/ToolboxV15/ToolboxV15.slnx -c Release

# Run the CLI from source
dotnet run --project src/ToolboxV15/ToolboxCLI -- triage --area system --guided

# Run the tests
dotnet test src/ToolboxV15/ToolboxV15.slnx
```

### Publish self-contained binaries

```bash
dotnet publish src/ToolboxV15/ToolboxCLI -c Release -r win-x64 --self-contained -o publish/cli
dotnet publish src/ToolboxV15/ToolboxAgent -c Release -r linux-x64 --self-contained -o publish/agent
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxApi -c Release -o publish/api
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxClinical -c Release -o publish/clinical
```

### Module manifests

Modules are described by JSON manifests validated against
[`schemas/module-manifest.schema.json`](schemas/module-manifest.schema.json). The
catalog lives in [`modules/manifests/`](modules/manifests/) and covers `system`,
`network`, `server` and `artec` areas with risk levels `R`, `W-R`, `W-L` and `!`.

---

## CLI Commands

| Command  | Usage                                                              | Description                                                |
|----------|-------------------------------------------------------------------|------------------------------------------------------------|
| `triage` | `triage --area <system\|network\|server\|artec> [--json] [--guided]` | Runs baseline + diagnostic modules; produces findings, `HealthScore`, recommendations. |
| `symptom`| `symptom <id> [--json]`                                            | Queries the symptom registry; returns causes and recommended modules. |
| `catalog`| `catalog [--area] [--os] [--risk] [--json]`                       | Lists and filters the loaded catalog.                     |
| `run`    | `run <module-id> [--json] [--force] [--params k=v;...]`           | Executes a single module by name.                          |
| `report` | `report export --format <html\|json\|csv> --path <file>`           | Exports the last cached triage result (or a placeholder).  |
| `agent`  | `agent install \| enroll [--token] [--server] \| status`          | Manages the remote agent (enroll, install as service, status). |
| `artec`  | `artec workflow \| production [--action] \| incident`             | Dental CAD/CAM workflow, production management and incidents. |

Add `--json` for machine-readable output (CI/CD, panel, agent). Add `--guided` for
human-friendly next-step hints.

---

## Docker Deployment

The full stack is defined in [`docker-compose.yml`](docker-compose.yml):

```bash
docker compose up -d --build
```

| Service            | Image / Dockerfile            | Exposed port   | Network            |
|--------------------|-------------------------------|----------------|--------------------|
| `proxy` (Caddy)    | `caddy:2-alpine`              | 80, 443        | operational, clinical |
| `api`              | `docker/Dockerfile.api`       | 8080 (internal)| operational        |
| `db-operational`   | `postgres:16-alpine`          | —              | operational        |
| `service-clinical` | `docker/Dockerfile.clinical`  | 8081 (internal)| clinical           |
| `db-clinical`      | `postgres:16-alpine`          | —              | clinical           |
| `storage-clinical` | `minio/minio`                | 9001 (console) | clinical           |
| `panel`            | `docker/Dockerfile.panel`     | 80 (internal)  | operational        |

Caddy publishes:

- `/api/*` → `api:8080`
- `/clinical/*` → `service-clinical:8081`
- `/panel/*` → `panel:80`

> Replace the default development credentials (`tbx_operational_pw`,
> `tbx_clinical_pw`, JWT keys, ApiKey, MfaToken) via environment variables or secrets
> before any real deployment. See the language READMEs for the clinical compliance
> notes (Argentina Ley 25.326 / 26.529, MFA, time-limited access, 90-day attachment
> retention, isolated clinical DB).

---

## V14 Migration / Legacy Bridge

V15 coexists with V14 during migration:

- Legacy scripts (`Windows/toolbox.bat`, `Windows/toolbox.ps1`, `Linux/toolbox.sh`,
  `Mac/toolbox.sh`) remain in their folders and are the recommended path while the
  V15 executor catalog is being completed.
- The V15 CLI can run in parallel; its modules are declarative and do not overwrite
  V14 artifacts.
- Recommended path: adopt `triage` + `catalog` first, then `run` for ported
  modules, then the agent and the server once the fleet is ready.

---

## Note on MAS

**MAS (Microsoft Activation Scripts) is no longer part of the Toolbox V15
distribution.** The `Windows/MAS_AIO.cmd` file and the contents under
`herramienta mas/` are kept only as a **separate external product** for authorized
testing scenarios. Toolbox V15 itself ships **MAS-free** for regulated and enterprise
environments; if activation tooling is required, it must be sourced as a standalone
artifact and is not supported through the V15 CLI, services or agents.

---

## Support

Email: **tomasrenggli@gmail.com**
Full documentation: see the `docs/` folder (V15) and `Manuales/` (V14).

## License

© 2024-2026 Renggli PC Solution
Enterprise-grade IT toolbox. All rights reserved.

## Current Version

Enterprise Toolbox V15