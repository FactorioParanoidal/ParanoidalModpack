#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net.NetworkInformation;
using System.Threading;
using System.Threading.Tasks;
using Nuke.Common;
using Nuke.Common.IO;
using Serilog;
using Process = System.Diagnostics.Process;
using ProcessStartInfo = System.Diagnostics.ProcessStartInfo;

partial class Build {
    void Zip(AbsolutePath target, params string[] paths) => Zip(target, paths.AsEnumerable());

    void Zip(AbsolutePath target, IEnumerable<string> paths) {
        var targetPath = target.ToString();
        bool finished = false, atLeastOneFileAdded = false;
        try {
            using (var targetStream = File.Create(targetPath)) {
                using (var archive = new ZipArchive(targetStream, ZipArchiveMode.Create)) {
                    void AddFile(string path, string relativePath) {
                        var e = archive.CreateEntry(relativePath.Replace("\\", "/"), CompressionLevel.Optimal);
                        using (var entryStream = e.Open()) {
                            using (var fileStream = File.OpenRead(path)) {
                                fileStream.CopyTo(entryStream);
                            }
                        }
                        atLeastOneFileAdded = true;
                    }

                    foreach (var path in paths)
                        if (Directory.Exists(path)) {
                            var dirInfo = new DirectoryInfo(path);
                            var rootPath = Path.GetDirectoryName(dirInfo.FullName);
                            foreach (var fsEntry in dirInfo.EnumerateFileSystemInfos("*", SearchOption.AllDirectories))
                                if (fsEntry is FileInfo) {
                                    var relPath = Path.GetRelativePath(rootPath, fsEntry.FullName);
                                    AddFile(fsEntry.FullName, relPath);
                                }
                        }
                        else if (File.Exists(path)) {
                            var name = Path.GetFileName(path);
                            AddFile(path, name);
                        }
                }
            }

            finished = true;
        }
        finally {
            try {
                if (!finished || !atLeastOneFileAdded)
                    File.Delete(targetPath);
            }
            catch {
                //Ignore
            }
        }
    }
    
    async Task<bool> EnsureFactorioServerCanLaunch(string factorioServerLocation, string? modsPath = null) {
        Assert.True(OperatingSystem.IsLinux(), "Factorio can be started only on linux");

        // File.Delete(Path.Combine(factorioServerLocation, "non-existent-save"));

        var serverFile = Path.Combine(factorioServerLocation, "bin/x64/factorio");
        Utils.Chmod(serverFile);

        var port = 34197;
        var arguments = $"--start-server-load-scenario base/freeplay --bind 0.0.0.0:{port}";
        if (modsPath is not null)
        {
            arguments += $" --mod-directory \"{modsPath}\"";
        }
        
        Log.Information("Starting Factorio server on port {Port}", port);
        var processStartInfo = new ProcessStartInfo
        {
            UseShellExecute = false,
            FileName = serverFile,
            Arguments = arguments,
            RedirectStandardOutput = true,
        };
        using var process = Process.Start(processStartInfo).NotNull("Process.Start(processStartInfo) != null")!;
        process.BeginOutputReadLine();

        Log.Debug("Redirection Factorio output:");
        process.OutputDataReceived += (_, args) =>
        {
            if (args.Data == null) return;
            Log.Debug("{FactorioLogEntry}", args.Data);
        };

        
        var cancellationTokenSource = new CancellationTokenSource(TimeSpan.FromMinutes(15));
        try
        {
            var processExitedTask = process.WaitForExitAsync(cancellationTokenSource.Token);
            var portIsBusyTask = CheckUntilPortIsBusy(port, cancellationTokenSource.Token);
            var completedTask = await Task.WhenAny(processExitedTask, portIsBusyTask);
            process.Kill(true);
            if (completedTask == portIsBusyTask)
            {
                Log.Information("Port {Port} acquired by launched Factorio", port);
                return true;
            }
        }
        catch (TaskCanceledException)
        {
            Log.Error("Process hasn't started in 15 minutes. Aborting");
            process.Kill(true);
            return false;
        }

        return false;
    }

    public async Task CheckUntilPortIsBusy(int port, CancellationToken token)
    {
        await Task.Delay(TimeSpan.FromSeconds(5), token);
        var ipGlobalProperties = IPGlobalProperties.GetIPGlobalProperties();
        while (!token.IsCancellationRequested)
        {
            var tcpConnInfoArray = ipGlobalProperties.GetActiveUdpListeners();
            if (tcpConnInfoArray.Any(info => info.Port == port))
            {
                return;
            }

            await Task.Delay(TimeSpan.FromSeconds(5), token);
        }
    }
}