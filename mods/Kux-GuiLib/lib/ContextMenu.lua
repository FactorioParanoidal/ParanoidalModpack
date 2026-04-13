
---
---@class KuxGuiLib.ContextMenu : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.ContextMenu
local ContextMenu = {
	__class  = "KuxGuiLib.ContextMenu",
	__guid   = "c780021d-592a-4359-95dd-3fc4b138ce13",
	__origin = "Kux-GuiLib/lib/ContextMenu.lua",
}
KuxCoreLib.__classUtils.ctor(ContextMenu, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------
local GuiBuilder = KuxGuiLib.require.GuiBuilder

---@param e EventData.on_gui_click   event data from the click event
---@param items table[]              menu items to display
---@param options {localization_section:string?, view_name: string?}?
function ContextMenu.open(e, items, options)
	options = options or {}
	local plx = getPlayerContextBase(e.player_index)
    local player = plx.player
	local context_view_name = options.view_name or e.element.tags.view_name --[[@as string]]
	local mod_name =  e.element.tags.mod_name --[[@as string]]
	options.localization_section = options.localization_section or mod_name.."-"..context_view_name
	local target_gui_id =  e.element.tags.gui_id
	plx.ContextMenu.element = e.element
	plx.ContextMenu.view_name = context_view_name
	plx.ContextMenu.items = items

    if player.gui.screen.context_menu then player.gui.screen.context_menu.destroy() end

	do
		local eb = GuiBuilder.ElementBuilder
		local createView, frame, flow, button, label, checkbox, dropdown, spritebutton, emptywidget,scrollpane = eb.createView, eb.frame, eb.flow,eb.button, eb.label, eb.checkbox, eb.dropdown, eb.spritebutton, eb.emptywidget, eb.scrollpane

		local function menu_entry (args)
			return button {caption=args.caption, style="list_box_item", horizontally_stretchable = true, raise_hover_events=true}
		end

		local function convert_menu_items(items)
			local menu_items = {}
			for _, item in ipairs(items) do
				local menu_item = {
					style="list_box_item", horizontally_stretchable = true, raise_hover_events=true
				}
				eb.patch(menu_item, item)
				eb.patch_tags(menu_item, "context_view_name", context_view_name)
				if not menu_item.caption then menu_item.caption = {options.localization_section.."."..item.name} end
				table.insert(menu_items, button(menu_item))
			end
			return menu_items
		end

		local ctx_items = convert_menu_items(items)

		createView{
			container = player.gui.screen,
			mod_name = mod_name,
			view_name = "ContextMenu",
			localization_section="Kux-GuiLib-ContextMenu", locale=plx.player.locale,

			frame { name = "context_menu", direction = "vertical", location = e.cursor_display_location, padding = 0, raise_hover_events = true,
				flow { direction = "vertical", horizontally_stretchable = true, vertical_spacing = 0, margin = 0,
					children = ctx_items
				}
			}
		}
		player.gui.screen.context_menu.location = e.cursor_display_location
	end
end

function close(player)
	--if true then return end
	local plx = getPlayerContextBase(player)
	if plx.player.gui.screen.context_menu then plx.player.gui.screen.context_menu.destroy() end
	plx.ContextMenu.element = nil
end


Events.on_event(defines.events.on_gui_click, function(e)
	local _ = "fid{654a61ac-e525-43a9-9b4e-5e6be7dc82d1}"
	local plx = getPlayerContextBase(e.player_index)
	if plx.ContextMenu.element == e.element then return end
	close(e.player_index)
end)

---@param e EventData.on_gui_leave
Events.on_event(defines.events.on_gui_hover, function(e)
	if not e.element then return end
	--print(e.tick, "hover", e.element.name, e.element.type)
	if e.element.tags.view_name ~= "ContextMenu" then return end
	local plx = getPlayerContextBase(e.player_index)
	plx.ContextMenu.close=false
end)

---@param e EventData.on_gui_leave
Events.on_event(defines.events.on_gui_leave, function(e)
	if not e.element then return end
	--print(e.tick, "leave", e.element.name, e.element.type)
	if e.element.tags.view_name ~= "ContextMenu" then return end
	local plx = getPlayerContextBase(e.player_index)
	plx.ContextMenu.close=true
	Events.on_next_tick({player_index=e.player_index}, function(e2)
		local plx = getPlayerContextBase(e2.state.player_index)
		if plx.ContextMenu.close == true then close(e.player_index) end
	end)
end)


-----------------------------------------------------------------------------------------------------------------------
return ContextMenu