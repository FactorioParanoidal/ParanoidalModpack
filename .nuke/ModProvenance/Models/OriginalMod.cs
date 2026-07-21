using System.Collections.Generic;

namespace ModProvenance.Models;

public sealed record OriginalMod(string Name, IReadOnlyList<string> Authors, OriginalModPortal Portal);
