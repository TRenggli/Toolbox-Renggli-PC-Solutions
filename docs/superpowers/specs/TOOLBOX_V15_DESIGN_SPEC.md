# Enterprise Toolbox V15 — Design Specification

**Version:** 1.0.0  
**Date:** 2026-08-12  
**Status:** Draft — Pending Final Review  
**Branch:** `codex/toolbox-v15-redesign`

## 1. Product Overview

Enterprise Toolbox V15 is a hybrid, cross-platform IT diagnostics and repair platform with four functional areas:

| Area | Scope |
|---|---|
| **Equipos y Sistema** | Hardware, OS, drivers, services, events, security baseline |
| **Redes** | Connectivity, DNS, ports, certificates, AD/IIS |
| **Servidores** | Docker, PostgreSQL, MySQL, MSSQL, service health |
| **Artec Invent / Dental CAD-CAM** | UP3D scanners, milling machines, CAD/CAM toolchain, production tracking |

### 1.1 Architecture Principles

- **Hybrid operation:** Core diagnostics run offline; catalog, updates, and panel require network.
- **Single engine:** Portable package and installed agent share identical diagnostic/remediation logic.
- **Guided-first:** Default guided mode with expandable technical terminal.
- **Cross-platform:** Windows, Linux, macOS via OS abstraction layer; UP3D is Windows-only.
- **MAS excluded:** Microsoft Activation Scripts removed from distribution; maintained as separate external product if needed.

## 2. CLI Commands

```
toolbox triage --area <system|network|server|artec> [--json] [--guided]
toolbox symptom <id> [--json]
toolbox catalog [--area <area>] [--os <os>] [--risk <risk>] [--json]
toolbox run <module-id> [--json] [--force] [--params <json>]
toolbox report export [--format html|json|csv] [--path <path>]
toolbox agent install|enroll|status [--token <token>] [--server <url>]
toolbox artec workflow|production|incident [--action <action>] [--json]
```

### 2.1 Modes

- **Guided mode (default):** Step-by-step wizard with explainers and confirmations.
- **Technical mode:** Full parameter control, JSON output, scriptable.

## 3. Module Manifests

Every module is registered via a JSON manifest:

```json
{
  "id": "uuid",
  "name": "human-readable",
  "area": "system|network|server|artec",
  "os": ["windows", "linux", "macos"],
  "category": "diagnostic|repair|admin|production",
  "risk": "R|W-R|W-L|!",
  "reversible": true,
  "parameters": {},
  "permissions": ["admin", "root"],
  "timeout_ms": 30000,
  "evidence": ["log", "screenshot", "registry"],
  "output_schema": {},
  "associated_repair": "module-id|none",
  "remote_support": "none|readonly|full",
  "rollback_module": "module-id|none"
}
```

### 3.1 Execution States

| State | Meaning |
|---|---|
| `success` | Completed without errors, verification passed |
| `cancelled` | User cancelled before execution |
| `skipped` | Preconditions not met, skipped safely |
| `partial` | Some steps completed, some failed |
| `failed` | Execution error, rollback triggered |
| `blocked` | Permission/requirement missing |
| `unsupported` | Not available on this OS/version |

### 3.2 Risk Levels

| Code | Description |
|---|---|
| `R` | Read-only, zero side effects |
| `W-R` | Write, reversible/remote-capable with rollback |
| `W-L` | Write, local-only (network, disks, firmware, credentials) |
| `!` | Critical local (BitLocker, calibration, physical) |

## 4. Diagnostic & Remediation Engine

### 4.1 System Baseline

Runs on every system: hardware inventory, disks (SMART), memory, sensors, OS version, patches, pending reboots, services, event log patterns, network config, security posture, installed software.

### 4.2 Causal Correlation

Evidence correlated against deterministic rules with confidence levels:

| Level | Meaning |
|---|---|
| `Confirmed` | Direct causal chain verified |
| `Probable` | Strong correlation, >80% confidence |
| `Possible` | Weak correlation, 30-80% |
| `Insufficient evidence` | <30%, need more data |

### 4.3 Health Score

0-100 composite score for quick assessment. Never used as substitute for findings. Components: hardware, storage, system, network, security.

### 4.4 Repair Protocol

Every repair follows: **Precondition → Backup → Execution → Verification → Rollback**

- Failed, partial, or non-zero exit codes NEVER register as success.
- Remote repairs: only `W-R` modules, re-authentication required, explicit scope, individual approval.
- Local-only: DISM/SFC, broad resets, irreversible cleanup, credentials, disks, BitLocker, firmware, calibrations, physical machine actions.

## 5. Agent & Server

### 5.1 Docker Compose Stack

| Service | Purpose |
|---|---|
| `proxy` | HTTPS reverse proxy (Caddy/Nginx) |
| `api` | .NET 8 operational API |
| `panel` | React dashboard |
| `db-operational` | PostgreSQL for operational data |
| `service-clinical` | Isolated clinical service |
| `db-clinical` | Isolated PostgreSQL for clinical data |
| `storage-clinical` | Isolated encrypted storage |

### 5.2 Agent Enrollment

1. Admin generates single-use enrollment token
2. Agent connects outbound with token
3. Server issues client certificate
4. All subsequent connections use mutual TLS

### 5.3 Security Requirements

- Local accounts with optional AD/LDAP
- MFA mandatory for all users
- Signed modules, packages, and jobs
- Version, parameters, recipient, expiry, and approval validated
- Separate networks, credentials, databases, and keys for operational vs clinical data
- Append-only audit logs with chained hashes and tamper alerts
- Daily encrypted backups + weekly immutable copies to separate destination
- RPO: 24 hours, RTO: 4 hours
- Monthly restore tests
- Ring-based staged rollouts with rollback

## 6. Artec Invent — Dental CAD-CAM

### 6.1 Supported Hardware

| Device | Type | Profiles |
|---|---|---|
| UP400 | Scanner | Declarative profile |
| UP560 / UP560HD | Scanner | Declarative profile |
| P52 | Dry mill | Declarative profile |
| P53 | Dry mill | Declarative profile |
| P42 / P42 Plus | Wet mill | After board confirmation |

### 6.2 Detection

Detects: PC hardware, GPU, drivers, USB 3, Plug & Play, network, storage, processes, services, software versions, associated logs.

### 6.3 Software Adapters

- Dental Station
- exocad
- UPCAD
- UPCAM 4.0
- hyperDENT (block production if no validated profile; official: https://www.follow-me-tech.com/hyperdent/)
- Official milling machine controllers

### 6.4 Guided Workflow

Scan → CAD → CAM → Machine Control → Post-processing / QC

- Always ask: UPCAM or hyperDENT
- Show compatibility, license, post-processor, advantages, risks
- Open official tools at the correct stage
- Never alter licenses, firmware, geometries, or CAM strategies

### 6.5 Diagnostic Scenarios

Scanner not detected, poor capture, calibration, export issues, CAD→CAM problems, machine not on network, interrupted milling, air/extraction, tools, cooling.

### 6.6 Production Management

**States:** received, scanning, cad, cam, queued, milling, qc, completed, blocked, cancelled, rework

**Roles:** Reception, Scanning, CAD Design, CAM, Machine Operator, Quality, Administrator

- Manual selection of CAM + mill machine required
- System validates incompatibilities, never substitutes operator

### 6.7 Clinical Records

File versioning with hash, immutable audit events (operator, date, software, version, machine, result).

Complete records stored in isolated clinical service:
- Time-limited access with MFA
- Mandatory reason for access
- Full audit trail
- Retention configurable, no auto-deletion without approved legal policy
- Compliant with Argentine laws 25.326 and 26.529 (integrity, authenticity, restricted access, patient rights)
- Support attachments separated, deleted 90 days after incident closure

## 7. Legacy Bridge

`toolbox.bat` becomes a temporary bridge:
- Translates `/perfil` and `/mod` parameters to new CLI
- Displays migration notice
- Retired after one stable V15 version

## 8. Delivery Phases

1. **Spec & Review:** This document + threat assessment → final review
2. **Contracts:** Branch `codex/toolbox-v15-redesign`, CLI contracts, manifests, JSON schemas
3. **Diagnostics:** Migrate read-only diagnostics, guided experience for all 3 OS
4. **Engine:** Causal engine, symptoms, local repairs, rollback
5. **Server:** Agent, Docker server, panel, identity, audit, backups
6. **Artec Invent:** Hardware/software validation with real equipment
7. **Production:** Production workflow + isolated clinical repository
8. **Bridge + Docs:** Legacy bridge, signed installers, ES/EN/CN documentation
9. **Pilot:** Test server, one station, one scanner, one mill; expand by rings

## 9. Acceptance Criteria

- No false successes
- Remote rollback tested
- Agents do not open ports
- Clinical records inaccessible from operational plane
- All tests pass (unit, integration, contract, security, E2E, physical)
- SBOM generated, no secrets exposed, MAS excluded from distribution
