require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.FunctionUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.FunctionUtils
local FunctionUtils = {
	__class  = "KuxCoreLib.FunctionUtils",
	__guid   = "{e622bb71-6b8c-40eb-b043-d945a24f653e}",
	__origin = "Kux-CoreLib/lib/FunctionUtils.lua",
}
if not KuxCoreLib.__classUtils.ctor(FunctionUtils) then return self end
-----------------------------------------------------------------------------------------------------------------------

---@class KuxCoreLib.FunctionUtils.private
local this = {}

-- to avoid circular references, the requires must defined after class registration
local Table= KuxCoreLib.Table
local Assert= KuxCoreLib.That
local String = KuxCoreLib.String

local idx_name_obj = {} ---@type table<string, table>
local idx_obj_name = {} ---@type table<table, string>
local idx_func_info = {} ---@type table<function, {name:string, full_name:string, id:string}>
local idx_full_name_func = {} ---@type table<string, function>
local idx_fid_func = {} ---@type table<string, function>

function normalize_guid(guid)
	return guid:lower():gsub("[^a-f0-9]", "") --TODO improve
end

--[ private ]----------------------------------------------------------------------------------------------------------

---@param func function
---@return string? #The guid or nil
function this.getFunctionsId(func)
    local serialized = serpent.line(func)
	local pattern = "(fid{%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x})"-- suggested format
	-- example: local _ = "fid{603ccfc4-9ee7-404f-b407-9157bdaf9eb4}"
    local guid = serialized:match(pattern)

	if not guid then -- fallback (deprecated)
		pattern = "({?%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x}?)"
		guid = serialized:match(pattern)
	end
	if not guid then return nil end

	guid = normalize_guid(guid)
	--local info = debug.getinfo(func, "S")
	--local filename = info.source:match("@(.+)$"):match("[^\\/]+%.lua$")
    return guid
end


function this.scanClass(obj, class_name)
	local debugInfo = nil
	local count = 0
	for funcName,func in pairs(obj) do
		if type(func) =="function" then
			if not debugInfo then debugInfo = debug.getinfo(func) end
			local fid = this.getFunctionsId(func)
			if(fid) then count = count +1 end
			local info = {
				id = fid,
				name = funcName,
				full_name = class_name.."."..funcName,
			}
			idx_func_info[func] = info
			idx_full_name_func[info.full_name] = func
			if(fid) then idx_fid_func[fid] = func end
		end
	end
	--[[
	if count == 0 and debugInfo ~= nil then
		print("No function in class has a id.\n"..
		    "  name: \""..tostring(obj.name).."\"\n" ..
			"  __class: \""..tostring(obj.__class).."\"\n" ..
			"  file: "..debugInfo.short_src.." near line "..debugInfo.linedefined
		)
	end
	]]
end

---@deprecated not fully tested
function this.unscanClass(obj, class_name)
	for funcName, func in pairs(obj) do
		if type(func) == "function" then
			local full_name = class_name.."."..funcName
			local fid = this.getFunctionsId(func)
			idx_func_info[func] = nil
			idx_full_name_func[full_name] = nil
			if fid then idx_fid_func[fid] = nil end
		end
	end
end

--[ static ]----------------------------------------------------------------------------------------------------------

---
---@param obj table
---@param name string?
function FunctionUtils.registerClass(obj, name)
	assert(obj~=nil, "Argument 'obj' must not be nil.")
	name = name or obj.__class or  error("Class name is nil and no 'name' argument specified.")
	if idx_name_obj[name] then error("Class name already registered: "..name) end
	if idx_obj_name[obj] then error("Class instance already registered: "..name) end
	idx_name_obj[name] = obj
	idx_obj_name[obj] = name
	this.scanClass(obj, name)
end

---@deprecated not fully tested
---@param arg string|table
function FunctionUtils.unregisterClass(arg)
	assert(arg~=nil, "Argument 'arg' must not be nil.")
	local obj, name
	if type(arg) == "string" then
		name = arg --[[@as string]]
		obj = idx_name_obj[name]
		if not obj then return end
	else
		obj = arg --[[@as table]]
		name = idx_obj_name[obj]
		if not name then return end
	end

	this.unscanClass(obj,name)---@diagnostic disable-line: deprecated
	idx_obj_name[obj] = nil
	idx_name_obj[name] = nil
end

---Gets the info object for the specifoed function name or GUID.
---@param name string full qualified name or GUID
---@returns FunctionInfo
function FunctionUtils.getInfo(name)
	if not name then return nil end
	local f = idx_full_name_func[name] or idx_fid_func[normalize_guid(name)]
	if not f then return nil end
	return idx_func_info[f]
end

FunctionUtils.getId = this.getFunctionsId

---Gets the class name of the object.
---@param obj table
function FunctionUtils.getClassName(obj)
	if not obj then return nil end
	local name = idx_obj_name[obj]
	if not name then return nil end
	return name
end

---[DEPRECATED] Gets the full qualified name of the function.
---@param func function
---@return string #The full qualified name of the function or nil if not found.
---<p>Functions must be registered with <code>FunctionUtils.register_class</code> to be able to get the full name.</p>
---@deprecated
function _G.fname(func)
	--if not func then return nil end
	if not func then error("name not found") end
	local info = idx_func_info[func]
	--if not info then return nil end
	if not info then error("name not found") end
	return info.full_name
end

---Gets the full qualified name of the function.
---@param func function
---@return string #The full qualified name of the function or nil if not found.
---<p>Functions must be registered with <code>FunctionUtils.register_class</code> to be able to get the full name.</p>
function FunctionUtils.nameof(func)
	--if not func then return nil end
	if not func then error("function is nil") end
	local info = idx_func_info[func]
	--if not info then return nil end
	if not info then error("name not found. Check whether FunctionUtils.registerClass or GuiEventDistributor.register_view is called" ) end
	return info.full_name
end

-----------------------------------------------------------------------------------------------------------------------
return FunctionUtils
-----------------------------------------------------------------------------------------------------------------------


---@class KuxCoreLib.FunctionInfo
--- ------------------------------
---@field name string        The name of the function
---@field full_name string 	 The full qualified name of the function
---@field id string?         The GUID of the function (if available)