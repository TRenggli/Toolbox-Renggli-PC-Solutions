using ToolboxClinical.Models;

namespace ToolboxClinical.Services;

public sealed class ProductionService
{
    private readonly Dictionary<Guid, ProductionJob> _jobs = new();
    private readonly object _gate = new();

    public ProductionJob Create(ProductionJob job)
    {
        job.Id = Guid.NewGuid();
        job.State = ProductionState.Drafted;
        job.CreatedAt = DateTime.UtcNow;
        job.LastStateChangedAt = job.CreatedAt;
        lock (_gate) _jobs[job.Id] = job;
        return job;
    }

    public ProductionJob? Get(Guid id)
    {
        lock (_gate) return _jobs.TryGetValue(id, out var j) ? j : null;
    }

    public bool UpdateState(Guid id, ProductionState state, string? note)
    {
        lock (_gate)
        {
            if (!_jobs.TryGetValue(id, out var j)) return false;
            j.State = state;
            j.LastStateChangedAt = DateTime.UtcNow;
            j.Note = note;
            return true;
        }
    }

    public List<ProductionJob> List()
    {
        lock (_gate) return _jobs.Values.ToList();
    }
}