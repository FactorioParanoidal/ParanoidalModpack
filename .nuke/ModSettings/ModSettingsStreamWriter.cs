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

    /// <remarks>
    /// 1 bool if there is no string - then, if there is a string:
    /// 1 Space optimized unsigned int the size of the string
    /// N byte the string contents
    /// </remarks>
    public void WriteString(string value) {
        // but factorio devs fucked up there
        // and actually there is always be false
        // even for empty strings there will be: `false 0` (length)
        WriteBool(false);
        var buffer = Encoding.UTF8.GetBytes(value);
        WriteSpaceOptimizedUInt((uint)buffer.Length);
        Stream.Write(buffer);
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