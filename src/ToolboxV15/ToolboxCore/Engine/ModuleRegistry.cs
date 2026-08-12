using System.Text.Json;
using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class ModuleRegistry
{
    private readonly Dictionary<string, ModuleManifest> _modules = new(StringComparer.OrdinalIgnoreCase);

    public void LoadFromDirectory(string path)
    {
        _modules.Clear();
        foreach (var file in Directory.GetFiles(path, "*.json", SearchOption.AllDirectories))
        {
            try
            {
                var manifest = ManifestLoader.LoadManifest(file);
                if (!string.IsNullOrEmpty(manifest.Name))
                    _modules[manifest.Name] = manifest;
            }
            catch { }
        }
    }

    public ModuleManifest? GetModule(string id)
    {
        return _modules.TryGetValue(id, out var m) ? m : null;
    }

    public List<ModuleManifest> GetAll()
    {
        return _modules.Values.ToList();
    }

    public List<ModuleManifest> GetModules(Area? area = null, string? os = null, RiskLevel? risk = null)
    {
        return _modules.Values.Where(m =>
            (area == null || m.Area == area) &&
            (os == null || m.Os.Contains(os)) &&
            (risk == null || m.Risk == risk)).ToList();
    }
}