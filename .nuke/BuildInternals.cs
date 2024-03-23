#nullable enable
using System.Text.Json;
using FactorioParanoidal.Models.PropertyTrees;

partial class Build
{
    public JsonSerializerOptions SerializerOptions { get; }
        = new() { WriteIndented = true, Converters = { new FactorioPropertyTreeJsonConverter() } };
}