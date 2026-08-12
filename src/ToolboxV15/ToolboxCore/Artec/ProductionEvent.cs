namespace ToolboxCore.Artec;

public record ProductionEvent(
    Guid Id,
    DateTime Timestamp,
    string Operator,
    string Software,
    string SoftwareVersion,
    string Machine,
    string Result,
    ProductionState StateFrom,
    ProductionState StateTo
);