namespace ToolboxAgent;

public class AgentConfig
{
    public string ServerUrl { get; set; } = "http://localhost:5137";
    public string ClientCertPath { get; set; } = string.Empty;
    public string AgentId { get; set; } = string.Empty;
    public string EnrollToken { get; set; } = string.Empty;
    public string Hostname { get; set; } = string.Empty;
    public string Os { get; set; } = string.Empty;
    public string OsVersion { get; set; } = string.Empty;
    public int PollIntervalSeconds { get; set; } = 15;
    public int HeartbeatSeconds { get; set; } = 30;

    public static AgentConfig Load(string path)
    {
        if (!File.Exists(path)) return new AgentConfig();
        var cfg = new AgentConfig();
        foreach (var line in File.ReadAllLines(path))
        {
            var i = line.IndexOf('=');
            if (i <= 0) continue;
            var key = line[..i].Trim();
            var val = line[(i + 1)..].Trim();
            switch (key)
            {
                case "ServerUrl": cfg.ServerUrl = val; break;
                case "ClientCertPath": cfg.ClientCertPath = val; break;
                case "AgentId": cfg.AgentId = val; break;
                case "EnrollToken": cfg.EnrollToken = val; break;
                case "Hostname": cfg.Hostname = val; break;
                case "Os": cfg.Os = val; break;
                case "OsVersion": cfg.OsVersion = val; break;
                case "PollIntervalSeconds": _ = int.TryParse(val, out var p); cfg.PollIntervalSeconds = p; break;
                case "HeartbeatSeconds": _ = int.TryParse(val, out var h); cfg.HeartbeatSeconds = h; break;
            }
        }
        return cfg;
    }

    public void Save(string path)
    {
        var lines = new[]
        {
            $"ServerUrl={ServerUrl}",
            $"ClientCertPath={ClientCertPath}",
            $"AgentId={AgentId}",
            $"EnrollToken={EnrollToken}",
            $"Hostname={Hostname}",
            $"Os={Os}",
            $"OsVersion={OsVersion}",
            $"PollIntervalSeconds={PollIntervalSeconds}",
            $"HeartbeatSeconds={HeartbeatSeconds}"
        };
        File.WriteAllLines(path, lines);
    }
}