using ToolboxClinical.Models;

namespace ToolboxClinical.Services;

public sealed class RetentionService
{
    private readonly Dictionary<Guid, Attachment> _attachments = new();
    private readonly object _gate = new();

    public RetentionService(int retentionDays)
    {
        RetentionDays = retentionDays;
    }

    public int RetentionDays { get; }

    public Attachment Store(AttachmentUpload upload, DateTime now)
    {
        var a = new Attachment
        {
            Id = Guid.NewGuid(),
            PatientId = upload.PatientId,
            FileName = upload.FileName,
            ContentType = upload.ContentType,
            Contents = upload.Contents,
            StoredAt = now,
            DeleteAfter = now.AddDays(RetentionDays)
        };
        lock (_gate) _attachments[a.Id] = a;
        return a;
    }

    public Attachment? Get(Guid id)
    {
        lock (_gate) return _attachments.TryGetValue(id, out var a) ? a : null;
    }

    public int PurgeExpired(DateTime now)
    {
        lock (_gate)
        {
            var expired = _attachments.Where(kvp => kvp.Value.DeleteAfter <= now).ToList();
            foreach (var kvp in expired) _attachments.Remove(kvp.Key);
            return expired.Count;
        }
    }
}