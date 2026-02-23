--[[---------------------------------------------------------------------------
lib/init.lua
Is the main entry point for the library.
It initializes the library and provides access to all modules.

USAGE: require("__Kux-CoreLib__/lib/init")

_G.KuxCoreLib is a global variaböe that provides access to all modules.
---------------------------------------------------------------------------]]--
-- print(debug.getinfo(1,"S").source)
-- @D:\Develop\Factorio\Mods\Kux-CoreLib/src\lib\init.lua
-- @__Kux-CoreLib__/lib/init.lua
KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/"

---@class KuxCoreLib.Class
---@field __class string The name of the class.
---@field __guid string The unique identifier of the class.
---@field __origin string The path of the class file.
---@field __isInitialized boolean? Indicates whether the class is initialized.
---@field __on_initialized fun(callback:function) List of callback functions to call when the class is initialized.
---@field __setGlobals function? Sets global variables for the class.
---@field __writableMembers string[]? List of members that can be written.
---@field __optionalMembers string[]? List of optional members.
---@field __isGlobal boolean? Indicates whether the class is global. (if asGlobal() was used)
---@field asGlobal fun():KuxCoreLib.Class Makes the class global.


if KuxCoreLib then
    if KuxCoreLib.__guid == "7c4df965-a929-4f58-92e6-4cfa6a60f4b8" then
		--log("Init KuxCoreLib, repeated, initialized:"..tostring(KuxCoreLib.__isInitialized)..", required by \n"..debug.traceback(2))
		--require(KuxCoreLibPath.."modules/require-override")
		return KuxCoreLib
	end
    error("A global class 'KuxCoreLib' already exist.")
else
	--log("Init KuxCoreLib, first time, required by \n"..debug.traceback(2))
end


---@class KuxCoreLib.__modules
--- --------------------------
---@field AsyncTask KuxCoreLib.AsyncTask
---@field Array KuxCoreLib.Array
---@field ColorConverter KuxCoreLib.ColorConverter
---@field Colors KuxCoreLib.Colors
---@field Debug KuxCoreLib.Debug
---@field Dictionary KuxCoreLib.Dictionary
---@field Event KuxCoreLib.Event
---@field EventDistributor KuxCoreLib.EventDistributor
---@field Events KuxCoreLib.Events
---@field FileWriter KuxCoreLib.FileWriter
---@field Flags KuxCoreLib.Flags
---@field FlyingText KuxCoreLib.FlyingText
---@field List KuxCoreLib.List
---@field Log KuxCoreLib.Log
---@field Trace KuxCoreLib.Trace
---@field ErrorHandler KuxCoreLib.ErrorHandler
---@field lua KuxCoreLib.lua
---@field Math KuxCoreLib.Math
---@field ModInfo KuxCoreLib.ModInfo
---@field Modules KuxCoreLib.Modules
---@field Path KuxCoreLib.Path
---@field Player KuxCoreLib.Player
---@field String KuxCoreLib.String
---@field Table KuxCoreLib.Table
---@field Technology KuxCoreLib.Technology
---@field StringBuilder KuxCoreLib.StringBuilder.static
---@field TestRunner KuxCoreLib.TestRunner
---@field That KuxCoreLib.That
---@field Version KuxCoreLib.Version
---@field DataRaw KuxCoreLib.DataRaw
---@field EntityData KuxCoreLib.EntityData
---@field ItemData KuxCoreLib.ItemData
---@field RecipeData KuxCoreLib.RecipeData
---@field PrototypeData KuxCoreLib.PrototypeData
---@field SettingsData KuxCoreLib.SettingsData
---@field TechnologyData KuxCoreLib.TechnologyData
---@field TechnologyIndex KuxCoreLib.TechnologyIndex
---@field BigData KuxCoreLib.BigData
---@field Inserter KuxCoreLib.Inserter
---@field Storage KuxCoreLib.Storage
---@field StoragePlayer KuxCoreLib.StoragePlayer
---@field StoragePlayers KuxCoreLib.StoragePlayers @deprecated
---@field PickerDollies KuxCoreLib.PickerDollies
---@field Factorissimo KuxCoreLib.Factorissimo
---@field SurfacesMod KuxCoreLib.SurfacesMod
---@field CollisionMaskData KuxCoreLib.CollisionMaskData
---@field DataGrid KuxCoreLib.DataGrid
---@field Timer KuxCoreLib.Timer
---@field PlayerStorage KuxCoreLib.PlayerStorage
---@field RadarData KuxCoreLib.RadarData
---@field Radar KuxCoreLib.Radar
---@field Vector KuxCoreLib.Vector.static
---@field LuaGenericPrototype KuxCoreLib.LuaGenericPrototype.static
-- @field SelectionTool KuxCoreLib.SelectionTool
---@field StageBridge KuxCoreLib.StageBridge
---@field FunctionUtils KuxCoreLib.FunctionUtils
---@field LocalizationUtils KuxCoreLib.LocalizationUtils
---@field TranslationService KuxCoreLib.TranslationService
---@field FactorioDatabase KuxCoreLib.FactorioDatabase
---@field RecipeUtils KuxCoreLib.RecipeUtils
---@field ElementUtils KuxCoreLib.ElementUtils


---Provides access to Kux-CoreLib modules<br>
---Usage: `local moduleName = KuxCoreLib.MODULENAME`<br>
---NOTE The syntax `require KuxCoreLib.MODULENAME` is no longer valid <br>
---The local use is suggested to avoid conflicts with other libraries,
---but you can also use the global access. (use `KuxCoreLib.MODULENAME.asGlobal()`)
---to force a class to be global, and override existing classes. (use with caution)
---@class KuxCoreLib : KuxCoreLib.__modules, KuxCoreLib.Class
---@field __modules KuxCoreLib.__modules
---@field __classUtils KuxCoreLib.__classUtils
---@field requireAll function
---@field Data table
---@field __version string
---@field require KuxCoreLib.__modules


---@type KuxCoreLib
---@diagnostic disable-next-line: missing-fields
KuxCoreLib = {
	__class  = "KuxCoreLib",
	__guid   = "7c4df965-a929-4f58-92e6-4cfa6a60f4b8",
	__origin = "Kux-CoreLib/init.lua",

	__modules = {},--[[@diagnostic disable-line: missing-fields]]
	__classUtils = nil,
	__version = (mods or script.active_mods)["Kux-CoreLib"],

	require = {},--[[@diagnostic disable-line: missing-fields]]
}

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/__classUtils")

do -- deprecated

	---@deprecated use KuxCoreLib.PlayerStorage
	---@see KuxCoreLib.PlayerStorage
	KuxCoreLib.StoragePlayers = nil

	---@deprecated use KuxCoreLib.PlayerStorage
	---@see KuxCoreLib.PlayerStorage
	KuxCoreLib.StoragePlayer = nil

end

---------------------------------------------------------------------------------------------------
--NOTE: We must not 'require' lib modules! circular reference!
-- e.g. local Debug = require(KuxCoreLibPath.."lib/Debug") is not allowed

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/InitGlobals")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio20Migrations")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio11BackwardCompatibility")

local require_map = { --RUN (F5) to AUTOGENERATE
        Array = "",
		AsyncTask = "",
        ColorConverter = "",
        Colors = "",
        Debug = "",
        Dictionary = "",
        Event = "",
        EventDistributor = "",
		Events = "",
        FileWriter = "",
        Flags = "",
        FlyingText = "",
        List = "",
        Log = "",
		Trace = "",
        lua = "",
        Math = "",
        ModInfo = "",
        Modules = "",
        Path = "",
        Player = "",
        String = "",
        Table = "",
        Technology = "",
        TestRunner = "",
        That = "",
        Version = "",
		DataGrid = "",
		ErrorHandler = "",
		Timer = "",
		Vector = "",
		LuaGenericPrototype = "",
		RecipeWithQuality = "",
		FunctionUtils = "",
		LocalizationUtils = "",
		TranslationService = "",
		FactorioDatabase = "",
		RecipeUtils = "",
		ElementUtils = "",

		CollisionMaskData = "data",
        DataRaw = "data",
        EntityData = "data",
        ItemData = "data",
		RecipeData = "data",
        PrototypeData = "data",
        SettingsData = "data",
        TechnologyData = "data",
        TechnologyIndex = "data",
		BigData = "data",
		RadarData = "data",
		SelectionTool = "data",
		StageBridge = "data",

        Inserter = "entities",
		Radar = "entities",

        Storage = "storage",
        StoragePlayer = "storage",
        StoragePlayers = "storage",
		PlayerStorage = "storage",

		PickerDollies = "mods",
		Factorissimo = "mods",
		SurfacesMod = "mods",
}

local KuxCoreLib_metatable = {}
function KuxCoreLib_metatable.__index(self, key)
	if KuxCoreLib.__modules[key] then return KuxCoreLib.__modules[key] end
	local rootpath = (KuxCoreLibPath or "__Kux-CoreLib__/").."lib/"
	if(require_map[key] and require_map[key] ~="") then rootpath = rootpath .. require_map[key] .."/" end
	local path = rootpath..key
	--print("KuxCoreLib require "..path)
	local result = require(path)
	assert(type(result)=="table", "require() returns not a table. "..path)
	return result
end
function KuxCoreLib_metatable.__newindex()
	error("KuxCoreLib is protected.")
end

setmetatable(KuxCoreLib.require,{
	__index = KuxCoreLib_metatable.__index,
	__newindex = function() error("KuxCoreLib.require is protected.") end
})

---Requires all modules as global
function KuxCoreLib.requireAll()
	if(KuxCoreLib.ModInfo.current_stage:match("^data") or KuxCoreLib.ModInfo.current_stage:match("^settings")) then
		require("__Kux-CoreLib__/lib/data/@")
	elseif(KuxCoreLib.ModInfo.current_stage=="control") then
		require("__Kux-CoreLib__/lib/@")
	end
	return KuxCoreLib
end

--TODO this is actually reduntant, because all modules can also be accessedby KuxCoreLib.<MODULENAME>
KuxCoreLib.Data = {}
setmetatable(KuxCoreLib.Data,{
	__index = function (self, key)
		local path = (KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/"..key
		return require(path)
	end,
	__newindex = function()
		error("KuxCoreLib.Data is protected.")
	end
})

KuxCoreLib.__isInitialized=true
setmetatable(KuxCoreLib,KuxCoreLib_metatable) -- protect KuxCoreLib
--log("Init KuxCoreLib, finished")

return KuxCoreLib
