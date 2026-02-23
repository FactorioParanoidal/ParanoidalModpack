--[[---------------------------------------------------------------------------
	ModInfo
	Provides information about the current mod.

	USAGE:
	create a mod.lua file in your mod root folder with the following content:

	--[[mod.lua]]-----------------------------------------------------------]
	--	KuxCoreLib = require("__Kux-CoreLib__/lib/init") --[[@as KuxCoreLib]]
	--	_G.mod = KuxCoreLib.ModInfo.extend({separator = "-"})
	--  ...
	--[[--------------------------------------------------------------------]

	Then you can use your `mod` in all stages.

	--[[settings.lua]]------------------------------------------------------]
	--  require("mod")
	--  ...
	--[[--------------------------------------------------------------------]
-----------------------------------------------------------------------------]]

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

if(KuxCoreLib.__modules.ModInfo) then
	if(KuxCoreLib.__modules.ModInfo.__isInitialized) then
		KuxCoreLib.__modules.ModInfo.update()
	end
	return KuxCoreLib.__modules.ModInfo
end

-- local isOverriding
-- if ModInfo then
--     if ModInfo.__guid == "35fb3f52-acde-45b9-9792-d1c0f570408b" then return ModInfo end
-- 	-- for key, value in pairs(Log) do print("  "..key) end
--     -- error("A global Log class already exist.")
-- 	log("WARNING Mod incompatibility detected. Override existing 'ModInfo'.")
-- end

-- if(isOverriding) then
-- 	ModInfo.__isOverridden = true
-- 	ModInfo.__extensions=ModInfo.__extensions or {}
-- 	table.insert(ModInfo.__extensions, {
-- 		name  = "Kux-CoreLib",
-- 		guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
-- 		origin = "Kux-CoreLib/lib/ModInfo.lua",
-- 		order = #ModInfo.__extensions + 1
-- 	})
-- else
-- 	ModInfo = {
-- 		__class  = "ModInfo",
-- 		__guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
-- 		__origin = "Kux-CoreLib/lib/ModInfo.lua"
-- 	}
-- end

---@class ModInfoOptions
---@field separator string The separator for the prefix. default: "_"

---@class KuxCoreLib.ModInfo
local ModInfo = {
	__class  = "ModInfo",
	__guid   = "35fb3f52-acde-45b9-9792-d1c0f570408b",
	__origin = "Kux-CoreLib/lib/ModInfo.lua",

	__isInitialized = false,
	__on_initialized = {},
}
KuxCoreLib.__modules.ModInfo = ModInfo
---------------------------------------------------------------------------------------------------
local debug_util =  require((KuxCoreLibPath or "__Kux-CoreLib__/").."modules/debug_util") --[[@KuxCoreLib.debug_util]]

---Gets the entry mod
---@type string
ModInfo.entryMod = debug_util.getEntryMod()

---Gets the calling mod
---@type string
ModInfo.callingMod = debug_util.getCallingMod(true)

---Gets the current stage
---@type "settings"|"settings-updates"|"settings-final-fixes"|"data"|"data-updates"|"data-final-fixes"|"control"|"control-on-init"|"control-on-load"|"control-on-configuration-changed"|"control-on-loaded"|"undefined"
---
---Sequence: settings > settings-updates > settings-final-fixes > data > data-updates > data-final-fixes > control > control-on-init > control-on-load > control-on-configuration-changed > control-on-loaded
ModInfo.current_stage = "undefined" -- mostly used with match, so nil would be not helpfull

---Gets the current mod name
---@type string
---example `ModName`
ModInfo.name = nil

---Gets the current mod version
---@type string
---example `1.2.3`
ModInfo.version = nil

---Gets the current mod name as path
---@type string
---example `__ModName__/`
ModInfo.path = nil

---Gets the current separator. default: "_"
---@type string
---example `_`
ModInfo.separator = "_"

---Gets the current mod name as prefix
---@type string
---example `ModName_`
ModInfo.prefix = nil

---getEntryStage
---@return "settings"|"settings-updates"|"settings-final-fixes"|"data"|"data-updates"|"data-final-fixes"|"control"
ModInfo.getEntryStage = debug_util.getEntryStage

---Update `current_stage` and `name`
function ModInfo.update()
	if(ModInfo.current_stage~="undefined" and ModInfo.current_stage:match("^control") and ModInfo.name) then return end
	local stackTrace = debug.traceback()
	local stage = "undefined"
	local mod_name = nil
	for line in stackTrace:gmatch("[^\r\n]+") do
		local m, f = line:match("__([^/]+)__/([^%.]+)%.lua")
		if m and f then stage = f; mod_name = m end
	end
	if(not ModInfo.current_stage or not ModInfo.current_stage:match("^control")) then
		ModInfo.current_stage = stage
	end

	if(mod_name) then
		ModInfo.name = mod_name
		ModInfo.path = "__"..mod_name.."__/"
		--ModInfo.prefix = ModInfo.name..ModInfo.separator
		ModInfo.version = script and script.active_mods[mod_name] or mods[mod_name]
	end

	--log("ModInfo.update(): stage="..ModInfo.current_stage.." mod="..ModInfo.name.." "..ModInfo.version)
end

function ModInfo:protect()
	local mt = getmetatable(self)
	mt.__newindex = function() error("ModInfo is protected.") end
	mt.__metatable = "ModInfo is protected"
end

---------------------------------------------------------------------------------------------------

---Provides ModInfo in the global namespace
---@return KuxCoreLib.ModInfo
function ModInfo.asGlobal() KuxCoreLib.__classUtils.asGlobal(ModInfo) return ModInfo end

ModInfo.update()

ModInfo.__isInitialized = true
for _, fnc in ipairs(ModInfo.__on_initialized) do fnc() end

if(ModInfo.current_stage=="control") then
	_=KuxCoreLib.EventDistributor -- this is reqired for update control states
end

---Initializes a new mod (due updating ModInfo)
---@param additionalMembers {key:string, value:any} [optional] additional members
---@return KuxCoreLib.ModInfo
---@overload fun(): KuxCoreLib.ModInfo
---@overload fun(additionalMembers: {key:string, value:any}): KuxCoreLib.ModInfo
function ModInfo.new(additionalMembers)
	--log("ModInfo.new()")
	local instance = {}
	if additionalMembers then for key, value in pairs(additionalMembers) do instance[key] = value end end
	local mod = setmetatable(instance, {
		__index = ModInfo,
		--__newindex = function() error("ModInfo is protected.") end,
		--__metatable = "ModInfo is protected"
	})
	ModInfo.update()
	ModInfo.prefix = mod.name..mod.separator
	--log("ModInfo.new() done: prefix="..ModInfo.prefix)
	return mod
end
-----------------------------------------------------------------------------------------------------------------------
return ModInfo