using System.Runtime.InteropServices;

namespace ToolboxCore.Platform;

public static class OSAbstractionFactory
{
    public static Abstractions.IOSAbstraction Create()
    {
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            return new WindowsOSAbstraction();
        if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            return new LinuxOSAbstraction();
        if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            return new MacOSAbstraction();
        throw new PlatformNotSupportedException("Unsupported OS");
    }
}