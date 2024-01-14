local renderer = require("__PipeVisualizer__/scripts/renderer")

--- @class EntityData
--- @field connections table<FluidSystemID, PipeConnectionExt[]>
--- @field connection_objects table<FluidSystemID, RenderObjectID[]>
--- @field shape RenderObjectID?
--- @field entity LuaEntity
--- @field fluidbox LuaFluidBox
--- @field unit_number UnitNumber

--- @class PipeConnectionExt: PipeConnection
--- @field direction defines.direction
--- @field shape_position MapPosition
--- @field target_owner LuaEntity?

--- Assumes that the positions are in exact cardinals.
--- @param connection PipeConnection
--- @return defines.direction
local function get_cardinal_direction(connection)
  local from, to = connection.position, connection.target_position
  if from.y > to.y then
    return defines.direction.north
  elseif from.x < to.x then
    return defines.direction.east
  elseif from.y < to.y then
    return defines.direction.south
  else
    return defines.direction.west
  end
end

--- @class EntityDataModule
local entity_data = {}

--- @param iterator Iterator
--- @param entity LuaEntity
--- @return EntityData?
function entity_data.create(iterator, entity)
  local unit_number = entity.unit_number
  if not unit_number then
    return
  end

  local data = iterator.entities[unit_number]
  if data then
    -- ---@diagnostic disable-next-line: missing-fields
    -- entity.surface.create_entity({
    --   name = "flying-text",
    --   text = "Redraw",
    --   color = { r = 1, g = 0.3, b = 0.3 },
    --   position = entity.position,
    -- })
    entity_data.remove(iterator, data)
  end

  --- @type EntityData
  local data = {
    connection_objects = {},
    connections = {},
    entity = entity,
    fluidbox = entity.fluidbox,
    unit_number = unit_number,
  }

  for i = 1, #data.fluidbox do
    --- @cast i uint
    local id = data.fluidbox.get_fluid_system_id(i)
    if not id then
      goto continue
    end
    --- @type PipeConnectionExt
    local connections = data.fluidbox.get_pipe_connections(i)
    for _, connection in pairs(connections) do
      connection.direction = get_cardinal_direction(connection)
      connection.shape_position = {
        x = connection.position.x + (connection.target_position.x - connection.position.x) / 2,
        y = connection.position.y + (connection.target_position.y - connection.position.y) / 2,
      }
      if connection.target then
        connection.target_owner = connection.target.owner
      end
    end
    data.connections[id] = connections
    ::continue::
  end

  iterator.entities[unit_number] = data
  return data
end

--- @param iterator Iterator
--- @param data EntityData
function entity_data.remove(iterator, data)
  renderer.clear(data)
  iterator.entities[data.unit_number] = nil
end

--- @param iterator Iterator
--- @param data EntityData
--- @param fluid_system_id FluidSystemID
function entity_data.remove_system(iterator, data, fluid_system_id)
  if renderer.clear_system(iterator, data, fluid_system_id) then
    iterator.entities[data.unit_number] = nil
  end
end

--- @param iterator Iterator
--- @param entity LuaEntity
--- @return EntityData?
function entity_data.get(iterator, entity)
  local unit_number = entity.unit_number
  if not unit_number then
    return
  end
  return iterator.entities[unit_number]
end

--- @param iterator Iterator
--- @param entity LuaEntity
--- @return EntityData?
function entity_data.get_or_create(iterator, entity)
  local data = entity_data.get(iterator, entity)
  if data then
    return data
  end
  return entity_data.create(iterator, entity)
end

return entity_data
