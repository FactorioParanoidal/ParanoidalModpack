namespace ModProvenance.Models;

public sealed record FileChange(string Path, ChangeKind Kind);