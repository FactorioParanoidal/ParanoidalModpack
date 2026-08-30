using System;
using System.Collections.Generic;
using System.IO;
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

        var modNames = mods
            .Select(x => x.Info.Name)
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
}
