local util = require "util"

local M = {}

-- returns an array of CircuitConnectionDefinition
function M.get_connections(entity)
  local position = entity.position
  local distance = entity.prototype.max_circuit_wire_distance
  local area = {
    left_top = { x = position.x - distance, y = position.y - distance },
    right_bottom = { x = position.x + distance, y = position.y + distance }
  }
  local ghosts = entity.surface.find_entities_filtered{
    type = "entity-ghost",
    area = area,
  }

  local out = {}
  for _, ghost in pairs(ghosts) do
    for _, ccd in pairs(ghost.circuit_connection_definitions or {}) do
      if ccd.target_entity == entity then
        out[#out+1] = {
          wire = ccd.wire,
          target_entity = ghost,
          source_circuit_id = ccd.target_circuit_id,
          target_circuit_id = ccd.source_circuit_id,
        }
      end
    end
  end

  return out
end

return M
