using System;
using FactorioParanoidal.FactorioMods.Mods;

namespace ModProvenance.Models;

public sealed record ModProvenanceExpectedEntry(string Name, FactorioVersion Version, string ContentHash,
    string? MetadataHash = null);
