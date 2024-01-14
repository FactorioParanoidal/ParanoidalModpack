local table = require("__flib__.table")

local util = require("scripts.util")

local lab_proc = {}

function lab_proc.build(database)
  for name, prototype in pairs(global.prototypes.lab) do
    local fuel_categories, fuel_filter = util.process_energy_source(prototype)
    database.entity[name] = {
      blueprintable = util.is_blueprintable(prototype),
      can_burn = {},
      class = "entity",
      entity_type = { class = "entity_type", name = prototype.type },
      fuel_categories = fuel_categories,
      fuel_filter = fuel_filter,
      hidden = prototype.has_flag("hidden"),
      inputs = table.map(prototype.lab_inputs, function(v)
        return { class = "item", name = v }
      end),
      module_slots = prototype.module_inventory_size
          and prototype.module_inventory_size > 0
          and prototype.module_inventory_size
        or nil,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      researching_speed = prototype.researching_speed,
      science_packs = {},
      size = util.get_size(prototype),
      unlocked_by = {},
    }
    util.add_to_dictionary("entity", name, prototype.localised_name)
    util.add_to_dictionary("entity_description", name, prototype.localised_description)
  end
end

-- Store labs in science pack items' researched_in
function lab_proc.process_researched_in(database)
  for name, prototype in pairs(global.prototypes.lab) do
    -- Add to items
    for _, item_name in ipairs(prototype.lab_inputs) do
      local item_data = database.item[item_name]
      if item_data then
        item_data.researched_in[#item_data.researched_in + 1] = { class = "entity", name = name }
      end
    end
  end
end

-- When calling the module directly, call lab_proc.build
setmetatable(lab_proc, {
  __call = function(_, ...)
    return lab_proc.build(...)
  end,
})

return lab_proc
