using System.Text.Json;
using System.Text;
using ToolboxCore.Models;

namespace ToolboxCore.Reporting;

public class ReportExporter
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public void Export(ExecutionResult result, string format, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        switch (format.ToLowerInvariant())
        {
            case "json":
                File.WriteAllText(path, JsonSerializer.Serialize(result, JsonOptions));
                break;
            case "csv":
                File.WriteAllText(path, ExportFindingsCsv(result.Findings));
                break;
            default:
                File.WriteAllText(path, ExportHtml(result));
                break;
        }
    }

    public void Export(TriageResult result, string format, string path)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        switch (format.ToLowerInvariant())
        {
            case "json":
                File.WriteAllText(path, JsonSerializer.Serialize(result, JsonOptions));
                break;
            case "csv":
                File.WriteAllText(path, ExportFindingsCsv(result.Findings));
                break;
            default:
                File.WriteAllText(path, ExportHtml(result));
                break;
        }
    }

    private static string ExportFindingsCsv(List<Finding> findings)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Id,Category,Severity,Title,Detail,Confidence,Remediation");
        foreach (var f in findings)
        {
            sb.AppendLine($"\"{f.Id}\",\"{f.Category}\",\"{f.Severity}\",\"{f.Title}\",\"{f.Detail}\",\"{f.Confidence}\",\"{f.Remediation}\"");
        }
        return sb.ToString();
    }

    private static string ExportHtml(ExecutionResult result)
    {
        var sb = new StringBuilder();
        sb.Append("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>");
        sb.Append("<style>body{background:#1a1a2e;color:#e0e0e0;font-family:sans-serif;margin:2em}");
        sb.Append("h1{color:#00d4ff}h2{color:#00ff88;border-bottom:1px solid #333}");
        sb.Append(".finding{background:#16213e;padding:1em;margin:0.5em 0;border-radius:4px}");
        sb.Append(".critical{border-left:4px solid #ff4444}.high{border-left:4px solid #ff8800}");
        sb.Append(".medium{border-left:4px solid #ffcc00}.low{border-left:4px solid #00aaff}");
        sb.Append(".info{border-left:4px solid #888}table{width:100%;border-collapse:collapse}");
        sb.Append("td{padding:4px 8px;border:1px solid #333}</style></head><body>");
        sb.Append($"<h1>Toolbox V15 - Reporte de Ejecucion</h1>");
        sb.Append($"<p>Modulo: {result.ModuleId} | Estado: {result.Status} | Score: {result.HealthScore}</p>");
        sb.Append($"<p>Host: {result.Hostname} | OS: {result.Os} {result.OsVersion}</p>");
        sb.Append($"<p>Duracion: {result.DurationMs}ms | Run ID: {result.RunId}</p>");
        sb.Append("<h2>Hallazgos</h2>");
        foreach (var f in result.Findings)
        {
            var cls = f.Severity.ToString().ToLowerInvariant();
            sb.Append($"<div class='finding {cls}'><strong>{f.Title}</strong><br>");
            sb.Append($"<small>{f.Category} | {f.Severity} | Confianza: {f.Confidence}</small><br>");
            sb.Append($"{f.Detail}<br>");
            if (!string.IsNullOrEmpty(f.Remediation))
                sb.Append($"<em>Remediacion: {f.Remediation}</em>");
            sb.Append("</div>");
        }
        if (result.Error != null)
        {
            sb.Append($"<h2>Error</h2><p>{result.Error.Code}: {result.Error.Message}</p>");
        }
        sb.Append("</body></html>");
        return sb.ToString();
    }

    private static string ExportHtml(TriageResult result)
    {
        var sb = new StringBuilder();
        sb.Append("<!DOCTYPE html><html lang='es'><head><meta charset='utf-8'>");
        sb.Append("<style>body{background:#1a1a2e;color:#e0e0e0;font-family:sans-serif;margin:2em}");
        sb.Append("h1{color:#00d4ff}h2{color:#00ff88;border-bottom:1px solid #333}");
        sb.Append(".finding{background:#16213e;padding:1em;margin:0.5em 0;border-radius:4px}");
        sb.Append(".critical{border-left:4px solid #ff4444}.high{border-left:4px solid #ff8800}");
        sb.Append(".medium{border-left:4px solid #ffcc00}.low{border-left:4px solid #00aaff}");
        sb.Append(".score{font-size:3em;font-weight:bold}");
        sb.Append("table{width:100%;border-collapse:collapse}td{padding:4px 8px;border:1px solid #333}</style></head><body>");
        sb.Append($"<h1>Toolbox V15 - Reporte de Triage</h1>");
        sb.Append($"<p>Area: {result.Area} | Estado: {result.OverallStatus}</p>");
        sb.Append($"<p class='score'>Health Score: {result.HealthScore}/100</p>");
        sb.Append($"<p>Host: {result.Hostname} | OS: {result.Os} | Duracion: {result.DurationMs}ms</p>");
        sb.Append("<h2>Hallazgos</h2>");
        foreach (var f in result.Findings)
        {
            var cls = f.Severity.ToString().ToLowerInvariant();
            sb.Append($"<div class='finding {cls}'><strong>{f.Title}</strong><br>");
            sb.Append($"<small>{f.Category} | {f.Severity} | Confianza: {f.Confidence}</small><br>");
            sb.Append($"{f.Detail}<br>");
            if (!string.IsNullOrEmpty(f.Remediation))
                sb.Append($"<em>Remediacion: {f.Remediation}</em>");
            sb.Append("</div>");
        }
        if (result.Recommendations.Count > 0)
        {
            sb.Append("<h2>Recomendaciones</h2><ul>");
            foreach (var r in result.Recommendations) sb.Append($"<li>{r}</li>");
            sb.Append("</ul>");
        }
        sb.Append("</body></html>");
        return sb.ToString();
    }
}