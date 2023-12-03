using System;
using System.Buffers.Binary;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace ModSettings;

public class ModSettingsSteamReader {
    readonly Stream Stream;

    public ModSettingsSteamReader(Stream stream) {
        Stream = stream;
    }

    public Version ReadVersion() {
        var bytes = new byte[8].AsSpan();
        Stream.ReadExactly(bytes);

        return new Version(
            BinaryPrimitives.ReadUInt16LittleEndian(bytes.Slice(0, 2)),
            BinaryPrimitives.ReadUInt16LittleEndian(bytes.Slice(2, 2)),
            BinaryPrimitives.ReadUInt16LittleEndian(bytes.Slice(4, 2)),
            BinaryPrimitives.ReadUInt16LittleEndian(bytes.Slice(6, 2))
        );
    }

    public bool ReadBool()
        => BitConverter.ToBoolean(ReadSpan(sizeof(bool)));

    public byte ReadByte()
        => (byte)Stream.ReadByte();

    public uint ReadUInt()
        => BinaryPrimitives.ReadUInt32LittleEndian(ReadSpan(sizeof(uint)));

    public double ReadDouble()
        => BinaryPrimitives.ReadDoubleLittleEndian(ReadSpan(sizeof(double)));

    public uint ReadSpaceOptimizedUInt() {
        var value = ReadByte();
        return value == byte.MaxValue ? ReadUInt() : value;
    }

    public string ReadString() {
        if (ReadBool())
            return string.Empty;

        var stringSize = ReadSpaceOptimizedUInt();
        return Encoding.UTF8.GetString(ReadSpan((int)stringSize));
    }

    public IReadOnlyList<FactorioPropertyTree> ReadList() {
        var elementCount = ReadUInt();

        var list = new List<FactorioPropertyTree>((int)elementCount);
        for (var i = 0; i < elementCount; i++) list.Add(ReadPropertyTree());

        return list;
    }

    public Dictionary<string, FactorioPropertyTree> ReadDictionary() {
        var elementCount = ReadUInt();

        var dict = new Dictionary<string, FactorioPropertyTree>((int)elementCount);
        for (var i = 0; i < elementCount; i++) {
            var readString = ReadString();
            dict[readString] = ReadPropertyTree();
        }

        return dict;
    }

    Span<byte> ReadSpan(int size) {
        var bytes = new byte[size].AsSpan();
        Stream.ReadExactly(bytes);

        return bytes;
    }

    public FactorioPropertyTree ReadPropertyTree()
        => FactorioPropertyTree.ReadFromStream(this);
}