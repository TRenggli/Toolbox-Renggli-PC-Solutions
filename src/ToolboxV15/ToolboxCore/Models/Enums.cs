namespace ToolboxCore.Models;

public enum Area
{
    System,
    Network,
    Server,
    Artec
}

public enum ModuleCategory
{
    Baseline,
    Diagnostic,
    Repair,
    Admin,
    Production
}

public enum RiskLevel
{
    R,
    WR,
    WL,
    Critical
}

public enum ExecutionStatus
{
    Success,
    Cancelled,
    Skipped,
    Partial,
    Failed,
    Blocked,
    Unsupported
}

public enum Confidence
{
    Confirmed,
    Probable,
    Possible,
    Insufficient
}

public enum Severity
{
    Critical,
    High,
    Medium,
    Low,
    Info
}

public enum RemoteSupport
{
    None,
    Readonly,
    Full
}

public enum OverallStatus
{
    Healthy,
    Degraded,
    Critical,
    Unknown
}

public enum RollbackStatus
{
    NotNeeded,
    Success,
    Failed,
    Partial
}