# 🛠️ RENGGLI PC SOLUTIONS - Enterprise Toolbox V14
## Multi-Platform Suite (Windows | Linux | macOS)

**Professional diagnostic, repair and administration solution for IT technicians**

---

## 🌍 CHOOSE YOUR OPERATING SYSTEM

This manual covers installation and usage on **Windows, Linux and macOS**.

**Jump directly to your section:**
- 🪟 [Instructions for WINDOWS](#windows)
- 🐧 [Instructions for LINUX](#linux)
- 🍎 [Instructions for macOS](#macos)

---

<h1 id="windows">🪟 WINDOWS</h1>

## 📋 System Requirements (Windows)

| Requirement | Specification |
|------------|---------------|
| **Operating System** | Windows 10/11 (Build 1809 or higher) |
| **PowerShell** | Version 5.1 or higher (pre-installed) |
| **Privileges** | Administrator (mandatory) |
| **Disk Space** | 50 MB minimum |
| **Network** | Internet connection (for updates) |

---

## 🚀 Installation on Windows - STEP BY STEP

### Step 1: Download the tool

1. Download the complete `Herramienta-toolbox` folder
2. Extract the ZIP file anywhere (Example: `C:\Tools\`)
3. You'll see this structure:
   ```
   Herramienta-toolbox/
   ├── Windows/
   │   ├── toolbox.bat
   │   └── toolbox_corporate.bat
   ├── Linux/
   ├── Mac/
   └── Manuales/
   ```

### Step 2: Navigate to Windows folder

1. Open **File Explorer** (Windows + E)
2. Navigate to where you extracted the tool
3. Enter the **`Windows`** folder
4. You'll see the files:
   - `toolbox.bat` (full version)
   - `toolbox_corporate.bat` (corporate version without MAS)

### Step 3: Run as Administrator

🔴 **IMPORTANT**: You must run with administrator permissions

**Method 1 - Right-click (Recommended):**

1. **Right-click** on `toolbox.bat`
2. Select **"Run as administrator"**
   ```
   ┌────────────────────────┐
   │ Open                   │
   │ Edit                   │
   │ Print                  │
   │ → Run as administrator │ ← THIS OPTION
   │ Share                  │
   └────────────────────────┘
   ```
3. If **User Account Control (UAC)** appears, click **"Yes"**

**Method 2 - From CMD:**

1. Open **CMD as administrator**:
   - Press `Windows + X`
   - Select "Terminal (Admin)" or "Command Prompt (Admin)"
2. Navigate to the folder:
   ```cmd
   cd C:\path\where\you\extracted\Herramienta-toolbox\Windows
   ```
3. Run:
   ```cmd
   toolbox.bat
   ```

**Method 3 - From PowerShell:**

1. Open **PowerShell as administrator**:
   - Press `Windows + X`
   - Select "Windows PowerShell (Admin)"
2. Navigate and run:
   ```powershell
   cd C:\path\where\you\extracted\Herramienta-toolbox\Windows
   .\toolbox.bat
   ```

### Step 4: Select Execution Profile

When you run it, you'll see this screen:

```
==============================================================================================================
                        RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14
==============================================================================================================
Current Log: C:\...\Logs\Audit_2024-02-10.log

[PROFILE SELECTION]

1. DIAGNOSTICS    - Read-only, audit and queries (no modifications)
2. REPAIR         - Automated maintenance and repairs
3. ADMINISTRATION - Full access (includes formatting and conversions)

=> Select profile [1-3]:
```

**Choose your profile:**
- **1** = View information only, makes no changes
- **2** = Allows repairs and cleanup
- **3** = Full access (be careful with this)

Type the number and press **Enter**.

### Step 5: Use the Main Menu

After selecting the profile, you'll see the specific menu for that profile:

#### 🔍 If you chose DIAGNOSTICS (Profile 1):

```
==============================================================================================================
   Active Profile: [DIAGNOSTICS] - Read Only

   [ HARDWARE DIAGNOSTICS ]         [ SYSTEM INFORMATION ]           [ MONITORING ]
   1. SMART Disk Status             4. BIOS and Motherboard Info     7. Network Speed Test
   2. RAM Test (mdsched)            5. Ports/DNS Audit               8. Battery Report
   3. System Resources Info         6. Windows Update Status

   [0] EXIT WITH REPORT             [00] EXIT WITHOUT REPORT
   [99] CHANGE PROFILE
==============================================================================================================

=> Select an option:
```

**This profile only has read-only options.** It doesn't modify the system, only queries information.

#### 🔧 If you chose REPAIR (Profile 2):

```
==============================================================================================================
   Active Profile: [REPAIR] - Maintenance and Repairs

   [ DIAGNOSTICS ]                  [ SYSTEM REPAIR ]                [ NETWORK AND UPDATES ]
   1. SMART Disk Status             5. Maintenance (DISM/SFC)        9. Network & IP Reset
   2. RAM Test (mdsched)            6. Repair Windows Update        10. Speed Test
   3. BIOS & Motherboard Info       7. EMMC/Temp Cleanup            11. Update Apps (Winget)
   4. Battery Report                8. Ports/DNS Audit              12. Scheduled Shutdown

   [0] EXIT WITH REPORT             [00] EXIT WITHOUT REPORT
   [99] CHANGE PROFILE
==============================================================================================================

=> Select an option:
```

**This profile includes diagnostics + system repairs.** Can perform maintenance but not critical operations.

#### ⚠️ If you chose ADMINISTRATION (Profile 3):

```
==============================================================================================================
   Active Profile: [ADMINISTRATION] - Full Access

   [ HARDWARE DIAGNOSTICS ]         [ SYSTEM REPAIR ]                [ NETWORK & CONNECTIVITY ]
   1. SMART Disk Status             4. Maintenance (DISM/SFC)        7. Network & IP Reset
   2. BIOS & Motherboard Info       5. Repair Windows Update         8. Real Speed Test
   3. RAM Test (mdsched)            6. EMMC/Temp Cleanup             9. DNS/Ports Audit

   [ STORAGE MANAGEMENT ]           [ SOFTWARE & LICENSES ]          [ AUTOMATION ]
   10. Secure Format (Audited)      12. Update Apps (Winget)         14. Scheduled Shutdown
   11. MBR to GPT Conversion        13. Activate Windows (MAS)       15. Battery Report

   [0] EXIT WITH REPORT             [00] EXIT WITHOUT REPORT
   [99] CHANGE PROFILE
==============================================================================================================

=> Select an option:
```

**This profile has full access**, including critical operations like formatting, GPT conversion, and activation.

**To use a function:**
1. Type the **option number** you want to use
2. Press **Enter**
3. Follow the on-screen instructions
4. The tool will guide you step by step

**To change profile:**
- Type **99** and press Enter at any time
- You can choose a different profile without restarting the tool

### Step 6: Exit and View Logs

**To exit:**
- Type **0** to generate HTML report and exit
- Type **00** to exit without generating report (log + checksum are saved)

**About the HTML report:**
- Option **0** automatically generates an HTML file in the `Logs/` folder
- The report includes all system information and operation logs
- It will open automatically in your browser

---

## 📁 Where are the logs?

Logs are automatically saved in:
```
Herramienta-toolbox\Windows\Logs\
├── Audit_2024-02-10.log         (Record of all operations)
├── Report_2024-02-10.html       (Visual report)
└── battery-report.html          (If you used battery function)
```

---

## ⚠️ Troubleshooting (Windows)

### Error: "You don't have administrator privileges"
**Solution:** You must run with right-click → "Run as administrator"

### Error: "The system cannot execute the script"
**Solution:**
1. Windows may have blocked the file
2. Right-click on `toolbox.bat` → Properties
3. If you see "This file came from another computer", check "Unblock"
4. Click Apply → OK

### The window closes immediately
**Solution:** Run from CMD or PowerShell to see the error

### Color menu doesn't appear
**Solution:** Use Windows Terminal or CMD (not PowerShell ISE)

---

<h1 id="linux">🐧 LINUX</h1>

## 📋 System Requirements (Linux)

| Requirement | Specification |
|------------|---------------|
| **Supported Distributions** | Debian, Ubuntu, Fedora, RHEL, CentOS, Arch, Manjaro, OpenSUSE |
| **Bash** | Version 4.0 or higher (pre-installed) |
| **Privileges** | root or sudo (mandatory) |
| **Disk Space** | 50 MB minimum |
| **Package Manager** | apt, dnf, yum, pacman or zypper |

---

## 🚀 Installation on Linux - STEP BY STEP

### Step 1: Download or transfer the tool

**Option A - If you downloaded on Windows:**
1. Copy the `Herramienta-toolbox` folder to your Linux system
2. Use USB, shared network, or FileZilla/SCP

**Option B - Download directly on Linux:**
1. Open a terminal
2. Download to your home folder:
   ```bash
   cd ~
   # Download or extract the file here
   ```

### Step 2: Navigate to Linux folder

1. Open a **Terminal** (Ctrl + Alt + T on most distributions)
2. Navigate to the folder:
   ```bash
   cd /path/where/is/Herramienta-toolbox/Linux
   ```

   **Example:**
   ```bash
   cd ~/Downloads/Herramienta-toolbox/Linux
   ```

3. Verify you're in the right place:
   ```bash
   ls -l
   ```

   You should see:
   ```
   toolbox.sh
   toolbox_corporate.sh
   ```

### Step 3: Give execution permissions

🔴 **IMPORTANT**: Scripts need execution permissions

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

**Explanation:**
- `chmod +x` = Give execution permissions
- This is only done ONCE

### Step 4: Run with sudo

🔴 **IMPORTANT**: You must run with sudo (as root)

**For full version:**
```bash
sudo ./toolbox.sh
```

**For corporate version (without activation modules):**
```bash
sudo ./toolbox_corporate.sh
```

**What does each part mean?**
- `sudo` = Run as superuser (root)
- `./` = Run from current folder
- `toolbox.sh` = Script name

**It will ask for your password**: Type it and press Enter
(You won't see anything while typing, this is normal for security)

### Step 5: Select Execution Profile

You'll see this screen:

```
==============================================================================================================
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (LINUX)
==============================================================================================================
Current Log: /path/Logs/Audit_2024-02-10.log
Distribution: ubuntu 22.04 | Package manager: apt

[PROFILE SELECTION]

1. DIAGNOSTICS    - Read-only, audit and queries (no modifications)
2. REPAIR         - Automated maintenance and repairs
3. ADMINISTRATION - Full access (includes formatting and critical operations)

=> Select profile [1-3]:
```

**Choose your profile:**
- **1** = Diagnostics only, makes no changes
- **2** = Allows repairs and updates
- **3** = Full access (disk formatting, conversions)

Type the number and press **Enter**.

### Step 6: Use the Main Menu

You'll see a menu with **30 options** organized in categories:

```
==============================================================================================================
   [ HARDWARE DIAGNOSTICS ]         [ SYSTEM REPAIR ]                [ NETWORK & CONNECTIVITY ]
   1. SMART Disk Status             6. Verify System (fsck)          11. Network Reset
   2. Complete Hardware Info        7. Repair Package Manager        12. Speed Test
   3. RAM Memory Test               8. Deep Cleanup                  13. DNS/Ports Audit
   4. OS System Info                9. Repair Bootloader (GRUB)      14. Firewall Diagnostics
   5. Temperature & Sensors         10. Docker Cleanup               15. Live Network Monitor

   [ STORAGE MANAGEMENT ]           [ SERVICES & PROCESSES ]         [ AUTOMATION ]
   16. Secure USB Format            21. Services Management          26. Update System
   17. MBR to GPT Conversion        22. Top CPU/RAM Processes        27. Scheduled Shutdown
   18. Disk Analysis                23. View System Logs             28. Data Backup
   19. Partition Mounting           24. Users & Permissions          29. Battery Report
   20. Disk Space                   25. Real-Time Monitoring         30. Verify Integrity

   [0] EXIT WITH REPORT             [00] EXIT WITHOUT REPORT
==============================================================================================================
```

**To use a function:**
1. Type the option **number**
2. Press **Enter**
3. Follow the instructions
4. Press **Enter** to continue after each operation

### Step 7: Exit

**To exit:**
- Type **0** to generate HTML report and exit
- Type **00** to exit without generating report (log + checksum are saved)

**About the HTML report:**
- Option **0** automatically generates an HTML file
- The report includes all system information and operation logs

---

## 📁 Where are the logs? (Linux)

Logs are saved in:
```
Herramienta-toolbox/Linux/Logs/
├── Audit_2024-02-10.log           (Operations record)
└── Report_Linux_2024-02-10.html   (Visual report)
```

To view the log:
```bash
cat Logs/Audit_2024-02-10.log
```

To open the HTML report:
```bash
firefox Logs/Report_Linux_2024-02-10.html
# Or your preferred browser
```

---

## ⚠️ Troubleshooting (Linux)

### Error: "Permission denied"
**Solution:**
```bash
chmod +x toolbox.sh
sudo ./toolbox.sh
```

### Error: "No such file or directory"
**Solution:** Verify you're in the correct folder:
```bash
pwd  # Shows current path
ls   # Lists files
```

### Error: "This script requires root privileges"
**Solution:** You must use `sudo`:
```bash
sudo ./toolbox.sh
```

### Dependencies don't install automatically
**Solution:** The tool detects and automatically installs packages like:
- smartmontools (for SMART)
- lm-sensors (for temperatures)
- speedtest-cli (for speed test)

If it fails, install manually:
```bash
# Debian/Ubuntu
sudo apt install smartmontools lm-sensors speedtest-cli

# Fedora/RHEL
sudo dnf install smartmontools lm_sensors speedtest-cli

# Arch
sudo pacman -S smartmontools lm_sensors speedtest-cli
```

---

<h1 id="macos">🍎 macOS</h1>

## 📋 System Requirements (macOS)

| Requirement | Specification |
|------------|---------------|
| **Operating System** | macOS 10.14 (Mojave) or higher |
| **Shell** | Bash or Zsh (pre-installed) |
| **Privileges** | Administrator with sudo (mandatory) |
| **Disk Space** | 50 MB minimum |
| **Xcode CLI Tools** | Auto-installs if missing |
| **Homebrew** | Recommended (can auto-install) |

---

## 🚀 Installation on macOS - STEP BY STEP

### Step 1: Download the tool

1. Download the `Herramienta-toolbox` folder
2. Extract the file (double-click the .zip)
3. Move the folder to your preferred location (Example: `~/Documents/`)

### Step 2: Open Terminal

**Method 1 - Spotlight:**
1. Press `Cmd + Space`
2. Type "Terminal"
3. Press Enter

**Method 2 - Finder:**
1. Open **Finder**
2. Go to **Applications** → **Utilities**
3. Double-click **Terminal**

### Step 3: Navigate to Mac folder

In the terminal, type:

```bash
cd /path/where/is/Herramienta-toolbox/Mac
```

**Example:**
```bash
cd ~/Documents/Herramienta-toolbox/Mac
```

**Trick:** You can drag the folder into the terminal after typing `cd ` (with space).

Verify you're in the right place:
```bash
ls -l
```

You should see:
```
toolbox.sh
toolbox_corporate.sh
```

### Step 4: Give execution permissions

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

### Step 5: Allow execution in Security (First time)

🔴 **IMPORTANT FOR macOS:**

macOS blocks scripts downloaded from the internet. To allow them:

**Option A - Remove quarantine:**
```bash
xattr -d com.apple.quarantine toolbox.sh toolbox_corporate.sh
```

**Option B - If security message appears:**
1. Try to run the script:
   ```bash
   sudo ./toolbox.sh
   ```
2. If macOS blocks it, you'll see a message
3. Go to **System Preferences** → **Security & Privacy**
4. In the **General** tab, you'll see a message about the blocked script
5. Click **"Allow Anyway"**
6. Run the script again

### Step 6: Run with sudo

🔴 **IMPORTANT**: You must run with sudo

**For full version:**
```bash
sudo ./toolbox.sh
```

**For corporate version:**
```bash
sudo ./toolbox_corporate.sh
```

**It will ask for your macOS password**: Type it and press Enter
(You won't see anything while typing, this is normal)

### Step 7: Select Profile

You'll see this screen:

```
==============================================================================================================
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (macOS)
==============================================================================================================
Current Log: /path/Logs/Audit_2024-02-10.log

[PROFILE SELECTION]

1. DIAGNOSTICS    - Read-only, audit and queries
2. REPAIR         - Maintenance and repairs
3. ADMINISTRATION - Full access (critical operations)

=> Select profile [1-3]:
```

Choose the number and press Enter.

### Step 8: Use the Main Menu

The menu is similar to Linux, with 30 options adapted for macOS.

Mac-specific functions include:
- FileVault status (disk encryption)
- Gatekeeper status (app security)
- SIP status (System Integrity Protection)
- Time Machine backup
- App Store updates

**Exit options (macOS):**
- **0** = exit without report
- **00** = generate report and exit
- **01** = generate report and return to the menu
- **02** = exit without log

---

## 📁 Where are the logs? (macOS)

Logs are saved in:
```
Herramienta-toolbox/Mac/Logs/
├── Audit_2024-02-10.log
└── Report_Mac_2024-02-10.html
```

To view the log:
```bash
cat Logs/Audit_2024-02-10.log
```

To open the HTML report:
```bash
open Logs/Report_Mac_2024-02-10.html
```

---

## ⚠️ Troubleshooting (macOS)

### Error: "Operation not permitted"
**Solution:** Run with `sudo`:
```bash
sudo ./toolbox.sh
```

### Error: "command not found: brew"
**Solution:** Some functions use Homebrew. Install it:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS blocks execution
**Solution:**
```bash
xattr -d com.apple.quarantine toolbox.sh
```

Or go to **System Preferences** → **Security & Privacy** and allow the script.

### Xcode Command Line Tools not installed
**Solution:** macOS will ask you to install them automatically. If not:
```bash
xcode-select --install
```

---

## 🔒 PROFILE SYSTEM (All Systems)

### 1️⃣ DIAGNOSTICS (Read-Only)
- ✅ View hardware information
- ✅ Status and queries
- ❌ Does NOT make system changes

**Ideal for:**
- Audits
- Preventive checks
- When you DON'T have authorization to make changes

### 2️⃣ REPAIR (Maintenance)
- ✅ Everything from DIAGNOSTICS +
- ✅ Temporary file cleanup
- ✅ Automatic repairs
- ✅ System updates
- ❌ Does NOT allow formatting or conversions

**Ideal for:**
- Daily technical support
- Routine maintenance
- Solving common problems

### 3️⃣ ADMINISTRATION (Full Access)
- ✅ EVERYTHING (DIAGNOSTICS + REPAIR) +
- ✅ Disk formatting
- ✅ MBR/GPT conversions
- ✅ Critical operations

⚠️ **CAUTION:** This profile can delete data

**Ideal for:**
- Senior technicians
- New equipment preparation
- Authorized critical operations

---

## 📊 FEATURE COMPARISON

| Feature | Windows | Linux | macOS |
|---------|---------|-------|-------|
| SMART disk status | ✅ | ✅ | ✅ |
| Hardware Info | ✅ | ✅ | ✅ |
| RAM Test | ✅ | ✅ | ⚠️ |
| Repair System | ✅ DISM/SFC | ✅ fsck | ✅ diskutil |
| Updates | ✅ Winget | ✅ apt/dnf/pacman | ✅ brew/softwareupdate |
| Network Reset | ✅ | ✅ | ✅ |
| Speed Test | ✅ | ✅ | ✅ |
| Disk Formatting | ✅ | ✅ | ✅ |
| MBR → GPT | ✅ | ✅ | ❌ |
| Docker | ❌ | ✅ | ✅ |
| Firewall | ✅ | ✅ UFW/firewalld | ✅ |
| Battery Report | ✅ | ✅ | ✅ |

---

## 📞 SUPPORT

Problems or questions?
- 📧 Email: soporte@renggli-solutions.com
- 📚 Complete documentation in `Manuales/` folder

---

## 🎯 VERSION

**Toolbox V14 Multi-Platform**
- Windows: 15 modules
- Linux: 30 modules
- macOS: 30 modules

**© 2024 RENGGLI PC SOLUTIONS**
