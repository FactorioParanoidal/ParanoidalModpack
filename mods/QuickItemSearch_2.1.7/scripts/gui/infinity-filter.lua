local gui = require("__flib__/gui")
local math = require("__flib__/math")

local constants = require("__QuickItemSearch__/constants")
local infinity_filter = require("__QuickItemSearch__/scripts/infinity-filter")

local infinity_filter_gui = {}

function infinity_filter_gui.build(player, player_table)
  local resolution = player.display_resolution
  local scale = player.display_scale
  local focus_frame_size = { resolution.width / scale, resolution.height / scale }

  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      style = "invisible_frame",
      style_mods = { size = focus_frame_size },
      ref = { "focus_frame" },
      visible = false,
      actions = {
        on_click = { gui = "infinity_filter", action = "close", reopen_after_subwindow = true },
      },
    },
    {
      type = "frame",
      name = "qis_infinity_filter_window",
      direction = "vertical",
      visible = false,
      ref = { "window" },
      actions = {
        on_closed = { gui = "infinity_filter", action = "close", reopen_after_subwindow = true },
      },
      children = {
        {
          type = "flow",
          style = "flib_titlebar_flow",
          ref = { "titlebar_flow" },
          actions = {
            on_click = { gui = "infinity_filter", action = "recenter" },
          },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = { "gui.qis-edit-infinity-filter" },
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
                on_click = { gui = "infinity_filter", action = "close", reopen_after_subwindow = true },
              },
            },
          },
        },
        {
          type = "frame",
          style = "inside_shallow_frame",
          direction = "vertical",
          children = {
            {
              type = "frame",
              style = "subheader_frame",
              children = {
                { type = "label", style = "subheader_caption_label", ref = { "item_label" } },
                { type = "empty-widget", style = "flib_horizontal_pusher" },
              },
            },
            {
              type = "flow",
              style_mods = { vertical_align = "center", horizontal_spacing = 8, padding = 12 },
              children = {
                {
                  type = "drop-down",
                  style_mods = { width = 60 },
                  items = { "≥", "≤", "=" },
                  selected_index = 3,
                  ref = { "filter_setter", "dropdown" },
                  actions = {
                    on_selection_state_changed = { gui = "infinity_filter", action = "change_filter_mode" },
                  },
                },
                {
                  type = "slider",
                  style = "notched_slider",
                  style_mods = { horizontally_stretchable = true },
                  minimum_value = 0,
                  maximum_value = 500,
                  value_step = 50,
                  value = 500,
                  discrete_slider = true,
                  discrete_values = true,
                  ref = { "filter_setter", "slider" },
                  actions = {
                    on_value_changed = {
                      gui = "infinity_filter",
                      action = "update_filter",
                      elem = "slider",
                    },
                  },
                },
                {
                  type = "textfield",
                  style = "slider_value_textfield",
                  numeric = true,
                  ref = { "filter_setter", "textfield" },
                  actions = {
                    on_text_changed = { gui = "infinity_filter", action = "update_filter", elem = "textfield" },
                  },
                },
                {
                  type = "sprite-button",
                  style = "item_and_count_select_confirm",
                  sprite = "utility/check_mark",
                  tooltip = { "", { "gui.qis-set-infinity-filter" }, { "gui.qis-confirm" } },
                  actions = {
                    on_click = { gui = "infinity_filter", action = "set_filter" },
                  },
                },
                {
                  type = "sprite-button",
                  style = "flib_tool_button_light_green",
                  style_mods = { top_margin = 1 },
                  sprite = "qis_temporary_request",
                  tooltip = { "", { "gui.qis-set-temporary-infinity-filter" }, { "gui.qis-shift-confirm" } },
                  actions = {
                    on_click = { gui = "infinity_filter", action = "set_filter", temporary = true },
                  },
                },
                {
                  type = "sprite-button",
                  style = "tool_button_red",
                  style_mods = { top_margin = 1 },
                  sprite = "utility/trash",
                  tooltip = { "", { "gui.qis-clear-infinity-filter" }, { "gui.qis-control-confirm" } },
                  actions = {
                    on_click = { gui = "infinity_filter", action = "clear_filter" },
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

  player_table.guis.infinity_filter = {
    refs = refs,
    state = {
      item_data = nil,
      visible = false,
    },
  }
end

function infinity_filter_gui.destroy(player_table)
  player_table.guis.infinity_filter.refs.window.destroy()
  player_table.guis.infinity_filter = nil
end

function infinity_filter_gui.open(player, player_table, item_data)
  local gui_data = player_table.guis.infinity_filter
  local refs = gui_data.refs
  local state = gui_data.state

  -- update state
  local stack_size = game.item_prototypes[item_data.name].stack_size
  item_data.stack_size = stack_size
  state.item_data = item_data
  local infinity_filter_data = item_data.infinity_filter or { mode = "at-least", count = stack_size }
  infinity_filter_data.name = item_data.name
  state.infinity_filter = infinity_filter_data
  state.visible = true

  -- update item label
  refs.item_label.caption = "[item=" .. item_data.name .. "]  " .. item_data.translation

  -- update filter setter
  local filter_setter = refs.filter_setter
  filter_setter.dropdown.selected_index = constants.infinity_filter_mode_to_index[infinity_filter_data.mode]
  filter_setter.slider.set_slider_value_step(1)
  filter_setter.slider.set_slider_minimum_maximum(0, stack_size * 10)
  filter_setter.slider.set_slider_value_step(stack_size)
  filter_setter.slider.slider_value = math.round(infinity_filter_data.count, stack_size)
  filter_setter.textfield.text = tostring(infinity_filter_data.count)
  filter_setter.textfield.select_all()
  filter_setter.textfield.focus()

  -- update window
  refs.focus_frame.visible = true
  refs.focus_frame.bring_to_front()
  refs.window.visible = true
  refs.window.bring_to_front()

  -- set opened
  player.opened = refs.window
end

function infinity_filter_gui.close(player, player_table)
  local gui_data = player_table.guis.infinity_filter
  gui_data.state.visible = false
  gui_data.refs.focus_frame.visible = false
  gui_data.refs.window.visible = false
  if not player.opened then
    player.opened = player_table.guis.search.refs.window
  end
end

function infinity_filter_gui.set_filter(player, player_table, is_temporary)
  player.play_sound({ path = "utility/confirm" })
  infinity_filter.set(player, player_table, player_table.guis.infinity_filter.state.infinity_filter, is_temporary)
  if is_temporary then
    player.opened = nil
  end
end

function infinity_filter_gui.clear_filter(player, player_table)
  player.play_sound({ path = "utility/confirm" })
  infinity_filter.clear(player, player_table, player_table.guis.infinity_filter.state.infinity_filter.name)
  player.opened = nil
end

function infinity_filter_gui.cycle_filter_mode(gui_data)
  local refs = gui_data.refs
  local state = gui_data.state

  state.infinity_filter.mode = (
      next(constants.infinity_filter_modes, state.infinity_filter.mode) or next(constants.infinity_filter_modes)
    )

  refs.filter_setter.dropdown.selected_index = constants.infinity_filter_mode_to_index[state.infinity_filter.mode]
end

function infinity_filter_gui.handle_action(e, msg)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.infinity_filter
  local refs = gui_data.refs
  local state = gui_data.state

  local item_data = state.item_data
  local filter_data = state.infinity_filter

  if msg.action == "close" then
    infinity_filter_gui.close(player, player_table)
  elseif msg.action == "change_filter_mode" then
    local new_mode = constants.infinity_filter_modes_by_index[e.element.selected_index]
    state.infinity_filter.mode = new_mode
  elseif msg.action == "update_filter" then
    if msg.elem == "slider" then
      local count = e.element.slider_value
      filter_data.count = count
      refs.filter_setter.textfield.text = tostring(count)
    else
      local count = tonumber(e.element.text) or 0
      filter_data.count = count
      refs.filter_setter.slider.slider_value = math.round(count, item_data.stack_size)
    end
  elseif msg.action == "clear_filter" then
    infinity_filter.clear(player, player_table, filter_data.name)
    -- invoke `on_gui_closed` so the search GUI will be refocused
    player.opened = nil
  elseif msg.action == "set_filter" then
    -- HACK: Makes it easy for the search GUI to tell that this was confirmed
    player_table.confirmed_tick = game.ticks_played
    infinity_filter.set(player, player_table, filter_data, msg.temporary)
    -- invoke `on_gui_closed` so the search GUI will be refocused
    player.opened = nil
  end
end

return infinity_filter_gui
