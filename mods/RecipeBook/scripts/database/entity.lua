local table = require("__flib__.table")

local util = require("scripts.util")

return function(database, metadata)
  metadata.gathered_from = {}

  --- @type table<string, LuaEntityPrototype>
  local prototypes = global.prototypes.entity
  for name, prototype in pairs(prototypes) do
    local equipment_categories = util.unique_obj_array()
    local equipment = util.unique_obj_array()
    local equipment_grid = prototype.grid_prototype
    if equipment_grid then
      for _, equipment_category in pairs(equipment_grid.equipment_categories) do
        table.insert(equipment_categories, { class = "equipment_category", name = equipment_category })
        local category_data = database.equipment_category[equipment_category]
        if category_data then
          for _, equipment_name in pairs(category_data.equipment) do
            table.insert(equipment, equipment_name)
          end
        end
      end
    end

    local fuel_categories, fuel_filter = util.process_energy_source(prototype)

    local expected_resources
    local mineable = prototype.mineable_properties
    if
      mineable
      and mineable.minable
      and mineable.products
      and #mineable.products > 0
      and mineable.products[1].name ~= name
    then
      expected_resources = table.map(mineable.products, function(product)
        if not metadata.gathered_from[product.name] then
          metadata.gathered_from[product.name] = {}
        end
        table.insert(metadata.gathered_from[product.name], { class = "entity", name = name })
        return { class = product.type, name = product.name, amount_ident = util.build_amount_ident(product) }
      end)
    end

    database.entity[name] = {
      accepted_equipment = equipment,
      blueprintable = util.is_blueprintable(prototype),
      can_burn = {},
      class = "entity",
      enabled_at_start = expected_resources and true or false, -- FIXME: This is inaccurate
      entity_type = { class = "entity_type", name = prototype.type },
      equipment_categories = equipment_categories,
      expected_resources = expected_resources,
      fuel_categories = fuel_categories,
      fuel_filter = fuel_filter,
      module_slots = prototype.module_inventory_size
          and prototype.module_inventory_size > 0
          and prototype.module_inventory_size
        or nil,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      science_packs = {},
      unlocked_by = {},
    }

    util.add_to_dictionary("entity", name, prototype.localised_name)
    util.add_to_dictionary("entity_description", name, prototype.localised_description)
  end
end
