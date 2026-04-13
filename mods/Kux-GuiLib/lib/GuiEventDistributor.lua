
---
---@class KuxGuiLib.GuiEventDistributor : KuxGuiLib.Class
---@field asGlobal fun():KuxGuiLib.GuiEventDistributor
local GuiEventDistributor = {
	__class  = "KuxGuiLib.GuiEventDistributor",
	__guid   = "775b8c4d-41a2-4007-8bad-b231a2a5a746",
	__origin = "Kux-GuiLib/lib/GuiEventDistributor.lua",
}
KuxCoreLib.__classUtils.ctor(GuiEventDistributor, KuxGuiLib)
-----------------------------------------------------------------------------------------------------------------------
local EventDistributor = KuxCoreLib.EventDistributor -- only for EventDistributor.getDisplayName ?!
local FunctionUtils = KuxCoreLib.require.FunctionUtils
local ErrorDialog = KuxGuiLib.require.ErrorDialog

local currentEvent = nil
local lastEvent = nil

---@type table<string,table<string,function>>
local view_handler = {}

---
---@param view_name string
---@param handler table
function GuiEventDistributor.register_view(view_name, handler)
	view_handler[view_name] = handler
	FunctionUtils.registerClass(handler, view_name)
end

function GuiEventDistributor.unregister_view(view_name)
	view_handler[view_name] = nil
	FunctionUtils.unregisterClass(view_name)
end

function GuiEventDistributor.raise_event(e, view_name, handler_name)
	local handler = view_handler[view_name]
	if not handler then return end
	local handler_fnc = handler[handler_name]
	if not handler_fnc then return end
	handler_fnc(e)
end

local function getRootElement(el)
	while el.parent and el.parent.parent do
		el = el.parent
	end
	return el
end

local function handle_error(err)
	local last_outer = err.trace:match("([^\n]*)$"):gsub("^%s*","") or ""
	local last_inner = err.err:match("([^\n]*)$"):gsub("^%s*","") or ""
	if last_inner == last_outer then
		err = err.err
	else
		err = err.err.."\n"..err.trace:gsub("\t","    ")
	end

	local e = currentEvent
	if e then
		 err = {"Kux-GuiLib-GuiEventDistributor.error",
		 		--[[__1__]] {"mod-name."..script.mod_name},
				--[[__2__]] script.active_mods[script.mod_name],
				--[[__3__]] script.mod_name,
				--[[__4__]] {"","Error while running event ",script.mod_name,"::",EventDistributor.getDisplayName(e),"\n",
				err }}
	else
		err = debug.traceback(err, 2):gsub("\t","    ")
	end

	log(err)
	--local player = e and e.player_index and game.get_player(e.player_index) or nil
	if player then player.print({"Kux-GuiLib.print_error_log_msg", {"mod-name."..script.mod_name}})
	else           game.print({"Kux-GuiLib.print_error_log_msg", {"mod-name."..script.mod_name}})
	end
	if player then
		local state = {
			context = "GuiEventDistributor"
		}
		if e.on_error.close_ui then
			state.close_ui = e.on_error.close_ui
		end

		ErrorDialog.show(player, err, "Kux-GuiLib", "GuiEventDistributor", state)
		Events.on_next_tick({}, function(e)
			game.tick_paused=true
		end)
	end
	return err
end

ErrorDialog.on_close(function (e)
	if not e.element.tags.state or e.element.tags.state.context~="GuiEventDistributor" then return end
	game.tick_paused=false

	local player = game.players[e.player_index]
	local root = e.element.tags.close_ui
	if root then player.gui.screen[root].destroy() end
end)

local function format_abort(e)
	local msg = e.on_error.error or "Game aborted by user."
	return {"", "\n\n――――――――――――――――――――――――――――――――\n",msg, "\n――――――――――――――――――――――――――――――――\n"}
end

local guess_handler_name_dic = {
	[defines.events.on_gui_click                  ] = {suffix = {"_clicked"  }, field={"on_gui_click", "on_click"}},
	[defines.events.on_gui_elem_changed           ] = {suffix = {"_changed"  }, field={"on_gui_elem_changed", "on_elem_changed", "on_changed"}},
	[defines.events.on_gui_checked_state_changed  ] = {suffix = {"_changed"  }, field={"on_gui_checked_state_changed", "on_checked_state_changed", "on_changed"}},
	[defines.events.on_gui_selection_state_changed] = {suffix = {"_changed"  }, field={"on_gui_selection_state_changed", "on_selection_state_changed", "on_changed"}},
	[defines.events.on_gui_text_changed           ] = {suffix = {"_changed"  }, field={"on_gui_text_changed", "on_text_changed", "on_changed"}},
	[defines.events.on_gui_value_changed          ] = {suffix = {"_changed"  }, field={"on_gui_value_changed", "on_value_changed", "on_changed"}},
	[defines.events.on_gui_location_changed       ] = {suffix = {"_changed"  }, field={"on_gui_location_changed", "on_location_changed", "on_changed"}},
	[defines.events.on_gui_confirmed              ] = {suffix = {"_confirmed"}, field={"on_gui_confirmed", "on_confirmed"}},
	[defines.events.on_gui_opened                 ] = {suffix = {"_opened"   }, field={"on_gui_opened", "on_opened"}},
	[defines.events.on_gui_closed                 ] = {suffix = {"_closed"   }, field={"on_gui_closed", "on_closed"}},
	[defines.events.on_gui_selected_tab_changed   ] = {suffix = {"_changed"  }, field={"on_gui_selected_tab_changed", "on_changed"}},
	[defines.events.on_gui_switch_state_changed   ] = {suffix = {"_changed"  }, field={"on_gui_switch_state_changed", "on_changed"}},
	[defines.events.on_gui_hover                  ] = {suffix = {"_hover"    }, field={"on_gui_hover", "on_hover"}},
	[defines.events.on_gui_leave                  ] = {suffix = {"_leave"    }, field={"on_gui_leave", "on_leave"}},
}

local function get_view_and_handler_name(e)
	local view_name = e.element.tags.context_view_name or e.element.tags.view_name or ""

	local dic = guess_handler_name_dic[e.name]
	local handler =
		e.element.tags[dic.field[1]] or
		e.element.tags[dic.field[2]] or
		e.element.tags[dic.field[3]]

	if handler then
		local v, f = string.match(handler, "^(.-)%.(.-)$")
		if v and f then view_name = v; handler = f end
	end
	return view_name, handler
end

local function get_handler_name(e)
	local dic = guess_handler_name_dic[e.name]
	local handler_name =
		e.element.tags[dic.field[1]] or
		e.element.tags[dic.field[2]] or
		e.element.tags[dic.field[3]] or
		e.element.name..dic.suffix[1]
	return handler_name
end

local function on_gui_event(e)
	--local player = game.players[e.player_index]
	if not e.element or not e.element.valid then return end
	if e.element.tags.mod_name ~= script.mod_name then return end
	local view, handler_name = get_view_and_handler_name(e)
	if not view then return end

	local view_handler = view_handler[view]
	if not view_handler then return end

	local is_generic = false
	if not handler_name then -- generic handler name
		handler_name = e.element.name..guess_handler_name_dic[e.name].suffix[1]
		if not handler_name then return end
		is_generic = true
	end
	local handler_fnc = view_handler[handler_name]
	if not handler_fnc then
		if not is_generic then
			dprintf("No event handler found for %s in %s", handler_name, safeget(e,"element.tags.view_name"))
		end
		return
	end

---@diagnostic disable-next-line: undefined-global
	e.player_context = getPlayerContextBase(e.player_index)
	e.plx = e.player_context --short alias (deprecated)

	if e.name == defines.events.on_gui_click then
		---@cast e KuxGuiLib.EventData.on_gui_click
		e.left = e.button == defines.mouse_button_type.left
		e.right = e.button == defines.mouse_button_type.right
		e.middle = e.button == defines.mouse_button_type.middle

		e.left_only       = e.left   and not (e.shift or e.control or e.alt)
		e.left_shift      = e.left   and e.shift and not (e.control or e.alt)
		e.left_control    = e.left   and e.control and not (e.shift or e.alt)
		e.left_alt        = e.left   and e.alt and not (e.shift or e.control)
		e.right_only      = e.right  and not (e.shift or e.control or e.alt)
		e.right_shift     = e.right  and e.shift and not (e.control or e.alt)
		e.right_control   = e.right  and e.control and not (e.shift or e.alt)
		e.right_alt       = e.right  and e.alt and not (e.shift or e.control)
		e.middle_only     = e.middle and not (e.shift or e.control or e.alt)
		e.middle_shift    = e.middle and e.shift and not (e.control or e.alt)
		e.middle_control  = e.middle and e.control and not (e.shift or e.alt)
		e.middle_alt      = e.middle and e.alt and not (e.shift or e.control)

		if e.element.type == "choose-elem-button" then
			e.elem_value = e.element.elem_value ---@diagnostic disable-line: assign-type-mismatch
			e.elem_type = e.element.elem_type
		end
	end


	e.on_error = {}

	currentEvent = e
	if false and mods["debugadapter"] then handler_fnc(e)
	else
		local success, result = xpcall(handler_fnc,function(err) return {err=err, trace=debug.traceback(2)} end, e)
		if not success and result.err:match("__ABORT_BY_USER__") then error(format_abort(e)) end
		if not success then handle_error(result) end
	end
	lastEvent = currentEvent
	currentEvent = nil
end

--use discrete names for a better stack trace:

local function on_gui_click(e)                   on_gui_event(e) end
local function on_gui_elem_changed(e)            on_gui_event(e) end
local function on_gui_checked_state_changed(e)   on_gui_event(e) end
local function on_gui_selection_state_changed(e) on_gui_event(e) end
local function on_gui_text_changed(e)            on_gui_event(e) end
local function on_gui_value_changed(e)           on_gui_event(e) end
local function on_gui_location_changed(e)        on_gui_event(e) end
local function on_gui_confirmed(e)               on_gui_event(e) end
local function on_gui_opened(e)                  on_gui_event(e) end
local function on_gui_closed(e)                  on_gui_event(e) end
local function on_gui_selected_tab_changed(e)    on_gui_event(e) end
local function on_gui_switch_state_changed(e)    on_gui_event(e) end
local function on_gui_hover(e)                   on_gui_event(e) end
local function on_gui_leave(e)                   on_gui_event(e) end

Events.on_event(defines.events.on_gui_click, function (e) on_gui_click(e) end)
Events.on_event(defines.events.on_gui_elem_changed, function (e) on_gui_elem_changed(e) end)
Events.on_event(defines.events.on_gui_checked_state_changed, function (e) on_gui_checked_state_changed(e) end)
Events.on_event(defines.events.on_gui_selection_state_changed, function (e) on_gui_selection_state_changed(e) end)
Events.on_event(defines.events.on_gui_text_changed, function (e) on_gui_text_changed(e) end)
Events.on_event(defines.events.on_gui_value_changed, function (e) on_gui_value_changed(e) end)
Events.on_event(defines.events.on_gui_location_changed, function (e) on_gui_location_changed(e) end)
Events.on_event(defines.events.on_gui_confirmed, function (e) on_gui_confirmed(e) end)
Events.on_event(defines.events.on_gui_opened, function (e) on_gui_opened(e) end)
Events.on_event(defines.events.on_gui_closed, function (e) on_gui_closed(e) end)
Events.on_event(defines.events.on_gui_selected_tab_changed, function (e) on_gui_selected_tab_changed(e) end)
Events.on_event(defines.events.on_gui_switch_state_changed, function (e) on_gui_switch_state_changed(e) end)
Events.on_event(defines.events.on_gui_hover, function (e) on_gui_hover(e) end)
Events.on_event(defines.events.on_gui_leave, function (e) on_gui_leave(e) end)

--[ finalize ] --------------------------------------------------------------------------------------------------------

KuxCoreLib.__classUtils.finalize(GuiEventDistributor)
return GuiEventDistributor

-----------------------------------------------------------------------------------------------------------------------
-- #region meta
-----------------------------------------------------------------------------------------------------------------------


---@class KuxGuiLib.EventData.on_gui_click : EventData.on_gui_click
--        ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext deprecated
---@field player_context KuxGuiLib.PlayerContext
---@field left boolean
---@field left_only boolean
---@field left_shift boolean
---@field left_control boolean
---@field left_alt boolean
---@field right boolean
---@field right_only boolean
---@field right_shift boolean
---@field right_control boolean
---@field right_alt boolean
---@field middle boolean
---@field middle_only boolean
---@field middle_shift boolean
---@field middle_control boolean
---@field middle_alt boolean
---@field elem_value string?
---@field elem_type string?
---@field elemId ElemID?


---@class KuxGuiLib.EventData.on_gui_text_changed : EventData.on_gui_text_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_checked_state_changed : EventData.on_gui_checked_state_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_selection_state_changed : EventData.on_gui_selection_state_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_elem_changed : EventData.on_gui_elem_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
--- @field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_value_changed : EventData.on_gui_value_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_location_changed : EventData.on_gui_location_changed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
--- @field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_confirmed : EventData.on_gui_confirmed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_opened : EventData.on_gui_opened
---	      ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext


---@class KuxGuiLib.EventData.on_gui_closed : EventData.on_gui_closed
---       ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
---@field plx KuxGuiLib.PlayerContext







