using System.Diagnostics;
using System.Security.Principal;
using System.Text.Json;

namespace ToolboxCore.Platform;

public class WindowsOSAbstraction : Abstractions.IOSAbstraction
{
    private static readonly JsonSerializerOptions JsonOpts = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public string GetOsName() => "windows";

    public string GetOsVersion()
    {
        return Environment.OSVersion.VersionString;
    }

    public string GetHostname()
    {
        return Environment.MachineName;
    }

    public bool IsElevated()
    {
        try
        {
            using var identity = WindowsIdentity.GetCurrent();
            var principal = new WindowsPrincipal(identity);
            return principal.IsInRole(WindowsBuiltInRole.Administrator);
        }
        catch
        {
            return false;
        }
    }

    public async Task<string> RunCommandAsync(string command, string args, int timeoutMs, CancellationToken ct)
    {
        var psi = new ProcessStartInfo
        {
            FileName = command,
            Arguments = args,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true,
            CreateNoWindow = true
        };
        using var process = new Process { StartInfo = psi };
        process.Start();

        var readTask = process.StandardOutput.ReadToEndAsync();
        var tcs = new TaskCompletionSource<bool>();
        using var ctr = ct.Register(() => tcs.TrySetResult(false));
        using var timeoutCts = new CancellationTokenSource(timeoutMs);
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(ct, timeoutCts.Token);
        using var linkedReg = linked.Token.Register(() =>
        {
            try { if (!process.HasExited) process.Kill(); } catch { }
        });

        try
        {
            await process.WaitForExitAsync(linked.Token);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested)
        {
            throw;
        }
        catch (OperationCanceledException)
        {
            throw new TimeoutException($"Command '{command}' timed out after {timeoutMs}ms");
        }

        return await readTask;
    }

    private async Task<string> RunPowerShellAsync(string script, CancellationToken ct)
    {
        return await RunCommandAsync("powershell", $"-NoProfile -Command \"{script}\"", 60000, ct);
    }

    private static JsonElement ParseJson(string json)
    {
        if (string.IsNullOrWhiteSpace(json))
        {
            return JsonSerializer.SerializeToElement(new { });
        }
        try
        {
            using var doc = JsonDocument.Parse(json);
            return doc.RootElement.Clone();
        }
        catch
        {
            using var doc = JsonDocument.Parse(JsonSerializer.Serialize(json));
            return doc.RootElement.Clone();
        }
    }

    private static List<JsonElement> ParseJsonArray(string json)
    {
        var list = new List<JsonElement>();
        if (string.IsNullOrWhiteSpace(json))
        {
            return list;
        }
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in doc.RootElement.EnumerateArray())
                {
                    list.Add(item.Clone());
                }
            }
            else if (doc.RootElement.ValueKind == JsonValueKind.Object)
            {
                list.Add(doc.RootElement.Clone());
            }
        }
        catch
        {
        }
        return list;
    }

    public async Task<JsonElement> GetHardwareInfoAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-CimInstance Win32_ComputerSystem | ConvertTo-Json", ct);
        return ParseJson(json);
    }

    public async Task<List<JsonElement>> GetDiskInfoAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-CimInstance Win32_DiskDrive | ConvertTo-Json", ct);
        return ParseJsonArray(json);
    }

    public async Task<JsonElement> GetMemoryInfoAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-CimInstance Win32_PhysicalMemory | ConvertTo-Json", ct);
        return ParseJson(json);
    }

    public async Task<List<JsonElement>> GetServicesAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-CimInstance Win32_Service | Select-Object Name,Status,StartMode | ConvertTo-Json", ct);
        return ParseJsonArray(json);
    }

    public async Task<JsonElement> GetNetworkInfoAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-NetIPConfiguration | ConvertTo-Json", ct);
        return ParseJson(json);
    }

    public async Task<List<JsonElement>> GetSoftwareListAsync(CancellationToken ct)
    {
        var json = await RunPowerShellAsync("Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\* | Select-Object DisplayName,DisplayVersion | ConvertTo-Json", ct);
        return ParseJsonArray(json);
    }
}