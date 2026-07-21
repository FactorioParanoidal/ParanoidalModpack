#nullable enable
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using ModProvenance;
using ModProvenance.Models;
using Nuke.Common;
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
        .Description("Checks local mods against the exact Mod Portal release").Executes((Func<Task>)(async () =>
        {
            var checker = new ModProvenanceChecker(RootDirectory, SerializerOptions);
            var modProvenanceOptions = new ModProvenanceOptions(CheckModPortal, MaintainModProvenance,
                PrepareModProvenance);
            var report = await checker.CheckAsync(modProvenanceOptions);
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
