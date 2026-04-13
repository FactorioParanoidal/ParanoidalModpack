--[[---------------------------------------------------------------------------
lib/init.lua
Is the main entry point for the library.
It initializes the library and provides access to all modules.

USAGE: require("__Kux-GuiLib__/lib/init")

_G.KuxGuiLib is a global variaböe that provides access to all modules.
---------------------------------------------------------------------------]]--
-- print(debug.getinfo(1,"S").source)
-- @D:\Develop\Factorio\Mods\Kux-GuiLib/src\lib\init.lua
-- @__Kux-GuiLib__/lib/init.lua
KuxGuiLibPath = KuxGuiLibPath or "__Kux-GuiLib__/"

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

if KuxGuiLib then
    if KuxGuiLib.__guid == "1011a47e-00b3-4c4a-878d-fa2e27bb79b1" then
		--log("Init KuxGuiLib, repeated, initialized:"..tostring(KuxGuiLib.__isInitialized)..", required by \n"..debug.traceback(2))
		--require(KuxGuiLibPath.."modules/require-override")
		return KuxGuiLib
	end
    error("A global class 'KuxGuiLib' already exist.")
else
	--log("Init KuxGuiLib, first time, required by \n"..debug.traceback(2))
end

---Kux-GuiLib specific 'storage' specifications
---@class KuxGuiLib.storage The global storage table
---@field ["Kux-GuiLib"] KuxGuiLib.storage Library root in storage
_G.storage = _G.storage

---Library root in storage
---@class KuxGuiLib.storage
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field PlayerContext KuxGuiLib.storage.PlayerContext PlayerContext root in storage


---PlayerContext root in storage
---@class KuxGuiLib.storage.PlayerContext
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field players KuxGuiLib.PlayerContext[]


---@class KuxGuiLib.__modules
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field Gui KuxGuiLib.Gui
---@field ContextMenu KuxGuiLib.ContextMenu
---@field PlayerContext KuxGuiLib.PlayerContext.static
---@field GuiEventDistributor KuxGuiLib.GuiEventDistributor
---@field ClipboardDialog KuxGuiLib.ClipboardDialog
---@field ErrorDialog KuxGuiLib.ErrorDialog
---@field MessageDialog KuxGuiLib.MessageDialog
---@field ElementSelectorView KuxGuiLib.ElementSelectorView
---@field ElementSelectorOptionsView KuxGuiLib.ElementSelectorOptionsView
---@field GuiElemenRef KuxGuiLib.GuiElementRef.static
---@field GuiView KuxGuiLib.GuiView.static
---@field VGuiElement KuxGuiLib.VGuiElement.static
---@field GuiHelper KuxGuiLib.GuiHelper
---@field GuiElementCache KuxGuiLib.GuiElementCache
---@field GuiElementCache2 KuxGuiLib.GuiElementCache2
---@field GuiBuilder KuxGuiLib.GuiBuilder
---@field Designer KuxGuiLib.Designer.static


---Provides access to Kux-GuiLib modules<br>
---Usage: `local moduleName = KuxGuiLib.require.MODULENAME`<br>
---The local use is suggested to avoid conflicts with other libraries,
---but you can also use the global access. (use `KuxGuiLib.require.MODULENAME.asGlobal()`)
---to force a class to be global, and override existing classes. (use with caution)
---@class KuxGuiLib : KuxGuiLib.__modules, KuxGuiLib.Class
---       ‾‾‾‾‾‾‾‾‾‾
---@field __guid string
---@field __modules KuxGuiLib.__modules
---@field requireAll function
---@field __version string
---@field require KuxGuiLib.__modules
---@field style string[]
---@field font string[]
---@field Storage KuxGuiLib.Storage


---@type KuxGuiLib
---@diagnostic disable-next-line: missing-fields
KuxGuiLib = {
	__class  = "KuxGuiLib",
	__guid   = "1011a47e-00b3-4c4a-878d-fa2e27bb79b1",
	__origin = "Kux-GuiLib/lib/init.lua",

	__modules = {},--[[@diagnostic disable-line: missing-fields]]
	__version = (mods or script.active_mods)["Kux-GuiLib"],

	require = {},--[[@diagnostic disable-line: missing-fields]]
}

---------------------------------------------------------------------------------------------------
--NOTE: We must not 'require' lib modules! circular reference!
-- e.g. local Debug = require(KuxGuiLibPath.."lib/Debug") is not allowed

KuxGuiLib.Storage = require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/GuiLibStorage")
_=KuxGuiLib.require.PlayerContext

---@class KuxGuiLib.Styles
KuxGuiLib.style = {
	dark_code_textbox = "Kux-GuiLib-dark-code-textbox"
}

KuxGuiLib.font = {
	NotoMono10 = "NotoMono-10",
	NotoMono11 = "NotoMono-11",
	NotoMono12 = "NotoMono-12",
	NotoMono14 = "NotoMono-14",
	NotoMono16 = "NotoMono-16",
	NotoMono18 = "NotoMono-18",
	NotoMono20 = "NotoMono-20",
}

local require_map = { --TODO: implement> RUN (F5) to AUTOGENERATE
	Gui ="",
	GuiEventDistributor ="",
    ContextMenu = "",
	PlayerContext = "",
	ClipboardDialog = "",
	ErrorDialog = "",
	ElementSelectorView = "",
	ElementSelectorOptionsView ="",

	GuiBuilder = "",
	ElementBuilder = "",
	GuiHelper = "",
	GuiElementCache = "",
	GuiElementCache2 = "",
	GuiElemenRef = "",
	GuiView = "",
	VGuiElement = "",
	Designer = ""
}

local KuxGuiLib_metatable = {}
function KuxGuiLib_metatable.__index(self, key)
	if KuxGuiLib.__modules[key] then return KuxGuiLib.__modules[key] end
	local rootpath = (KuxGuiLibPath or "__Kux-GuiLib__/").."lib/"
	if(require_map[key] and require_map[key] ~="") then rootpath = rootpath .. require_map[key] .."/" end
	local path = rootpath..key
	--print("KuxGuiLib require "..path)
	local result = require(path)
	assert(type(result)=="table", "require() returns not a table. "..path)
	return result
end
function KuxGuiLib_metatable.__newindex()
	error("KuxGuiLib is protected.")
end

setmetatable(KuxGuiLib.require,{
	__index = KuxGuiLib_metatable.__index,
	__newindex = function() error("KuxGuiLib.require is protected.") end
})


KuxGuiLib.__isInitialized=true
setmetatable(KuxGuiLib,KuxGuiLib_metatable) -- protect KuxGuiLib
--log("Init KuxGuiLib, finished")
-----------------------------------------------------------------------------------------------------------------------
return KuxGuiLib

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
---@class KuxGuiLib.Class : KuxCoreLib.Class
