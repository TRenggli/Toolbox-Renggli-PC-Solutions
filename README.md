# 🛠️ RENGGLI PC SOLUTIONS

## Enterprise Toolbox V14

Unified cross-platform IT diagnostics and repair suite for Windows, Linux and
macOS.

[![License](https://img.shields.io/badge/License-Enterprise-blue)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-Windows%20%7C%20Linux%20%7C%20macOS-green)](#-compatibility)
[![Version](https://img.shields.io/badge/Version-V14-orange)](#-current-version)
[![Build](https://img.shields.io/badge/Build-Stable-success)](README.md)
[![Docs](https://img.shields.io/badge/Documentation-Available-brightgreen)](Manuales/README_EN.md)

A professional multi-platform toolbox designed for IT technicians, system
administrators, and enterprise environments.

> [!NOTE]
> This repository contains the Enterprise Edition.
> A separate Personal Edition exists and includes Windows and Office activation
> utilities. Those modules are not included in the corporate version.

## 📁 Project Structure

```text
Toolbox/
├── Windows/
│   ├── toolbox.bat
│   └── toolbox_corporate.bat
├── Linux/
│   ├── toolbox.sh
│   └── toolbox_corporate.sh
├── Mac/
│   ├── toolbox.sh
│   └── toolbox_corporate.sh
└── Manuales/
    ├── README_ES.md
    ├── README_EN.md
    ├── README_CN.md
    ├── COMO_GENERAR_PDFS.md
    ├── estilo_pdf_corporativo.css
    └── PDFs/
        ├── Manual_Toolbox_V14_ES.pdf
        ├── Manual_Toolbox_V14_EN.pdf
        └── Manual_Toolbox_V14_CN.pdf
```

## 🚀 Quick Start

### 🪟 Windows

1. Open the `Windows/` folder.
2. Right-click `toolbox.bat`.
3. Select **Run as administrator**.
4. See [Windows documentation](Manuales/README_EN.md#windows).

### 🐧 Linux

```bash
cd Linux/
chmod +x toolbox.sh
sudo ./toolbox.sh
```

See [Linux documentation](Manuales/README_EN.md#linux).

### 🍎 macOS

```bash
cd Mac/
chmod +x toolbox.sh
sudo ./toolbox.sh
```

See [macOS documentation](Manuales/README_EN.md#macos).

## 📚 Documentation

- 🇪🇸 [README_ES.md](Manuales/README_ES.md)
- 🇬🇧 [README_EN.md](Manuales/README_EN.md)
- 🇨🇳 [README_CN.md](Manuales/README_CN.md)
- 📌 [HISTORIAL_DE_CAMBIOS.md](HISTORIAL_DE_CAMBIOS.md)

### Pre-generated PDFs

- `Manuales/PDFs/Manual_Toolbox_V14_ES.pdf`
- `Manuales/PDFs/Manual_Toolbox_V14_EN.pdf`
- `Manuales/PDFs/Manual_Toolbox_V14_CN.pdf`

## ⚙️ Features

### Windows (15 modules)

- Hardware diagnostics (SMART, RAM, resource monitoring)
- System repair (DISM, SFC, registry tools)
- Network and connectivity utilities
- Advanced administration tools

### Linux (30 modules)

- All Windows features plus Linux-specific modules
- `systemd` service management
- GRUB and bootloader repair
- Advanced system monitoring
- Docker/container cleanup
- User and permission management

### macOS Compatibility

- Apple hardware diagnostics
- Permission and security management
- System cleanup and maintenance

## 🔐 Execution Profiles

- 🔍 **Diagnostic**: Read-only
- 🔧 **Repair**: Reversible changes
- ⚠️ **Administration**: Advanced and critical operations

## 🆚 Editions

### Full Edition (`toolbox`)

- All modules enabled
- Includes activation modules (Personal Edition only)
- All execution profiles available

### Corporate Edition (`toolbox_corporate`)

- Activation modules removed
- Designed for licensed enterprise environments
- Logs marked as `VERSION: CORPORATE`

## 📊 Logs and Reports

Each execution can generate:

- Timestamped text logs
- HTML reports with corporate styling
- SHA256 checksums for integrity validation

Exit behavior:

- Option 0: generate report and persist the current session log
- Option 00: exit without report and discard the current session log

Log locations:

- Windows: `C:\ToolboxLogs\`
- Linux/macOS: `/var/log/toolbox/` or `~/toolbox_logs/`

## 🛡️ Security

- Requires administrator/root privileges
- Command validation before execution
- Auditable logs with checksums
- Open-source and reviewable scripts

## 🌐 Compatibility

### Windows

- Windows 10 (1809+)
- Windows 11
- Windows Server 2016 / 2019 / 2022

### Linux

- Debian / Ubuntu
- Fedora / RHEL / CentOS
- Arch / Manjaro
- OpenSUSE

### macOS

- macOS 10.14+
- Intel and Apple Silicon (M1/M2)

## 📞 Support

- Email: [soporte@renggli-solutions.com](mailto:soporte@renggli-solutions.com)
- Full documentation in [Manuales](Manuales/)

## 📜 License

© 2024 RENGGLI PC SOLUTIONS. Enterprise-grade IT toolbox.

## 🔄 Current Version

Enterprise Toolbox V14
