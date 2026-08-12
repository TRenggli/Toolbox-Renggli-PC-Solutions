using System.Text.Json;

namespace ToolboxClinical.Models;

public enum ProductionState
{
    Drafted,
    Scheduled,
    Running,
    Paused,
    Completed,
    Cancelled,
    Failed
}

public class ProductionJob
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string Recipe { get; set; } = string.Empty;
    public string Operator { get; set; } = string.Empty;
    public JsonElement Parameters { get; set; }
    public ProductionState State { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastStateChangedAt { get; set; }
    public string? Note { get; set; }
}

public class ProductionStateUpdate
{
    public ProductionState State { get; set; }
    public string? Note { get; set; }
}

public class Patient
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public string ExternalRef { get; set; } = string.Empty;
}

public class AccessRequest
{
    public Guid ResourceId { get; set; }
    public string Reason { get; set; } = string.Empty;
    public string MfaToken { get; set; } = string.Empty;
    public int TtlMinutes { get; set; } = 15;
}