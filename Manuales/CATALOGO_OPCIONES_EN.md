# Option Catalog - Toolbox V14 (EN)

This document explains each menu option by operating system.
It includes: what it does, why it exists, when to use it, and precautions.

Risk legend:

- `[R]` = Read-only (no configuration changes)
- `[W]` = Writes/changes system state
- `[!]` = Critical or potentially irreversible

Profiles:

- `D` = Diagnostics
- `R` = Repair
- `A` = Administration

## Windows (21 options)

| # | Option | Profiles | Risk | What it does | When to use | Precautions |
| --- | -------- | ---------- | ------ | -------------- | ------------- | ------------- |
| 1 | BIOS/board or SMART info (menu-dependent) | D/R/A | [R] | Reads firmware/model/disk health | Inventory or technical audit | None, read-only |
| 2 | RAM or resources (menu-dependent) | D/R/A | [R] | Shows memory/CPU or launches RAM test | Slowdowns, freezes, preventive checks | RAM test may require reboot/outside flow |
| 3 | Resources/RAM (menu-dependent) | D/R/A | [R] | Reads operational hardware metrics | Validate machine capacity | None, read-only |
| 4 | WU status or DISM/SFC (profile-dependent) | D/R/A | [R]/[W] | In D it queries; in R/A it repairs image/files | Windows integrity incidents | Do not interrupt DISM/SFC |
| 5 | DNS audit or WU repair (profile-dependent) | D/R/A | [R]/[W] | Queries ports/DNS or repairs WU stack | Update/network incidents | Repair mode changes services/cache |
| 6 | Speed/cleanup/WU status (profile-dependent) | D/R/A | [R]/[W] | Diagnostic query or cleanup depending on profile | Diagnostics or maintenance | Cleanup removes temp files |
| 7 | Battery or network reset (profile-dependent) | D/R/A | [R]/[W] | Generates battery report or resets network stack | Laptops / IP-DNS failures | Network reset can disconnect temporarily |
| 8 | Critical events / speed test | D/R/A | [R] | Reads critical events or network speed | Post-failure analysis | Read-only |
| 9 | BSOD analyzer / DNS audit | D/R/A | [R] | Lists minidumps + bugcheck or audits DNS/ports | BSOD incidents / network diagnostics | Read-only |
| 10 | Process forensics or disk format (A) | D/R/A | [R]/[!] | In D/R audits processes; in A formats disk | Malware suspicion / media prep | Formatting: confirm target disk |
| 11 | RAID status or MBR->GPT (A) | D/R/A | [R]/[!] | In D/R reads storage status; in A converts partition scheme | Storage diagnostics / migration | Wrong conversion can break boot |
| 12 | RAID status / Winget / maintenance tools | D/R/A | [R]/[W] | Storage query or app updates | Software maintenance | Updates may require restart |
| 13 | Process forensics / Driver backup / MAS (normal) | R/A | [W] | In R driver backup; in A normal edition MAS; corporate blocked | Pre-repair backup or licensed activation | Backup consumes disk; MAS only where authorized |
| 14 | Critical events / scheduled shutdown | R/A | [R]/[W] | Event query or shutdown scheduling | Incident review or automation | Risk of service interruption. Use validated `HH:MM` time format |
| 15 | BSOD / Battery | R/A | [R] | BSOD query or battery report | Post-failure or battery health | Read-only |
| 16 | Forensics / Driver backup | R/A | [R]/[W] | Process audit or driver export | Security review / rollback prep | Requires free disk space |
| 17 | RAID status / Events | R/A | [R] | Reads storage/event state by menu | Advanced diagnostics | Read-only |
| 18 | BSOD (A) | A | [R] | Reads minidumps and bugcheck events | Stability incidents | Read-only |
| 19 | Process forensics (A) | A | [R] | Finds temp-path processes and signature status | Hardening and audits | Read-only |
| 20 | RAID/Storage (A) | A | [R] | Reads virtual/physical disk health + WMI fallback | Servers or complex storage | Read-only |
| 21 | High Security Profile (Blindaje V1 integrated) (A) | A | [W] | Applies strict hardening + safe temp workflow: manual review/cleanup, local scheduled auto-clean, auto-clean disable, and mass deployment guide (GPO/remote), with patterns limited to `~$*`, `.tmp`, `.temp` in `SECUNDARIA/PRIMARIA` | School/lab endpoints with standard users where preserving student work is the priority while keeping temp files controlled | After Undo, reboot and manually verify whether `C:\Trabajos Alumnos` was fully removed; for temp cleanup keep safe patterns only and do not widen extensions |

Notes (Windows):

- Exact number can map to different action depending on profile (D/R/A).
- In `toolbox_corporate.bat`, option 13 (MAS) is removed by compliance design.

### Mini CLI Guide (Windows)

Quick parameter usage:

```cmd
toolbox.bat /perfil:X /mod:Y
```

- `X`: `1` Diagnostics, `2` Repair, `3` Administration
- `Y`: module number inside that profile

Examples (`toolbox.bat`):

- `toolbox.bat /perfil:1 /mod:4`  (Windows Update status)
- `toolbox.bat /perfil:2 /mod:5`  (repair Windows Update)
- `toolbox.bat /perfil:3 /mod:10` (secure format)
- `toolbox.bat /perfil:3 /mod:21` (High Security Profile)

Examples (`toolbox_corporate.bat`):

- `toolbox_corporate.bat /perfil:1 /mod:1`  (SMART)
- `toolbox_corporate.bat /perfil:2 /mod:6`  (repair Windows Update)
- `toolbox_corporate.bat /perfil:3 /mod:10` (secure format)

Notes:

- If `profile/module` is not valid for the selected profile, execution is blocked and logged.
- Critical modules keep safety confirmations before execution.

## Linux (30 options)

| # | Option | Profiles | Risk | What it does | When to use | Precautions |
| --- | -------- | ---------- | ------ | -------------- | ------------- | ------------- |
| 1 | SMART disk health | D/R/A | [R] | Reads SMART status | Detect disk degradation | May auto-install smartmontools |
| 2 | Full hardware info | D/R/A | [R] | CPU/RAM/board data | Asset inventory | Read-only |
| 3 | RAM diagnostics | D/R/A | [R] | Memory status/symptoms | Performance or memory issues | Deep tests may require external tools |
| 4 | OS info | D/R/A | [R] | Kernel/distro/version | Support and compatibility | Read-only |
| 5 | Sensors and temperature | D/R/A | [R] | Thermal sensor readout | Overheating checks | Sensor package availability |
| 6 | Filesystem check (fsck) | R/A | [W] | Checks/repairs filesystem | Corruption symptoms | May need unmounted partition |
| 7 | Package manager repair | R/A | [W] | Repairs package DB/state | Broken dependencies | Can reinstall/repair packages |
| 8 | Deep cleanup | R/A | [W] | Cleans caches/temp data | Recover disk space | Review cleanup scope |
| 9 | GRUB repair | A | [!] | Repairs bootloader | Boot failures | Critical operation |
| 10 | Docker cleanup | R/A | [W] | Prunes Docker artifacts | Disk pressure | Can remove unused data |
| 11 | Network reset | R/A | [W] | Resets network stack/settings | Connectivity incidents | Temporary disconnect |
| 12 | Speed test | D/R/A | [R] | Measures throughput | ISP/network diagnostics | Read-only |
| 13 | DNS/ports audit | D/R/A | [R] | Lists services/ports/DNS status | Security baseline | Read-only |
| 14 | Firewall diagnostics | R/A | [W] | Reviews/applies firewall state | Security troubleshooting | Can alter active rules |
| 15 | Live network monitor | D/R/A | [R] | Current traffic/connection view | Incident response | Read-only |
| 16 | Safe USB format | A | [!] | Formats removable media | Prepare clean media | Verify target device |
| 17 | MBR to GPT conversion | A | [!] | Changes partition scheme | Migration tasks | Critical disk operation |
| 18 | Disk analysis | D/R/A | [R] | Reads disk topology/health | Storage diagnostics | Read-only |
| 19 | Partition mounting | A | [!] | Mount/remount partitions | Advanced admin | Risk on production volumes |
| 20 | Disk space | D/R/A | [R] | Filesystem usage summary | Capacity planning | Read-only |
| 21 | Service management | R/A | [W] | systemd service operations | Service recovery | Can impact availability |
| 22 | Top CPU/RAM processes | D/R/A | [R] | Lists heaviest processes | Performance analysis | Read-only |
| 23 | System logs | D/R/A | [R] | dmesg/journalctl review | Error investigation | Read-only |
| 24 | Users and permissions | A | [!] | Account/permission management | Advanced administration | Potential lockout risk |
| 25 | Realtime monitor | D/R/A | [R] | Live resource watch | Load analysis | Read-only |
| 26 | System update | R/A | [W] | Upgrades packages/system | Planned maintenance | May require reboot |
| 27 | Scheduled shutdown | R/A | [W] | Schedules shutdown | Automation windows | Validate `HH:MM` format and maintenance window |
| 28 | Data backup | R/A | [W] | Creates compressed backup | Before risky changes | Validate destination space |
| 29 | Battery report | D/R/A | [R] | Reads battery state | Laptop health checks | May not apply to desktops |
| 30 | Integrity checks | D/R/A | [R] | Consistency/health checks | Preventive auditing | Read-only |

## macOS (14 options)

| # | Option | Profiles | Risk | What it does | When to use | Precautions |
| --- | -------- | ---------- | ------ | -------------- | ------------- | ------------- |
| 1 | Disk status | D/R/A | [R] | `diskutil` and disk overview | Storage checks | Read-only |
| 2 | Hardware info | D/R/A | [R] | `system_profiler`, CPU, RAM | Technical inventory | Read-only |
| 3 | Memory test (informational) | D/R/A | [R] | Memory status snapshot | Performance checks | Use Apple Diagnostics for deep tests |
| 4 | System info | D/R/A | [R] | `sw_vers`, `uname`, uptime | Support baseline | Read-only |
| 5 | Disk space | D/R/A | [R] | `df -h` usage report | Capacity checks | Read-only |
| 6 | Cache cleanup | R/A | [W] | Clears cache/temp paths | Routine maintenance | May invalidate active caches |
| 7 | Connectivity test | D/R/A | [R] | Ping/basic connectivity | Network troubleshooting | Read-only |
| 8 | Network info | D/R/A | [R] | Interface/network details | LAN/WiFi diagnosis | Read-only |
| 9 | Listening ports | D/R/A | [R] | Open listening services | Exposure audit | Read-only |
| 10 | System update | R/A | [W] | `softwareupdate`/package actions | Patch maintenance | Restart may be required |
| 11 | Package cleanup | R/A | [W] | Cleans package artifacts | Reduce software residue | Confirm package is unused |
| 12 | System report | D/R/A | [R] | Generates operational report | Audit closure | Read-only. Log is HTML-escaped and SHA256 is written to `*.sha256` |
| 13 | Process info | D/R/A | [R] | Active process overview | Performance checks | Read-only |
| 14 | Scheduled shutdown | R/A | [W] | Schedules shutdown via launchd/shutdown | Automation | Validate `HH:MM` format and confirm maintenance window |

## Quick Profile Guidance

- Diagnostics: use first to assess and decide interventions.
- Repair: use for confirmed incidents or planned maintenance.
- Administration: reserve for senior operators and controlled windows.

## Important Notes

- Any `[!]` option should require backup and explicit impact confirmation.
- Any `[W]` option is best executed in maintenance windows.
- If unsure, run `[R]` options first and review logs before intervening.
