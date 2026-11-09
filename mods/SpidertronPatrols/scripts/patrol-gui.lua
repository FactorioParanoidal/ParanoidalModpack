PatrolGui = {}
local PatrolGuiWaypoint = {}
local PatrolGuiGeneral = {}

---@class GuiElements
---@field sp-relative-frame LuaGuiElement
---@field camera LuaGuiElement
---@field on_patrol_switch LuaGuiElement
---@field toggle_camera_button LuaGuiElement
---@field toggle_center_button LuaGuiElement
---@field schedule-scroll-pane LuaGuiElement
---@field time_slider any
---@field time_textfield any
---@field waypoint_dropdown any
---@field waypoint_button any

---@param spidertron LuaEntity
---@return boolean
local function has_fuel_inventory(spidertron)
  return not not spidertron.get_fuel_inventory()
end

---@param spidertron LuaEntity
---@return boolean
local function has_trash_inventory(spidertron)
  return not not spidertron.get_inventory(defines.inventory.spider_trash)
end

---@param spidertron LuaEntity
---@return boolean
---https://mods.factorio.com/mod/maraxsis
local function is_maraxsis_submarine(spidertron)
  if not remote.interfaces.maraxsis then return false end
  local melon = remote.call("maraxsis", "get_submarine_list")[spidertron.name]
  return not not melon
end

---@param spidertron LuaEntity
---@return string[]
local function dropdown_contents(spidertron)
  local contents = {
    {"description.no-limit"},
    {"gui-train.add-time-condition"},
    {"gui-train.add-inactivity-condition"},
    {"gui-patrol.full-inventory-condition"},
    {"gui-patrol.empty-inventory-condition"},
    {"gui-patrol.empty-trash-condition"},
    {"gui-train.add-item-count-condition"},
    {"gui-train.add-fuel-full-condition"},
    {"gui-train.add-circuit-condition"},
    {"gui-train.add-robots-inactive-condition"},
    {"gui-patrol.driver-present"},
    {"gui-patrol.driver-not-present"},
  }
  if not has_fuel_inventory(spidertron) then
    table.remove(contents, 8)
  end
  if not has_trash_inventory(spidertron) then
    table.remove(contents, 6)
  end
  if is_maraxsis_submarine(spidertron) then
    table.insert(contents, {"gui-patrol.submerge"})
  end
  return contents
end

---@param index number
---@param spidertron LuaEntity
---@return string
local function dropdown_index_lookup(index, spidertron)
  local lookup = {
    "none",
    "time-passed",
    "inactivity",
    "full-inventory",
    "empty-inventory",
    "empty-trash",
    "item-count",
    "fuel-full",
    "circuit-condition",
    "robots-inactive",
    "passenger-present",
    "passenger-not-present",
  }
  if not has_fuel_inventory(spidertron) then
    table.remove(lookup, 8)
  end
  if not has_trash_inventory(spidertron) then
    table.remove(lookup, 6)
  end
  if is_maraxsis_submarine(spidertron) then
    table.insert(lookup, "submerge")
  end
  return lookup[index]
end

---@param wait_condition WaypointType
---@param spidertron LuaEntity
---@return integer?
local function dropdown_index(wait_condition, spidertron)
  local lookup = {
    "none",
    "time-passed",
    "inactivity",
    "full-inventory",
    "empty-inventory",
    "empty-trash",
    "item-count",
    "fuel-full",
    "circuit-condition",
    "robots-inactive",
    "passenger-present",
    "passenger-not-present",
  }
  if not has_fuel_inventory(spidertron) then
    table.remove(lookup, 8)
  end
  if not has_trash_inventory(spidertron) then
    table.remove(lookup, 6)
  end
  if is_maraxsis_submarine(spidertron) then
    table.insert(lookup, "submerge")
  end
  for i, condition in pairs(lookup) do
    if condition == wait_condition then
      return i
    end
  end
end


condition_dropdown_contents = {">", "<", "=", "≥", "≤", "≠"}


local slider_values = {5, 10, 30, 60, 120, 600}
slider_values[0] = 0

---@param input_value integer
---@return integer
local function slider_value_index(input_value)
  for i, slider_value in pairs(slider_values) do
    if input_value == slider_value then
      return i
    elseif input_value < slider_value then
      return i - 1
    end
  end
  return #slider_values
end

---@param i WaypointIndex
---@param waypoint Waypoint
---@return table?
local function build_waypoint_player_input(i, waypoint)
  local waypoint_type = waypoint.type
  if waypoint_type == "time-passed" or waypoint_type == "inactivity" then
    return {
      {
        type = "slider", style = "sp_compact_notched_slider", minimum_value = 0, maximum_value = #slider_values, value = slider_value_index(waypoint.wait_time), discrete_slider = true,
        ref = {"time_slider", i},
        handler = {[defines.events.on_gui_value_changed] = PatrolGuiWaypoint.update_text_field}, tags = {index = i},
      },
      {
        type = "textfield", style = "sp_compact_slider_value_textfield", text = tostring(waypoint.wait_time) .. " s",  numeric = true, allow_decimal = false, allow_negative = false, lose_focus_on_confirm = true,
        ref = {"time_textfield", i},
        handler = {
          [defines.events.on_gui_text_changed] = PatrolGuiWaypoint.update_slider,
          [defines.events.on_gui_click] = PatrolGuiWaypoint.remove_s,
          [defines.events.on_gui_confirmed] = PatrolGuiWaypoint.add_s,
        },
        tags = {index = i},
      }
    }
  elseif waypoint_type == "item-count" or waypoint_type == "circuit-condition" then
    local condition_info = waypoint.item_condition_info or waypoint.circuit_condition_info  ---@cast condition_info -?
    local elem_type = waypoint_type == "item-count" and "item-with-quality" or "signal"
    return {
      {
        type = "choose-elem-button", style = "train_schedule_item_select_button", elem_type = elem_type, ["item-with-quality"] = condition_info.elem, signal = condition_info.elem,
        handler = {[defines.events.on_gui_elem_changed] = PatrolGuiWaypoint.condition_elem_selected}, tags = {index = i},
      },
      {
        type = "drop-down", style = "train_schedule_circuit_condition_comparator_dropdown", items = condition_dropdown_contents, selected_index = condition_info.condition,
        handler = {[defines.events.on_gui_selection_state_changed] = PatrolGuiWaypoint.condition_comparison_changed}, tags = {index = i},
      },
      {
        type = "textfield", style = "sp_compact_slider_value_textfield", text = tostring(condition_info.count), numeric = true, allow_decimal = false, allow_negative = waypoint_type == "circuit-condition", lose_focus_on_confirm = true,
        handler = {[defines.events.on_gui_text_changed] = PatrolGuiWaypoint.condition_count_changed}, tags = {index = i},
      },
    }
  end
end

---@param patrol_data PatrolData
---@param index WaypointIndex
---@return table
local function generate_button_status(patrol_data, index)
  local toggled = false
  local sprite = "utility/play"
  if patrol_data.on_patrol and patrol_data.current_index == index then
    toggled = true
    if patrol_data.on_patrol.at_waypoint then
      sprite = "utility/stop"
    end
  end
  return {toggled = toggled, sprite = sprite}
end

---@param patrol_data PatrolData
---@param spidertron LuaEntity
---@return table
local function build_waypoint_frames(patrol_data, spidertron)
  --patrol_data.waypoints = {{type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}}--{type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}, {type = "none"}, {type = "time-passed", wait_time = 5}, {type = "inactivity", wait_time = 10}, {type = "full-inventory"}, {type = "empty-inventory"}, {type = "robots-inactive"}, {type = "passenger-present"}, {type = "passenger-not-present"}}
  local frames = {}
  for i, waypoint in pairs(patrol_data.waypoints) do
    local button_status = generate_button_status(patrol_data, i)
    table.insert(frames,
      {type = "frame", --[[name = "schedule-waypoint-" .. i,]] style = "sp_spidertron_schedule_station_frame", children = {
        {
          type = "sprite-button", name = "status_button", style = "train_schedule_action_button", toggled = button_status.toggled, mouse_button_filter = {"left"}, sprite = button_status.sprite,
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.go_to_waypoint}, tags = {index = i},
        },
        {
          type = "label", style = "sp_spidertron_waypoint_label", caption = "#" .. tostring(i),
          game_controller_interaction = defines.game_controller_interaction and defines.game_controller_interaction.always,  -- This code works even on pre-1.1.83 versions
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_camera_to_waypoint}, tags = {index = i},
        },
        {
          type = "drop-down", items = dropdown_contents(spidertron), selected_index = dropdown_index(waypoint.type, spidertron),
          ref = {"waypoint_dropdown", i},
          tooltip = waypoint.type == "circuit-condition" and {"gui-patrol.circuit-condition-tooltip"} or nil,
          handler = {[defines.events.on_gui_selection_state_changed] = PatrolGuiWaypoint.waypoint_type_changed}, tags = {index = i},
        },
        {
          type = "flow", style = "sp_player_input_horizontal_flow", children =
          build_waypoint_player_input(i, waypoint)
        },
        {type = "empty-widget", style = "sp_empty_filler"},
        {
          type = "sprite-button",
          style = "train_schedule_action_button",
          style_mods = {right_margin = -4},
          mouse_button_filter = {"left"},
          sprite = "item/sp-spidertron-patrol-remote",
          tooltip = {"", {"gui-patrol.insert-after-waypoint"}, "\n", prototypes.item["sp-spidertron-patrol-remote"].localised_description},
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.give_connected_remote_for_waypoint}, tags = {index = i},
        },
        {
          type = "sprite-button", name = "up", style = "sp_schedule_move_button", mouse_button_filter = {"left"}, sprite = "sp-up-white",
          tooltip = {"gui-patrol.move-to-top"},
          ref = {"waypoint_button", i, "up"},
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_waypoint_up}, tags = {index = i},
        },
        {
          type = "sprite-button", name = "down", style = "sp_schedule_move_button", mouse_button_filter = {"left"}, sprite = "sp-down-white",
          tooltip = {"gui-patrol.move-to-bottom"},
          ref = {"waypoint_button", i, "down"},
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.move_waypoint_down}, tags = {index = i},
        },
        {
          type = "sprite-button", style = "train_schedule_delete_button", mouse_button_filter = {"left"}, sprite = "utility/close",
          handler = {[defines.events.on_gui_click] = PatrolGuiWaypoint.delete_waypoint}, tags = {index = i},
        },
      }}
    )
  end
    -- 'Add new waypoint' button
    table.insert(frames, {
      type = "button",
      style = "sp_spidertron_schedule_add_station_button",
      mouse_button_filter = {"left"},
      caption = {"gui-patrol.add-waypoint"},
      tooltip = prototypes.item["sp-spidertron-patrol-remote"].localised_description,
      handler = {[defines.events.on_gui_click] = PatrolGui.give_connected_remote},
    })
  return frames
end

---@param patrol_data PatrolData
---@return table
local function build_on_patrol_switch(patrol_data)
  local switch_state
  if patrol_data.on_patrol then switch_state = "left" else switch_state = "right" end
  return {
    type = "switch",
    name = "on_patrol_switch",
    handler = {[defines.events.on_gui_switch_state_changed] = PatrolGui.toggle_on_patrol},
    switch_state = switch_state,
    tooltip = {"gui-patrol.toggle-automatic-manual-tooltip"},
    left_label_caption = {"gui-train.automatic-mode"},
    left_label_tooltip = {"gui-patrol.toggle-automatic-manual-tooltip"},
    right_label_caption = {"gui-train.manual-mode"},
    right_label_tooltip = {"gui-patrol.toggle-automatic-manual-tooltip"},
  }
end

---@param player LuaPlayer
---@param spidertron LuaEntity
local function build_gui(player, spidertron)
  local relative_frame = player.gui.relative["sp-relative-frame"]
  if relative_frame then
    relative_frame.destroy()
  end
  storage.open_gui_elements[player.index] = nil

  local patrol_data = get_patrol_data(spidertron)
  local anchor = {
    gui = defines.relative_gui_type.spider_vehicle_gui,
    names = allowed_spidertron_names_array,  -- Avoids ghosts, constructrons, etc
    position = defines.relative_gui_position.right,
  }
  if patrol_data.hide_gui then
    -- Add minimal GUI that gives player a connected remote
    gui.add(player.gui.relative, {
      {
        type = "frame",
        style = "sp_relative_stretchable_frame",
        style_mods = {padding = 4},  ---@diagnostic disable-line: missing-fields
        name = "sp-relative-frame",
        anchor = anchor,
        children = {
          {
            type = "frame",
            style = "quick_bar_inner_panel",
            children = {
              {
                type = "sprite-button",
                style = "slot_sized_button",
                mouse_button_filter = {"left"},
                sprite = "item/sp-spidertron-patrol-remote",
                tooltip = prototypes.item["sp-spidertron-patrol-remote"].localised_description,
                handler = {[defines.events.on_gui_click] = PatrolGuiGeneral.unhide_gui},
              },
            }
          }
        }
      }
    })
    return
  end

  storage.open_gui_elements[player.index] = gui.add(player.gui.relative, {
    {
      type = "frame",
      name = "sp-relative-frame",
      style = "sp_relative_stretchable_frame",
      direction = "vertical",
      anchor = anchor,
      children = {
        {type = "flow", direction = "horizontal", style = "frame_header_flow", children = {
          {type = "label", style = "frame_title", caption = {"gui-train.schedule"}, ignored_by_interaction = true},
          {type = "empty-widget", style = "sp_stretchable_empty_widget"},
          {
            type = "sprite-button", style = "frame_action_button", sprite = "sp-hide-window", tooltip = {"gui-patrol.hide-gui"},
            handler = {[defines.events.on_gui_click] = PatrolGui.hide_gui}
          },
        }},
        {type = "flow", direction = "vertical", style = "inset_frame_container_vertical_flow", children = {
          {type = "frame", style = "inside_shallow_frame", children = {
            {
              type = "camera", style = "sp_spidertron_camera", position = spidertron.position, surface_index = spidertron.surface.index, zoom = 0.75,
              elem_mods = {entity = spidertron},  ---@diagnostic disable-line: missing-fields
              name = "camera",
            },
          }},
          {type = "frame", direction = "vertical", style = "sp_inside_shallow_frame", children = {
            {type = "frame", direction = "horizontal", style = "sp_stretchable_subheader_frame", children = {
              {type = "flow", style = "sp_patrol_schedule_mode_switch_horizontal_flow", children = {
                build_on_patrol_switch(patrol_data),
                {type = "empty-widget", style = "sp_stretchable_empty_widget"},
                {
                  type = "sprite-button", style = "tool_button", mouse_button_filter = {"left"}, sprite = "sp-camera", tooltip = {"gui-patrol.toggle-camera"},
                  name = "toggle_camera_button",
                  auto_toggle = true, toggled = true,
                  handler = {[defines.events.on_gui_click] = PatrolGui.toggle_camera},
                },
                {
                  type = "sprite-button", style = "tool_button", mouse_button_filter = {"left"}, sprite = "utility/center", tooltip = {"gui-patrol.toggle-center-on-spidertron", SPIDERTRON_NAME},
                  name = "toggle_center_button",
                  auto_toggle = true, toggled = true,
                  handler = {[defines.events.on_gui_click] = PatrolGui.toggle_camera_center_on_spidertron},
                },
                {
                  type = "sprite-button", style = "tool_button", mouse_button_filter = {"left"}, sprite = "utility/map", tooltip = {"gui-train.open-in-map"},
                  handler = {[defines.events.on_gui_click] = PatrolGui.open_location_on_map},
                },
                {
                  type = "sprite-button", style = "tool_button_red", mouse_button_filter = {"left"}, sprite = "utility/reset", tooltip = {"gui-patrol.delete-all-waypoints"},
                  handler = {[defines.events.on_gui_click] = PatrolGui.delete_all_waypoints},
                },
              }},
            }},
            {
              type = "scroll-pane", style = "sp_spidertron_schedule_scroll_pane", name = "schedule-scroll-pane", horizontal_scroll_policy = "never", vertical_scroll_policy = "auto-and-reserve-space",
              children = build_waypoint_frames(patrol_data, spidertron)
            }
          }},
        }},
      }
    }
  })
end

---@param patrol_data PatrolData
function PatrolGui.update_gui_button_states(patrol_data)
  -- Lightweight version of PatrolGui.update_gui_schedule that only touches the play/stop buttons
  -- Use when not the result of a GUI interaction
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == patrol_data.spidertron then
      local gui_elements = storage.open_gui_elements[player.index]
      if gui_elements then
        local scroll_pane = gui_elements["schedule-scroll-pane"]
        for i, frame in pairs(scroll_pane.children) do
          local status_button = frame.status_button
          if status_button then
            -- Filters out "Add waypoints" button
            local button_status = generate_button_status(patrol_data, i)
            status_button.toggled = button_status.toggled
            status_button.sprite = button_status.sprite
          end
        end
      end
    end
  end
end

---@param patrol_data PatrolData
function PatrolGui.update_gui_schedule(patrol_data)
  local spidertron = patrol_data.spidertron

  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == patrol_data.spidertron then
      local gui_elements = storage.open_gui_elements[player.index]
      if gui_elements then
        local scroll_pane = gui_elements["schedule-scroll-pane"]
        scroll_pane.clear()
        local waypoint_frames = build_waypoint_frames(patrol_data, spidertron)
        local new_gui_elements = gui.add(scroll_pane, waypoint_frames)
        -- Copy across new gui elements to global storage
        gui_elements.waypoint_dropdown = new_gui_elements.waypoint_dropdown
        gui_elements.time_slider = new_gui_elements.time_slider
        gui_elements.time_textfield = new_gui_elements.time_textfield
        gui_elements.waypoint_button = new_gui_elements.waypoint_button
      else
        build_gui(player, spidertron)
      end
    end
  end
end

---@param patrol_data PatrolData
function PatrolGui.update_gui_switch(patrol_data)
  for _, player in pairs(game.players) do
    if player.opened_gui_type == defines.gui_type.entity and player.opened == patrol_data.spidertron then
      local gui_elements = storage.open_gui_elements[player.index]
      if gui_elements then
        gui_elements.on_patrol_switch.switch_state = build_on_patrol_switch(patrol_data).switch_state
        PatrolGui.update_gui_button_states(patrol_data)
      end
    end
  end
end

local function on_tick()
  -- Updates GUI highlights
  for player_index, button_info in pairs(storage.player_highlights) do
    local button = button_info.button
    local tick_started = button_info.tick_started
    if button and button.valid then
      if (game.tick - tick_started) > 20 then
        button.style = "sp_schedule_move_button"
        button.sprite = "sp-" .. button.name .. "-white"
        storage.player_highlights[player_index] = nil
      end
    else
      storage.player_highlights[player_index] = nil
    end
  end
end

---@param player LuaPlayer
function PatrolGui.clear_highlights_for_player(player)
  local button_info = storage.player_highlights[player.index]
  if button_info then
    local button = button_info.button
    if button and button.valid then
      button.style = "sp_schedule_move_button"
      button.sprite = "sp-" .. button.name .. "-white"
    end
    storage.player_highlights[player.index] = nil
  end
end

---@param event EventData.on_gui_opened
local function on_gui_opened(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local entity = event.entity
  if entity and entity.type == "spider-vehicle" and is_allowed_spidertron_name[entity.name] then
    WaypointRendering.update_player_render_paths(player)

    local relative_frame = player.gui.relative["sp-relative-frame"]
    if relative_frame then
      relative_frame.destroy()
    end
    build_gui(player, entity)
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
function PatrolGuiGeneral.unhide_gui(player, spidertron)
  -- Called from hidden GUI
  local patrol_data = get_patrol_data(spidertron)
  patrol_data.hide_gui = false
  build_gui(player, spidertron)
  PatrolRemote.give_remote(player, spidertron)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.hide_gui(player, spidertron, gui_elements)
  local patrol_data = get_patrol_data(spidertron)
  patrol_data.hide_gui = true
  build_gui(player, spidertron)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.toggle_camera(player, spidertron, gui_elements)
  local camera_button = gui_elements.toggle_camera_button
  local camera = gui_elements.camera
  if camera_button.toggled then
    -- Button was clicked
    camera.parent.visible = true
  else
    -- Button was unclicked
    camera.parent.visible = false
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.toggle_camera_center_on_spidertron(player, spidertron, gui_elements)
  local center_button = gui_elements.toggle_center_button
  local camera = gui_elements.camera
  if center_button.toggled then
    -- Button was clicked
    camera.entity = spidertron
  else
    -- Button was unclicked
    camera.entity = nil
    camera.position = spidertron.position
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.open_location_on_map(player, spidertron, gui_elements)
  local camera = gui_elements.camera
  local entity = camera.entity
  local position = entity and entity.position or camera.position
  player.set_controller{
    type = defines.controllers.remote,
    position = position,
    surface = player.surface,
  }
  if entity then
    player.centered_on = entity
  end
  player.opened = nil
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.delete_all_waypoints(player, spidertron, gui_elements)
  Control.clear_spidertron_waypoints(spidertron)
end

---@param on_patrol boolean
---@param spidertron LuaEntity
---@param patrol_data PatrolData
function PatrolGui.set_on_patrol(on_patrol, spidertron, patrol_data)
  if on_patrol then
    patrol_data.on_patrol = patrol_data.on_patrol or {}
  else
    patrol_data.on_patrol = nil
  end
  if on_patrol and #patrol_data.waypoints > 0 then
    SpidertronControl.go_to_next_waypoint(spidertron, patrol_data.current_index)
  else
    spidertron.autopilot_destination = nil
  end
  PatrolGui.update_gui_switch(patrol_data)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.toggle_on_patrol(player, spidertron, gui_elements)
  local switch = gui_elements.on_patrol_switch
  local patrol_data = get_patrol_data(spidertron)
  local on_patrol = switch.switch_state == "left"
  PatrolGui.set_on_patrol(on_patrol, spidertron, patrol_data)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
function PatrolGui.give_connected_remote(player, spidertron, gui_elements)
  -- Can be called from addon GUI
  PatrolRemote.give_remote(player, spidertron)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.give_connected_remote_for_waypoint(player, spidertron, gui_elements, patrol_data, index)
  PatrolRemote.give_remote(player, spidertron, index)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.go_to_waypoint(player, spidertron, gui_elements, patrol_data, index)
  -- 'Play' button
  if not patrol_data.on_patrol or index ~= patrol_data.current_index then
    PatrolGui.set_on_patrol(true, spidertron, patrol_data)
    SpidertronControl.go_to_next_waypoint(spidertron, index)
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.move_camera_to_waypoint(player, spidertron, gui_elements, patrol_data, index)
  -- Numbered labels
  local center_button = gui_elements.toggle_center_button
  local camera = gui_elements.camera

  center_button.toggled = false
  camera.entity = nil
  camera.position = patrol_data.waypoints[index].position
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
function PatrolGuiWaypoint.waypoint_type_changed(player, spidertron, gui_elements, patrol_data, index, element)
  local dropdown = gui_elements.waypoint_dropdown[index]
  local waypoint = patrol_data.waypoints[index]
  local new_waypoint_type = dropdown_index_lookup(dropdown.selected_index, spidertron)
  if waypoint.type ~= new_waypoint_type then
    waypoint.type = new_waypoint_type
    element.tooltip = nil
    if new_waypoint_type == "time-passed" then
      waypoint.wait_time = 30
    elseif new_waypoint_type == "inactivity" then
      waypoint.wait_time = 5
    elseif new_waypoint_type == "submerge" then
      waypoint.wait_time = 2
    else
      waypoint.wait_time = nil
    end
    if new_waypoint_type == "item-count" then
      waypoint.item_condition_info = {elem = nil, condition = 4, count = 100}
      waypoint.circuit_condition_info = nil
    elseif new_waypoint_type == "circuit-condition" then
      waypoint.circuit_condition_info = {elem = nil, condition = 1, count = 0}
      waypoint.item_condition_info = nil
      element.tooltip = {"gui-patrol.circuit-condition-tooltip"}
    else
      waypoint.item_condition_info = nil
      waypoint.circuit_condition_info = nil
    end
    PatrolGui.update_gui_schedule(patrol_data)
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
---@param modifiers table
function PatrolGuiWaypoint.move_waypoint_up(player, spidertron, gui_elements, patrol_data, index, element, modifiers)
  local waypoints = patrol_data.waypoints
  local index_to_move = index
  if index_to_move == 1 then
    -- Wrap around aka move to bottom with shift = true
    PatrolGuiWaypoint.move_waypoint_down(player, spidertron, gui_elements, patrol_data, index, element, {shift = true, wrap = true})
  else
    local new_index
    if modifiers.shift then
      -- Move waypoint to top
      local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
      table.remove(waypoints, index_to_move)
      table.insert(waypoints, 1, waypoint_to_move)

      local current_index = patrol_data.current_index
      if current_index then
        if current_index == index_to_move then patrol_data.current_index = 1 end
        if current_index < index_to_move then patrol_data.current_index = current_index + 1 end
      end
      new_index = 1
    else
      -- Move waypoint up one
      local index_above = index - 1

      local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
      local waypoint_above = util.table.deepcopy(waypoints[index_above])

      waypoints[index_above] = waypoint_to_move
      waypoints[index_to_move] = waypoint_above

      local current_index = patrol_data.current_index
      if current_index then
        if current_index == index_above then patrol_data.current_index = index_to_move end
        if current_index == index_to_move then patrol_data.current_index = index_above end
      end
      new_index = index_above
    end


    PatrolGui.update_gui_schedule(patrol_data)
    WaypointRendering.update_render_text(spidertron)

    local buttons = gui_elements.waypoint_button[new_index]
    local button = modifiers.wrap and buttons.down or buttons.up
    button.style = "sp_selected_schedule_move_button"
    button.sprite = modifiers.wrap and "sp-down-black" or "sp-up-black"

    PatrolGui.clear_highlights_for_player(player)
    storage.player_highlights[player.index] = {button = button, tick_started = game.tick}
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
---@param modifiers table
function PatrolGuiWaypoint.move_waypoint_down(player, spidertron, gui_elements, patrol_data, index, element, modifiers)
  local waypoints = patrol_data.waypoints
  local index_to_move = index
  local number_of_waypoints = #waypoints
  if number_of_waypoints == 1 then return end  -- Prevents infinite loop between move_waypoint_up and move_waypoint_down
  if index_to_move == number_of_waypoints then
    -- Wrap around aka move to top with shift = true
    PatrolGuiWaypoint.move_waypoint_up(player, spidertron, gui_elements, patrol_data, index, element, {shift = true, wrap = true})
  else
    local new_index
    if modifiers.shift then
      -- Move waypoint to bottom
      local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
      table.remove(waypoints, index_to_move)
      table.insert(waypoints, number_of_waypoints, waypoint_to_move)

      local current_index = patrol_data.current_index
      if current_index then
        if current_index == index_to_move then patrol_data.current_index = number_of_waypoints end
        if current_index > index_to_move then patrol_data.current_index = current_index - 1 end
      end
      new_index = number_of_waypoints
    else
      -- Move waypoint down one
      local index_below = index + 1

      local waypoint_to_move = util.table.deepcopy(waypoints[index_to_move])
      local waypoint_below = util.table.deepcopy(waypoints[index_below])

      waypoints[index_below] = waypoint_to_move
      waypoints[index_to_move] = waypoint_below

      local current_index = patrol_data.current_index
      if current_index then
        if current_index == index_below then patrol_data.current_index = index_to_move end
        if current_index == index_to_move then patrol_data.current_index = index_below end
      end
      new_index = index_below
    end

    PatrolGui.update_gui_schedule(patrol_data)
    WaypointRendering.update_render_text(spidertron)

    local buttons = gui_elements.waypoint_button[new_index]
    local button = modifiers.wrap and buttons.up or buttons.down
    button.style = "sp_selected_schedule_move_button"
    button.sprite = modifiers.wrap and "sp-up-black" or "sp-down-black"

    PatrolGui.clear_highlights_for_player(player)
    storage.player_highlights[player.index] = {button = button, tick_started = game.tick}
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.delete_waypoint(player, spidertron, gui_elements, patrol_data, index)
  local waypoints = patrol_data.waypoints
  local index_to_delete = index
  if patrol_data.current_index > index_to_delete then
    patrol_data.current_index = patrol_data.current_index - 1
  end
  waypoints[index_to_delete].render.destroy()
  table.remove(waypoints, index_to_delete)
  if not next(waypoints) then
    -- All waypoints are gone, so cleanup
    Control.clear_spidertron_waypoints(spidertron)
    return
  end
  if not waypoints[patrol_data.current_index] then
    patrol_data.current_index = 1
  end
  if patrol_data.on_patrol then
    SpidertronControl.go_to_next_waypoint(spidertron, patrol_data.current_index)
  end
  PatrolGui.update_gui_schedule(patrol_data)
  WaypointRendering.update_render_text(spidertron)
end

---@param wait_time number
---@param spidertron LuaEntity
---@param waypoint_index WaypointIndex
local function set_waypoint_time(wait_time, spidertron, waypoint_index)
  local patrol_data = get_patrol_data(spidertron)
  local waypoint = patrol_data.waypoints[waypoint_index]
  waypoint.wait_time = wait_time
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.update_text_field(player, spidertron, gui_elements, patrol_data, index)
  local wait_time = slider_values[gui_elements.time_slider[index].slider_value]
  gui_elements.time_textfield[index].text = tostring(wait_time) .. " s"

  set_waypoint_time(wait_time, spidertron, index)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.update_slider(player, spidertron, gui_elements, patrol_data, index)
  local text_field = gui_elements.time_textfield[index]

   -- If the user tabbed into the textbox, then remove_s won't have been called, so need to filter out all non-digits
  local text = text_field.text:gsub("%D", "")
  text_field.text = text

  if text == "" then text = "0" end
  local wait_time = tonumber(text) or 5
  gui_elements.time_slider[index].slider_value = slider_value_index(wait_time)

  set_waypoint_time(wait_time, spidertron, index)
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.remove_s(player, spidertron, gui_elements, patrol_data, index)
  local textfield = gui_elements.time_textfield[index]
  local current_text = textfield.text
  if current_text:sub(-2, -1) == " s" then
    textfield.text = textfield.text:sub(0, -3)
  end
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements any
---@param patrol_data PatrolData
---@param index WaypointIndex
function PatrolGuiWaypoint.add_s(player, spidertron, gui_elements, patrol_data, index)
  local textfield = gui_elements.time_textfield[index]
  textfield.text = textfield.text .. " s"
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements GuiElements
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
function PatrolGuiWaypoint.condition_elem_selected(player, spidertron, gui_elements, patrol_data, index, element)
  local elem_button = element
  local waypoint = patrol_data.waypoints[index]
  local condition_info = waypoint.item_condition_info or waypoint.circuit_condition_info  ---@cast condition_info -?
  condition_info.elem = elem_button.elem_value  --[[@as ItemIDAndQualityIDPair|SignalID]]
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements GuiElements
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
function PatrolGuiWaypoint.condition_comparison_changed(player, spidertron, gui_elements, patrol_data, index, element)
  local dropdown = element
  local waypoint = patrol_data.waypoints[index]
  local condition_info = waypoint.item_condition_info or waypoint.circuit_condition_info  ---@cast condition_info -?
  condition_info.condition = dropdown.selected_index
end

---@param player LuaPlayer
---@param spidertron LuaEntity
---@param gui_elements GuiElements
---@param patrol_data PatrolData
---@param index WaypointIndex
---@param element LuaGuiElement
function PatrolGuiWaypoint.condition_count_changed(player, spidertron, gui_elements, patrol_data, index, element)
  local waypoint = patrol_data.waypoints[index]
  local condition_info = waypoint.item_condition_info or waypoint.circuit_condition_info  ---@cast condition_info -?
  local text = element.text
  if text == "" then text = "0" end
  local item_count = tonumber(text)  ---@cast item_count -?
  condition_info.count = item_count
end

gui.add_handlers(PatrolGuiGeneral,  -- For handlers called from the addon GUI as well
  function(event, handler)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local spidertron = player.opened
    if player.gui.relative["sp-relative-frame"] then
      handler(player, spidertron)
    end
  end
)

gui.add_handlers(PatrolGui,
  function(event, handler)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local spidertron = player.opened
    local gui_elements = storage.open_gui_elements[player.index]
    if gui_elements then
      handler(player, spidertron, gui_elements)
    end
  end
)

gui.add_handlers(PatrolGuiWaypoint,
  function(event, handler)
    local player = game.get_player(event.player_index)  ---@cast player -?
    local spidertron = player.opened
    local gui_elements = storage.open_gui_elements[player.index]
    if spidertron and gui_elements then
      local patrol_data = storage.patrol_data[spidertron.unit_number]
      local index = event.element.tags.index
      local modifiers = {shift = event.shift, control = event.control, alt = event.alt}
      -- TODO look at using event.element in all events or none
      handler(player, spidertron, gui_elements, patrol_data, index, event.element, modifiers)
    end
  end
)

local toggleable_entities = {
  ["locomotive"] = true,
  ["constant-combinator"] = true,
  ["power-switch"] = true,
}
---Checks selected, then opened, then spidertron_remote_selection, then vehicle/physical_vehicle
---@param event EventData.CustomInputEvent
local function toggle_spidertron_automatic_manual(event)
  local player = game.get_player(event.player_index)  ---@cast player -?
  local spidertron = player.selected
  local spidertrons
  if not spidertron or spidertron.type ~= "spider-vehicle" then
    if spidertron and toggleable_entities[spidertron.type] then
      return  -- Don't check opened/vehicle because the player is toggling a different entity by selection
    end
    spidertron = player.opened  --[[@as LuaEntity]]
    if not spidertron or spidertron.object_name ~= "LuaEntity" or spidertron.type ~= "spider-vehicle" then
      spidertrons = player.spidertron_remote_selection
      if not spidertrons or not next(spidertrons) then
        spidertron = player.vehicle or player.physical_vehicle
        if not spidertron then
          return
        end
      end
    end
  end
  spidertrons = spidertrons or {spidertron}
  for _, spidertron_ in pairs(spidertrons) do
    if spidertron_.type == "spider-vehicle" then
      local patrol_data = get_patrol_data(spidertron_)
      local new_on_patrol = not patrol_data.on_patrol
      PatrolGui.set_on_patrol(new_on_patrol, spidertron_, patrol_data)
    end
  end
end

PatrolGui.events = {
  [defines.events.on_gui_opened] = on_gui_opened,
  [defines.events.on_tick] = on_tick,
  ["sp-toggle-spidertron-automatic-manual"] = toggle_spidertron_automatic_manual,
}

return PatrolGui
