using ToolboxCore.Models;

namespace ToolboxCore.Abstractions;

public interface IModuleExecutor
{
    string ModuleId { get; }
    Task<ExecutionResult> ExecuteAsync(ModuleManifest manifest, Dictionary<string, object> parameters, CancellationToken ct);
    bool CanExecute(ModuleManifest manifest);
}