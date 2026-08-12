using ToolboxCLI.Commands;
using ToolboxCLI.Output;
using ToolboxCore.Models;

namespace ToolboxCLI;

public static class Program
{
    public static TriageResult? LastTriage;

    public static async Task<int> Main(string[] args)
    {
        if (args.Length == 0)
        {
            PrintUsage();
            return 0;
        }

        var command = args[0].ToLowerInvariant();
        var rest = args.Length > 1 ? args[1..] : Array.Empty<string>();

        return command switch
        {
            "triage" => await TriageCommand.Execute(rest),
            "symptom" => await SymptomCommand.Execute(rest),
            "catalog" => await CatalogCommand.Execute(rest),
            "run" => await RunCommand.Execute(rest),
            "report" => await ReportCommand.Execute(rest),
            "agent" => await AgentCommand.Execute(rest),
            "artec" => await ArtecCommand.Execute(rest),
            "help" or "--help" or "-h" => PrintUsage(),
            _ => Unknown(command)
        };
    }

    private static int PrintUsage()
    {
        OutputFormatter.PrintGuided(
            """
            Toolbox V15 CLI
            Usage: toolbox <command> [options]

            Commands:
              triage    --area <system|network|server|artec> [--json] [--guided]
              symptom   <id> [--json]
              catalog   [--area] [--os] [--risk] [--json]
              run       <module-id> [--json] [--force] [--params k=v;...]
              report    export --format <html|json|csv> --path <file>
              agent     install | enroll [--token] [--server] | status
              artec     workflow | production [--action] | incident
            """);
        return 0;
    }

    private static int Unknown(string command)
    {
        OutputFormatter.PrintError($"Unknown command: {command}. Run 'toolbox help' for usage.");
        return 1;
    }
}