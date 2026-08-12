using System.Runtime.InteropServices;
using System.Text.Json;
using ToolboxCore.Abstractions;

namespace ToolboxCore.Artec;

public class SoftwareAdapter
{
    public string Name { get; }
    public string DisplayName { get; }
    public List<string> CompatibleDevices { get; }
    public bool RequiresValidatedProfile { get; }

    private readonly string? _registryDisplayName;
    private readonly string? _fallbackPath;
    private readonly string _expectedVersion;

    public SoftwareAdapter(
        string name,
        string displayName,
        List<string> compatibleDevices,
        bool requiresValidatedProfile = false,
        string? registryDisplayName = null,
        string? fallbackPath = null,
        string expectedVersion = "")
    {
        Name = name;
        DisplayName = displayName;
        CompatibleDevices = compatibleDevices;
        RequiresValidatedProfile = requiresValidatedProfile;
        _registryDisplayName = registryDisplayName;
        _fallbackPath = fallbackPath;
        _expectedVersion = expectedVersion;
    }

    public async Task<SoftwareAdapterResult> DetectAsync(IOSAbstraction os, CancellationToken ct)
    {
        var issues = new List<string>();
        var installed = false;
        var version = string.Empty;
        var path = string.Empty;

        if (OperatingSystem.IsWindows())
        {
            try
            {
                var list = await os.GetSoftwareListAsync(ct);
                foreach (var item in list)
                {
                    if (item.TryGetProperty("DisplayName", out var nameEl) &&
                        nameEl.ValueKind == JsonValueKind.String)
                    {
                        var name = nameEl.GetString() ?? string.Empty;
                        if (!string.IsNullOrWhiteSpace(_registryDisplayName))
                        {
                            if (name.Contains(_registryDisplayName, StringComparison.OrdinalIgnoreCase))
                            {
                                installed = true;
                                if (item.TryGetProperty("DisplayVersion", out var vEl) &&
                                    vEl.ValueKind == JsonValueKind.String)
                                {
                                    version = vEl.GetString() ?? string.Empty;
                                }
                                break;
                            }
                        }
                        else if (name.Contains(Name, StringComparison.OrdinalIgnoreCase))
                        {
                            installed = true;
                            if (item.TryGetProperty("DisplayVersion", out var vEl) &&
                                vEl.ValueKind == JsonValueKind.String)
                            {
                                version = vEl.GetString() ?? string.Empty;
                            }
                            break;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                issues.Add($"Registry scan failed: {ex.Message}");
            }
        }

        if (!installed && !string.IsNullOrWhiteSpace(_fallbackPath))
        {
            try
            {
                if (File.Exists(_fallbackPath) || Directory.Exists(_fallbackPath))
                {
                    installed = true;
                    path = _fallbackPath;
                }
            }
            catch (Exception ex)
            {
                issues.Add($"Path check failed: {ex.Message}");
            }
        }

        if (installed && !string.IsNullOrWhiteSpace(_expectedVersion) && string.IsNullOrWhiteSpace(version))
        {
            version = _expectedVersion;
        }

        if (!installed)
        {
            issues.Add($"{DisplayName} is not installed.");
        }

        if (RequiresValidatedProfile && installed && string.IsNullOrWhiteSpace(version))
        {
            issues.Add($"{DisplayName} requires a validated profile before production use.");
        }

        return new SoftwareAdapterResult(
            Name,
            installed,
            version,
            path,
            CompatibleDevices,
            issues
        );
    }

    public async Task<string> GetVersion(IOSAbstraction os, CancellationToken ct)
    {
        var result = await DetectAsync(os, ct);
        return result.Version;
    }

    public async Task<bool> IsInstalled(IOSAbstraction os, CancellationToken ct)
    {
        var result = await DetectAsync(os, ct);
        return result.IsInstalled;
    }

    public static IReadOnlyList<SoftwareAdapter> BuildStandardAdapters() => new List<SoftwareAdapter>
    {
        new SoftwareAdapter(
            "DentalStation",
            "Artec DentalStation",
            new List<string>(),
            registryDisplayName: "DentalStation",
            fallbackPath: @"C:\Program Files\Artec\DentalStation\DentalStation.exe"
        ),
        new SoftwareAdapter(
            "exocad",
            "exocad DentalCAD",
            new List<string>(),
            registryDisplayName: "exocad",
            fallbackPath: @"C:\Program Files\exocad\DentalCAD"
        ),
        new SoftwareAdapter(
            "UPCAD",
            "Artec UPCAD",
            new List<string> { "UP400", "UP560", "UP560HD" },
            registryDisplayName: "UPCAD",
            fallbackPath: @"C:\Program Files\Artec\UPCAD\UPCAD.exe"
        ),
        new SoftwareAdapter(
            "UPCAM",
            "Artec UPCAM",
            new List<string> { "P42", "P42Plus", "P52", "P53" },
            registryDisplayName: "UPCAM",
            fallbackPath: @"C:\Program Files\Artec\UPCAM\UPCAM.exe",
            expectedVersion: "4.0"
        ),
        new SoftwareAdapter(
            "hyperDENT",
            "hyperDENT",
            new List<string> { "P42", "P42Plus", "P52", "P53" },
            requiresValidatedProfile: true,
            registryDisplayName: "hyperDENT",
            fallbackPath: @"C:\Program Files\hyperDENT\hyperDENT.exe"
        )
    };
}