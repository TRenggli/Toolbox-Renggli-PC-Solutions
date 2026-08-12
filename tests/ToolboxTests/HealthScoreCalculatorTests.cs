using ToolboxCore.Engine;
using ToolboxCore.Models;
using static ToolboxTests.Fixtures;

namespace ToolboxTests;

public class HealthScoreCalculatorTests
{
    private readonly HealthScoreCalculator _calc = new();

    [Fact]
    public void Score_100_WhenNoFindings() =>
        Assert.Equal(100, _calc.Calculate(new List<Finding>()));

    [Fact]
    public void Score_75_WithOneCriticalFinding() =>
        Assert.Equal(75, _calc.Calculate(new List<Finding> { MakeFinding(severity: Severity.Critical) }));

    [Fact]
    public void Score_0_WithFourCriticalFindings() =>
        Assert.Equal(0, _calc.Calculate(Enumerable.Repeat(MakeFinding(severity: Severity.Critical), 4).ToList()));

    [Fact]
    public void Score_NeverBelowZero()
    {
        var many = Enumerable.Repeat(MakeFinding(severity: Severity.Critical), 10).ToList();
        Assert.Equal(0, _calc.Calculate(many));
    }

    [Fact]
    public void Score_85_WithOneHighFinding() =>
        Assert.Equal(85, _calc.Calculate(new List<Finding> { MakeFinding(severity: Severity.High) }));

    [Fact]
    public void Score_92_WithOneMediumFinding() =>
        Assert.Equal(92, _calc.Calculate(new List<Finding> { MakeFinding(severity: Severity.Medium) }));
}