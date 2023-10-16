local table = require("__flib__.table")

local util = require("scripts.util")

local properties_by_type = {
  ["active-defense-equipment"] = { { "energy_consumption", "energy" } },
  ["battery-equipment"] = {},
  ["belt-immunity-equipment"] = { { "energy_consumption", "energy" } },
  ["energy-shield-equipment"] = {
    { "energy_consumption", "energy" },
    { "shield", "number", "shield_points" },
    { "energy_per_shield", "energy", "energy_per_shield_point" },
  },
  ["generator-equipment"] = { { "energy_production", "energy" } },
  ["movement-bonus-equipment"] = { { "energy_consumption", "energy" }, { "movement_bonus", "percent" } },
  ["night-vision-equipment"] = { { "energy_consumption", "energy" } },
  ["roboport-equipment"] = { { "energy_consumption", "energy" } },
  ["solar-panel-equipment"] = { { "energy_production", "energy" } },
}

local function get_equipment_property(properties, source, name, formatter, label)
  local value = source[name]
  if value and value > 0 then
    table.insert(properties, {
      type = "plain",
      label = label or name,
      value = value,
      formatter = formatter,
    })
  end
end

return function(database)
  --- @type table<string, LuaEquipmentPrototype>
  local prototypes = global.prototypes.equipment
  for name, prototype in pairs(prototypes) do
    local fuel_categories
    local burner = prototype.burner_prototype
    if burner then
      fuel_categories = util.convert_categories(burner.fuel_categories, "fuel_category")
    end

    for _, category in pairs(prototype.equipment_categories) do
      local category_data = database.equipment_category[category]
      category_data.equipment[#category_data.equipment + 1] = { class = "equipment", name = name }
    end

    local equipment_type = prototype.type
    local properties = {}
    for _, property in pairs(properties_by_type[equipment_type]) do
      get_equipment_property(properties, prototype, property[1], property[2], property[3])
    end

    local energy_source = prototype.energy_source
    if energy_source then
      get_equipment_property(properties, energy_source, "buffer_capacity", "energy_storage")
    end

    if equipment_type == "roboport-equipment" then
      local logistic_parameters = prototype.logistic_parameters
      get_equipment_property(properties, logistic_parameters, "logistic_radius", "number")
      get_equipment_property(properties, logistic_parameters, "construction_radius", "number")
      get_equipment_property(properties, logistic_parameters, "robot_limit", "number")
      get_equipment_property(properties, logistic_parameters, "charging_energy", "energy")
    end

    database.equipment[name] = {
      can_burn = {},
      class = "equipment",
      enabled = true,
      equipment_categories = table.map(prototype.equipment_categories, function(category)
        return { class = "equipment_category", name = category }
      end),
      equipment_properties = properties,
      fuel_categories = fuel_categories,
      hidden = false,
      placed_in = util.unique_obj_array(),
      prototype_name = name,
      science_packs = {},
      size = prototype.shape and prototype.shape.width or nil, -- Equipments can have irregular shapes
      take_result = prototype.take_result and { class = "item", name = prototype.take_result.name } or nil,
      unlocked_by = {},
    }
    util.add_to_dictionary("equipment", name, prototype.localised_name)
    util.add_to_dictionary("equipment_description", name, prototype.localised_description)
  end
end
