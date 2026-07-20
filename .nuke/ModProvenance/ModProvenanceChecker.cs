#nullable enable
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using FactorioParanoidal.FactorioApi;
using FactorioParanoidal.FactorioApi.DependencyInjection;
using FactorioParanoidal.FactorioApi.ModPortal;
using FactorioParanoidal.FactorioMods;
using FactorioParanoidal.FactorioMods.Mods;
using Microsoft.Extensions.DependencyInjection;
using ModProvenance.Models;
using Nuke.Common.IO;
using Serilog;

namespace ModProvenance;

public sealed class ModProvenanceChecker(AbsolutePath rootDirectory, JsonSerializerOptions serializerOptions)
{
    const string ExpectedModsFile = "!expected.json";
    const string ModMetadataFolder = "mods-metadata";
    private readonly AbsolutePath _lockPath = rootDirectory / ModMetadataFolder / ExpectedModsFile;

    public async Task<ModProvenanceReport> CheckAsync(ModProvenanceOptions options)
    {
        var mods = await LoadMods();
        var failures = new List<string>();
        var results = new List<ModProvenanceResult>();
        Log.Debug("Loaded {ModCount} folder mods from {ModsDirectory}", mods.Count, rootDirectory / "mods");
        if (mods.Count == 0)
            return new ModProvenanceReport(results, failures);
        var metadata = LoadModMetadata();
        var expected = LoadExpected();
        Log.Debug("Loaded {MetadataCount} metadata declarations and {ExpectedCount} expected entries from {LockPath}",
            metadata.Count, expected.Mods.Count, _lockPath);
        var modNames = mods.Select(x => x.Info.Name).ToHashSet(StringComparer.Ordinal);
        var maintenanceChanges = false;
        foreach (var orphanedMetadata in metadata.Values
                     .Where(x => !modNames.Contains(x.Mod))
                     .OrderBy(x => x.Mod, StringComparer.Ordinal))
        {
            const string error = "metadata file exists, but the corresponding mod is missing from the modpack";
            if (options.Maintenance)
            {
                var metadataPath = rootDirectory / ModMetadataFolder / $"{orphanedMetadata.Mod}.json";
                File.Delete(metadataPath);
                metadata.Remove(orphanedMetadata.Mod);
                maintenanceChanges = true;
                Log.Information("Removed obsolete metadata file {MetadataPath}", metadataPath);
                results.Add(
                    new ModProvenanceResult(orphanedMetadata.Mod, null, ModProvenanceStatus.MetadataRemoved, []));
            }
            else
            {
                Log.Warning("Orphaned metadata found for {Mod}: {Error}", orphanedMetadata.Mod, error);
                results.Add(new ModProvenanceResult(orphanedMetadata.Mod, null, ModProvenanceStatus.MetadataWithoutMod,
                    [], error));
                failures.Add($"{orphanedMetadata.Mod}: {error}");
            }
        }

        var updatedEntries = expected.Mods
            .Where(x => modNames.Contains(x.Name))
            .ToDictionary(x => x.Name, StringComparer.Ordinal);
        var lockMismatchCount = 0;
        var acceptedCount = 0;
        await using var services = CreateFactorioApiServices();

        foreach (var mod in mods)
        {
            var name = mod.Info.Name;
            var version = mod.Info.Version;
            metadata.TryGetValue(name, out var declaration);
            var currentDirectory = AbsolutePath.Create(mod.Directory);
            var currentHash = ModFileComparer.GetDirectoryHash(currentDirectory);
            var expectedEntry = expected.Mods.SingleOrDefault(x => x.Name == name);
            var isLocal = declaration?.Source == "local";
            Log.Debug("Inspecting {Mod} version {Version}: directory hash {ContentHash}", name, version,
                currentHash);

            var metadataHash = GetMetadataHash(declaration);
            var requiresMetadataMigration = options.Maintenance && declaration is not null &&
                                            expectedEntry?.MetadataHash is null;
            if (!requiresMetadataMigration && expectedEntry is not null && expectedEntry.Version == version &&
                expectedEntry.ContentHash == currentHash &&
                (expectedEntry.MetadataHash is null || expectedEntry.MetadataHash == metadataHash))
            {
                Log.Debug("Expected entry matched for {Mod}: version {Version}, hash {ContentHash}",
                    name, version, currentHash);
                results.Add(new ModProvenanceResult(name, version, ModProvenanceStatus.Unchanged, [],
                    ChangeReason: declaration?.ChangeReason));

                continue;
            }

            Log.Debug(
                "Expected miss for {Mod}: expected version={ExpectedVersion}, hash={ExpectedHash}; actual version={Version}, hash={CurrentHash}",
                name, expectedEntry?.Version, expectedEntry?.ContentHash ?? "<none>", version, currentHash);
            lockMismatchCount++;

            if (isLocal || !options.VerifyUpstream)
            {
                if (isLocal && options.Maintenance)
                {
                    Log.Information("Registering {Mod} as a local project mod in the provenance lock", name);
                    updatedEntries[name] = new ModProvenanceExpectedEntry(name, version, currentHash, metadataHash);
                    acceptedCount++;
                    results.Add(new ModProvenanceResult(name, version, ModProvenanceStatus.ProjectMod, [],
                        ChangeReason: declaration?.ChangeReason));
                }
                else
                {
                    var status = isLocal ? ModProvenanceStatus.ProjectMod : ModProvenanceStatus.LockMismatch;
                    var error = isLocal
                        ? "local project mod is not present in the provenance lock; run maintenance to register it"
                        : "mod differs from upstream lock; run with --check-mod-portal to verify the current version";
                    Log.Warning("{Mod} lock mismatch: {Error}", name, error);
                    results.Add(new ModProvenanceResult(name, version, status, [], error,
                        ChangeReason: declaration?.ChangeReason));
                    failures.Add($"{name}: {error}");
                }

                continue;
            }

            var currentFiles = ModFileComparer.ReadDirectoryFiles(currentDirectory);
            Log.Debug("Calculated per-file hashes for {FileCount} files in {Mod} after lock miss",
                currentFiles.Count, name);

            var upstreamResult = await CheckUpstreamAsync(mod, version, currentFiles, currentHash,
                declaration, expectedEntry, metadataHash, options, services.GetRequiredService<IFactorioApi>());
            results.Add(upstreamResult.Result with { ChangeReason = declaration?.ChangeReason });
            if (upstreamResult.IsAccepted)
            {
                acceptedCount++;
                updatedEntries[name] = upstreamResult.ExpectedEntry! with
                {
                    MetadataHash = upstreamResult.Result.Status == ModProvenanceStatus.Modified ? metadataHash : null
                };
            }
            else
                failures.Add($"{name}: {upstreamResult.Result.Error ?? "current files do not match upstream"}");
        }

        foreach (var removed in expected.Mods.Where(x => !modNames.Contains(x.Name)))
        {
            const string error = "mod is present in lock but missing from the current modpack";
            if (options.Maintenance)
            {
                Log.Information("Removing obsolete lock entry for {Mod}", removed.Name);
                results.Add(new ModProvenanceResult(removed.Name, removed.Version, ModProvenanceStatus.Removed, []));
                maintenanceChanges = true;
            }
            else
            {
                results.Add(new ModProvenanceResult(removed.Name, removed.Version, ModProvenanceStatus.Removed, [],
                    error));
                failures.Add($"{removed.Name}: {error}");
                lockMismatchCount++;
            }
        }

        if (options.Maintenance)
        {
            if (lockMismatchCount == acceptedCount && failures.Count == 0)
            {
                if (lockMismatchCount > 0 || maintenanceChanges)
                {
                    SaveLock(new ModProvenanceExpected(1,
                        updatedEntries.Values.OrderBy(x => x.Name, StringComparer.Ordinal).ToArray()));
                    Log.Information("Updated provenance expected file with {UpdateCount} accepted updates",
                        acceptedCount);
                }
                else
                    Log.Information("Provenance lock is already up to date");
            }
            else
                failures.Add("expected update refused: every change must be exact upstream, local, or documented");
        }

        Log.Debug("Provenance check completed: {ResultCount} results, {FailureCount} failures", results.Count,
            failures.Count);
        return new ModProvenanceReport(results, failures);
    }

    private async Task<UpstreamCheckResult> CheckUpstreamAsync(FolderFactorioMod mod, FactorioVersion version,
        IReadOnlyDictionary<string, string> currentFiles, string currentHash,
        ModMetadata? declaration, ModProvenanceExpectedEntry? previousExpected, string? metadataHash,
        ModProvenanceOptions options, IFactorioApi api)
    {
        var name = mod.Info.Name;
        try
        {
            Log.Debug("Requesting Mod Portal file for {Mod}", name);
            await using var archive = await api.DownloadAsync(name, version);
            var upstream = await ModFileComparer.ReadArchiveFilesAsync(archive);
            var changes = ModFileComparer.Compare(currentFiles, upstream.Files);
            Log.Debug("Compared {Mod}: upstream hash {UpstreamHash}, {FileCount} upstream files, {ChangeCount} changes",
                name, upstream.ContentHash, upstream.Files.Count, changes.Count);
            foreach (var change in changes.Take(10))
                Log.Debug("{Mod} file difference: {ChangeKind} {Path}", name, change.Kind, change.Path);
            if (changes.Count > 10)
                Log.Debug("{Mod}: {RemainingChangeCount} additional file differences omitted", name,
                    changes.Count - 10);
            if (changes.Count == 0)
                return new UpstreamCheckResult(
                    new ModProvenanceResult(name, version, ModProvenanceStatus.ExactUpstream, changes),
                    new ModProvenanceExpectedEntry(name, version, currentHash), true);

            if (ValidateDeclaredChange(name, version, declaration, previousExpected, currentHash, metadataHash,
                    out var metadataError))
                return new UpstreamCheckResult(
                    new ModProvenanceResult(name, version, ModProvenanceStatus.Modified, changes),
                    new ModProvenanceExpectedEntry(name, version, currentHash), true);

            var metadataTemplate = declaration is null ? SerializeMetadataTemplate(name, version) : null;
            if (metadataTemplate is not null && options.Prepare)
                CreateMetadataTemplate(name, metadataTemplate);

            return new UpstreamCheckResult(
                new ModProvenanceResult(name, version, ModProvenanceStatus.Modified, changes, metadataError,
                    metadataTemplate),
                null, false);
        }
        catch (ModPortalHttpException exception) when (exception.StatusCode == HttpStatusCode.NotFound)
        {
            var error = declaration is null
                ? "not found on the Mod Portal; add a metadata declaration with source 'local' or portalName"
                : "configured Mod Portal source was not found";
            Log.Warning("Mod Portal source not found for {Mod} version {Version}: {Error}", name, version, error);
            return new UpstreamCheckResult(
                new ModProvenanceResult(name, version, ModProvenanceStatus.SourceNotFound, [], error), null,
                false);
        }
        catch (UpstreamReleaseNotFoundException exception)
        {
            Log.Warning("Mod Portal release missing for {Mod} version {Version}", name, version);
            return new UpstreamCheckResult(
                new ModProvenanceResult(name, version, ModProvenanceStatus.ReleaseNotFound, [], exception.Message),
                null, false);
        }
        catch (Exception exception) when (exception is HttpRequestException or IOException)
        {
            Log.Warning(exception, "Upstream verification failed for {Mod} version {Version}", name, version);
            return new UpstreamCheckResult(
                new ModProvenanceResult(name, version, ModProvenanceStatus.CheckFailed, [], exception.Message), null,
                false);
        }
        catch (Exception exception)
        {
            Log.Error(exception, "Unexpected provenance verification error for {Mod} version {Version}", name, version);
            return new UpstreamCheckResult(
                new ModProvenanceResult(name, version, ModProvenanceStatus.CheckFailed, [], exception.Message), null,
                false);
        }
    }

    private string SerializeMetadataTemplate(string modName, Version version) =>
        JsonSerializer.Serialize(new
        {
            Mod = modName,
            Source = "portal",
            UpstreamVersion = version,
            ChangeReason = string.Empty
        }, serializerOptions);

    private void CreateMetadataTemplate(string modName, string metadataTemplate)
    {
        var path = rootDirectory / ModMetadataFolder / $"{modName}.json";
        if (File.Exists(path)) return;

        Directory.CreateDirectory(Path.GetDirectoryName(path)!);
        File.WriteAllText(path, metadataTemplate + Environment.NewLine);
        Log.Information("Created metadata template {MetadataPath}", path);
    }

    private string? GetMetadataHash(ModMetadata? metadata)
    {
        if (metadata is null) return null;
        var json = JsonSerializer.Serialize(metadata, serializerOptions);
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(json))).ToLowerInvariant();
    }

    private static bool ValidateDeclaredChange(string modName, Version version, ModMetadata? declaration,
        ModProvenanceExpectedEntry? previousExpected, string currentHash, string? metadataHash, out string error)
    {
        if (declaration is null || string.IsNullOrWhiteSpace(declaration.ChangeReason))
        {
            error = $"current files differ from the exact Mod Portal release; add a change reason in mods-metadata/{modName}.json";
            return false;
        }

        if (declaration.UpstreamVersion != version)
        {
            error = $"metadata upstreamVersion must be {version}, but is {declaration.UpstreamVersion}";
            return false;
        }

        if (previousExpected is not null && previousExpected.ContentHash != currentHash &&
            previousExpected.MetadataHash == metadataHash)
        {
            error = $"mod changed since its last accepted state, but mods-metadata/{modName}.json was not updated";
            return false;
        }

        error = string.Empty;
        return true;
    }

    private async Task<IReadOnlyList<FolderFactorioMod>> LoadMods()
    {
        var modpack = await FactorioModpack.LoadFromDirectory(rootDirectory / "mods");
        Log.Debug("FactorioModpack discovered {ModCount} mods", modpack.Mods.Count);
        return modpack.Mods.OfType<FolderFactorioMod>()
            .OrderBy(x => x.Info.Name, StringComparer.Ordinal)
            .ToArray();
    }

    private Dictionary<string, ModMetadata> LoadModMetadata()
    {
        var metadataDirectory = rootDirectory / ModMetadataFolder;
        if (!Directory.Exists(metadataDirectory))
        {
            Log.Debug("Metadata directory does not exist: {MetadataDirectory}", metadataDirectory);
            return new Dictionary<string, ModMetadata>(StringComparer.Ordinal);
        }

        var result = new Dictionary<string, ModMetadata>(StringComparer.Ordinal);
        foreach (var path in Directory.EnumerateFiles(metadataDirectory, "*.json", SearchOption.TopDirectoryOnly)
                     .Where(x => !string.Equals(Path.GetFileName(x), ExpectedModsFile, StringComparison.Ordinal)))
        {
            var metadata = JsonSerializer.Deserialize<ModMetadata>(File.ReadAllText(path), serializerOptions)
                           ?? throw new JsonException($"Could not deserialize {path}.");
            ValidateMetadata(metadata, path);
            if (!string.Equals(Path.GetFileNameWithoutExtension(path), metadata.Mod, StringComparison.Ordinal))
                throw new InvalidOperationException(
                    $"Metadata file name must match mod name: expected {metadata.Mod}.json, got {Path.GetFileName(path)}.");
            if (!result.TryAdd(metadata.Mod, metadata))
                throw new InvalidOperationException($"Duplicate metadata for mod {metadata.Mod}.");
        }

        Log.Debug("Loaded metadata declarations: {MetadataCount}", result.Count);
        return result;
    }

    private static void ValidateMetadata(ModMetadata metadata, string path)
    {
        if (metadata.Source != "local") return;
        if (string.IsNullOrWhiteSpace(metadata.ChangeReason))
            throw new InvalidOperationException($"Local mod metadata {path} must explain why the mod is local.");
        if (metadata.Original is null)
            return;
        if (string.IsNullOrWhiteSpace(metadata.Original.Name))
            throw new InvalidOperationException($"Local mod metadata {path} must specify the original mod name.");
        if (metadata.Original.Authors.Count == 0 || metadata.Original.Authors.Any(string.IsNullOrWhiteSpace))
            throw new InvalidOperationException($"Local mod metadata {path} must specify original authors.");
        if (string.IsNullOrWhiteSpace(metadata.Original.Portal.Name) ||
            string.IsNullOrWhiteSpace(metadata.Original.Portal.Url))
            throw new InvalidOperationException(
                $"Original in {path} must specify its Mod Portal name and URL.");
    }

    private ModProvenanceExpected LoadExpected()
    {
        if (!File.Exists(_lockPath))
        {
            Log.Debug("Provenance expected file does not exist: {ExpectedPath}", _lockPath);
            return new ModProvenanceExpected(1, []);
        }

        var expected =
            JsonSerializer.Deserialize<ModProvenanceExpected>(File.ReadAllText(_lockPath), serializerOptions)
            ?? throw new JsonException($"Could not deserialize {_lockPath}.");
        if (expected.SchemaVersion != 1)
            throw new InvalidOperationException(
                $"Unsupported mod provenance expected version {expected.SchemaVersion}.");
        Log.Debug("Loaded provenance expected file {ExpectedPath}: schema {SchemaVersion}, {EntryCount} entries",
            _lockPath, expected.SchemaVersion, expected.Mods.Count);
        return expected;
    }

    private void SaveLock(ModProvenanceExpected provenanceExpected)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(_lockPath)!);
        File.WriteAllText(_lockPath,
            JsonSerializer.Serialize(provenanceExpected, serializerOptions) + Environment.NewLine);
        Log.Debug("Saved provenance lock {LockPath}: {EntryCount} entries", _lockPath, provenanceExpected.Mods.Count);
    }

    private static ServiceProvider CreateFactorioApiServices()
    {
        var services = new ServiceCollection();
        services.AddFactorioModPortal().UseRe146ModDownloader();
        return services.BuildServiceProvider();
    }

}
