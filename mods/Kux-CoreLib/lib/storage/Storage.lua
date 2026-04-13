require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides managed access to the Factorio's persistent 'storage' table (formerly `global`) .
---@class KuxCoreLib.Storage : KuxCoreLib.Class
---@field players KuxCoreLib.StoragePlayers
---@field events nil reserved
---
---Because the name 'global' is ambiguous, we use 'storage' instead
---Introduced as 'Global' in 2.7.0, renamed to STorage in 2.7.1
---Factorio 2.0 has renamed the 'global' table to 'storage' so we have some conflicts to resolve
local Storage = {
	__class  = "Storage",
	__guid   = "431a60fa-6289-4f1e-b0f8-9047cf33b2d0",
	__origin = "Kux-CoreLib/lib/storage/Storage.lua",
	raw = {}
}
if not KuxCoreLib.__classUtils.ctor(Storage) then return self end
---------------------------------------------------------------------------------------------------

local Events = KuxCoreLib.Events

---Gets a value indicating wether the Storage (resp. the `global` variable) can be read.
---@type boolean
---
---`storage` (formerly `global`) can be read in or after 'on_init' and 'on_load'
Storage.canRead = false

---Gets a value indicating wether the Storage (resp. the `global` variable) can be changed.
---@type boolean
---
---`storage` (formerly `global`) can be changed in or after 'on_init' or after 'on_load'
Storage.canWrite = false

local mt = {}

---
---@param self table
---@param key string
---@return any
function mt.__index(self,key)
	if(key:match("^__")) then return nil end
	return storage[key]
end

function mt.__newindex(self,key,value)
	if(key:match("^__")) then rawset(self,key,value) end
	storage[key] = value
end

Storage.__self = Storage.__self or {}
Storage.__self.path_registrations = Storage.__self.path_registrations or {}

--- Registers a path for the owner.
---@param path string The path to register. like `storage.yourdata`
---@param owner string? The owner of the path. like `YouMod.PlayerStorage`.
---
---If the path is already registered for diffent owner, an error is thrown.<br>
---The owner is optional and defaults to "unknown". But if specified, it helps to find the other owner.
---The path `storage.___KuxCoreLib___` is reserved for the KuxCoreLib.
---Names startinng with `__` are reserved for internal use and are not stored in `storage`.
function Storage.register(path, owner)
	local registrations = Storage.__self.path_registrations
	if not registrations[path] then registrations[path] = owner or "unknown" return end
	if registrations[path] == owner then return end
	error("Path already registered. Path:'"..path.."' Owner:'"..registrations[path].."'")
end

Storage.register("storage.__KuxCoreLib__", "KuxCoreLib.Storage")

function Storage.check()
	local me = {}
	function me.func()
		me.scan(storage, "storage")
	end

	function me.scan(tbl, path)
		for key, value in pairs(tbl) do
			if type(key) == "function" then error("Function key found at path: " .. path) end
			local current_path = path .. "." .. tostring(key)

			if type(value) == "function" then
				error("Function found at path: " .. current_path)
			elseif type(value) == "table" then
				me.scan(value, current_path)
			end
		end
	end

	me.func()
end

local function register_events()
	Events.on_load(function()
		Storage.raw = storage or error("storage is not available")
	end)

	local function init_storage(e)
		if not storage.__KuxCoreLib__ then storage.__KuxCoreLib__ = {} end
		Storage.raw = storage or error("storage is not available")
	end

	Events.on_init(init_storage)
	Events.on_configuration_changed(init_storage)
	Events.on_loaded(init_storage)-- only for development
end

function Storage.set(...)
	local args = table.pack(...)
	if args.n < 2 then error("Argument count mismatch. set requires at least a name and a value") end

	local value = args[args.n]
	local path = {}

	for i = 1, args.n - 1 do
		local arg = args[i]
		if type(arg) == "table" then
			for _, seg in ipairs(arg) do
				for part in tostring(seg):gmatch("[^%./]+") do
					table.insert(path, part)
				end
			end
		else
			for part in tostring(arg):gmatch("[^%./]+") do
				table.insert(path, part)
			end
		end
	end

	local t = storage or error("storage is not available")
	for i = 1, #path - 1 do
		local key = path[i]
		if t[key] == nil then
			t[key] = {}
		elseif type(t[key]) ~= "table" then
			error("Path conflict at '" .. key .. "'")
		end
		t = t[key]
	end

	t[path[#path]] = value
end

---Get value from storage
---@param ... (string|table) Path segments (strings with optional "/" or arrays of segments)
---@return any
function Storage.get(...)
	local raw = { ... }
	local path = {}

	local function split(raw)
		for _, segment in ipairs(raw) do
			if type(segment) == "table" then
				split(segment)
			else
				for part in tostring(segment):gmatch("[^%./]+") do
					path[#path+1] = part
				end
			end
		end
	end
	split(raw)

	local t = storage or error("storage is not available")
	for _, p in ipairs(path) do
		t = t[p]
		if t == nil then return nil end
	end

	return t
end

---Get boolean value
---@param ... (string) Path segments
---@return boolean?
function Storage.getBool(...) return Storage.get(...) --[[@as boolean?]] end

---Get numeric value
---@param ... (string) Path segments
---@return number?
function Storage.getNumber(...) return Storage.get(...) --[[@as number?]] end

---Get string value
---@param ... (string) Path segments
---@return string?
function Storage.getString(...) return Storage.get(...) --[[@as string?]] end

---Get table value
---@param ... (string) Path segments
---@return table?
function Storage.getTable(...) return Storage.get(...) --[[@as table?]] end


-- Storage get/set Test
if script.active_mods["debugadapter"] then
	local restore = storage
	storage = {}

	Storage.set("test.path", "value", 123)
	assert(storage.test.path.value == 123,  "Storage.set: expected 123 at test.path.value")
	assert(Storage.get("test.path", "value") == 123,  "Storage.get: expected 123 at test.path.value")

	Storage.set("test", "flag", true)
	assert(storage.test.flag == true,       "Storage.get: expected true at test.flag")
	assert(Storage.get("test","flag") == true,       "Storage.get: expected true at test.flag")

	Storage.set("test/flag2", true)
	assert(storage.test.flag2 == true,       "Storage.get: expected true at test.flag")
	assert(Storage.get("test/flag2") == true,       "Storage.get: expected true at test.flag")

	Storage.set({"test.nested"}, "inner", "hello")
	assert(storage.test.nested.inner == "hello", "Storage.get: expected 'hello' at test.nested.inner")
	assert(Storage.get({"test.nested"},"inner") == "hello", "Storage.get: expected 'hello' at test.nested.inner")

	log("[Storage] get/set test: OK")
	storage = restore
end

KuxCoreLib.Events.__on_initialized(register_events)

---------------------------------------------------------------------------------------------------
setmetatable(Storage,mt)
KuxCoreLib.__classUtils.finalize(Storage)
return Storage

--[[ v??
In der global-Tabelle von Factorio können Sie eine Vielzahl von Daten speichern, darunter:

Numerische Werte wie Zahlen und Boolesche Werte
Tabellen und Arrays
Funktionen (die vorher definiert wurden oder als Closures erstellt wurden)
Zeichenketten (Strings)
Benutzerdefinierte Datenstrukturen
Es gibt jedoch einige Einschränkungen bei der Verwendung der global-Tabelle:

Metatables und userdata (einschließlich Funktionen, die als Metamethoden verwendet werden) können nicht in der global-Tabelle gespeichert werden.
]]

--[[ 2.0
Nur bestimmte Daten können im Speicher abgelegt werden:

- Grunddaten: Null, Zeichenketten, Zahlen, Boolesche Werte.
- Tabellen, mit begrenzten Metatabellen:
  - Die Metatabelle selbst wird nicht gespeichert.
  - Metatabellen, die mit LuaBootstrap::register_metatable registriert sind, werden mit ihrem Namen gespeichert und beim Laden automatisch mit der registrierten Tabelle verknüpft.
  - Alle anderen Metatables werden entfernt; Tabellen mit nicht registrierten Metatables werden beim Speichern und Laden zu einfachen Tabellen.
- Verweise auf Factorio's LuaObjects.
Funktionen sind im Speicher nicht erlaubt und werden beim Speichern einen Fehler auslösen.
]]