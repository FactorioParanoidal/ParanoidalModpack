
---
---@class KuxGuiLib.ErrorDialog : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.ErrorDialog
local ErrorDialog = {
	__class  = "KuxGuiLib.ErrorDialog",
	__guid   = "c780021d-592a-4359-95dd-3fc4b138ce13",
	__origin = "Kux-GuiLib/lib/ErrorDialog.lua",
}
KuxCoreLib.__classUtils.ctor(ErrorDialog, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------

---@class KuxGuiLib.ErrorDialog.handler
local handler = {}

local GuiEventDistributor = KuxGuiLib.require.GuiEventDistributor

local TranslationService = KuxCoreLib.require.TranslationService
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils
local eb = KuxGuiLib.require.GuiBuilder.ElementBuilder

local translation_requests = {}

---@class KuxGuiLib.ElementSelectorView.localization ---@type {[string]:string|table}
local loc = {
	title = "Error",

	[".caption"] = {
		word_wrap_checkbox = "Word wrap",
		back  = "Continue [color=yellow]⚠[/color]",
		exit  = "Exit"
	},
	[".tooltip"] = {
		back="[color=yellow]⚠ Warning[/color]: You can try to continue the game (not recommended). but game/ui state may be corrupted."
	}
}
LocalizationUtils.map_keys(loc, "ErrorDialog", "Kux-GuiLib")
TranslationService.add_gui_localization(loc)

local listening = true

local function getGuiId(mod_name, view_name)
	return mod_name.."-".."ErrorDialog-"..view_name
end

---@param e EventData.on_gui_click|EventData.on_gui_checked_state_changed
---@return LuaGuiElement?
local function getRoot(e)
	local gui_id = e.element and e.element.tags and e.element.tags.gui_id
	if not gui_id then return nil end
	return e.element.gui.screen[gui_id]
end


function table_deep_concat(t, sep)
	local result = {}
	local function flatten(v)
		if type(v) == "table" then
			for _, val in ipairs(v) do flatten(val) end
		else
			table.insert(result, tostring(v))
		end
	end
	flatten(t)
	return table.concat(result, sep)
end

---
---@param player LuaPlayer
---@param message LocalisedString
---@param mod_name string?
---@param view_name string?
---@param state AnyBasic?
function ErrorDialog.show(player, message, mod_name, view_name, state)
	local gui_id = getGuiId(mod_name,view_name)
	local gui = player.gui.screen
	local dlg = gui[gui_id] or gui[gui_id]
	if dlg then dlg.destroy() end
	local createView, frame, flow, button, checkbox, emptywidget, textbox = eb.createView, eb.frame, eb.flow, eb.button,eb.checkbox, eb.emptywidget, eb.textbox
	local elements={}
	dlg = createView {
		container = player.gui.screen,
		element_index = elements,
		view_name = "ErrorDialog", --must always be "ErrorDialog", no custom view name!
		mod_name = script.mod_name,
		creator_name = "Kux-GuiLib",
		localization_section = "Kux-GuiLib-ErrorDialog",
		locale = player.locale,

		frame { name=gui_id, direction="vertical", caption={loc.title}, horizontally_stretchable = true, tags={state=state or {}},
			textbox { style=KuxGuiLib.style.dark_code_textbox, name="message_textbox", text="translating...",
				font = "NotoMono-12", read_only = true, word_wrap = true, minimal_width = 400,
				--maximal_width =  (player.display_resolution.width /player.display_scale*0.6)
				--minimal_height = 150
				maximal_height = (player.display_resolution.height/player.display_scale*0.6)},
			flow { direction="horizontal", horizontally_stretchable = true, top_margin=5,
				button { name="back", style="back_button", tags={gui_id=gui_id}},
				emptywidget { horizontally_stretchable = true},
				checkbox { name = "word_wrap_checkbox", tags={gui_id=gui_id}, state = true },
				emptywidget { horizontally_stretchable = true},
				button { name="exit", style="red_confirm_button", tags={gui_id=gui_id}}
			}
		}
	}

	if type(message) == "table" then
		listening = true
		local translation_id = player.request_translation(message) or error("invalid state")
		--local plx = getPlayerContextBase(player)
		--local data = plx.ErrorDialog
		--data.translations[translation_id] = gui_id
		translation_requests[player.index] = translation_requests[player.index] or {}
		translation_requests[player.index][translation_id] = gui_id
	else
		elements[view_name].message_textbox.text = tostring(message)
	end

	--player.opened=frame
	Events.on_next_tick({player_index=player.index, window=dlg.name}, function(e)
		local player = game.players[e.state.player_index]
		local dlg = player.gui.screen[e.state.window]
		if not dlg then return end
		dlg.force_auto_center()
	end)
end

local on_close_handler = {}
function ErrorDialog.on_close(f) table.insert(on_close_handler,f) end

local function this_close(e)
	e.state = e.element.tags.state
	for _, f in ipairs(on_close_handler) do f(e) end
end

local function hasAnyActiveTranslation()
	for _, player in pairs(game.players) do
		if translation_requests[player.index] and next(translation_requests[player.index]) then return true end
	end
	return false
end

---@param e EventData.on_string_translated
local function on_string_translated(e)
	if not listening then return end
	if not translation_requests[e.player_index] or not translation_requests[e.player_index][e.id] then return end
	local plx = getPlayerContextBase(e.player_index)
	local data = plx.ErrorDialog
	--local dialog_id = data.translations[e.id]
	local dialog_id = translation_requests[e.player_index][e.id]
	if dialog_id == nil then return end
	local dlg = plx.player.gui.screen[dialog_id]
	if not dlg or not dlg.valid then return end
	dlg.message_textbox.text = e.result
	--data.translations[e.id] = nil
	translation_requests[e.player_index][e.id]=nil
	listening = hasAnyActiveTranslation()
end



---[ handler ] --------------------------------------------------------------------------------------------------------

---
---@param e KuxGuiLib.EventData.on_gui_click
function handler.back_clicked(e)
	local dlg = getRoot(e); if not dlg or not dlg.valid then return end
	e.element = dlg
	this_close(e)
	local player = game.players[e.player_index]
	if player.opened == dlg then player.opened = nil end
	if dlg.valid then dlg.destroy() end
end

function handler.exit_clicked(e)
	e.on_error.error={"Game aborted by user. No error report necessary.", game.players[e.player_index].name}
	error("__ABORT_BY_USER__")
end

---@param e KuxGuiLib.EventData.on_gui_checked_state_changed
function handler.word_wrap_checkbox_changed(e)
	local dlg = getRoot(e); if not dlg or not dlg.valid then return end
	dlg.message_textbox.word_wrap = e.element.state
end

---@param e EventData.on_gui_checked_state_changed
Events.on_event(defines.events.on_gui_closed, function(e)
	if not e.element or e.element.tags.mod_name ~= script.mod_name then return end
	local root = getRoot(e); if not root then return end
	root.destroy()
end)

Events.on_event(defines.events.on_string_translated, on_string_translated)
--Events.on_event(defines.events.on_gui_click,handler.close_clicked)

GuiEventDistributor.__on_initialized(function(e)
	GuiEventDistributor.register_view("ErrorDialog", handler)
end)

--[ finalize ] --------------------------------------------------------------------------------------------------------

KuxCoreLib.__classUtils.finalize(ErrorDialog)
return ErrorDialog

-----------------------------------------------------------------------------------------------------------------------
-- #region meta
-----------------------------------------------------------------------------------------------------------------------


---@class KuxGuiLib.ErrorDialog.Data
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field translations  table<integer, string>  {translation-id -> gui-id}