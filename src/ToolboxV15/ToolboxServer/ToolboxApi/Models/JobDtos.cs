namespace ToolboxApi.Models;

public enum JobStatus
{
    Queued,
    Dispatched,
    Running,
    Completed,
    Failed,
    Cancelled
}

public class JobRequest
{
    public Guid AgentId { get; set; }
    public string ModuleId { get; set; } = string.Empty;
    public Dictionary<string, object> Parameters { get; set; } = new();
    public bool Force { get; set; }
    public int TimeoutMs { get; set; } = 30000;
}

public class JobRecord
{
    public Guid Id { get; set; }
    public Guid AgentId { get; set; }
    public string ModuleId { get; set; } = string.Empty;
    public Dictionary<string, object> Parameters { get; set; } = new();
    public bool Force { get; set; }
    public int TimeoutMs { get; set; }
    public JobStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? DispatchedAt { get; set; }
    public DateTime? CompletedAt { get; set; }
    public string? Error { get; set; }
    public Dictionary<string, object>? Result { get; set; }
}