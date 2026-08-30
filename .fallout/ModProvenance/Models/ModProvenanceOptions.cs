namespace ModProvenance.Models;

public sealed record ModProvenanceOptions(bool CheckModPortal = false, bool Maintenance = false, bool Prepare = false)
{
    public bool VerifyUpstream => CheckModPortal || Maintenance || Prepare;
}
