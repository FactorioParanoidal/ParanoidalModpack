local math = require("__flib__.math")

local constants = require("constants")

local util = require("scripts.util")

local fluid_proc = require("scripts.database.fluid")

return function(database, metadata)
  for name, prototype in pairs(global.prototypes.recipe) do
    local category = prototype.category
    local group = prototype.group

    local enabled_at_start = prototype.enabled

    -- Add to recipe category
    local category_data = database.recipe_category[category]
    category_data.recipes[#category_data.recipes + 1] = { class = "recipe", name = name }

    -- Add to group
    local group_data = database.group[group.name]
    group_data.recipes[#group_data.recipes + 1] = { class = "recipe", name = name }

    local data = {
      accepted_modules = {},
      class = "recipe",
      enabled_at_start = enabled_at_start,
      energy = prototype.energy,
      group = { class = "group", name = group.name },
      hidden = prototype.hidden,
      made_in = {},
      pollution_multiplier = prototype.emissions_multiplier ~= 1 and prototype.emissions_multiplier or nil,
      prototype_name = name,
      recipe_category = { class = "recipe_category", name = category },
      science_packs = {},
      subgroup = { class = "group", name = prototype.subgroup.name },
      unlocked_by = {},
      used_as_fixed_recipe = metadata.fixed_recipes[name],
    }

    -- Ingredients / products
    local fluids = { ingredients = 0, products = 0 }
    for lookup_type, io_type in pairs({ ingredient_in = "ingredients", product_of = "products" }) do
      local output = {}
      for i, material in ipairs(prototype[io_type]) do
        local amount_ident = util.build_amount_ident(material)
        local material_io_data = {
          class = material.type,
          name = material.name,
          amount_ident = amount_ident,
        }
        local material_data = database[material.type][material.name]
        local lookup_table = material_data[lookup_type]
        lookup_table[#lookup_table + 1] = { class = "recipe", name = name }
        output[i] = material_io_data
        material_data.recipe_categories[#material_data.recipe_categories + 1] = {
          class = "recipe_category",
          name = category,
        }

        -- Don't set enabled at start if this is an ignored recipe
        local disabled = constants.disabled_categories.recipe_category[category]
        if io_type == "products" and (not disabled or disabled ~= 0) then
          local subtable = category_data[material.type .. "s"]
          subtable[#subtable + 1] = { class = material.type, name = material.name }

          -- If this recipe is enabled at start and is not disabled,
          -- set enabled at start for its products and their placement results.
          if enabled_at_start then
            material_data.enabled_at_start = true
            for _, property in pairs({ "place_result", "place_as_equipment_result" }) do
              local placed_ident = material_data[property]
              if placed_ident then
                local placed_data = database[placed_ident.class][placed_ident.name]
                if placed_data then
                  placed_data.enabled_at_start = true
                end
              end
            end
          end
        end

        if material.type == "fluid" then
          -- Fluid temperatures
          local temperature_ident = util.build_temperature_ident(material)
          if temperature_ident then
            material_io_data.temperature_ident = temperature_ident
            fluid_proc.add_temperature(database.fluid[material.name], temperature_ident)
          end
          -- Add to aggregate
          fluids[io_type] = fluids[io_type] + 1
        end
      end

      data[io_type] = output
    end

    -- Made in
    local num_item_ingredients = 0
    for _, ingredient in pairs(prototype.ingredients) do
      if ingredient.type == "item" then
        num_item_ingredients = num_item_ingredients + 1
      end
    end
    for _, crafters in pairs({ global.prototypes.character, global.prototypes.crafter }) do
      for crafter_name in pairs(crafters) do
        local crafter_data = database.entity[crafter_name]
        local fluidbox_counts = metadata.crafter_fluidbox_counts[crafter_name] or { inputs = 0, outputs = 0 }
        if
          (crafter_data.ingredient_limit or 255) >= num_item_ingredients
          and crafter_data.recipe_categories_lookup[category]
          and fluidbox_counts.inputs >= fluids.ingredients
          and fluidbox_counts.outputs >= fluids.products
        then
          local crafting_time = math.round(prototype.energy / crafter_data.crafting_speed, 0.01)
          data.made_in[#data.made_in + 1] = {
            class = "entity",
            name = crafter_name,
            amount_ident = util.build_amount_ident({ amount = crafting_time, format = "format_seconds_parenthesis" }),
          }
          crafter_data.can_craft[#crafter_data.can_craft + 1] = { class = "recipe", name = name }
        end
      end
    end

    -- Compatible modules
    for module_name, module_limitations in pairs(metadata.modules) do
      if not next(module_limitations) or module_limitations[name] then
        data.accepted_modules[#data.accepted_modules + 1] = { class = "item", name = module_name }
        table.insert(database.item[module_name].affects_recipes, { class = "recipe", name = name })
      end
    end

    database.recipe[name] = data
    util.add_to_dictionary("recipe", name, prototype.localised_name)
    util.add_to_dictionary("recipe_description", name, prototype.localised_description)
  end
end
