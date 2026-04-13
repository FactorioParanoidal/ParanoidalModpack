--[[-----------------------------------------------------------------------------------------------
NOTE: require only in src/lib/init.lua (CoreLib)
--]]-----------------------------------------------------------------------------------------------

---@class KuxCoreLib.__classUtils
local __classUtils = {}
KuxCoreLib.__classUtils = __classUtils
---------------------------------------------------------------------------------------------------
---@class KuxCoreLib.__classUtils.Table
local Table = { -- we can not load lib/Table here, because it needs __classUtils
	contains = function(t, v)
		for _, v1 in ipairs(t) do if v1 == v then return true end end
		return false
	end
}
---------------------------------------------------------------------------------------------------

local function isReadable(obj, member)
	if Table.contains(rawget(obj, "__writableMembers") or {}, member) then return true end
	if Table.contains(rawget(obj, "__optionalMembers") or {}, member) then return true end
	return false
end
__classUtils.isReadable = isReadable

local function isWritable(obj, member)
	if Table.contains(rawget(obj, "__writableMembers") or {}, member) then return true end
	return false
end
__classUtils.isWritable = isWritable

local function isOptional(obj, member)
	if Table.contains(rawget(obj, "__optionalMembers") or {}, member) then return true end
	return false
end
__classUtils.isOptional = isOptional

---Makes a local class global. With verification.
---@param t table The class to make public
---@return KuxCoreLib.Class
---@overload fun(t:table):KuxCoreLib.Class
function __classUtils.asGlobal(t)
	local function getClassFileName(class)
		--local classTable = getmetatable(class)

		for key, value in pairs(class) do
		  if type(value) == "function" then
			local info = debug.getinfo(value, "S")
			if info.source and info.source ~= "=[C]" then
			  return info.source:gsub("@", "")
			end
		  end
		end
		return nil
	end

	local name = t.__class
	--mode = mode or "error"

	if(not name) then error("Invalid class specified! missing '__class'") end
	if(not t.__guid) then error("Invalid class specified! missing '__guid'") end
	local gt = _G[name]
	if gt then
		if gt.__guid == t.__guid then return gt end
		--[[
		local lines = {}
		for n, v in pairs(gt) do
			    if(type(v)=="function") then table.insert(lines,"  "..n.." ("..type(v).." @ "..getClassFileName(gt) or "?"..")")
			elseif(type(v)=="table"   ) then table.insert(lines,"  "..n.." ("..type(v)..")")
			elseif(type(v)=="string"  ) then table.insert(lines,"  "..n.." = \""..v.."\"")
			else table.insert(lines,"  "..n.." = "..tostring(v).."")
			end
		end
		log("A global class '"..name.."' already exists! dump: \n{\n"..table.concat(lines,"\n").."\n}\nResolving mode: "..mode)
		]]
	end
	_G[name] = t
	t.__isGlobal = true;
	if t.__setGlobals then t.__setGlobals() end
	return t
end


local mt__on_initialized = {
	__call = function(t, fnc)
		if t.parent.__isInitialized then fnc()
		else table.insert(t, fnc) end
	end
}

local mt_table_add = {
	__call = function(t, v)
		if type(v) == "table" then
			for _, v1 in ipairs(v) do table.insert(t, v1) end
		else
			table.insert(t, v)
		end
	end
}

local function inject_ctor(obj)
	obj.__writableMembers = setmetatable(obj.__writableMembers or {}, mt_table_add)
	obj.__optionalMembers = setmetatable(obj.__optionalMembers or {}, mt_table_add)
	obj.__writableMembers{"__isInitialized", "__isGlobal"}
	obj.__optionalMembers{"__setGlobals"}
	obj.__isInitialized = false
	obj.__on_initialized = setmetatable({parent=obj}, mt__on_initialized)
	obj.asGlobal = function() return __classUtils.asGlobal(obj) end
	obj.__isGlobal = false
end

-- Usage: <br>
-- local myClass = {__class="myClass"} -- or -- <br>
-- local myClass = {__module="myClass", __class="prefix.myClass.suffix"} <br>
-- if not KuxCoreLib.__classUtils.ctor(myClass) then return self end -- or -- <br>
-- if not KuxCoreLib.__classUtils.ctor(myClass, OtheLib) then return self end <br>
-- ...<class initializer>
function __classUtils.ctor(obj, lib)
	if not obj then error("Argument 'obj' must not be nil!") end
	lib = lib or KuxCoreLib
	local module_name = obj.__module -- or normalize "KuxCoreLib.Foo" → "Foo"
		or obj.__class:match("([^.]+)%.static$")
		or obj.__class:match("([^.]+)$")
		or obj.__class
	local m = lib.__modules[module_name] -- uses KuxCoreLib.__modules
	if m then
		if obj.__guid ~= m.__guid then error("Duplicate module name! " ..obj.__origin.." existing: "..m.__origin) end
		--error("Duplicate constructor call for class '"..tostring(obj.__class).."'\n" .."origin: "..tostring(obj.__origin))

		-- to use with: if not KuxCoreLib.__classUtils.ctor(Foo) then return self end
		_G.self = m; return false
	end
	inject_ctor(obj)
	lib.__modules[module_name] = obj
	return true
end


local function protect(obj)
	local mt = getmetatable(obj); if mt then return end

	setmetatable(obj,{
		__index = function(self, key)
			if isReadable(self, key) then return nil end
			--print(obj.__writableMembers[1])
			--print(obj.__optionalMembers[1])
			error("Member not exists. "..obj.__class .."."..key)
			end,
		__newindex = function(self, key, value)
			if isWritable(self, key) then rawset(self, key, value)
			else error(obj.__class .." is protected: " .. key) end
		end,
		__metatable = obj.__class .." is protected."
	})
	return obj
end

---Finalizes the class initialization
---@param obj KuxCoreLib.Class
---@return KuxCoreLib.Class
function __classUtils.finalize(obj)
	if not obj then error("Argument 'obj' must not be nil!") end
	obj.__isInitialized = true
	protect(obj)
	if obj.__setGlobals then obj.__setGlobals() end
	for _, fnc in ipairs(obj.__on_initialized--[[@as table]] or {} ) do fnc() end
	return obj
end

---------------------------------------------------------------------------------------------------
