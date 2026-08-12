using ToolboxCore.Models;
using static ToolboxTests.Fixtures;

namespace ToolboxTests;

public class ExecutionResultTests
{
    [Theory]
    [InlineData(ExecutionStatus.Failed)]
    [InlineData(ExecutionStatus.Blocked)]
    [InlineData(ExecutionStatus.Unsupported)]
    [InlineData(ExecutionStatus.Cancelled)]
    [InlineData(ExecutionStatus.Skipped)]
    public void ExecutionResult_With_Failed_NeverReportsSuccess(ExecutionStatus status)
    {
        var result = MakeResult("m", status, new List<Finding>(), 0);
        Assert.NotEqual(ExecutionStatus.Success, result.Status);
    }

    [Fact]
    public void ExecutionResult_Status_CoversAllStates()
    {
        var states = new[]
        {
            MakeResult("a", ExecutionStatus.Success),
            Failed("b"),
            Partial("c"),
            Cancelled("d"),
            Blocked("e"),
            Unsupported("f"),
            Skipped("g")
        };
        var distinct = states.Select(s => s.Status).Distinct().ToList();
        Assert.Equal(7, distinct.Count);
        Assert.Contains(ExecutionStatus.Success, distinct);
        Assert.Contains(ExecutionStatus.Failed, distinct);
        Assert.Contains(ExecutionStatus.Partial, distinct);
        Assert.Contains(ExecutionStatus.Cancelled, distinct);
        Assert.Contains(ExecutionStatus.Blocked, distinct);
        Assert.Contains(ExecutionStatus.Unsupported, distinct);
        Assert.Contains(ExecutionStatus.Skipped, distinct);
    }
}