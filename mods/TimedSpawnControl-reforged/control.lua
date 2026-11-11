local mod_gui = require("mod-gui")

local COOLDOWN_TICKS = 60 * 60
local UNSTUCK_SEARCH_COOLDOWN = 5 * 60
local MANAGE_FRAME = "timed_spawn_control_manage"
local MANAGE_TAG = "timed_spawn_control_manage"
local close_shift_prompt
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
  storage.player_actions = storage.player_actions or {}
end

-- Keep cooldowns after a reset, without changing the legacy spawn record layout.
local function player_actions(index)
  ensure_state()
  local actions = storage.player_actions[index]
  if not actions then
    local saved = storage.player_spawns[index]
    actions = {
      last_set_tick = saved and saved.last_set_tick,
      last_shift_tick = saved and saved.last_shift_tick,
    }
    storage.player_actions[index] = actions
  end
  return actions
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

local BUTTONS = {
  {name = SPAWN_BUTTON, caption = "set-spawn-caption", tooltip = "set-spawn-tooltip", sprite = "spawncontrol_button"},
  {name = UNSTUCK_BUTTON, caption = "unstuck-caption", tooltip = "unstuck-tooltip", sprite = "spawncontrol_random_button"},
}

local function close_dialog(player, name)
  local frame = player and player.valid and player.gui.screen[name]
  if not frame then return end
  local was_open = player.opened == frame
  frame.destroy()
  if was_open and player.opened == frame then player.opened = nil end
end

local function dialog_width(player)
  return math.max(180, math.min(SHIFT_FRAME_WIDTH, math.floor(player.display_resolution.width / player.display_scale) - 24))
end

local function position_dialog(player, frame, width, height, location)
  local resolution, scale = player.display_resolution, player.display_scale
  location = location or {
    x = (resolution.width - width * scale) / 2,
    y = resolution.height / 2 + SHIFT_FRAME_TOP_OFFSET * scale,
  }
  frame.location = {
    x = math.floor(math.max(0, math.min(location.x, resolution.width - width * scale))),
    y = math.floor(math.max(0, math.min(location.y, resolution.height - height * scale))),
  }
end

local function remove_legacy_button(parent, name)
  local button = parent[name]
  if button and (button.get_mod() == script.mod_name or button.get_mod() == "GUI_Unifyer") then button.destroy() end
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
  remove_legacy_button(top, "random")
  remove_legacy_button(button_flow, "random")
  remove_legacy_button(other, SPAWN_BUTTON)
  remove_legacy_button(other, UNSTUCK_BUTTON)

  for _, definition in ipairs(BUTTONS) do
    local button = target[definition.name]
    -- Tags cannot transfer ownership: replace legacy buttons created by GUI_Unifyer.
    if button and button.get_mod() == "GUI_Unifyer" then
      button.destroy()
      button = nil
    end
    local caption = {"timed-spawn-control." .. definition.caption}
    local tooltip = {"timed-spawn-control." .. definition.tooltip}
    if button and button.get_mod() ~= script.mod_name then
      log("TimedSpawnControl: toolbar name conflict: " .. definition.name .. "; foreign control left unchanged")
    else
      if button then
        update_button(button, caption, tooltip)
      else
        button = add_button(target, definition.name, caption, tooltip, use_unifier and definition.sprite or nil)
      end
      if not use_unifier then button.style.maximal_width = 300 end
    end
  end
end

local function ensure_all_guis()
  for _, player in pairs(game.players) do
    ensure_player_gui(player)
  end
end

local function find_unstuck_position(character, index)
  local surface, position = character.surface, character.position
  local result = surface.find_non_colliding_position(character.name, position, 3, 0.1, true)
  if result then return result end

  local actions = player_actions(index)
  local remaining = actions.last_unstuck_tick and UNSTUCK_SEARCH_COOLDOWN - (game.tick - actions.last_unstuck_tick) or 0
  if remaining > 0 then return nil, math.ceil(remaining / 60) end
  -- Charge attempts, including failed ones; keep the original long-range rescue.
  actions.last_unstuck_tick = game.tick
  for _, radius in ipairs({16, 64, 1000}) do
    result = surface.find_non_colliding_position(character.name, position, radius, 1)
    if result then return result end
  end
  return nil
end

local function find_respawn_position(character_name, surface, position)
  if not character_name or not prototypes.entity[character_name] then return nil end
  local result = surface.find_non_colliding_position(character_name, position, 3, 0.1)
  if not result then
    result = surface.find_non_colliding_position(character_name, position, 32, 1)
  end
  return result
end

local function unstuck_player(player)
  local character = get_character(player)
  if not character then
    print_message(player, {"timed-spawn-control.no-character"})
    return
  end

  local position, remaining = find_unstuck_position(character, player.index)
  if remaining then
    print_message(player, {"timed-spawn-control.unstuck-cooldown", remaining})
    return
  end
  if not position then
    print_message(player, {"timed-spawn-control.unstuck-no-position"})
    return
  end

  local ok, teleported = pcall(function()
    return character.teleport(position)
  end)
  if not ok or not teleported then
    if not ok then log("TimedSpawnControl unstuck: " .. tostring(teleported)) end
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

  local actions = player_actions(player.index)
  if actions.last_set_tick then
    local remaining = COOLDOWN_TICKS - (game.tick - actions.last_set_tick)
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
    last_shift_tick = actions.last_shift_tick,
  }
  actions.last_set_tick = game.tick
  close_shift_prompt(player.index)
  close_dialog(player, MANAGE_FRAME)
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

  local position = find_respawn_position(character.name, surface, saved.position)
  if not position then
    print_message(player, {"timed-spawn-control.respawn-no-position", surface.name})
    return
  end

  local ok, teleported = pcall(function()
    return player.teleport(position, surface)
  end)
  if not ok or not teleported then
    if not ok then log("TimedSpawnControl respawn: " .. tostring(teleported)) end
    print_message(player, {"timed-spawn-control.respawn-teleport-failed", surface.name})
  end
end

-- Overrun respawn point dialog --------------------------------------------------

close_shift_prompt = function(player_index)
  if storage.shift_prompts then
    storage.shift_prompts[player_index] = nil
  end
  local player = game.get_player(player_index)
  if player and player.valid then
    close_dialog(player, SHIFT_FRAME)
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
    name = action,
    style = style,
    caption = caption,
    tags = {[SHIFT_TAG] = action},
  }
  if enabled == false then
    button.enabled = false
  end
  return button
end

local function valid_shift_prompt(player, prompt)
  local saved = storage.player_spawns[player.index]
  local surface = saved and resolve_saved_surface(saved)
  -- on_player_died runs before the engine has necessarily assigned the respawn timer.
  -- Validate the snapshot here; only user actions require the waiting-to-respawn state.
  return saved and surface
    and surface.index == prompt.surface_index
    and prompt.origin and saved.position.x == prompt.origin.x and saved.position.y == prompt.origin.y
    and saved.last_set_tick == prompt.last_set_tick
    and prompt.character_name and prototypes.entity[prompt.character_name] ~= nil
end

local function wrapped_label(parent, name, caption, width)
  local label = parent.add{type = "label", name = name, caption = caption}
  label.style.single_line = false
  label.style.maximal_width = math.max(100, width - 52)
  return label
end

local function dialog_content(player, frame, width)
  local pane = frame.add{type = "scroll-pane", name = "content",
    horizontal_scroll_policy = "never", vertical_scroll_policy = "auto"}
  pane.style.horizontally_stretchable = true
  pane.style.maximal_height = math.max(60, math.floor(player.display_resolution.height / player.display_scale) - 130)
  return pane
end

local select_shift_direction

local function build_shift_gui(player, prompt, open_dialog)
  local screen = player.gui.screen
  local old_frame = screen[SHIFT_FRAME]
  local reopen = open_dialog ~= false or (old_frame and player.opened == old_frame)
  local location = old_frame and old_frame.valid and old_frame.location or nil
  remove_element(screen, SHIFT_FRAME)

  if not valid_shift_prompt(player, prompt) then
    close_shift_prompt(player.index)
    return
  end
  local saved = storage.player_spawns[player.index]
  local width = dialog_width(player)
  local frame = screen.add{type = "frame", name = SHIFT_FRAME, direction = "vertical"}
  frame.style.width = width
  position_dialog(player, frame, width, math.min(SHIFT_FRAME_MAX_HEIGHT,
    math.floor(player.display_resolution.height / player.display_scale)), location)

  local titlebar = frame.add{type = "flow", direction = "horizontal"}
  titlebar.drag_target = frame
  local title_key = prompt.step == 2 and "timed-spawn-control.shift-direction-title" or "timed-spawn-control.shift-title"
  local title = titlebar.add{type = "label", style = "frame_title", caption = {title_key}, ignored_by_interaction = true}
  title.style.single_line = false
  title.style.maximal_width = width - 52
  local drag = titlebar.add{type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true}
  drag.style.height = 24
  drag.style.horizontally_stretchable = true
  drag.style.left_margin = 4

  local content = dialog_content(player, frame, width)

  if prompt.step == 2 then
    local row = content.add{type = "flow", name = "row", direction = width < 430 and "vertical" or "horizontal"}
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
      local size = math.min(DIRECTION_BUTTON_SIZE, math.floor((width - 52) / 3))
      button.style.width = size
      button.style.height = size
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
    local map_size = math.min(MINIMAP_SIZE, width - 52)
    minimap.style.width = map_size
    minimap.style.height = map_size

    -- Marker of the selected point: the minimap is always centred on it.
    local overlay = minimap.add{type = "flow", name = "overlay", direction = "vertical", ignored_by_interaction = true}
    overlay.style.horizontally_stretchable = true
    overlay.style.vertically_stretchable = true
    overlay.style.width = map_size
    overlay.style.height = map_size
    overlay.style.horizontal_align = "center"
    overlay.style.vertical_align = "center"
    local marker = overlay.add{type = "label", name = "marker", caption = "●", ignored_by_interaction = true}
    marker.style.font = "default-large-bold"
    marker.style.font_color = choice and {1, 0.8, 0.3} or {1, 1, 1}
    wrapped_label(content, "status", {"timed-spawn-control.shift-select"}, width)
  else
    local warning = wrapped_label(content, "warning", {"timed-spawn-control.shift-warning"}, width)
    warning.style.font = "default-bold"
    warning.style.font_color = {1, 0.55, 0.45}
    wrapped_label(content, "question", {"timed-spawn-control.shift-question"}, width)
  end

  local footer = frame.add{type = "flow", name = "footer", style = "dialog_buttons_horizontal_flow", direction = "horizontal"}
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
    add_footer_button(footer, "confirm_button", {"timed-spawn-control.shift-confirm"}, "confirm", false)
  else
    add_footer_button(footer, "confirm_button", {"timed-spawn-control.shift-move"}, "choose")
  end
  if prompt.step == 2 and prompt.choice then
    select_shift_direction(player, prompt, prompt.choice)
  end
  if reopen then player.opened = frame end
end

select_shift_direction = function(player, prompt, key)
  local direction = DIRECTION_BY_KEY[key]
  local saved = storage.player_spawns[player.index]
  local frame = player.gui.screen[SHIFT_FRAME]
  if not direction or not saved or not frame then
    return
  end
  prompt.choice = key

  -- Update in place so a dragged window keeps its position.
  local content = frame.content
  local row = content and content.row
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
  local surface = resolve_saved_surface(saved)
  local nominal = shifted_position(saved, direction)
  local candidate = surface and find_respawn_position(prompt.character_name, surface, nominal)
  minimap.position = candidate or nominal
  local enemy = candidate and surface.find_nearest_enemy{
    position = candidate, max_distance = DANGER_RADIUS, force = player.force,
  }
  content.status.caption = {candidate and (enemy and "timed-spawn-control.shift-enemies" or "timed-spawn-control.shift-ready")
    or "timed-spawn-control.shift-no-position"}
  frame.footer.confirm.enabled = candidate ~= nil
  local overlay = minimap.overlay
  local marker = overlay and overlay.marker
  if marker then
    marker.style.font_color = {1, 0.8, 0.3}
  end
end

local function confirm_shift(player, prompt)
  local saved = storage.player_spawns[player.index]
  local direction = prompt.choice and DIRECTION_BY_KEY[prompt.choice]
  local surface = saved and resolve_saved_surface(saved)
  if not direction or player.ticks_to_respawn == nil or not valid_shift_prompt(player, prompt) then
    print_message(player, {"timed-spawn-control.shift-failed"})
    close_shift_prompt(player.index)
    return
  end
  -- Recheck on confirmation: the preview may already be occupied.
  local position = find_respawn_position(prompt.character_name, surface, shifted_position(saved, direction))
  if not position then
    print_message(player, {"timed-spawn-control.shift-no-position"})
    return
  end
  saved.position = position
  saved.last_shift_tick = game.tick
  player_actions(player.index).last_shift_tick = game.tick
  print_message(player, {"timed-spawn-control.shift-done", {"timed-spawn-control.direction-" .. direction.key}})
  close_shift_prompt(player.index)
end

local function handle_shift_click(player, element)
  ensure_state()
  local prompt = storage.shift_prompts[player.index]
  if not prompt or player.ticks_to_respawn == nil or not valid_shift_prompt(player, prompt) then
    close_shift_prompt(player.index)
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
  elseif action == "direction" and prompt.step == 2 then
    select_shift_direction(player, prompt, element.tags.direction)
  elseif action == "confirm" and prompt.step == 2 then
    confirm_shift(player, prompt)
  end
end

-- Runs before the character is gone: decide whether the dialog is needed.
local function check_overrun_on_death(event)
  ensure_state()
  close_shift_prompt(event.player_index)

  local player = game.get_player(event.player_index)
  close_dialog(player, MANAGE_FRAME)
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
  storage.shift_prompts[event.player_index] = {
    surface_index = surface.index, step = 1, character_name = character.name,
    origin = {x = saved.position.x, y = saved.position.y}, last_set_tick = saved.last_set_tick,
  }
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

-- Personal point management: right-click the existing Set Spawn button.
local function build_manage_gui(player, confirm_reset, open_dialog)
  ensure_state()
  local screen = player.gui.screen
  local old = screen[MANAGE_FRAME]
  local reopen = open_dialog ~= false or (old and player.opened == old)
  local location = old and old.location
  remove_element(screen, MANAGE_FRAME)
  local saved = storage.player_spawns[player.index]
  local surface = saved and resolve_saved_surface(saved)
  local width = dialog_width(player)
  local frame = screen.add{type = "frame", name = MANAGE_FRAME, direction = "vertical",
    tags = {confirm_reset = confirm_reset == true}}
  frame.style.width = width
  position_dialog(player, frame, width, SHIFT_FRAME_MAX_HEIGHT, location)
  local titlebar = frame.add{type = "flow", direction = "horizontal"}
  titlebar.drag_target = frame
  local title = titlebar.add{type = "label", style = "frame_title",
    caption = {"timed-spawn-control.manage-title"}, ignored_by_interaction = true}
  title.style.single_line = false
  title.style.maximal_width = width - 52
  local content = dialog_content(player, frame, width)
  if saved then
    wrapped_label(content, "point_location", {"timed-spawn-control.manage-location", saved.surface_name or "?",
      math.floor(saved.position.x), math.floor(saved.position.y)}, width)
    if surface then
      local minimap = content.add{type = "minimap", name = "minimap", surface_index = surface.index,
        position = saved.position, zoom = 1, ignored_by_interaction = true}
      minimap.style.size = math.min(MINIMAP_SIZE, width - 52)
    else
      wrapped_label(content, "missing", {"timed-spawn-control.manage-missing"}, width)
    end
  else
    wrapped_label(content, "empty", {"timed-spawn-control.manage-empty"}, width)
  end
  if confirm_reset then
    wrapped_label(content, "warning", {"timed-spawn-control.manage-reset-question"}, width)
  end
  local function action(parent, name, caption, enabled, style)
    return parent.add{type = "button", name = name, caption = {"timed-spawn-control." .. caption},
      enabled = enabled, style = style or "button", tags = {[MANAGE_TAG] = name}}
  end
  action(content, "set", "manage-set", get_character(player) ~= nil)
  action(content, "reset", confirm_reset and "manage-reset-confirm" or "manage-reset", saved ~= nil,
    confirm_reset and "red_button" or "button")
  local footer = frame.add{type = "flow", name = "footer", style = "dialog_buttons_horizontal_flow"}
  action(footer, "close", "manage-close", true, "back_button")
  local space = footer.add{type = "empty-widget", style = "draggable_space"}
  space.style.horizontally_stretchable = true
  space.drag_target = frame
  action(footer, "chart", "manage-chart", surface ~= nil)
  if reopen then player.opened = frame end
end

local function handle_manage_click(player, element)
  local frame = player.gui.screen[MANAGE_FRAME]
  if not frame then return end
  local action = element.tags[MANAGE_TAG]
  if action == "close" then
    close_dialog(player, MANAGE_FRAME)
  elseif action == "set" then
    set_player_spawn(player)
  elseif action == "reset" then
    if not storage.player_spawns[player.index] then return end
    if not frame.tags.confirm_reset then
      build_manage_gui(player, true)
      return
    end
    player_actions(player.index) -- Retain both cooldowns after removing the point.
    storage.player_spawns[player.index] = nil
    close_shift_prompt(player.index)
    close_dialog(player, MANAGE_FRAME)
    print_message(player, {"timed-spawn-control.spawn-reset"})
  elseif action == "chart" then
    local saved = storage.player_spawns[player.index]
    local surface = saved and resolve_saved_surface(saved)
    if surface then
      print_message(player, {"", {"timed-spawn-control.manage-title"}, ": ",
        string.format("[gps=%d,%d,%s]", math.floor(saved.position.x), math.floor(saved.position.y), surface.name)})
    end
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

local function import_renamed_mod()
  local migrated = storage._migrated
  local previous = migrated and migrated.TimedSpawnControl
  if type(previous) ~= "table" then return end
  -- Factorio migrates the old mod's storage and GUI ownership via migrates_from.
  -- Keep existing new-mod state if it exists; importing twice must not roll it back.
  for key, value in pairs(previous) do
    if key ~= "_migrated" then
      if storage[key] == nil then
        storage[key] = value
      elseif type(value) == "table" and type(storage[key]) == "table" then
        for id, entry in pairs(value) do
          if storage[key][id] == nil then storage[key][id] = entry end
        end
      end
    end
  end
  migrated.TimedSpawnControl = nil
end

local function initialize()
  import_renamed_mod()
  migrate_legacy_spawns()
  -- Old unconfirmed dialogs have no character prototype/origin. Do not guess.
  for index, prompt in pairs(storage.shift_prompts) do
    local player = game.get_player(index)
    if not player or player.ticks_to_respawn == nil or not valid_shift_prompt(player, prompt) then close_shift_prompt(index) end
  end
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
  storage.player_actions[event.player_index] = nil
  close_shift_prompt(event.player_index)
end)

script.on_event(defines.events.on_player_left_game, function(event)
  ensure_state()
  close_dialog(game.get_player(event.player_index), MANAGE_FRAME)
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
  if not player or not player.valid or element.get_mod() ~= script.mod_name then return end
  if element.tags[SHIFT_TAG] then
    handle_shift_click(player, element)
    return
  elseif element.tags[MANAGE_TAG] then
    handle_manage_click(player, element)
    return
  end
  if not element.tags[BUTTON_TAG] then
    return
  end

  if element.name == SPAWN_BUTTON then
    if event.button == defines.mouse_button_type.right then
      build_manage_gui(player)
    else
      set_player_spawn(player)
    end
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
  for _, player in pairs(game.players) do
    local saved = storage.player_spawns[player.index]
    if player.gui.screen[MANAGE_FRAME] and saved and saved.surface_index == event.surface_index then
      build_manage_gui(player, false, false)
    end
  end
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  ensure_state()
  for _, saved in pairs(storage.player_spawns) do
    if saved.surface_index == event.surface_index then saved.surface_deleted = true end
  end
  for index, prompt in pairs(storage.shift_prompts) do
    if prompt.surface_index == event.surface_index then close_shift_prompt(index) end
  end
  for _, player in pairs(game.players) do
    local frame = player.gui.screen[MANAGE_FRAME]
    local saved = storage.player_spawns[player.index]
    if frame and saved and saved.surface_index == event.surface_index then build_manage_gui(player, false, false) end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local element = event.element
  if not element or not element.valid or element.get_mod() ~= script.mod_name then return end
  if element.name == SHIFT_FRAME then
    close_shift_prompt(event.player_index)
  elseif element.name == MANAGE_FRAME then
    remove_element(game.get_player(event.player_index).gui.screen, MANAGE_FRAME)
  end
end)

local function resize_dialogs(event)
  local player = game.get_player(event.player_index)
  if not player or not player.valid then return end
  local prompt = storage.shift_prompts and storage.shift_prompts[event.player_index]
  if prompt and player.gui.screen[SHIFT_FRAME] then build_shift_gui(player, prompt, false) end
  local manage = player.gui.screen[MANAGE_FRAME]
  if manage then build_manage_gui(player, manage.tags.confirm_reset, false) end
end
script.on_event(defines.events.on_player_display_resolution_changed, resize_dialogs)
script.on_event(defines.events.on_player_display_scale_changed, resize_dialogs)
