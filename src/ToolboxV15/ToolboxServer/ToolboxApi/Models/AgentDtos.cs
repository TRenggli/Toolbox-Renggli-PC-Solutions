namespace ToolboxApi.Models;

public class EnrollRequest
{
    public string Token { get; set; } = string.Empty;
    public string Hostname { get; set; } = string.Empty;
    public string Os { get; set; } = string.Empty;
    public string OsVersion { get; set; } = string.Empty;
}

public class EnrollResponse
{
    public Guid AgentId { get; set; }
    public string AgentName { get; set; } = string.Empty;
    public string ClientCert { get; set; } = string.Empty;
    public DateTime EnrolledAt { get; set; }
    public string ServerUrl { get; set; } = string.Empty;
}

public enum AgentState
{
    Pending,
    Online,
    Offline,
    Degraded
}

public class AgentRecord
{
    public Guid Id { get; set; }
    public string Hostname { get; set; } = string.Empty;
    public string Os { get; set; } = string.Empty;
    public string OsVersion { get; set; } = string.Empty;
    public string ClientCert { get; set; } = string.Empty;
    public AgentState State { get; set; }
    public DateTime EnrolledAt { get; set; }
    public DateTime LastSeen { get; set; }
    public Dictionary<string, string> Tags { get; set; } = new();
}

public class AgentStatus
{
    public Guid Id { get; set; }
    public string Hostname { get; set; } = string.Empty;
    public AgentState State { get; set; }
    public DateTime LastSeen { get; set; }
}