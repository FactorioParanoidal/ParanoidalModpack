require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---__[DRAFT]__ Provides GUI helper functions
---@class KuxGuiLib.GuiElementRef.static : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.GuiElementRef.static
local GuiElementRef = {
	__class  = "KuxGuiLib.GuiElementRef.static",
	__guid   = "885c41a3-9334-4b11-9ab2-6ee3e041807c",
	__origin = "Kux-GuiLib/lib/GuiElementRef.lua",
}
KuxCoreLib.__classUtils.ctor(GuiElementRef, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.GuiElementRef.metatable
local mt = {}

---@class KuxGuiLib.GuiElementRef : LuaGuiElement
---@field __base LuaGuiElement
---@field __path string[]
local impl = {}

-----------------------------------------------------------------------------------------------------------------------

local GuiHelper = KuxGuiLib.require.GuiHelper

--[ local ]------------------------------------------------------------------------------------------------------------

---@param t KuxGuiLib.GuiElementRef
---@return LuaGuiElement?
local function restore(t)
	local path = t.__path
	local player = game.get_player(path[1])
	if not player then return nil end
	local current = player.gui[path[2]] --[[@as LuaGuiElement]]
	for i = 3, #path do
		if not current then return nil end
		current = current[path[i]]
	end

	t.__base = current
	return current
end

-----------------------------------------------------------------------------------------------------------------------
--- #region: instance implementation
-----------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------------------------
--- #region: meta table implementation
-----------------------------------------------------------------------------------------------------------------------

mt.__index = function(t, k)
	local base = rawget(t, "__base")
	if not base.valid then base = restore(t)end
	return base[k]
end

script.register_metatable("KuxGuiLib.GuiElementRef.metatable", mt)

-----------------------------------------------------------------------------------------------------------------------
--- #region: static implementation
-----------------------------------------------------------------------------------------------------------------------

---@param el LuaGuiElement
function GuiElementRef.new(el, path)
	local instance = {
		__base=el,
		__class = "KuxGuiLib.GuiElementRef",
		__path = path or GuiHelper.getPath(el) --slow!!
	}
	setmetatable(instance, mt)
	return instance
end

setmetatable(GuiElementRef, {
	__index = function(t, k) error("Member not found. name='"..k.."'") end,
	__newindex = function(t, k, v) error("Member not found. name='"..k.."'") end,
	__call = function(t, el) return GuiElementRef.new(el) end,
})

-----------------------------------------------------------------------------------------------------------------------
return GuiElementRef