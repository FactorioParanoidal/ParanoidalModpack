using System.IO;
using System.Linq;
using Nuke.Common;

public class ParanoidalRepository {
    public const string CoreModeName = "zzzparanoidal";

    private string _rootPath;
    public ParanoidalRepository(string rootPath) {
        _rootPath = rootPath;
        Assert.DirectoryExists(Path.Combine(rootPath, "mods"), "Repository mods folder does not exists");
    }

    public string? LocateMod(string modName) {
        modName = modName.ToLower();
        var modDirectories = Directory.GetDirectories(Path.Combine(_rootPath, "mods"));
        return modDirectories.FirstOrDefault(s => Path.GetFileName(s).ToLower().Contains(modName));
    }
}