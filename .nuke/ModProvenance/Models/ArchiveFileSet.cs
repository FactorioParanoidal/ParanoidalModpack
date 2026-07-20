using System.Collections.Generic;

namespace ModProvenance.Models;

public sealed record ArchiveFileSet(IReadOnlyDictionary<string, string> Files, string ContentHash);
