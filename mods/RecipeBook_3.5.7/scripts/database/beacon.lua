local util = require("scripts.util")

return function(database, metadata)
  metadata.beacon_allowed_effects = {}
  for name, prototype in pairs(global.prototypes.beacon) do
    local size = util.get_size(prototype) --[[@as DisplayResolution]]

    database.entity[name] = {
      accepted_modules = {},
      blueprintable = util.is_blueprintable(prototype),
      class = "entity",
      distribution_effectivity = prototype.distribution_effectivity,
      effect_area = {
        height = size.height + (prototype.supply_area_distance * 2),
        width = size.width + (prototype.supply_area_distance * 2),
      },
      energy_usage = prototype.energy_usage,
      entity_type = { class = "entity_type", name = prototype.type },
      module_slots = prototype.module_inventory_size
          and prototype.module_inventory_size > 0
          and prototype.module_inventory_size
        or nil,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      science_packs = {},
      size = size,
      unlocked_by = {},
    }

    util.add_to_dictionary("entity", name, prototype.localised_name)
    util.add_to_dictionary("entity_description", name, prototype.localised_description)

    metadata.beacon_allowed_effects[name] = prototype.allowed_effects
  end
end
