using ToolboxCore.Symptoms;

namespace ToolboxTests;

public class SymptomRegistryTests
{
    private readonly SymptomRegistry _registry = new();

    [Fact]
    public void GetSymptom_ReturnsDefinition_ForKnownId()
    {
        var result = _registry.GetSymptom("slow-system");
        Assert.NotNull(result);
        Assert.Equal("slow-system", result!.SymptomId);
        Assert.NotEmpty(result.RecommendedModules);
    }

    [Fact]
    public void GetSymptom_ReturnsNull_ForUnknownId() =>
        Assert.Null(_registry.GetSymptom("does-not-exist"));

    [Fact]
    public void GetAll_ReturnsAllSymptoms() =>
        Assert.NotEmpty(_registry.GetAll());

    [Fact]
    public void GetAllIds_ReturnsAtLeast10Symptoms() =>
        Assert.True(_registry.GetAllIds().Count >= 10);
}