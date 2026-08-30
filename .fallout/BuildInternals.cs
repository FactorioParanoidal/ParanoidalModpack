using System.Text.Json;
using System.Text.Json.Serialization;
using FactorioParanoidal.Models.PropertyTrees;

partial class Build
{
    public JsonSerializerOptions SerializerOptions { get; }
        = new()
        {
            WriteIndented = true,
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            Converters =
            {
                new FactorioPropertyTreeJsonConverter(),
                new JsonStringEnumConverter(JsonNamingPolicy.CamelCase)
            }
        };
}
