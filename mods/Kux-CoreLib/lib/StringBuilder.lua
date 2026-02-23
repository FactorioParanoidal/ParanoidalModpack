require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---DRAFT Provides StringBuilder functions
---@class KuxCoreLib.StringBuilder.static : KuxCoreLib.Class
---@field asGlobal fun(): KuxCoreLib.StringBuilder.static
local StringBuilderClass = {
	__class  = "StringBuilder",
	__guid   = "d5b31800-b937-41d3-9ea4-f92de667806a",
	__origin = "Kux-CoreLib/lib/StringBuilder.lua",
}
if not KuxCoreLib.__classUtils.ctor(StringBuilderClass) then return self end

---------------------------------------------------------------------------------------------------

---@class KuxCoreLib.StringBuilder : KuxCoreLib.StringBuilder.static
---@field lines string[] The lines of the StringBuilder
---@field __isInstance boolean Always true for instances
local StringBuilder = {name="StringBuilder"}

---------------------------------------------------------------------------------------------------
--- static functions
---------------------------------------------------------------------------------------------------

local instance_mt = {
	name="instance_mt",
	__index = StringBuilder
}

---Create a new StringBuilder
---@return KuxCoreLib.StringBuilder
function StringBuilderClass.new()
	local instance = {
		lines = {}
	}
	setmetatable(instance, instance_mt) --[[@as KuxCoreLib.StringBuilder]]
	assert(instance.appendLine,"StringBuilder.appendLine is nil (new)")
	return instance
end

---------------------------------------------------------------------------------------------------
--- Instance functions
---------------------------------------------------------------------------------------------------

local inner_mt = {name="inner_mt"}
function inner_mt.__index(t,k)
	if k=="__isInstance" then return true
	elseif StringBuilderClass[k] then return StringBuilderClass[k]
	end
end
function inner_mt.__newindex(t,k,v)
	if k=="__isInstance" then error("The field '"..k.."'is write-protected.")
	elseif StringBuilderClass[k] then error("The field '"..k.."'is write-protected.")
	elseif k=="lines" then
		assert(type(v)=="table","The field '"..k.."' must be a table.")
		t.lines = v
	end
end

---append
---@param s any
function StringBuilder:append(s)
	if(#(self.lines)==0) then
		table.insert(self.lines,tostring(s))
	else
		self.lines[#(self.lines)] = self.lines[#(self.lines)]..tostring(s)
	end
end

---appendLine
---@param s any
function StringBuilder:appendLine(s)
	table.insert(self.lines, tostring(s))
end
assert(StringBuilder.appendLine,"StringBuilder.appendLine is nil (main)")

---toString
---@return string #The whole created string
function StringBuilder:toString()
	return table.concat(self.lines,"\n")
end

setmetatable(StringBuilder, inner_mt) -- MUST be done here as last, AFTER the functions are defined!

---------------------------------------------------------------------------------------------------

return StringBuilderClass