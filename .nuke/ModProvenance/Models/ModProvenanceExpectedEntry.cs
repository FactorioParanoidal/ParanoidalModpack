using System;

namespace ModProvenance.Models;

public sealed record ModProvenanceExpectedEntry(string Name, Version Version, string ContentHash,
    string? MetadataHash = null);
