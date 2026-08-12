namespace ToolboxCore.Artec;

public static class DeviceRegistry
{
    private static readonly List<DeviceProfile> _profiles = new()
    {
        new DeviceProfile(
            "UP400 Scanner",
            DeviceType.Scanner,
            DeviceModel.UP400,
            IsDry: true,
            IsWet: false,
            RequiresBoardConfirmation: false,
            new List<string> { "UPCAM" },
            NetworkRequired: false,
            UsbRequired: true
        ),
        new DeviceProfile(
            "UP560 Scanner",
            DeviceType.Scanner,
            DeviceModel.UP560,
            IsDry: true,
            IsWet: false,
            RequiresBoardConfirmation: false,
            new List<string> { "UPCAM" },
            NetworkRequired: false,
            UsbRequired: true
        ),
        new DeviceProfile(
            "UP560HD Scanner",
            DeviceType.Scanner,
            DeviceModel.UP560HD,
            IsDry: true,
            IsWet: false,
            RequiresBoardConfirmation: false,
            new List<string> { "UPCAM" },
            NetworkRequired: false,
            UsbRequired: true
        ),
        new DeviceProfile(
            "P52 Mill",
            DeviceType.Mill,
            DeviceModel.P52,
            IsDry: true,
            IsWet: false,
            RequiresBoardConfirmation: false,
            new List<string> { "UPCAM", "hyperDENT" },
            NetworkRequired: true,
            UsbRequired: false
        ),
        new DeviceProfile(
            "P53 Mill",
            DeviceType.Mill,
            DeviceModel.P53,
            IsDry: true,
            IsWet: false,
            RequiresBoardConfirmation: false,
            new List<string> { "UPCAM", "hyperDENT" },
            NetworkRequired: true,
            UsbRequired: false
        ),
        new DeviceProfile(
            "P42 Mill",
            DeviceType.Mill,
            DeviceModel.P42,
            IsDry: false,
            IsWet: true,
            RequiresBoardConfirmation: true,
            new List<string> { "UPCAM", "hyperDENT" },
            NetworkRequired: true,
            UsbRequired: false
        ),
        new DeviceProfile(
            "P42Plus Mill",
            DeviceType.Mill,
            DeviceModel.P42Plus,
            IsDry: false,
            IsWet: true,
            RequiresBoardConfirmation: true,
            new List<string> { "UPCAM", "hyperDENT" },
            NetworkRequired: true,
            UsbRequired: false
        )
    };

    public static IReadOnlyList<DeviceProfile> GetAllProfiles() => _profiles;

    public static DeviceProfile? GetProfile(string model)
    {
        if (string.IsNullOrWhiteSpace(model)) return null;
        return _profiles.FirstOrDefault(p =>
            p.Model.ToString().Equals(model, StringComparison.OrdinalIgnoreCase) ||
            p.DeviceName.Contains(model, StringComparison.OrdinalIgnoreCase));
    }

    public static IReadOnlyList<DeviceProfile> GetScanners() =>
        _profiles.Where(p => p.DeviceType == DeviceType.Scanner).ToList();

    public static IReadOnlyList<DeviceProfile> GetMills() =>
        _profiles.Where(p => p.DeviceType == DeviceType.Mill).ToList();
}