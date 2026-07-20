using System.Collections.Generic;
using System.Text;
using ModProvenance;

namespace ModProvenance.Models;

public sealed record ModProvenanceReport(IReadOnlyList<ModProvenanceResult> Results,
    IReadOnlyList<string> Failures)
{
    public override string ToString()
    {
        var summary = new StringBuilder();
        if (this.Results.Count == 0)
        {
            summary.AppendLine("No local mod directories were found.");
            return summary.ToString();
        }

        summary.AppendLine("| Mod | Version | Result |");
        summary.AppendLine("|---|---:|---|");
        foreach (var result in this.Results)
        {
            var link = result.Status == ModProvenanceStatus.ProjectMod
                ? $"`{result.Name}`"
                : $"[`{result.Name}`](https://mods.factorio.com/mod/{result.Name})";
            summary.AppendLine($"| {link} | {result.Version} | {GetStatusText(result.Status)} |");
            if (result.Changes.Count > 0)
            {
                summary.AppendLine($"\n## `{result.Name}` changes\n");
                foreach (var change in result.Changes)
                    summary.AppendLine($"- `{change.Kind.ToString().ToLowerInvariant()}` `{change.Path}`");
            }

            if (!string.IsNullOrEmpty(result.Error))
                summary.AppendLine($"\n**Error:** {result.Error}\n");

            if (!string.IsNullOrEmpty(result.MetadataTemplate))
            {
                summary.AppendLine($"\n### Create `mods-metadata/{result.Name}.json`\n");
                summary.AppendLine("```json");
                summary.AppendLine(result.MetadataTemplate);
                summary.AppendLine("```\n");
            }
        }

        return summary.ToString();
    }
    
    private static string GetStatusText(ModProvenanceStatus status) => status switch
    {
        ModProvenanceStatus.Unchanged => "unchanged, lock verified",
        ModProvenanceStatus.ExactUpstream => "exact upstream copy",
        ModProvenanceStatus.LockMismatch => "differs from lock",
        ModProvenanceStatus.Removed => "removed from modpack",
        ModProvenanceStatus.MetadataWithoutMod => "metadata exists without mod",
        ModProvenanceStatus.MetadataRemoved => "obsolete metadata removed",
        ModProvenanceStatus.Modified => "modified",
        ModProvenanceStatus.ProjectMod => "project mod",
        ModProvenanceStatus.InvalidMetadata => "invalid metadata",
        ModProvenanceStatus.SourceNotFound => "source not found",
        ModProvenanceStatus.ReleaseNotFound => "release not found",
        ModProvenanceStatus.CheckFailed => "check failed",
        _ => status.ToString()
    };
}
