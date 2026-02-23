require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

--- Log module
---@class KuxCoreLib.Log : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Log
local Log = {
	__class  = "Log",
	__guid   = "{93D539EB-D2F8-41C8-9BAB-44CFDFE67F00}",
	__origin = "Kux-CoreLib/lib/Log.lua"
}
if not KuxCoreLib.__classUtils.ctor(Log) then return self end
---------------------------------------------------------------------------------------------------

-- to avoid circular references, the class MUST be defined before require other modules
local Modules = KuxCoreLib.Modules
local Table= KuxCoreLib.Table

if log == nil then log = function (s) --[[dummy]] end end -- fallback if not running in Factorio

local getIsLogEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableLog"]
	if entry == nil then return false end
	return entry.value
end

local getIsConsoleEnabled = function ()
	local entry = settings.global[script.mod_name.."_EnableConsole"]
	if entry == nil then return false end
	return entry.value
end

local update = function (data)
	data.isLogEnabled     = getIsLogEnabled()
	data.isConsoleEnabled = getIsConsoleEnabled()
	data.isEnabled        = data.isLogEnabled and data.isConsoleEnabled
end

local data_prototype = {
	dataVersion      = 2,
	isLogEnabled     = false,
	isConsoleEnabled = false,
	isEnabled        = false,
}

--- deterministic data of Log module
local data = {}

function Log.on_init ()
	--log("Kux-Corelib.Log.on_init")
	storage.moduleData = storage.moduleData or {}
	data = Table.migrate(storage.moduleData.Log or {}, data_prototype)
	update(data)
	storage.moduleData.Log = data
end

function Log.on_load ()
	--log("Kux-Corelib.Log.on_load")
	if not storage.moduleData or not storage.moduleData.Log then
		data = Table.migrate({}, data_prototype)
		update(data)
	else
		data = storage.moduleData.Log
	end
end

function Log.on_configuration_changed()
	--log("Kux-Corelib.Log.on_configuration_changed")
	storage.moduleData = storage.moduleData or {}
	storage.moduleData.log = nil -- MIGRATION remove field uded by previous version
	data = Table.migrate(storage.moduleData.Log or {}, data_prototype)
	update(data)
	storage.moduleData.Log = data
end

function Log.onSettingsChanged()
	update(data)
end

function Log.on_runtime_mod_setting_changed()
	--log("Kux-Corelib.Log.on_runtime_mod_setting_changed")
	storage.moduleData = storage.moduleData or {}
	data = Table.migrate(storage.moduleData.Log or {}, data_prototype)
	update(data)
	storage.moduleData.Log = data
	Log.onSettingsChanged()
end

function Log.joinArgs(...)
	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
end

function Log.trace(...)
	if not data or not data.isEnabled then return end

	local msg = script.mod_name..": "
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
end

function Log.print(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
end

-- TODO use current player and not always player 1
-- userXyz outputs a message to the current user (and if enabled to console and log)

function Log.userTrace(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 0.7, g = 0.7, b = 0.7, a = 1})
end

function Log.userWarning(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 1, g = 1, b = 0, a = 1})
end

function Log.userError(...)
	if not data or not data.isEnabled then return end

	local msg = ""
	for i = 1, select("#",...) do
		local v = select(i,...)
		if v == nil then v = "{nil}"
		else v = tostring(v) end
		msg = msg .. v
	end
	if data.isConsoleEnabled then print(msg) end
	if data.isLogEnabled then log(msg) end
	game.get_player(1).print(msg, {r = 1, g = 0, b = 0, a = 1})
end

---Formats a parameter.
---@param s? any The value. (can be nil)
---@return string
function Log.P(s)
    if s == nil then return "" end
    if type(s)=="string" then return " \""..s.."\"" end
    return " "..tostring(s)
end

---Formats a parameter.
---@param name string
---@param s? any The value. (can be nil)
---@return string
function Log.NP(name,s)
    if s == nil then return "" end
    if type(s)=="string" then return " "..name..":\""..s.."\"" end
    return " "..name..":"..tostring(s)
end
---Formats a parameter.
---@param name string
---@param s? any The value. (can be nil)
---@return string
function Log.LNP(name,s)
    if s == nil then return "" end
    if type(s)=="string" then return "\n  "..name..":\""..s.."\"" end
    return "\n  "..name..":"..tostring(s)
end

---------------------------------------------------------------------------------------------------
return KuxCoreLib.__classUtils.finalize(Log)

-- if Log then
--     if Log.__guid == "{93D539EB-D2F8-41C8-9BAB-44CFDFE67F00}" then return Log end
-- 	-- for key, value in pairs(Log) do print("  "..key) end
--     -- error("A global Log class already exist.")
-- 	log("WARNING Mod incompatibility detected. Override existing 'Log'.")
-- end