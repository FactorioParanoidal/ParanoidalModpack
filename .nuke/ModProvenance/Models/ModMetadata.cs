using System;
namespace ModProvenance.Models;

public sealed record ModMetadata(string Mod, string Source = "portal",
    Version? UpstreamVersion = null, OriginalMod? Original = null, string? ChangeReason = null);
