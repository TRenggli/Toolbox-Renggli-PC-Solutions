using System.Text;
using ToolboxCLI.Output;
using ToolboxCore.Models;
using ToolboxCore.Symptoms;

namespace ToolboxCLI.Commands;

internal static class SymptomCommand
{
    public static Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "json" });
        var id = CommandOptions.GetValue(opts, "arg0");
        var json = CommandOptions.HasFlag(opts, "json");

        if (string.IsNullOrEmpty(id))
        {
            OutputFormatter.PrintError("Usage: toolbox symptom <id> [--json]");
            return Task.FromResult(1);
        }

        var registry = new SymptomRegistry();
        var result = registry.GetSymptom(id!);

        if (result == null)
        {
            OutputFormatter.PrintError($"Symptom not found: {id}");
            return Task.FromResult(1);
        }

        if (json)
            OutputFormatter.PrintJson(result);
        else
            OutputFormatter.PrintGuided(Format(result));

        return Task.FromResult(0);
    }

    private static string Format(SymptomResult s)
    {
        var sb = new StringBuilder();
        sb.AppendLine($"=== Symptom: {s.Title} ({s.SymptomId}) ===");
        sb.AppendLine(s.Description);
        sb.AppendLine($"Confidence: {s.Confidence}");
        sb.AppendLine("Possible causes:");
        foreach (var c in s.PossibleCauses)
            sb.AppendLine($"  - {c.CauseId}: {c.Description} (evidence: {string.Join(", ", c.Evidence)})");
        sb.AppendLine("Recommended modules:");
        foreach (var m in s.RecommendedModules)
            sb.AppendLine($"  - {m}");
        return sb.ToString();
    }
}