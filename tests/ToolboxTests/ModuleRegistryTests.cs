using System.Text.Json;
using ToolboxCore.Engine;
using ToolboxCore.Models;

namespace ToolboxTests;

public class ModuleRegistryTests : IDisposable
{
    private readonly string _dir;

    public ModuleRegistryTests()
    {
        _dir = Path.Combine(Path.GetTempPath(), "ToolboxModuleTests_" + Guid.NewGuid());
        Directory.CreateDirectory(_dir);
        WriteModule(_dir, "net.json", "net-module", Area.Network, new List<string> { "Windows" });
        WriteModule(_dir, "sys.json", "sys-module", Area.System, new List<string> { "Linux" });
        WriteModule(_dir, "artec.json", "artec-module", Area.Artec, new List<string> { "Windows", "Linux" });
    }

    public void Dispose()
    {
        if (Directory.Exists(_dir)) Directory.Delete(_dir, true);
    }

    private static void WriteModule(string dir, string file, string name, Area area, List<string> os)
    {
        var path = Path.Combine(dir, file);
        var json = $$"""
        {
            "Id": "22222222-2222-2222-2222-222222222222",
            "Name": "{{name}}",
            "Description": "Test",
            "Area": {{(int)area}},
            "Os": {{JsonSerializer.Serialize(os)}},
            "Category": 0,
            "Risk": 0,
            "Reversible": false,
            "Parameters": {},
            "Permissions": [],
            "TimeoutMs": 5000,
            "Evidence": [],
            "OutputSchema": {},
            "RemoteSupport": 0,
            "Version": "1.0.0"
        }
        """;
        File.WriteAllText(path, json);
    }

    private ModuleRegistry BuildRegistry()
    {
        var registry = new ModuleRegistry();
        registry.LoadFromDirectory(_dir);
        return registry;
    }

    [Fact]
    public void GetModules_FiltersByArea()
    {
        var registry = BuildRegistry();
        var net = registry.GetModules(area: Area.Network);
        Assert.Single(net);
        Assert.Equal("net-module", net[0].Name);

        var sys = registry.GetModules(area: Area.System);
        Assert.Single(sys);
        Assert.Equal("sys-module", sys[0].Name);

        var artec = registry.GetModules(area: Area.Artec);
        Assert.Single(artec);
    }

    [Fact]
    public void GetModules_FiltersByOs()
    {
        var registry = BuildRegistry();
        var linuxModules = registry.GetModules(os: "Linux");
        Assert.Equal(2, linuxModules.Count);
        Assert.Contains(linuxModules, m => m.Name == "sys-module");
        Assert.Contains(linuxModules, m => m.Name == "artec-module");

        var winModules = registry.GetModules(os: "Windows");
        Assert.Equal(2, winModules.Count);
        Assert.Contains(winModules, m => m.Name == "net-module");
        Assert.Contains(winModules, m => m.Name == "artec-module");
    }

    [Fact]
    public void GetModule_ReturnsNull_ForUnknownId()
    {
        var registry = BuildRegistry();
        Assert.Null(registry.GetModule("does-not-exist"));
    }

    [Fact]
    public void GetModule_ReturnsModule_ForKnownId()
    {
        var registry = BuildRegistry();
        var mod = registry.GetModule("net-module");
        Assert.NotNull(mod);
        Assert.Equal(Area.Network, mod!.Area);
    }
}