
---@class KuxCoreLib.PrototypeData.Extend.Arguments

---@class KuxCoreLib.PrototypeData.Extend
---@field prefix string
---@overload fun(KuxCoreLib.PrototypeData.Extend.Arguments):KuxCoreLib.PrototypeData.ExtendInstance
local extend = {
	---@type string
	prefix = nil,
	---@type table
	common = {},
}

---@class KuxCoreLib.PrototypeData.ExtendInstance : KuxCoreLib.PrototypeData.ExtendInstanceBase
local instanceMembers = {}

---@class KuxCoreLib.PrototypeData.Extend.Utils
local utils = {
		---@type any
		NIL = "nil\b\b\b",
		---@return any
		MERGE = function (t) t.ACTION="merge"; return t end,
		---@return any
		PATCH = function (t) t.ACTION="patch"; return t end,
		---@return any
		DEEPCOPY = function (t) t.ACTION="deepcopy"; return t end,
		---@return any
		COPY = function (t) t.ACTION="copy"; return t end --reduntand because it is the default action
}
extend.utils = utils

---@type KuxCoreLib.PrototypeData.ExtendInstanceBase
local extendBase = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/data/PrototypeData-extend-base")

---------------------------------------------------------------------------------------------------

extendBase.setUtils(utils)
setmetatable(instanceMembers, {__index = extendBase}) --instanceMembers inherits from baseClass

---Creates a new Extend object
---@param t KuxCoreLib.PrototypeData.Extend.Arguments | table ExtendArguments | {setting_type, order}
---@return KuxCoreLib.PrototypeData.ExtendInstance
local function call_extend(self, t)
	local new = {
		common = t or {},
		count = 0
	}
	setmetatable(new, {
		__index = instanceMembers
	})
	return new
end

setmetatable(extend--[[@as table]],{
	__call = call_extend
})

---------------------------------------------------------------------------------------------------
--- Utils
---------------------------------------------------------------------------------------------------

---Returns the prefix
---@param obj KuxCoreLib.PrototypeData.ExtendInstance
---@return string
function utils.getPrefix(obj)
	return (obj["common"].prefix or extend.prefix
		or (_G["mod"] and _G["mod"]["prefix"] or nil)) -- assumig the mod defines a global "mod.prefix" variable
		or error("No prefix defined. use extend.common.prefix, extend.prefix, or _G.mod.prefix")
end

---Returns the name with prefix
---@param obj KuxCoreLib.PrototypeData.ExtendInstance
---@param name string
---@return string
function utils.getName(obj, name)
	return utils.getPrefix(obj)..name
end

function utils.merge(common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end

	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end

	--clean up--
	merged.prefix = nil

	return merged
end

function utils.patch(data, patch)
	local function prepTable(d,k)
		if type(d[k])=="table" then return
		elseif d[k]==nil then d[k] = {}
		else error("Cannot patch a non-table value: "..tostring(d[k]))
		end
	end
	for k,v in pairs(patch) do
		if(v==utils.NIL) then data[k] = nil
		elseif k=="ACTION" and (v=="merge" or v=="patch" or v=="deepcopy") then --skip
		--elseif type(v)=="table" and v.ACTION=="merge" then utils.merge(data[k], v)
		--elseif type(v)=="table" and v.ACTION=="deepcopy" then utils.deepcopy(data[k], v)
		elseif type(v)=="table" and v.ACTION=="patch" then prepTable(data,k); utils.patch(data[k], v)
		else data[k] = v
		end
	end
end

---------------------------------------------------------------------------------------------------
--- instanceMembers
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
return extend


