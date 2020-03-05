local util = require "lualib.util"

local M = {}

local temp_storage_chest

function M.on_pre_player_mined_item(event)
  local entity = event.entity
  if not util.is_miniloader_inserter(entity) then
    return
  end

  temp_storage_chest = entity.surface.create_entity{
    name = "steel-chest",
    position = util.moveposition(entity.position, util.offset(defines.direction.north, 2, 0)),
    force = entity.force,
  }
  local temp_storage = temp_storage_chest.get_inventory(defines.inventory.chest)

  -- upgrade-planner is about to try to fast replace an inserter, so let's prepare the way
  local inserters = util.get_loader_inserters(entity)
  for i, inserter in ipairs(inserters) do
    local storage_stack = temp_storage[i+20]
    inserter.held_stack.swap_stack(storage_stack)
    if inserter.unit_number ~= entity.unit_number then
      inserter.destroy()
    end
  end

  local loader = util.find_miniloaders{
    surface = entity.surface,
    position = entity.position,
  }[1]
  for i=1,2 do
    local tl = loader.get_transport_line(i)
    for j=#tl,1,-1 do
      tl[j].swap_stack(temp_storage[(i-1)*10 + j])
    end
  end
  loader.destroy()
end

function M.on_built_entity(event)
  local entity = event.created_entity
  if not util.is_miniloader_inserter(entity) then
    return
  end
  local is_ultimate_belts_loader = entity.name:find("^ub%-") ~= nil

  local temp_storage = temp_storage_chest.get_inventory(defines.inventory.chest)

  -- restore contents, if possible
  local inserters = util.get_loader_inserters(entity)
  local loader = util.find_miniloaders{
    surface = entity.surface,
    position = entity.position,
  }[1]

  for i, inserter in ipairs(inserters) do
    inserter.held_stack.swap_stack(temp_storage[20+i])
    if is_ultimate_belts_loader then
      inserter.disconnect_neighbour(defines.wire_type.red)
      inserter.disconnect_neighbour(defines.wire_type.green)
    end
  end

  for i=1,2 do
    local tl = loader.get_transport_line(i)
    for j=1,10 do
      local storage_stack = temp_storage[(i-1)*10 + j]
      if storage_stack.valid_for_read and tl.insert_at_back{name="raw-wood", count=1} then
        tl[j].swap_stack(storage_stack)
        storage_stack.clear()
      end
    end
  end

  -- check for any leftovers and give them to player, or spill if no room
  local player = game.players[event.player_index]
  for i=1,#temp_storage do
    local storage_stack = temp_storage[i]
    if storage_stack.valid_for_read then
      local inserted = player.insert(storage_stack)
      if inserted < storage_stack.count then
        player.remove_item{name = storage_stack.name, count = inserted}
        player.surface.spill_item_stack(player.position, storage_stack)
      end
    end
  end

  temp_storage_chest.destroy()
  temp_storage_chest = nil
end

return M