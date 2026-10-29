using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text.Json;
using FactorioParanoidal.FactorioMods.Mods;
using Fallout.Common.IO;

namespace ModDescriptions;

public sealed class ModDescriptionsChecker(AbsolutePath rootDirectory)
{
    const string MetadataFolder = "mods-metadata";
    const string DescriptionsFile = "!descriptions.json";

    public void Check(IReadOnlyList<FolderFactorioMod> mods)
    {
        var descriptionsPath = rootDirectory / MetadataFolder / DescriptionsFile;
        if (!File.Exists(descriptionsPath))
            throw new FileNotFoundException($"Mod descriptions file not found: {descriptionsPath}", descriptionsPath);

        var descriptionsText = File.ReadAllText(descriptionsPath);
        var descriptions = JsonSerializer.Deserialize<Dictionary<string, string>>(descriptionsText)
                           ?? throw new InvalidOperationException($"Mod descriptions file must contain a JSON object: {descriptionsPath}");

        // Every mod in mods/ counts, enabled or not: mods disabled in the local mod-list.json still show
        // their description in the game's mod list.
        var modNames = mods
            .Select(x => x.Info.Name)
            .Concat(ReadAllModNames(rootDirectory / "mods"))
            .ToHashSet(StringComparer.Ordinal);
        var failures = new List<string>();
        foreach (var (modName, description) in descriptions)
        {
            if (!modNames.Contains(modName))
            {
                failures.Add($"{modName}: mod does not exist in mods/");
                continue;
            }

            if (string.IsNullOrWhiteSpace(description))
                failures.Add($"{modName}: description must be a non-empty string");
        }

        if (failures.Count > 0)
            throw new InvalidOperationException("Mod descriptions check failed:\n" +
                                                string.Join("\n", failures.Select(x => $"- {x}")));
    }

    static IEnumerable<string> ReadAllModNames(string modsDirectory)
    {
        if (!Directory.Exists(modsDirectory))
            yield break;
        foreach (var directory in Directory.EnumerateDirectories(modsDirectory))
        {
            var infoPath = Path.Combine(directory, "info.json");
            if (File.Exists(infoPath) && ReadName(File.ReadAllText(infoPath)) is { } name)
                yield return name;
        }

        foreach (var archivePath in Directory.EnumerateFiles(modsDirectory, "*.zip"))
        {
            using var archive = ZipFile.OpenRead(archivePath);
            var entry = archive.Entries.FirstOrDefault(x =>
                x.FullName.Count(c => c == '/') == 1 && x.FullName.EndsWith("/info.json", StringComparison.Ordinal));
            if (entry is null)
                continue;
            using var reader = new StreamReader(entry.Open());
            if (ReadName(reader.ReadToEnd()) is { } name)
                yield return name;
        }
    }

    static string? ReadName(string infoJson)
    {
        using var document = JsonDocument.Parse(infoJson.TrimStart('﻿'));
        return document.RootElement.TryGetProperty("name", out var name) ? name.GetString() : null;
    }
}
