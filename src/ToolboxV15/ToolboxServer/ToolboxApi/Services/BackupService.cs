using ToolboxApi.Models;

namespace ToolboxApi.Services;

public sealed class BackupService
{
    public Task<Guid> TriggerAsync(BackupRequest req)
    {
        var id = Guid.NewGuid();
        return Task.FromResult(id);
    }

    public Task<BackupRecord> GetAsync(Guid id)
    {
        return Task.FromResult(new BackupRecord
        {
            Id = id,
            Target = "operational",
            Scope = "full",
            Destination = "/backups",
            Status = BackupStatus.Completed,
            StartedAt = DateTime.UtcNow,
            FinishedAt = DateTime.UtcNow
        });
    }
}