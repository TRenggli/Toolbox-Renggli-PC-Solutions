namespace ToolboxCore.Models;

public record ErrorDetail(
    string Code,
    string Message,
    string? StackTrace,
    int? ExitCode
);

public record ExecutionResult(
    string ModuleId,
    ExecutionStatus Status,
    DateTime Timestamp,
    long DurationMs,
    List<Finding> Findings,
    int HealthScore,
    List<string> Evidence,
    RollbackStatus RollbackStatus,
    ErrorDetail? Error,
    string Os,
    string OsVersion,
    string Hostname,
    Guid RunId
);