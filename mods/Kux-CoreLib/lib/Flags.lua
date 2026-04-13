require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Flags : { [string]: boolean }
local Flags = {
	__class  = "Flags",
	__guid   = "6b3edfc1-861b-4e38-86c3-1272706f1c59",
	__origin = "Kux-CoreLib/lib/Flags.lua",
}
if not KuxCoreLib.__classUtils.ctor(Flags) then return self end

-----------------------------------------------------------------------------------------------------------------------

---Creates new Flags
---@param flags string[]
---@return KuxCoreLib.Flags
function Flags:new(flags)
	local instance = {}
	setmetatable(instance, Flags)
	for _, value in ipairs(flags) do
		instance[value]=true
	end
	return instance
end

---Creates a dictionary
---@param list string[]
---@return {[string]: boolean}
function Flags.toDictionary(list)
	local dic = {}
	for _, value in ipairs(list) do
		dic[value]=true
	end
	return dic
end

function Flags:isSet(flag)
	if(self==Flags) then error("Invalid operation.") end
	return self[flag]
end

---
---@param flags string|string[]
function Flags:set(flags)
	if(self==Flags) then error("Invalid operation.") end
	if(type(flags)=="table") then
		for _, value in ipairs(flags) do
			self[value]=true
		end
	elseif type(flags)=="string" then
		self[flags]=true
	end
end

function Flags:reset(flags)
	if(self==Flags) then error("Invalid operation.") end
	if(type(flags)=="table") then
		for _, value in ipairs(flags) do
			self[value]=nil
		end
	else
		self[flags]=nil
	end
end

---------------------------------------------------------------------------------------------------

---Provides Flags in the global namespace
---@return KuxCoreLib.Flags
function Flags.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Flags) end

return Flags