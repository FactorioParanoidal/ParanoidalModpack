using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using Nuke.Common;
using Nuke.Common.Utilities;
public class FactorioMod {
    private string _modPath;
    JObject? _cachedModInfo;
    public FactorioMod(string path) {
        Assert.DirectoryExists(path, "Required mod directory does not exists");
        _modPath = path;
    }

    private JObject GetModInfo() {
        if (_cachedModInfo != null) return _cachedModInfo;
        var infoPath = Path.Combine(_modPath, "info.json");
        var infoText = File.ReadAllText(infoPath);
        _cachedModInfo = JObject.Parse(infoText);
        return _cachedModInfo;
    }

    public Version GetModVersion() {
        var info = GetModInfo();
        var version = info["version"];
        return new Version(version!.ToString());
    }

    public IEnumerable<string> GetDependencies() {
        var modInfo = GetModInfo();
        return modInfo.Property("dependencies")!.First().ToObject<List<string>>()!;
    }

    public Version GetDependsOnFactorioVersion() {
        // BUG Currently it can works only with dependency in format "base >= 1.1.1"
        var versionString = GetDependencies().FirstOrDefault(s => s.StartsWith("base"))?[8..]
                         ?? GetModInfo().GetPropertyStringValue("factorio_version");
        return Version.Parse(versionString);
    }
    public string GetInternalName() {
        var modInfo = GetModInfo();
        return modInfo.Property("name")!.ToObject<string>()!;
    }
}