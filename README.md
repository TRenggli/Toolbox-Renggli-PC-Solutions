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
├── Manuals/
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

Documentation: Manuals/README_EN.md#windows

🐧 Linux
bash
cd Linux/
chmod +x toolbox.sh
sudo ./toolbox.sh
Documentation: Manuals/README_EN.md#linux

🍎 macOS
bash
cd Mac/
chmod +x toolbox.sh
sudo ./toolbox.sh
Documentation: Manuals/README_EN.md#macos

📚 Documentation
Manuals by Language
🇪🇸 Spanish — Manuals/README_ES.md

🇬🇧 English — Manuals/README_EN.md

🇨🇳 Chinese — Manuals/README_CN.md

Developer Documentation (How to Add New Modules)
- 🇪🇸 ES: `Manuales/README_ES.md` → section `GUIA PARA PROGRAMADORES: COMO AGREGAR NUEVOS MODULOS`
- 🇬🇧 EN: `Manuales/README_EN.md` → section `PROGRAMMER GUIDE: HOW TO ADD NEW MODULES`
- 🇨🇳 CN: `Manuales/README_CN.md` → section `开发者指南：如何新增模块`
- Contribution checklist template: `CONTRIBUTING.md` → section `New Module Template (Recommended)`

Pre‑Generated PDFs
Located in Manuals/PDFs/:

Manual_Toolbox_V14_ES.pdf

Manual_Toolbox_V14_EN.pdf

Manual_Toolbox_V14_CN.pdf

⚙️ Features
✔️ Windows (15 Modules)
Hardware diagnostics (SMART, RAM, resource monitoring)

System repair (DISM, SFC, registry tools)

Network & connectivity utilities

Advanced administration tools

✔️ Linux (30 Modules)
All Windows features + Linux‑specific modules

systemd service management

GRUB and bootloader repair

Advanced system monitoring

Docker/container cleanup

User & permission management

✔️ macOS
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

Windows: C:\ToolboxLogs\

Linux/macOS: /var/log/toolbox/ or ~/toolbox_logs/

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
Email: soporte@renggli-solutions.com
Full documentation available in the Manuals/ directory.

📜 License
© 2024 RENGGLI PC SOLUTIONS
Enterprise‑grade IT toolbox. All rights reserved.

🔄 Current Version
Enterprise Toolbox V14
