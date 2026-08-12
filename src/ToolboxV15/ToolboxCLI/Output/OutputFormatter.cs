using System.Text.Encodings.Web;
using System.Text.Json;

namespace ToolboxCLI.Output;

internal static class OutputFormatter
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        WriteIndented = true,
        Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping
    };

    public static void PrintJson(object? obj)
    {
        if (obj == null)
        {
            Console.WriteLine("null");
            return;
        }
        Console.WriteLine(JsonSerializer.Serialize(obj, obj.GetType(), JsonOptions));
    }

    public static void PrintGuided(string text)
    {
        WriteColored(text, ConsoleColor.Cyan);
    }

    public static void PrintError(string text)
    {
        WriteColored(text, ConsoleColor.Red);
    }

    private static void WriteColored(string text, ConsoleColor color)
    {
        var previous = Console.ForegroundColor;
        try
        {
            Console.ForegroundColor = color;
            Console.WriteLine(text);
        }
        finally
        {
            Console.ForegroundColor = previous;
        }
    }
}