using System.Text;
using ToolboxCLI.Output;
using ToolboxCore.Abstractions;
using ToolboxCore.Engine;
using ToolboxCore.Models;
using ToolboxCore.Platform;

namespace ToolboxCLI.Commands;

internal static class TriageCommand
{
    public static async Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "area", "json", "guided" });
        var areaValue = CommandOptions.GetValue(opts, "area") ?? "system";

        if (!Enum.TryParse<Area>(areaValue, true, out var area))
        {
            OutputFormatter.PrintError($"Unknown area: {areaValue}. Valid: system, network, server, artec.");
            return 1;
        }

        var json = CommandOptions.HasFlag(opts, "json");
        var guided = CommandOptions.HasFlag(opts, "guided");

        var manifestDir = Path.Combine(Directory.GetCurrentDirectory(), "modules", "manifests");
        var registry = new ModuleRegistry();
        if (Directory.Exists(manifestDir))
            registry.LoadFromDirectory(manifestDir);

        var os = OSAbstractionFactory.Create();
        var runner = new ModuleRunner(os, Enumerable.Empty<IModuleExecutor>());
        var causal = new CausalEngine();
        var health = new HealthScoreCalculator();
        var orchestrator = new TriageOrchestrator(registry, runner, causal, health, os);

        var result = await orchestrator.RunTriageAsync(area);
        Program.LastTriage = result;

        if (json)
            OutputFormatter.PrintJson(result);
        else
            OutputFormatter.PrintGuided(Format(result, guided));

        return 0;
    }

    private static string Format(TriageResult r, bool guided)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"=== Triage Result - Area: {r.Area} ===");
        sb.AppendLine($"Overall: {r.OverallStatus}   HealthScore: {r.HealthScore}/100");
        sb.AppendLine($"Host: {r.Hostname} ({r.Os})   Duration: {r.DurationMs}ms   RunId: {r.RunId}");
        sb.AppendLine($"Findings ({r.Findings.Count}):");
        foreach (var f in r.Findings)
            sb.AppendLine($"  [{f.Severity}] {f.Title} ({f.Category}) - {f.Detail}");

        if (r.Recommendations.Count > 0)
        {
            sb.AppendLine("Recommendations:");
            foreach (var rec in r.Recommendations)
                sb.AppendLine($"  - {rec}");
        }

        if (guided)
        {
            sb.AppendLine();
            sb.AppendLine("Guided mode available: run individual modules via 'toolbox run <module-id>'.");
        }

        return sb.ToString();
    }
}