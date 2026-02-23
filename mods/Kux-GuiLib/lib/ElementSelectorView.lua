
---
---@class KuxGuiLib.ElementSelectorView : KuxGuiLib.Class, KuxGuiLib.View
---@field asGlobal fun():KuxGuiLib.ElementSelectorView
local ElementSelectorView = {
	__class  = "KuxGuiLib.ElementSelectorView",
	__guid   = "c780021d-592a-4359-95dd-3fc4b138ce13",
	__origin = "Kux-GuiLib/lib/ElementSelectorView.lua",
}
KuxCoreLib.__classUtils.ctor(ElementSelectorView, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------
local GuiEventDistributor = KuxGuiLib.require.GuiEventDistributor
local ElementUtils = KuxCoreLib.require.ElementUtils

ElementSelectorView.designer = require("__Kux-GuiLib__/lib/ElementSelectorView-designer")
local designer = ElementSelectorView.designer

---@type KuxGuiLib.ElementSelectorView.Data
local data_template = {
	group_name = nil,
	filter = { ---@type ElementFilter
		search_text = "",
		locale = "en",
		show_disabled = true,
		show_hidden = true,
	},
	num_results = 0,
	elements = { ---@type ElementCatalog
		rows = {},
		idx_row_index_group_name = {},
		idx_type_name_key = {},
		count_total = 0,
		count_filtered = 0
	}
}


---@param plx KuxGuiLib.PlayerContext
---@param container LuaGuiElement
function ElementSelectorView.open_subview(plx, container)
	plx.ElementSelectorView = plx.ElementSelectorView or {}
	Table.migrate(plx.ElementSelectorView, data_template, "none")
	plx.ElementSelectorView.filter.locale = plx.player.locale
	plx.ElementSelectorView.elements = ElementUtils.getAllElementsFiltered(plx.player, plx.ElementSelectorView.filter) --TODO: performance!
	designer.open(plx, container)
end

---@param plx KuxGuiLib.PlayerContext
function ElementSelectorView.apply_settings(plx)
	local data = plx.ElementSelectorView
	local settings = plx.ElementSelectorOptionsView
	local gui = ElementSelectorView.designer
	data.filter.show_hidden = settings.show_hidden
	data.filter.show_disabled = settings.show_disabled
	data.elements = ElementUtils.getAllElementsFiltered(plx.player, data.filter)
	if gui.num_results and gui.num_results.valid then
		designer.update_elements(plx) end
end

---@class ElementSelectorView.handler
local handler = {}


---@param e KuxGuiLib.EventData.on_gui_text_changed
function handler.search_text_changed(e)
	local data = e.plx.ElementSelectorView
	local gui = ElementSelectorView.designer

	data.filter = {
		search_text=e.element.text,
		locale=e.plx.player.locale,
		show_disabled=true,
		show_hidden=true,
	}
	gui.search_textfield_shadow_text.visible = e.element.text==nil or #e.element.text==0
	ElementUtils.updateAllElementsFiltered(data.elements, data.filter)
	designer.update_elements(e.plx)
end

---@param e KuxGuiLib.EventData.on_gui_click
function handler.item_group_clicked(e)
	for _, btn in ipairs(e.element.parent.children) do
		btn.toggled = btn == e.element
	end
	local item_group = e.element.tags.item_group --[[@as string]]
	designer.select_group(e.plx, item_group)
	e.plx.ElementSelectorView.group_name = item_group
end


---
---@param e KuxGuiLib.EventData.on_gui_click
function handler.element_clicked(e)
	local data = e.plx.ElementSelectorView
	if not data.on_element_click then return end
	local view_name, handler_name = data.on_element_click:match("([^%.]+)%.([^%.]+)")
	GuiEventDistributor.raise_event(e,view_name,handler_name)
end

---@param e KuxGuiLib.EventData.on_gui_click
function handler.option_clicked(e)
	local data = e.plx.ElementSelectorView
	e.plx.ElementSelectorOptionsView[e.element.name] = e.element.state
	data.filter[e.element.name] = e.element.state
	ElementUtils.updateAllElementsFiltered(data.elements, data.filter)
	designer.update_elements(e.plx)
end

GuiEventDistributor.register_view("ElementSelectorView", handler)

-----------------------------------------------------------------------------------------------------------------------
return ElementSelectorView

-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.ElementSelectorView.Data
---       -------------------
---@field __class "KuxGuiLib.ElementSelectorView.Data"?
---@field group_name string?
---@field filter ElementFilter
---@field num_results number?
---@field elements ElementCatalog?
---@field on_element_click string? routed event handler "view_name.handler_name"

