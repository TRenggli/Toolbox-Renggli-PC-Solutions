<!-- markdownlint-disable MD034 MD041 -->

🛠️ RENGGLI PC SOLUTIONS
Enterprise Toolbox V14
Unified Cross‑Platform IT Diagnostics & Repair Suite
https://img.shields.io/badge/License-Enterprise-blue  
https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux%20%7C%20macOS-green  
https://img.shields.io/badge/Version-V14-orange  
https://img.shields.io/badge/Build-Stable-success  
https://img.shields.io/badge/Documentation-Available-brightgreen
[![CI Smoke Checks](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-smoke.yml/badge.svg)](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-smoke.yml)
[![CI Matrix Regression](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-matrix-regression.yml/badge.svg)](https://github.com/TRenggli/Toolbox-Renggli-PC-Solutions/actions/workflows/ci-matrix-regression.yml)

A professional multi‑platform toolbox designed for system administrators, IT technicians, and enterprise environments.
Supports Windows, Linux, and macOS, offering diagnostics, maintenance, repair, and advanced administration tools.

Note:  
This repository contains the Enterprise Edition.
A separate Personal Edition exists, which includes Windows & Office activation utilities.
These modules are not included in the corporate version.

📁 Project Structure
Código
Toolbox/
│
├── Windows/
│   ├── toolbox.bat               # Full version
│   └── toolbox_corporate.bat     # Corporate version
│
├── Linux/
│   ├── toolbox.sh                # Full version (30 modules)
│   └── toolbox_corporate.sh      # Corporate version
│
├── Mac/
│   ├── toolbox.sh                # Full version
│   └── toolbox_corporate.sh      # Corporate version
│
├── Manuales/
│   ├── README_ES.md              # Spanish manual
│   ├── README_EN.md              # English manual
│   ├── README_CN.md              # Chinese manual
│   ├── COMO_GENERAR_PDFS.md      # PDF generation guide
│   ├── estilo_pdf_corporativo.css
│   └── PDFs/
│       ├── Manual_Toolbox_V14_ES.pdf
│       ├── Manual_Toolbox_V14_EN.pdf
│       └── Manual_Toolbox_V14_CN.pdf
│
└── Scripts/
    ├── generar_pdfs.bat          # PDF generator (Windows)
    └── generar_pdfs.sh           # PDF generator (Linux/Mac)
🚀 Quick Start
🪟 Windows
Open the Windows/ folder

Right‑click toolbox.bat

Select Run as administrator

Documentation: Manuales/README_EN.md#seccion-windows

🐧 Linux
bash
cd Linux/
chmod +x toolbox.sh
sudo ./toolbox.sh
Documentation: Manuales/README_EN.md#seccion-linux

🍎 macOS
bash
cd Mac/
chmod +x toolbox.sh
sudo ./toolbox.sh
Documentation: Manuales/README_EN.md#seccion-macos

📚 Documentation
Quick Documentation Index (Onboarding)

- Start here (operational usage by OS):
    - Spanish: [Manuales/README_ES.md](Manuales/README_ES.md)
    - English: [Manuales/README_EN.md](Manuales/README_EN.md)
    - Chinese: [Manuales/README_CN.md](Manuales/README_CN.md)

- Understand each option (what it does, when to use it, risks, precautions):
    - ES: [Manuales/CATALOGO_OPCIONES_ES.md](Manuales/CATALOGO_OPCIONES_ES.md)
    - EN: [Manuales/CATALOGO_OPCIONES_EN.md](Manuales/CATALOGO_OPCIONES_EN.md)
    - CN: [Manuales/CATALOGO_OPCIONES_CN.md](Manuales/CATALOGO_OPCIONES_CN.md)

- Modify or add modules safely (developer path):
    - Programmer guide in manuals (ES/EN/CN):
        - [Manuales/README_ES.md](Manuales/README_ES.md)
        - [Manuales/README_EN.md](Manuales/README_EN.md)
        - [Manuales/README_CN.md](Manuales/README_CN.md)
    - Contribution workflow + new module checklist:
        - [CONTRIBUTING.md](CONTRIBUTING.md)

- Keep change history updated:
    - [HISTORIAL_DE_CAMBIOS.md](HISTORIAL_DE_CAMBIOS.md)

Manuals by Language
🇪🇸 Spanish — Manuales/README_ES.md

🇬🇧 English — Manuales/README_EN.md

🇨🇳 Chinese — Manuales/README_CN.md

Detailed Option Catalogs (Multi-language)

- `Manuales/CATALOGO_OPCIONES_ES.md` (ES: explica cada opcion, riesgos, casos de uso y recaudos)
- `Manuales/CATALOGO_OPCIONES_EN.md` (EN: explains each option, risks, use cases, and precautions)
- `Manuales/CATALOGO_OPCIONES_CN.md` (CN: 说明每个选项、风险、使用场景与注意事项)

Developer Documentation (How to Add New Modules)

- 🇪🇸 ES: `Manuales/README_ES.md` → section `GUIA PARA PROGRAMADORES: COMO AGREGAR NUEVOS MODULOS`
- 🇬🇧 EN: `Manuales/README_EN.md` → section `PROGRAMMER GUIDE: HOW TO ADD NEW MODULES`
- 🇨🇳 CN: `Manuales/README_CN.md` → section `开发者指南：如何新增模块`
- Contribution checklist template: `CONTRIBUTING.md` → section `New Module Template (Recommended)`

Pre‑Generated PDFs
Located in Manuales/PDFs/:

Manual_Toolbox_V14_ES.pdf

Manual_Toolbox_V14_EN.pdf

Manual_Toolbox_V14_CN.pdf

⚙️ Features
✔️ Windows (21 Modules)
Hardware diagnostics (SMART, RAM, resource monitoring)

System repair (DISM, SFC, registry tools)

Network & connectivity utilities

Advanced administration tools

Blindaje V1 (Option 21 in Administration profile) is fully integrated in Toolbox.
Current integrated workflow includes:
- strict classroom hardening
- safe temporary-file review/cleanup for `SECUNDARIA` and `PRIMARIA`
- local scheduled auto-clean task creation/removal
- mass deployment guidance (domain/GPO and non-domain remote rollout)

✔️ Linux (30 Modules)
All Windows features + Linux‑specific modules

systemd service management

GRUB and bootloader repair

Advanced system monitoring

Docker/container cleanup

User & permission management

✔️ macOS (14 Modules)
Apple hardware diagnostics

Permission & security management

System cleanup & maintenance

🔐 Execution Profiles
🔍 Diagnostic — Read‑only

🔧 Repair — Reversible changes

⚠️ Administration — Advanced & critical operations

📖 PDF Generation
For PDF requirements, execution steps, troubleshooting, and technical details, use:
`Manuales/COMO_GENERAR_PDFS.md`

🆚 Editions
Full Edition (toolbox)
All modules enabled

Includes Windows activation tools (Personal Edition only)

All execution profiles available

Corporate Edition (toolbox_corporate)
Activation modules removed

Designed for licensed enterprise environments

Logs marked as VERSION: CORPORATE

📊 Logs & Reports
Each execution generates:

Timestamped text logs

HTML reports with corporate styling

SHA256 checksums for integrity validation

Log locations:

Windows: Windows/Logs/

Linux: Linux/Logs/

macOS: Mac/Logs/

🛡️ Security
Requires administrator/root privileges

Command validation before execution

Auditable logs with checksums

Open‑source, fully reviewable scripts

No malicious code

🌐 Compatibility
Windows
Windows 10 (1809+)

Windows 11

Windows Server 2016 / 2019 / 2022

Linux
Debian / Ubuntu

Fedora / RHEL / CentOS

Arch / Manjaro

OpenSUSE

macOS
macOS 10.14+

Intel & Apple Silicon (M1/M2)

📞 Support
Email: tomasrenggli@gmail.com
Full documentation available in the Manuales/ directory.

📜 License
© 2024 RENGGLI PC SOLUTIONS
Enterprise‑grade IT toolbox. All rights reserved.

🔄 Current Version
Enterprise Toolbox V14
