namespace ToolboxApi.Models;

public class ModuleUpload
{
    public string Name { get; set; } = string.Empty;
    public string Version { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Area { get; set; } = string.Empty;
    public string Risk { get; set; } = "WR";
    public bool Reversible { get; set; }
    public int TimeoutMs { get; set; } = 30000;
    public List<string> Evidence { get; set; } = new();
}