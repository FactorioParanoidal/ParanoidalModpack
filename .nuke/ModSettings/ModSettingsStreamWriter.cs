using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace ModSettings;

public class ModSettingsStreamWriter {
    readonly Stream Stream;

    public ModSettingsStreamWriter(Stream stream) {
        Stream = stream;
    }

    public void WriteVersion(Version version) {
        Stream.Write(BitConverter.GetBytes((ushort)version.Major));
        Stream.Write(BitConverter.GetBytes((ushort)version.Minor));
        Stream.Write(BitConverter.GetBytes((ushort)version.Build));
        Stream.Write(BitConverter.GetBytes((ushort)version.Revision));
    }

    public void WriteBool(bool value)
        => Stream.Write(BitConverter.GetBytes(value));

    public void WriteByte(byte value) {
        if (Stream.Position > 51330) { }
        Stream.WriteByte(value);
    }

    public void WriteUInt(uint value)
        => Stream.Write(BitConverter.GetBytes(value));

    public void WriteDouble(double value)
        => Stream.Write(BitConverter.GetBytes(value));

    public void WriteSpaceOptimizedUInt(uint value) {
        if (value < byte.MaxValue)
            Stream.WriteByte((byte)value);
        else {
            Stream.WriteByte(byte.MaxValue);
            WriteUInt(value);
        }
    }

    public void WriteString(string value) {
        WriteBool(value.Length == 0);
        WriteSpaceOptimizedUInt((uint)value.Length);
        Stream.Write(Encoding.UTF8.GetBytes(value));
    }

    public void WriteList(IReadOnlyList<FactorioPropertyTree> list) {
        WriteUInt((uint)list.Count);

        foreach (var factorioPropertyTree in list) factorioPropertyTree.WriteToStream(this);
    }

    public void WriteDictionary(IReadOnlyDictionary<string, FactorioPropertyTree> dictionary) {
        WriteUInt((uint)dictionary.Count);

        foreach (var (key, value) in dictionary) {
            WriteString(key);
            value.WriteToStream(this);
        }
    }

    public void WritePropertyTree(FactorioPropertyTree tree)
        => tree.WriteToStream(this);
}