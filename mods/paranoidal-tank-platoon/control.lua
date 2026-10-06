-- 1. Upgrading a tank by crafting returns the equipment of the consumed tank to the player.
-- 2. Vehicle clone placement: a vehicle built while driving the same vehicle type (or receiving
--    pasted settings) gets the same equipment, fuel, ammo and trunk contents from the player's inventory.

local VEHICLE_TYPES = {
  ["car"] = true, ["spider-vehicle"] = true, ["locomotive"] = true,
  ["cargo-wagon"] = true, ["fluid-wagon"] = true, ["artillery-wagon"] = true,
}

local COLOR_EMPTY = {r = 1, g = 0.14, b = 0}

local function quality_name(quality)
  if type(quality) == "table" then return quality.name end
  return quality or "normal"
end

local function show_texts(player, position, lines)
  for index, line in pairs(lines) do
    player.create_local_flying_text({
      text = line.text,
      color = line.color,
      position = {position.x, position.y - 0.5 * index},
      time_to_live = 120,
    })
  end
end

-- Moves everything from one inventory to the player; overflow is spilled.
local function give(player, item)
  local inserted = player.insert(item)
  if inserted < item.count then
    player.physical_surface.spill_item_stack({
      position = player.physical_position,
      stack = {name = item.name, count = item.count - inserted, quality = item.quality},
      enable_looted = true,
      allow_belts = false,
    })
  end
end

local function empty_inventory(player, inventory)
  if not (inventory and inventory.valid) then return end
  for _, content in pairs(inventory.get_contents()) do
    give(player, {name = content.name, count = content.count, quality = content.quality})
  end
  inventory.clear()
end

local function on_pre_player_crafted_item(event)
  local player = game.get_player(event.player_index)
  if not player then return end
  local taken, counts = 0, {}
  for index = 1, #event.items do
    local stack = event.items[index]
    local grid = stack.valid_for_read and stack.grid
    if grid and grid.valid then
      for _, equipment in pairs(grid.equipment) do
        local burner = equipment.burner
        if burner then
          empty_inventory(player, burner.inventory)
          empty_inventory(player, burner.burnt_result_inventory)
        end
        local item = grid.take({equipment = equipment})
        if item then
          give(player, {name = item.name, count = item.count or 1, quality = quality_name(item.quality)})
          counts[item.name] = (counts[item.name] or 0) + (item.count or 1)
          taken = taken + (item.count or 1)
        end
      end
    end
  end
  if taken == 0 then return end
  local lines = {}
  for name, count in pairs(counts) do
    table.insert(lines, {text = {"paranoidal-tank-platoon.flying-text-item", prototypes.item[name].localised_name, "+", count, player.get_item_count(name)}})
  end
  show_texts(player, player.physical_position, lines)
  player.print({"paranoidal-tank-platoon.precraft-take-equipment", taken})
end

-- Clone placement ---------------------------------------------------------------------------------

local function new_stats()
  return {used = {}, failed = {}}
end

local function count_up(map, name, amount)
  map[name] = (map[name] or 0) + amount
end

-- Takes up to `amount` items from the player; returns how many are available (and removes them unless check_only).
local function take_from(player, name, quality, amount, stats, check_only)
  local available = math.min(amount, player.get_item_count({name = name, quality = quality}))
  if check_only or available <= 0 then return available end
  player.remove_item({name = name, count = available, quality = quality})
  count_up(stats.used, name, available)
  return available
end

local function is_complex(stack)
  return stack.grid or stack.is_blueprint or stack.is_blueprint_book or stack.is_armor
    or stack.is_item_with_inventory or stack.is_item_with_entity_data
    or stack.is_deconstruction_item or stack.is_upgrade_item
end

local function clone_slot(source, target, player, stats)
  if not (source.valid_for_read and target.valid) then return end
  if is_complex(source) then
    count_up(stats.failed, source.name, source.count)
    return
  end
  local quality = quality_name(source.quality)
  if target.valid_for_read then
    if target.name ~= source.name or quality_name(target.quality) ~= quality then
      count_up(stats.failed, source.name, source.count)
    elseif source.count > target.count then
      target.count = target.count + take_from(player, source.name, quality, source.count - target.count, stats)
    end
    return
  end
  local available = take_from(player, source.name, quality, source.count, stats, true)
  if available <= 0 then return end
  if target.set_stack({name = source.name, count = available, quality = quality}) then
    take_from(player, source.name, quality, available, stats)
  else
    count_up(stats.failed, source.name, available)
  end
end

local function clone_inventory(source, target, player, stats)
  if not (source and source.valid and target and target.valid) or source.is_empty() then return end
  for index = math.min(#source, #target), 1, -1 do
    clone_slot(source[index], target[index], player, stats)
  end
end

local function clone_filters(source, target)
  if not (source and source.valid and target and target.valid) then return end
  if not (source.supports_filters() and target.supports_filters()) then return end
  for index = math.min(#source, #target), 1, -1 do
    target.set_filter(index, source.get_filter(index))
  end
end

local function clone_grid(source, target, player, stats)
  if not (source and source.valid and target and target.valid) then return end
  for _, equipment in pairs(source.equipment) do
    local quality = quality_name(equipment.quality)
    local item = equipment.prototype.take_result
    local placed = item and target.put({name = equipment.name, position = equipment.position, quality = quality, by_player = player})
    if placed then
      if take_from(player, item.name, quality, 1, stats) > 0 then
        if equipment.burner and placed.burner then
          clone_inventory(equipment.burner.inventory, placed.burner.inventory, player, stats)
        end
      else
        target.take({equipment = placed})
      end
    else
      local existing = target.get(equipment.position)
      if existing and existing.name == equipment.name then
        if equipment.burner and existing.burner then
          clone_inventory(equipment.burner.inventory, existing.burner.inventory, player, stats)
        end
      else
        count_up(stats.failed, item and item.name or equipment.name, 1)
      end
    end
  end
end

local function clone_vehicle(source, target, player)
  if not (source and source.valid and target and target.valid) then return end
  if not (VEHICLE_TYPES[target.type] and VEHICLE_TYPES[source.type]) then return end
  if not player.character then return end
  local stats = new_stats()
  local inventory = defines.inventory
  clone_grid(source.grid, target.grid, player, stats)
  clone_inventory(source.get_fuel_inventory(), target.get_fuel_inventory(), player, stats)
  clone_inventory(source.get_inventory(inventory.car_ammo), target.get_inventory(inventory.car_ammo), player, stats)
  clone_filters(source.get_inventory(inventory.car_trunk), target.get_inventory(inventory.car_trunk))
  clone_inventory(source.get_inventory(inventory.car_trunk), target.get_inventory(inventory.car_trunk), player, stats)
  clone_filters(source.get_inventory(inventory.cargo_wagon), target.get_inventory(inventory.cargo_wagon))
  clone_inventory(source.get_inventory(inventory.cargo_wagon), target.get_inventory(inventory.cargo_wagon), player, stats)

  local lines = {{text = {"paranoidal-tank-platoon.flying-text-place"}}}
  for name in pairs(stats.failed) do
    table.insert(lines, {text = {"paranoidal-tank-platoon.flying-text-insert-failed", prototypes.item[name] and prototypes.item[name].localised_name or name}})
  end
  for name, count in pairs(stats.used) do
    local left = player.get_item_count(name)
    table.insert(lines, {
      text = {"paranoidal-tank-platoon.flying-text-item", prototypes.item[name].localised_name, "", -count, left},
      color = left == 0 and COLOR_EMPTY or nil,
    })
  end
  show_texts(player, target.position, lines)
end

local function on_built_entity(event)
  local player = game.get_player(event.player_index)
  if not (player and player.mod_settings["tankplatoon-vehicle-clone-placement-built-enable"].value) then return end
  local source, target = player.vehicle, event.entity
  if not (source and target and target.valid and source.name == target.name) then return end
  clone_vehicle(source, target, player)
end

local function on_entity_settings_pasted(event)
  local player = game.get_player(event.player_index)
  if not (player and player.mod_settings["tankplatoon-vehicle-clone-placement-pasted-enable"].value) then return end
  clone_vehicle(event.source, event.destination, player)
end

local vehicle_filter = {}
for vehicle_type in pairs(VEHICLE_TYPES) do
  table.insert(vehicle_filter, {filter = "type", type = vehicle_type})
end

script.on_event(defines.events.on_pre_player_crafted_item, on_pre_player_crafted_item)
script.on_event(defines.events.on_built_entity, on_built_entity, vehicle_filter)
script.on_event(defines.events.on_entity_settings_pasted, on_entity_settings_pasted)
