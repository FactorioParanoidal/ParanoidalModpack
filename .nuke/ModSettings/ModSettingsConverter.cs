using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.Json.Nodes;
using Newtonsoft.Json;

namespace ModSettings;

public static class ModSettingsConverter {
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
                .ToDictionary(pair => pair.Key, pair =>
                {
                    var propertyValue = pair.Value.AsDictionary()["value"];
                    return propertyValue.Type switch {
                        FactorioPropertyTreeType.None       => throw new NotSupportedException("Reading None from mod settings not supported"),
                        FactorioPropertyTreeType.Bool       => JsonValue.Create(propertyValue.AsBool()),
                        FactorioPropertyTreeType.Number     => JsonValue.Create(propertyValue.AsNumber()),
                        FactorioPropertyTreeType.String     => JsonValue.Create(propertyValue.AsString()),
                        FactorioPropertyTreeType.List       => JsonValue.Create(propertyValue.AsList()),
                        FactorioPropertyTreeType.Dictionary => JsonValue.Create(propertyValue.AsDictionary()),
                        _                                   => throw new ArgumentOutOfRangeException(nameof(pair.Value.Type))
                    };
                });

            modSettingsContentProperties[key].SetValue(modSettingsContent, jsonValues);
        }

        return new ModSettings {
            Version = version,
            Content = modSettingsContent
        };
    }

    static Dictionary<string, PropertyInfo> GetModSettingsContentProperties() {
        var modSettingsContentType = typeof(ModSettingsContent);
        var propertyInfos = modSettingsContentType.GetProperties();
        return propertyInfos.ToDictionary(info => ((JsonPropertyAttribute)info.GetCustomAttribute(typeof(JsonPropertyAttribute))!).PropertyName!);
    }
}