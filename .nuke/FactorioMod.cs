using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using Nuke.Common;
using Nuke.Common.Utilities;

public class FactorioMod {
    private string _modPath;
    public FactorioMod(string path) {
        Assert.DirectoryExists(path, "Required mod directory does not exists");
        _modPath = path;
    }

    private JObject GetModInfo() {
        var infoPath = Path.Combine(_modPath, "info.json");
        var infoText = File.ReadAllText(infoPath);
        return JObject.Parse(infoText);
    }

    public IEnumerable<string> GetDependencies() {
        var modInfo = GetModInfo();
        return modInfo.Property("dependencies").First().ToObject<List<string>>();
    }

    public Version GetDependsOnFactorioVersion() {
        // BUG Currently it can works only with dependency in format "base >= 1.1.1"
        var versionString = GetDependencies().FirstOrDefault(s => s.StartsWith("base"))?[8..]
                         ?? GetModInfo().GetPropertyStringValue("factorio_version");
        return Version.Parse(versionString);
    }
}