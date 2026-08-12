using ToolboxClinical.Models;

namespace ToolboxClinical.Services;

public sealed class RecordService
{
    private readonly Dictionary<Guid, ClinicalRecord> _records = new();
    private readonly object _gate = new();

    public ClinicalRecord Create(ClinicalRecord record)
    {
        record.Id = Guid.NewGuid();
        record.RecordedAt = DateTime.UtcNow;
        record.Status = RecordStatus.Active;
        record.AccessExpiresAt = DateTime.UtcNow.AddMinutes(15);
        lock (_gate) _records[record.Id] = record;
        return record;
    }

    public ClinicalRecord? Get(Guid id, TimeSpan ttl)
    {
        lock (_gate)
        {
            if (!_records.TryGetValue(id, out var r)) return null;
            if (r.AccessExpiresAt is null || r.AccessExpiresAt < DateTime.UtcNow)
            {
                r.AccessExpiresAt = DateTime.UtcNow.Add(ttl);
            }
            return r;
        }
    }

    public List<ClinicalRecord> GetPatientHistory(Guid patientId)
    {
        lock (_gate)
        {
            return _records.Values
                .Where(r => r.PatientId == patientId)
                .OrderBy(r => r.RecordedAt)
                .ToList();
        }
    }

    public bool Seal(Guid id)
    {
        lock (_gate)
        {
            if (!_records.TryGetValue(id, out var r)) return false;
            r.Status = RecordStatus.Sealed;
            r.AccessExpiresAt = null;
            return true;
        }
    }
}