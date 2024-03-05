local gui = require("__flib__/gui")
local math = require("__flib__/math")

local constants = require("__QuickItemSearch__/constants")
local logistic_request = require("__QuickItemSearch__/scripts/logistic-request")

local logistic_request_gui = {}

function logistic_request_gui.build(player, player_table)
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
        on_click = { gui = "request", action = "close", reopen_after_subwindow = true },
      },
    },
    {
      type = "frame",
      name = "qis_request_window",
      direction = "vertical",
      visible = false,
      ref = { "window" },
      actions = {
        on_closed = { gui = "request", action = "close", reopen_after_subwindow = true },
      },
      children = {
        {
          type = "flow",
          style = "flib_titlebar_flow",
          ref = { "titlebar_flow" },
          actions = {
            on_click = { gui = "request", action = "recenter" },
          },
          children = {
            {
              type = "label",
              style = "frame_title",
              caption = { "gui.qis-edit-logistic-request" },
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
                on_click = { gui = "request", action = "close", reopen_after_subwindow = true },
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
                  type = "textfield",
                  style = "slider_value_textfield",
                  numeric = true,
                  clear_and_focus_on_right_click = true,
                  text = "0",
                  tags = { bound = "min" },
                  ref = { "logistic_setter", "min", "textfield" },
                  actions = {
                    on_confirmed = { gui = "request", action = "update_request" },
                  },
                },
                {
                  type = "flow",
                  direction = "vertical",
                  children = {
                    {
                      type = "slider",
                      style = "notched_slider",
                      style_mods = { horizontally_stretchable = true },
                      minimum_value = 0,
                      maximum_value = 500,
                      value_step = 50,
                      value = 0,
                      discrete_slider = true,
                      discrete_values = true,
                      tags = { bound = "max" },
                      ref = { "logistic_setter", "max", "slider" },
                      actions = {
                        on_value_changed = { gui = "request", action = "update_request" },
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
                      tags = { bound = "min" },
                      ref = { "logistic_setter", "min", "slider" },
                      actions = {
                        on_value_changed = { gui = "request", action = "update_request" },
                      },
                    },
                  },
                },
                {
                  type = "textfield",
                  style = "slider_value_textfield",
                  numeric = true,
                  clear_and_focus_on_right_click = true,
                  text = constants.infinity_rep,
                  tags = { bound = "max" },
                  ref = { "logistic_setter", "max", "textfield" },
                  actions = {
                    on_confirmed = { gui = "request", action = "update_request" },
                  },
                },
                {
                  type = "sprite-button",
                  style = "item_and_count_select_confirm",
                  sprite = "utility/check_mark",
                  tooltip = { "", { "gui.qis-set-request" }, { "gui.qis-confirm" } },
                  ref = { "logistic_setter", "set_request_button" },
                  actions = {
                    on_click = { gui = "request", action = "set_request" },
                  },
                },
                {
                  type = "sprite-button",
                  style = "flib_tool_button_light_green",
                  style_mods = { top_margin = 1 },
                  sprite = "qis_temporary_request",
                  tooltip = { "", { "gui.qis-set-temporary-request" }, { "gui.qis-shift-confirm" } },
                  ref = { "logistic_setter", "set_temporary_request_button" },
                  actions = {
                    on_click = { gui = "request", action = "set_request", temporary = true },
                  },
                },
                {
                  type = "sprite-button",
                  style = "tool_button_red",
                  style_mods = { top_margin = 1 },
                  sprite = "utility/trash",
                  tooltip = { "", { "gui.qis-clear-request" }, { "gui.qis-control-confirm" } },
                  actions = {
                    on_click = { gui = "request", action = "clear_request" },
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

  player_table.guis.request = {
    refs = refs,
    state = {
      item_data = nil,
      visible = false,
    },
  }
end

function logistic_request_gui.destroy(player_table)
  player_table.guis.request.refs.window.destroy()
  player_table.guis.request = nil
end

function logistic_request_gui.open(player, player_table, item_data)
  local gui_data = player_table.guis.request
  local refs = gui_data.refs
  local state = gui_data.state

  -- update state
  local stack_size = game.item_prototypes[item_data.name].stack_size
  item_data.stack_size = stack_size
  state.item_data = item_data
  local request_data = item_data.request or { min = 0, max = math.max_uint }
  state.request = request_data
  state.visible = true

  -- update item label
  refs.item_label.caption = "[item=" .. item_data.name .. "]  " .. item_data.translation

  -- update logistic setter
  local logistic_setter = refs.logistic_setter
  for _, type in ipairs({ "min", "max" }) do
    local elems = logistic_setter[type]
    local count = request_data[type]
    elems.textfield.enabled = true
    if count == math.max_uint then
      elems.textfield.text = constants.infinity_rep
    else
      elems.textfield.text = tostring(count)
    end
    elems.slider.enabled = true
    elems.slider.set_slider_value_step(1)
    elems.slider.set_slider_minimum_maximum(0, stack_size * 10)
    elems.slider.set_slider_value_step(stack_size)
    elems.slider.slider_value = math.round(count / stack_size) * stack_size
  end
  refs.logistic_setter.min.textfield.select_all()
  refs.logistic_setter.min.textfield.focus()

  -- update window
  refs.focus_frame.visible = true
  refs.focus_frame.bring_to_front()
  refs.window.visible = true
  refs.window.bring_to_front()

  -- set opened
  player.opened = refs.window
end

function logistic_request_gui.close(player, player_table)
  local gui_data = player_table.guis.request
  gui_data.state.visible = false
  gui_data.refs.focus_frame.visible = false
  gui_data.refs.window.visible = false
  if not player.opened then
    player.opened = player_table.guis.search.refs.window
  end
end

function logistic_request_gui.update_focus_frame_size(player, player_table)
  local gui_data = player_table.guis.request
  if gui_data then
    local resolution = player.display_resolution
    local scale = player.display_scale
    local size = { resolution.width / scale, resolution.height / scale }
    gui_data.refs.focus_frame.style.size = size
  end
end

function logistic_request_gui.set_request(player, player_table, is_temporary, skip_sound)
  if not skip_sound then
    player.play_sound({ path = "utility/confirm" })
  end

  local gui_data = player_table.guis.request
  local refs = gui_data.refs
  local state = gui_data.state

  -- get the latest values from each textfield
  logistic_request_gui.update_request(refs, state, refs.logistic_setter.min.textfield)
  logistic_request_gui.update_request(refs, state, refs.logistic_setter.max.textfield)

  -- set the request
  logistic_request.set(player, player_table, state.item_data.name, state.request, is_temporary)

  -- close this window
  if is_temporary then
    player.opened = nil
  end
end

function logistic_request_gui.clear_request(player, player_table)
  player.play_sound({ path = "utility/confirm" })
  logistic_request.clear(player, player_table, player_table.guis.request.state.item_data.name)
  player.opened = nil
end

function logistic_request_gui.update_request(refs, state, element)
  local item_data = state.item_data
  local request_data = state.request

  local bound = gui.get_tags(element).bound

  local elems = refs.logistic_setter[bound]
  local count
  if element.type == "textfield" then
    count = tonumber(element.text)
    if not count then
      count = bound == "min" and 0 or math.max_uint
    end
    elems.slider.slider_value = math.round(count / item_data.stack_size) * item_data.stack_size
  else
    count = element.slider_value
    local text
    if bound == "max" and count == item_data.stack_size * 10 then
      count = math.max_uint
      text = constants.infinity_rep
    else
      text = tostring(count)
    end
    elems.textfield.text = text
  end
  request_data[bound] = count

  -- sync border
  if bound == "min" and count > request_data.max then
    request_data.max = count
    refs.logistic_setter.max.textfield.text = tostring(count)
    refs.logistic_setter.max.slider.slider_value = math.round(count / item_data.stack_size) * item_data.stack_size
  elseif bound == "max" and count < request_data.min then
    request_data.min = count
    refs.logistic_setter.min.textfield.text = tostring(count)
    refs.logistic_setter.min.slider.slider_value = math.round(count / item_data.stack_size) * item_data.stack_size
  end

  -- switch textfield
  if element.type == "textfield" then
    if bound == "min" then
      refs.logistic_setter.max.textfield.select_all()
      refs.logistic_setter.max.textfield.focus()
    else
      refs.logistic_setter.min.textfield.select_all()
      refs.logistic_setter.min.textfield.focus()
    end
  end
end

function logistic_request_gui.handle_action(e, msg)
  local player = game.get_player(e.player_index)
  local player_table = global.players[e.player_index]
  local gui_data = player_table.guis.request
  local refs = gui_data.refs
  local state = gui_data.state

  if msg.action == "close" then
    logistic_request_gui.close(player, player_table)
  elseif msg.action == "bring_to_front" then
    refs.window.bring_to_front()
  elseif msg.action == "recenter" and e.button == defines.mouse_button_type.middle then
    refs.window.force_auto_center()
  elseif msg.action == "update_request" then
    logistic_request_gui.update_request(refs, state, e.element)
  elseif msg.action == "clear_request" then
    logistic_request.clear(player, player_table, state.item_data.name)
    -- invoke `on_gui_closed` so the search GUI will be refocused
    player.opened = nil
  elseif msg.action == "set_request" then
    -- HACK: Makes it easy for the search GUI to tell that this was confirmed
    player_table.confirmed_tick = game.ticks_played
    logistic_request_gui.set_request(player, player_table, msg.temporary, true)
    -- invoke `on_gui_closed` if the above function did not
    if not msg.temporary then
      player.opened = nil
    end
  end
end

return logistic_request_gui
