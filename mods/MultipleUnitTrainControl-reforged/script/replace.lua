-- Swaps locomotives of a stopped train between the normal and the MU prototype.
-- The engine cannot change the prototype of an entity, so each locomotive is destroyed and created
-- again in the same place. Everything the player can see is carried over: quality, health, colour,
-- name, flags, driver, open GUIs, fuel (with the burning item and heat), equipment, item requests,
-- couplings, and the schedule, group and mode of the train.
local M = {}

local FRONT, BACK = defines.rail_direction.front, defines.rail_direction.back

-- Moves an inventory into a script inventory. The caller must pass the result to unstash.
local function stash(inventory)
  if not (inventory and inventory.valid) or inventory.is_empty() then return nil end
  local copy = game.create_inventory(#inventory)
  for i = 1, #inventory do copy[i].transfer_stack(inventory[i]) end
  return copy
end

-- Puts stashed stacks back slot by slot, inserts what does not fit, spills the rest, frees the copy.
local function unstash(copy, inventory, surface, position)
  if not copy then return end
  local usable = inventory and inventory.valid
  for i = 1, #copy do
    local stack = copy[i]
    if stack.valid_for_read and usable then
      if i <= #inventory then inventory[i].transfer_stack(stack) end
      if stack.valid_for_read then
        local inserted = inventory.insert(stack)
        if inserted >= stack.count then stack.clear() elseif inserted > 0 then stack.count = stack.count - inserted end
      end
    end
    if stack.valid_for_read then
      surface.spill_item_stack({position = position, stack = stack, allow_belts = false})
      stack.clear()
    end
  end
  copy.destroy()
end

local function save_burner(burner)
  if not burner then return nil end
  local burning = burner.currently_burning
  return {
    burning = burning and {name = burning.name.name, quality = burning.quality.name},
    remaining = burner.remaining_burning_fuel,
    heat = burner.heat,
    fuel = stash(burner.inventory),
    burnt = stash(burner.burnt_result_inventory),
  }
end

local function restore_burner(saved, burner, surface, position)
  if not saved then return end
  if burner then
    if saved.burning then
      burner.currently_burning = saved.burning
      burner.remaining_burning_fuel = saved.remaining
    end
    burner.heat = saved.heat
  end
  unstash(saved.fuel, burner and burner.inventory, surface, position)
  unstash(saved.burnt, burner and burner.burnt_result_inventory, surface, position)
end

local function save_grid(grid)
  if not (grid and grid.valid) then return nil end
  local list = {}
  for _, equipment in pairs(grid.equipment) do
    local ghost = equipment.type == "equipment-ghost"
    list[#list + 1] = {
      name = ghost and equipment.ghost_name or equipment.name,
      quality = equipment.quality.name,
      position = equipment.position,
      ghost = ghost,
      energy = equipment.energy,
      shield = equipment.shield,
      remove = equipment.to_be_removed,
      burner = save_burner(equipment.burner),
    }
  end
  return list
end

local function restore_grid(list, grid, surface, position)
  if not list then return end
  for _, saved in ipairs(list) do
    local equipment = grid and grid.valid and grid.put({name = saved.name, quality = saved.quality,
                                                        position = saved.position, ghost = saved.ghost})
    if equipment then
      if saved.energy > 0 then equipment.energy = saved.energy end
      if saved.shield > 0 then equipment.shield = saved.shield end
      restore_burner(saved.burner, equipment.burner, surface, position)
      if saved.remove then grid.order_removal(equipment) end
    else
      local item = not saved.ghost and prototypes.equipment[saved.name].take_result
      if item then
        surface.spill_item_stack({position = position, stack = {name = item.name, quality = saved.quality, count = 1},
                                  allow_belts = false})
      end
      restore_burner(saved.burner, nil, surface, position)
    end
  end
end

local function save_requests(entity)
  local plans = {}
  for _, proxy in pairs(entity.surface.find_entities_filtered({name = "item-request-proxy", position = entity.position,
                                                               force = entity.force})) do
    if proxy.proxy_target == entity then
      plans[#plans + 1] = {insert = proxy.insert_plan, removal = proxy.removal_plan}
    end
  end
  return plans
end

local function save_train(train)
  local schedule = train.get_schedule()
  return {
    group = train.group,
    records = schedule.get_records() or {},
    interrupts = schedule.get_interrupts() or {},
    current = schedule.current,
    manual = train.manual_mode,
  }
end

-- The group brings its own records and interrupts; temporary stops of this train are added back.
local function restore_train(train, saved)
  if saved.group and saved.group ~= "" then
    train.group = saved.group
    local schedule = train.get_schedule()
    for index, record in ipairs(saved.records) do
      if record.temporary then
        record.index = {schedule_index = index}
        schedule.add_record(record)
      end
    end
  else
    local schedule = train.get_schedule()
    schedule.set_records(saved.records)
    schedule.set_interrupts(saved.interrupts)
  end
  local schedule = train.get_schedule() -- writes above may invalidate earlier handles
  local count = schedule.get_record_count() or 0
  if saved.current and saved.current > 0 and saved.current <= count and schedule.current ~= saved.current then
    train.go_to_station(saved.current)
  end
  train.manual_mode = saved.manual
end

-- Replaces one locomotive. Returns the new entity, or nil if it could not be created: then the
-- locomotive item and all its contents are spilled on the ground.
local function replace_one(old, name)
  local surface, position, force, quality = old.surface, old.position, old.force, old.quality
  local saved = {
    orientation = old.orientation,
    health = old.health,
    color = old.color,
    backer_name = old.backer_name,
    copy_color = old.copy_color_from_train_stop,
    logistics = old.enable_logistics_while_moving,
    minable = old.minable_flag,
    destructible = old.destructible,
    operable = old.operable,
    last_user = old.last_user,
    driver = old.get_driver(),
    front = old.get_connected_rolling_stock(FRONT) ~= nil,
    back = old.get_connected_rolling_stock(BACK) ~= nil,
    burner = save_burner(old.burner),
    grid = save_grid(old.grid),
    requests = save_requests(old),
    viewers = {},
    item = old.prototype.items_to_place_this[1],
  }
  for _, player in pairs(game.connected_players) do
    if player.opened == old then saved.viewers[#saved.viewers + 1] = player end
  end

  old.destroy({raise_destroy = true})
  local new = surface.create_entity({
    name = name, position = position, orientation = saved.orientation, force = force, quality = quality,
    snap_to_train_stop = false, create_build_effect_smoke = false,
  })

  if not new then
    if saved.item then
      surface.spill_item_stack({position = position, allow_belts = false,
                                stack = {name = saved.item.name, quality = quality.name, count = 1}})
    end
    restore_burner(saved.burner, nil, surface, position)
    restore_grid(saved.grid, nil, surface, position)
    force.print({"mutc.replace-failed", saved.backer_name or "", position.x, position.y, surface.name})
    return nil
  end

  -- A created carriage couples to everything in reach; undo couplings the old one did not have.
  if not saved.front and new.get_connected_rolling_stock(FRONT) then new.disconnect_rolling_stock(FRONT) end
  if not saved.back and new.get_connected_rolling_stock(BACK) then new.disconnect_rolling_stock(BACK) end

  new.health = saved.health
  if saved.color then new.color = saved.color end
  if saved.backer_name then new.backer_name = saved.backer_name end
  new.copy_color_from_train_stop = saved.copy_color
  new.enable_logistics_while_moving = saved.logistics
  new.minable_flag = saved.minable
  new.destructible = saved.destructible
  new.operable = saved.operable
  if saved.last_user then new.last_user = saved.last_user end
  restore_burner(saved.burner, new.burner, surface, position)
  restore_grid(saved.grid, new.grid, surface, position)
  for _, request in ipairs(saved.requests) do
    surface.create_entity({name = "item-request-proxy", position = new.position, force = force, target = new,
                           modules = request.insert, removal_plan = request.removal})
  end
  if saved.driver and saved.driver.valid then new.set_driver(saved.driver) end
  for _, player in ipairs(saved.viewers) do
    if player.valid then player.opened = new end
  end
  script.raise_script_built({entity = new})
  return new
end

-- Replaces the given locomotives of one train ({entity, name} entries) and restores the train.
-- Returns the resulting train, or nil if nothing of it is left.
function M.batch(train, list)
  local saved = save_train(train)
  local carriages = train.carriages
  local result
  for _, entry in ipairs(list) do
    if entry.entity.valid then
      local new = replace_one(entry.entity, entry.name)
      if new then result = new end
    end
  end
  if not (result and result.valid) then
    for _, carriage in ipairs(carriages) do
      if carriage.valid then result = carriage break end
    end
  end
  local new_train = result and result.valid and result.train
  if new_train then restore_train(new_train, saved) end
  return new_train
end

return M
