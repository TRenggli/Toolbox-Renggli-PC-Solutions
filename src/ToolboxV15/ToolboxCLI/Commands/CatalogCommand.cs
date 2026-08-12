using System.Text;
using ToolboxCLI.Output;
using ToolboxCore.Engine;
using ToolboxCore.Models;

namespace ToolboxCLI.Commands;

internal static class CatalogCommand
{
    public static Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "area", "os", "risk", "json" });
        var json = CommandOptions.HasFlag(opts, "json");

        Area? area = null;
        var areaValue = CommandOptions.GetValue(opts, "area");
        if (areaValue != null && Enum.TryParse<Area>(areaValue, true, out var ar))
            area = ar;

        var os = CommandOptions.GetValue(opts, "os");

        RiskLevel? risk = null;
        var riskValue = CommandOptions.GetValue(opts, "risk");
        if (riskValue != null && Enum.TryParse<RiskLevel>(riskValue, true, out var rl))
            risk = rl;

        var manifestDir = Path.Combine(Directory.GetCurrentDirectory(), "modules", "manifests");
        var registry = new ModuleRegistry();
        if (Directory.Exists(manifestDir))
            registry.LoadFromDirectory(manifestDir);

        var modules = registry.GetModules(area, os, risk);
        var view = modules
            .Select(m => new
            {
                m.Name,
                m.Description,
                Area = m.Area.ToString(),
                Category = m.Category.ToString(),
                Risk = m.Risk.ToString(),
                Os = string.Join(",", m.Os)
            })
            .ToList();

        if (json)
        {
            OutputFormatter.PrintJson(view);
        }
        else
        {
            if (view.Count == 0)
            {
                OutputFormatter.PrintGuided("No modules match the filter.");
            }
            else
            {
                var sb = new StringBuilder();
                sb.AppendLine($"=== Catalog ({view.Count} modules) ===");
                foreach (var m in view)
                    sb.AppendLine($"  {m.Name,-32} [{m.Area}/{m.Category}/{m.Risk}] - {m.Description}");
                OutputFormatter.PrintGuided(sb.ToString());
            }
        }

        return Task.FromResult(0);
    }
}