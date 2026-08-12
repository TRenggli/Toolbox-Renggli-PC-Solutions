using ToolboxApi.Models;

namespace ToolboxApi.Services;

public sealed class JobService
{
    private readonly Dictionary<Guid, JobRecord> _jobs = new();
    private readonly object _gate = new();

    public JobRecord Enqueue(JobRequest req)
    {
        var job = new JobRecord
        {
            Id = Guid.NewGuid(),
            AgentId = req.AgentId,
            ModuleId = req.ModuleId,
            Parameters = req.Parameters,
            Force = req.Force,
            TimeoutMs = req.TimeoutMs,
            Status = JobStatus.Queued,
            CreatedAt = DateTime.UtcNow
        };
        lock (_gate) _jobs[job.Id] = job;
        return job;
    }

    public List<JobRecord> List(string? status)
    {
        lock (_gate)
        {
            var q = _jobs.Values.AsEnumerable();
            if (!string.IsNullOrEmpty(status) &&
               Enum.TryParse<JobStatus>(status, true, out var s))
            {
                q = q.Where(j => j.Status == s);
            }
            return q.OrderByDescending(j => j.CreatedAt).ToList();
        }
    }

    public JobRecord? Get(Guid id)
    {
        lock (_gate) return _jobs.TryGetValue(id, out var j) ? j : null;
    }

    public JobRecord? ClaimNext(Guid agentId)
    {
        lock (_gate)
        {
            var job = _jobs.Values
                .FirstOrDefault(j => j.AgentId == agentId && j.Status == JobStatus.Queued);
            if (job is null) return null;
            job.Status = JobStatus.Dispatched;
            job.DispatchedAt = DateTime.UtcNow;
            return job;
        }
    }

    public bool Report(Guid id, JobStatus status, Dictionary<string, object>? result, string? error)
    {
        lock (_gate)
        {
            if (!_jobs.TryGetValue(id, out var j)) return false;
            j.Status = status;
            j.Result = result;
            j.Error = error;
            j.CompletedAt = DateTime.UtcNow;
            return true;
        }
    }
}