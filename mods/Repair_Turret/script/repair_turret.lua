local util = require("util")
local pathfinding = require("pathfinding")
local TURRET_UPDATE_INTERVAL = 31
local moving_entity_check_interval = 301
local energy_per_heal = 100000

local turret_names =
{
  [require("shared").entities.repair_turret] = true
}

local is_turret = function(name)
  return turret_names[name]
end

local script_data =
{
  turrets = {},
  turret_map = {},
  active_turrets = {},
  repair_check_queue = {},
  beam_multiple = {},
  beam_efficiency = {},
  can_construct = {},
  pathfinder_cache = {},
  moving_entity_buckets = {},
  non_repairable_entities = {},
  ghost_check_queue = {},
  deconstruct_check_queue = {},
  proxy_inventory = nil,
  prune_asteroids = false
}

local moving_entities =
{
  ["car"] = true,
  ["unit"] = true,
  ["character"] = true,
  ["combat-robot"] = true,
  ["locomotive"] = true,
  ["cargo-wagon"] = true,
  ["fluid-wagon"] = true,
  ["artillery-wagon"] = true,
  ["construction-robot"] = true,
  ["logistic-robot"] = true,
  ["spider-vehicle"] = true
}

local ghost_names =
{
  ["entity-ghost"] = true,
  ["tile-ghost"] = true
}

local can_move = function(entity)
  return moving_entities[entity.type]
end

local repair_items
local get_repair_items = function()
  if repair_items then return repair_items end
  repair_items = {}
  for name, item in pairs(prototypes.item) do
    if item.type == "repair-tool" and (item.speed and item.speed > 0) then
      repair_items[name] = true
    end
  end
  return repair_items
end

local add_to_turret_map = function(turret, s, x, y)
  local map = script_data.turret_map

  local surface_map = map[s]
  if not surface_map then
    surface_map = {}
    map[s] = surface_map
  end

  local map_x = surface_map[x]
  if not map_x then
    map_x = {}
    surface_map[x] = map_x
  end

  local turrets = map_x[y]
  if not turrets then
    turrets = {}
    map_x[y] = turrets
  end

  turrets[turret.unit_number] = turret
end

local remove_from_turret_map = function(unit_number, s, x, y)
  local map = script_data.turret_map
  local surface_map = map[s]
  if not surface_map then return end
  local map_x = surface_map[x]
  if not map_x then return end
  local turrets = map_x[y]
  if not turrets then return end
  turrets[unit_number] = nil
end

local add_to_turret_update = function(turret)
  local unit_number = turret.unit_number
  local bucket_index = unit_number % TURRET_UPDATE_INTERVAL
  local bucket = script_data.active_turrets[bucket_index]
  if not bucket then
    bucket = {}
    script_data.active_turrets[bucket_index] = bucket
  end
  assert(not bucket[unit_number])
  bucket[unit_number] = turret
end

local remove_from_turret_update = function(unit_number)
  local bucket_index = unit_number % TURRET_UPDATE_INTERVAL
  local bucket = script_data.active_turrets[bucket_index]
  if not bucket then return end
  bucket[unit_number] = nil
  if not next(bucket) then
    script_data.active_turrets[bucket_index] = nil
  end
end

local RepairTurret = {}
RepairTurret.metatable =
{
  __index = RepairTurret
}
script.register_metatable("repair-turret", RepairTurret.metatable)

RepairTurret.new = function(entity)
  script.register_on_object_destroyed(entity)

  local self = setmetatable({}, RepairTurret.metatable)
  self.entity = entity
  self.range = entity.prototype.construction_radius
  self.unit_number = entity.unit_number
  self.surface_index = entity.surface.index
  self.position = entity.position
  self.force_index = entity.force.index
  self.targets = {}
  self.low_priority_queue = {}
  self.inventory = self.entity.get_inventory(defines.inventory.roboport_material)

  self:post_setup()
end

RepairTurret.post_setup = function(self)
  script_data.turrets[self.unit_number] = self
  self:register_on_chunks()
  self:add_nearby_damaged_entities_to_repair_check_queue()
  self:add_nearby_ghost_entities_to_ghost_check_queue()
  self:add_nearby_entities_to_deconstruct_check_queue()
end

RepairTurret.on_destroyed = function(self)
  self.entity = nil
  self:unregister_from_chunks()
  if self.active then
    self:deactivate()
  end
  script_data.turrets[self.unit_number] = nil
end

RepairTurret.get_turret = function(unit_number)
  return script_data.turrets[unit_number]
end

RepairTurret.register_on_chunks = function(self)
  for k, chunk_position in pairs (self:get_chunks_in_range()) do
    add_to_turret_map(self, self.surface_index, chunk_position[1], chunk_position[2])
  end
end

RepairTurret.unregister_from_chunks = function(self)
  for k, chunk_position in pairs (self:get_chunks_in_range()) do
    remove_from_turret_map(self.unit_number, self.surface_index, chunk_position[1], chunk_position[2])
  end
end

local CHUNK_SIZE = 32
RepairTurret.get_chunks_in_range = function(self)
  local position = self.position
  local range = self.range
  local chunks = {}
  local i = 1
  for x = math.floor((position.x - range) / CHUNK_SIZE), math.floor((position.x + range) / CHUNK_SIZE) do
    for y = math.floor((position.y - range) / CHUNK_SIZE), math.floor((position.y + range) / CHUNK_SIZE) do
      chunks[i] = {x, y}
      i = i + 1
    end
  end
  return chunks
end

local on_player_created = function(event)
  local player = game.get_player(event.player_index)
  if player and player.name == "Klonan" then
    player.insert("repair-turret")
  end
end

local clear_cache = function()
  --game.print("Clearing cache")
  script_data.pathfinder_cache = {}
  pathfinding.cache = script_data.pathfinder_cache
end

local add_to_moving_entity_check = function(entity)

  local unit_number = entity.unit_number
  if not unit_number then return end

  local bucket_index = unit_number % moving_entity_check_interval

  local bucket = script_data.moving_entity_buckets[bucket_index]
  if not bucket then
    bucket = {}
    script_data.moving_entity_buckets[bucket_index] = bucket
  end

  bucket[unit_number] = entity

end

local add_to_repair_check_queue = function(entity)

  if can_move(entity) then
    add_to_moving_entity_check(entity)
    return
  end

  local unit_number = entity.unit_number
  if not unit_number then return end

  script_data.repair_check_queue[unit_number] = entity

end

local floor = math.floor

local to_chunk_position = function(position)
  local x = floor(position.x / CHUNK_SIZE)
  local y = floor(position.y / CHUNK_SIZE)
  return x, y
end

local get_turrets_in_map = function(s, x, y)
  --game.print("HI"..x..y)
  local map = script_data.turret_map
  local surface_map = map[s]
  if not surface_map then return end
  local map_x = surface_map[x]
  if not map_x then return end
  --local turrets = map_x[y]
  --if not turrets then return end
  return map_x[y]
end

local get_beam_multiple = function(force_index)
  return script_data.beam_multiple[force_index] or 1
end

local get_needed_energy = function(force_index)
  local base = energy_per_heal * TURRET_UPDATE_INTERVAL
  local modifier = script_data.beam_efficiency[force_index] or 1
  return base * modifier
end

local has_repair_item = function(network)
  local get_item_count = network.get_item_count
  for name, item in pairs (get_repair_items()) do
    if get_item_count(name) > 0 then return true end
  end
end

local abs = math.abs
RepairTurret.is_in_range = function(self, position)
  return (abs(position.x - self.position.x) <= self.range) and (abs(position.y - self.position.y) <= self.range)
end

local NEUTRAL_FORCE_INDEX = 3
RepairTurret.can_do_stuff_to_force = function(self, force_index, for_deconstruction)
  if for_deconstruction and force_index == NEUTRAL_FORCE_INDEX then
    return true
  end
  return self.force_index == force_index
end

RepairTurret.is_valid_for_entity = function(self, entity_position, force_index, for_deconstruction)
  assert(self.entity.valid)
  if not self:can_do_stuff_to_force(force_index, for_deconstruction) then
    return false
  end
  if not self:is_in_range(entity_position) then
    return false
  end
  return true
end

local get_unit_number = function(entity)
  local unit_number = entity.unit_number
  if not unit_number then
    unit_number = entity.position.x.."-"..entity.position.y
  end
  return unit_number
end

RepairTurret.add_target = function(self, entity)
  if (self.entity == entity) then return end
  self.targets[get_unit_number(entity)] = entity
  self:activate()
end

RepairTurret.move_target_to_low_priority = function(self, entity)
  local unit_number = get_unit_number(entity)
  self.targets[unit_number] = nil
  self.low_priority_queue[unit_number] = entity
end

RepairTurret.activate = function(self)
  if self.active then return end
  self.active = true
  add_to_turret_update(self)
end

RepairTurret.deactivate = function(self)
  assert(self.active)
  self.active = false
  remove_from_turret_update(self.unit_number)
end

RepairTurret.get_energy_to_update = function(self)
  return self.entity.energy - get_needed_energy(self.force_index)
end

RepairTurret.can_build = function(self)
  return script_data.can_construct[self.force_index]
end

RepairTurret.check_deactivate = function(self)
  if next(self.targets) then
    return
  end
  if next(self.low_priority_queue) then
    return
  end
  self:deactivate()
end

RepairTurret.check_queue_swap = function(self)
  if not next(self.targets) and next(self.low_priority_queue) then
    self.targets, self.low_priority_queue = self.low_priority_queue, self.targets
  end
end

local entity_needs_repair = function(entity)
  local health = entity.health
  if not health then return end
  local max_health = entity.max_health
  if health >= max_health then
    return
  end
  return health - entity.get_damage_to_be_taken() < max_health
end

local result_enum =
{
  success = 1,
  fail = 2,
  low_priority = 3
}
RepairTurret.check_target = function(self, entity)

  if not entity.valid then
    return result_enum.fail
  end

  if ghost_names[entity.name] then
    if self:try_build_ghost(entity) then
      return result_enum.success
    end
    return self:can_build() and result_enum.low_priority or result_enum.fail
  end

  if entity.to_be_deconstructed() then
    if self:deconstruct_entity(entity) then
      return result_enum.success
    end
    return self:can_build() and result_enum.low_priority or result_enum.fail
  end

  if (entity_needs_repair(entity)) then
    if self:repair_entity(entity) then
      return result_enum.success
    end
    return result_enum.low_priority
  end

  return result_enum.fail
end

RepairTurret.update = function(self)
  --local profiler = game.create_profiler()
  if not self.entity.valid then
    self:on_destroyed()
    return
  end

  local new_energy = self:get_energy_to_update()
  if new_energy < 0 then
    return
  end

  for unit_number, target in pairs (self.targets) do
    local result = self:check_target(target)
    if result == result_enum.success then
      self.entity.energy = new_energy
      return
    elseif result == result_enum.low_priority then
      self:move_target_to_low_priority(target)
    else -- fail
      self.targets[unit_number] = nil
    end
  end

  self:check_queue_swap()
  self:check_deactivate()

end

local find_nearby_turrets = function(entity, for_deconstruction)

  local result_turrets = {}
  local position = entity.position
  local force_index = entity.force.index
  local surface_index = entity.surface.index

  local x, y = to_chunk_position(position)

  local turrets = get_turrets_in_map(surface_index, x, y)
  if turrets then
    for unit_number, turret in pairs (turrets) do
      if turret:is_valid_for_entity(position, force_index, for_deconstruction) then
        result_turrets[unit_number] = turret
      end
    end
  end

  return result_turrets
end

RepairTurret.get_range_area = function(self)
  local position = self.position
  return {{position.x - self.range, position.y - self.range}, {position.x + self.range, position.y + self.range}}
end

RepairTurret.add_nearby_damaged_entities_to_repair_check_queue = function(self)
  for k, entity in pairs (self.entity.surface.find_entities_filtered{area = self:get_range_area()}) do
    if entity.unit_number and (entity.get_health_ratio() or 1) < 1 then
      add_to_repair_check_queue(entity)
    end
  end
end

local ghost_check_names = {"entity-ghost", "tile-ghost"}
RepairTurret.add_nearby_ghost_entities_to_ghost_check_queue = function(self)
  local ghost_check_queue = script_data.ghost_check_queue
  for k, entity in pairs(self.entity.surface.find_entities_filtered {area = self:get_range_area(), name = ghost_check_names}) do
    ghost_check_queue[get_unit_number(entity)] = entity
  end
end

local insert = table.insert
RepairTurret.add_nearby_entities_to_deconstruct_check_queue = function(self)
  local deconstruct_check_queue = script_data.deconstruct_check_queue
  for k, entity in pairs(self.entity.surface.find_entities_filtered {area = self:get_range_area(), to_be_deconstructed = true}) do
    deconstruct_check_queue[get_unit_number(entity)] = entity
  end
end

local entity_ghost_built = function(entity)
  script_data.ghost_check_queue[entity.unit_number] = entity
  local decons = entity.surface.find_entities_filtered{area = entity.bounding_box, to_be_deconstructed = true}
  for k, decon in pairs (decons) do
    script_data.deconstruct_check_queue[get_unit_number(decon)] = decon
  end
end

local on_created_entity = function(event)
  local entity = event.created_entity or event.entity or event.destination
  if not (entity and entity.valid) then return end

  local name = entity.name

  if ghost_names[name] then
    entity_ghost_built(entity)
    return
  end

  if is_turret(name) then
    RepairTurret.new(entity)
  end

  if entity.logistic_cell then
    clear_cache()
  end

  if (entity.get_health_ratio() or 1) < 1 then
    add_to_repair_check_queue(entity)
  end

end

local max_duration = TURRET_UPDATE_INTERVAL * 8

local highlight_path = function(source, path, beam_name)

  --local profiler = game.create_profiler()

  local current_duration = TURRET_UPDATE_INTERVAL

  local surface = source.surface
  local create_entity = surface.create_entity
  local force = source.force
  local count = 0

  if source.type ~= "roboport" then
    local position = source.position
    create_entity
    {
      name = beam_name,
      target_position = position,
      source_position = {position.x, position.y - 2.5},
      force = force,
      duration = current_duration,
      position = position
    }
  end

  local make_beam = function(source, target)
    --count = count + 1
    --local profiler = game.create_profiler()
    local source_position = source.position
    local target_position = target.position

    local x1, y1 = source_position.x, source_position.y - 2.5
    local x2, y2 = target_position.x, target_position.y - 2.5

    --game.print({"", count, " get positions ", profiler})
    --profiler.reset()

    --source.energy = (source.energy - transmission_energy_per_hop) + 1

    --game.print({"", count, " set energy ", profiler})
    --profiler.reset()

    local position = {x1, y1}
    local beam = create_entity
    {
      name = beam_name,
      source_position = position,
      target_position = position,
      duration = current_duration,
      position = position,
      force = force,
    }
    beam.set_beam_target({x2, y2})

    --game.print({"", count, " create entity ", profiler})

    if current_duration < max_duration then
      current_duration = current_duration + 3
    end
  end

  local i = 1
  local last_target = source
  while true do
    local cell = path[i]
    if not cell then break end

    if not (cell.valid and cell.transmitting) then
      clear_cache()
      return
    end

    local source = cell.owner
    if last_target then
      make_beam(last_target, source)
    end
    last_target = source
    i = i + 1

  end

end

RepairTurret.get_repair_pickup_point = function(self)
  local select_pickup_point = self.entity.logistic_network.select_pickup_point
  for name, item in pairs(get_repair_items()) do
    local pickup_point = select_pickup_point {name = name, position = self.position, include_buffers = true}
    if pickup_point then
      return pickup_point.owner, name
    end
  end
end

local get_owner_inventory = function(entity)
  local entity_type = entity.type
  if entity_type == "roboport" then
    return entity.get_inventory(defines.inventory.roboport_material)
  end
  if entity_type == "character" then
    return entity.get_main_inventory()
  end
  return entity.get_output_inventory()
end

RepairTurret.get_repair_stack_and_entity = function(self)

  local inventory = self.inventory
  if not inventory.is_empty() then
    return self.entity, inventory[1]
  end

  local owner, repair_item = self:get_repair_pickup_point()
  if not owner then return end

  local owner_inventory = get_owner_inventory(owner)

  local stack = owner_inventory and owner_inventory.find_item_stack(repair_item)

  if not (stack and stack.valid and stack.valid_for_read) then return end

  return owner, stack

end

local make_path = function(target_entity, source_cell, beam_name)
  if settings.global.hide_repair_paths.value then return end

  local path = pathfinding.get_cell_path(target_entity, source_cell)

  if path then
    highlight_path(target_entity, path, beam_name)
  end

end

RepairTurret.repair_entity = function(self, entity)

  local pickup_entity, stack = self:get_repair_stack_and_entity()
  if not (pickup_entity and pickup_entity.valid) then
    return
  end

  if not (stack and stack.valid and stack.valid_for_read and stack.is_repair_tool) then
    return
  end

  if pickup_entity ~= self.entity then
    make_path(pickup_entity, self.entity.logistic_cell, "repair-beam")
  end

  stack.drain_durability(TURRET_UPDATE_INTERVAL / stack.prototype.speed)

  local speed = 1 / 2

  local source_position = {self.position.x, self.position.y - 2.5}
  local surface = entity.surface
  local create_entity = surface.create_entity

  for k = 1, get_beam_multiple(self.force_index) do
    local rocket = create_entity
    {
      name = "repair-bullet",
      speed = speed,
      position = source_position,
      target = entity,
      force = force,
      max_range = self.range * 2
    }
    speed = speed / 0.8
    create_entity
    {
      name = "repair-beam",
      target_position = source_position,
      source = rocket,
      position = self.position,
      force = force
    }
  end

  return true

end

local items_to_place_cache = {}
local get_items_to_place = function(ghost)

  local quality = ghost.quality.name
  local quality_items = items_to_place_cache[quality]
  if not quality_items then
    quality_items = {}
    items_to_place_cache[quality] = quality_items
  end

  local name = ghost.ghost_name
  local items = quality_items[name]
  if items then return items end

  local prototype = ghost.ghost_prototype
  items = prototype.items_to_place_this
  quality_items[name] = items
  for k, item in pairs (items) do
    item.quality = quality
  end

  return items

end

local mineable_products_cache = {}
local get_mineable_products = function(entity)

  local name = entity.name
  local products = mineable_products_cache[name]
  if products then return products end

  local prototype = entity.prototype
  products = prototype.mineable_properties.products or {}
  mineable_products_cache[name] = products
  for k, product in pairs (products) do
    product.count = product.amount_max or product.amount or 1
  end

  return products

end

local can_revive = function(ghost)
  if ghost.name == "tile-ghost" then return true end -- TODO, check if we can place tiles, there is no API for it at the moment.
  return ghost.surface.can_place_entity
  {
    name = ghost.ghost_name,
    position = ghost.position,
    direction = ghost.direction,
    force = ghost.force,
    build_check_type = defines.build_check_type.manual,
    forced = true
  }
end

local get_item_to_place_in_network = function(ghost, get_item_count)
  for k, item in pairs (get_items_to_place(ghost)) do
    if (get_item_count(item)) >= item.count then
      return item
    end
  end
end

RepairTurret.can_build_ghost = function(self, ghost)
  if can_revive(ghost) then
    local get_item_count = self.entity.logistic_network.get_item_count
    local item = get_item_to_place_in_network(ghost, get_item_count)
    if item then
      return item
    end
  end

end

local revive_param = {raise_revive = true}

RepairTurret.try_build_ghost = function(self, ghost)

  if not self:can_build() then return end

  local build_item = self:can_build_ghost(ghost)
  --game.print(serpent.block(build_item))
  if not build_item then return end

  local network = self.entity.logistic_network
  local point = network.select_pickup_point
  {
    name = build_item,
    position = self.position,
    include_buffers = true
  }
  if not point then return end

  local pickup_entity = point.owner

  local target_position = ghost.position
  local force = ghost.force

  local collided_items, entity, proxy = ghost.revive(revive_param)

  if collided_items then
    for k, item in pairs (collided_items) do
      network.insert(item)
    end
  end

  if pickup_entity ~= self.entity then
    make_path(pickup_entity, self.entity.logistic_cell, "construct-beam")
  end

  pickup_entity.remove_item(build_item)

  local position = self.position
  local source_position = {position.x, position.y - 2.5}

  self.entity.surface.create_entity
  {
    name = "construct-beam",
    source_position = source_position,
    target = entity,
    target_position = target_position,
    position = position,
    force = force,
    duration = TURRET_UPDATE_INTERVAL
  }

  return true

end

RepairTurret.deconstruct_entity = function(self, entity)
  if not self:can_build() then return end
  if not entity.can_be_destroyed() then return end
  local network = self.entity.logistic_network
  local position = entity.position
  local surface = entity.surface
  local tiles

  if entity.name == "deconstructible-tile-proxy" then
    local tile_name = surface.get_hidden_tile(position)
    if tile_name then
      tiles =
      {
        {name = tile_name, position = position}
      }
    end
    -- todo check we can like the check below
  else
    for k, product in pairs (get_mineable_products(entity)) do
      if not network.select_drop_point{stack = product, "storage"} then
        return
      end
    end
  end

  local inventory = script_data.proxy_inventory
  local success = entity.mine
  {
    inventory = inventory
  }
  if not success then return end

  local cell = self.entity.logistic_cell
  local force = self.entity.force

  if tiles then
    surface.set_tiles(tiles)
  end

  local source_position = {self.position.x, self.position.y - 2.5}

  local rocket = surface.create_entity
  {
    name = "deconstruct-bullet",
    speed = -0.1,
    position = position,
    target = source_position,
    force = force,
    max_range = self.range * 2
  }
  surface.create_entity
  {
    name = "deconstruct-beam",
    target_position = source_position,
    source = rocket,
    position = position,
    force = force
  }

  local made_beam = false

  for stack_index = 1, #inventory do
    local stack = inventory[stack_index]
    if not stack.valid_for_read then break end
    local count = stack.count
    if not made_beam then
      local drop_point = network.select_drop_point{stack = stack}
      if drop_point then
        local owner = drop_point.owner
        count = count - owner.insert(stack)
        make_path(owner, cell, "deconstruct-beam")
        made_beam = true
      end
    end
    if count > 0 then
      count = count - network.insert(stack)
    end
    if count > 0 then
      stack.count = count
      surface.spill_item_stack(
      {
        position = position,
        stack = stack,
        allow_belts = false})
    end
    stack.clear()
  end

  return true

end


local check_repair = function(unit_number, entity)
  if not (entity and entity.valid) then return true end
  if entity.has_flag("not-repairable") then return true end
  if (entity.get_health_ratio() or 1) == 1 then return true end

  --entity.surface.create_entity{name = "flying-text", position = entity.position, text = "?"}

  for turret_unit_number, turret in pairs(find_nearby_turrets(entity)) do
    turret:add_target(entity)
  end
end

local repair_check_count = 5
local check_repair_check_queue = function()

  local repair_check_queue = script_data.repair_check_queue
  for k = 1, repair_check_count do

    local unit_number, entity = next(repair_check_queue)
    if not unit_number then return end

    repair_check_queue[unit_number] = nil

    check_repair(unit_number, entity)
  end

end

local check_moving_entity_repair = function(event)

  local moving_entity_check_index = event.tick % moving_entity_check_interval
  local moving_entity_bucket = script_data.moving_entity_buckets[moving_entity_check_index]

  if not moving_entity_bucket then return end

  for unit_number, entity in pairs(moving_entity_bucket) do
    if check_repair(unit_number, entity) then
      moving_entity_bucket[unit_number] = nil
    end
  end

  if not next(moving_entity_bucket) then
    script_data.moving_entity_buckets[moving_entity_check_index] = nil
  end

end

local check_turret_update = function(event)
  local active_turrets = script_data.active_turrets
  local bucket_index = event.tick % TURRET_UPDATE_INTERVAL
  local bucket = active_turrets[bucket_index]
  if not bucket then return end
  for unit_number, turret in pairs(bucket) do
    turret:update()
  end
end

local check_ghost = function(unit_number, entity)
  if not (entity and entity.valid) then return true end

  local turrets = find_nearby_turrets(entity)

  for turret_unit_number, turret in pairs (turrets) do
    turret:add_target(entity)
  end

end

local ghost_check_count = 5
local check_ghost_check_queue = function()

  local ghost_check_queue = script_data.ghost_check_queue
  for k = 1, ghost_check_count do

    local unit_number, entity = next(ghost_check_queue)
    if not unit_number then return end

    ghost_check_queue[unit_number] = nil

    check_ghost(unit_number, entity)
  end

end

local check_deconstruction = function(entity)
  if not (entity and entity.valid) then return true end
  if (entity.type == "cliff") then return end
  if not entity.to_be_deconstructed() then return end

  local turrets = find_nearby_turrets(entity, true)
  for turret_unit_number, turret in pairs (turrets) do
    turret:add_target(entity)
  end

end

local deconstruct_check_count = 5
local check_deconstruction_check_queue = function()

  local deconstruct_check_queue = script_data.deconstruct_check_queue
  for k = 1, deconstruct_check_count do
    local index, entity = next(deconstruct_check_queue)
    if not index then return end
    deconstruct_check_queue[index] = nil
    check_deconstruction(entity)
  end

end

local on_tick = function(event)
  --local profiler = game.create_profiler()

  check_deconstruction_check_queue()
  --game.print({"", event.tick, " deconstruction check ", profiler})
  --profiler.reset()

  check_ghost_check_queue()
  --game.print({"", event.tick, " ghost check ", profiler})
  --profiler.reset()

  check_repair_check_queue()
  --game.print({"", event.tick, " repair check ", profiler})
  --profiler.reset()

  check_moving_entity_repair(event)
  --game.print({"", event.tick, " moving entity check ", profiler})
  --profiler.reset()

  check_turret_update(event)
  --game.print({"", event.tick, " turret update ", profiler})
  --profiler.reset()

end

local on_entity_damaged = function(event)

  local entity = event.entity
  if not (entity and entity.valid and entity.unit_number) then
    return
  end

  add_to_repair_check_queue(entity)

end

local on_research_finished = function(event)
  local research = event.research
  if not (research and research.valid) then return end

  local name = research.name

  if name:find("repair%-turret%-power") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
    script_data.beam_multiple[index] = math.max(script_data.beam_multiple[index] or 1, (number + 1))
  end

  if name:find("repair%-turret%-efficiency") then
    local number = name:sub(name:len())
    if not tonumber(number) then return end
    local index = research.force.index
    local amount = 1 - (number / 4)
    script_data.beam_efficiency[index] = math.min(script_data.beam_efficiency[index] or 1, amount)
  end

  if name == "repair-turret-construction" then
    script_data.can_construct[research.force.index] = true
  end

end

local on_entity_removed = function(event)
  local entity = event.entity
  if not (entity and entity.valid) then return end

  if entity.logistic_cell then
    clear_cache()
  end

end

local set_damaged_event_filter = function()

  if not script_data.non_repairable_entities then return end

  local filters = {}
  for name, bool in pairs (script_data.non_repairable_entities) do
    local filter =
    {
      filter = "name",
      name = name,
      invert = true,
      mode = "and"
    }
    table.insert(filters, filter)
  end

  if not next(filters) then return end

  script.set_event_filter(defines.events.on_entity_damaged, filters)
end

local update_non_repairable_entities = function()
  script_data.non_repairable_entities = {}
  for name, entity in pairs(prototypes.entity) do
    if entity.has_flag("not-repairable") then
      script_data.non_repairable_entities[name] = true
    end
  end
  set_damaged_event_filter()
end

local on_post_entity_died = function(event)
  local ghost = event.ghost
  if ghost and ghost.valid then
    script_data.ghost_check_queue[ghost.unit_number] = ghost
  end
end

local on_marked_for_deconstruction = function(event)
  local entity = event.entity
  if entity and entity.valid then
    script_data.deconstruct_check_queue[get_unit_number(entity)] = entity
  end
end

local entity_type = defines.target_type.entity
local on_object_destroyed = function(event)
  if event.type ~= entity_type then return end
  local turret = RepairTurret.get_turret(event.useful_id)
  if not turret then return end
  turret:on_destroyed()
end

local lib = {}

lib.events =
{
  [defines.events.on_player_created] = on_player_created,
  [defines.events.on_built_entity] = on_created_entity,
  [defines.events.on_robot_built_entity] = on_created_entity,
  [defines.events.script_raised_built] = on_created_entity,
  [defines.events.script_raised_revive] = on_created_entity,
  [defines.events.on_entity_cloned] = on_created_entity,
  [defines.events.on_space_platform_built_entity] = on_created_entity,

  [defines.events.on_tick] = on_tick,
  [defines.events.on_entity_damaged] = on_entity_damaged,
  [defines.events.on_research_finished] = on_research_finished,

  [defines.events.on_entity_died] = on_entity_removed,
  [defines.events.script_raised_destroy] = on_entity_removed,
  [defines.events.on_player_mined_entity] = on_entity_removed,
  [defines.events.on_robot_mined_entity] = on_entity_removed,
  [defines.events.on_space_platform_mined_entity] = on_entity_removed,

  [defines.events.on_object_destroyed] = on_object_destroyed,

  [defines.events.on_post_entity_died] = on_post_entity_died,

  [defines.events.on_surface_cleared] = clear_cache,
  [defines.events.on_surface_deleted] = clear_cache,

  [defines.events.on_marked_for_deconstruction] = on_marked_for_deconstruction,
}

lib.on_init = function()
  storage.repair_turret = storage.repair_turret or script_data
  pathfinding.cache = script_data.pathfinder_cache
  script_data.proxy_inventory = game.create_inventory(200)
end

lib.on_load = function()
  script_data = storage.repair_turret or script_data
  pathfinding.cache = script_data.pathfinder_cache
  set_damaged_event_filter()
end

lib.on_configuration_changed = function()

  script_data.moving_entity_buckets = script_data.moving_entity_buckets or {}

  if not script_data.pathfinder_cache then
    script_data.pathfinder_cache = {}
    pathfinding.cache = script_data.pathfinder_cache
  end

  if not script_data.repair_check_queue then
    local profiler = game.create_profiler()

    script_data.repair_check_queue = {}
    script_data.active_turrets = {}

    for x, array in pairs (script_data.turret_map) do
      for y, turrets in pairs (array) do
        for k, turret in pairs (turrets) do
          if not turret.valid then
            turrets[k] = nil
          else
            add_nearby_damaged_entities_to_repair_check_queue(turret)
          end
        end
      end
    end

    game.print{"", "Repair turret - Rescanned map for repair targets. ", profiler}


  end

  update_non_repairable_entities()

  if not script_data.ghost_check_queue then
    local profiler = game.create_profiler()

    script_data.ghost_check_queue = {}

    for x, array in pairs (script_data.turret_map) do
      for y, turrets in pairs (array) do
        for k, turret in pairs (turrets) do
          if not turret.valid then
            turrets[k] = nil
          else
            add_nearby_ghost_entities_to_ghost_check_queue(turret)
          end
        end
      end
    end

    game.print{"", "Repair turret - Rescanned map for ghost targets. ", profiler}

  end

  if not script_data.deconstruct_check_queue then
    local profiler = game.create_profiler()

    script_data.deconstruct_check_queue = {}

    for x, array in pairs (script_data.turret_map) do
      for y, turrets in pairs (array) do
        for k, turret in pairs (turrets) do
          if not turret.valid then
            turrets[k] = nil
          else
            add_nearby_entities_to_deconstruct_check_queue(turret)
          end
        end
      end
    end

    game.print{"", "Repair turret - Rescanned map for deconstruct targets. ", profiler}

  end

  script_data.can_construct = script_data.can_construct or {}

  script_data.proxy_inventory = script_data.proxy_inventory or game.create_inventory(200)

  if not script_data.prune_asteroids then
    local profiler = game.create_profiler()
    script_data.prune_asteroids = true
    local non_repairable_entities = script_data.non_repairable_entities
    local repair_queue = script_data.repair_check_queue
    local new_queue = {}
    for unit_number, entity in pairs(repair_queue) do
      if (entity and entity.valid) then
        if not non_repairable_entities[entity.name] then
          new_queue[unit_number] = entity
        end
      end
    end
    script_data.repair_check_queue = new_queue
    game.print{"", "Repair turret - Pruned repair check queue. ", profiler}
  end

end

return lib
