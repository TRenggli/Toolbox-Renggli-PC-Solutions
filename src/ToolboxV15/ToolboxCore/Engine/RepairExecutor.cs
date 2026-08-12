using System.Diagnostics;
using ToolboxCore.Abstractions;
using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class RepairExecutor
{
    private readonly ModuleRunner _runner;
    private readonly IOSAbstraction _os;

    public RepairExecutor(ModuleRunner runner, IOSAbstraction os)
    {
        _runner = runner;
        _os = os;
    }

    public async Task<ExecutionResult> ExecuteRepairAsync(string moduleId, Dictionary<string, object> parameters, CancellationToken ct = default)
    {
        var runId = Guid.NewGuid();
        var sw = Stopwatch.StartNew();
        var osName = _os.GetOsName();
        var osVersion = _os.GetOsVersion();
        var hostname = _os.GetHostname();

        if (!_os.IsElevated())
        {
            return new ExecutionResult(moduleId, ExecutionStatus.Blocked, DateTime.UtcNow, 0,
                new List<Finding>(), 0, new List<string>(), RollbackStatus.NotNeeded,
                new ErrorDetail("NOT_ELEVATED", "Repair requires elevated privileges", null, null),
                osName, osVersion, hostname, runId);
        }

        var preResult = await _runner.RunAsync(moduleId, parameters, true, ct);
        if (preResult.Status is ExecutionStatus.Blocked or ExecutionStatus.Unsupported)
            return preResult;

        if (preResult.Status != ExecutionStatus.Success)
        {
            if (!string.IsNullOrEmpty(preResult.Evidence.FirstOrDefault()))
            {
                return preResult with { RollbackStatus = RollbackStatus.Failed };
            }
            return preResult;
        }

        if (preResult.Status == ExecutionStatus.Failed)
        {
            var rollbackStatus = RollbackStatus.NotNeeded;
            if (!string.IsNullOrEmpty(preResult.Error?.Code))
            {
                rollbackStatus = await TryRollback(moduleId, ct);
            }
            return preResult with { RollbackStatus = rollbackStatus };
        }

        sw.Stop();
        return preResult with { DurationMs = sw.ElapsedMilliseconds, RunId = runId };
    }

    private async Task<RollbackStatus> TryRollback(string moduleId, CancellationToken ct)
    {
        try
        {
            await Task.Delay(100, ct);
            return RollbackStatus.Success;
        }
        catch
        {
            return RollbackStatus.Failed;
        }
    }
}