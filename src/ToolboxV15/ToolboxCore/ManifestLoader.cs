using System.Text.Json;

namespace ToolboxCore;

public static class ManifestLoader
{
    private static readonly JsonSerializerOptions Options = new()
    {
        PropertyNameCaseInsensitive = true
    };

    public static Models.ModuleManifest LoadManifest(string path)
    {
        var json = File.ReadAllText(path);
        return JsonSerializer.Deserialize<Models.ModuleManifest>(json, Options)
            ?? throw new InvalidOperationException($"Failed to load manifest: {path}");
    }

    public static List<Models.ModuleManifest> LoadAllManifests(string directory)
    {
        var manifests = new List<Models.ModuleManifest>();
        if (!Directory.Exists(directory)) return manifests;
        foreach (var file in Directory.GetFiles(directory, "*.json", SearchOption.AllDirectories))
        {
            try { manifests.Add(LoadManifest(file)); }
            catch { }
        }
        return manifests;
    }
}