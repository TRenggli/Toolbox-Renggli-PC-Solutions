using System.Security.Cryptography;

namespace ToolboxCore.Artec;

public class ProductionManager
{
    private readonly Dictionary<Guid, ProductionJob> _jobs = new();
    private readonly object _lock = new();

    public ProductionJob CreateJob(string patientCaseRef, ProductionRole assignedRole = ProductionRole.Reception)
    {
        if (string.IsNullOrWhiteSpace(patientCaseRef))
        {
            throw new ArgumentException("Patient case reference is required.", nameof(patientCaseRef));
        }

        var job = ProductionJob.CreateNew(patientCaseRef, assignedRole);
        lock (_lock)
        {
            _jobs[job.Id] = job;
        }
        return job;
    }

    public ProductionJob? GetJob(Guid id)
    {
        lock (_lock)
        {
            return _jobs.TryGetValue(id, out var job) ? job : null;
        }
    }

    public IReadOnlyList<ProductionJob> GetAllJobs()
    {
        lock (_lock)
        {
            return _jobs.Values.ToList();
        }
    }

    public ProductionJob? UpdateState(
        Guid jobId,
        ProductionState newState,
        string @operator,
        string software,
        string softwareVersion,
        string machine,
        string result)
    {
        lock (_lock)
        {
            if (!_jobs.TryGetValue(jobId, out var job)) return null;

            var evt = new ProductionEvent(
                Guid.NewGuid(),
                DateTime.UtcNow,
                @operator,
                software,
                softwareVersion,
                machine,
                result,
                job.State,
                newState
            );

            job = job.WithState(newState, evt);
            _jobs[jobId] = job;
            return job;
        }
    }

    public ProductionJob? AssignCamAndMill(Guid jobId, string camSoftware, string millModel)
    {
        var (valid, reason) = ValidateCompatibility(camSoftware, millModel);
        if (!valid)
        {
            throw new InvalidOperationException(reason);
        }

        lock (_lock)
        {
            if (!_jobs.TryGetValue(jobId, out var job)) return null;
            job = job.WithCamMill(camSoftware, millModel);
            _jobs[jobId] = job;
            return job;
        }
    }

    public (bool valid, string reason) ValidateCompatibility(string? camSoftware, string? millModel)
    {
        if (string.IsNullOrWhiteSpace(camSoftware))
        {
            return (false, "CAM software must be selected.");
        }

        if (string.IsNullOrWhiteSpace(millModel))
        {
            return (false, "Mill machine must be selected.");
        }

        var profile = DeviceRegistry.GetProfile(millModel);
        if (profile == null)
        {
            return (false, $"Unknown mill model: {millModel}.");
        }

        if (profile.DeviceType != DeviceType.Mill)
        {
            return (false, $"{millModel} is not a milling device.");
        }

        if (!profile.SupportedCAM.Contains(camSoftware, StringComparer.OrdinalIgnoreCase))
        {
            return (false, $"{camSoftware} is not supported by {profile.DeviceName}. Supported CAM: {string.Join(", ", profile.SupportedCAM)}.");
        }

        if (camSoftware.Equals("hyperDENT", StringComparison.OrdinalIgnoreCase))
        {
            return (false, "hyperDENT requires a validated profile before production use. Load a validated profile before assigning.");
        }

        if (profile.RequiresBoardConfirmation)
        {
            return (true, $"Compatibility valid. NOTE: {profile.DeviceName} requires board confirmation before milling.");
        }

        return (true, "Compatibility valid.");
    }

    public (bool valid, string reason) ValidateCompatibilityWithProfile(
        string? camSoftware,
        string? millModel,
        bool usesValidatedProfile)
    {
        if (string.IsNullOrWhiteSpace(camSoftware))
        {
            return (false, "CAM software must be selected.");
        }

        if (string.IsNullOrWhiteSpace(millModel))
        {
            return (false, "Mill machine must be selected.");
        }

        var profile = DeviceRegistry.GetProfile(millModel);
        if (profile == null)
        {
            return (false, $"Unknown mill model: {millModel}.");
        }

        if (profile.DeviceType != DeviceType.Mill)
        {
            return (false, $"{millModel} is not a milling device.");
        }

        if (!profile.SupportedCAM.Contains(camSoftware, StringComparer.OrdinalIgnoreCase))
        {
            return (false, $"{camSoftware} is not supported by {profile.DeviceName}. Supported CAM: {string.Join(", ", profile.SupportedCAM)}.");
        }

        if (camSoftware.Equals("hyperDENT", StringComparison.OrdinalIgnoreCase) && !usesValidatedProfile)
        {
            return (false, "hyperDENT requires a validated profile before production use.");
        }

        if (profile.RequiresBoardConfirmation)
        {
            return (true, $"Compatibility valid. NOTE: {profile.DeviceName} requires board confirmation before milling.");
        }

        return (true, "Compatibility valid.");
    }

    public ProductionJob? RecordFileVersion(
        Guid jobId,
        string filePath,
        string @operator,
        int version)
    {
        if (!File.Exists(filePath))
        {
            throw new FileNotFoundException($"File not found: {filePath}");
        }

        var hash = ComputeSha256(filePath);
        var fv = new FileVersion(filePath, hash, version, DateTime.UtcNow, @operator);

        lock (_lock)
        {
            if (!_jobs.TryGetValue(jobId, out var job)) return null;
            job = job.WithFileVersion(fv);
            _jobs[jobId] = job;
            return job;
        }
    }

    private static string ComputeSha256(string filePath)
    {
        using var stream = File.OpenRead(filePath);
        using var sha = SHA256.Create();
        var bytes = sha.ComputeHash(stream);
        return Convert.ToHexString(bytes).ToLowerInvariant();
    }
}