local M = {}

-- Position adjustments

function M.moveposition(position, offset)
  return {x=position.x + offset.x, y=position.y + offset.y}
end

function M.offset(direction, longitudinal, orthogonal)
  if direction == defines.direction.north then
    return {x=orthogonal, y=-longitudinal}
  end

  if direction == defines.direction.south then
    return {x=-orthogonal, y=longitudinal}
  end

  if direction == defines.direction.east then
    return {x=longitudinal, y=orthogonal}
  end

  if direction == defines.direction.west then
    return {x=-longitudinal, y=-orthogonal}
  end
end

function M.box_centered_at(position, radius)
  return {
    left_top = M.moveposition(position, M.offset(defines.direction.north, radius, -radius)),
    right_bottom = M.moveposition(position, M.offset(defines.direction.south, radius, -radius)),
  }
end

function M.expand_box(box, delta)
  return {
    left_top = { x = box.left_top.x - delta, y = box.left_top.y - delta },
    right_bottom = { x = box.right_bottom.x + delta, y = box.right_bottom.y + delta },
  }
end

function M.is_empty_box(box)
  local size_x = box.right_bottom.x - box.left_top.x
  local size_y = box.right_bottom.y - box.left_top.y
  return size_x < 0.01 and size_y < 0.01
end

function M.opposite_direction(direction)
  if direction >= 4 then
    return direction - 4
  end
  return direction + 4
end

function M.orthogonal_direction(direction)
  if direction < 6 then
    return direction + 2
  end
  return 0
end

function M.position_key(entity)
  return entity.surface.name .. "@" .. entity.position.x .. "," .. entity.position.y
end

function M.railloader_inserters(entity, pattern)
  local out = {}
  local inserters = entity.surface.find_entities_filtered{
    type = "inserter",
    position = entity.position,
    force = entity.force,
  }
  if not pattern then
    return inserters
  end
  for _, e in ipairs(inserters) do
    if string.find(e.name, pattern) ~= nil then
      out[#out+1] = e
    end
  end
  return out
end

function M.railloader_filter_inserters(entity)
  return M.railloader_inserters(entity, "^railu?n?loader%-inserter$")
end

function M.railloader_universal_inserters(entity)
  return M.railloader_inserters(entity, "^railu?n?loader%-universal%-inserter$")
end

function M.railloader_cargo_wagon_inserters(entity)
  local filter_inserters = M.railloader_filter_inserters(entity)
  if next(filter_inserters) then
    return filter_inserters
  end
  return M.railloader_universal_inserters(entity)
end

function M.railloader_interface_inserters(entity)
  return M.railloader_inserters(entity, "^railu?n?loader%-interface%-inserter$")
end

function M.is_railloader_chest(entity)
  return string.find(entity.name, "^railu?n?loader%-chest$") ~= nil
end

function M.is_filter_inserter(inserter)
  return string.find(inserter.name, "loader%-inserter$") ~= nil
end

function M.find_railloaders_from_chest(chest)
  local out = {}
  local area = M.expand_box(chest.bounding_box, 1)
  local es = chest.surface.find_entities_filtered{
    type = "container",
    area = area,
    force = chest.force,
  }
  for _, e in ipairs(es) do
    if M.is_railloader_chest(e) then
      out[#out+1] = e
    end
  end
  return out
end

function M.railloader_type(name)
  return string.match(name, "^rail(u?n?loader)%-")
end

function M.loader_direction(loader)
  local rail = loader.surface.find_entities_filtered{
    type = "straight-rail",
    area = M.box_centered_at(loader.position, 0.6),
  }[1]
  if rail and rail.valid then
    return rail.direction
  end
end

function M.interface_inserter_name_for_loader(loader)
  return "rail" .. M.railloader_type(loader.name) .. "-interface-inserter"
end

function M.find_inserter_for_interface(loader, interface)
  local type = M.railloader_type(loader.name)
  local interface_position = interface.position
  local inserters = loader.surface.find_entities_filtered{
    name = M.interface_inserter_name_for_loader(loader),
    position = loader.position,
  }
  for _, inserter in ipairs(inserters) do
    local target_interface_position = inserter[type == "loader" and "pickup_position" or "drop_position"]
    if target_interface_position.x == interface_position.x and
      target_interface_position.y == interface_position.y then
      return inserter
    end
  end
  return nil
end

function M.loader_position_for_interface(loader, interface)
  local offset = { x = 1.5, y = 1.5 }
  for _, axis in ipairs{"x", "y"} do
    if interface.position[axis] < loader.position[axis] then
      offset[axis] = offset[axis] * -1
    end
  end
  return { x = loader.position.x + offset.x, y = loader.position.y + offset.y }
end

function M.find_chests_from_railloader(loader)
  local position = loader.position
  local is_horiz = M.loader_direction(loader) == defines.direction.east
  local area = {
    left_top = {
      x = position.x - (is_horiz and 2.5 or 1.5),
      y = position.y - (is_horiz and 1.5 or 2.5),
    },
    right_bottom = {
      x = position.x + (is_horiz and 2.5 or 1.5),
      y = position.y + (is_horiz and 1.5 or 2.5),
    },
  }
  local entities = loader.surface.find_entities_filtered{
    area = area,
    force = loader.force,
  }
  local out = {}
  for _, e in ipairs(entities) do
    if string.find(e.type, "container$") and not M.is_railloader_chest(e) then
      out[#out+1] = e
    end
  end
  return out
end

function M.insert_or_spill(entity, stack, inventories)
  if not stack or not stack.valid_for_read then
    return
  end

  if stack.prototype.stackable then
    for _, inv in ipairs(inventories) do
      local inserted = inv.insert(stack)
      stack.count = stack.count - inserted
      if not stack.valid_for_read then
        return
      end
    end
  else
    for _, inv in ipairs(inventories) do
      for slot=1,#inv do
        if not inv[slot].valid_for_read then
          inv[slot].swap_stack(stack)
          return
        end
      end
    end
  end

  entity.surface.spill_item_stack(entity.position, stack)
  stack.clear()
end

return M