using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using ModProvenance.Models;
using Nuke.Common.IO;

namespace ModProvenance;

public static class ModFileComparer
{
    private static readonly HashSet<string> IgnoredDirectoryNames = new(StringComparer.OrdinalIgnoreCase)
    {
        ".git", ".idea", ".vscode"
    };

    private static readonly HashSet<string> IgnoredFileNames = new(StringComparer.OrdinalIgnoreCase)
    {
        ".DS_Store", ".gitattributes", "Thumbs.db"
    };

    private static readonly HashSet<string> BinaryExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".7z", ".gif", ".ico", ".jpeg", ".jpg", ".kra", ".mp3", ".mp4", ".ods", ".ogg", ".pdf", ".png", ".swg",
        ".ttf", ".wav", ".xcf", ".zip"
    };

    public static string GetDirectoryHash(AbsolutePath directory) =>
        directory.GetDirectoryHash(path => IncludeFile(directory, path));

    public static IReadOnlyDictionary<string, string> ReadDirectoryFiles(AbsolutePath directory) =>
        Directory.EnumerateFiles(directory, "*", SearchOption.AllDirectories)
            .Select(AbsolutePath.Create)
            .Where(path => IncludeFile(directory, path))
            .ToDictionary(path => NormalizePath(Path.GetRelativePath(directory, path)), path => path.GetFileHash(),
                StringComparer.Ordinal);

    public static async Task<ArchiveFileSet> ReadArchiveFilesAsync(Stream archiveStream)
    {
        var result = new Dictionary<string, string>(StringComparer.Ordinal);
        await using var archive = new ZipArchive(archiveStream, ZipArchiveMode.Read);
        var files = archive.Entries.Where(x => !string.IsNullOrEmpty(x.Name)).ToArray();
        var root = files.Select(x => NormalizePath(x.FullName).Split('/')[0])
            .Distinct(StringComparer.Ordinal).Count() == 1
            ? NormalizePath(files[0].FullName).Split('/')[0] + "/"
            : string.Empty;
        using var contentHash = MD5.Create();
        var buffer = new byte[81920];
        var normalizedBuffer = new byte[81921];
        var includedFiles = files
            .Select(entry =>
            {
                var path = NormalizePath(entry.FullName);
                if (path.StartsWith(root, StringComparison.Ordinal)) path = path[root.Length..];
                return (Entry: entry, Path: path);
            })
            .Where(x => !IsIgnored(x.Path))
            .OrderBy(x => x.Path, StringComparer.Ordinal);

        foreach (var (entry, path) in includedFiles)
        {
            var pathBytes = Encoding.UTF8.GetBytes(path);
            contentHash.TransformBlock(pathBytes, 0, pathBytes.Length, pathBytes, 0);

            using var fileHash = MD5.Create();
            await using var stream = await entry.OpenAsync();
            var pendingCarriageReturn = false;
            var read = await stream.ReadAtLeastAsync(buffer, 8000, throwOnEndOfStream: false);
            var isText = !IsExplicitBinary(path) && IsTextContent(buffer, read);
            while (read > 0)
            {
                if (isText)
                {
                    var normalizedLength = NormalizeLineEndings(buffer, read, normalizedBuffer,
                        ref pendingCarriageReturn);
                    contentHash.TransformBlock(normalizedBuffer, 0, normalizedLength, normalizedBuffer, 0);
                    fileHash.TransformBlock(normalizedBuffer, 0, normalizedLength, normalizedBuffer, 0);
                }
                else
                {
                    contentHash.TransformBlock(buffer, 0, read, buffer, 0);
                    fileHash.TransformBlock(buffer, 0, read, buffer, 0);
                }

                read = await stream.ReadAsync(buffer);
            }

            if (pendingCarriageReturn)
            {
                normalizedBuffer[0] = (byte)'\n';
                contentHash.TransformBlock(normalizedBuffer, 0, 1, normalizedBuffer, 0);
                fileHash.TransformBlock(normalizedBuffer, 0, 1, normalizedBuffer, 0);
            }

            fileHash.TransformFinalBlock([], 0, 0);
            result[path] = Convert.ToHexString(fileHash.Hash!).ToLowerInvariant();
        }

        contentHash.TransformFinalBlock([], 0, 0);
        return new ArchiveFileSet(result, Convert.ToHexString(contentHash.Hash!).ToLowerInvariant());
    }

    public static IReadOnlyList<FileChange> Compare(IReadOnlyDictionary<string, string> currentFiles,
        IReadOnlyDictionary<string, string> upstreamFiles) =>
        upstreamFiles.Keys.Union(currentFiles.Keys, StringComparer.Ordinal)
            .Order(StringComparer.Ordinal)
            .Select(path => new FileChange(path,
                !upstreamFiles.ContainsKey(path) ? ChangeKind.Added :
                !currentFiles.ContainsKey(path) ? ChangeKind.Removed :
                upstreamFiles[path] != currentFiles[path] ? ChangeKind.Changed : ChangeKind.Unchanged))
            .Where(x => x.Kind != ChangeKind.Unchanged)
            .ToArray();

    private static bool IncludeFile(AbsolutePath baseDirectory, AbsolutePath path) =>
        !IsIgnored(Path.GetRelativePath(baseDirectory, path));

    private static bool IsIgnored(string relativePath)
    {
        var pathParts = NormalizePath(relativePath).Split('/', StringSplitOptions.RemoveEmptyEntries);
        if (pathParts.Length == 0 || IgnoredFileNames.Contains(pathParts[^1])) return pathParts.Length > 0;

        for (var index = 0; index < pathParts.Length - 1; index++)
        {
            if (IgnoredDirectoryNames.Contains(pathParts[index])) return true;
        }

        return false;
    }

    private static bool IsExplicitBinary(string relativePath)
    {
        if (relativePath.EndsWith(".png.bak", StringComparison.OrdinalIgnoreCase) ||
            relativePath.EndsWith(".xcf.bak", StringComparison.OrdinalIgnoreCase)) return true;
        return BinaryExtensions.Contains(Path.GetExtension(relativePath));
    }

    private static bool IsTextContent(byte[] buffer, int length)
    {
        // Match Git's text=auto classification: a NUL in the first 8000 bytes marks binary content.
        var inspectedLength = Math.Min(length, 8000);
        return Array.IndexOf(buffer, (byte)0, 0, inspectedLength) < 0;
    }

    private static int NormalizeLineEndings(byte[] source, int length, byte[] destination,
        ref bool pendingCarriageReturn)
    {
        var output = 0;
        var index = 0;
        if (pendingCarriageReturn)
        {
            destination[output++] = (byte)'\n';
            if (source[0] == '\n') index++;
            pendingCarriageReturn = false;
        }

        for (; index < length; index++)
        {
            if (source[index] == '\r')
            {
                if (index + 1 == length)
                {
                    pendingCarriageReturn = true;
                    continue;
                }

                if (source[index + 1] == '\n') index++;
                destination[output++] = (byte)'\n';
                continue;
            }

            destination[output++] = source[index];
        }

        return output;
    }

    private static string NormalizePath(string path) => path.Replace('\\', '/').TrimStart('/');
}
