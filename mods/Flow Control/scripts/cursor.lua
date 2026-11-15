local M = {}
local registry = prototypes.mod_data["flow-control-cursor"].data
-- Four elbow, four junction, two distinct straight orientations.
local shape_at_step = {[0] = 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4}
local first_step = {[0] = 0, 1, 5, 9}
local inventory_ids = {}
do
  local seen = {}
  for _, id in pairs(defines.inventory) do
    if not seen[id] then seen[id] = true; inventory_ids[#inventory_ids + 1] = id end
  end
  table.sort(inventory_ids)
end

local function states()
  storage.flow_control_cursor = storage.flow_control_cursor or {}
  return storage.flow_control_cursor
end

local function held(player)
  local stack = player.cursor_stack
  if stack and stack.valid_for_read then
    return stack.name, stack.quality.name, stack
  end
  local ghost = player.cursor_ghost
  if ghost then return ghost.name.name, ghost.quality.name end
end

local function replace(stack, name)
  -- Only rename the current physical stack; never reconstruct a saved count.
  -- Overfull stacks can exist in machine inputs or be supplied by other mods.
  if stack.count > prototypes.item[name].stack_size then return false end
  return stack.set_stack{name = name, count = stack.count,
    quality = stack.quality.name, health = stack.health}
end

local function restore_stack(stack)
  if not stack or not stack.valid_for_read then return end
  local info = registry.items[stack.name]
  if info and info.shape ~= 0 then replace(stack, info.base) end
end

local function restore_inventory(inventory)
  if not inventory or not inventory.valid then return end
  -- Do not scan slots for unrelated inventory changes.
  local has_fittings = false
  for _, item in pairs(inventory.get_contents()) do
    local info = registry.items[item.name]
    if info and info.shape ~= 0 then has_fittings = true; break end
  end
  if not has_fittings then return end
  for i = 1, #inventory do restore_stack(inventory[i]) end
end

local function restore_player_inventory(player)
  restore_inventory(player.get_main_inventory())
  restore_inventory(player.get_inventory(defines.inventory.character_trash))
end

local function restore_entity_inventory(entity)
  if not entity or not entity.valid or entity.object_name ~= "LuaEntity" then return end
  local seen = {}
  for _, id in ipairs(inventory_ids) do
    local inventory = entity.get_inventory(id)
    if inventory and not seen[inventory] then
      seen[inventory] = true
      restore_inventory(inventory)
    end
  end
end

function M.rotate(event, delta)
  if event.in_gui then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  local name, quality, stack = held(player)
  local info = name and registry.items[name]
  if not info then return end
  local all = states()
  local state = all[player.index]
  if not state or state.item ~= name or state.quality ~= quality then
    state = {base = info.base, step = first_step[info.shape], quality = quality}
  end
  local step = (state.step + delta) % 11
  local target = registry.families[info.base][shape_at_step[step]]
  if target ~= name then
    if stack then
      if not replace(stack, target) then return end
    else
      player.cursor_ghost = {name = target, quality = quality}
    end
  end
  state.step = step
  state.item = target
  all[player.index] = state
  -- consuming=none is intentional: the native rotate action runs AFTER this
  -- handler and supplies the actual preview/build direction for each fitting.
end

function M.clear(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local name, quality, stack = held(player)
  local info = name and registry.items[name]
  if info and info.shape ~= 0 then
    if stack then replace(stack, info.base)
    else player.cursor_ghost = {name = info.base, quality = quality} end
  end
  states()[player.index] = nil
end

function M.cursor_changed(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local all = states()
  local state = all[player.index]
  local name, quality, stack = held(player)
  if state and state.refill_tick and state.refill_tick == event.tick
    and not stack and (not name or name == state.item) then
    -- Cursor events are deferred until the build has actually consumed its item.
    -- Do not assume on_built_entity itself runs after cursor consumption.
    if player.pipette(prototypes.item[state.base], state.quality, false) then
      local refill_name, refill_quality, refill_stack = held(player)
      if refill_stack and refill_name == state.base and refill_quality == state.quality then
        replace(refill_stack, state.item)
      end
      name, quality = held(player)
    end
  end
  if state then state.refill_tick = nil end
  if state or (name and registry.items[name]) then
    -- Covers drag/split transfers into an opened chest/machine, not just Q.
    restore_entity_inventory(player.opened)
  end
  if state and (name ~= state.item or quality ~= state.quality) then
    restore_player_inventory(player)
    all[player.index] = nil
  end
end

function M.inventory_changed(event)
  local player = game.get_player(event.player_index)
  if player then restore_player_inventory(player) end
end

function M.dropped(event)
  if event.entity.valid then restore_stack(event.entity.stack) end
end

function M.transferred(event)
  -- Ctrl-click can transfer directly to a closed entity, without player.opened.
  restore_entity_inventory(event.entity)
end

function M.closed(event)
  restore_entity_inventory(event.entity)
end

function M.built(event)
  local state = states()[event.player_index]
  if not state or event.entity.name ~= state.item then return end
  -- Native refill looks for the fitting item, while our stock is ordinary pipe.
  -- Let the deferred cursor event replenish it, once consumption is complete.
  state.refill_tick = event.tick
end

function M.removed(event)
  states()[event.player_index] = nil
end

function M.configure()
  for _, player in pairs(game.players) do
    restore_entity_inventory(player.opened)
    M.clear{player_index = player.index}
    restore_player_inventory(player)
  end
end

return M
