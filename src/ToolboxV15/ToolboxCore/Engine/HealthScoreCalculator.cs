using ToolboxCore.Models;

namespace ToolboxCore.Engine;

public class HealthScoreCalculator
{
    public int Calculate(List<Finding> findings)
    {
        int penalty = 0;
        foreach (var f in findings)
        {
            penalty += f.Severity switch
            {
                Severity.Critical => 25,
                Severity.High => 15,
                Severity.Medium => 8,
                Severity.Low => 3,
                _ => 0
            };
        }
        return Math.Max(0, 100 - Math.Min(penalty, 100));
    }

    public int Calculate(ExecutionResult result) => Calculate(result.Findings);
}