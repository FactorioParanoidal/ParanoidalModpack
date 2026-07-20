using System.Collections.Generic;

namespace ModProvenance.Models;

public sealed record ModProvenanceExpected(int SchemaVersion, IReadOnlyList<ModProvenanceExpectedEntry> Mods);
