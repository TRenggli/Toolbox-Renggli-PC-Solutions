using System.Text.Json;

namespace ToolboxCore.Models;

public record TriageResult(
    Area Area,
    DateTime Timestamp,
    long DurationMs,
    OverallStatus OverallStatus,
    int HealthScore,
    JsonElement Baseline,
    List<Finding> Findings,
    List<string> Recommendations,
    List<string> ModulesExecuted,
    List<JsonElement> ModulesSkipped,
    string Hostname,
    string Os,
    Guid RunId
);