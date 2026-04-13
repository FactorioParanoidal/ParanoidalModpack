require((KuxGuiLibPath or "__Kux-GuiLib__/").."lib/init")

---
---@class KuxGuiLib.ElementSelectorOptionsView : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.ElementSelectorOptionsView
local ElementSelectorOptionsView = {
	__class  = "KuxGuiLib.ElementSelectorOptionsView",
	__guid   = "c9f0084a-f81e-4faa-b9e6-4a8ebc13d69a",
	__origin = "Kux-GuiLib/lib/ElementSelectorOptionsView.lua",
}
KuxCoreLib.__classUtils.ctor(ElementSelectorOptionsView, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------
local GuiEventDistributor = KuxGuiLib.require.GuiEventDistributor
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils
local TranslationService = KuxCoreLib.require.TranslationService
local ElementBuilder = KuxGuiLib.require.GuiBuilder.ElementBuilder

---@class ElementSelectorOptionsView.designer
local designer = {}

---@class ElementSelectorOptionsView.handler
local handler = {}

---@class ElementSelectorOptionsView.private
local this = {}

-----------------------------------------------------------------------------------------------------------------------
local GuiBuilder = KuxGuiLib.require.GuiBuilder

-----------------------------------------------------------------------------------------------------------------------

---@vlass ElementSelectorOptionsView.localization
local loc = {---@type {[string]:string|table}
	search_header = "Filter Options:",
	show_hidden = "Show hidden elements",
	show_disabled = "Show disabled elements",
	use_internal_names = "Use internal names"
}
LocalizationUtils.map_keys(loc, "ElementSelectorOptionsView","Kux-GuiLib")
TranslationService.add_gui_localization(loc)

-----------------------------------------------------------------------------------------------------------------------
---@param plx KuxGuiLib.PlayerContext
---@param container LuaGuiElement
function ElementSelectorOptionsView.open_subview(plx, container)
	designer.open(plx, container)
end

-----------------------------------------------------------------------------------------------------------------------

---@param plx KuxGuiLib.PlayerContext
---@param container LuaGuiElement
function designer.open(plx, container)
	local eb = GuiBuilder.ElementBuilder
	local createView, frame, flow, button, label, checkbox, dropdown, spritebutton, emptywidget,scrollpane, choose_elem_button, radiobutton = eb.createView, eb.frame, eb.flow,eb.button, eb.label, eb.checkbox, eb.dropdown, eb.spritebutton, eb.emptywidget, eb.scrollpane, eb.chooseelembutton, eb.radiobutton
	local data = plx.ElementSelectorOptionsView
	data.show_hidden = data.show_hidden or false
	data.show_disabled = data.show_disabled or false
	container.clear() --TODO: cleanup gui.elements
	local v = createView {
		container =	container,
		mod_name = script.mod_name,
		creator_name = "Kux-GuiLib",
		view_name = "ElementSelectorOptionsView",
		parent_view_name = "MainView",
		localization_section = "Kux-GuiLib-ElementSelectorOptionsView", locale = plx.player.locale,

		flow { name = "search_options_view", direction = "vertical", horizontally_stretchable = true,
			flow { direction = "vertical", horizontally_stretchable = true,
				label { name = "search_header", style="caption_label"},
				checkbox { name = "show_disabled", state = data.show_disabled, on_click = "option_clicked" },
				checkbox { name = "show_hidden", state = data.show_hidden, on_click = "option_clicked" },
			}
		}
	}
	designer.element = eb.createElementAccessor(v)
end

--[ events ]-----------------------------------------------------------------------------------------------------------

---@param e KuxGuiLib.EventData.on_gui_click
function handler.option_clicked(e)
	e.plx.ElementSelectorOptionsView[e.element.name] = e.element.state
	e.plx.ElementSelectorView.filter[e.element.name] = e.element.state
end

GuiEventDistributor.register_view("ElementSelectorOptionsView", handler)

designer.element = ElementBuilder.loadElementAccessor("Kux-GuiLib","ClipboardDialog")
setmetatable(designer,{
	__index = function(t,k) return t.element[k] end,
	__newindex = function () error("Designer is readonly") end
})

--[ export ]-----------------------------------------------------------------------------------------------------------

return ElementSelectorOptionsView

-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.ElementSelectorOptionsView.Data
---       -------------------
---@field __class "KuxGuiLib.SearchOptions.Data"?
---@field show_disabled boolean? show disabled recipes/prototypes
---@field show_hidden boolean?  show hidden recipes/prototypes
