namespace ToolboxApi.Models;

public class BackupRequest
{
    public string Target { get; set; } = "operational";
    public string Scope { get; set; } = "full";
    public string Destination { get; set; } = string.Empty;
}

public class BackupRecord
{
    public Guid Id { get; set; }
    public string Target { get; set; } = string.Empty;
    public string Scope { get; set; } = string.Empty;
    public string Destination { get; set; } = string.Empty;
    public BackupStatus Status { get; set; }
    public DateTime StartedAt { get; set; }
    public DateTime? FinishedAt { get; set; }
    public string? Error { get; set; }
}

public enum BackupStatus
{
    Pending,
    Running,
    Completed,
    Failed
}