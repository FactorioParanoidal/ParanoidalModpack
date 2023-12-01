using System.Collections.Generic;
using System.Text.Json.Nodes;
using Newtonsoft.Json;

namespace ModSettings;

public class ModSettingsContent {
    [JsonProperty("startup")]
    public Dictionary<string, JsonValue> Startup { get; set; } = new();

    [JsonProperty("runtime-global")]
    public Dictionary<string, JsonValue> RuntimeGlobal { get; set; } = new();

    [JsonProperty("runtime-per-user")]
    public Dictionary<string, JsonValue> RuntimePerUser { get; set; } = new();
}