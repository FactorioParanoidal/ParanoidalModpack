local gui = require("__flib__/gui")
local math = require("__flib__/math")

local constants = require("__QuickItemSearch__/constants")
local cursor = require("__QuickItemSearch__/scripts/cursor")
local search = require("__QuickItemSearch__/scripts/search")

local infinity_filter_gui = require("__QuickItemSearch__/scripts/gui/infinity-filter")
local logistic_request_gui = require("__QuickItemSearch__/scripts/gui/logistic-request")

local search_gui = {}

function search_gui.build(player, player_table)
  -- At some point it's possible for the player table to get out of sync... somehow.
  local orphaned_dimmer = player.gui.screen.qis_window_dimmer
  if orphaned_dimmer and orphaned_dimmer.valid then
    orphaned_dimmer.destroy()
  end
  local orphaned_window = player.gui.screen.qis_search_window
  if orphaned_window and orphaned_window.valid then
    orphaned_window.destroy()
  end
  search_gui.destroy(player_table)

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      style = "qis_window_dimmer",
      style_mods = { size = { 448, 390 } },
      visible = false,
      ref = { "window_dimmer" },
    },
    {
      type = "frame",
      name = "qis_search_window",
      direction = "vertical",
      visible = false,
      ref = { "window" },
      actions = {
        on_closed = { gui = "search", action = "close" },
        on_location_changed = { gui = "search", action = "update_dimmer_location" },
      },
      children = {
        {
          type = "flow",
          style = "flib_titlebar_flow",
          ref = { "titlebar_flow" },
          actions = {
            on_click = { gui = "search", action = "recenter" },
          },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = { "mod-name.QuickItemSearch" },
              ignored_by_interaction = true,
            },
            { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
            {
              type = "sprite-button",
              style = "frame_action_button",
              sprite = "utility/close_white",
              hovered_sprite = "utility/close_black",
              clicked_sprite = "utility/close_black",
              actions = {
                on_click = { gui = "search", action = "close" },
              },
            },
          },
        },
        {
          type = "frame",
          style = "inside_shallow_frame_with_padding",
          style_mods = { top_padding = -2 },
          direction = "vertical",
          children = {
            {
              type = "textfield",
              style = "qis_disablable_textfield",
              style_mods = { width = 400, top_margin = 9 },
              clear_and_focus_on_right_click = true,
              lose_focus_on_confirm = true,
              ref = { "search_textfield" },
              actions = {
                on_confirmed = { gui = "search", action = "enter_result_selection" },
                on_text_changed = { gui = "search", action = "update_search_query" },
              },
            },
            {
              type = "frame",
              style = "deep_frame_in_shallow_frame",
              style_mods = { top_margin = 10, height = 28 * 10 },
              direction = "vertical",
              children = {
                {
                  type = "frame",
                  style = "negative_subheader_frame",
                  style_mods = { left_padding = 12, height = 28, horizontally_stretchable = true },
                  visible = false,
                  ref = { "warning_subheader" },
                  children = {
                    {
                      type = "label",
                      style = "bold_label",
                      caption = {
                        "",
                        "[img=utility/warning_white]  ",
                        { "gui.qis-not-connected-to-logistic-network" },
                      },
                    },
                  },
                },
                {
                  type = "scroll-pane",
                  style = "qis_list_box_scroll_pane",
                  style_mods = { vertically_stretchable = true, bottom_padding = 2 },
                  ref = { "results_scroll_pane" },
                  children = {
                    {
                      type = "table",
                      style = "qis_list_box_table",
                      column_count = 3,
                      ref = { "results_table" },
                      children = {
                        -- dummy elements for the borked first row
                        { type = "empty-widget" },
                        { type = "empty-widget" },
                        { type = "empty-widget" },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
    },
  })

  refs.window.force_auto_center()
  refs.titlebar_flow.drag_target = refs.window

  player_table.guis.search = {
    refs = refs,
    state = {
      last_search_update = game.ticks_played,
      query = "",
      raw_query = "",
      selected_index = 1,
      subwindow_open = false,
      visible = false,
    },
  }
end

function search_gui.destroy(player_table)
  local gui_data = player_table.guis.search
  if not gui_data then
    return
  end
  if not gui_data.window or not gui_data.window.valid then
    return
  end
  gui_data.window.valid.destroy()
  player_table.guis.search = nil
end

function search_gui.open(player, player_table)
  local gui_data = player_table.guis.search
  gui_data.refs.window.visible = true
  gui_data.state.visible = true
  player.set_shortcut_toggled("qis-search", true)
  player.opened = gui_data.refs.window

  gui_data.refs.search_textfield.focus()
  gui_data.refs.search_textfield.select_all()

  -- update the table right away
  search_gui.perform_search(player, player_table)

  global.update_search_results[player.index] = true
end

function search_gui.close(player, player_table, force_close)
  local gui_data = player_table.guis.search
  local refs = gui_data.refs
  local state = gui_data.state

  if not force_close and state.selected_item_tick == game.ticks_played then
    player.opened = refs.window
  elseif force_close or not state.subwindow_open then
    refs.window.visible = false
    state.visible = false
    player.set_shortcut_toggled("qis-search", false)
    if player.opened == refs.window then
      player.opened = nil
    end
  end
  global.update_search_results[player.index] = nil
end

function search_gui.toggle(player, player_table, force_open)
  local gui_data = player_table.guis.search
  if not gui_data then
    return
  end
  if gui_data.state.visible then
    search_gui.close(player, player_table)
  elseif force_open or player.opened_gui_type and player.opened_gui_type == defines.gui_type.none then
    search_gui.open(player, player_table)
  end
end

function search_gui.reopen_after_subwindow(e)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.search

  if gui_data then
    local refs = gui_data.refs
    local state = gui_data.state

    refs.search_textfield.enabled = true
    refs.window_dimmer.visible = false
    state.subwindow_open = false

    search_gui.perform_search(player, player_table)

    if player_table.settings.auto_close and player_table.confirmed_tick == game.ticks_played then
      search_gui.close(player, player_table)
    else
      player.opened = gui_data.refs.window
    end

    global.update_search_results[player.index] = true
  end
end

function search_gui.perform_search(player, player_table, updated_query, combined_contents)
  local gui_data = player_table.guis.search
  local refs = gui_data.refs
  local state = gui_data.state

  state.last_search_update = game.ticks_played

  local query = string.lower(state.query)
  local results_table = refs.results_table
  local children = results_table.children

  -- deselect highlighted entry
  if updated_query and #results_table.children > 3 then
    results_table.children[state.selected_index * 3 + 1].style.font_color = constants.colors.normal
    refs.results_scroll_pane.scroll_to_top()
    -- reset selected index
    state.selected_index = 1
  end

  local result_tooltip = {
    "",
    { "gui.qis-result-click-tooltip" },
    "\n",
    { "gui.qis-shift-click" },
    " ",
    (player.controller_type == defines.controllers.character and { "gui.qis-edit-logistic-request" } or {
      "gui.qis-edit-infinity-filter",
    }),
  }

  if #state.raw_query > 1 then
    local i = 0
    local results, connected_to_network, logistic_requests_available =
      search.run(player, player_table, query, combined_contents)
    for _, row in ipairs(results) do
      i = i + 1
      local i3 = i * 3

      -- build row if nonexistent
      if not results_table.children[i3 + 1] then
        gui.build(results_table, {
          {
            type = "label",
            style = "qis_clickable_item_label",
            actions = {
              on_click = { gui = "search", action = "select_item", index = i },
            },
          },
          { type = "label" },
          { type = "label" },
        })
        -- update our copy of the table
        children = results_table.children
      end

      -- item label
      local item_label = children[i3 + 1]
      local hidden_abbrev = row.hidden and "[font=default-semibold](H)[/font]  " or ""
      item_label.caption = hidden_abbrev .. "[item=" .. row.name .. "]  " .. row.translation
      item_label.tooltip = result_tooltip
      -- item counts
      if player.controller_type == defines.controllers.character and connected_to_network then
        children[i3 + 2].caption = (
          (row.inventory or 0)
          .. " / [color="
          .. constants.colors.logistic_str
          .. "]"
          .. (row.logistic or 0)
          .. "[/color]"
        )
      else
        children[i3 + 2].caption = (row.inventory or 0)
      end
      -- request / infinity filter
      local request_label = children[i3 + 3]
      if player.controller_type == defines.controllers.editor then
        local filter = row.infinity_filter
        if filter then
          request_label.caption = constants.infinity_filter_mode_to_symbol[filter.mode] .. " " .. filter.count
        else
          request_label.caption = "--"
        end
      else
        if logistic_requests_available then
          local request = row.request
          if request then
            local max = request.max
            if max == math.max_uint then
              max = constants.infinity_rep
            end
            request_label.caption = request.min .. " / " .. max
            if request.is_temporary then
              request_label.caption = "(T) " .. request_label.caption
            end
            request_label.style.font_color = constants.colors[row.request_color or "normal"]
          else
            request_label.caption = "--"
            request_label.style.font_color = constants.colors.normal
          end
        else
          request_label.caption = ""
        end
      end
    end
    -- destroy extraneous rows
    for j = #results_table.children, ((i + 1) * 3) + 1, -1 do
      results_table.children[j].destroy()
    end
    -- show or hide warning
    if
      logistic_requests_available
      and player.controller_type == defines.controllers.character
      and not connected_to_network
    then
      refs.warning_subheader.visible = true
    else
      refs.warning_subheader.visible = false
    end
    if
      player.controller_type == defines.controllers.god
      or (player.controller_type == defines.controllers.character and not logistic_requests_available)
    then
      results_table.style.right_margin = -15
    else
      results_table.style.right_margin = 0
    end
    -- add to state
    state.results = results
    -- clear table if it has contents
  elseif #results_table.children > 3 then
    -- clear results
    results_table.clear()
    state.results = {}
    -- add new dummy elements
    for _ = 1, 3 do
      results_table.add({ type = "empty-widget" })
    end
  end
end

function search_gui.select_item(player, player_table, modifiers, index)
  local gui_data = player_table.guis.search
  local refs = gui_data.refs
  local state = gui_data.state

  local i = index or state.selected_index
  local results = state.results
  if not results then
    return
  end

  local result = state.results[i]
  if not result then
    return
  end
  if modifiers.shift then
    local player_controller = player.controller_type
    if player_controller == defines.controllers.editor or player_controller == defines.controllers.character then
      state.subwindow_open = true
      refs.search_textfield.enabled = false
      refs.window_dimmer.visible = true
      refs.window_dimmer.bring_to_front()

      if player_controller == defines.controllers.editor then
        infinity_filter_gui.open(player, player_table, result)
      elseif player_controller == defines.controllers.character then
        logistic_request_gui.open(player, player_table, result)
      end

      player.play_sound({ path = "utility/confirm" })
    else
      player.play_sound({ path = "utility/cannot_build" })
    end
  else
    -- make sure we're not already holding this item
    local cursor_stack = player.cursor_stack
    if cursor_stack and cursor_stack.valid_for_read and cursor_stack.name == result.name then
      player.play_sound({ path = "utility/cannot_build" })
      player.create_local_flying_text({ text = { "message.qis-already-holding-item" }, create_at_cursor = true })
    else
      -- Close the window after selection if desired
      if player_table.settings.auto_close then
        search_gui.close(player, player_table, true)
        -- Or prevent the window from closing
      else
        state.selected_item_tick = game.ticks_played
      end
      cursor.set_stack(player, player.cursor_stack, player_table, result.name)
      player.play_sound({ path = "utility/confirm" })
    end
  end
end

function search_gui.update_for_active_players()
  local tick = game.ticks_played
  for player_index in pairs(global.update_search_results) do
    local player = game.get_player(player_index)
    local player_table = global.players[player_index]
    local gui_data = player_table.guis.search
    if gui_data then
      local state = gui_data.state
      if tick - state.last_search_update > 120 then
        search_gui.perform_search(player, player_table)
      end
    end
  end
end

function search_gui.handle_action(e, msg)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.search
  local refs = gui_data.refs
  local state = gui_data.state

  if msg.action == "close" then
    search_gui.close(player, player_table)
  elseif msg.action == "recenter" and e.button == defines.mouse_button_type.middle then
    refs.window.force_auto_center()
  elseif msg.action == "update_search_query" then
    local query = e.text
    -- fuzzy search
    if player_table.settings.fuzzy_search then
      query = string.gsub(query, ".", "%1.*")
    end
    -- input sanitization
    for pattern, replacement in pairs(constants.input_sanitizers) do
      query = string.gsub(query, pattern, replacement)
    end
    state.query = query
    state.raw_query = e.text
    search_gui.perform_search(player, player_table, true)
  elseif msg.action == "perform_search" then
    -- perform search without updating query
    search_gui.perform_search(player, player_table)
  elseif msg.action == "enter_result_selection" then
    if #refs.results_table.children == 3 then
      refs.search_textfield.focus()
      return
    else
      refs.results_scroll_pane.focus()
    end
    if state.selected_index > ((#refs.results_table.children - 3) / 3) then
      state.selected_index = 1
    end
    local results_table = refs.results_table
    results_table.children[state.selected_index * 3 + 1].style.font_color = constants.colors.hovered
  elseif msg.action == "update_selected_index" then
    local results_table = refs.results_table
    local selected_index = state.selected_index
    results_table.children[selected_index * 3 + 1].style.font_color = constants.colors.normal
    local new_selected_index = math.clamp(selected_index + msg.offset, 1, #results_table.children / 3 - 1)
    state.selected_index = new_selected_index
    results_table.children[new_selected_index * 3 + 1].style.font_color = constants.colors.hovered
    refs.results_scroll_pane.scroll_to_element(results_table.children[new_selected_index * 3 + 1], "top-third")
  elseif msg.action == "select_item" then
    search_gui.select_item(player, player_table, { shift = e.shift, control = e.control }, msg.index)
  elseif msg.action == "update_dimmer_location" then
    refs.window_dimmer.location = refs.window.location
  end
end

return search_gui
