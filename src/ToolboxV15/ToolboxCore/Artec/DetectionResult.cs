namespace ToolboxCore.Artec;

public record DetectionResult(
    List<string> DetectedScanners,
    List<string> DetectedMills,
    string GpuInfo,
    bool Usb3Available,
    List<string> NetworkAdapters,
    List<string> Issues
)
{
    public static DetectionResult Empty() => new(
        new List<string>(),
        new List<string>(),
        string.Empty,
        false,
        new List<string>(),
        new List<string>()
    );
}