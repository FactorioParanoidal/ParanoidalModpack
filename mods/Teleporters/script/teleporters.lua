local util = require("script/script_util")
local names = require("shared")
local teleporter_name = names.entities.teleporter
local teleporter_sticker = names.entities.teleporter_sticker

local data =
{
  networks = {},
  rename_frames = {},
  button_actions = {},
  teleporter_map = {},
  teleporter_frames = {},
  player_linked_teleporter = {},
  to_be_removed = {},
  tag_map = {},
  search_boxes = {},
  recent = {}
}

local preview_size = 256

local debug_print = false
local print = function(string)
  if not debug_print then return end
  game.print(string)
  log(string)
end

local create_flash = function(surface, position)
  surface.create_entity{name = "teleporter-explosion", position = position}
  for k = 1, 3 do
    surface.create_entity{name = "teleporter-explosion-no-sound", position = position}
  end
end

local clear_gui = function(frame)
  if not (frame and frame.valid) then return end
  util.deregister_gui(frame, data.button_actions)
  frame.clear()
end

local close_gui = function(frame)
  if not (frame and frame.valid) then return end
  util.deregister_gui(frame, data.button_actions)
  frame.destroy()
end

local get_rename_frame = function(player)
  local frame = data.rename_frames[player.index]
  if frame and frame.valid then return frame end
  data.rename_frames[player.index] = nil
end

local get_teleporter_frame = function(player)
  local frame = data.teleporter_frames[player.index]
  if frame and frame.valid then return frame end
  data.teleporter_frames[player.index] = nil
end

local make_rename_frame = function(player, caption)

  local teleporter_frame = get_teleporter_frame(player)
  if teleporter_frame then
    teleporter_frame.ignored_by_interaction = true
  end

  player.opened = nil

  local force = player.force
  local teleporters = data.networks[force.name]
  local param = teleporters[caption]
  local text = param.flying_text
  local gui = player.gui.screen
  local frame = gui.add{type = "frame", caption = {"gui-train-rename.title", caption}, direction = "horizontal"}
  frame.auto_center = true
  player.opened = frame
  data.rename_frames[player.index] = frame



  local textfield = frame.add{type = "textfield", text = caption}
  textfield.style.horizontally_stretchable = true
  textfield.focus()
  textfield.select_all()
  util.register_gui(data.button_actions, textfield, {type = "confirm_rename_textfield", textfield = textfield, flying_text = text, tag = param.tag})

  local confirm = frame.add{type = "sprite-button", sprite = "utility/enter", style = "tool_button", tooltip = {"gui-train-rename.perform-change"}}
  util.register_gui(data.button_actions, confirm, {type = "confirm_rename_button", textfield = textfield, flying_text = text, tag = param.tag})

end

local get_force_color = function(force)
  local player = force.connected_players[1]
  if player and player.valid then
    return player.chat_color
  end
  return {r = 1, b = 1, g = 1}
end

local add_recent = function(player, teleporter)
  local recent = data.recent[player.name]
  if not recent then
    recent = {}
    data.recent[player.name] = recent
  end
  recent[teleporter.unit_number] = game.tick
  if table_size(recent) >= 9 then
    local min = math.huge
    local index
    for k, tick in pairs (recent) do
      if tick < min then
        min = tick
        index = k
      end
    end
    if index then recent[index] = nil end
  end
end

local unlink_teleporter = function(player)
  if player.character then player.character.active = true end
  close_gui(get_teleporter_frame(player))
  local source = data.player_linked_teleporter[player.index]
  if source and source.valid then
    source.active = true
    add_recent(player, source)
  end
  data.player_linked_teleporter[player.index] = nil
end

local clear_teleporter_data = function(teleporter_data)
  local flying_text = teleporter_data.flying_text
  if flying_text and flying_text.valid then
    flying_text.destroy()
  end
  local map_tag = teleporter_data.tag
  if map_tag and map_tag.valid then
    data.tag_map[map_tag.tag_number] = nil
    map_tag.destroy()
  end
end


local get_sort_function = function()
  return
  function(t, a, b) return a < b end
end

local make_teleporter_gui = function(player, source)

  local location
  local teleporter_frame = get_teleporter_frame(player)
  if teleporter_frame then
    location = teleporter_frame.location
    data.teleporter_frames[player.index] = nil
    print("Frame already exists")
    close_gui(teleporter_frame)
    player.opened = nil
  end

  print("Making new frame")

  if not (source and source.valid and not data.to_be_removed[source.unit_number]) then
    unlink_teleporter(player)
    return
  end

  local force = source.force
  local network = data.networks[force.name]
  if not network then return end

  local gui = player.gui.screen
  local frame = gui.add{type = "frame", direction = "vertical", ignored_by_interaction = false}
  if location then
    frame.location = location
  else
    frame.auto_center = true
  end

  player.opened = frame
  data.teleporter_frames[player.index] = frame
  frame.ignored_by_interaction = false
  local title_flow = frame.add{type = "flow", direction = "horizontal"}
  title_flow.style.vertical_align = "center"
  local title = title_flow.add{type = "label", style = "heading_1_label"}
  title.drag_target = frame
  local rename_button = title_flow.add{type = "sprite-button", sprite = "utility/rename_icon_small_white", style = "frame_action_button", visible = source.force == player.force}
  local pusher = title_flow.add{type = "empty-widget", direction = "horizontal", style = "draggable_space_header"}
  pusher.style.horizontally_stretchable = true
  pusher.style.vertically_stretchable = true
  pusher.drag_target = frame
  local search_box = title_flow.add{type = "textfield", visible = false}
  local search_button = title_flow.add{type = "sprite-button", style = "frame_action_button", sprite = "utility/search_white", tooltip = {"gui.search-with-focus", {"search"}}}
  util.register_gui(data.button_actions, search_button, {type = "search_button", box = search_box})
  data.search_boxes[player.index] = search_box
  local inner = frame.add{type = "frame", style = "inside_deep_frame"}
  local scroll = inner.add{type = "scroll-pane", direction = "vertical"}
  scroll.style.maximal_height = (player.display_resolution.height / player.display_scale) * 0.8
  local column_count = ((player.display_resolution.width / player.display_scale) * 0.6) / preview_size
  local holding_table = scroll.add{type = "table", column_count = column_count}
  util.register_gui(data.button_actions, search_box, {type = "search_text_changed", parent = holding_table})
  holding_table.style.horizontal_spacing = 2
  holding_table.style.vertical_spacing = 2
  local any = false
  --print(table_size(network))

  local recent = data.recent[player.name] or {}

  local sorted = {}
  local i = 1
  for name, teleporter in pairs (network) do
    if teleporter.teleporter.valid then
      sorted[i] = {name = name, teleporter = teleporter, unit_number = teleporter.teleporter.unit_number}
      i = i + 1
    else
      clear_teleporter_data(teleporter)
    end
  end

  table.sort(sorted, function(a, b)
    if recent[a.unit_number] and recent[b.unit_number] then  
      return recent[a.unit_number] > recent[b.unit_number]
    end

    if recent[a.unit_number] then
      return true
    end

    if recent[b.unit_number] then
      return false
    end

    return a.name:lower() < b.name:lower()
  end)

  local sorted_network = {}
  for k, sorted_data in pairs (sorted) do
    sorted_network[sorted_data.name] = sorted_data.teleporter
  end

  local chart = player.force.chart
  for name, teleporter in pairs(sorted_network) do
    local teleporter_entity = teleporter.teleporter
    if not (teleporter_entity.valid) then
      clear_teleporter_data(teleporter)
    elseif teleporter_entity == source then
      title.caption = name
      util.register_gui(data.button_actions, rename_button, {type = "rename_button", caption = name})
    else
      local position = teleporter_entity.position
      local area = {{position.x - preview_size / 2, position.y - preview_size / 2}, {position.x + preview_size / 2, position.y + preview_size / 2}}
      chart(teleporter_entity.surface, area)
      local button = holding_table.add{type = "button", name = "_"..name}
      button.style.height = preview_size + 32 + 8
      button.style.width = preview_size + 8
      button.style.left_padding = 0
      button.style.right_padding = 0
      local inner_flow = button.add{type = "flow", direction = "vertical", ignored_by_interaction = true}
      inner_flow.style.vertically_stretchable = true
      inner_flow.style.horizontally_stretchable = true
      inner_flow.style.horizontal_align = "center"
      local map = inner_flow.add
      {
        type = "minimap",
        surface_index = teleporter_entity.surface.index,
        zoom = 1,
        force = teleporter_entity.force.name,
        position = position,
      }
      map.ignored_by_interaction = true
      map.style.height = preview_size
      map.style.width = preview_size
      map.style.horizontally_stretchable = true
      map.style.vertically_stretchable = true
      local caption = name
      if recent[teleporter_entity.unit_number] then
        caption = "[img=quantity-time] "..name
      end
      local label = inner_flow.add{type = "label", caption = caption}
      label.style.horizontally_stretchable = true
      label.style.font = "default-dialog-button"
      label.style.font_color = {}
      label.style.horizontally_stretchable = true
      label.style.maximal_width = preview_size
      util.register_gui(data.button_actions, button, {type = "teleport_button", param = teleporter})
      any = true
    end
  end
  if not any then
    holding_table.add{type = "label", caption = {"no-teleporters"}}
  end
end

function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end

local refresh_teleporter_frames = function()
  local players = game.players
  for player_index, source in pairs (data.player_linked_teleporter) do
    local player = players[player_index]
    local frame = get_teleporter_frame(player)
    if frame then
      print("Refreshing frame")
      make_teleporter_gui(player, source)
    end
  end
end

local check_player_linked_teleporter = function(player)
  print("Checking player linked teleporter")
  local source = data.player_linked_teleporter[player.index]
  if source and source.valid then
    print("Linked teleporter exists...")
    make_teleporter_gui(player, source)
  else
    print("Unlinnkgin")
    unlink_teleporter(player)
  end
end

local resync_teleporter = function(name, teleporter_data)
  local teleporter = teleporter_data.teleporter
  if not (teleporter and teleporter.valid) then
    return
  end
  local force = teleporter.force
  local surface = teleporter.surface
  local color = get_force_color(force)

  clear_teleporter_data(teleporter_data)

  local flying_text = teleporter.surface.create_entity
  {
    name = "teleporter-flying-text",
    text = name,
    position = {teleporter.position.x, teleporter.position.y - 2},
    force = force,
    color = color
  }
  flying_text.active = false
  teleporter_data.flying_text = flying_text

  data.adding_tag = true
  local map_tag = force.add_chart_tag(surface,
  {
    icon = {type = "item", name = teleporter_name},
    position = teleporter.position,
    text = name
  })
  data.adding_tag = false

  if map_tag then
    teleporter_data.tag = map_tag
    data.tag_map[map_tag.tag_number] = teleporter_data
  end

end

local is_name_available = function(force, name)
  local network = data.networks[force.name]
  return not network[name]
end

local rename_teleporter = function(force, old_name, new_name)
  if old_name == new_name then
    refresh_teleporter_frames()
    return
  end
  local network = data.networks[force.name]
  local teleporter_data = network[old_name]
  network[new_name] = teleporter_data
  network[old_name] = nil
  resync_teleporter(new_name, teleporter_data)
  refresh_teleporter_frames()
end

local gui_actions =
{
  rename_button = function(event, param)
    make_rename_frame(game.get_player(event.player_index), param.caption)
  end,
  cancel_rename = function(event, param)
    local player = game.get_player(event.player_index)
    close_gui(get_rename_frame(player))

    print("On cancel rename linked check")
    check_player_linked_teleporter(player)
  end,
  confirm_rename_button = function(event, param)
    if event.name ~= defines.events.on_gui_click then return end
    local flying_text = param.flying_text
    if not (flying_text and flying_text.valid) then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local old_name = flying_text.text
    local new_name = param.textfield.text

    if new_name ~= old_name and not is_name_available(player.force, new_name) then
      player.print({"name-already-taken"})
      return
    end

    close_gui(get_rename_frame(player))
    rename_teleporter(player.force, old_name, new_name)

    print("On rename linked check")
    --check_player_linked_teleporter(player)
  end,
  confirm_rename_textfield = function(event, param)
    if event.name ~= defines.events.on_gui_confirmed then return end
    local flying_text = param.flying_text
    if not (flying_text and flying_text.valid) then return end
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    local old_name = flying_text.text
    local new_name = param.textfield.text

    if new_name ~= old_name and not is_name_available(player.force, new_name) then
      player.print({"name-already-taken"})
      return
    end

    close_gui(get_rename_frame(player))
    rename_teleporter(player.force, old_name, new_name)

    print("On rename linked check")
    --check_player_linked_teleporter(player)
  end,
  teleport_button = function(event, param)
    local teleport_param = param.param
    if not teleport_param then return end
    local destination = teleport_param.teleporter
    if not (destination and destination.valid) then return end
    destination.timeout = destination.prototype.timeout
    local destination_surface = destination.surface
    local destination_position = destination.position
    local player = game.players[event.player_index]
    if not (player and player.valid) then return end
    create_flash(destination_surface, destination_position)
    create_flash(player.surface, player.position)
    --This teleport doesn't check collisions. If someone complains, make it check 'can_place' and if false find a positions etc....
    player.teleport(destination_position, destination_surface)
    unlink_teleporter(player)
    add_recent(player, destination)
  end,

  search_text_changed = function(event, param)
    local box = event.element
    local search = box.text
    local parent = param.parent
    for k, child in pairs (parent.children) do
      child.visible = child.name:lower():find(search:lower(), 1, true)
    end
  end,
  search_button = function(event, param)
    param.box.visible = not param.box.visible
    if param.box.visible then param.box.focus() end
  end
}

local get_network = function(force)
  local name = force.name
  local network = data.networks[name]
  if network then return network end
  data.networks[name] = {}
  return data.networks[name]
end

local on_built_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end
  if entity.name ~= teleporter_name then return end
  local surface = entity.surface
  local force = entity.force
  local name = "Teleporter ".. entity.unit_number
  local network = get_network(force)
  local teleporter_data = {teleporter = entity, flying_text = text, tag = tag}
  network[name] = teleporter_data
  data.teleporter_map[entity.unit_number] = teleporter_data
  resync_teleporter(name, teleporter_data)
  refresh_teleporter_frames()
end

local on_teleporter_removed = function(entity)
  if not (entity and entity.valid) then return end
  if entity.name ~= teleporter_name then return end
  local force = entity.force
  local teleporter_data = data.teleporter_map[entity.unit_number]
  if not teleporter_data then return end
  local caption = teleporter_data.flying_text.text
  local network = get_network(force)
  network[caption] = nil
  clear_teleporter_data(teleporter_data)
  data.teleporter_map[entity.unit_number] = nil

  data.to_be_removed[entity.unit_number] = true
  refresh_teleporter_frames()
  data.to_be_removed[entity.unit_number] = nil
end

local teleporter_triggered = function(entity, character)
  if not (entity and entity.valid and entity.name == teleporter_name) then return error("HEOK") end
  if character.type ~= "character" then return end
  local force = entity.force
  local surface = entity.surface
  local position = entity.position
  local param = data.teleporter_map[entity.unit_number]
  local player = character.player
  if not player then return end
  player.teleport(entity.position)
  entity.active = false
  entity.timeout = entity.prototype.timeout
  character.active = false
  data.player_linked_teleporter[player.index] = entity
  make_teleporter_gui(player, entity)
end

local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  on_teleporter_removed(entity)
end


local on_entity_died = function(event)
  on_teleporter_removed(event.entity)
end

local on_player_mined_entity = function(event)
  on_teleporter_removed(event.entity)
end

local on_robot_mined_entity = function(event)
  on_teleporter_removed(event.entity)
end

local on_gui_action = function(event)
  local element = event.element
  if not (element and element.valid) then return end
  local player_data = data.button_actions[event.player_index]
  if not player_data then return end
  local action = player_data[element.index]
  if action then
    gui_actions[action.type](event, action)
    return true
  end
end


local on_gui_closed = function(event)
  --print("CLOSED "..event.tick)
  local element = event.element
  if not element then return end

  local player = game.get_player(event.player_index)

  local rename_frame = get_rename_frame(player)
  if rename_frame and rename_frame == element then
    close_gui(rename_frame)
    print("Closed rename frame, checking player linked")
    check_player_linked_teleporter(player)
    return
  end

  local teleporter_frame = get_teleporter_frame(player)
  if teleporter_frame and teleporter_frame == element and not teleporter_frame.ignored_by_interaction then
    close_gui(teleporter_frame)
    unlink_teleporter(player)
    print("Frame unlinked")
    return
  end

end

local on_player_removed = function(event)
  local player = game.get_player(event.player_index)
  close_gui(get_rename_frame(player))
  unlink_teleporter(player)
end

local resync_all_teleporters = function()
  for force, network in pairs (data.networks) do
    for name, teleporter_data in pairs (network) do
      resync_teleporter(name, teleporter_data)
    end
  end
end

local on_chart_tag_modified = function(event)
  local force = event.force
  local tag = event.tag
  if not (force and force.valid and tag and tag.valid) then return end
  local teleporter_data = data.tag_map[tag.tag_number]
  if not teleporter_data then
    --Nothing to do with us...
    return
  end
  local player = event.player_index and game.get_player(event.player_index)

  local old_name = event.old_text
  local new_name = tag.text
  if tag.icon and tag.icon.name ~= teleporter_name then
    --They're trying to modify the icon! Straight to JAIL!
    if player and player.valid then player.print({"cant-change-icon"}) end
    tag.icon = {type = "item", name = teleporter_name}
  end
  if new_name == old_name then
    return
  end
  if new_name == "" or not is_name_available(force, new_name) then
    if player and player.valid then
      player.print({"name-already-taken"})
    end
    tag.text = old_name
    return
  end
  rename_teleporter(force, old_name, new_name)
end

local on_chart_tag_removed = function(event)
  local force = event.force
  local tag = event.tag
  if not (force and force.valid and tag and tag.valid) then return end
  local teleporter_data = data.tag_map[tag.tag_number]
  if not teleporter_data then
    --Nothing to do with us...
    return
  end
  local name = tag.text
  resync_teleporter(name, teleporter_data)
end

local on_chart_tag_added = function(event)
  if data.adding_tag then return end
  local tag = event.tag
  if not (tag and tag.valid) then
    return
  end
  local icon = tag.icon
  if icon and icon.type == "item" and icon.name == teleporter_name then
    --Trying to add a fake teleporter tag! JAIL!
    local player = event.player_index and game.get_player(event.player_index)
    if player and player.valid then player.print({"cant-add-tag"}) end
    tag.destroy()
    return
  end
end

local toggle_search = function(player)
  local box = data.search_boxes[player.index]
  if not (box and box.valid) then return end
  box.visible = true
  box.focus()
end

local on_search_focused = function(event)
  local player = game.get_player(event.player_index)
  toggle_search(player)
end

local on_player_display_resolution_changed = function(event)
  local player = game.get_player(event.player_index)
  check_player_linked_teleporter(player)
end

local on_player_display_scale_changed = function(event)
  local player = game.get_player(event.player_index)
  check_player_linked_teleporter(player)
end

local on_trigger_created_entity = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end
  if entity.name ~= teleporter_sticker then return end
  local source = event.source
  if not (source and source.valid) then return end
  local stuck_to = entity.sticked_to
  if not (stuck_to and stuck_to.valid) then return end
  teleporter_triggered(source, stuck_to)
end




local on_rocket_launched = function(event)
  local rocket = event.rocket
  if not (rocket and rocket.valid) then return end

  local count = rocket.get_item_count(teleporter_name)
  if count == 0 then return end

  local rand = math.random
  local rando = function(i)
    return rand() * (i or 5)
  end

  local rando_autoplace = function(i)
    return
    {
      frequency = rando(i),
      richness = rando(i),
      size = rando(i)
    }
  end

  local settings = rocket.surface.map_gen_settings

  for name, autoplace in pairs(settings.autoplace_controls) do
    settings.autoplace_controls[name] = rando_autoplace(rando(2))
  end

  settings.cliff_settings =
  {
    cliff_elevation_0 = rando(20),
    cliff_elevation_interval = rando(80),
    name = "cliff",
    richness = 1
  }

  settings.seed = math.floor(rando(2 ^ 32))
  settings.terrain_segmentation = rando(3)
  settings.water = rando(3)
  settings.starting_area = rando(3)

  local new_surface = game.create_surface("teleporter_surface"..game.tick..settings.seed, settings)

  new_surface.create_entity{name = teleporter_name, position = {0, 0}, force = rocket.force, raise_built = true}

end

local teleporters = {}

teleporters.events =
{
  [defines.events.on_built_entity] = on_built_entity,
  [defines.events.on_robot_built_entity] = on_built_entity,
  [defines.events.script_raised_built] = on_built_entity,
  [defines.events.script_raised_revive] = on_built_entity,
  [defines.events.on_entity_cloned] = on_built_entity,

  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,

  [defines.events.on_gui_click] = on_gui_action,
  [defines.events.on_gui_text_changed] = on_gui_action,
  [defines.events.on_gui_confirmed] = on_gui_action,
  [defines.events.on_gui_closed] = on_gui_closed,
  [require("shared").hotkeys.focus_search] = on_search_focused,
  [defines.events.on_player_display_resolution_changed] = on_player_display_resolution_changed,
  [defines.events.on_player_display_scale_changed] = on_player_display_scale_changed,

  [defines.events.on_player_died] = on_player_removed,
  [defines.events.on_player_left_game] = on_player_removed,
  [defines.events.on_player_changed_force] = on_player_removed,

  [defines.events.on_chart_tag_modified] = on_chart_tag_modified,
  [defines.events.on_chart_tag_removed] = on_chart_tag_removed,
  [defines.events.on_chart_tag_added] = on_chart_tag_added,

  [defines.events.on_trigger_created_entity] = on_trigger_created_entity,
  [defines.events.on_rocket_launched] = on_rocket_launched

}

teleporters.on_init = function()
  global.teleporters = global.teleporters or data
end

teleporters.on_load = function()
  data = global.teleporters
end

teleporters.on_configuration_changed = function()
  -- 0.1.2 migration...
  data.player_linked_teleporter = data.player_linked_teleporter or {}
  data.rename_frames = data.rename_frames or data.frames or {}
  data.to_be_removed = data.to_be_removed or {}

  --0.1.5...
  data.teleporter_map = data.teleporter_map or data.map or {}
  data.tag_map = data.tag_map or {}
  resync_all_teleporters()

  --0.1.7...
  data.search_boxes = data.search_boxes or {}

  data.recent = data.recent or {}
end

return teleporters
