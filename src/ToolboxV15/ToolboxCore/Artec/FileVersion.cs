namespace ToolboxCore.Artec;

public record FileVersion(
    string FilePath,
    string Hash,
    int Version,
    DateTime Timestamp,
    string Operator
);