using System.Collections.Generic;
using System.Linq;
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

        var problems = Results.Where(IsProblem).ToArray();
        if (problems.Length > 0)
        {
            summary.AppendLine("## Problems\n");
            foreach (var result in problems)
                summary.AppendLine($"- [{result.Name}](#{GetAnchor(result.Name)}) - {GetProblemText(result)}");
            summary.AppendLine();
        }

        summary.AppendLine("## All mods\n");
        summary.AppendLine("| Mod | Version | Result | Reason |");
        summary.AppendLine("|---|---:|---|---|");
        foreach (var result in Results)
        {
            var link = result.Status == ModProvenanceStatus.ProjectMod
                ? $"`{result.Name}`"
                : $"[`{result.Name}`](https://mods.factorio.com/mod/{result.Name})";
            var reason = string.IsNullOrWhiteSpace(result.ChangeReason)
                ? "-"
                : $"**{EscapeTableCell(result.ChangeReason)}**";
            summary.AppendLine($"| {link} | {result.Version} | {GetStatusText(result.Status)} | {reason} |");
        }

        foreach (var result in problems)
        {
            summary.AppendLine($"\n<a id=\"{GetAnchor(result.Name)}\"></a>");
            summary.AppendLine($"## `{result.Name}`\n");
            if (!string.IsNullOrEmpty(result.Error)) summary.AppendLine($"**Error:** {result.Error}\n");
            if (!string.IsNullOrEmpty(result.MetadataTemplate))
            {
                summary.AppendLine("**Metadata template:**\n");
                summary.AppendLine("```json");
                summary.AppendLine(result.MetadataTemplate);
                summary.AppendLine("```\n");
            }

            if (result.Changes.Count > 0)
            {
                summary.AppendLine("**File differences:**\n");
                summary.AppendLine("```diff");
                foreach (var change in result.Changes)
                {
                    if (change.Kind is ChangeKind.Removed or ChangeKind.Changed)
                        summary.AppendLine($"- {change.Path}");
                    if (change.Kind is ChangeKind.Added or ChangeKind.Changed)
                        summary.AppendLine($"+ {change.Path}");
                }
                summary.AppendLine("```\n");
            }
        }

        return summary.ToString();
    }

    private static bool IsProblem(ModProvenanceResult result) => !string.IsNullOrEmpty(result.Error);

    private static string GetAnchor(string name) => "mod-" +
        new string(name.ToLowerInvariant().Select(character => char.IsLetterOrDigit(character) ? character : '-').ToArray())
            .Trim('-');

    private static string GetProblemText(ModProvenanceResult result) => result.Status switch
    {
        ModProvenanceStatus.Modified when result.MetadataTemplate is not null => "modified; metadata required",
        ModProvenanceStatus.Modified => "modified; metadata invalid or stale",
        _ => GetStatusText(result.Status)
    };

    private static string EscapeTableCell(string value) => value.Replace("|", "\\|").Replace("\r", " ").Replace("\n", " ");

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
