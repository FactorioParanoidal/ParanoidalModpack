using System;
using System.Diagnostics;
using System.Net.Http;
using System.Runtime.InteropServices;
using Nuke.Common.Tools.NSwag;
public static class Utils {
    public static readonly HttpClient HttpClient = new();
    public static string GetFactorioDownloadLinkForCurrentOs(string build = "latest", string version = "alpha", string? os = null) {
        return $"https://www.factorio.com/get-download/{build}/{version}/{os ?? GetFactorioDistroNameForCurrentOs()}";
    }

    public static string GetFactorioDistroNameForCurrentOs() {
        return true switch {
            _ when OperatingSystem.IsWindows() => "win64-manual",
            _ when OperatingSystem.IsMacOS() => "osx",
            _ when OperatingSystem.IsLinux() => "linux64",
        };
    }

    public static void Chmod(string path) {
        if (!OperatingSystem.IsLinux()) return;
        using var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                RedirectStandardOutput = true,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden,
                FileName = "/bin/bash",
                Arguments = $"-c \"chmod +x {path}\""
            }
        };

        process.Start();
        process.WaitForExit();
    }
}