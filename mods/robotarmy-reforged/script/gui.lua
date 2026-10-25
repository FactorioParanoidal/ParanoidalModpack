-- GUI: the army window (shortcut / hotkey) and the panel next to a droid assembler or
-- guard station.
--
-- Army window: squad thresholds of the force (hunt size, retreat size, hunt radius) and the
-- list of squads with their composition, state and actions (show on map, pick, retreat).
-- Spawner panel: droids waiting to be deployed; guard stations also set their garrison size.
-- Element names are prefixed "robotarmy_"; actions are in the element tags.
local shared = require("lib.shared")
local config = require("script.config")
local state = require("script.state")
local Squad = require("script.squad")
local tools = require("script.tools")

local gui = {}

local WINDOW = "robotarmy_army"
local PANEL = "robotarmy_spawner"
local MAX_KINDS = 4 -- droid kinds shown per squad row

------------------------------------------------------------------------------------------
-- Thresholds

local function clamp(value, spec)
  value = math.floor(value / spec.step + 0.5) * spec.step
  if value < spec.min then return spec.min end
  if value > spec.max then return spec.max end
  return value
end

--- Sets a squad threshold of a force; keeps retreat size below hunt size.
function gui.set_threshold(fd, key, value)
  local spec = shared.thresholds[key]
  if not spec or type(value) ~= "number" then return end
  local t = fd.thresholds
  t[key] = clamp(value, spec)
  if key == "hunt_size" and t.retreat_size >= t.hunt_size then
    t.retreat_size = math.max(1, t.hunt_size - 1)
  elseif key == "retreat_size" and t.retreat_size >= t.hunt_size then
    t.retreat_size = math.max(1, t.hunt_size - 1)
  end
  for _, squad in pairs(fd.squads) do
    if squad.mode ~= Squad.MODE.guard then squad.order.dirty = true end
  end
end

------------------------------------------------------------------------------------------
-- Army window

local function window_of(player)
  return player.gui.screen[WINDOW]
end

local function sync_thresholds(window, fd)
  local box = window.robotarmy_body.robotarmy_thresholds
  for _, key in pairs(shared.threshold_order) do
    local value = fd.thresholds[key]
    local slider = box["robotarmy_slider_" .. key]
    local field = box["robotarmy_field_" .. key]
    if slider.slider_value ~= value then slider.slider_value = value end
    if tonumber(field.text) ~= value then field.text = tostring(value) end
  end
end

local function composition(squad)
  local counts, order = {}, {}
  for _, member in pairs(squad.members) do
    if member.valid then
      local name = member.name
      if not counts[name] then order[#order + 1] = name end
      counts[name] = (counts[name] or 0) + 1
    end
  end
  table.sort(order, function(a, b)
    if counts[a] ~= counts[b] then return counts[a] > counts[b] end
    return a < b
  end)
  return counts, order
end

local function fill_row(row, squad)
  row.robotarmy_status.caption = {"robotarmy-gui.status-" .. Squad.status(squad)}
  local hold = row.robotarmy_hold
  if hold then
    hold.visible = squad.mode ~= Squad.MODE.guard
    hold.sprite = squad.hold and "utility/play" or "utility/backward_arrow_black"
    hold.tooltip = squad.hold and {"robotarmy-gui.release"} or {"robotarmy-gui.recall"}
  end
  local kinds = row.robotarmy_kinds
  kinds.clear()
  local counts, order = composition(squad)
  for i = 1, math.min(#order, MAX_KINDS) do
    local name = order[i]
    kinds.add({
      type = "sprite-button",
      sprite = "item/" .. name,
      number = counts[name],
      style = "transparent_slot",
      tooltip = {"entity-name." .. name},
      ignored_by_interaction = true,
    })
  end
  if #order > MAX_KINDS then
    kinds.add({type = "label", caption = "…"})
  end
end

local function add_row(list, squad)
  local row = list.add({type = "flow", name = tostring(squad.id), direction = "horizontal"})
  row.style.vertical_align = "center"
  row.style.horizontal_spacing = 8
  local id = row.add({type = "label", caption = {"robotarmy-gui.squad-number", squad.id}, style = "bold_label"})
  id.style.minimal_width = 48
  local kinds = row.add({type = "flow", name = "robotarmy_kinds", direction = "horizontal"})
  kinds.style.minimal_width = 4 * 40
  kinds.style.horizontal_spacing = 0
  local status = row.add({type = "label", name = "robotarmy_status"})
  status.style.minimal_width = 130
  row.add({type = "empty-widget"}).style.horizontally_stretchable = true
  local function button(action, sprite, tooltip)
    row.add({
      type = "sprite-button",
      name = "robotarmy_" .. action,
      sprite = sprite,
      style = "tool_button",
      tooltip = tooltip,
      tags = {robotarmy = action, squad = squad.id},
    })
  end
  button("locate", "utility/gps_map_icon", {"robotarmy-gui.locate"})
  button("select", "utility/select_icon_black", {"robotarmy-gui.select"})
  button("hold", "utility/backward_arrow_black", {"robotarmy-gui.recall"})
  fill_row(row, squad)
end

local function refresh_window(player, window)
  local fd = storage.forces[player.force.index]
  local body = window.robotarmy_body
  local list = window.robotarmy_list_frame.robotarmy_scroll.robotarmy_list
  local squads = fd and fd.squads or {}

  local droids, count = 0, 0
  for _, squad in pairs(squads) do
    count = count + 1
    droids = droids + squad.size
  end
  body.robotarmy_summary.caption = {"robotarmy-gui.summary", count, droids}

  -- update the rows in place; squad ids only grow, so new rows go to the end
  for _, row in pairs(list.children) do
    local squad = squads[tonumber(row.name) or -1]
    if squad and squad.size > 0 then
      fill_row(row, squad)
    else
      row.destroy()
    end
  end
  local ids = {}
  for id, squad in pairs(squads) do
    if squad.size > 0 and not list[tostring(id)] then ids[#ids + 1] = id end
  end
  table.sort(ids)
  for _, id in pairs(ids) do add_row(list, squads[id]) end
  window.robotarmy_list_frame.robotarmy_empty.visible = (#list.children == 0)
end

function gui.close_window(player)
  local window = window_of(player)
  if window then window.destroy() end
  storage.windows[player.index] = nil
  player.set_shortcut_toggled(shared.army_shortcut, false)
end

function gui.open_window(player)
  gui.close_window(player)
  local fd = state.force_data(player.force)
  local window = player.gui.screen.add({type = "frame", name = WINDOW, direction = "vertical"})
  window.auto_center = true

  local title = window.add({type = "flow", direction = "horizontal"})
  title.drag_target = window
  title.style.horizontal_spacing = 8
  title.add({type = "label", caption = {"robotarmy-gui.title"}, style = "frame_title", ignored_by_interaction = true})
  local drag = title.add({type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true})
  drag.style.horizontally_stretchable = true
  drag.style.height = 24
  title.add({
    type = "sprite-button",
    sprite = "utility/close",
    style = "frame_action_button",
    tooltip = {"gui.close"},
    tags = {robotarmy = "close"},
  })

  local body = window.add({type = "frame", name = "robotarmy_body", direction = "vertical", style = "inside_shallow_frame_with_padding"})
  body.style.horizontally_stretchable = true
  body.add({type = "label", name = "robotarmy_summary", style = "bold_label"})
  body.add({type = "line"})
  body.add({type = "label", caption = {"robotarmy-gui.thresholds"}, style = "caption_label"})
  local box = body.add({type = "table", name = "robotarmy_thresholds", column_count = 3})
  box.style.horizontal_spacing = 12
  box.style.vertical_align = "center"
  for _, key in pairs(shared.threshold_order) do
    local spec = shared.thresholds[key]
    box.add({type = "label", caption = {"robotarmy-gui." .. key}, tooltip = {"robotarmy-gui." .. key .. "-tooltip"}})
    local slider = box.add({
      type = "slider",
      name = "robotarmy_slider_" .. key,
      minimum_value = spec.min,
      maximum_value = spec.max,
      value = fd.thresholds[key],
      value_step = spec.step,
      tags = {robotarmy = "threshold", key = key},
    })
    slider.style.width = 200
    local field = box.add({
      type = "textfield",
      name = "robotarmy_field_" .. key,
      text = tostring(fd.thresholds[key]),
      numeric = true,
      allow_decimal = false,
      allow_negative = false,
      lose_focus_on_confirm = true,
      style = "short_number_textfield",
      tags = {robotarmy = "threshold", key = key},
    })
    field.style.width = 64
  end
  body.add({type = "line"})
  local hint = body.add({type = "label", caption = {"robotarmy-gui.hint"}})
  hint.style.single_line = false
  hint.style.maximal_width = 520
  hint.style.font_color = {0.8, 0.8, 0.8}

  local list_frame = window.add({type = "frame", name = "robotarmy_list_frame", direction = "vertical", style = "inside_deep_frame"})
  local scroll = list_frame.add({type = "scroll-pane", name = "robotarmy_scroll", horizontal_scroll_policy = "never"})
  scroll.style.maximal_height = 400
  scroll.style.minimal_width = 540
  scroll.style.padding = 8
  local list = scroll.add({type = "flow", name = "robotarmy_list", direction = "vertical"})
  list.style.vertical_spacing = 4
  local empty = list_frame.add({type = "label", name = "robotarmy_empty", caption = {"robotarmy-gui.no-squads"}})
  empty.style.single_line = false
  empty.style.maximal_width = 520
  empty.style.padding = 8

  storage.windows[player.index] = true
  player.set_shortcut_toggled(shared.army_shortcut, true)
  player.opened = window -- E / Esc close it
  refresh_window(player, window)
end

function gui.toggle_window(player)
  if window_of(player) then gui.close_window(player) else gui.open_window(player) end
end

------------------------------------------------------------------------------------------
-- Spawner panel (next to the machine window)

local function spawner_status(record)
  local waiting = #record.pending
  if waiting > 0 then
    return {"robotarmy-gui.spawner-waiting", waiting}
  end
  return {"robotarmy-gui.spawner-ready"}
end

local function garrison_now(record)
  local fd = storage.forces[record.entity.force.index]
  local id = fd and fd.station_squad[record.entity.unit_number]
  local squad = id and storage.squads[id]
  return squad and squad.size or 0
end

local function refresh_panel(player, panel)
  local record = storage.spawners[panel.tags.unit_number]
  if not (record and record.entity.valid) then
    panel.destroy()
    return
  end
  local inner = panel.robotarmy_inner
  inner.robotarmy_status.caption = spawner_status(record)
  if record.station then
    inner.robotarmy_garrison_now.caption = {"robotarmy-gui.garrison-now", garrison_now(record), record.garrison}
  end
end

function gui.open_panel(player, entity)
  local anchor_gui = player.gui.relative
  if anchor_gui[PANEL] then anchor_gui[PANEL].destroy() end
  local record = storage.spawners[entity.unit_number]
  if not record then return end
  local panel = anchor_gui.add({
    type = "frame",
    name = PANEL,
    direction = "vertical",
    caption = {"robotarmy-gui.panel-title"},
    anchor = {
      gui = defines.relative_gui_type.assembling_machine_gui,
      position = defines.relative_gui_position.right,
      names = {shared.buildings.assembler, shared.buildings.station},
    },
    tags = {unit_number = entity.unit_number},
  })
  local inner = panel.add({type = "frame", name = "robotarmy_inner", direction = "vertical", style = "inside_shallow_frame_with_padding"})
  inner.style.width = 280
  if record.station then
    inner.add({type = "label", caption = {"robotarmy-gui.garrison"}, tooltip = {"robotarmy-gui.garrison-tooltip"}, style = "caption_label"})
    local flow = inner.add({type = "flow", name = "robotarmy_garrison_flow", direction = "horizontal"})
    flow.style.vertical_align = "center"
    local slider = flow.add({
      type = "slider",
      name = "robotarmy_garrison_slider",
      minimum_value = shared.garrison.min,
      maximum_value = shared.garrison.max,
      value = record.garrison,
      value_step = 1,
      tags = {robotarmy = "garrison", unit_number = entity.unit_number},
    })
    slider.style.width = 170
    flow.add({
      type = "textfield",
      name = "robotarmy_garrison_field",
      text = tostring(record.garrison),
      numeric = true,
      allow_decimal = false,
      allow_negative = false,
      lose_focus_on_confirm = true,
      style = "very_short_number_textfield",
      tags = {robotarmy = "garrison", unit_number = entity.unit_number},
    })
    inner.add({type = "label", name = "robotarmy_garrison_now"})
  else
    local hint = inner.add({type = "label", caption = {"robotarmy-gui.assembler-hint"}})
    hint.style.single_line = false
    hint.style.maximal_width = 256
  end
  local status = inner.add({type = "label", name = "robotarmy_status"})
  status.style.single_line = false
  status.style.maximal_width = 256
  refresh_panel(player, panel)
end

function gui.close_panel(player)
  local panel = player.gui.relative[PANEL]
  if panel then panel.destroy() end
end

local function set_garrison(player, unit_number, value)
  local record = storage.spawners[unit_number]
  if not (record and record.station and record.entity.valid) then return end
  if record.entity.force.index ~= player.force.index then return end
  record.garrison = clamp(value, {min = shared.garrison.min, max = shared.garrison.max, step = 1})
  local panel = player.gui.relative[PANEL]
  if panel and panel.tags.unit_number == unit_number then
    local flow = panel.robotarmy_inner.robotarmy_garrison_flow
    if flow.robotarmy_garrison_slider.slider_value ~= record.garrison then
      flow.robotarmy_garrison_slider.slider_value = record.garrison
    end
    if tonumber(flow.robotarmy_garrison_field.text) ~= record.garrison then
      flow.robotarmy_garrison_field.text = tostring(record.garrison)
    end
    refresh_panel(player, panel)
  end
end

------------------------------------------------------------------------------------------
-- Events

function gui.refresh()
  for player_index in pairs(storage.windows) do
    local player = game.get_player(player_index)
    local window = player and window_of(player)
    if window then
      refresh_window(player, window)
    else
      storage.windows[player_index] = nil
    end
  end
  for _, player in pairs(game.connected_players) do
    local panel = player.gui.relative[PANEL]
    if panel then refresh_panel(player, panel) end
  end
end

--- Threshold changed in one window: show it in the other open windows of the force.
local function thresholds_changed(force)
  local fd = storage.forces[force.index]
  for player_index in pairs(storage.windows) do
    local player = game.get_player(player_index)
    local window = player and player.force == force and window_of(player)
    if window then sync_thresholds(window, fd) end
  end
end

local function on_value(event, value)
  local element = event.element
  local tags = element.tags
  local player = game.get_player(event.player_index)
  if not player or not value then return end
  if tags.robotarmy == "threshold" then
    gui.set_threshold(state.force_data(player.force), tags.key, value)
    thresholds_changed(player.force)
  elseif tags.robotarmy == "garrison" then
    set_garrison(player, tags.unit_number, value)
  end
end

function gui.on_value_changed(event)
  if not (event.element.valid and event.element.tags.robotarmy) then return end
  on_value(event, event.element.slider_value)
end

function gui.on_confirmed(event)
  local element = event.element
  if not (element.valid and element.tags.robotarmy and element.type == "textfield") then return end
  on_value(event, tonumber(element.text))
end

function gui.on_click(event)
  local element = event.element
  if not element.valid then return end
  local action = element.tags.robotarmy
  if not action then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  if action == "close" then
    gui.close_window(player)
    return
  end
  local squad = storage.squads[element.tags.squad]
  if not squad or squad.force_index ~= player.force.index or squad.size <= 0 then return end
  if action == "locate" then
    if squad.surface.valid then
      player.set_controller({type = defines.controllers.remote, position = squad.pos, surface = squad.surface})
    end
  elseif action == "select" then
    tools.select(player, squad)
  elseif action == "hold" and squad.mode ~= Squad.MODE.guard then
    if squad.hold then
      squad.hold = nil -- back to automatic hunting
      squad.order.dirty = true
    elseif Squad.ensure_group(squad) then
      squad.hold = true
      squad.qrf = nil
      if squad.mode == Squad.MODE.hunt then squad.mode = Squad.MODE.assemble end
      Squad.order_retreat(squad)
    end
  end
  local window = window_of(player)
  if window then refresh_window(player, window) end
end

function gui.on_opened(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name ~= shared.buildings.assembler and entity.name ~= shared.buildings.station then return end
  local player = game.get_player(event.player_index)
  if player then gui.open_panel(player, entity) end
end

function gui.on_closed(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  if event.element and event.element.valid and event.element.name == WINDOW then
    gui.close_window(player)
  end
  local entity = event.entity
  if entity and entity.valid and (entity.name == shared.buildings.assembler or entity.name == shared.buildings.station) then
    gui.close_panel(player)
  end
end

--- Copy-paste between guard stations copies the garrison size.
function gui.on_settings_pasted(event)
  local source, destination = event.source, event.destination
  if not (source.valid and destination.valid) then return end
  if source.name ~= shared.buildings.station or destination.name ~= shared.buildings.station then return end
  local from, to = storage.spawners[source.unit_number], storage.spawners[destination.unit_number]
  if from and to then to.garrison = from.garrison end
end

return gui
