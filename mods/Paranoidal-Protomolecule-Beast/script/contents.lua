-- What's inside a building, kept while the outbreak holds it, so that it comes back with it: its inventories (moved stack
-- by stack into script inventories, so items keep their own data: blueprints, armour with grids, remotes), its equipment
-- grid, its fluids. Used when inserters lift a building, when its lair takes a train in, and when either is set down
-- again. Script inventories stay in the save until destroyed, so every pack is restored, spilled or discarded once.
-- 2.1: get_max_inventory_index, create_inventory, get_fluid/set_fluid (LuaEntity.fluidbox is gone in 2.1 and isn't
-- used here), grid.put, spill_inventory and spill_item_stack are the same in 2.1.24.
local contents = {}

-- A pack of what's in it, or nil if there's nothing. The entity is left empty.
function contents.pack(entity)
  if not (entity and entity.valid) then return nil end
  local pack
  local ok, max = pcall(entity.get_max_inventory_index)
  for index = 1, ok and max or 0 do
    local inventory = entity.get_inventory(index)
    if inventory and inventory.valid and not inventory.is_empty() then
      local copy = game.create_inventory(#inventory)
      for slot = 1, #inventory do
        local stack = inventory[slot]
        if stack.valid_for_read then copy[slot].transfer_stack(stack) end
      end
      pack = pack or {}
      pack.inventories = pack.inventories or {}
      pack.inventories[#pack.inventories + 1] = {index = index, inventory = copy}
    end
  end
  local grid = entity.grid
  if grid and grid.valid and #grid.equipment > 0 then
    pack = pack or {}
    pack.equipment = {}
    for _, equipment in pairs(grid.equipment) do
      pack.equipment[#pack.equipment + 1] = {name = equipment.name, quality = equipment.quality.name, position = equipment.position, energy = equipment.energy}
    end
  end
  local fluids = entity.fluids_count or 0
  for index = 1, fluids do
    local fluid = entity.get_fluid(index)
    if fluid then
      pack = pack or {}
      pack.fluids = pack.fluids or {}
      pack.fluids[index] = fluid
    end
  end
  return pack
end

local function destroy_inventories(pack)
  for _, entry in pairs(pack.inventories or {}) do
    if entry.inventory.valid then entry.inventory.destroy() end
  end
  pack.inventories = nil
end

-- Its equipment as items, for when there's no grid to put it back in.
local function equipment_items(pack)
  local items = {}
  for _, equipment in pairs(pack.equipment or {}) do
    local prototype = prototypes.equipment[equipment.name]
    local result = prototype and prototype.take_result
    if result then items[#items + 1] = {name = result.name, count = 1, quality = equipment.quality} end
  end
  return items
end

-- On the ground where it stood: what's in it, as whole stacks, and its equipment as items. Fluids are lost.
function contents.spill(surface, position, pack)
  if not pack then return end
  if surface and surface.valid then
    for _, entry in pairs(pack.inventories or {}) do
      if entry.inventory.valid and not entry.inventory.is_empty() then
        surface.spill_inventory{position = position, inventory = entry.inventory, enable_looted = true, drop_full_stack = true, allow_belts = false}
      end
    end
    for _, stack in pairs(equipment_items(pack)) do
      if prototypes.item[stack.name] then surface.spill_item_stack{position = position, stack = stack, enable_looted = true, drop_full_stack = true, allow_belts = false} end
    end
  end
  destroy_inventories(pack)
  pack.equipment, pack.fluids = nil, nil
end

-- Back into the same kind of entity; whatever doesn't fit is spilled beside it.
function contents.restore(entity, pack)
  if not pack then return end
  if not (entity and entity.valid) then return end
  for _, entry in pairs(pack.inventories or {}) do
    local source = entry.inventory
    local target = entity.get_inventory(entry.index)
    if source.valid and target and target.valid then
      for slot = 1, #source do
        local stack = source[slot]
        if stack.valid_for_read then
          if slot <= #target and not target[slot].valid_for_read then target[slot].transfer_stack(stack) end
          if stack.valid_for_read then
            local empty = target.find_empty_stack{name = stack.name, quality = stack.quality.name}
            if empty then empty.transfer_stack(stack) end
          end
          if stack.valid_for_read then
            local inserted = target.insert(stack)
            if inserted >= stack.count then stack.clear() elseif inserted > 0 then stack.count = stack.count - inserted end
          end
        end
      end
    end
  end
  local grid = entity.grid
  local left = {}
  for _, equipment in pairs(pack.equipment or {}) do
    local put = grid and grid.valid and grid.put{name = equipment.name, position = equipment.position, quality = equipment.quality}
    if put then
      if equipment.energy and equipment.energy > 0 then put.energy = equipment.energy end
    else
      left[#left + 1] = equipment
    end
  end
  pack.equipment = #left > 0 and left or nil
  for index, fluid in pairs(pack.fluids or {}) do
    if index <= (entity.fluids_count or 0) then pcall(entity.set_fluid, index, fluid) end
  end
  pack.fluids = nil
  contents.spill(entity.surface, entity.position, pack)
end

-- Gone for good, along with whatever was in it.
function contents.discard(pack)
  if not pack then return end
  destroy_inventories(pack)
  pack.equipment, pack.fluids = nil, nil
end

return contents
