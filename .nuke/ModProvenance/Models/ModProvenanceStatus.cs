namespace ModProvenance.Models;

public enum ModProvenanceStatus
{
    Unchanged,
    ExactUpstream,
    LockMismatch,
    Removed,
    MetadataWithoutMod,
    MetadataRemoved,
    Modified,
    ProjectMod,
    InvalidMetadata,
    SourceNotFound,
    ReleaseNotFound,
    CheckFailed
}
