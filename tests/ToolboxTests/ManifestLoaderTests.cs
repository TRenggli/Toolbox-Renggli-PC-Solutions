using ToolboxCore;
using ToolboxCore.Models;

namespace ToolboxTests;

public class ManifestLoaderTests : IDisposable
{
    private readonly List<string> _tempDirs = new();

    private string NewTempDir()
    {
        var dir = Path.Combine(Path.GetTempPath(), "ToolboxManifestTests_" + Guid.NewGuid());
        Directory.CreateDirectory(dir);
        _tempDirs.Add(dir);
        return dir;
    }

    private static string WriteManifest(string dir, string name, Area area = Area.System)
    {
        var path = Path.Combine(dir, name);
        var json = $$"""
        {
            "Id": "11111111-1111-1111-1111-111111111111",
            "Name": "test-module",
            "Description": "Test module",
            "Area": {{(int)area}},
            "Os": ["Windows"],
            "Category": 0,
            "Risk": 0,
            "Reversible": false,
            "Parameters": {},
            "Permissions": [],
            "TimeoutMs": 10000,
            "Evidence": [],
            "OutputSchema": {},
            "RemoteSupport": 0,
            "Version": "1.0.0"
        }
        """;
        File.WriteAllText(path, json);
        return path;
    }

    public void Dispose()
    {
        foreach (var dir in _tempDirs)
        {
            if (Directory.Exists(dir))
                Directory.Delete(dir, recursive: true);
        }
        _tempDirs.Clear();
    }

    [Fact]
    public void LoadManifest_ReturnsValidManifest()
    {
        var dir = NewTempDir();
        var path = WriteManifest(dir, "m.json");
        var manifest = ManifestLoader.LoadManifest(path);
        Assert.Equal("test-module", manifest.Name);
        Assert.Equal(Area.System, manifest.Area);
        Assert.Contains("Windows", manifest.Os);
    }

    [Fact]
    public void LoadAllManifests_LoadsFromDirectory()
    {
        var dir = NewTempDir();
        WriteManifest(dir, "a.json");
        WriteManifest(dir, "b.json");
        var all = ManifestLoader.LoadAllManifests(dir);
        Assert.Equal(2, all.Count);
        Assert.All(all, m => Assert.Equal("test-module", m.Name));
    }
}