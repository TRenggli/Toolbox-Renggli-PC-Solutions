using ToolboxCore.Engine;
using ToolboxCore.Models;
using static ToolboxTests.Fixtures;

namespace ToolboxTests;

public class CausalEngineTests
{
    private readonly CausalEngine _engine = new();

    [Fact]
    public void Analyze_DiskFailure_Confirmed_WhenSmartAndEventsFail()
    {
        var results = new List<ExecutionResult> { DiskSmartFailed(), DiskEventsFailed() };
        var findings = _engine.Analyze(results);
        Assert.Contains(findings, f => f.Id == "disk-failure" && f.Confidence == Confidence.Confirmed && f.Severity == Severity.Critical);
    }

    [Fact]
    public void Analyze_MemoryPressure_Probable_WhenRamHigh()
    {
        var results = new List<ExecutionResult> { RamHigh() };
        var findings = _engine.Analyze(results);
        Assert.Contains(findings, f => f.Id == "memory-pressure" && f.Confidence == Confidence.Probable);
    }

    [Fact]
    public void Analyze_Empty_WhenNoResultsProvided() =>
        Assert.Empty(_engine.Analyze(new List<ExecutionResult>()));

    [Fact]
    public void Analyze_DnsMisconfig_Possible_WhenDnsFailsNetworkOK()
    {
        var results = new List<ExecutionResult> { DnsFailed(), NetworkSpeedOk() };
        var findings = _engine.Analyze(results);
        Assert.Contains(findings, f => f.Id == "dns-misconfig" && f.Confidence == Confidence.Possible);
    }
}