using System.Security.Cryptography;
using System.Text;
using ToolboxApi.Models;

namespace ToolboxApi.Services;

public sealed class AgentService
{
    private readonly Dictionary<Guid, AgentRecord> _agents = new();
    private readonly object _gate = new();

    public EnrollResponse Enroll(EnrollRequest req, string remoteIp)
    {
        var id = Guid.NewGuid();
        var cert = GenerateClientCert(id, req.Hostname);
        var now = DateTime.UtcNow;
        var record = new AgentRecord
        {
            Id = id,
            Hostname = req.Hostname,
            Os = req.Os,
            OsVersion = req.OsVersion,
            ClientCert = cert,
            State = AgentState.Online,
            EnrolledAt = now,
            LastSeen = now,
            Tags = new Dictionary<string, string> { ["enrolledFrom"] = remoteIp }
        };

        lock (_gate)
        {
            _agents[id] = record;
        }

        return new EnrollResponse
        {
            AgentId = id,
            AgentName = req.Hostname,
            ClientCert = cert,
            EnrolledAt = now,
            ServerUrl = "https://toolbox.local/api"
        };
    }

    public List<AgentRecord> List()
    {
        lock (_gate) return _agents.Values.ToList();
    }

    public AgentStatus? GetStatus(Guid id)
    {
        lock (_gate)
        {
            return _agents.TryGetValue(id, out var a)
                ? new AgentStatus { Id = a.Id, Hostname = a.Hostname, State = a.State, LastSeen = a.LastSeen }
                : null;
        }
    }

    public bool Heartbeat(Guid id)
    {
        lock (_gate)
        {
            if (!_agents.TryGetValue(id, out var a)) return false;
            a.LastSeen = DateTime.UtcNow;
            a.State = AgentState.Online;
            return true;
        }
    }

    private static string GenerateClientCert(Guid agentId, string hostname)
    {
        var payload = $"{agentId}:{hostname}:{DateTime.UtcNow:O}";
        var bytes = SHA256.HashData(Encoding.UTF8.GetBytes(payload));
        return "TBX-CERT-" + Convert.ToHexString(bytes).ToLowerInvariant();
    }
}