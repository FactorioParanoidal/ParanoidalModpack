using System;

namespace ModProvenance;

public sealed class UpstreamReleaseNotFoundException(string portalName, Version version)
    : InvalidOperationException($"Mod Portal has no {portalName} release {version}.");
