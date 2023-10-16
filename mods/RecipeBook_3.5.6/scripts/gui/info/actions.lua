local math = require("__flib__.math")
local on_tick_n = require("__flib__.on-tick-n")

local constants = require("constants")

local database = require("scripts.database")
local gui_util = require("scripts.gui.util")
local util = require("scripts.util")

local actions = {}

--- @param Gui InfoGui
function actions.set_as_active(Gui, _, _)
  Gui.player_table.guis.info._active_id = Gui.id
end

--- @param Gui InfoGui
--- @param e on_gui_click
function actions.reset_location(Gui, _, e)
  if e.button == defines.mouse_button_type.middle then
    Gui.refs.root.force_auto_center()
  end
end

--- @param Gui InfoGui
function actions.close(Gui, _, _)
  Gui:destroy()
end

--- @param Gui InfoGui
function actions.bring_to_front(Gui, _, _)
  if not Gui.state.docked then
    Gui.refs.root.bring_to_front()
  end
end

--- @param Gui InfoGui
function actions.toggle_search(Gui, _, _)
  local state = Gui.state
  local refs = Gui.refs

  local opened = state.search_opened
  state.search_opened = not opened

  local search_button = refs.titlebar.search_button
  local search_textfield = refs.titlebar.search_textfield
  if opened then
    search_button.sprite = "utility/search_white"
    search_button.style = "frame_action_button"
    search_textfield.visible = false

    if state.search_query ~= "" then
      -- Reset query
      search_textfield.text = ""
      state.search_query = ""
      -- Refresh page
      Gui:update_contents()
    end
  else
    -- Show search textfield
    search_button.sprite = "utility/search_black"
    search_button.style = "flib_selected_frame_action_button"
    search_textfield.visible = true
    search_textfield.focus()
  end
end

--- @param Gui InfoGui
--- @param msg table
--- @param e on_gui_click
function actions.navigate(Gui, msg, e)
  -- Update position in history
  local delta = msg.delta
  local history = Gui.state.history
  if e.shift then
    if delta < 0 then
      history._index = 1
    else
      history._index = #history
    end
  else
    history._index = math.clamp(history._index + delta, 1, #history)
  end
  Gui:update_contents()
end

--- @param Gui InfoGui
--- @param msg table
--- @param e on_gui_text_changed
function actions.update_search_query(Gui, msg, e)
  local state = Gui.state
  local id = msg.id

  local query = string.lower(e.element.text)
  -- Fuzzy search
  if Gui.player_table.settings.general.search.fuzzy_search then
    query = string.gsub(query, ".", "%1.*")
  end
  -- Input sanitization
  for pattern, replacement in pairs(constants.input_sanitizers) do
    query = string.gsub(query, pattern, replacement)
  end
  -- Save query
  state.search_query = query

  -- Remove scheduled update if one exists
  if state.update_results_ident then
    on_tick_n.remove(state.update_results_ident)
    state.update_results_ident = nil
  end

  if query == "" then
    -- Update now
    Gui:update_contents({ refresh = true })
  else
    -- Update in a while
    state.update_results_ident = on_tick_n.add(
      game.tick + constants.search_timeout,
      { gui = "info", id = id, action = "update_search_results", player_index = e.player_index }
    )
  end
end

--- @param Gui InfoGui
function actions.update_search_results(Gui, _, _)
  -- Update based on query
  Gui:update_contents({ refresh = true })
end

--- @param Gui InfoGui
--- @param e on_gui_click
function actions.navigate_to(Gui, _, e)
  local context = gui_util.navigate_to(e)
  if context then
    if e.button == defines.mouse_button_type.middle then
      INFO_GUI.build(Gui.player, Gui.player_table, context)
    else
      Gui:update_contents({ new_context = context })
    end
  end
end

--- @param Gui InfoGui
--- @param msg table
function actions.navigate_to_plain(Gui, msg, _)
  Gui:update_contents({ new_context = msg.context })
end

--- @param Gui InfoGui
function actions.open_in_tech_window(Gui, _, _)
  Gui.player_table.flags.technology_gui_open = true
  Gui.player.open_technology_gui(Gui:get_context().name)
end

--- @param Gui InfoGui
function actions.go_to_base_fluid(Gui, _, _)
  local base_fluid = database.fluid[Gui:get_context().name].prototype_name
  Gui:update_contents({ new_context = { class = "fluid", name = base_fluid } })
end

--- @param Gui InfoGui
function actions.toggle_quick_ref(Gui, _, _)
  local player = Gui.player
  -- Toggle quick ref GUI
  local name = Gui:get_context().name
  --- @type QuickRefGui?
  local QuickRefGui = util.get_gui(player.index, "quick_ref", name)
  local to_state = false
  if QuickRefGui then
    QuickRefGui:destroy()
  else
    to_state = true
    QUICK_REF_GUI.build(player, Gui.player_table, name)
  end
  -- Update all quick ref buttons
  for _, InfoGui in pairs(INFO_GUI.find_open_context(Gui.player_table, Gui:get_context())) do
    InfoGui:dispatch({
      action = "update_header_button",
      button = "quick_ref_button",
      to_state = to_state,
    })
  end
end

--- @param Gui InfoGui
function actions.toggle_favorite(Gui, _, _)
  local player_table = Gui.player_table
  local favorites = player_table.favorites
  local context = Gui:get_context()
  local combined_name = context.class .. "." .. context.name
  local to_state
  if favorites[combined_name] then
    to_state = false
    favorites[combined_name] = nil
  else
    -- Copy the table instead of passing a reference
    favorites[combined_name] = { class = context.class, name = context.name }
    to_state = true
  end
  for _, InfoGui in pairs(INFO_GUI.find_open_context(Gui.player_table, context)) do
    InfoGui:dispatch({ action = "update_header_button", button = "favorite_button", to_state = to_state })
  end
  local SearchGui = util.get_gui(Gui.player.index, "search")
  if SearchGui and SearchGui.refs.window.visible then
    SearchGui:dispatch("update_favorites")
  end
end

--- @param Gui InfoGui
--- @param msg table
function actions.update_header_button(Gui, msg, _)
  local button = Gui.refs.header[msg.button]
  if msg.to_state then
    button.style = "flib_selected_tool_button"
    button.tooltip = constants.header_button_tooltips[msg.button].selected
  else
    button.style = "tool_button"
    button.tooltip = constants.header_button_tooltips[msg.button].unselected
  end
end

--- @param Gui InfoGui
--- @param msg table
function actions.open_list(Gui, msg, _)
  local list_context = msg.context
  local source = msg.source
  local list = database[list_context.class][list_context.name][source]
  if list and #list > 0 then
    local first_obj = list[1]
    OPEN_PAGE(Gui.player, Gui.player_table, {
      class = first_obj.class,
      name = first_obj.name,
      list = {
        context = list_context,
        index = 1,
        source = source,
      },
    })
  end
end

--- @param Gui InfoGui
--- @param msg table
function actions.toggle_collapsed(Gui, msg, _)
  local context = msg.context
  local component_index = msg.component_index
  local component_ident = constants.pages[context.class][component_index]
  if component_ident then
    local state = Gui.state.components[component_index]
    if state then
      state.collapsed = not state.collapsed
      Gui:update_contents({ refresh = true })
    end
  end
end

--- @param Gui InfoGui
--- @param msg table
function actions.change_tech_level(Gui, msg, _)
  local context = Gui:get_context()
  local state = Gui.state

  local context_data = database[context.class][context.name]
  local min = context_data.min_level
  local max = context_data.max_level
  local new_level = math.clamp(state.selected_tech_level + msg.delta, min, max)
  if new_level ~= state.selected_tech_level then
    state.selected_tech_level = new_level
    Gui:update_contents({ refresh = true })
  end
end

--- @param Gui InfoGui
function actions.detach_window(Gui, _, _)
  local state = Gui.state
  -- Just in case
  if not state.docked then
    return
  end

  local context = Gui:get_context()

  -- Close this GUI and create a detached one
  Gui:destroy()
  OPEN_PAGE(Gui.player, Gui.player_table, context)
end

--- @param Gui InfoGui
function actions.print_object(Gui, _, _)
  local context = Gui:get_context()
  local obj_data = database[context.class][context.name]

  if obj_data then
    if __DebugAdapter then
      __DebugAdapter.print(obj_data)
      Gui.player.print("Object data has been printed to the debug console.")
    else
      log(serpent.block(obj_data))
      Gui.player.print("Object data has been printed to the log file.")
    end
  end
end

return actions
