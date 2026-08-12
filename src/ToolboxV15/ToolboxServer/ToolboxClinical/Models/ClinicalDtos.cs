namespace ToolboxClinical.Models;

public enum RecordStatus
{
    Active,
    Sealed,
    Void
}

public class ClinicalRecord
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string PatientName { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public string Summary { get; set; } = string.Empty;
    public string Operator { get; set; } = string.Empty;
    public DateTime RecordedAt { get; set; }
    public RecordStatus Status { get; set; }
    public DateTime? AccessExpiresAt { get; set; }
}

public class AttachmentUpload
{
    public Guid PatientId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = "application/octet-stream";
    public string Contents { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
}

public class Attachment
{
    public Guid Id { get; set; }
    public Guid PatientId { get; set; }
    public string FileName { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public string Contents { get; set; } = string.Empty;
    public DateTime StoredAt { get; set; }
    public DateTime DeleteAfter { get; set; }
}

public class AuditEntry
{
    public Guid Id { get; set; }
    public DateTime Timestamp { get; set; }
    public string Action { get; set; } = string.Empty;
    public string Actor { get; set; } = string.Empty;
    public string Target { get; set; } = string.Empty;
    public string Details { get; set; } = string.Empty;
    public string? PreviousHash { get; set; }
    public string Hash { get; set; } = string.Empty;
}