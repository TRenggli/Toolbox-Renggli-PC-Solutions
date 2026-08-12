using ToolboxCore.Models;

namespace ToolboxCore.Symptoms;

public record SymptomDefinition(
    string Id,
    string Title,
    string Description,
    List<CauseDefinition> PossibleCauses,
    List<string> RecommendedModules
);

public record CauseDefinition(
    string CauseId,
    string Description,
    List<string> AssociatedModules
);