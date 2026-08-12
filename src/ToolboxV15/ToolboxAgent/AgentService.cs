using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Runtime.InteropServices;

namespace ToolboxAgent;

public sealed class AgentService : IDisposable
{
    private readonly HttpClient _http = new();
    private readonly AgentConfig _config;
    private readonly CancellationTokenSource _cts = new();
    private DateTime _lastHeartbeat = DateTime.MinValue;

    public AgentConfig Config => _config;

    public AgentService(AgentConfig config)
    {
        _config = config;
        _http.BaseAddress = new Uri(_config.ServerUrl.TrimEnd('/'));
        if (!string.IsNullOrWhiteSpace(_config.EnrollToken))
            _http.DefaultRequestHeaders.Add("X-API-Key", _config.EnrollToken);
    }

    public async Task<EnrollResult?> EnrollAsync(CancellationToken ct = default)
    {
        var req = new
        {
            Token = _config.EnrollToken,
            Hostname = _config.Hostname,
            Os = _config.Os,
            OsVersion = _config.OsVersion
        };
        var resp = await _http.PostAsJsonAsync("/api/agents/enroll", req, ct);
        if (!resp.IsSuccessStatusCode) return null;
        var body = await resp.Content.ReadFromJsonAsync<EnrollResult>(cancellationToken: ct);
        return body;
    }

    public async Task<bool> HeartbeatAsync(CancellationToken ct = default)
    {
        if (!Guid.TryParse(_config.AgentId, out var id)) return false;
        try
        {
            var resp = await _http.GetAsync($"/api/agents/{id}/status", ct);
            _lastHeartbeat = DateTime.UtcNow;
            return resp.IsSuccessStatusCode;
        }
        catch { return false; }
    }

    public async Task RunAsync(CancellationToken ct = default)
    {
        if (!Guid.TryParse(_config.AgentId, out var id))
        {
            Console.Error.WriteLine("AgentId not configured; run 'enroll' first.");
            return;
        }

        var linked = CancellationTokenSource.CreateLinkedTokenSource(_cts.Token, ct);
        var token = linked.Token;
        var nextHeartbeat = DateTime.MinValue;

        while (!token.IsCancellationRequested)
        {
            try
            {
                if (DateTime.UtcNow >= nextHeartbeat)
                {
                    await HeartbeatAsync(token);
                    nextHeartbeat = DateTime.UtcNow.AddSeconds(_config.HeartbeatSeconds);
                }

                var job = await PollNextJobAsync(id, token);
                if (job is not null)
                {
                    await ExecuteJobAsync(job, token);
                }

                await Task.Delay(TimeSpan.FromSeconds(_config.PollIntervalSeconds), token);
            }
            catch (OperationCanceledException) { break; }
            catch (Exception ex)
            {
                Console.Error.WriteLine($"[agent] loop error: {ex.Message}");
                await Task.Delay(TimeSpan.FromSeconds(_config.PollIntervalSeconds), token);
            }
        }
    }

    private async Task<JobDto?> PollNextJobAsync(Guid agentId, CancellationToken ct)
    {
        try
        {
            var resp = await _http.GetAsync($"/api/jobs?agentId={agentId}&status=Queued", ct);
            if (!resp.IsSuccessStatusCode) return null;
            var jobs = await resp.Content.ReadFromJsonAsync<List<JobDto>>(cancellationToken: ct);
            return jobs?.FirstOrDefault();
        }
        catch { return null; }
    }

    private async Task ExecuteJobAsync(JobDto job, CancellationToken ct)
    {
        Console.WriteLine($"[agent] executing job {job.Id} module={job.ModuleId}");
        await ReportAsync(job.Id, "Running", null, null, ct);

        try
        {
            await Task.Delay(100, ct);
            var result = new Dictionary<string, object>
            {
                ["status"] = "ok",
                ["module"] = job.ModuleId,
                ["executedAt"] = DateTime.UtcNow
            };
            await ReportAsync(job.Id, "Completed", result, null, ct);
        }
        catch (Exception ex)
        {
            await ReportAsync(job.Id, "Failed", null, ex.Message, ct);
        }
    }

    private async Task ReportAsync(Guid jobId, string status, Dictionary<string, object>? result, string? error, CancellationToken ct)
    {
        var payload = new { Status = status, Result = result, Error = error };
        try { await _http.PostAsJsonAsync($"/api/jobs/{jobId}/report", payload, ct); }
        catch (Exception ex) { Console.Error.WriteLine($"[agent] report failed: {ex.Message}"); }
    }

    public void Stop() => _cts.Cancel();

    public void Dispose()
    {
        _cts.Cancel();
        _http.Dispose();
    }
}

public sealed class EnrollResult
{
    public Guid AgentId { get; set; }
    public string AgentName { get; set; } = string.Empty;
    public string ClientCert { get; set; } = string.Empty;
    public DateTime EnrolledAt { get; set; }
    public string ServerUrl { get; set; } = string.Empty;
}

public sealed class JobDto
{
    public Guid Id { get; set; }
    public Guid AgentId { get; set; }
    public string ModuleId { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
}