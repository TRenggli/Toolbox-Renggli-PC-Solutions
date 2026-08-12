namespace ToolboxCore.Artec;

public enum DeviceType
{
    Scanner,
    Mill
}

public enum DeviceModel
{
    UP400,
    UP560,
    UP560HD,
    P52,
    P53,
    P42,
    P42Plus
}

public record DeviceProfile(
    string DeviceName,
    DeviceType DeviceType,
    DeviceModel Model,
    bool IsDry,
    bool IsWet,
    bool RequiresBoardConfirmation,
    List<string> SupportedCAM,
    bool NetworkRequired,
    bool UsbRequired
);