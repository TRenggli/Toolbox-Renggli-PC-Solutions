namespace ToolboxCLI.Commands;

internal static class CommandOptions
{
    public static Dictionary<string, string?> Parse(string[] args, List<string> flags)
    {
        var result = new Dictionary<string, string?>(StringComparer.OrdinalIgnoreCase);
        foreach (var f in flags)
            result[f] = null;

        string? positional = null;

        for (var i = 0; i < args.Length; i++)
        {
            var a = args[i];
            if (a.StartsWith("--"))
            {
                var name = a[2..];
                string? value = null;
                if (i + 1 < args.Length && !args[i + 1].StartsWith("--"))
                {
                    value = args[i + 1];
                    i++;
                }
                result[name] = value ?? "true";
            }
            else if (positional == null)
            {
                positional = a;
            }
        }

        if (positional != null)
            result["arg0"] = positional;

        return result;
    }

    public static bool HasFlag(Dictionary<string, string?> opts, string name)
    {
        return opts.TryGetValue(name, out var v) && v == "true";
    }

    public static string? GetValue(Dictionary<string, string?> opts, string name)
    {
        if (!opts.TryGetValue(name, out var v))
            return null;
        if (v == null || v == "true")
            return null;
        return v;
    }
}