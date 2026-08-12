using System.Runtime.InteropServices;
using System.Text.Json;
using ToolboxCore.Abstractions;

namespace ToolboxCore.Artec;

public class DeviceDetector
{
    private readonly IOSAbstraction _os;

    public DeviceDetector(IOSAbstraction os)
    {
        _os = os;
    }

    public async Task<DetectionResult> DetectAsync(TimeSpan timeout, CancellationToken ct)
    {
        var scanners = new List<string>();
        var mills = new List<string>();
        var networkAdapters = new List<string>();
        var issues = new List<string>();
        var gpuInfo = string.Empty;
        var usb3 = false;

        if (!OperatingSystem.IsWindows())
        {
            issues.Add("Device detection is only supported on Windows.");
            return new DetectionResult(scanners, mills, gpuInfo, usb3, networkAdapters, issues);
        }

        try
        {
            var scannerJson = await RunPsAsync(
                "Get-PnpDevice | Where-Object {$_.FriendlyName -like '*UP3D*'} | ConvertTo-Json",
                timeout, ct);
            ExtractFriendlyNames(scannerJson, scanners);
        }
        catch (Exception ex)
        {
            issues.Add($"Scanner detection failed: {ex.Message}");
        }

        try
        {
            var millResults = await DetectMillsAsync(timeout, ct);
            mills.AddRange(millResults);
        }
        catch (Exception ex)
        {
            issues.Add($"Mill detection failed: {ex.Message}");
        }

        try
        {
            var gpuJson = await RunPsAsync(
                "Get-CimInstance Win32_VideoController | ConvertTo-Json",
                timeout, ct);
            gpuInfo = ExtractGpuName(gpuJson);
        }
        catch (Exception ex)
        {
            issues.Add($"GPU detection failed: {ex.Message}");
        }

        try
        {
            var usbJson = await RunPsAsync(
                "Get-PnpDevice | Where-Object {$_.Class -eq 'USB' -and $_.FriendlyName -like '*3.0*'} | ConvertTo-Json",
                timeout, ct);
            usb3 = HasUsb30(usbJson);
        }
        catch (Exception ex)
        {
            issues.Add($"USB 3.0 check failed: {ex.Message}");
        }

        try
        {
            var netJson = await RunPsAsync(
                "Get-NetAdapter | Where-Object {$_.Status -eq 'Up'} | Select-Object Name,InterfaceDescription | ConvertTo-Json",
                timeout, ct);
            ExtractNetworkAdapters(netJson, networkAdapters);
        }
        catch (Exception ex)
        {
            issues.Add($"Network adapter detection failed: {ex.Message}");
        }

        return new DetectionResult(scanners, mills, gpuInfo, usb3, networkAdapters, issues);
    }

    private async Task<string> RunPsAsync(string script, TimeSpan timeout, CancellationToken ct)
    {
        return await _os.RunCommandAsync("powershell",
            $"-NoProfile -Command \"{script}\"",
            (int)timeout.TotalMilliseconds, ct);
    }

    private static void ExtractFriendlyNames(string json, List<string> target)
    {
        if (string.IsNullOrWhiteSpace(json)) return;
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in doc.RootElement.EnumerateArray())
                {
                    AddFriendlyName(item, target);
                }
            }
            else if (doc.RootElement.ValueKind == JsonValueKind.Object)
            {
                AddFriendlyName(doc.RootElement, target);
            }
        }
        catch
        {
        }
    }

    private static void AddFriendlyName(JsonElement element, List<string> target)
    {
        if (element.TryGetProperty("FriendlyName", out var fn) &&
            fn.ValueKind == JsonValueKind.String)
        {
            var name = fn.GetString();
            if (!string.IsNullOrWhiteSpace(name) && !target.Contains(name))
            {
                target.Add(name);
            }
        }
    }

    private static string ExtractGpuName(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return string.Empty;
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in doc.RootElement.EnumerateArray())
                {
                    if (item.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String)
                    {
                        return n.GetString() ?? string.Empty;
                    }
                }
            }
            else if (doc.RootElement.ValueKind == JsonValueKind.Object)
            {
                if (doc.RootElement.TryGetProperty("Name", out var n) && n.ValueKind == JsonValueKind.String)
                {
                    return n.GetString() ?? string.Empty;
                }
            }
        }
        catch
        {
        }
        return string.Empty;
    }

    private static bool HasUsb30(string json)
    {
        if (string.IsNullOrWhiteSpace(json)) return false;
        try
        {
            using var doc = JsonDocument.Parse(json);
            return doc.RootElement.ValueKind == JsonValueKind.Array
                ? doc.RootElement.GetArrayLength() > 0
                : doc.RootElement.ValueKind == JsonValueKind.Object;
        }
        catch
        {
            return false;
        }
    }

    private static void ExtractNetworkAdapters(string json, List<string> target)
    {
        if (string.IsNullOrWhiteSpace(json)) return;
        try
        {
            using var doc = JsonDocument.Parse(json);
            void AddItem(JsonElement item)
            {
                if (item.TryGetProperty("InterfaceDescription", out var d) && d.ValueKind == JsonValueKind.String)
                {
                    var name = d.GetString();
                    if (!string.IsNullOrWhiteSpace(name) && !target.Contains(name))
                    {
                        target.Add(name);
                    }
                }
            }
            if (doc.RootElement.ValueKind == JsonValueKind.Array)
            {
                foreach (var item in doc.RootElement.EnumerateArray()) AddItem(item);
            }
            else if (doc.RootElement.ValueKind == JsonValueKind.Object)
            {
                AddItem(doc.RootElement);
            }
        }
        catch
        {
        }
    }

    private async Task<List<string>> DetectMillsAsync(TimeSpan timeout, CancellationToken ct)
    {
        var mills = new List<string>();
        var ipTargets = new List<string>();
        for (int i = 2; i <= 254; i++)
        {
            ipTargets.Add($"192.168.1.{i}");
        }

        var pingScript = string.Join("; ", ipTargets.Select(ip =>
            $"try {{ if (Test-Connection -ComputerName {ip} -Count 1 -Quiet -ErrorAction SilentlyContinue) {{ '{ip}' }} }} catch {{ }}"));

        var result = await RunPsAsync(pingScript, timeout, ct);
        if (!string.IsNullOrWhiteSpace(result))
        {
            foreach (var line in result.Split(new[] { '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries))
            {
                var trimmed = line.Trim();
                if (!string.IsNullOrWhiteSpace(trimmed))
                {
                    mills.Add(trimmed);
                }
            }
        }

        return mills;
    }
}