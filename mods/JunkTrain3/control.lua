local primitive_rails = {
  ["straight-scrap-rail"] = true,
  ["half-diagonal-scrap-rail"] = true,
  ["curved-scrap-rail"] = true,
  ["curved-scrap-rail-b"] = true,
}

-- Factorio reports train speed in tiles per tick: 54 km/h / (60 ticks/s * 3.6) = 1/4.
local speed_limit = 1 / 4

local function train_is_on_primitive_rail(train)
  for _, rail in pairs(train.get_rails()) do
    if primitive_rails[rail.name] then
      return true
    end
  end
  return false
end

-- Periodic slowdown, not a hard cap: trains may accelerate or cross short sections between checks.
script.on_nth_tick(20, function()
  -- Query only moving trains; no world-wide entity or rail scan is performed.
  for _, train in pairs(game.train_manager.get_trains({is_moving = true})) do
    local speed = train.speed
    if math.abs(speed) > speed_limit and train_is_on_primitive_rail(train) then
      train.speed = speed < 0 and -speed_limit or speed_limit
    end
  end
end)

local primitive_infrastructure = {
  ["train-stop-scrap"] = true,
  ["rail-signal-scrap"] = true,
  ["rail-chain-signal-scrap"] = true,
}

local function is_primitive_rail(rail)
  return rail and rail.valid and primitive_rails[rail.name] or false
end

local function infrastructure_has_primitive_rail(entity)
  if entity.type == "train-stop" then
    return is_primitive_rail(entity.connected_rail)
  end
  for _, rail in pairs(entity.get_connected_rails()) do
    if is_primitive_rail(rail) then
      return true
    end
  end
  return false
end

script.on_event(defines.events.on_robot_built_entity, function(event)
  local entity = event.entity
  if not (entity and entity.valid and primitive_infrastructure[entity.name]) then
    return
  end
  if infrastructure_has_primitive_rail(entity) then
    return
  end

  local item_name = entity.name
  local stack = {name = item_name, count = 1, quality = entity.quality.name}
  local surface, position, force = entity.surface, entity.position, entity.force
  if not entity.destroy() then
    return
  end

  local inserted = 0
  if event.robot and event.robot.valid then
    local cargo = event.robot.get_inventory(defines.inventory.robot_cargo)
    if cargo then
      inserted = cargo.insert(stack)
    end
  end
  if inserted < stack.count then
    stack.count = stack.count - inserted
    surface.spill_item_stack({
      position = position,
      stack = stack,
      force = force,
      allow_belts = false,
      use_start_position_on_failure = true,
    })
  end
  force.print({"message.invalid-rail-type-" .. item_name})
end)

-- Beta 8 only enforced primitive-track placement for construction robots: its manual
-- handler compared a string as if it were an item stack and therefore never rejected placement.
