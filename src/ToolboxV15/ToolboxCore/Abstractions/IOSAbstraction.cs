using System.Text.Json;

namespace ToolboxCore.Abstractions;

public interface IOSAbstraction
{
    string GetOsName();
    string GetOsVersion();
    string GetHostname();
    bool IsElevated();
    Task<string> RunCommandAsync(string command, string args, int timeoutMs, CancellationToken ct);
    Task<JsonElement> GetHardwareInfoAsync(CancellationToken ct);
    Task<List<JsonElement>> GetDiskInfoAsync(CancellationToken ct);
    Task<JsonElement> GetMemoryInfoAsync(CancellationToken ct);
    Task<List<JsonElement>> GetServicesAsync(CancellationToken ct);
    Task<JsonElement> GetNetworkInfoAsync(CancellationToken ct);
    Task<List<JsonElement>> GetSoftwareListAsync(CancellationToken ct);
}