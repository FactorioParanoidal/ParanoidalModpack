local constants = require "scripts.constants"

local filter = {
  ghost_type = "constant-combinator",
  ghost_name = constants.ENTITY_NAME
}
for _, surface in pairs(game.surfaces) do
  local entities = surface.find_entities_filtered(filter)
  for _, entity in pairs(entities) do
    if entity.valid and entity.tags and type(entity.tags.description) == "string" then
      entity.combinator_description = entity.tags.description --[[@as string]]
      entity.tags.description = nil
    end
  end
end
