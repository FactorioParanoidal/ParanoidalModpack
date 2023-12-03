using System.Collections.Generic;
using Newtonsoft.Json;

namespace ModSettings;

public class ModSettingsContent {
    [JsonProperty("startup")]
    public Dictionary<string, FactorioPropertyTree> Startup { get; set; } = new();

    [JsonProperty("runtime-global")]
    public Dictionary<string, FactorioPropertyTree> RuntimeGlobal { get; set; } = new();

    [JsonProperty("runtime-per-user")]
    public Dictionary<string, FactorioPropertyTree> RuntimePerUser { get; set; } = new();
}