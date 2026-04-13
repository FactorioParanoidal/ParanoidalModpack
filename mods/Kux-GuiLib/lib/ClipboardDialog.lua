---
---@class KuxGuiLib.ClipboardDialog : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.ClipboardDialog
local ClipboardDialog = {
	__class  = "KuxGuiLib.ClipboardDialog",
	__guid   = "b37b36fb-e0f5-4990-a559-5bad2c033f38",
	__origin = "Kux-GuiLib/lib/ClipboardDialog.lua",
}
KuxCoreLib.__classUtils.ctor(ClipboardDialog, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------
local GuiEventDistributor = KuxGuiLib.require.GuiEventDistributor
local GuiBuilder = KuxGuiLib.require.GuiBuilder
LocalizationUtils = KuxCoreLib.require.LocalizationUtils
TranslationService = KuxCoreLib.require.TranslationService
local eb = GuiBuilder.ElementBuilder
local createView, frame, flow, button, label, checkbox, dropdown, spritebutton, emptywidget,scrollpane,textfield,eventof = eb.createView, eb.frame, eb.flow,eb.button, eb.label, eb.checkbox, eb.dropdown, eb.spritebutton, eb.emptywidget, eb.scrollpane, eb.textfield, eb.eventof
-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.ClipboardDialog.designer : KuxGuiLib.Designer
local designer = {}

---@class KuxGuiLib.ClipboardDialog.handler
local handler = {}

---@class KuxGuiLib.ClipboardDialog.loc
local loc = {---@type {[string]:string|table}
	dialog_hint = "Press Ctrl+X to copy and close",                            -- gui.fact_ClipboardDialog_dialog_hint
}
LocalizationUtils.map_keys(loc,"ClipboardDialog","Kux-GuiLib")
TranslationService.add_gui_localization(loc)

---
---@param player LuaPlayer
---@param clipboard_text string
---@param cursor_display_location GuiLocation
function ClipboardDialog.open(player, clipboard_text, cursor_display_location)
	local plx = getPlayerContextBase(player)
	if set_1(plx.player.gui.screen.fact_clipboard_dialog) then
		plx.ClipboardDialog.location = _1.location
		_1.destroy()
	end
	local width = 350
	local v = createView {
		container     = player.gui.screen,
		mod_name      = script.mod_name,
		view_name     = "ClipboardDialog",
		creator_name  = "Kux-GuiLib",
		localization_section="Kux-GuiLib-ClipboardDialog", locale=plx.player.locale,

		frame { name = "fact_clipboard_dialog", direction = "vertical", width = width, horizontally_stretchable = true, on_closed=eventof(handler.on_closed),
			flow { name = "dialog_titlebar", direction = "horizontal", drag_target = true, horizontally_stretchable = true,
				label { caption = "Clipboard Text", style = "frame_title", ignored_by_interaction = true },
				emptywidget { style="draggable_space_header", horizontally_stretchable = true, height = 24 },
				spritebutton { name = "close_dialog", sprite = "utility.close", style = "frame_action_button", on_click = eventof(handler.close_dialog) }
			},
			flow { name = "dialog_content", direction = "vertical", horizontally_stretchable = true,
				textfield { name = "clipboard_text", style="stretchable_textfield", text = clipboard_text, on_changed="clipboard_text_changed"},
				label { caption = {loc.dialog_hint} },
			}
		}
	}
	designer.element = eb.createElementAccessor(v)

	designer.dialog_titlebar.drag_target = designer.fact_clipboard_dialog
	designer.clipboard_text.focus()
	designer.clipboard_text.select_all()
	player.opened = designer.fact_clipboard_dialog
	designer.fact_clipboard_dialog.force_auto_center()

	if cursor_display_location then
		Events.on_next_tick({player_index=plx.player.index, curser_location=cursor_display_location},function(e)
			local plx=getPlayerContextBase(e.state.player_index)
			local frame=designer.fact_clipboard_dialog
			local quick_bar_heigh = 96 --TODO: constant for 2 rows
			local screen_width = plx.player.display_resolution.width
			local screen_height = plx.player.display_resolution.height - quick_bar_heigh
			local window_width = screen_width - 2 * frame.location.x
			local window_height = screen_height - 2 * frame.location.y

			frame.location = {
				cursor_display_location.x - window_width / 2,
				cursor_display_location.y - (window_height) / 2
			}
		end)
	end
end

---@param plx KuxGuiLib.PlayerContext
function ClipboardDialog.close(plx)
	if set_1(plx.player.gui.screen.fact_clipboard_dialog) then
		plx.ClipboardDialog.location = _1.location
		_1.destroy()
	end
end


---@param e KuxGuiLib.EventData.on_gui_text_changed
function handler.clipboard_text_changed(e)
	if e.element.text == "" then ClipboardDialog.close(e.plx) end
end
function handler.close_dialog(e) ClipboardDialog.close(e.plx) end
function handler.on_closed(e) ClipboardDialog.close(e.plx) end

GuiEventDistributor.register_view("ClipboardDialog", handler)

designer.element = eb.loadElementAccessor("Kux-GuiLib","ClipboardDialog")
setmetatable(designer,{
	__index = function(t,k) return t.element[k] end,
	__newindex = function () error("Designer is readonly") end
})
-----------------------------------------------------------------------------------------------------------------------
return ClipboardDialog