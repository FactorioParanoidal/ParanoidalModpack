require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---DRAFT Provides Dictionary functions
---@class KuxCoreLib.Dictionary : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Dictionary
local Dictionary = {
	__class  = "Dictionary",
	__guid   = "{114989BE-8900-4ABF-91F4-BC5D19537396}",
	__origin = "Kux-CoreLib/lib/Dictionary.lua",
}
if not KuxCoreLib.__classUtils.ctor(Dictionary) then return self end
---------------------------------------------------------------------------------------------------
-- to avoid circular references, the class is defined before require other modules
local Table = KuxCoreLib.Table
local Assert = KuxCoreLib.That
local String = KuxCoreLib.String
local PRIVATE = "71d7bad4-21c1-4148-a979-506c3b02bd9e"

---@class KuxCoreLib.Dictionary.factory
local factory = {}

local private_cache = {} ---@type table<{}, KuxCoreLib.Dictionary.Instance.internal_data>

---Gets the private data of the dictionary
---@param t {}
---@return KuxCoreLib.Dictionary.Instance.internal_data
function get_private(t)
	local private = private_cache[t]
	if not private then
		private = rawget(t, PRIVATE)
		if not private then
			private = {---@type KuxCoreLib.Dictionary.Instance.internal_data
				keys = {}
			}
			rawset(t, PRIVATE, private)
		end
		private_cache[t] = private
	end
	return private
end

-----------------------------------------------------------------------------------------------------------------------
---#region: instance implementation
-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.Dictionary.Instance
local impl = {
	__class = "KuxCoreLib.Dictionary.Instance",
	__guid  = "71d7bad4-21c1-4148-a979-506c3b02bd9e"
}

function impl:add(key, value)
	self[key]=value
	get_private(self).keys[key] = true
end

function impl:remove(key)
	self[key]=nil
	get_private(self).keys[key] = nil
end

function impl:removeValue(value)
	for key, val in pairs(self) do
		if val == value then
			self[key]=nil
			return
		end
	end
end

function impl:clear()
	for key, value in impl.getKeys(self) do
		self[key]=nil
	end
end

function impl:getKeys()
	local keys = {}
	for key, _ in pairs(get_private(self).keys) do table.insert(keys, key) end
	return keys
end

function impl:count()
	local count = 0
	for _ in pairs(get_private(self).keys) do count = count + 1 end
	return count
	--TODO make it faster
end

---Gets a raw table with a copy of the entries (no metatable, no extra fields)
---<p>Use this e.g. in layers dictionary where extra fields are not passible.</p>
---@return {}
function impl:raw()
	local raw = {}
	for key, value in pairs(self) do raw[key] = value end
	return raw
end

---Converts the Dictionary into a raw table (in-place)
function impl:make_raw()
	setmetatable(self, nil)
	self[PRIVATE] = nil
end

-----------------------------------------------------------------------------------------------------------------------
---#region: metatable implementation
-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.Dictionary.Metatable
local mt = {
	__class = "KuxCoreLib.Dictionary.Metatable"
}

function mt.__index(t, k)
	if impl[k] then return impl[k] end
	return nil
end

function mt.__newindex(t, k, v)
	if impl[k] then error(string.format("Class member '%s' is protected", k)) end
	rawset(t, k, v)
	get_private(t).keys[k] = true
end

function mt.__pairs(t)
	local function iter(tbl, k)
		local nextK, nextV = next(tbl, k)
		if nextK == PRIVATE then return iter(tbl, nextK) end
		return nextK, nextV
	end
	return iter, t, nil
end

if KuxCoreLib.ModInfo.current_stage == "control" then
	script.register_metatable("KuxCoreLib.Dictionary.Metatable", mt)
end

-----------------------------------------------------------------------------------------------------------------------
---#region: static implementation
-----------------------------------------------------------------------------------------------------------------------

---Convert a table to a Dictionary (inplace)
---@param t {}
---@return KuxCoreLib.Dictionary
function Dictionary.setmetatable(t)
	assert(type(t) == "table", "Invalid argumen 't'. Expect table but got "..type(t))
	local keys = {}
	for k, v in pairs(t) do keys[k]=true end
	setmetatable(t, mt)
	get_private(t).keys = keys
	return t --[[@as KuxCoreLib.Dictionary]]
end

---Creates a new dictionary
---@param t {}|nil
---@return KuxCoreLib.Dictionary
function Dictionary.new(t)
	local n = setmetatable({}, mt) ---@type KuxCoreLib.Dictionary
	for k, v in pairs(t or {}) do n[k] = v end
	return n
end


factory.mt_dic_any2 = {
	__index = function(t, k)
		local v = {}
		t[k] = v
		return v
	end
}
if script then script.register_metatable("KuxCoreLib-018846cd-6863-4fb0-8f88-0415b2b114e4", factory.mt_dic_any2) end

factory.mt_dic_player_any = {
	__index = function(t, k)
		local playerIndex
		if type(k) == "number" then playerIndex = k
		elseif type(k) == "string" then playerIndex = game.players[k].index
		else playerIndex = k.index end

		local v = {}
		t[playerIndex] = v
		return v
	end
}
if script then script.register_metatable("KuxCoreLib-cdcca1f2-60a1-4355-b04d-70871bedf230", factory.mt_dic_player_any) end

factory.mt_dic_player_string_any = {
	__index = function(t, k)
		local playerIndex
		if type(k) == "number" then playerIndex = k
		elseif type(k) == "string" then playerIndex = game.players[k].index
		else playerIndex = k.index end

		local v = setmetatable({}, factory.mt_dic_any2)
		t[playerIndex] = v
		return v
	end
}
if script then script.register_metatable("KuxCoreLib-8caa792c-ade1-4c5c-9bf0-6a274d0bef78", factory.mt_dic_player_string_any) end


factory.mt_dic_any3 = {
	__index = function(t, k)
		local v = setmetatable({}, factory.mt_dic_any2)
		t[k] = v
		return v
	end
}
if script then script.register_metatable("KuxCoreLib-cba2c2c8-65db-416e-8434-8a2bb1782f25", factory.mt_dic_any3) end

factory.mt_dic_any4 = {
	__index = function(t, k)
		local v = setmetatable({}, factory.mt_dic_any3)
		t[k] = v
		return v
	end
}
if script then script.register_metatable("KuxCoreLib-bd38d6c9-0582-4752-802b-6b4b6e8112c1", factory.mt_dic_any4) end

function Dictionary.create_byString()
	local t = {}
	setmetatable(t, factory.mt_dic_any2)
	return t
end

function Dictionary.create_byPlayer()
	local t = {}
	setmetatable(t, factory.mt_dic_player_any)
	return t
end

function Dictionary.create_byPlayerAndString()
	local t = {}
	setmetatable(t, factory.mt_dic_player_string_any)
	return t
end

function Dictionary.create_byStringAndString()
	local t = {}
	setmetatable(t, factory.mt_dic_any3)
	return t
end
-----------------------------------------------------------------------------------------------------------------------

function Dictionary.removeValue(t, value) impl.removeValue(t, value) end

function Dictionary.clear(t) impl.clear(t) end

function Dictionary.count(t) return impl.count(t) end

function Dictionary.getKeys(t)
	local keys = {}
	for k, _ in pairs(t) do table.insert(keys,k) end
	return keys
end

---Gets the first key of the dictionary
---@param t table
---@return any
function Dictionary.firstKey(t)
	for key, _ in pairs(t) do return key end
end

---Gets the first value of the dictionary
---@param t table
---@return any
function Dictionary.firstValue(t)
	for _, value in pairs(t) do return value end
end
-----------------------------------------------------------------------------------------------------------------------
return Dictionary

-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.Dictionary.Instance.internal_data
---       ---------------------------------------------
---@field keys {string:true}  The names of the entries