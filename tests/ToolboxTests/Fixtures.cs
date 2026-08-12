using System.Text.Json;
using ToolboxCore.Models;

namespace ToolboxTests;

public static class Fixtures
{
    public static Finding MakeFinding(
        string id = "test-finding",
        string category = "test",
        Severity severity = Severity.Medium,
        Confidence confidence = Confidence.Probable) =>
        new(id, category, severity, "Test finding", "Detail", confidence, "Remediation", null);

    public static ExecutionResult MakeResult(
        string moduleId = "test-module",
        ExecutionStatus status = ExecutionStatus.Success,
        List<Finding>? findings = null,
        int healthScore = 100) =>
        new(moduleId, status, DateTime.UtcNow, 10, findings ?? new(), healthScore,
            new(), RollbackStatus.NotNeeded, null, "Windows", "10.0", "host", Guid.NewGuid());

    public static ExecutionResult Success(string moduleId = "test-module", List<Finding>? findings = null) =>
        MakeResult(moduleId, ExecutionStatus.Success, findings, 100);

    public static ExecutionResult Failed(string moduleId = "test-module", List<Finding>? findings = null, ErrorDetail? error = null) =>
        new(moduleId, ExecutionStatus.Failed, DateTime.UtcNow, 10, findings ?? new(), 0,
            new(), RollbackStatus.NotNeeded, error ?? new ErrorDetail("E_FAIL", "Failed", null, 1),
            "Windows", "10.0", "host", Guid.NewGuid());

    public static ExecutionResult Partial(string moduleId = "test-module", List<Finding>? findings = null) =>
        MakeResult(moduleId, ExecutionStatus.Partial, findings, 50);

    public static ExecutionResult Cancelled(string moduleId = "test-module") =>
        MakeResult(moduleId, ExecutionStatus.Cancelled, null, 0);

    public static ExecutionResult Blocked(string moduleId = "test-module") =>
        MakeResult(moduleId, ExecutionStatus.Blocked, null, 0);

    public static ExecutionResult Unsupported(string moduleId = "test-module") =>
        MakeResult(moduleId, ExecutionStatus.Unsupported, null, 0);

    public static ExecutionResult Skipped(string moduleId = "test-module") =>
        MakeResult(moduleId, ExecutionStatus.Skipped, null, 0);

    public static ExecutionResult DiskSmartFailed() =>
        Failed("hardware-smart", new()
        {
            new("smart-fail", "disk", Severity.High, "SMART failing",
                "Bad sectors", Confidence.Confirmed, "Replace disk", null)
        });

    public static ExecutionResult DiskEventsFailed() =>
        Failed("system-events", new()
        {
            new("events-disk", "disk", Severity.High, "Disk events",
                "Disk errors in event log", Confidence.Confirmed, "Replace disk", null)
        });

    public static ExecutionResult RamHigh() =>
        Success("hardware-ram", new()
        {
            new("ram-high", "memory", Severity.Medium, "RAM high",
                "RAM > 90%", Confidence.Probable, "Close apps", null)
        });

    public static ExecutionResult DnsFailed() =>
        Failed("network-dns", new()
        {
            new("dns-fail", "network", Severity.Medium, "DNS failing",
                "DNS not resolving", Confidence.Probable, "Check DNS", null)
        });

    public static ExecutionResult NetworkSpeedOk() =>
        Success("network-speed");
}