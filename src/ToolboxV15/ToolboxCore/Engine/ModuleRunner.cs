using System.Diagnostics;
using System.Text.Json;
using ToolboxCore.Abstractions;
using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class ModuleRunner
{
    private readonly IOSAbstraction _os;
    private readonly List<IModuleExecutor> _executors;

    public ModuleRunner(IOSAbstraction os, IEnumerable<IModuleExecutor> executors)
    {
        _os = os;
        _executors = executors.ToList();
    }

    public async Task<ExecutionResult> RunAsync(string moduleId, Dictionary<string, object> parameters, bool force, CancellationToken ct = default)
    {
        var runId = Guid.NewGuid();
        var sw = Stopwatch.StartNew();
        var osName = _os.GetOsName();
        var osVersion = _os.GetOsVersion();
        var hostname = _os.GetHostname();

        var executor = _executors.FirstOrDefault(e => e.ModuleId.Equals(moduleId, StringComparison.OrdinalIgnoreCase));
        if (executor == null)
        {
            return new ExecutionResult(moduleId, ExecutionStatus.Unsupported, DateTime.UtcNow, 0,
                new List<Finding>(), 0, new List<string>(), RollbackStatus.NotNeeded,
                new ErrorDetail("NO_EXECUTOR", $"No executor registered for module '{moduleId}'", null, null),
                osName, osVersion, hostname, runId);
        }

        if (!force)
        {
            var elevated = _os.IsElevated();
            if (!elevated)
            {
                return new ExecutionResult(moduleId, ExecutionStatus.Blocked, DateTime.UtcNow, 0,
                    new List<Finding>(), 0, new List<string>(), RollbackStatus.NotNeeded,
                    new ErrorDetail("NOT_ELEVATED", "Module requires elevated privileges", null, null),
                    osName, osVersion, hostname, runId);
            }
        }

        try
        {
            using var cts = CancellationTokenSource.CreateLinkedTokenSource(ct);
            cts.CancelAfter(TimeSpan.FromMilliseconds(30000));

            var result = await executor.ExecuteAsync(executor.ModuleId == moduleId ? new ModuleManifest() : new ModuleManifest(), parameters, cts.Token);
            sw.Stop();

            if (result.Status == ExecutionStatus.Failed)
            {
                var manifest = executor.ModuleId;
                return result with { DurationMs = sw.ElapsedMilliseconds, RunId = runId };
            }

            return result with { DurationMs = sw.ElapsedMilliseconds, RunId = runId, Os = osName, OsVersion = osVersion, Hostname = hostname };
        }
        catch (OperationCanceledException)
        {
            sw.Stop();
            return new ExecutionResult(moduleId, ExecutionStatus.Failed, DateTime.UtcNow, sw.ElapsedMilliseconds,
                new List<Finding>(), 0, new List<string>(), RollbackStatus.NotNeeded,
                new ErrorDetail("TIMEOUT", "Module execution timed out", null, null), osName, osVersion, hostname, runId);
        }
        catch (Exception ex)
        {
            sw.Stop();
            return new ExecutionResult(moduleId, ExecutionStatus.Failed, DateTime.UtcNow, sw.ElapsedMilliseconds,
                new List<Finding>(), 0, new List<string>(), RollbackStatus.NotNeeded,
                new ErrorDetail("EXCEPTION", ex.Message, ex.StackTrace, null), osName, osVersion, hostname, runId);
        }
    }
}