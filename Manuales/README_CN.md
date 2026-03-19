<!-- markdownlint-disable MD022 MD026 MD031 MD032 MD033 MD036 MD040 MD060 -->

# 🛠️ RENGGLI PC SOLUTIONS - 企业工具箱 V14
## 多平台套件 (Windows | Linux | macOS)

**为IT技术人员提供的专业诊断、修复和管理解决方案**

---

## 🌍 选择您的操作系统

本手册涵盖 **Windows、Linux 和 macOS** 的安装和使用。

**直接跳转到您的部分:**
- 🪟 [Windows 说明](#windows)
- 🐧 [Linux 说明](#linux)
- 🍎 [macOS 说明](#macos)

---

<h1 id="windows">🪟 WINDOWS</h1>

## 📋 系统要求 (Windows)

| 要求 | 规格 |
|------|------|
| **操作系统** | Windows 10/11 (构建版本 1809 或更高) |
| **PowerShell** | 版本 5.1 或更高 (预装) |
| **权限** | 管理员 (必需) |
| **磁盘空间** | 最少 50 MB |
| **网络** | 互联网连接 (用于更新) |

---

## 🚀 Windows 安装 - 分步说明

### 步骤 1: 下载工具

1. 下载完整的 `Herramienta-toolbox` 文件夹
2. 将 ZIP 文件解压到任意位置 (例如: `C:\Tools\`)
3. 您将看到此结构:
   ```
   Herramienta-toolbox/
   ├── Windows/
   │   ├── toolbox.bat
   │   └── toolbox_corporate.bat
   ├── Linux/
   ├── Mac/
   └── Manuales/
   ```

### 步骤 2: 导航到 Windows 文件夹

1. 打开 **文件资源管理器** (Windows + E)
2. 导航到您解压工具的位置
3. 进入 **`Windows`** 文件夹
4. 您将看到以下文件:
   - `toolbox.bat` (完整版本)
   - `toolbox_corporate.bat` (企业版本，不含 MAS)

### 步骤 3: 以管理员身份运行

🔴 **重要**: 必须以管理员权限运行

**方法 1 - 右键单击 (推荐):**

1. **右键单击** `toolbox.bat`
2. 选择 **"以管理员身份运行"**
   ```
   ┌────────────────────────┐
   │ 打开                   │
   │ 编辑                   │
   │ 打印                   │
   │ → 以管理员身份运行      │ ← 此选项
   │ 共享                   │
   └────────────────────────┘
   ```
3. 如果出现 **用户账户控制 (UAC)** 提示，点击 **"是"**

**方法 2 - 从 CMD:**

1. 以管理员身份打开 **CMD**:
   - 按 `Windows + X`
   - 选择 "终端 (管理员)" 或 "命令提示符 (管理员)"
2. 导航到文件夹:
   ```cmd
   cd C:\您解压的路径\Herramienta-toolbox\Windows
   ```
3. 运行:
   ```cmd
   toolbox.bat
   ```

**方法 3 - 从 PowerShell:**

1. 以管理员身份打开 **PowerShell**:
   - 按 `Windows + X`
   - 选择 "Windows PowerShell (管理员)"
2. 导航并运行:
   ```powershell
   cd C:\您解压的路径\Herramienta-toolbox\Windows
   .\toolbox.bat
   ```

### 步骤 4: 选择执行配置文件

运行时，您将看到此屏幕:

```
==============================================================================================================
                        RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14
==============================================================================================================
当前日志: C:\...\Logs\Audit_2024-02-10.log

[配置文件选择]

1. 诊断       - 只读、审计和查询 (无修改)
2. 修复       - 自动化维护和修复
3. 管理       - 完全访问 (包括格式化和转换)

=> 选择配置文件 [1-3]:
```

**选择您的配置文件:**
- **1** = 仅查看信息，不做更改
- **2** = 允许修复和清理
- **3** = 完全访问 (小心使用)

输入数字并按 **Enter**。

### 步骤 5: 使用主菜单

选择配置文件后，您将看到该配置文件的特定菜单：

#### 🔍 如果您选择了诊断 (配置文件 1):

```
==============================================================================================================
   活动配置文件: [诊断] - 只读

   此菜单仅供查询，不会修改系统。
   适合审核硬件、资源、网络和 Windows Update 状态。
   注意：电池报告仅适用于笔记本。
   图例: [R] 只读  [W] 写入/修改系统  [!] 关键/不可逆

   [ 诊断基础 ]
   1. [R] RAM 测试 (mdsched)
   2. [R] 系统资源信息
   3. [R] BIOS 和主板信息
   4. [R] Windows 更新状态
   5. [R] 端口/DNS 审计
   6. [R] 网络速度测试
   7. [R] 电池报告

   [ 高级分析 - 只读 ]
   8. [R] 关键事件 (系统)
   9. [R] BSOD 分析 (Minidump)
   10. [R] 进程取证审计
   11. [R] RAID/存储状态

   [0] 生成报告并退出              [00] 退出不生成报告且不保留日志
   [99] 更改配置文件
==============================================================================================================

=> 选择一个选项:
```

**此配置文件只有只读选项。** 不修改系统，仅查询信息。

#### 🔧 如果您选择了修复 (配置文件 2):

```
==============================================================================================================
   活动配置文件: [修复] - 维护和修复

   包含诊断与会修改系统的任务。
   建议用于维护、清理与引导式修复。
   注意：电池报告仅适用于笔记本。
   图例: [R] 只读  [W] 写入/修改系统  [!] 关键/不可逆

   [ 修复与维护 ]
   1. [R] RAM 测试 (mdsched)
   2. [R] 系统资源信息
   3. [R] BIOS 和主板信息
   4. [W] 维护 (DISM/SFC)
   5. [W] 修复 Windows Update
   6. [W] EMMC/临时清理
   7. [W] 网络和 IP 重置
   8. [R] 速度测试
   9. [R] 端口/DNS 审计
   10. [W] 计划关机
   11. [W] 更新应用 (Winget)
   12. [R] 电池报告
   13. [W] 驱动备份（写入磁盘）

   [ 高级分析 - 只读 ]
   14. [R] 关键事件
   15. [R] BSOD 分析
   16. [R] 进程取证审计
   17. [R] RAID/存储状态

   [0] 生成报告并退出              [00] 退出不生成报告且不保留日志
   [99] 更改配置文件
==============================================================================================================

=> 选择一个选项:
```

**此配置文件包括诊断 + 系统修复。** 可以执行维护但不能执行关键操作。

#### ⚠️ 如果您选择了管理 (配置文件 3):

```
==============================================================================================================
   活动配置文件: [管理] - 完全访问

   完整访问。包含不可逆和关键变更操作。
   仅在你充分理解每项操作影响时使用该配置文件。
   注意：电池报告仅适用于笔记本。
   图例: [R] 只读  [W] 写入/修改系统  [!] 关键/不可逆

   [ 管理操作 ]
   1. [R] BIOS 和主板信息
   2. [R] RAM 测试 (mdsched)
   3. [R] 系统资源信息
   4. [W] 维护 (DISM/SFC)
   5. [W] 修复 Windows Update
   6. [W] EMMC/临时清理
   7. [W] 网络和 IP 重置
   8. [R] 真实速度测试
   9. [R] 端口/DNS 审计
   10. [!] 安全格式化 (已审计)
   11. [!] MBR 到 GPT 转换
   12. [W] 更新应用 (Winget)
   13. [W] 主激活 (MAS)
   14. [W] 计划关机
   15. [R] 电池报告
   16. [W] 驱动备份（写入磁盘）

   [ 高级分析 - 只读 ]
   17. [R] 关键事件
   18. [R] BSOD 分析
   19. [R] 进程取证审计
   20. [R] RAID/存储状态
   21. [W] 高安全配置（Blindaje V1 集成）

   [0] 生成报告并退出              [00] 退出不生成报告且不保留日志
   [99] 更改配置文件
==============================================================================================================

=> 选择一个选项:
```

**此配置文件具有完全访问权限**，包括格式化/分区转换等关键操作，以及 21 号 Blindaje V1。

> 说明：在 `toolbox_corporate.bat` 中，13 号选项显示为 `[模块 13 已移除]`（合规要求）。

**使用功能:**
1. 输入您想使用的 **选项编号**
2. 按 **Enter**
3. 按照屏幕上的说明操作
4. 工具将逐步引导您

**更改配置文件:**
- 随时输入 **99** 并按 Enter
- 您可以选择不同的配置文件而无需重新启动工具

### CLI 参数运行（可选）

也可以通过参数直接预选配置文件和模块：

```cmd
toolbox.bat /perfil:X /mod:Y
```

- `X` = 配置文件（`1` 诊断，`2` 修复，`3` 管理）
- `Y` = 该配置文件下的模块编号

快速示例（完整版 `toolbox.bat`）：

- 配置文件 1（诊断）：
  - `toolbox.bat /perfil:1 /mod:1`（RAM 测试）
  - `toolbox.bat /perfil:1 /mod:4`（Windows Update 状态）
  - `toolbox.bat /perfil:1 /mod:11`（RAID/存储状态）
- 配置文件 2（修复）：
  - `toolbox.bat /perfil:2 /mod:4`（DISM/SFC）
  - `toolbox.bat /perfil:2 /mod:5`（修复 Windows Update）
  - `toolbox.bat /perfil:2 /mod:10`（计划关机）
- 配置文件 3（管理）：
  - `toolbox.bat /perfil:3 /mod:10`（安全格式化）
  - `toolbox.bat /perfil:3 /mod:11`（MBR 转 GPT）
  - `toolbox.bat /perfil:3 /mod:21`（高安全配置）

快速示例（`toolbox_corporate.bat`）：

- `toolbox_corporate.bat /perfil:1 /mod:1`（SMART）
- `toolbox_corporate.bat /perfil:2 /mod:6`（修复 Windows Update）
- `toolbox_corporate.bat /perfil:3 /mod:10`（安全格式化）

说明：
- 若 `perfil/mod` 与当前配置文件不匹配，会被阻止执行并写入日志。
- 关键模块仍会保留安全确认步骤。

### 步骤 6: 完成并查看日志

**退出:**
- 输入 **0** 生成 HTML 报告并退出
- 输入 **00** 退出不生成报告且不保留日志

**关于 HTML 报告:**
- 选项 **0** 会自动在 `Logs/` 文件夹中生成 HTML 文件
- 报告包括所有系统信息和操作日志
- 将自动在浏览器中打开

---

## 📁 日志在哪里？

日志自动保存在:
```
Windows/Logs/
├── Audit_2024-02-10.log         (所有操作的记录)
├── Report_2024-02-10.html       (可视化报告)
└── battery-report.html          (如果使用了电池功能)
```

---

## ⚠️ 故障排除 (Windows)

### 错误: "没有管理员权限"
**解决方案:** 必须右键单击 → "以管理员身份运行"

### 错误: "系统无法执行脚本"
**解决方案:**
1. Windows 可能已阻止该文件
2. 右键单击 `toolbox.bat` → 属性
3. 如果看到 "此文件来自另一台计算机"，勾选 "解除阻止"
4. 点击应用 → 确定

### 窗口立即关闭
**解决方案:** 从 CMD 或 PowerShell 运行以查看错误

### 彩色菜单未显示
**解决方案:** 使用 Windows 终端或 CMD (不是 PowerShell ISE)

### Windows 下 `bash -n` 校验失败
**原因:** `bash.exe` 依赖 WSL 以及已安装/已启用的 Linux 发行版。

**含义:** 如果 WSL 没有可用发行版，即使 `.sh` 脚本本身正确，`bash -n` 也会失败。

**快速处理:**
1. 安装/启用 WSL，并安装发行版（如 Ubuntu）。
2. 在 Linux/WSL 中重新执行语法校验：
   - `bash -n Linux/toolbox.sh`
   - `bash -n Linux/toolbox_corporate.sh`
   - `bash -n Mac/toolbox.sh`
   - `bash -n Mac/toolbox_corporate.sh`

### 课堂临时文件流程（选项 21）

在 **配置文件 3（管理）** 中，**选项 21（高安全配置）** 现已包含：

- 在 `Trabajos Alumnos\SECUNDARIA` 与 `Trabajos Alumnos\PRIMARIA` 的安全手动复核/清理
- 本地每日自动清理任务创建
- 本地自动清理任务停用/删除
- 批量部署指南（域/GPO 与非域远程下发）

安全临时文件模式仅限 `~$*`、`.tmp`、`.temp`，避免误删学生真实项目文件。

---

<h1 id="linux">🐧 LINUX</h1>

## 📋 系统要求 (Linux)

| 要求 | 规格 |
|------|------|
| **支持的发行版** | Debian, Ubuntu, Fedora, RHEL, CentOS, Arch, Manjaro, OpenSUSE |
| **Bash** | 版本 4.0 或更高 (预装) |
| **权限** | root 或 sudo (必需) |
| **磁盘空间** | 最少 50 MB |
| **包管理器** | apt, dnf, yum, pacman 或 zypper |

---

## 🚀 Linux 安装 - 分步说明

### 步骤 1: 下载或传输工具

**选项 A - 如果在 Windows 上下载:**
1. 将 `Herramienta-toolbox` 文件夹复制到您的 Linux 系统
2. 使用 USB、共享网络或 FileZilla/SCP

**选项 B - 直接在 Linux 上下载:**
1. 打开终端
2. 下载到您的主文件夹:
   ```bash
   cd ~
   # 在此处下载或解压文件
   ```

### 步骤 2: 导航到 Linux 文件夹

1. 打开 **终端** (大多数发行版上按 Ctrl + Alt + T)
2. 导航到文件夹:
   ```bash
   cd /文件所在路径/Herramienta-toolbox/Linux
   ```

   **示例:**
   ```bash
   cd ~/Downloads/Herramienta-toolbox/Linux
   ```

3. 验证您在正确的位置:
   ```bash
   ls -l
   ```

   您应该看到:
   ```
   toolbox.sh
   toolbox_corporate.sh
   ```

### 步骤 3: 授予执行权限

🔴 **重要**: 脚本需要执行权限

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

**说明:**
- `chmod +x` = 授予执行权限
- 这只需做一次

### 步骤 4: 用 sudo 运行

🔴 **重要**: 必须以 sudo (作为 root) 运行

**完整版本:**
```bash
sudo ./toolbox.sh
```

**企业版本 (无激活模块):**
```bash
sudo ./toolbox_corporate.sh
```

**每部分的含义:**
- `sudo` = 以超级用户 (root) 运行
- `./` = 从当前文件夹运行
- `toolbox.sh` = 脚本名称

**会要求您输入密码**: 输入并按 Enter
(输入时看不到任何内容，这是正常的安全特性)

### 步骤 5: 选择执行配置文件

您将看到此屏幕:

```
==============================================================================================================
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (LINUX)
==============================================================================================================
当前日志: /路径/Logs/Audit_2024-02-10.log
发行版: ubuntu 22.04 | 包管理器: apt

[配置文件选择]

1. 诊断       - 只读、审计和查询 (无修改)
2. 修复       - 自动化维护和修复
3. 管理       - 完全访问 (包括格式化和关键操作)

=> 选择配置文件 [1-3]:
```

**选择您的配置文件:**
- **1** = 仅诊断，不做更改
- **2** = 允许修复和更新
- **3** = 完全访问 (磁盘格式化、转换)

输入数字并按 **Enter**。

### 步骤 6: 使用主菜单

您将看到包含 **30 个选项** 的菜单，按类别组织:

```
==============================================================================================================
   [ 硬件诊断 ]                 [ 系统修复 ]                 [ 网络和连接性 ]
   1. SMART 磁盘状态            6. 验证系统 (fsck)           11. 网络重置
   2. 完整硬件信息              7. 修复包管理器              12. 速度测试
   3. RAM 内存测试              8. 深度清理                  13. DNS/端口审计
   4. 操作系统信息              9. 修复引导加载程序 (GRUB)  14. 防火墙诊断
   5. 温度和传感器              10. Docker 清理              15. 实时网络监控

   [ 存储管理 ]                 [ 服务和进程 ]               [ 自动化 ]
   16. 安全 USB 格式化          21. 服务管理                 26. 更新系统
   17. MBR 到 GPT 转换          22. CPU/RAM 进程排名         27. 计划关机
   18. 磁盘分析                 23. 查看系统日志             28. 数据备份
   19. 分区挂载                 24. 用户和权限               29. 电池报告
   20. 磁盘空间                 25. 实时监控                 30. 验证完整性

   [0] 生成报告并退出           [00] 退出不生成报告且不保留日志
==============================================================================================================
```

**使用功能:**
1. 输入选项 **编号**
2. 按 **Enter**
3. 按照说明操作
4. 每次操作后按 **Enter** 继续

### 步骤 7: 完成

**退出:**
- 输入 **0** 生成 HTML 报告并退出
- 输入 **00** 退出不生成报告且不保留日志

**关于 HTML 报告:**
- 选项 **0** 会自动生成 HTML 文件
- 报告包括所有系统信息和操作日志

---

## 📁 日志在哪里？ (Linux)

日志保存在:
```
Linux/Logs/
├── Audit_2024-02-10.log           (操作记录)
└── Report_Linux_2024-02-10.html   (可视化报告)
```

查看日志:
```bash
cat Logs/Audit_2024-02-10.log
```

打开 HTML 报告:
```bash
firefox Logs/Report_Linux_2024-02-10.html
# 或您喜欢的浏览器
```

---

## ⚠️ 故障排除 (Linux)

### 错误: "Permission denied"
**解决方案:**
```bash
chmod +x toolbox.sh
sudo ./toolbox.sh
```

### 错误: "No such file or directory"
**解决方案:** 验证您在正确的文件夹中:
```bash
pwd  # 显示当前路径
ls   # 列出文件
```

### 错误: "This script requires root privileges"
**解决方案:** 必须使用 `sudo`:
```bash
sudo ./toolbox.sh
```

### 依赖项未自动安装
**解决方案:** 工具会自动检测并安装包，如:
- smartmontools (用于 SMART)
- lm-sensors (用于温度)
- speedtest-cli (用于速度测试)

如果失败，手动安装:
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

## 📋 系统要求 (macOS)

| 要求 | 规格 |
|------|------|
| **操作系统** | macOS 10.14 (Mojave) 或更高 |
| **Shell** | Bash 或 Zsh (预装) |
| **权限** | 具有 sudo 的管理员 (必需) |
| **磁盘空间** | 最少 50 MB |
| **Xcode CLI Tools** | 如果缺少则自动安装 |
| **Homebrew** | 推荐 (可自动安装) |

---

## 🚀 macOS 安装 - 分步说明

### 步骤 1: 下载工具 (macOS)

1. 下载 `Herramienta-toolbox` 文件夹
2. 解压文件 (双击 .zip 文件)
3. 将文件夹移动到您喜欢的位置 (例如: `~/Documents/`)

### 步骤 2: 打开终端

**方法 1 - Spotlight:**
1. 按 `Cmd + 空格`
2. 输入 "Terminal"
3. 按 Enter

**方法 2 - Finder:**
1. 打开 **Finder**
2. 转到 **应用程序** → **实用工具**
3. 双击 **终端**

### 步骤 3: 导航到 Mac 文件夹

在终端中，输入:

```bash
cd /文件所在路径/Herramienta-toolbox/Mac
```

**示例:**
```bash
cd ~/Documents/Herramienta-toolbox/Mac
```

**技巧:** 在输入 `cd` 后再输入一个空格，然后可以将文件夹拖到终端中。

验证您在正确的位置:
```bash
ls -l
```

您应该看到:
```
toolbox.sh
toolbox_corporate.sh
```

### 步骤 4: 授予执行权限

```bash
chmod +x toolbox.sh toolbox_corporate.sh
```

### 步骤 5: 允许在安全性中执行 (首次)

🔴 **macOS 重要提示:**

macOS 会阻止从互联网下载的脚本。要允许它们:

**选项 A - 删除隔离:**
```bash
xattr -d com.apple.quarantine toolbox.sh toolbox_corporate.sh
```

**选项 B - 如果出现安全消息:**
1. 尝试运行脚本:
   ```bash
   sudo ./toolbox.sh
   ```
2. 如果 macOS 阻止它，您将看到一条消息
3. 转到 **系统偏好设置** → **安全性与隐私**
4. 在 **通用** 选项卡中，您将看到关于被阻止脚本的消息
5. 点击 **"仍然允许"**
6. 再次运行脚本

### 步骤 6: 用 sudo 运行

🔴 **重要**: 必须以 sudo 运行

**完整版本:**
```bash
sudo ./toolbox.sh
```

**企业版本:**
```bash
sudo ./toolbox_corporate.sh
```

**会要求您输入 macOS 密码**: 输入并按 Enter
(输入时看不到任何内容，这是正常的)

### 步骤 7: 选择配置文件

您将看到此屏幕:

```
==============================================================================================================
                     RENGGLI PC SOLUTIONS - SUITE ENTERPRISE V14 (macOS)
==============================================================================================================
当前日志: /路径/Logs/Audit_2024-02-10.log

[配置文件选择]

1. 诊断       - 只读、审计和查询
2. 修复       - 维护和修复
3. 管理       - 完全访问 (关键操作)

=> 选择配置文件 [1-3]:
```

选择数字并按 Enter。

### 步骤 8: 使用主菜单

macOS 菜单当前包含 14 个选项，按配置文件组织。

macOS 核心功能包括:
- 硬件、资源与进程诊断
- 磁盘与文件系统校验
- 网络诊断与重置
- 系统更新与清理
- 定时关机与系统报告

**退出选项 (macOS):**
- **0** = 生成报告并退出
- **00** = 退出不生成报告且不保留日志

---

## 📁 日志在哪里？ (macOS)

日志保存在:
```
Mac/Logs/
├── Audit_2024-02-10.log
└── Report_Mac_2024-02-10.html
```

查看日志:
```bash
cat Logs/Audit_2024-02-10.log
```

打开 HTML 报告:
```bash
open Logs/Report_Mac_2024-02-10.html
```

---

## ⚠️ 故障排除 (macOS)

### 错误: "Operation not permitted"
**解决方案:** 以 `sudo` 运行:
```bash
sudo ./toolbox.sh
```

### 错误: "command not found: brew"
**解决方案:** 某些功能使用 Homebrew。安装它:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### macOS 阻止执行
**解决方案:**
```bash
xattr -d com.apple.quarantine toolbox.sh
```

或转到 **系统偏好设置** → **安全性与隐私** 并允许脚本。

### 未安装 Xcode 命令行工具
**解决方案:** macOS 将自动要求您安装它们。如果没有:
```bash
xcode-select --install
```

---

## 🔒 配置文件系统 (所有系统)

### 1️⃣ 诊断 (只读)
- ✅ 查看硬件信息
- ✅ 状态和查询
- ❌ 不对系统进行更改

**理想用于:**
- 审计
- 预防性检查
- 当您没有授权进行更改时

### 2️⃣ 修复 (维护)
- ✅ 诊断中的所有内容 +
- ✅ 临时文件清理
- ✅ 自动修复
- ✅ 系统更新
- ❌ 不允许格式化或转换

**理想用于:**
- 日常技术支持
- 常规维护
- 解决常见问题

### 3️⃣ 管理 (完全访问)
- ✅ 所有内容 (诊断 + 修复) +
- ✅ 磁盘格式化
- ✅ MBR/GPT 转换
- ✅ 关键操作

⚠️ **注意:** 此配置文件可以删除数据

**理想用于:**
- 高级技术人员
- 新设备准备
- 授权的关键操作

---

## 📊 功能比较

| 功能 | Windows | Linux | macOS |
|------|---------|-------|-------|
| SMART 磁盘状态 | ✅ | ✅ | ✅ |
| 硬件信息 | ✅ | ✅ | ✅ |
| RAM 测试 | ✅ | ✅ | ⚠️ |
| 修复系统 | ✅ DISM/SFC | ✅ fsck | ✅ diskutil |
| 更新 | ✅ Winget | ✅ apt/dnf/pacman | ✅ brew/softwareupdate |
| 网络重置 | ✅ | ✅ | ✅ |
| 速度测试 | ✅ | ✅ | ✅ |
| 磁盘格式化 | ✅ | ✅ | ✅ |
| MBR → GPT | ✅ | ✅ | ❌ |
| Docker | ❌ | ✅ | ✅ |
| 防火墙 | ✅ | ✅ UFW/firewalld | ✅ |
| 电池报告 | ✅ | ✅ | ✅ |

---

## 🆕 Windows 新增模块 (V14)

以下模块已添加到 `Windows/toolbox.bat` 和 `Windows/toolbox_corporate.bat`：

- 系统关键事件分析（磁盘/电源）
- BSOD 分析（Minidump + Event ID 1001）
- 进程取证审计（临时路径 + 数字签名）
- RAID/Storage 状态（Storage cmdlets + WMI 回退）
- 驱动备份（DISM export-driver）
- 高安全配置（Blindaje V1 集成：持久 T: 映射、严格 ACL、离线 Explorer 策略、日常文件夹重定向，以及内置验证/回退）

说明：

- 诊断类模块为只读。
- `驱动备份` 会写入磁盘并需要可用空间。
- `高安全配置` 会修改注册表、ACL 和学生 hive。执行“撤销”后请重启，并在 `C:\` 手动确认 `Trabajos Alumnos` 是否已完全删除；若文件被占用可能仍会残留。
- 该模块仅适用于 Windows。Linux 与 macOS 使用各自模块集合，不包含等效的 Blindaje 模块。

---

## 👨‍💻 开发者指南：如何新增模块

本节说明如何在 **Windows、Linux、macOS** 上以安全且一致的方式扩展 Toolbox。

### 1) 建议具备的知识

新增模块前，建议具备以下能力：

- Windows：Batch (`.bat`) 与管理命令（`DISM`、`SFC`、`PowerShell`、`netsh`、`wmic` 替代方案）。
- Linux/macOS：Bash、权限模型（`sudo`、`root`）、系统工具（`systemctl`、`journalctl`、`ip`、`diskutil`、`launchctl`）。
- 运维安全：理解破坏性操作（磁盘、网络、用户、关机）的影响。
- 审计能力：保持清晰、可追踪、带时间戳的日志。
- Git 流程：分支、小粒度提交、本地验证、Pull Request。

### 2) 各系统应修改的位置

为保证普通版/企业版一致性：

- Windows 普通版：`Windows/toolbox.bat`
- Windows 企业版：`Windows/toolbox_corporate.bat`
- Linux 普通版：`Linux/toolbox.sh`
- Linux 企业版：`Linux/toolbox_corporate.sh`
- macOS 普通版：`Mac/toolbox.sh`
- macOS 企业版：`Mac/toolbox_corporate.sh`

通用规则：

- 在正确的权限档位菜单中添加选项（`DIAGNOSTICS`、`REPAIR`、`ADMINISTRATION`）。
- 将菜单选项路由到独立模块（Windows 使用 `MOD_...`，Linux/macOS 使用 `mod_...`）。
- 模块保持独立代码块/函数。
- 执行后必须稳定返回菜单。

### 3) 新模块最小结构

一个新模块至少应包含：

- 清晰的界面标题（说明模块作用）。
- 前置校验（权限、命令存在、输入合法）。
- 敏感操作的二次确认。
- 主逻辑执行与可控错误处理。
- 带时间戳的日志记录。
- 干净返回菜单。

命名约定：

- 变量：`UPPER_SNAKE_CASE`。
- 模块：`MOD_`（Batch）或 `mod_`（Bash）。
- 校验函数：`CHECK_` / `check_`。

### 4) 必须遵守的安全要求

如果模块会修改系统/磁盘/网络，必须满足：

- 未经明确阻断逻辑，不得操作系统盘/系统分区。
- 不得在 Toolbox 管辖范围外使用宽泛通配删除。
- 不得影响非 Toolbox 管理的计划任务（cron/launchd/Task Scheduler）。
- 保留管理员/root 检查。
- 在不可逆操作前显示明确警告。

### 5) 平台差异注意事项

- Windows：
  - 命令需兼容受支持的 Windows 版本。
  - 调用外部工具前先校验存在性。
  - 保持报告与校验和行为一致。

- Linux：
  - 兼容不同发行版（apt、dnf、yum、pacman、zypper）。
  - 避免硬编码路径/服务假设。
  - 管道对非关键失败要有韧性。

- macOS：
  - 校验 Intel 与 Apple Silicon 兼容性。
  - 不应假设非默认依赖已安装。
  - 使用 `launchd` 时仅操作 Toolbox 自有标识。

### 6) 发布前快速检查清单

1. 模块只出现在正确的档位菜单中。
2. 普通版与企业版行为正确（或企业版有明确禁用提示）。
3. 包含校验、确认与日志。
4. 不破坏退出选项（`0` 与 `00`）及菜单返回。
5. 不引入不安全的清理/关机/磁盘模式。
6. 已在目标系统完成基础手动验证。

### 7) 必须同步更新的文档

当行为变更或新增模块时，更新：

- `HISTORIAL_DE_CAMBIOS.md`
- `Manuales/README_ES.md`
- `Manuales/README_EN.md`
- `Manuales/README_CN.md`

并遵循以下贡献流程文件：

- `CONTRIBUTING.md`

### 8) 推荐实施流程（摘要）

1. 定义模块目标与所属档位。
2. 先在目标系统普通版脚本实现。
3. 在企业版脚本中复制/适配。
4. 覆盖成功与失败路径测试。
5. 验证日志、退出行为与菜单回跳。
6. 更新文档与变更历史。
7. 提交 PR，说明范围、风险与验证结果。

---

## 📘 菜单与选项详细目录

若要了解**每个选项**（功能、用途、使用场景与注意事项），请查看：

- `Manuales/CATALOGO_OPCIONES_CN.md`

覆盖范围包括：

- Windows（普通版与企业版）
- Linux（普通版与企业版）
- macOS（普通版与企业版）
- 配置档位 `DIAGNOSTICO`、`REPARACION`、`ADMINISTRACION`
- 风险标签 `[R]`、`[W]`、`[!]`

### 稳健性说明（更新 16）

- Windows、Linux、macOS 的定时关机输入已统一校验为 `HH:MM` 格式。
- HTML 报告在写入日志前会转义特殊字符（`&`、`<`、`>`），避免渲染异常。
- SHA256 校验和改为写入独立 `*.sha256` 文件，避免修改日志后导致哈希失效。

---

## 📞 支持

有问题或疑问？
- 📧 电子邮件: [soporte@renggli-solutions.com](mailto:soporte@renggli-solutions.com)
- 📚 `Manuales/` 文件夹中的完整文档

---

## 🎯 版本

**工具箱 V14 多平台**
- Windows: 21 个模块
- Linux: 30 个模块
- macOS: 14 个模块

**© 2024 RENGGLI PC SOLUTIONS**
