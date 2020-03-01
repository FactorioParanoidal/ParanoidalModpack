local util = require "util"

local M = {}

--[[
  global.ghosts = {
    ["surface@x,y"] = {
      {
        name = ...,
        surface = ...,
        position = ...,
        connections = {
          {
            wire = ...,
            target_entity_name = ...,
            target_entity_position = ...,
            source_circuit_id = ...,
            target_circuit_id = ...,
          },
          ...
        }
      },
      ...
    }
  }
]]

local entity_filter = "railu?n?loader%-placement%-proxy"

local function is_setup_bp(stack)
  return stack.valid and
    stack.valid_for_read and
    stack.is_blueprint and
    stack.is_blueprint_setup()
end

local function bp_to_world(position, direction)
  return function(bp_position)
    local world_offset
    if direction == defines.direction.north then
      world_offset = bp_position
    elseif direction == defines.direction.east then
      world_offset = { x = -bp_position.y, y = bp_position.x }
    elseif direction == defines.direction.south then
      world_offset = { x = -bp_position.x, y = -bp_position.y }
    elseif direction == defines.direction.west then
      world_offset = { x = bp_position.y, y = -bp_position.x }
    else
      error("invalid direction passed to bp_to_world")
    end
    return { x = position.x + world_offset.x, y = position.y + world_offset.y }
  end
end

local function store_ghost(ghost)
  global.ghosts[util.position_key(ghost)] = ghost
end

local function get_ghost(entity)
  return global.ghosts[util.position_key(entity)]
end

local function bp_bitshift(bp)
  local shift = 0
  for _, e in ipairs(bp.get_blueprint_entities()) do
    local prototype = game.entity_prototypes[e.name]
    if prototype and prototype.building_grid_bit_shift > shift then
      shift = prototype.building_grid_bit_shift
    end
  end
  return shift
end

local function gridalign(bp, position)
  local granularity = 2 ^ bp_bitshift(bp)
  return {
    x = math.floor(position.x / granularity) * granularity + (granularity / 2),
    y = math.floor(position.y / granularity) * granularity + (granularity / 2),
  }
end

local function on_put_item(event)
  if event.mod_name == "Bluebuild" then
    -- Bluebuild fires on_put_item when cursor_stack holds an unrelated item
    return
  end

  local player = game.players[event.player_index]
  local bp = player.cursor_stack
  if not is_setup_bp(bp) then
    return
  end
  local entities = bp.get_blueprint_entities()
  if not entities then
    return
  end
  local position = gridalign(bp, event.position)
  local translate = bp_to_world(position, event.direction)
  if not global.ghost_connections then
    global.ghost_connections = {}
  end
  for _, e in ipairs(bp.get_blueprint_entities()) do
    if e.connections and entity_filter and string.find(e.name, entity_filter) then
      local ghost = {
        name = e.name,
        surface = player.surface,
        position = translate(e.position),
        connections = {},
      }
      for source_circuit_id, wires in pairs(e.connections) do
        for wire_name, conns in pairs(wires) do
          for _, conn in ipairs(conns) do
            ghost.connections[#ghost.connections+1] = {
              wire = defines.wire_type[wire_name],
              target_entity_name = entities[conn.entity_id].name,
              target_entity_position = translate(entities[conn.entity_id].position),
              source_circuit_id = source_circuit_id,
              target_circuit_id = conn.circuit_id,
            }
          end
        end
      end
      store_ghost(ghost)
    end
  end
end

function M.on_init()
  global.ghosts = {}
end

-- returns an array of CircuitConnectionDefinition
function M.get_connections(ghost)
  local out = {}
  local ghost_record = get_ghost(ghost)
  if not ghost_record then
    return out
  end
  for _, conn in ipairs(ghost_record.connections) do
    local target_entity = ghost.surface.find_entity("entity-ghost", conn.target_entity_position)
    if not target_entity then
      target_entity = ghost.surface.find_entity(conn.target_entity_name, conn.target_entity_position)
    end
    if target_entity then
      out[#out+1] = {
        wire = conn.wire,
        target_entity = target_entity,
        source_circuit_id = conn.source_circuit_id,
        target_circuit_id = conn.target_circuit_id,
      }
    end
  end
  return out
end

function M.remove_ghost(ghost)
  global.ghosts[util.position_key(ghost)] = nil
end

script.on_event(defines.events.on_put_item, on_put_item)

return M
