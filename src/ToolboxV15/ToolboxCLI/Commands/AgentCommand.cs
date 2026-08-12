using ToolboxCLI.Output;

namespace ToolboxCLI.Commands;

internal static class AgentCommand
{
    public static Task<int> Execute(string[] args)
    {
        var opts = CommandOptions.Parse(args, new() { "token", "server" });
        var sub = CommandOptions.GetValue(opts, "arg0");

        switch (sub?.ToLowerInvariant())
        {
            case "install":
                OutputFormatter.PrintGuided(
                    "Agent install (stub): would install and register the remote agent service on this host.");
                break;

            case "enroll":
                var token = CommandOptions.GetValue(opts, "token") ?? "<none>";
                var server = CommandOptions.GetValue(opts, "server") ?? "<none>";
                OutputFormatter.PrintGuided(
                    $"Agent enroll (stub): would enroll this host with server '{server}' using token '{token}'.");
                break;

            case "status":
                OutputFormatter.PrintGuided(
                    "Agent status (stub): agent is not installed on this host.");
                break;

            default:
                OutputFormatter.PrintError(
                    "Usage: toolbox agent <install|enroll|status> [--token <t>] [--server <url>]");
                return Task.FromResult(1);
        }

        return Task.FromResult(0);
    }
}