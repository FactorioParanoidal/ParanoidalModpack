require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")


---__[DRAFT]__ Provides GUI helper functions
---@class KuxGuiLib.VGuiElement.static : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.VGuiElement.static
local VGuiElement = {
	__class  = "KuxGuiLib.VGuiElement.static",
	__guid   = "53c91921-195e-4e1d-a04e-3402d5321a17",
	__origin = "Kux-GuiLib/VGuiElement.lua",
}
KuxCoreLib.__classUtils.ctor(VGuiElement, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.VGuiElement.metatable
local mt = {}

---@class KuxGuiLib.VGuiElement : LuaGuiElement
---@field freeze fun():nil Converts to a POCO by recursively removing the metatables and parent references.
local impl = {}

-----------------------------------------------------------------------------------------------------------------------

local GuiHelper = KuxGuiLib.require.GuiHelper
local element_factory_utils = require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/element_factory_utils")
local prep_children = element_factory_utils.prep.children

--[ local ]------------------------------------------------------------------------------------------------------------

---
---@param container KuxGuiLib.VGuiElement
---@param args table
local function add(container, args)
	local el = VGuiElement.new(args, { parent = container })
	if args.index then
		table.insert(container.children, args.index, el)
	else
		table.insert(container.children, el)
	end
	return el
end

-----------------------------------------------------------------------------------------------------------------------
--- #region: instance implementation
-----------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
--- #region: meta table implementation
-----------------------------------------------------------------------------------------------------------------------

mt.__index = function(t, k)
	if k == "add" then rawset(t,"__call", "add") return t end
	if k == "tags" then local v = {} rawset(t,k,v) return v end
	if k == "children" then local v = {} rawset(t,k,v) return v end
	if k == "freeze" then rawset(t,"__call", "freeze") return t end
	if k == "__class" then return "KuxGuiLib.VGuiElement" end
	return nil
end
mt.__call = function(t,...)
	if t.__call=="add" then rawset(t,"__call", nil); return add(t, select(1, ...)) end
	if t.__call=="freeze" then rawset(t,"__call", nil); return VGuiElement.freeze(t) end
	return error("Invalid call")
end
mt.__pairs = function(t)
	return function(_, k)
		local nextKey, nextVal = next(t, k)
		--[[if nextKey == "parent" then
			--return nextKey, "<ref:" .. (t.parent.type or "?") .. ":" .. (t.parent.name or "unnamed") .. ">"
			return nextKey, "<ref>"
		end]]
		if k == "parent" then  nextKey, nextVal = next(t, k) end -- skip 'parent'
		return nextKey, nextVal
	end
end

script.register_metatable("KuxGuiLib.VGuiElement.metatable", mt)

-----------------------------------------------------------------------------------------------------------------------
--- #region: static implementation
-----------------------------------------------------------------------------------------------------------------------

--- Creates a new VGuiElement instance. (no hierarchy changes)
---@param args table add arguments
---@param internal_args table
---@return KuxGuiLib.VGuiElement
function VGuiElement.new(args,internal_args)
	args.children = prep_children(args) or {}
	local parent = internal_args.parent; internal_args.parent = nil
	local instance = KuxCoreLib.__classUtils.new(internal_args, args, mt)
	instance.parent = parent
	return instance
end

function VGuiElement.freeze(el)
	setmetatable(el, nil)
	el.parent = nil
	el.vid = nil
	for _, child in pairs(el.children) do VGuiElement.freeze(child) end
end

--[[setmetatable(VGuiElement, {
	__index = function(t, k) error("Member not found. name='"..k.."'") end,
	__newindex = function(t, k, v) error("Member not found. name='"..k.."'") end,
	__call = function(t, el) return VGuiElement.new(el) end,
})--]]

-----------------------------------------------------------------------------------------------------------------------
return VGuiElement