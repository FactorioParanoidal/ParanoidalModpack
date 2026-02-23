require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---
---@class KuxGuiLib.GuiView.static : KuxGuiLib.Class
---@field element KuxGuiLib.ElementAccessor
---@field asGlobal fun():KuxGuiLib.GuiView.static
local GuiView = {
	__class  = "KuxGuiLib.GuiView",
	__guid   = "aaf81fca-5fcf-4cd1-9b94-b7b7801da56f",
	__origin = "Kux-GuiLib/lib/ui/GuiView.lua",
}
KuxCoreLib.__classUtils.ctor(GuiView, KuxGuiLib)
---------------------------------------------------------------------------------------------------
local ElementBuilder = KuxGuiLib.require.GuiBuilder.ElementBuilder

---@class KuxGuiLib.GuiView.metatable
local mt = {}

---@class KuxGuiLib.GuiView
---       ------------------
---@field __class "KuxGuiLib.GuiView" The class name
---@field element LuaGuiElement The root element of the view
---@field name string The name of the view
---@field path string[] The path to the view element in the view hierarchy
local impl = {
	__class = "KuxGuiLib.GuiView",
	__element = nil,
	__name = nil,
	__path = nil,
}

---
---@param el LuaGuiElement
---@param name string
---@param value number|string|boolean|table
local function setTag(el, name, value)
	local tags = el.tags or {}
	el.tags[name] = value
	el.tags = tags
end

---------------------------------------------------------------------------------------------------
--- #region: instance implementation
---------------------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------------------
--- #region: meta table implementation
---------------------------------------------------------------------------------------------------

mt.__index = function(t, k) return nil end -- dummy

script.register_metatable("KuxGuiLib.GuiView.metatable", mt)

---------------------------------------------------------------------------------------------------
--- #region: static implementation
---------------------------------------------------------------------------------------------------

---@param el LuaGuiElement
function GuiView.new(el)
	error("not implemented")
	--return KuxCoreLib.__classUtils.new(impl, {element=el}, mt)
end

function GuiView.ctor(public, private)
	--TODO: integrate with KuxCoreLib.__classUtils.ctor(GuiView, KuxGuiLib)

	setmetatable(private,{
		__index=public,
		__newindex=function (t,k,v)
			if k == "element" then rawset(public, k, v)
			else rawset(private, k, v) end
		end
	})

	setmetatable(public,{
		__index=function (t,k)
			if k == "element" then
				local modName = private.mod_name or script.mod_name
				local viewName = assert(private.view_name, "view_name missing")
				local lazy = ElementBuilder.loadElementAccessor(modName, viewName)
				rawset(t, "element", lazy)
				return lazy
			end
		end
	})
end

function GuiView.finalize(public, private)
	if private then KuxCoreLib.__classUtils.finalize(private) end
	KuxCoreLib.__classUtils.finalize(public)
end



function GuiView.buildNames(nx)
	for k, _ in pairs(nx) do nx[k]=k end
end

---[ finalize ]--------------------------------------------------------------------------------------------------------

setmetatable(GuiView, {
	__index = function(t, k) error("Member not found. name='"..k.."'") end,
	__newindex = function(t, k, v) error("Object is protected. The new member '"..k.."' can not be injected.") end,
	__call = function(t, el) return GuiView.new(el) end,
})
---------------------------------------------------------------------------------------------------
return GuiView