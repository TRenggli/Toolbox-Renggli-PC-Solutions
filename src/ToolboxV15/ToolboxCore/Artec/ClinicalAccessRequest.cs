namespace ToolboxCore.Artec;

public record ClinicalAccessRequest(
    Guid RequestId,
    string RequesterId,
    string PatientId,
    string Reason,
    string MfaToken,
    DateTime Timestamp,
    DateTime ExpiresAt,
    bool IsApproved
);