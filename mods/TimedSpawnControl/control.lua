local mod_gui = require("mod-gui")

local COOLDOWN_TICKS = 60 * 60
local BUTTON_TAG = "timed_spawn_control"
local SPAWN_BUTTON = "spawn"
local UNSTUCK_BUTTON = "unstuck"

-- Overrun respawn point: when a player dies near their saved point and enemies are
-- within DANGER_RADIUS of it, a dialog offers to move the point by SHIFT_TILES in
-- one of eight directions while the player waits to respawn.
local SHIFT_FRAME = "timed_spawn_control_shift"
local SHIFT_TAG = "timed_spawn_control_shift"
local SHIFT_TILES = 64 -- 2 chunks
local DANGER_RADIUS = 64 -- 2 chunks around the saved point
local DEATH_RADIUS = 32 -- a death within 1 chunk of the saved point counts as "on the point"
local SHIFT_COOLDOWN_TICKS = 2 * 60 * 60 -- after a confirmed shift the dialog is replaced by a chat notice
local MINIMAP_SIZE = 200
local DIRECTION_BUTTON_SIZE = 56
-- The engine's centred "You died" notice must stay readable: place the dialog
-- below the screen centre (sizes in GUI pixels at scale 1). The fixed width
-- keeps both steps exactly centred horizontally.
local SHIFT_FRAME_WIDTH = 440
local SHIFT_FRAME_TOP_OFFSET = 90
local SHIFT_FRAME_MAX_HEIGHT = 330

-- Arrow glyphs come from the DejaVu fallback of the default fonts.
local DIRECTION_GRID = {
  {key = "nw", arrow = "↖", dx = -1, dy = -1},
  {key = "n", arrow = "↑", dx = 0, dy = -1},
  {key = "ne", arrow = "↗", dx = 1, dy = -1},
  {key = "w", arrow = "←", dx = -1, dy = 0},
  false,
  {key = "e", arrow = "→", dx = 1, dy = 0},
  {key = "sw", arrow = "↙", dx = -1, dy = 1},
  {key = "s", arrow = "↓", dx = 0, dy = 1},
  {key = "se", arrow = "↘", dx = 1, dy = 1},
}

local DIRECTION_BY_KEY = {}
for _, direction in pairs(DIRECTION_GRID) do
  if direction then
    DIRECTION_BY_KEY[direction.key] = direction
  end
end

local function ensure_state()
  storage.player_spawns = storage.player_spawns or {}
  storage.shift_prompts = storage.shift_prompts or {}
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
    -- Setting the point manually does not reset the shift cooldown.
    last_shift_tick = existing and existing.last_shift_tick or nil,
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

-- Overrun respawn point dialog --------------------------------------------------

local function close_shift_prompt(player_index)
  if storage.shift_prompts then
    storage.shift_prompts[player_index] = nil
  end
  local player = game.get_player(player_index)
  if player and player.valid then
    remove_element(player.gui.screen, SHIFT_FRAME)
  end
end

local function shifted_position(saved, direction)
  return {
    x = saved.position.x + direction.dx * SHIFT_TILES,
    y = saved.position.y + direction.dy * SHIFT_TILES,
  }
end

local function add_footer_button(footer, style, caption, action, enabled)
  local button = footer.add{
    type = "button",
    style = style,
    caption = caption,
    tags = {[SHIFT_TAG] = action},
  }
  if enabled == false then
    button.enabled = false
  end
  return button
end

local function build_shift_gui(player, prompt)
  local screen = player.gui.screen
  local old_frame = screen[SHIFT_FRAME]
  local location = old_frame and old_frame.valid and old_frame.location or nil
  remove_element(screen, SHIFT_FRAME)

  local saved = storage.player_spawns[player.index]
  if not saved then
    return
  end

  local frame = screen.add{type = "frame", name = SHIFT_FRAME, direction = "vertical"}
  if not location then
    local resolution = player.display_resolution
    local scale = player.display_scale
    local y = resolution.height / 2 + SHIFT_FRAME_TOP_OFFSET * scale
    y = math.min(y, resolution.height - SHIFT_FRAME_MAX_HEIGHT * scale)
    location = {
      x = math.max(0, math.floor((resolution.width - SHIFT_FRAME_WIDTH * scale) / 2)),
      y = math.max(0, math.floor(y)),
    }
  end
  frame.location = location
  frame.style.width = SHIFT_FRAME_WIDTH

  local titlebar = frame.add{type = "flow", direction = "horizontal"}
  titlebar.drag_target = frame
  local title_key = prompt.step == 2 and "timed-spawn-control.shift-direction-title" or "timed-spawn-control.shift-title"
  titlebar.add{type = "label", style = "frame_title", caption = {title_key}, ignored_by_interaction = true}
  local drag = titlebar.add{type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true}
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.left_margin = 4

  local content = frame.add{
    type = "frame",
    name = "content",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }
  content.style.horizontally_stretchable = true

  if prompt.step == 2 then
    local row = content.add{type = "flow", direction = "horizontal"}
    row.style.horizontal_spacing = 12
    row.style.vertical_align = "center"

    local grid = row.add{type = "table", name = "directions", column_count = 3}
    grid.style.horizontal_spacing = 4
    grid.style.vertical_spacing = 4
    for index = 1, 9 do
      local direction = DIRECTION_GRID[index]
      local button
      if direction then
        button = grid.add{
          type = "button",
          name = direction.key,
          caption = direction.arrow,
          tags = {[SHIFT_TAG] = "direction", direction = direction.key},
        }
        button.toggled = prompt.choice == direction.key
      else
        button = grid.add{type = "button", caption = "✖", enabled = false}
      end
      button.style.width = DIRECTION_BUTTON_SIZE
      button.style.height = DIRECTION_BUTTON_SIZE
      button.style.padding = 0
      button.style.font = "default-large-bold"
    end

    local choice = prompt.choice and DIRECTION_BY_KEY[prompt.choice]
    local center = choice and shifted_position(saved, choice) or saved.position
    local minimap = row.add{
      type = "minimap",
      name = "minimap",
      surface_index = prompt.surface_index,
      position = center,
      zoom = 1,
    }
    minimap.ignored_by_interaction = true
    minimap.style.width = MINIMAP_SIZE
    minimap.style.height = MINIMAP_SIZE

    -- Marker of the selected point: the minimap is always centred on it.
    local overlay = minimap.add{type = "flow", direction = "vertical", ignored_by_interaction = true}
    overlay.style.horizontally_stretchable = true
    overlay.style.vertically_stretchable = true
    overlay.style.width = MINIMAP_SIZE
    overlay.style.height = MINIMAP_SIZE
    overlay.style.horizontal_align = "center"
    overlay.style.vertical_align = "center"
    local marker = overlay.add{type = "label", name = "marker", caption = "●", ignored_by_interaction = true}
    marker.style.font = "default-large-bold"
    marker.style.font_color = choice and {1, 0.8, 0.3} or {1, 1, 1}
  else
    local warning = content.add{type = "label", caption = {"timed-spawn-control.shift-warning"}}
    warning.style.font = "default-bold"
    warning.style.font_color = {1, 0.55, 0.45}
    warning.style.single_line = false
    warning.style.maximal_width = 380
    local question = content.add{type = "label", caption = {"timed-spawn-control.shift-question"}}
    question.style.single_line = false
    question.style.maximal_width = 380
  end

  local footer = frame.add{type = "flow", style = "dialog_buttons_horizontal_flow", direction = "horizontal"}
  if prompt.step == 2 then
    add_footer_button(footer, "back_button", {"timed-spawn-control.shift-back"}, "back")
  else
    add_footer_button(footer, "red_back_button", {"timed-spawn-control.shift-keep"}, "keep")
  end
  local pusher = footer.add{type = "empty-widget", style = "draggable_space"}
  pusher.style.height = 32
  pusher.style.horizontally_stretchable = true
  pusher.drag_target = frame
  if prompt.step == 2 then
    add_footer_button(footer, "confirm_button", {"timed-spawn-control.shift-confirm"}, "confirm", prompt.choice ~= nil)
  else
    add_footer_button(footer, "confirm_button", {"timed-spawn-control.shift-move"}, "choose")
  end
end

local function select_shift_direction(player, prompt, key)
  local direction = DIRECTION_BY_KEY[key]
  local saved = storage.player_spawns[player.index]
  local frame = player.gui.screen[SHIFT_FRAME]
  if not direction or not saved or not frame then
    return
  end
  prompt.choice = key

  -- Update in place so a dragged window keeps its position.
  local content = frame.content
  local row = content and content.children[1]
  local grid = row and row.directions
  local minimap = row and row.minimap
  if not grid or not minimap then
    build_shift_gui(player, prompt)
    return
  end
  for _, button in pairs(grid.children) do
    if button.tags[SHIFT_TAG] == "direction" then
      button.toggled = button.tags.direction == key
    end
  end
  minimap.position = shifted_position(saved, direction)
  local overlay = minimap.children[1]
  local marker = overlay and overlay.marker
  if marker then
    marker.style.font_color = {1, 0.8, 0.3}
  end
  for _, child in pairs(frame.children) do
    for _, button in pairs(child.children) do
      if button.tags[SHIFT_TAG] == "confirm" then
        button.enabled = true
      end
    end
  end
end

local function confirm_shift(player, prompt)
  local saved = storage.player_spawns[player.index]
  local direction = prompt.choice and DIRECTION_BY_KEY[prompt.choice]
  local surface = saved and resolve_saved_surface(saved)
  if direction and surface and surface.index == prompt.surface_index then
    saved.position = shifted_position(saved, direction)
    saved.last_shift_tick = game.tick
    print_message(player, {"timed-spawn-control.shift-done", {"timed-spawn-control.direction-" .. direction.key}})
  else
    print_message(player, {"timed-spawn-control.shift-failed"})
  end
  close_shift_prompt(player.index)
end

local function handle_shift_click(player, element)
  ensure_state()
  local prompt = storage.shift_prompts[player.index]
  if not prompt then
    remove_element(player.gui.screen, SHIFT_FRAME)
    return
  end

  local action = element.tags[SHIFT_TAG]
  if action == "keep" then
    close_shift_prompt(player.index)
  elseif action == "choose" then
    prompt.step = 2
    build_shift_gui(player, prompt)
  elseif action == "back" then
    prompt.step = 1
    build_shift_gui(player, prompt)
  elseif action == "direction" then
    select_shift_direction(player, prompt, element.tags.direction)
  elseif action == "confirm" then
    confirm_shift(player, prompt)
  end
end

-- Runs before the character is gone: decide whether the dialog is needed.
local function check_overrun_on_death(event)
  ensure_state()
  storage.shift_prompts[event.player_index] = nil

  local player = game.get_player(event.player_index)
  if not player or not player.connected then
    return
  end
  local saved = storage.player_spawns[event.player_index]
  local character = get_character(player)
  if not saved or not character then
    return
  end
  local surface = resolve_saved_surface(saved)
  if not surface or character.surface.index ~= surface.index then
    return
  end

  local dx = character.position.x - saved.position.x
  local dy = character.position.y - saved.position.y
  if dx * dx + dy * dy > DEATH_RADIUS * DEATH_RADIUS then
    return
  end

  local enemy = surface.find_nearest_enemy{
    position = saved.position,
    max_distance = DANGER_RADIUS,
    force = player.force,
  }
  if not enemy then
    return
  end

  if saved.last_shift_tick then
    local remaining = SHIFT_COOLDOWN_TICKS - (game.tick - saved.last_shift_tick)
    if remaining > 0 then
      print_message(player, {"timed-spawn-control.shift-cooldown", math.ceil(remaining / 60)})
      return
    end
  end
  storage.shift_prompts[event.player_index] = {surface_index = surface.index, step = 1}
end

local function open_shift_prompt_after_death(event)
  ensure_state()
  local prompt = storage.shift_prompts[event.player_index]
  if not prompt then
    return
  end
  local player = game.get_player(event.player_index)
  if not player or not player.valid or not player.connected then
    close_shift_prompt(event.player_index)
    return
  end

  build_shift_gui(player, prompt)
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
  close_shift_prompt(event.player_index)
end)

script.on_event(defines.events.on_player_left_game, function(event)
  ensure_state()
  if storage.shift_prompts[event.player_index] then
    close_shift_prompt(event.player_index)
  end
end)

script.on_event(defines.events.on_pre_player_died, check_overrun_on_death)
script.on_event(defines.events.on_player_died, open_shift_prompt_after_death)

script.on_event(defines.events.on_gui_click, function(event)
  local element = event.element
  if not element or not element.valid then
    return
  end

  local player = game.get_player(event.player_index)
  if element.tags[SHIFT_TAG] then
    handle_shift_click(player, element)
    return
  end
  if not element.tags[BUTTON_TAG] then
    return
  end

  if element.name == SPAWN_BUTTON then
    set_player_spawn(player)
  elseif element.name == UNSTUCK_BUTTON then
    unstuck_player(player)
  end
end)

script.on_event(defines.events.on_player_respawned, function(event)
  ensure_state()
  if storage.shift_prompts[event.player_index] then
    close_shift_prompt(event.player_index)
  end
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
