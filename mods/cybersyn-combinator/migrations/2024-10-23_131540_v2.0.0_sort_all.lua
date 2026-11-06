local constants = require "scripts.constants"
local CybersynCombinator = require "scripts.combinator"

local filter = {
  name = constants.ENTITY_NAME
}
for _, surface in pairs(game.surfaces) do
  local entities = surface.find_entities_filtered(filter)
  for _, entity in pairs(entities) do
    if entity.valid then
      local combinator = CybersynCombinator:new(entity, false)
      combinator:sort_signals()
    end
  end
end
