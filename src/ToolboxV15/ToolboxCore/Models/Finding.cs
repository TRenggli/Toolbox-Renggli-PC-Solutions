using System.Text.Json;

namespace ToolboxCore.Models;

public record Finding(
    string Id,
    string Category,
    Severity Severity,
    string Title,
    string Detail,
    Confidence Confidence,
    string Remediation,
    JsonElement? RawData
);