namespace ToolboxCore.Models;

public record SymptomResult(
    string SymptomId,
    string Title,
    string Description,
    List<CauseMatch> PossibleCauses,
    List<string> RecommendedModules,
    Confidence Confidence,
    DateTime Timestamp,
    Guid RunId
);