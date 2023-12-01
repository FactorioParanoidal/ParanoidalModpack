local util = require("scripts.util")

return function(database, metadata)
  -- Characters as crafters
  for name, prototype in pairs(global.prototypes.character) do
    local ingredient_limit = prototype.ingredient_count
    if ingredient_limit == 255 then
      ingredient_limit = nil
    end
    database.entity[name] = {
      accepted_modules = {}, -- Always empty
      blueprintable = false,
      can_burn = {}, -- Always empty
      can_craft = {},
      class = "entity",
      crafting_speed = 1,
      enabled = true,
      entity_type = { class = "entity_type", name = prototype.type },
      hidden = false,
      ingredient_limit = ingredient_limit,
      is_character = true,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      recipe_categories_lookup = prototype.crafting_categories or {},
      recipe_categories = util.convert_categories(prototype.crafting_categories or {}, "recipe_category"),
      science_packs = {},
      unlocked_by = {},
    }
    util.add_to_dictionary("entity", name, prototype.localised_name)
    util.add_to_dictionary("entity_description", name, prototype.localised_description)
  end

  -- Actual crafters
  metadata.allowed_effects = {}
  metadata.crafter_fluidbox_counts = {}
  metadata.fixed_recipes = {}
  local rocket_silo_categories = util.unique_obj_array()
  for name, prototype in pairs(global.prototypes.crafter) do
    -- Fixed recipe
    local fixed_recipe
    if prototype.fixed_recipe then
      metadata.fixed_recipes[prototype.fixed_recipe] = true
      fixed_recipe = { class = "recipe", name = prototype.fixed_recipe }
    end

    -- Rocket silo categories
    if prototype.rocket_parts_required then
      for category in pairs(prototype.crafting_categories) do
        table.insert(rocket_silo_categories, { class = "recipe_category", name = category })
      end
    end

    local ingredient_limit = prototype.ingredient_count
    if ingredient_limit == 255 then
      ingredient_limit = nil
    end

    metadata.allowed_effects[name] = prototype.allowed_effects

    local fluidboxes = prototype.fluidbox_prototypes
    if fluidboxes then
      local fluidbox_counts = { inputs = 0, outputs = 0 }
      for _, fluidbox in pairs(fluidboxes) do
        local type = fluidbox.production_type
        if string.find(type, "input") then
          fluidbox_counts.inputs = fluidbox_counts.inputs + 1
        end
        if string.find(type, "output") then
          fluidbox_counts.outputs = fluidbox_counts.outputs + 1
        end
      end
      metadata.crafter_fluidbox_counts[name] = fluidbox_counts
    end

    local is_hidden = prototype.has_flag("hidden")
    local fuel_categories, fuel_filter = util.process_energy_source(prototype)
    database.entity[name] = {
      accepted_modules = {},
      blueprintable = util.is_blueprintable(prototype),
      can_burn = {},
      can_craft = {},
      class = "entity",
      crafting_speed = prototype.crafting_speed,
      entity_type = { class = "entity_type", name = prototype.type },
      fixed_recipe = fixed_recipe,
      fuel_categories = fuel_categories,
      fuel_filter = fuel_filter,
      hidden = is_hidden,
      ingredient_limit = ingredient_limit,
      module_slots = prototype.module_inventory_size
          and prototype.module_inventory_size > 0
          and prototype.module_inventory_size
        or nil,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      recipe_categories_lookup = prototype.crafting_categories or {},
      recipe_categories = util.convert_categories(prototype.crafting_categories or {}, "recipe_category"),
      rocket_parts_required = prototype.rocket_parts_required,
      science_packs = {},
      size = util.get_size(prototype),
      unlocked_by = {},
    }
    util.add_to_dictionary("entity", name, prototype.localised_name)
    util.add_to_dictionary("entity_description", name, prototype.localised_description)
  end

  metadata.rocket_silo_categories = rocket_silo_categories
end
