using System.Diagnostics;
using System.Text.Json;
using ToolboxCore.Abstractions;
using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class TriageOrchestrator
{
    private readonly ModuleRegistry _registry;
    private readonly ModuleRunner _runner;
    private readonly CausalEngine _causal;
    private readonly HealthScoreCalculator _healthCalc;
    private readonly IOSAbstraction _os;

    public TriageOrchestrator(ModuleRegistry registry, ModuleRunner runner, CausalEngine causal,
        HealthScoreCalculator healthCalc, IOSAbstraction os)
    {
        _registry = registry;
        _runner = runner;
        _causal = causal;
        _healthCalc = healthCalc;
        _os = os;
    }

    public async Task<TriageResult> RunTriageAsync(Area area, CancellationToken ct = default)
    {
        var runId = Guid.NewGuid();
        var sw = Stopwatch.StartNew();
        var osName = _os.GetOsName();
        var hostname = _os.GetHostname();
        var results = new List<ExecutionResult>();
        var executed = new List<string>();
        var skipped = new List<JsonElement>();

        var modules = _registry.GetModules(area: area, os: osName)
            .Where(m => m.Category is ModuleCategory.Baseline or ModuleCategory.Diagnostic)
            .ToList();

        foreach (var module in modules)
        {
            var result = await _runner.RunAsync(module.Name, new Dictionary<string, object>(), false, ct);
            results.Add(result);
            if (result.Status == ExecutionStatus.Success || result.Status == ExecutionStatus.Partial)
                executed.Add(module.Name);
            else
                skipped.Add(JsonSerializer.SerializeToElement(new { module = module.Name, reason = result.Status.ToString() }));
        }

        sw.Stop();
        var findings = _causal.Analyze(results);
        var healthScore = _healthCalc.Calculate(findings);
        var overall = healthScore switch
        {
            >= 80 => OverallStatus.Healthy,
            >= 50 => OverallStatus.Degraded,
            > 0 => OverallStatus.Critical,
            _ => OverallStatus.Unknown
        };

        var recommendations = findings
            .Where(f => !string.IsNullOrEmpty(f.Remediation))
            .Select(f => f.Remediation!)
            .Distinct()
            .ToList();

        var baseline = JsonSerializer.SerializeToElement(new
        {
            hardware = osName,
            os = _os.GetOsVersion(),
            timestamp = DateTime.UtcNow
        });

        return new TriageResult(area, DateTime.UtcNow, sw.ElapsedMilliseconds, overall,
            healthScore, baseline, findings, recommendations, executed, skipped,
            hostname, osName, runId);
    }
}