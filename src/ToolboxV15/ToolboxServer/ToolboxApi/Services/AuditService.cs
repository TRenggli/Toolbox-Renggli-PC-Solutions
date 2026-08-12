using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using ToolboxApi.Models;

namespace ToolboxApi.Services;

public sealed class AuditService
{
    private readonly List<AuditEntry> _entries = new();
    private readonly object _gate = new();
    private string? _lastHash;

    public Task<AuditEntry> AppendAsync(AuditEntry entry)
    {
        entry.Id = Guid.NewGuid();
        entry.Timestamp = DateTime.UtcNow;
        entry.PreviousHash = _lastHash;
        entry.Hash = ComputeHash(entry);
        lock (_gate)
        {
            _entries.Add(entry);
            _lastHash = entry.Hash;
        }
        return Task.FromResult(entry);
    }

    public List<AuditEntry> GetLatest(int limit)
    {
        lock (_gate)
        {
            return _entries
                .Skip(Math.Max(0, _entries.Count - limit))
                .ToList();
        }
    }

    public bool VerifyChain()
    {
        string? prev = null;
        lock (_gate)
        {
            foreach (var e in _entries)
            {
                if (e.PreviousHash != prev) return false;
                if (e.Hash != ComputeHash(e)) return false;
                prev = e.Hash;
            }
        }
        return true;
    }

    private static string ComputeHash(AuditEntry e)
    {
        var payload = $"{e.Id}|{e.Timestamp:O}|{e.Action}|{e.Actor}|{e.Target}|{e.Details}|{e.PreviousHash ?? string.Empty}";
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(payload));
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}