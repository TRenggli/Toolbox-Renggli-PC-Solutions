using System.Diagnostics;
using System.Text.Json;

namespace ToolboxCore.Platform;

public class MacOSAbstraction : Abstractions.IOSAbstraction
{
    public string GetOsName() => "macos";

    public string GetOsVersion()
    {
        try
        {
            var swVers = RunCommandAsync("/usr/bin/sw_vers", "-productVersion", 10000, CancellationToken.None).GetAwaiter().GetResult();
            return swVers.Trim();
        }
        catch
        {
            return Environment.OSVersion.VersionString;
        }
    }

    public string GetHostname()
    {
        try
        {
            var host = RunCommandAsync("/bin/hostname", "", 10000, CancellationToken.None).GetAwaiter().GetResult();
            return host.Trim();
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
            var groups = RunCommandAsync("/usr/bin/id", "-G", 10000, CancellationToken.None).GetAwaiter().GetResult();
            foreach (var g in groups.Split(new[] { ' ', '\t', '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries))
            {
                if (g == "0" || g == "80" || g == "admin")
                {
                    return true;
                }
            }
        }
        catch
        {
        }
        return false;
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
        var json = await RunCommandAsync("/usr/sbin/system_profiler", "SPHardwareDataType -json", 60000, ct);
        return ParseJson(json);
    }

    public async Task<List<JsonElement>> GetDiskInfoAsync(CancellationToken ct)
    {
        var plist = await RunCommandAsync("/usr/sbin/diskutil", "list -plist", 30000, ct);
        string json;
        try
        {
            var converted = await RunCommandAsync("/usr/bin/plutil", $"-convert json -o - - <<< {ShellEscape(plist)}", 30000, ct);
            json = converted;
        }
        catch
        {
            json = JsonSerializer.Serialize(new { plist });
        }
        var list = ParseJsonArray(json);
        if (list.Count == 0)
        {
            list.Add(ParseJson(json));
        }
        return list;
    }

    public async Task<JsonElement> GetMemoryInfoAsync(CancellationToken ct)
    {
        var json = await RunCommandAsync("/usr/sbin/sysctl", "hw.memsize", 30000, ct);
        return ParseJson(JsonSerializer.Serialize(new { raw = json }));
    }

    public async Task<List<JsonElement>> GetServicesAsync(CancellationToken ct)
    {
        var raw = await RunCommandAsync("/bin/launchctl", "list", 30000, ct);
        var lines = raw.Split(new[] { '\n', '\r' }, StringSplitOptions.RemoveEmptyEntries);
        var list = new List<JsonElement>();
        foreach (var line in lines)
        {
            var parts = line.Split(new[] { '\t' }, StringSplitOptions.None);
            if (parts.Length < 3) continue;
            var obj = JsonSerializer.Serialize(new
            {
                pid = parts[0],
                status = parts[1],
                label = parts[2]
            });
            using var doc = JsonDocument.Parse(obj);
            list.Add(doc.RootElement.Clone());
        }
        return list;
    }

    public async Task<JsonElement> GetNetworkInfoAsync(CancellationToken ct)
    {
        var raw = await RunCommandAsync("/sbin/ifconfig", "", 30000, ct);
        return ParseJson(JsonSerializer.Serialize(new { raw }));
    }

    public async Task<List<JsonElement>> GetSoftwareListAsync(CancellationToken ct)
    {
        var json = await RunCommandAsync("/usr/sbin/system_profiler", "SPApplicationsDataType -json", 60000, ct);
        try
        {
            using var doc = JsonDocument.Parse(json);
            var root = doc.RootElement.Clone();
            var list = new List<JsonElement>();
            foreach (var prop in root.EnumerateObject())
            {
                if (prop.Value.ValueKind == JsonValueKind.Array)
                {
                    foreach (var item in prop.Value.EnumerateArray())
                    {
                        list.Add(item.Clone());
                    }
                }
                else if (prop.Value.ValueKind == JsonValueKind.Object)
                {
                    list.Add(prop.Value.Clone());
                }
            }
            if (list.Count > 0)
            {
                return list;
            }
            list.Add(root);
            return list;
        }
        catch
        {
            return ParseJsonArray(json);
        }
    }

    private static string ShellEscape(string s)
    {
        return "'" + s.Replace("'", "'\\''") + "'";
    }
}