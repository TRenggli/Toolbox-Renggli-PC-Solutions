namespace ToolboxCore.Artec;

public record SoftwareAdapterResult(
    string Name,
    bool IsInstalled,
    string Version,
    string Path,
    List<string> CompatibleDevices,
    List<string> Issues
);