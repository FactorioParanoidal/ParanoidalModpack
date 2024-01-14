local fluid_proc = require("scripts.database.fluid")
local util = require("scripts.util")

return function(database)
  --- @type LuaCustomTable<string, LuaEntityPrototype>
  local prototypes = global.prototypes.resource
  for name, prototype in pairs(prototypes) do
    local products = prototype.mineable_properties.products
    if products then
      for _, product in ipairs(products) do
        local product_data = database[product.type][product.name]
        if product_data then
          product_data.mined_from[#product_data.mined_from + 1] = { class = "resource", name = name }
        end
      end
    end
    local required_fluid
    local mineable_properties = prototype.mineable_properties
    if mineable_properties.required_fluid then
      required_fluid = {
        class = "fluid",
        name = mineable_properties.required_fluid,
        -- Ten mining operations per amount consumed, so divide by 10 to get the actual number
        amount_ident = util.build_amount_ident({ amount = mineable_properties.fluid_amount / 10 }),
      }
    else
      -- TODO: Validate that it's hand-mineable by checking character mineable categories (requires an API addition)
      -- Enable resource items that are hand-minable
      for _, product in ipairs(mineable_properties.products or {}) do
        if product.type == "item" then
          local product_data = database[product.type][product.name]
          product_data.enabled_at_start = true
        end
      end
    end

    local products = {}
    for i, product in pairs(mineable_properties.products or {}) do
      products[i] = {
        class = product.type,
        name = product.name,
        amount_ident = util.build_amount_ident(product),
      }
      -- Fluid temperatures
      local temperature_ident = product.type == "fluid" and util.build_temperature_ident(product) or nil
      if temperature_ident then
        products[i].temperature_ident = temperature_ident
        fluid_proc.add_temperature(database.fluid[product.name], temperature_ident)
      end
    end

    local mined_by = {}
    local resource_category = prototype.resource_category
    for drill_name in pairs(global.prototypes.mining_drill) do
      local drill_data = database.entity[drill_name]
      if
        drill_data.resource_categories_lookup[resource_category]
        and (not required_fluid or drill_data.supports_fluid)
      then
        mined_by[#mined_by + 1] = { class = "entity", name = drill_name }
      end
    end

    local resource_category_data = database.resource_category[resource_category]
    resource_category_data.resources[#resource_category_data.resources + 1] = { class = "resource", name = name }

    database.resource[name] = {
      class = "resource",
      mined_by = mined_by,
      mining_time = mineable_properties.mining_time,
      products = products,
      prototype_name = name,
      resource_category = { class = "resource_category", name = resource_category },
      required_fluid = required_fluid,
    }
    util.add_to_dictionary("resource", name, prototype.localised_name)
    util.add_to_dictionary("resource_description", name, prototype.localised_description)
  end
end
