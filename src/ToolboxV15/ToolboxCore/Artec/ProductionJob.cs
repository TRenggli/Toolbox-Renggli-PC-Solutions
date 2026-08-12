namespace ToolboxCore.Artec;

public record ProductionJob(
    Guid Id,
    string PatientCaseRef,
    ProductionState State,
    ProductionRole AssignedRole,
    string? CamSoftware,
    string? MillMachine,
    List<FileVersion> VersionedFiles,
    List<ProductionEvent> Events,
    DateTime CreatedAt,
    DateTime UpdatedAt
)
{
    public static ProductionJob CreateNew(string patientCaseRef, ProductionRole assignedRole)
    {
        var now = DateTime.UtcNow;
        return new ProductionJob(
            Guid.NewGuid(),
            patientCaseRef,
            ProductionState.Received,
            assignedRole,
            null,
            null,
            new List<FileVersion>(),
            new List<ProductionEvent>(),
            now,
            now
        );
    }

    public ProductionJob WithState(ProductionState newState, ProductionEvent evt)
    {
        return this with
        {
            State = newState,
            Events = Events.Append(evt).ToList(),
            UpdatedAt = DateTime.UtcNow
        };
    }

    public ProductionJob WithCamMill(string camSoftware, string millMachine)
    {
        return this with
        {
            CamSoftware = camSoftware,
            MillMachine = millMachine,
            UpdatedAt = DateTime.UtcNow
        };
    }

    public ProductionJob WithFileVersion(FileVersion version)
    {
        return this with
        {
            VersionedFiles = VersionedFiles.Append(version).ToList(),
            UpdatedAt = DateTime.UtcNow
        };
    }
}