local constants = require("constants")
local fake_name = constants.fake_fluid_fuel_category

local util = require("scripts.util")

local fuel_category_proc = {}

function fuel_category_proc.build(database)
  -- Add the actual fuel categories
  for name, prototype in pairs(global.prototypes.fuel_category) do
    database.fuel_category[name] = {
      class = "fuel_category",
      enabled_at_start = true,
      fluids = {}, -- Will always be empty
      items = util.unique_obj_array({}),
      prototype_name = name,
    }
    util.add_to_dictionary("fuel_category", name, prototype.localised_name)
    util.add_to_dictionary("fuel_category_description", name, prototype.localised_description)
  end

  -- Add our fake fuel category for fluids
  database.fuel_category[fake_name] = {
    class = "fuel_category",
    enabled_at_start = true,
    fluids = util.unique_obj_array({}),
    items = {}, -- Will always be empty
    prototype_name = fake_name,
  }
end

function fuel_category_proc.check_fake_category(database)
  local category = database.fuel_category[fake_name]
  if #category.fluids > 0 then
    -- Add translations
    util.add_to_dictionary("fuel_category", fake_name, { "fuel-category-name." .. fake_name })
    util.add_to_dictionary("fuel_category_description", fake_name, { "fuel-category-description." .. fake_name })
  else
    -- Remove the category
    database.fuel_category[fake_name] = nil
  end
end

-- When calling the module directly, call fuel_category_proc.build
setmetatable(fuel_category_proc, {
  __call = function(_, ...)
    return fuel_category_proc.build(...)
  end,
})

return fuel_category_proc
