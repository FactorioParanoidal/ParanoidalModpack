using System;
using System.Collections.Generic;

namespace ModProvenance.Models;

public sealed record ModProvenanceResult(
    string Name,
    Version? Version,
    ModProvenanceStatus Status,
    IReadOnlyList<FileChange> Changes,
    string? Error = null,
    string? MetadataTemplate = null,
    string? ChangeReason = null);
