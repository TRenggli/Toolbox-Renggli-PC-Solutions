# Toolbox V15 — 文档（简体中文）

> Renggli PC Solution — Enterprise Toolbox V15
> 混合跨平台诊断、修复与牙齿临床管理套件。

[README (Español)](./V15_README_ES.md) · [README (English)](./V15_README_EN.md) · [根目录 README](../README.md)

---

## 1. V15 重新设计概览

Toolbox V15 是对 V14 套件的全面重写。它放弃了纯脚本模型
（`.bat`/`.ps1`/`.sh`），改为围绕 **.NET 10** 核心引擎、声明式 **JSON 清单**
模块目录以及面向生产环境的服务化部署架构。

设计支柱：

- **共享内核（`ToolboxCore`）** 与操作系统无关，提供 Windows、Linux 与 macOS 的
  平台抽象。
- **因果引擎**：一次 triage 不仅仅是执行检查，它将各 `Finding` 关联，生成
  `HealthScore` 和建议。
- **强制清单**：任何模块都必须有签名 manifest，声明其风险、权限、支持的 OS、
  输出 schema 与回滚策略，否则不予执行。
- **可部署服务**：运营 API、隔离的临床服务与 Web 面板，由 Docker Compose 编排。
- **远程代理**：可入网、发送心跳并执行服务端排队的作业的轻量进程。
- **牙科领域（`artec`）**：面向 CAD/CAM 流程与牙科实验室生产管理的新领域，
  带临床可追溯性。

V15 在迁移期间通过 *legacy bridge* 与 V14 脚本共存。

---

## 2. 架构

```
                        +--------------------------+
                        |        ToolboxCLI        |  (dotnet run，交互式 CLI)
                        +------------+-------------+
                                     |
                                     v
                        +--------------------------+
                        |        ToolboxCore       |  (引擎、清单、因果分析)
                        +---+----------+-----------+
                            |          |
       +--------------------+          +--------------------+
       | ToolboxAgent       |          | ToolboxServer     |
       | (入网、心跳、       |          |  + ToolboxApi     |
       |  作业轮询)          |          |  + ToolboxClinical|
       +---------+----------+          +---+----------+---+
                 |                          |          |
                 |  mTLS / API Key           |          | 隔离网络
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

| 组件                    | 职责                                                                                  | 技术栈                                 |
|------------------------|---------------------------------------------------------------------------------------|----------------------------------------|
| `ToolboxCLI`           | 命令行接口：triage、symptom、catalog、run、report、agent、artec。                      | .NET 10，`System.CommandLine`           |
| `ToolboxCore`          | 因果引擎、模块注册、运行器、健康分计算、OS 抽象、报告导出。                            | .NET 10（共享库）                       |
| `ToolboxAgent`         | 部署在端点的代理。入网、心跳、作业轮询、远程执行。                                     | .NET 10，`HttpClient`                   |
| `ToolboxServer.Api`    | 运营 API：代理、模块、作业、triage、审计、备份。使用 JWT + ApiKey 认证。              | ASP.NET Core 10，PostgreSQL             |
| `ToolboxServer.Clinical` | 隔离的临床服务：记录、生产、附件、保留期、带 MFA 的审计。                            | ASP.NET Core 10，PostgreSQL，MinIO      |
| `ToolboxPanel`         | 管理 Web 面板。                                                                        | Vite + React                            |
| `docker-compose.yml`   | 编排：Caddy 代理、api、db-operational、临床服务、临床库、存储、面板。                  | Docker Compose                          |

隔离的网络：

- `operational-net`：api、db-operational、面板、代理。
- `clinical-net`：临床服务、临床库、临床存储。

临床服务 **不** 与运营 API 共享网络；Caddy 是唯一将 `/clinical/*` 路由发布出去
的组件。

---

## 3. 安装

### 依赖

- **.NET 10 SDK**（编译 / `dotnet run` 必需）。
- 服务端部署：支持 **Compose v2** 的 **Docker**。
- 代理：已发布的自包含二进制，覆盖 Win x64、Linux x64、macOS。
- PostgreSQL 16（Compose 栈自带）。
- 对标记为 `admin`/`root` 的模块，需管理员/root 权限。

### 从源码构建

```bash
git clone <repo>
cd Toolbox-Renggli-PC-Solutions
dotnet build src/ToolboxV15/ToolboxV15.slnx -c Release
```

### 用 `dotnet run` 运行

```bash
dotnet run --project src/ToolboxV15/ToolboxCLI -- triage --area system --guided
```

清单默认从当前工作目录下的 `./modules/manifests` 加载。建议从仓库根目录运行
CLI，以便加载完整目录。

### 发布二进制

```bash
dotnet publish src/ToolboxV15/ToolboxCLI -c Release -r win-x64 --self-contained -o publish/cli
dotnet publish src/ToolboxV15/ToolboxAgent -c Release -r linux-x64 --self-contained -o publish/agent
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxApi -c Release -o publish/api
dotnet publish src/ToolboxV15/ToolboxServer/ToolboxClinical -c Release -o publish/clinical
```

发布后的二进制（CLI 的 `toolbox`/`toolbox.exe`，代理的 `toolbox-agent`）可在无
SDK 的环境中分发。

### 测试

```bash
dotnet test src/ToolboxV15/ToolboxV15.slnx
```

`tests/ToolboxTests` 项目覆盖因果引擎、模块注册、清单加载、症状注册、健康分
计算与执行结果。

---

## 4. CLI 命令参考

通用形式：

```
toolbox <command> [options]
```

### `triage`

对某领域执行完整 triage，运行与当前 OS 兼容的 `baseline` 与 `diagnostic`
模块，产出 findings、`HealthScore`、建议与 `RunId`。

```
toolbox triage --area <system|network|server|artec> [--json] [--guided]
```

- `--area`（默认 `system`）。
- `--json` 将序列化的 `TriageResult` 输出到 stdout
  （遵循 `schemas/triage-result.schema.json`）。
- `--guided` 为人工后续操作添加上下文提示。

上一个 `TriageResult` 会缓存在进程内，供 `report export` 立即使用。

### `symptom`

查询症状注册表，返回可能原因与推荐模块。

```
toolbox symptom <id> [--json]
```

### `catalog`

列出并过滤从 `modules/manifests/` 加载的目录。

```
toolbox catalog [--area <area>] [--os <windows|linux|macos>] [--risk <R|WR|WL|Critical>] [--json]
```

### `run`

按名称运行单个模块。

```
toolbox run <module-id> [--json] [--force] [--params k=v;k2=v2]
```

- `--force` 跳过权限提升检查（用于 CI 流水线）。
- `--params` 向模块执行器传递内联参数。

### `report`

导出最近缓存的 triage（无缓存时导出占位文件）。

```
toolbox report export --format <html|json|csv> --path <file>
```

### `agent`

代理子命令：

```
toolbox agent install
toolbox agent enroll --token <t> --server <url>
toolbox agent status
```

独立的 `toolbox-agent` 二进制额外支持 `run` 启动轮询循环，以及 `install`
打印服务注册说明（Windows `sc.exe` 或 Linux systemd）。

### `artec`

牙科领域子命令：

```
toolbox artec workflow
toolbox artec production [--action <status|queue|advance|block|cancel|rework>]
toolbox artec incident
```

- `workflow` 引导 CAD/CAM 流程。
- `production` 对生产作业状态执行操作。
- `incident` 记录并对设备事件做 triage。

---

## 5. 模块清单

每个模块由一份 JSON 描述，校验依据为
`schemas/module-manifest.schema.json`。关键字段：

| 字段                | 说明                                                                |
|---------------------|---------------------------------------------------------------------|
| `id`                | 模块 UUID。                                                         |
| `name`              | 由 `run`、`catalog` 与代理使用的稳定标识。                          |
| `area`              | `system` · `network` · `server` · `artec`。                         |
| `os`                | 支持的 OS 列表：`windows`、`linux`、`macos`。                       |
| `category`          | `diagnostic` · `repair` · `admin` · `production` · `baseline`。     |
| `risk`              | 风险等级（见下）。                                                   |
| `reversible`        | `true` 表示动作可撤销。                                             |
| `timeout_ms`        | 最大执行超时。                                                       |
| `permissions`       | `admin`、`root` 等。                                                |
| `remote_support`    | `none` · `readonly` · `full`。                                      |
| `rollback_module`   | 可选的回滚模块名。                                                   |
| `associated_repair` | 发现问题后建议的修复模块。                                          |
| `version`           | 模块 SemVer。                                                       |

### 风险等级（`risk`）

| 代码 | 含义                                  | 典型示例                                |
|------|--------------------------------------|------------------------------------------|
| `R`  | 只读，不修改系统。                    | `hardware-smart`、`network-dns`。        |
| `W-R`| 可逆写，变更可撤销。                  | `repair-temp-cleanup`、`repair-wu-reset`。|
| `W-L`| 影响有限/潜伏型写。                   | `system-services`、`system-autostart`。   |
| `!`  | 关键，不可逆或高影响操作。            | `admin-format`、`admin-mbr-gpt`、`artec-scanner-calibration`。|

### 执行状态

`ExecutionResult.Status` 可为：

- `Success` — 执行无错误。
- `Partial` — 完成但仅得到部分 findings。
- `Cancelled` — 被令牌或用户取消。
- `Skipped` — 因目录过滤被跳过。
- `Blocked` — 缺少权限提升或权限不足。
- `Failed` — 执行期间出错或异常。
- `Unsupported` — 该模块/OS 无已注册执行器。

`ModuleRunner` 默认设置 30 秒超时，取消时将 `ErrorDetail.Code` 置为
`TIMEOUT`。

---

## 6. 引导模式与技术模式

CLI 支持两种输出风格：

- **引导模式**（默认）：面向人工操作者的彩色文本，包含摘要、编号 findings 与
  下一步建议。不带 flag 的 `triage`、`symptom`、`catalog`、`run` 与 `report`
  使用此模式。
- **技术模式**：使用 `--json` 将结果对象（`TriageResult`、`ExecutionResult`、
  `SymptomResult` 等）序列化到 stdout，便于自动化、CI/CD 以及面板或代理消费。

`triage --guided` 同时具备两者：生成引导输出，并补充人工后续命令提示。

---

## 7. Docker 部署

`docker-compose.yml` 拉起完整生产栈：

```bash
docker compose up -d --build
```

包含的服务：

| 服务                | 镜像/Dockerfile             | 暴露端口        | 网络               |
|---------------------|------------------------------|-----------------|--------------------|
| `proxy`（Caddy）    | `caddy:2-alpine`             | 80、443         | operational、clinical |
| `api`               | `docker/Dockerfile.api`      | 8080（内部）    | operational        |
| `db-operational`    | `postgres:16-alpine`         | —               | operational        |
| `service-clinical`  | `docker/Dockerfile.clinical`  | 8081（内部）    | clinical           |
| `db-clinical`       | `postgres:16-alpine`         | —               | clinical           |
| `storage-clinical`  | `minio/minio`                | 9001（控制台）  | clinical           |
| `panel`             | `docker/Dockerfile.panel`     | 80（内部）      | operational        |

Caddy 发布三条路由：

- `/api/*` → `api:8080`
- `/clinical/*` → `service-clinical:8081`
- `/panel/*` → `panel:80`

其他路由返回 404，80 端口以内部 TLS 重定向到 HTTPS。

### 敏感配置

默认凭据（`tbx_operational_pw`、`tbx_clinical_pw`、JWT 密钥、ApiKey、
MfaToken）是**开发用值**，正式部署前必须通过环境变量或 secret 替换。

---

## 8. Artec Invent / 牙科 CAD-CAM

`artec` 领域覆盖 **Artec / 牙科 CAD-CAM** 流程，聚焦 UP3D 扫描仪与雕刻机，以
及实验室生产线。

### 可用模块

| 模块                          | 说明                                                          | 风险 |
|-------------------------------|---------------------------------------------------------------|------|
| `artec-scanner-detect`         | UP3D 扫描仪检测：在线、连接与驱动。                            | `R`  |
| `artec-scanner-calibration`    | 校准确认、日期与精度。                                         | `!`  |
| `artec-mill-detect`            | P52/P53 雕刻机检测：在线、连接与固件。                         | `R`  |
| `artec-mill-network`            | 雕刻机网络连通性：ping、延迟、端口与链路状态。                 | `R`  |
| `artec-air-extraction`         | 气路与抽吸系统：压力、滤芯、泵、告警。                          | `R`  |
| `artec-software-versions`       | CAD/CAM 软件审计：版本、授权与更新。                           | `R`  |
| `artec-workflow-guide`          | 牙科流程交互式指南。                                           | `R`  |

### CAD/CAM 流程

1. **接单**：牙科病例/单件入实验室。
2. **扫描**：使用 UP3D 扫描仪（先经 `artec-scanner-detect` 与
   `artec-scanner-calibration` 验证）。
3. **CAD 设计**：在设计工位完成。
4. **CAM**：生成刀路。
5. **排队**：生产排队并分配雕刻机。
6. **雕刻**：在 P52/P53 上加工（配合 `artec-mill-detect` 与
   `artec-mill-network`）。
7. **质检（QC）**：验证产出的单件。
8. **完成**：交付。

扫描与雕刻阶段需要设备验证；`artec` 模块暴露自动化检查，而
`toolbox artec workflow` 命令提供分步指南。

---

## 9. 生产管理

临床服务用 `ToolboxCore.Artec` 中定义并在 `ToolboxClinical` 中镜像的状态与角色
来建模生产作业。

### 状态（`ProductionState`）

`Received` → `Scanning` → `Cad` → `Cam` → `Queued` → `Milling` → `QC` →
`Completed`

侧支：`Blocked`、`Cancelled`、`Rework`。

| 状态        | 含义                                            |
|-------------|-------------------------------------------------|
| `Received`  | 病例进入实验室。                                 |
| `Scanning`  | 使用 UP3D 扫描仪扫描中。                         |
| `Cad`       | CAD 设计进行中。                                 |
| `Cam`       | 生成 CAM 刀路。                                  |
| `Queued`    | 等待分配雕刻机。                                  |
| `Milling`   | 在 P52/P53 上雕刻。                              |
| `QC`        | 质量控制。                                       |
| `Completed` | 单件完成并验证。                                  |
| `Blocked`   | 因依赖或待处理事项暂停。                         |
| `Cancelled` | 取消。                                          |
| `Rework`    | 对 QC 拒收的单件返工。                           |

### 角色（`ProductionRole`）

`Reception`、`Scanning`、`CadDesign`、`Cam`、`MachineOperator`、`Quality`、
`Administrator`。

状态转换通过 `PUT /clinical/production/{id}/state` 完成，每条动作都写入审计
链，记录 `actor`、`target` 与 `details`。

---

## 10. 临床记录

`ToolboxClinical` 服务管理临床记录与附件，具有阿根廷法规要求的可追溯性。

### 访问

- **JWT 认证**（校验 issuer、audience、签名密钥、生命周期）。
- **强制 MFA**：每个接触临床数据的操作都会校验 `X-MFA-Token` 头，缺失则返回
  `401 Unauthorized`。
- **必须提供原因**：读取（`record.read`、`patient.history`）需要
  `X-Access-Reason` 头。

### 时限

- `RecordService.Create` 默认将 `AccessExpiresAt = 现在 + 15 分钟`。
- `ClinicalAccessManager` 允许以 `requesterId`、`patientId`、`reason` 与
  `mfaToken` 显式申请的 **30 分钟** 会话（`DefaultAccessDuration`）。
- 记录可被 **封存（Seal）**，封存后禁止任何后续访问。

### 审计与保留

- `ClinicalAuditService` 存储 `Action`、`Actor`、`Target`、`Details` 条目。
- 可通过 `GET /clinical/records/{id}/audit` 查询。
- 上传到 `storage-clinical` 的附件会 **在事件关闭 90 天后删除**
  （`RetentionService`），每个附件都记录 `deleteAfter`。

### 合规

`ClinicalAccessManager.ComplianceNote` 显式声明：

> 临床记录访问遵守 **阿根廷第 25.326 号法**（个人数据保护）和 **第 26.529 号
> 法**（患者权利）。访问有时间限制、受 MFA 保护、必须提供原因并记录审计。
> 支持附件在事件关闭 90 天后删除。

---

## 11. 安全

### 签名模块

清单可以以签名方式传递；加载器校验其结构，在受控部署中可要求已知签名后才
注册模块。`!`（关键）模块需要显式确认或 `--force`。

### mTLS 与 ApiKey

- **代理** 以令牌入网，并收到一份客户端证书（`agent-{id}.cert`），保存在
  `AgentConfig` 中。
- **运营 API** 使用 *Hybrid* 方案（JWT 或经 `X-API-Key` 头的 ApiKey），由
  `ForwardDefaultSelector` 在运行时选择。
- **临床服务** 留在隔离网络（`clinical-net`），仅能通过启用内部 TLS 的 Caddy
  代理访问。

### 审计链

每个关键动作（入网、模块上传、作业创建、triage、备份、生产状态转换、记录
或附件访问）都会在 `AuditService` / `ClinicalAuditService` 中写入一条包含
actor、target、details 与时间戳的条目。`GET /api/audit?limit=N` 可用于重建
完整链路。

### 隔离的临床数据库

临床库（`db-clinical`，数据库 `clinical`）与运营库（`toolbox`）**相互独立**，
位于不同网络，凭据不共用。附件存放在 **MinIO**（`storage-clinical`），仅能从
`clinical-net` 访问。

---

## 12. 从 V14 迁移

V15 保留 **legacy bridge** 以在迁移过程中与 V14 脚本共存：

- 旧脚本（`Windows/toolbox.bat`、`Windows/toolbox.ps1`、`Linux/toolbox.sh`、
  `Mac/toolbox.sh`）仍保留在各自目录，在 V15 执行器目录补齐前推荐继续使用。
- V15 CLI 可并行运行：其模块为声明式，不会覆盖 V14 产物。
- 推荐的迁移路径是渐进的：先采用 `triage` 与 `catalog` 做审计，再对已迁移至
  `ToolboxCore` 的模块使用 `run`，最后在车队就绪后启用代理与服务器。
- V15 清单取代了 V14 的纯文本“选项目录”；V14 目录在迁移期间仍作为语义参考。

---

## 13. 状态 — 待办与试点阶段

V15 处于**试点阶段**，部分项目尚未生产就绪：

- **hyperDENT 配置文件**：hyperDENT 的雕刻配置文件**尚未验证**。在验证完成
  前，请继续使用继承的配置文件与厂商的 CAM 模块。
- **湿雕控制板（wet mill board）**：湿雕控制板的检测与监控**待确认**；当前
  `artec-mill-*` 模块仅覆盖干雕。
- **目录执行器**：V15 目录中部分模块暴露了接口但具体执行器是 *stub*；在全面
  实现之前，状态将返回 `Unsupported`。
- **临床试点**：在加载真实患者数据前，临床服务与附件保留期必须与法务团队
  一起验证。
- **代理服务**：将代理安装为服务（`sc.exe` / systemd）已有文档，但生产入网
  必须对接启用真实 TLS 与 ApiKey/JWT 的服务器。

本阶段的任何临床使用由试点组织自行负责。

---

## 14. 支持与许可

- 支持：**tomasrenggli@gmail.com**
- 完整文档：`docs/` 目录，以及 `Manuales/` 中的历史手册。
- 许可：© 2024-2026 Renggli PC Solution。Enterprise Toolbox V15。All rights reserved。