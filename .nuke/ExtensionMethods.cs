using System;
using System.IO;
using System.Linq;
using FactorioParanoidal.FactorioMods.Mods;
using Nuke.Common.IO;

public static class ExtensionMethods
{
    public static Version GetBaseBaseRequiredVersion(this IFactorioMod factorioMod)
    {
        var factorioDependency = factorioMod.Info.Dependencies?.FirstOrDefault(dep => dep.Name == "base");
        if (factorioDependency?.EqualityVersion is null)
        {
            throw new Exception("No factorio version dependency specified in zzzparanoidal mod");
        }

        return factorioDependency.EqualityVersion.Version;
    }

    public static void CreateDirectoryForFile(this AbsolutePath path)
    {
        var directoryName = Path.GetDirectoryName(path);
        if (directoryName != null) Directory.CreateDirectory(directoryName);
    }
}