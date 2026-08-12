using ToolboxCore.Abstractions;

namespace ToolboxCore.Artec;

public class SoftwareAdapterRegistry
{
    private readonly List<SoftwareAdapter> _adapters;
    private readonly IOSAbstraction _os;

    public SoftwareAdapterRegistry(IOSAbstraction os)
        : this(os, SoftwareAdapter.BuildStandardAdapters().ToList())
    {
    }

    public SoftwareAdapterRegistry(IOSAbstraction os, List<SoftwareAdapter> adapters)
    {
        _os = os;
        _adapters = adapters;
    }

    public IReadOnlyList<SoftwareAdapter> GetAdapters() => _adapters;

    public async Task<List<SoftwareAdapterResult>> DetectAllAsync(CancellationToken ct)
    {
        var results = new List<SoftwareAdapterResult>();
        foreach (var adapter in _adapters)
        {
            try
            {
                var result = await adapter.DetectAsync(_os, ct);
                results.Add(result);
            }
            catch (Exception ex)
            {
                results.Add(new SoftwareAdapterResult(
                    adapter.Name,
                    false,
                    string.Empty,
                    string.Empty,
                    adapter.CompatibleDevices,
                    new List<string> { $"Detection failed: {ex.Message}" }
                ));
            }
        }
        return results;
    }
}