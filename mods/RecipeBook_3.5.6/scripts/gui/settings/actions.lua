local on_tick_n = require("__flib__.on-tick-n")

local constants = require("constants")
local util = require("scripts.util")

local actions = {}

--- @param Gui SettingsGui
function actions.close(Gui, _, _)
  Gui:destroy()
  local SearchGui = util.get_gui(Gui.player.index, "search")
  if SearchGui then
    SearchGui:dispatch("deselect_settings_button")
  end
end

--- @param Gui SettingsGui
--- @param e on_gui_click
function actions.reset_location(Gui, _, e)
  if e.button == defines.mouse_button_type.middle then
    Gui.refs.window.force_auto_center()
  end
end

--- @param Gui SettingsGui
function actions.toggle_search(Gui, _, _)
  local state = Gui.state
  local refs = Gui.refs

  local opened = state.search_opened
  state.search_opened = not opened

  local search_button = refs.titlebar.search_button
  local search_textfield = refs.titlebar.search_textfield
  if opened then
    search_button.style = "frame_action_button"
    search_button.sprite = "utility/search_white"
    search_textfield.visible = false

    if state.search_query ~= "" then
      -- Reset query
      search_textfield.text = ""
      state.search_query = ""
      -- Immediately refresh page
      Gui:update_contents()
    end
  else
    -- Show search textfield
    search_button.style = "flib_selected_frame_action_button"
    search_button.sprite = "utility/search_black"
    search_textfield.visible = true
    search_textfield.focus()
  end
end

--- @param Gui SettingsGui
--- @param e on_gui_text_changed
function actions.update_search_query(Gui, _, e)
  local player_table = Gui.player_table
  local state = Gui.state

  local query = string.lower(e.element.text)
  -- Fuzzy search
  if player_table.settings.general.search.fuzzy_search then
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
    actions.update_search_results(Gui)
  else
    -- Update in a while
    state.update_results_ident = on_tick_n.add(
      game.tick + constants.search_timeout,
      { gui = "settings", action = "update_search_results", player_index = e.player_index }
    )
  end
end

--- @param Gui SettingsGui
function actions.update_search_results(Gui, _, _)
  Gui:update_contents()
end

--- @param Gui SettingsGui
--- @param msg table
--- @param e on_gui_checked_state_changed|on_gui_selection_state_changed
function actions.change_general_setting(Gui, msg, e)
  local type = msg.type
  local category = msg.category
  local name = msg.name
  local setting_ident = constants.general_settings[category][name]
  local settings = Gui.player_table.settings.general[category]

  local new_value
  local element = e.element

  -- NOTE: This shouldn't ever happen, but we will avoid a crash just in case!
  if not element.valid then
    return
  end

  if type == "bool" then
    new_value = element.state
  elseif type == "enum" then
    local selected_index = element.selected_index
    new_value = setting_ident.options[selected_index]
  end

  -- NOTE: This _also_ shouldn't ever happen, but you can't be too safe!
  if new_value ~= nil then
    settings[name] = new_value
    REFRESH_CONTENTS(Gui.player, Gui.player_table)
    -- Update enabled statuses
    Gui:update_contents("general")
  end
end

--- @param Gui SettingsGui
--- @param e on_gui_selection_state_changed
function actions.change_category(Gui, _, e)
  Gui.state.selected_category = e.element.selected_index
  Gui:update_contents("categories")
end

--- @param Gui SettingsGui
--- @param msg table
--- @param e on_gui_checked_state_changed
function actions.change_category_setting(Gui, msg, e)
  local class = msg.class
  local name = msg.name

  local category_settings = Gui.player_table.settings.categories[class]
  category_settings[name] = e.element.state
  REFRESH_CONTENTS(Gui.player, Gui.player_table)
end

--- @param Gui SettingsGui
--- @param e on_gui_selected_tab_changed
function actions.change_page(Gui, _, e)
  Gui.state.selected_page = e.element.selected_index
  Gui:update_contents("pages")
end

--- @param Gui SettingsGui
--- @param msg table
--- @param e on_gui_selection_state_changed
function actions.change_default_state(Gui, msg, e)
  local class = msg.class
  local component = msg.component

  local component_settings = Gui.player_table.settings.pages[class][component]
  if component_settings then
    component_settings.default_state = constants.component_states[e.element.selected_index]
  end
  REFRESH_CONTENTS(Gui.player, Gui.player_table)
end

--- @param Gui SettingsGui
--- @param msg table
--- @param e on_gui_text_changed
function actions.change_max_rows(Gui, msg, e)
  local class = msg.class
  local component = msg.component

  local component_settings = Gui.player_table.settings.pages[class][component]
  if component_settings then
    component_settings.max_rows = tonumber(e.element.text)
  end
  REFRESH_CONTENTS(Gui.player, Gui.player_table)
end

--- @param Gui SettingsGui
--- @param msg table
--- @param e on_gui_checked_state_changed
function actions.change_row_visible(Gui, msg, e)
  local class = msg.class
  local component = msg.component
  local row = msg.row

  local component_settings = Gui.player_table.settings.pages[class][component]
  if component_settings then
    component_settings.rows[row] = e.element.state
  end
  REFRESH_CONTENTS(Gui.player, Gui.player_table)
end

return actions
