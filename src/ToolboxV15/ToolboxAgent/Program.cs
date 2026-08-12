using System.Runtime.InteropServices;

namespace ToolboxAgent;

public static class Program
{
    public static async Task<int> Main(string[] args)
    {
        if (args.Length == 0)
        {
            PrintUsage();
            return 1;
        }

        var cmd = args[0].ToLowerInvariant();
        var configPath = args.Length > 1 ? args[1] : DefaultConfigPath();

        switch (cmd)
        {
            case "install": return Install();
            case "enroll": return await Enroll(configPath);
            case "status": return Status(configPath);
            case "run": return await Run(configPath);
            case "help":
            case "-h":
            case "--help":
                PrintUsage();
                return 0;
            default:
                Console.Error.WriteLine($"Unknown command: {cmd}");
                PrintUsage();
                return 1;
        }
    }

    private static async Task<int> Enroll(string configPath)
    {
        var cfg = AgentConfig.Load(configPath);
        if (string.IsNullOrWhiteSpace(cfg.EnrollToken))
        {
            Console.Error.WriteLine("EnrollToken not set in config.");
            return 2;
        }

        cfg.Hostname = string.IsNullOrWhiteSpace(cfg.Hostname) ? Environment.MachineName : cfg.Hostname;
        cfg.Os = string.IsNullOrWhiteSpace(cfg.Os) ? DetectOs() : cfg.Os;
        cfg.OsVersion = string.IsNullOrWhiteSpace(cfg.OsVersion) ? Environment.OSVersion.Version.ToString() : cfg.OsVersion;

        using var svc = new AgentService(cfg);
        var result = await svc.EnrollAsync();
        if (result is null)
        {
            Console.Error.WriteLine("Enrollment failed.");
            return 3;
        }

        cfg.AgentId = result.AgentId.ToString();
        cfg.ClientCertPath = Path.Combine(Path.GetDirectoryName(configPath) ?? ".", $"agent-{result.AgentId}.cert");
        File.WriteAllText(cfg.ClientCertPath, result.ClientCert);
        cfg.Save(configPath);
        Console.WriteLine($"Enrolled. AgentId={result.AgentId}");
        Console.WriteLine($"Client cert saved to {cfg.ClientCertPath}");
        return 0;
    }

    private static int Status(string configPath)
    {
        if (!File.Exists(configPath))
        {
            Console.WriteLine("Agent not configured.");
            return 0;
        }
        var cfg = AgentConfig.Load(configPath);
        Console.WriteLine($"ServerUrl        : {cfg.ServerUrl}");
        Console.WriteLine($"AgentId          : {(string.IsNullOrEmpty(cfg.AgentId) ? "(not enrolled)" : cfg.AgentId)}");
        Console.WriteLine($"Hostname         : {cfg.Hostname}");
        Console.WriteLine($"Os               : {cfg.Os} {cfg.OsVersion}");
        Console.WriteLine($"ClientCertPath   : {cfg.ClientCertPath}");
        Console.WriteLine($"PollIntervalSec  : {cfg.PollIntervalSeconds}");
        Console.WriteLine($"HeartbeatSec     : {cfg.HeartbeatSeconds}");
        return 0;
    }

    private static async Task<int> Run(string configPath)
    {
        var cfg = AgentConfig.Load(configPath);
        if (string.IsNullOrWhiteSpace(cfg.AgentId))
        {
            Console.Error.WriteLine("Agent not enrolled. Run 'enroll' first.");
            return 4;
        }

        using var svc = new AgentService(cfg);
        Console.CancelKeyPress += (_, e) => { e.Cancel = true; svc.Stop(); };

        Console.WriteLine($"Agent {cfg.AgentId} starting. Polling {cfg.ServerUrl} every {cfg.PollIntervalSeconds}s");
        await svc.RunAsync();
        return 0;
    }

    private static int Install()
    {
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            Console.WriteLine("Install as Windows Service:");
            Console.WriteLine("  sc.exe create ToolboxAgent binPath= \"<agentPath> run <configPath>\" start= auto");
            Console.WriteLine("  sc.exe start ToolboxAgent");
        }
        else
        {
            const string unit = """
[Unit]
Description=Toolbox V15 Agent
After=network.target

[Service]
ExecStart=/usr/local/bin/toolbox-agent run /etc/toolbox/agent.conf
Restart=on-failure
User=toolbox

[Install]
WantedBy=multi-user.target
""";
            var path = "/etc/systemd/system/toolbox-agent.service";
            Console.WriteLine($"Install as systemd unit. Write the following to {path}:");
            Console.WriteLine(unit);
            Console.WriteLine("  systemctl daemon-reload && systemctl enable --now toolbox-agent");
        }
        return 0;
    }

    private static string DetectOs() =>
        RuntimeInformation.IsOSPlatform(OSPlatform.Windows) ? "Windows"
        : RuntimeInformation.IsOSPlatform(OSPlatform.Linux) ? "Linux"
        : RuntimeInformation.IsOSPlatform(OSPlatform.OSX) ? "macOS" : "Unknown";

    private static string DefaultConfigPath()
    {
        var dir = RuntimeInformation.IsOSPlatform(OSPlatform.Windows)
            ? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "Toolbox")
            : "/etc/toolbox";
        return Path.Combine(dir, "agent.conf");
    }

    private static void PrintUsage()
    {
        Console.WriteLine("Toolbox V15 Agent");
        Console.WriteLine("Usage: toolbox-agent <command> [configPath]");
        Console.WriteLine("Commands:");
        Console.WriteLine("  install   Show instructions for installing as a system service");
        Console.WriteLine("  enroll    Enroll with the server using the configured token");
        Console.WriteLine("  status    Show current agent status");
        Console.WriteLine("  run       Start the main polling loop");
    }
}