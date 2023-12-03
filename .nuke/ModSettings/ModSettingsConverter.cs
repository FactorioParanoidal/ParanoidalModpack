using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using Newtonsoft.Json;

namespace ModSettings;

public static class ModSettingsConverter {
    static Dictionary<string, PropertyInfo>? ModSettingsContentProperties;

    public static ModSettings Deserialize(Stream datFileStream) {
        var steamReader = new ModSettingsSteamReader(datFileStream);

        // https://wiki.factorio.com/Mod_settings_file_format
        var version = steamReader.ReadVersion();
        _ = steamReader.ReadBool();
        var contentPropertyTree = steamReader.ReadPropertyTree().AsDictionary();

        var modSettingsContentProperties = GetModSettingsContentProperties();
        var modSettingsContent = new ModSettingsContent();
        foreach (var (key, value) in contentPropertyTree) {
            var jsonValues = value.AsDictionary()
                .ToDictionary(pair => pair.Key, pair => pair.Value.AsDictionary()["value"]);

            modSettingsContentProperties[key].SetValue(modSettingsContent, jsonValues);
        }

        return new ModSettings {
            Version = version,
            Content = modSettingsContent
        };
    }

    public static void Serialize(ModSettings modSettings, Stream stream) {
        var streamWriter = new ModSettingsStreamWriter(stream);

        streamWriter.WriteVersion(modSettings.Version);
        streamWriter.WriteBool(false);

        var factorioPropertyTrees = GetModSettingsContentProperties()
            .ToDictionary(pair => pair.Key, pair =>
            {
                var jsonValueDictionary = (IReadOnlyDictionary<string, FactorioPropertyTree>)pair.Value.GetValue(modSettings.Content)!;
                var valuedDictionary = jsonValueDictionary
                    .ToDictionary(jsonPair => jsonPair.Key, jsonPair =>
                    {
                        var tempDictionary = new Dictionary<string, FactorioPropertyTree>() {
                            { "value", jsonPair.Value }
                        };
                        return FactorioPropertyTree.Create(tempDictionary);
                    });
                return FactorioPropertyTree.Create(valuedDictionary);
            });
        var modSettingsContent = FactorioPropertyTree.Create(factorioPropertyTrees);
        streamWriter.WritePropertyTree(modSettingsContent);
    }

    static Dictionary<string, PropertyInfo> GetModSettingsContentProperties() {
        if (ModSettingsContentProperties is not null) return ModSettingsContentProperties;
        var modSettingsContentType = typeof(ModSettingsContent);
        var propertyInfos = modSettingsContentType.GetProperties();
        return ModSettingsContentProperties = propertyInfos.ToDictionary(info => ((JsonPropertyAttribute)info.GetCustomAttribute(typeof(JsonPropertyAttribute))!).PropertyName!);
    }
}