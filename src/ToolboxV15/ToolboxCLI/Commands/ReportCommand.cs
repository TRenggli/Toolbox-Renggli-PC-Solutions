using System.Text;
using ToolboxCLI.Output;
using ToolboxCore.Models;
using ToolboxCore.Reporting;

namespace ToolboxCLI.Commands;

internal static class ReportCommand
{
    public static Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "format", "path" });
        var sub = CommandOptions.GetValue(opts, "arg0");

        if (string.IsNullOrEmpty(sub))
        {
            OutputFormatter.PrintError("Usage: toolbox report export --format <html|json|csv> --path <file>");
            return Task.FromResult(1);
        }

        if (!sub.Equals("export", StringComparison.OrdinalIgnoreCase))
        {
            OutputFormatter.PrintError($"Unknown report subcommand: {sub}. Only 'export' is supported.");
            return Task.FromResult(1);
        }

        var format = (CommandOptions.GetValue(opts, "format") ?? "html").ToLowerInvariant();
        var path = CommandOptions.GetValue(opts, "path")
            ?? Path.Combine(Directory.GetCurrentDirectory(), $"report.{format}");

        EnsureDirectory(path);

        if (Program.LastTriage != null)
        {
            var exporter = new ReportExporter();
            exporter.Export(Program.LastTriage, format, path);
            OutputFormatter.PrintGuided($"Report exported to {path} ({format}).");
            return Task.FromResult(0);
        }

        WritePlaceholder(format, path);
        OutputFormatter.PrintGuided($"No cached triage result. Placeholder report written to {path} ({format}).");
        return Task.FromResult(0);
    }

    private static void EnsureDirectory(string path)
    {
        var dir = Path.GetDirectoryName(path);
        if (!string.IsNullOrEmpty(dir))
            Directory.CreateDirectory(dir);
    }

    private static void WritePlaceholder(string format, string path)
    {
        var sb = new StringBuilder();
        if (format == "json")
        {
            sb.Append("{\"status\":\"empty\",\"message\":\"No triage result cached yet. Run 'toolbox triage --area <area>' first.\"}");
        }
        else if (format == "csv")
        {
            sb.AppendLine("Id,Category,Severity,Title");
        }
        else
        {
            sb.Append("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>");
            sb.Append("<style>body{background:#1a1a2e;color:#e0e0e0;font-family:sans-serif;margin:2em}");
            sb.Append("h1{color:#00d4ff}</style></head><body>");
            sb.Append("<h1>Toolbox V15 - Reporte</h1>");
            sb.Append("<p>No hay resultado de triage cacheado. Ejecute 'toolbox triage --area &lt;area&gt;' primero.</p>");
            sb.Append("</body></html>");
        }
        File.WriteAllText(path, sb.ToString());
    }
}