local mod_gui = require("mod-gui")

local COOLDOWN_TICKS = 60 * 60
local BUTTON_TAG = "timed_spawn_control"
local SPAWN_BUTTON = "spawn"
local UNSTUCK_BUTTON = "unstuck"

local function ensure_state()
  storage.player_spawns = storage.player_spawns or {}
end

local function print_message(player, message)
  if player and player.valid then
    player.print(message)
  end
end

local function get_character(player)
  local character = player and player.valid and player.character
  if character and character.valid then
    return character
  end
  return nil
end

local function remove_element(parent, name)
  local element = parent and parent[name]
  if element and element.valid then
    element.destroy()
  end
end

local function add_button(parent, name, caption, tooltip, sprite)
  local definition = {
    name = name,
    tooltip = tooltip,
    tags = {[BUTTON_TAG] = true},
  }

  if sprite then
    definition.type = "sprite-button"
    definition.sprite = sprite
    definition.style = "slot_button"
  else
    definition.type = "button"
    definition.caption = caption
    definition.style = "timed-spawn-control-button"
  end

  return parent.add(definition)
end

local function update_button(element, caption, tooltip)
  element.tags = {[BUTTON_TAG] = true}
  element.tooltip = tooltip
  if element.type == "button" then
    element.caption = caption
  end
end

local function ensure_player_gui(player)
  if not player or not player.valid then
    return
  end

  local top = player.gui.top
  local button_flow = mod_gui.get_button_flow(player)
  local use_unifier = script.active_mods["GUI_Unifyer"] ~= nil
  local target = use_unifier and button_flow or top
  local other = use_unifier and top or button_flow

  -- Remove buttons left by the 1.1 version and by the former random-spawn integration.
  remove_element(top, "random")
  remove_element(button_flow, "random")
  remove_element(other, SPAWN_BUTTON)
  remove_element(other, UNSTUCK_BUTTON)

  local spawn = target[SPAWN_BUTTON]
  if not spawn then
    spawn = add_button(
      target,
      SPAWN_BUTTON,
      {"timed-spawn-control.set-spawn-caption"},
      {"timed-spawn-control.set-spawn-tooltip"},
      use_unifier and "spawncontrol_button" or nil
    )
  else
    update_button(spawn, {"timed-spawn-control.set-spawn-caption"}, {"timed-spawn-control.set-spawn-tooltip"})
  end

  local unstuck = target[UNSTUCK_BUTTON]
  if not unstuck then
    unstuck = add_button(
      target,
      UNSTUCK_BUTTON,
      {"timed-spawn-control.unstuck-caption"},
      {"timed-spawn-control.unstuck-tooltip"},
      use_unifier and "spawncontrol_random_button" or nil
    )
  else
    update_button(unstuck, {"timed-spawn-control.unstuck-caption"}, {"timed-spawn-control.unstuck-tooltip"})
  end
end

local function ensure_all_guis()
  for _, player in pairs(game.players) do
    ensure_player_gui(player)
  end
end

local function find_unstuck_position(character)
  local surface = character.surface
  local position = character.position
  local result = surface.find_non_colliding_position(character.name, position, 3, 0.1, true)
  if not result then
    result = surface.find_non_colliding_position(character.name, position, 1000, 1)
  end
  return result
end

local function find_respawn_position(character, surface, position)
  local result = surface.find_non_colliding_position(character.name, position, 3, 0.1)
  if not result then
    result = surface.find_non_colliding_position(character.name, position, 32, 1)
  end
  return result
end

local function unstuck_player(player)
  local character = get_character(player)
  if not character then
    print_message(player, {"timed-spawn-control.no-character"})
    return
  end

  local position = find_unstuck_position(character)
  if not position then
    print_message(player, {"timed-spawn-control.unstuck-no-position"})
    return
  end

  local ok, teleported = pcall(function()
    return character.teleport(position)
  end)
  if not ok or not teleported then
    print_message(player, {"timed-spawn-control.unstuck-teleport-failed"})
  end
end

local function set_player_spawn(player)
  ensure_state()

  local character = get_character(player)
  if not character then
    print_message(player, {"timed-spawn-control.no-character"})
    return
  end

  local existing = storage.player_spawns[player.index]
  if existing and existing.last_set_tick then
    local remaining = COOLDOWN_TICKS - (game.tick - existing.last_set_tick)
    if remaining > 0 then
      print_message(player, {"timed-spawn-control.cooldown", math.ceil(remaining / 60)})
      return
    end
  end

  local surface = character.surface
  if not surface or not surface.valid then
    print_message(player, {"timed-spawn-control.spawn-set-failed"})
    return
  end

  storage.player_spawns[player.index] = {
    player_name = player.name,
    position = {x = character.position.x, y = character.position.y},
    surface_index = surface.index,
    surface_name = surface.name,
    last_set_tick = game.tick,
  }
  print_message(player, {"timed-spawn-control.spawn-set"})
end

local function resolve_saved_surface(saved)
  if saved.surface_deleted then
    return nil
  end

  local surface = saved.surface_index and game.get_surface(saved.surface_index) or nil
  if not surface or not surface.valid or surface.name ~= saved.surface_name then
    return nil
  end
  return surface
end

local function respawn_at_saved_point(player)
  ensure_state()
  local saved = storage.player_spawns[player.index]
  if not saved then
    return
  end

  local character = get_character(player)
  if not character then
    print_message(player, {"timed-spawn-control.respawn-no-character"})
    return
  end

  local surface = resolve_saved_surface(saved)
  if not surface then
    print_message(player, {"timed-spawn-control.respawn-surface-missing", saved.surface_name or "?"})
    return
  end

  local position = find_respawn_position(character, surface, saved.position)
  if not position then
    print_message(player, {"timed-spawn-control.respawn-no-position", surface.name})
    return
  end

  local ok, teleported = pcall(function()
    return player.teleport(position, surface)
  end)
  if not ok or not teleported then
    print_message(player, {"timed-spawn-control.respawn-teleport-failed", surface.name})
  end
end

local function legacy_surface(legacy)
  local identifier = legacy.surface
  if type(identifier) == "number" or type(identifier) == "string" then
    return game.get_surface(identifier)
  end

  if identifier ~= nil then
    local ok, valid = pcall(function() return identifier.valid end)
    if ok and valid then
      return identifier
    end
  end
  return nil
end

local function finite_number(value)
  return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function migrate_legacy_spawns()
  ensure_state()
  if storage.timed_spawn_control_legacy_migrated then
    return
  end

  if type(storage.spawns) == "table" then
    for key, legacy in pairs(storage.spawns) do
      if type(legacy) == "table" and finite_number(legacy.x) and finite_number(legacy.y) then
        local player_name = type(legacy.player) == "string" and legacy.player or key
        local player = type(player_name) == "string" and game.get_player(player_name) or nil
        local surface = legacy_surface(legacy)
        if player and surface and surface.valid and not storage.player_spawns[player.index] then
          storage.player_spawns[player.index] = {
            player_name = player.name,
            position = {x = legacy.x, y = legacy.y},
            surface_index = surface.index,
            surface_name = surface.name,
            last_set_tick = finite_number(legacy.changeTick) and math.max(0, math.floor(legacy.changeTick)) or 0,
          }
        end
      end
    end
    storage.spawns = nil
  end

  storage.timed_spawn_control_legacy_migrated = true
end

local function initialize()
  migrate_legacy_spawns()
  ensure_all_guis()
end

script.on_init(initialize)
script.on_configuration_changed(initialize)

script.on_event(defines.events.on_player_created, function(event)
  ensure_state()
  ensure_player_gui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  ensure_state()
  local player = game.get_player(event.player_index)
  local saved = storage.player_spawns[event.player_index]
  if saved and player then
    saved.player_name = player.name
  end
  ensure_player_gui(player)
end)

script.on_event(defines.events.on_player_removed, function(event)
  ensure_state()
  storage.player_spawns[event.player_index] = nil
end)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not element or not element.valid or not element.tags[BUTTON_TAG] then
    return
  end

  local player = game.get_player(event.player_index)
  if element.name == SPAWN_BUTTON then
    set_player_spawn(player)
  elseif element.name == UNSTUCK_BUTTON then
    unstuck_player(player)
  end
end)

script.on_event(defines.events.on_player_respawned, function(event)
  respawn_at_saved_point(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_surface_renamed, function(event)
  ensure_state()
  for _, saved in pairs(storage.player_spawns) do
    if saved.surface_index == event.surface_index and saved.surface_name == event.old_name then
      saved.surface_name = event.new_name
    end
  end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  ensure_state()
  for _, saved in pairs(storage.player_spawns) do
    if saved.surface_index == event.surface_index then
      saved.surface_deleted = true
    end
  end
end)
