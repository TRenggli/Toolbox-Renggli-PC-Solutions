using System.Text;
using ToolboxCLI.Output;
using ToolboxCore.Abstractions;
using ToolboxCore.Engine;
using ToolboxCore.Models;
using ToolboxCore.Platform;

namespace ToolboxCLI.Commands;

internal static class RunCommand
{
    public static async Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "json", "force", "params" });
        var id = CommandOptions.GetValue(opts, "arg0");

        if (string.IsNullOrEmpty(id))
        {
            OutputFormatter.PrintError("Usage: toolbox run <module-id> [--json] [--force] [--params k=v;...]");
            return 1;
        }

        var json = CommandOptions.HasFlag(opts, "json");
        var force = CommandOptions.HasFlag(opts, "force");

        var parameters = new Dictionary<string, object>();
        var paramsValue = CommandOptions.GetValue(opts, "params");
        if (paramsValue != null)
        {
            foreach (var pair in paramsValue.Split(';', StringSplitOptions.RemoveEmptyEntries))
            {
                var kv = pair.Split('=', 2);
                if (kv.Length == 2)
                    parameters[kv[0].Trim()] = kv[1].Trim();
            }
        }

        var os = OSAbstractionFactory.Create();
        var runner = new ModuleRunner(os, Enumerable.Empty<IModuleExecutor>());
        var result = await runner.RunAsync(id!, parameters, force);

        if (json)
            OutputFormatter.PrintJson(result);
        else
            OutputFormatter.PrintGuided(Format(result));

        return 0;
    }

    private static string Format(ExecutionResult r)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"=== Run {r.ModuleId} ===");
        sb.AppendLine($"Status: {r.Status}   HealthScore: {r.HealthScore}   Duration: {r.DurationMs}ms");
        sb.AppendLine($"Host: {r.Hostname} ({r.Os} {r.OsVersion})   RunId: {r.RunId}");
        sb.AppendLine($"Findings ({r.Findings.Count}):");
        foreach (var f in r.Findings)
            sb.AppendLine($"  [{f.Severity}] {f.Title}: {f.Detail}");
        if (r.Error != null)
            sb.AppendLine($"Error: {r.Error.Code} - {r.Error.Message}");
        sb.AppendLine($"Rollback: {r.RollbackStatus}");
        return sb.ToString();
    }
}