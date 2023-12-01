using System;
using System.Collections.Generic;

namespace ModSettings;

public class FactorioPropertyTree {
    FactorioPropertyTree(FactorioPropertyTreeType type, object? value) {
        Type = type;
        Value = value;
    }

    public static FactorioPropertyTree ReadFromStream(ModSettingsSteamReader streamReader) {
        var type = (FactorioPropertyTreeType)streamReader.ReadByte();
        _ = streamReader.ReadBool();

        object? content = type switch {
            FactorioPropertyTreeType.None       => null,
            FactorioPropertyTreeType.Bool       => streamReader.ReadBool(),
            FactorioPropertyTreeType.Number     => streamReader.ReadDouble(),
            FactorioPropertyTreeType.String     => streamReader.ReadString(),
            FactorioPropertyTreeType.List       => streamReader.ReadList(),
            FactorioPropertyTreeType.Dictionary => streamReader.ReadDictionary(),
            _                                   => throw new ArgumentOutOfRangeException(nameof(type), "No such PropertyTree type supported")
        };

        return new FactorioPropertyTree(type, content);
    }

    public FactorioPropertyTreeType Type { get; }
    public object? Value { get; }

    public bool AsBool()
        => (bool)Value!;

    public double AsNumber()
        => (double)Value!;

    public string AsString()
        => (string)Value!;

    public List<FactorioPropertyTree> AsList()
        => (List<FactorioPropertyTree>)Value!;

    public Dictionary<string, FactorioPropertyTree> AsDictionary()
        => (Dictionary<string, FactorioPropertyTree>)Value!;
}