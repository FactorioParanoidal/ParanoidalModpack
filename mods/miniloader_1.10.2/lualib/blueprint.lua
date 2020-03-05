local util = require("lualib.util")

local M = {}

local function inserters_in_position(bp_entities, starting_index)
  local out = {}
  local x = bp_entities[starting_index].position.x
  local y = bp_entities[starting_index].position.y
  for i=starting_index,#bp_entities do
    local ent = bp_entities[i]
    if ent.position.x == x and ent.position.y == y and util.is_miniloader_inserter(ent) then
      out[#out+1] = ent
    end
  end
  return out
end

local function count_connections(bp_entity)
  local out = 0
  if not bp_entity.connections then
    return 0
  end
  for _, circuit in pairs(bp_entity.connections) do
    for _, wire_connections in pairs(circuit) do
      out = out + #wire_connections
    end
  end
  return out
end

-- Expects a list of miniloader-inserter blueprint entities in a single position.
-- Only the miniloader-inserter with the most circuit connections is retained,
-- the others are added to to_remove.
local function find_slaves(miniloader_inserters, to_remove)
  local most_connected_inserter
  local most_connections
  for _, inserter in ipairs(miniloader_inserters) do
    local num_connections = count_connections(inserter)
    if not most_connected_inserter or num_connections > most_connections then
      most_connected_inserter = inserter
      most_connections = num_connections
    end
  end

  -- iterate back over and record slaves
  for _, inserter in ipairs(miniloader_inserters) do
    if inserter ~= most_connected_inserter then
      to_remove[inserter.entity_number] = true
    end
  end
end

local function remove_connections(bp_entity, to_remove_set)
  local connections = bp_entity.connections
  if not connections then
    return
  end
  for circuit_id, circuit_connections in pairs(connections) do
    if not circuit_id:find("^Cu") then -- ignore copper cables on power switch
      for wire_name, wire_connections in pairs(circuit_connections) do
        local new_wire_connections = {}
        for _, connection in ipairs(wire_connections) do
          if not to_remove_set[connection.entity_id] then
            new_wire_connections[#new_wire_connections+1] = connection
          end
        end
        if next(new_wire_connections) then
          circuit_connections[wire_name] = new_wire_connections
        else
          circuit_connections[wire_name] = nil
        end
      end
    end
  end
end

local function remove_entities(bp_entities, to_remove_set)
  local cnt = #bp_entities
  for i=1,cnt do
    remove_connections(bp_entities[i], to_remove_set)
  end

  local w = 1
  for r=1,cnt do
    if not to_remove_set[bp_entities[r].entity_number] then
      bp_entities[w] = bp_entities[r]
      w = w + 1
    end
  end
  for i=w,cnt do
    bp_entities[i] = nil
  end
end

function M.is_setup_bp(stack)
  return stack and
    stack.valid and
    stack.valid_for_read and
    stack.is_blueprint and
    stack.is_blueprint_setup()
end

function M.bounding_box(bp)
  local left = -0.1
  local top = -0.1
  local right = 0.1
  local bottom = 0.1

  local entities = bp.get_blueprint_entities()
  if entities then
    for _, e in pairs(entities) do
      local pos = e.position
      if pos.x < left then left = pos.x - 0.5 end
      if pos.y < top then top = pos.y - 0.5 end
      if pos.x > right then right = pos.x + 0.5 end
      if pos.y > bottom then bottom = pos.y + 0.5 end
    end
  end

  return {
    left_top = {x=left, y=top},
    right_bottom = {x=right, y=bottom},
  }
end

function M.filter_miniloaders(bp)
  local bp_entities = bp.get_blueprint_entities()
  if not bp_entities then
    return
  end
  local to_remove = {}
  for i, ent in ipairs(bp_entities) do
    if util.is_miniloader_inserter(ent) then
      local overlapping = inserters_in_position(bp_entities, i)
      find_slaves(overlapping, to_remove)
    end
  end
  if next(to_remove) then
    remove_entities(bp_entities, to_remove)
    bp.set_blueprint_entities(bp_entities)
  end
end

return M