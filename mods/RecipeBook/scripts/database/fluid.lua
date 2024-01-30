local table = require("__flib__.table")

local constants = require("constants")

local util = require("scripts.util")

local fluid_proc = {}

function fluid_proc.build(database, metadata)
  local localised_fluids = {}
  for name, prototype in pairs(global.prototypes.fluid) do
    -- Group
    local group = prototype.group
    local group_data = database.group[group.name]
    group_data.fluids[#group_data.fluids + 1] = { class = "fluid", name = name }
    -- Fake fuel category
    local fuel_category
    if prototype.fuel_value > 0 then
      fuel_category = { class = "fuel_category", name = constants.fake_fluid_fuel_category }
      local fluids = database.fuel_category[constants.fake_fluid_fuel_category].fluids
      fluids[#fluids + 1] = { class = "fluid", name = name }
    end
    -- Save to recipe book
    database.fluid[name] = {
      burned_in = {},
      class = "fluid",
      default_temperature = prototype.default_temperature,
      fuel_category = fuel_category,
      fuel_pollution = prototype.fuel_value > 0
          and prototype.emissions_multiplier ~= 1
          and prototype.emissions_multiplier
        or nil,
      fuel_value = prototype.fuel_value > 0 and prototype.fuel_value or nil,
      group = { class = "group", name = group.name },
      hidden = prototype.hidden,
      ingredient_in = {},
      mined_from = {},
      product_of = {},
      prototype_name = name,
      pumped_by = {},
      recipe_categories = util.unique_obj_array(),
      science_packs = {},
      subgroup = { class = "group", name = prototype.subgroup.name },
      temperatures = {},
      unlocked_by = util.unique_obj_array(),
    }
    -- Don't add strings yet - they will be added in process_temperatures() to improve the ordering
    localised_fluids[name] = { name = prototype.localised_name, description = prototype.localised_description }
  end
  metadata.localised_fluids = localised_fluids
end

-- Adds a fluid temperature definition if one doesn't exist yet
function fluid_proc.add_temperature(fluid_data, temperature_ident)
  local temperature_string = temperature_ident.string

  local temperatures = fluid_data.temperatures
  if not temperatures[temperature_string] then
    temperatures[temperature_string] = {
      base_fluid = { class = "fluid", name = fluid_data.prototype_name },
      class = "fluid",
      default_temperature = fluid_data.default_temperature,
      fuel_pollution = fluid_data.fuel_pollution,
      fuel_value = fluid_data.fuel_value,
      group = fluid_data.group,
      hidden = fluid_data.hidden,
      ingredient_in = {},
      mined_from = {},
      name = fluid_data.prototype_name .. "." .. temperature_string,
      product_of = {},
      prototype_name = fluid_data.prototype_name,
      recipe_categories = util.unique_obj_array(),
      science_packs = {},
      subgroup = fluid_data.subgroup,
      temperature_ident = temperature_ident,
      unlocked_by = util.unique_obj_array(),
    }
  end
end

-- Returns true if `comp` is within `base`
function fluid_proc.is_within_range(base, comp, flip)
  if flip then
    return base.min >= comp.min and base.max <= comp.max
  else
    return base.min <= comp.min and base.max >= comp.max
  end
end

function fluid_proc.process_temperatures(database, metadata)
  -- Create a new fluids table so insertion order will neatly organize the temperature variants
  local new_fluid_table = {}
  for fluid_name, fluid_data in pairs(database.fluid) do
    new_fluid_table[fluid_name] = fluid_data
    local localised = metadata.localised_fluids[fluid_name]
    util.add_to_dictionary("fluid", fluid_name, localised.name)
    util.add_to_dictionary("fluid_description", fluid_name, localised.description)
    local temperatures = fluid_data.temperatures
    if temperatures and next(temperatures) then
      -- Step 1: Add a variant for the default temperature if one does not exist
      local default_temperature = fluid_data.default_temperature
      local default_temperature_ident = util.build_temperature_ident({ temperature = default_temperature })
      if not temperatures[default_temperature_ident.string] then
        fluid_proc.add_temperature(fluid_data, default_temperature_ident)
      end

      -- Step 2: Sort the temperature variants
      local temp = {}
      for _, temperature_data in pairs(temperatures) do
        table.insert(temp, temperature_data)
      end
      table.sort(temp, function(temp_a, temp_b)
        return util.get_sorting_number(temp_a.temperature_ident) < util.get_sorting_number(temp_b.temperature_ident)
      end)
      -- Create a new table and insert in order
      temperatures = {}
      for _, temperature_data in pairs(temp) do
        temperatures[temperature_data.name] = temperature_data
        -- Add to database and add translation
        new_fluid_table[temperature_data.name] = temperature_data
        util.add_to_dictionary("fluid", temperature_data.name, {
          "",
          localised.name,
          " (",
          { "format-degrees-c-compact", temperature_data.temperature_ident.string },
          ")",
        })
      end
      fluid_data.temperatures = temperatures

      -- Step 3: Add researched properties to temperature variants
      for _, temperature_data in pairs(temperatures) do
        temperature_data.enabled_at_start = fluid_data.enabled_at_start
        if fluid_data.researched_forces then
          temperature_data.researched_forces = {}
        end
      end

      -- Step 4: Add properties from base fluid to temperature variants
      -- TODO: This is an idiotic way to do this
      for fluid_tbl_name, obj_table_name in pairs({
        ingredient_in = "ingredients",
        product_of = "products",
        mined_from = "products",
      }) do
        for _, obj_ident in pairs(fluid_data[fluid_tbl_name]) do
          local obj_data = database[obj_ident.class][obj_ident.name]

          -- Get the matching fluid
          local fluid_ident
          -- This is kind of a slow way to do it, but I don't really care
          for _, material_ident in pairs(obj_data[obj_table_name]) do
            if material_ident.name == fluid_name then
              fluid_ident = material_ident
              break
            end
          end

          -- Get the temperature identifier from the material table
          local temperature_ident = fluid_ident.temperature_ident
          if temperature_ident then
            -- Change the name of the material and remove the identifier
            fluid_ident.name = fluid_ident.name .. "." .. temperature_ident.string
            fluid_ident.temperature_ident = nil
          elseif obj_table_name == "products" then
            -- Change the name of the material to the default temperature
            fluid_ident.name = fluid_ident.name .. "." .. default_temperature_ident.string
            fluid_ident.temperature_ident = nil
            -- Use the default temperature for matching
            temperature_ident = default_temperature_ident
          end

          -- Iterate over all temperature variants and compare their constraints
          for _, temperature_data in pairs(temperatures) do
            if
              not temperature_ident
              or fluid_proc.is_within_range(
                temperature_data.temperature_ident,
                temperature_ident,
                fluid_tbl_name == "ingredient_in"
              )
            then
              -- Add to recipes table
              temperature_data[fluid_tbl_name][#temperature_data[fluid_tbl_name] + 1] = obj_ident
              -- Recipe-specific logic
              if obj_ident.class == "recipe" then
                -- Add recipe category
                local recipe_categories = temperature_data.recipe_categories
                recipe_categories[#recipe_categories + 1] = table.shallow_copy(obj_data.recipe_category)
                -- If in product_of, append to unlocked_by
                -- Also add this fluid to that tech's `unlocks fluids` table
                -- This is to avoid variants being "unlocked" when you can't actually get them
                -- If this is an "empty X barrel" recipe, ignore it
                if fluid_tbl_name == "product_of" and not string.find(obj_ident.name, "^empty%-.+%-barrel$") then
                  local temp_unlocked_by = temperature_data.unlocked_by
                  for _, technology_ident in pairs(obj_data.unlocked_by) do
                    temp_unlocked_by[#temp_unlocked_by + 1] = technology_ident
                    local technology_data = database.technology[technology_ident.name]
                    -- Don't use fluid_ident becuase it has an amount
                    technology_data.unlocks_fluids[#technology_data.unlocks_fluids + 1] = {
                      class = "fluid",
                      name = temperature_data.name,
                    }
                  end
                end
              end
            end
          end
        end
      end

      -- Step 5: If this variant is not produced by anything, unlock with the base fluid
      for _, temperature_data in pairs(temperatures) do
        if #temperature_data.product_of == 0 and #temperature_data.unlocked_by == 0 then
          temperature_data.unlocked_by = table.deep_copy(fluid_data.unlocked_by)
          for _, technology_ident in pairs(fluid_data.unlocked_by) do
            local technology_data = database.technology[technology_ident.name]
            -- Don't use fluid_ident becuase it has an amount
            technology_data.unlocks_fluids[#technology_data.unlocks_fluids + 1] = {
              class = "fluid",
              name = temperature_data.name,
            }
          end
        end
      end
    end
  end
  database.fluid = new_fluid_table
end

-- When calling the module directly, call fluid_proc.build
setmetatable(fluid_proc, {
  __call = function(_, ...)
    return fluid_proc.build(...)
  end,
})

return fluid_proc
