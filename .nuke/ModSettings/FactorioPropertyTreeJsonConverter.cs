using System;
using System.Linq;
using System.Text.Json;
using System.Text.Json.Serialization;

namespace ModSettings;

public class FactorioPropertyTreeJsonConverter : JsonConverter<FactorioPropertyTree> {
    /// <inheritdoc />
    public override FactorioPropertyTree? Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options) {
        switch (reader.TokenType) {
            case JsonTokenType.None:
            case JsonTokenType.Null:
                return FactorioPropertyTree.CreateNone();
            case JsonTokenType.StartObject:
                var jElementObject = JsonElement.ParseValue(ref reader);
                var propertyTrees = jElementObject.EnumerateObject()
                    .ToDictionary(property => property.Name, property => property.Value.Deserialize<FactorioPropertyTree>(options)!);
                return FactorioPropertyTree.Create(propertyTrees);
            case JsonTokenType.StartArray:
                var jElementArray = JsonElement.ParseValue(ref reader);
                var factorioPropertyTrees = jElementArray.EnumerateArray()
                    .Select(element => element.Deserialize<FactorioPropertyTree>(options)!);
                return FactorioPropertyTree.Create(factorioPropertyTrees);
            case JsonTokenType.String:
                return FactorioPropertyTree.Create(reader.GetString()!);
            case JsonTokenType.Number:
                return FactorioPropertyTree.Create(reader.GetDouble());
            case JsonTokenType.True:
                return FactorioPropertyTree.Create(true);
            case JsonTokenType.False:
                return FactorioPropertyTree.Create(false);
            case JsonTokenType.EndObject:
            case JsonTokenType.EndArray:
            case JsonTokenType.PropertyName:
            case JsonTokenType.Comment:
            default:
                throw new JsonException("Can't read FactorioPropertyTree from this JSON");
        }
    }

    /// <inheritdoc />
    public override void Write(Utf8JsonWriter writer, FactorioPropertyTree tree, JsonSerializerOptions options) {
        switch (tree.Type) {
            case FactorioPropertyTreeType.None:
                writer.WriteNullValue();
                break;
            case FactorioPropertyTreeType.Bool:
                writer.WriteBooleanValue(tree.AsBool());
                break;
            case FactorioPropertyTreeType.Number:
                writer.WriteNumberValue(tree.AsNumber());
                break;
            case FactorioPropertyTreeType.String:
                writer.WriteStringValue(tree.AsString());
                break;
            case FactorioPropertyTreeType.List:
                writer.WriteStartArray();
                foreach (var nestedTree in tree.AsList()) JsonSerializer.Serialize(writer, nestedTree, options);
                writer.WriteEndArray();
                break;
            case FactorioPropertyTreeType.Dictionary:
                writer.WriteStartObject();
                foreach (var (key, value) in tree.AsDictionary()) {
                    writer.WritePropertyName(key);
                    JsonSerializer.Serialize(writer, value, options);
                }
                writer.WriteEndObject();
                break;
            default:
                throw new ArgumentOutOfRangeException();
        }
    }
}