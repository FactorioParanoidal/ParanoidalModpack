require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides array functions
---@class KuxCoreLib.Array : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Array
local Array = {
	__class  = "Array",
	__guid   = "{57811545-A9BF-42D3-9AD5-DDEF82BB9C40}",
	__origin = "Kux-CoreLib/lib/Array.lua",

    ---@type integer The length of the array
    length = 0
}
if not KuxCoreLib.__classUtils.ctor(Array) then return self end
-----------------------------------------------------------------------------------------------------------------------
-- to avoid circular references, the class is defined before require other modules
local Table= KuxCoreLib.Table
local Assert= KuxCoreLib.That
local String = KuxCoreLib.String

---Creates a new array
---@param values any[]
---@param maxlength integer
---@return KuxCoreLib.Array
function Array:new(values, maxlength)
	local t = Table.shallowCopy(values or {})
	setmetatable(t, self)
    self.__index = self
	self.length = 0
    --setmetatable(t,{maxlength=maxlength})
	return t
end

function Array:add(v)
	self.length = self.length + 1
	table.insert(self, v, self.length)
end

function Array:insert(v, index)
	table.insert(self, v, index)
	self.length = self.length + 1
end

function Array:remove(v)
	local i = Table.indexOf(self,v)
	if i == 0 then return false end
	table.remove(self, i)
	self.length = self.length - 1
end

function Array:removeAt(index)
	table.remove(self, index)
	self.length = self.length - 1
end

---------------------------------------------------------------------------------------------------
return Array