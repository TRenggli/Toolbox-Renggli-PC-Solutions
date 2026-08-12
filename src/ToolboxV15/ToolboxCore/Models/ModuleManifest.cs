using System.Text.Json;

namespace ToolboxCore.Models;

public class ModuleManifest
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public Area Area { get; set; }
    public List<string> Os { get; set; } = new();
    public ModuleCategory Category { get; set; }
    public RiskLevel Risk { get; set; }
    public bool Reversible { get; set; }
    public JsonElement Parameters { get; set; }
    public List<string> Permissions { get; set; } = new();
    public int TimeoutMs { get; set; }
    public List<string> Evidence { get; set; } = new();
    public JsonElement OutputSchema { get; set; }
    public string? AssociatedRepair { get; set; }
    public RemoteSupport RemoteSupport { get; set; }
    public string? RollbackModule { get; set; }
    public string Version { get; set; } = string.Empty;
    public string? MinOsVersion { get; set; }
    public string? MaxOsVersion { get; set; }
    public List<string> Dependencies { get; set; } = new();
    public List<string> Tags { get; set; } = new();
}