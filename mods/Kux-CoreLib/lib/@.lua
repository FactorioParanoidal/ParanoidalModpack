require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---
---usage: require()"__Kux-CoreLib__/lib/@")
---

KuxCoreLib.lua             .asGlobal()
Modules          = KuxCoreLib.Modules         .asGlobal()
Colors           = KuxCoreLib.Colors          .asGlobal()
Debug            = KuxCoreLib.Debug           .asGlobal()
Log              = KuxCoreLib.Log             .asGlobal()
EventDistributor = KuxCoreLib.EventDistributor--.asGlobal()
Events           = KuxCoreLib.Events          .asGlobal()
Trace            = KuxCoreLib.Trace           .asGlobal()
ErrorHandler     = KuxCoreLib.ErrorHandler    .asGlobal()
FileWriter       = KuxCoreLib.FileWriter      .asGlobal()
FlyingText       = KuxCoreLib.FlyingText      .asGlobal()
String           = KuxCoreLib.String          .asGlobal()
Array            = KuxCoreLib.Array           .asGlobal()
Dictionary       = KuxCoreLib.Dictionary      .asGlobal()
List             = KuxCoreLib.List            .asGlobal()
Table            = KuxCoreLib.Table           .asGlobal()
Version          = KuxCoreLib.Version         .asGlobal()
Path             = KuxCoreLib.Path            .asGlobal()
ModInfo          = KuxCoreLib.ModInfo         .asGlobal()
That             = KuxCoreLib.That            .asGlobal()
Technology       = KuxCoreLib.Technology      .asGlobal()
StringBuilder    = KuxCoreLib.StringBuilder   .asGlobal()

if not script then return KuxCoreLib end

--[ runtime only ]--

KuxCoreLib.Player          .asGlobal()

-- entities --
-- KuxCoreLib.Inserter        .asGlobal()

-- storage --
--TODO DISABELD Storage         = KuxCoreLib.Storage          .asGlobal()
--TODO DISABELD PlayerStorage   = KuxCoreLib.PlayerStorage    .asGlobal()
--TODO DISABELD StoragePlayer   = KuxCoreLib.StoragePlayer    .asGlobal()
--TODO DISABELD StoragePlayers  = KuxCoreLib.StoragePlayers   .asGlobal()


return KuxCoreLib
