local primitive_rails = {
  ["straight-scrap-rail"] = true,
  ["half-diagonal-scrap-rail"] = true,
  ["curved-scrap-rail"] = true,
  ["curved-scrap-rail-b"] = true,
}

-- Factorio reports train speed in tiles per tick: 80 km/h / (60 ticks/s * 3.6) = 10/27.
local damage_speed = 10 / 27
local damage_budget = 64

local function enqueue_rail(queue, rail, damage)
  local id = rail.unit_number
  if queue.entries[id] then
    queue.entries[id].damage = queue.entries[id].damage + damage
    return
  end
  queue.entries[id] = {rail = rail, damage = damage}
  if queue.last then
    queue.entries[queue.last].next = id
  else
    queue.first = id
  end
  queue.last = id
  queue.size = queue.size + 1
end

local function damage_released_rails(queue)
  -- A blocked segment goes to the back, so stopped trains cannot starve other entries.
  for _ = 1, math.min(queue.size, damage_budget) do
    local id = queue.first
    local entry = queue.entries[id]
    queue.first = entry.next
    queue.entries[id] = nil
    queue.size = queue.size - 1
    if not queue.first then
      queue.last = nil
    end

    local rail = entry.rail
    if rail.valid and primitive_rails[rail.name] then
      -- Wait until no train occupies the segment, including slow or stopped trains.
      if rail.can_be_destroyed() then
        rail.damage(entry.damage, "neutral", "impact")
      else
        enqueue_rail(queue, rail, entry.damage)
      end
    end
  end
end

script.on_nth_tick(20, function()
  -- Old experimental destruction marks have no speed history; cancel them once.
  if not storage.damaged_rails or storage.damaged_rails.version ~= 2 then
    storage.damaged_rails = {version = 2, entries = {}, size = 0}
  end
  local queue = storage.damaged_rails
  damage_released_rails(queue)

  -- Each sample adds 1 HP per excess km/h to every primitive rail under the train.
  -- Never change train speed; short sections may be crossed between checks.
  for _, train in pairs(game.train_manager.get_trains({is_moving = true})) do
    local speed = math.abs(train.speed)
    if speed > damage_speed then
      local damage = (speed - damage_speed) * 216
      for _, rail in pairs(train.get_rails()) do
        if rail.valid and primitive_rails[rail.name] then
          enqueue_rail(queue, rail, damage)
        end
      end
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
