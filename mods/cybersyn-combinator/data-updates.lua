local constants = require "scripts.constants"

for _, prototype in pairs(data.raw["assembling-machine"]) do
  if not prototype.additional_pastable_entities then
    prototype.additional_pastable_entities = {}
  end
  table.insert(prototype.additional_pastable_entities, constants.ENTITY_NAME)
end
