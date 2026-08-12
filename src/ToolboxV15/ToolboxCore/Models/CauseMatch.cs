namespace ToolboxCore.Models;

public record CauseMatch(
    string CauseId,
    string Description,
    Confidence Confidence,
    List<string> Evidence
);