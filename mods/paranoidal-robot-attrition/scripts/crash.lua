-- What happens to a crashing robot: an ordered list of steps, each function(robot, ctx).
-- A step may make the robot invalid; the following steps are then skipped.
local shared = require("shared")
local model = require("scripts.model")
local stats = require("scripts.stats")

local M = {}

-- Set by control.lua: id of the custom event raised for every crash.
M.event_id = nil

local cargo_inventory = defines.inventory.robot_cargo
local chest_inventory = defines.inventory.chest

-- Prototype data, identical on every peer.
local cargo_classes
local function cargo_class(name)
  if not cargo_classes then
    local mod_data = prototypes.mod_data[shared.cargo_data]
    cargo_classes = mod_data and mod_data.data or {explosive = {}, flammable = {}}
  end
  if cargo_classes.explosive[name] then return "explosive" end
  if cargo_classes.flammable[name] then return "flammable" end
end

local wreck_items = {}
local function wreck_item(robot_name)
  local name = wreck_items[robot_name]
  if name == nil then
    name = shared.wreck_item_prefix .. robot_name
    if not prototypes.item[name] then name = false end
    wreck_items[robot_name] = name
  end
  return name
end

-- Safety coverage and what the cargo does: explosive cargo always detonates and loses a share of the stack,
-- flammable cargo catches fire unless Swarm safety covers the network.
local function inspect(robot, ctx)
  ctx.covered = ctx.busy <= model.safety_level(ctx.force) * shared.safety_per_level
  ctx.detonate, ctx.ignite, ctx.wreck = false, false, nil
  local cargo = robot.get_inventory(cargo_inventory)
  if not cargo or cargo.is_empty() or not settings.global[shared.setting_cargo].value then return end
  local stack = cargo[1]
  local class = cargo_class(stack.name)
  if class == "explosive" then
    ctx.detonate = true
    local left = stack.count - math.ceil(stack.count * shared.explosive_loss)
    if left > 0 then stack.count = left else stack.clear() end
  elseif class == "flammable" and not ctx.covered then
    ctx.ignite = true
  end
end

-- The cargo and the wreck item go into an indestructible wreck marked for deconstruction; the cargo stack is moved
-- as a whole, so quality, spoilage and item data stay. The wreck item is always of normal quality.
-- Without a wreck entity both are spilled.
local function drop(robot, ctx)
  local cargo = robot.get_inventory(cargo_inventory)
  local stack = cargo and not cargo.is_empty() and cargo[1] or nil
  local wreck_name = wreck_item(robot.name)
  if not (stack or wreck_name) then return end
  local surface, force, position = ctx.surface, ctx.force, robot.position
  local wreck = surface.create_entity{name = shared.wreck_entity, position = position, force = force,
    create_build_effect_smoke = false}
  if wreck then
    wreck.destructible = false
    local inventory = wreck.get_inventory(chest_inventory)
    if stack then inventory[1].transfer_stack(stack) end
    if wreck_name then inventory.insert{name = wreck_name, count = 1} end
    if wreck.valid then
      wreck.order_deconstruction(force)
      ctx.wreck = wreck
    end
  else
    if wreck_name then
      surface.spill_item_stack{position = position, stack = {name = wreck_name, count = 1}, force = force,
        allow_belts = false}
    end
  end
  if stack and stack.valid_for_read then
    surface.spill_item_stack{position = position, stack = stack, force = force, allow_belts = false,
      drop_full_stack = true}
    stack.clear()
  end
end

-- At most one alert per force and surface in alert_interval, pointing at the wreck.
local function alert(robot, ctx)
  local wreck = ctx.wreck
  if not (wreck and wreck.valid) then return end
  local force_index, surface_index = ctx.force.index, ctx.surface.index
  local last = storage.alerts[force_index]
  if not last then
    last = {}
    storage.alerts[force_index] = last
  end
  if last[surface_index] and game.tick - last[surface_index] < shared.alert_interval then return end
  last[surface_index] = game.tick
  local icon = {type = "entity", name = robot.name}
  local message = {"pra.alert-crash", robot.prototype.localised_name}
  for _, player in pairs(ctx.force.connected_players) do
    if player.mod_settings[shared.setting_alerts].value then
      player.add_custom_alert(wreck, icon, message, true)
    end
  end
end

local function notify(robot, ctx)
  stats.add(ctx.force.index)
  alert(robot, ctx)
  if M.event_id then
    script.raise_event(M.event_id, {robot = robot, force = ctx.force, surface_index = ctx.surface.index,
      busy = ctx.busy, wreck = ctx.wreck, detonated = ctx.detonate, ignited = ctx.ignite})
  end
end

-- The robot leaves the network and counts as lost for its force; as a neutral robot killed without a cause it
-- raises no death alert (MxlChievements "Air Crash" counts exactly these deaths).
local function explode_and_die(robot, ctx)
  local force, surface, position = ctx.force, ctx.surface, robot.position
  force.get_kill_count_statistics(surface).on_flow(robot, -1)
  robot.force = "neutral"
  if not ctx.covered then
    surface.create_entity{name = shared.explosion_entity, position = position, force = "neutral"}
  end
  if ctx.detonate then
    surface.create_entity{name = shared.cargo_explosion_entity, position = position, force = "neutral"}
  end
  if ctx.ignite and prototypes.entity[shared.fire_entity] then
    surface.create_entity{name = shared.fire_entity, position = position, force = "neutral"}
  end
  if robot.valid then robot.die() end
end

M.steps = {inspect, drop, notify, explode_and_die}

function M.run(robot, ctx)
  local steps = M.steps
  for i = 1, #steps do
    steps[i](robot, ctx)
    if not robot.valid then return end
  end
end

return M
