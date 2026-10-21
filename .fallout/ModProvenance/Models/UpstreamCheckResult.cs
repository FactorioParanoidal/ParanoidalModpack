namespace ModProvenance.Models;

public sealed record UpstreamCheckResult(ModProvenanceResult Result, ModProvenanceExpectedEntry? ExpectedEntry,
    bool IsAccepted);
