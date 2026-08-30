using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using FactorioParanoidal.FactorioMods;
using FactorioParanoidal.FactorioMods.Mods;
using Fallout.Common;
using ModDescriptions;
using ModProvenance;
using ModProvenance.Models;
using Serilog;

partial class Build
{
    [Parameter("Checks lock mismatches against the exact Mod Portal release without changing the lock file")]
    public bool CheckModPortal { get; }

    [Parameter("Removes obsolete metadata and maintains the lock when every other mismatch is an exact Mod Portal release")]
    public bool MaintainModProvenance { get; }

    [Parameter("Creates metadata templates for modified Mod Portal mods without changing the expected file")]
    public bool PrepareModProvenance { get; }

    Target CheckModProvenance => _ => _
        .Description("Checks mod descriptions and local mods against the exact Mod Portal release").Executes((Func<Task>)(async () =>
        {
            var modpack = await FactorioModpack.LoadFromDirectory(RootDirectory / "mods");
            var mods = modpack.Mods.OfType<FolderFactorioMod>()
                .OrderBy(x => x.Info.Name, StringComparer.Ordinal)
                .ToArray();
            var descriptionsChecker = new ModDescriptionsChecker(RootDirectory);
            descriptionsChecker.Check(mods);
            var checker = new ModProvenanceChecker(RootDirectory, SerializerOptions);
            var modProvenanceOptions = new ModProvenanceOptions(CheckModPortal, MaintainModProvenance,
                PrepareModProvenance);
            var report = await checker.CheckAsync(modProvenanceOptions, mods);
            var summary = "# Mod provenance\n\n" + report;

            Log.Information("{Summary}", summary);
            var summaryPath = Environment.GetEnvironmentVariable("GITHUB_STEP_SUMMARY");
            if (!string.IsNullOrWhiteSpace(summaryPath))
                File.AppendAllText(summaryPath, summary);

            if (report.Failures.Count > 0)
                throw new Exception("Mod provenance check failed:\n" +
                                    string.Join("\n", report.Failures.Select(x => $"- {x}")));
        }));
}
