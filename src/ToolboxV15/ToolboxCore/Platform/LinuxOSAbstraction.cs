using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text.Json;

namespace ToolboxCore.Platform;

public class LinuxOSAbstraction : Abstractions.IOSAbstraction
{
    public string GetOsName() => "linux";

    public string GetOsVersion()
    {
        try
        {
            if (File.Exists("/etc/os-release"))
            {
                var lines = File.ReadAllLines("/etc/os-release");
                foreach (var line in lines)
                {
                    if (line.StartsWith("PRETTY_NAME="))
                    {
                        var v = line.Substring("PRETTY_NAME=".Length).Trim('"', '\'');
                        return v;
                    }
                }
            }
        }
        catch
        {
        }
        return Environment.OSVersion.VersionString;
    }

    public string GetHostname()
    {
        try
        {
            return File.ReadAllText("/etc/hostname").Trim();
        }
        catch
        {
            return Environment.MachineName;
        }
    }

    public bool IsElevated()
    {
        if (Environment.UserName == "root")
        {
            return true;
        }
        try
        {
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                return geteuid() == 0;
            }
        }
        catch
        {
        }
        return false;
    }

    [DllImport("libc")]
    private static extern uint geteuid();

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
        using var timeoutCts = new CancellationTokenSource(timeoutMs);
        using var linked = CancellationTokenSource.CreateLinkedTokenSource(ct, timeoutCts.Token);
        using var reg = linked.Token.Register(() =>
        {
            try { if (!process.HasExited) process.Kill(true); } catch { }
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
        string cpuInfo = string.Empty;
        try
        {
            if (File.Exists("/proc/cpuinfo"))
            {
                cpuInfo = await File.ReadAllTextAsync("/proc/cpuinfo", ct);
            }
        }
        catch
        {
        }
        var lscpu = await RunCommandAsync("lscpu", "--json", 30000, ct);
        var combined = JsonSerializer.Serialize(new
        {
            cpuinfo = cpuInfo,
            lscpu = lscpu
        });
        return ParseJson(combined);
    }

    public async Task<List<JsonElement>> GetDiskInfoAsync(CancellationToken ct)
    {
        var json = await RunCommandAsync("lsblk", "--json", 30000, ct);
        return ParseJsonArray(json);
    }

    public async Task<JsonElement> GetMemoryInfoAsync(CancellationToken ct)
    {
        string meminfo = string.Empty;
        try
        {
            if (File.Exists("/proc/meminfo"))
            {
                meminfo = await File.ReadAllTextAsync("/proc/meminfo", ct);
            }
        }
        catch
        {
        }
        return ParseJson(JsonSerializer.Serialize(new { meminfo }));
    }

    public async Task<List<JsonElement>> GetServicesAsync(CancellationToken ct)
    {
        var json = await RunCommandAsync("systemctl", "list-units --type=service --output=json", 30000, ct);
        return ParseJsonArray(json);
    }

    public async Task<JsonElement> GetNetworkInfoAsync(CancellationToken ct)
    {
        var json = await RunCommandAsync("ip", "--json addr show", 30000, ct);
        return ParseJson(json);
    }

    public async Task<List<JsonElement>> GetSoftwareListAsync(CancellationToken ct)
    {
        string json;
        try
        {
            json = await RunCommandAsync("dpkg", "--get-selections", 60000, ct);
        }
        catch
        {
            json = await RunCommandAsync("rpm", "-qa", 60000, ct);
        }
        var lines = json.Split(new[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
        var list = new List<JsonElement>();
        foreach (var line in lines)
        {
            var parts = line.Split(new[] { ' ', '\t' }, StringSplitOptions.RemoveEmptyEntries);
            var name = parts.Length > 0 ? parts[0] : line;
            var state = parts.Length > 1 ? parts[1] : string.Empty;
            var obj = JsonSerializer.Serialize(new { name, state });
            using var doc = JsonDocument.Parse(obj);
            list.Add(doc.RootElement.Clone());
        }
        return list;
    }
}