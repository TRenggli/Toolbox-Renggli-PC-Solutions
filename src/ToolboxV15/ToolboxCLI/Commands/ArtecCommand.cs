using ToolboxCLI.Output;

namespace ToolboxCLI.Commands;

internal static class ArtecCommand
{
    public static Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "action" });
        var sub = CommandOptions.GetValue(opts, "arg0");

        switch (sub?.ToLowerInvariant())
        {
            case "workflow":
                OutputFormatter.PrintGuided(
                    "Artec workflow (stub): would run the Artec dental equipment troubleshooting workflow.");
                break;

            case "production":
                var action = CommandOptions.GetValue(opts, "action") ?? "status";
                OutputFormatter.PrintGuided(
                    $"Artec production (stub): action '{action}' on production environment.");
                break;

            case "incident":
                OutputFormatter.PrintGuided(
                    "Artec incident (stub): would log and triage an Artec equipment incident.");
                break;

            default:
                OutputFormatter.PrintError(
                    "Usage: toolbox artec <workflow|production|incident> [--action <action>]");
                return Task.FromResult(1);
        }

        return Task.FromResult(0);
    }
}