
local Public = {}


local fuel_category_warnings = {}

-- Claude
--- Combines duplicate science pack entries in an ingredients list,
--- summing their amounts.
--- @param ingredients table  Array of {name, amount} entries
--- @return table  New array with one entry per unique science pack
local function combine_science_packs(ingredients)
  local totals = {}      -- name -> summed amount
  local order = {}       -- preserves first-seen order of names

  for _, ingredient in ipairs(ingredients) do
    local name = ingredient[1] or ingredient.name
    local amount = ingredient[2] or ingredient.amount

    if not totals[name] then
      totals[name] = 0
      table.insert(order, name)
    end
    totals[name] = totals[name] + amount
  end

  local result = {}
  for _, name in ipairs(order) do
    table.insert(result, {name, totals[name]})
  end

  return result
end

-- Claude
--- Converts the obsolete WaterTileEffectParameters::textures field to the
--- split noise_textures/image_textures fields introduced in Factorio 2.1.22.
--- @param water table  The tile effect's water parameters
--- @param variation string|nil  The water shader variation
--- @return boolean  Whether the table was modified
local function correct_water_textures(water, variation)
  local textures = water.textures
  local changed = false

  local function as_noise(texture)
    if not texture then
      return nil
    end
    local converted = table.deepcopy(texture)
    if converted.width and converted.height and not converted.size then
      if converted.width == converted.height then
        converted.size = converted.width
        converted.width = nil
        converted.height = nil
      end
    end
    return converted
  end

  local function as_image(texture)
    if not texture then
      return nil
    end
    local converted = table.deepcopy(texture)
    -- Image texture dimensions are now read from the image itself.
    converted.width = nil
    converted.height = nil
    converted.size = nil
    return converted
  end

  if textures then
    local noise_textures = {}
    local image_textures = {}

    if variation == "lava" then
      -- The lava shader used one multi-channel noise texture before 2.1.22 and
      -- two noise textures afterwards. Reusing the old texture as both layers
      -- keeps the effect functional until the mod updates its graphics.
      noise_textures = {as_noise(textures[1]), as_noise(textures[1])}
      image_textures = {as_image(textures[2])}
    elseif variation == "oil" then
      -- Old order: noise, image, gradient, specular image.
      noise_textures = {as_noise(textures[1]), as_noise(textures[3])}
      image_textures = {as_image(textures[2]), as_image(textures[4])}
    elseif variation == "wetland-water" then
      noise_textures = {as_noise(textures[1])}
      image_textures = {as_image(textures[2])}
    else
      noise_textures = {as_noise(textures[1])}
      image_textures = {as_image(textures[2])}
    end

    water.noise_textures = noise_textures
    water.image_textures = image_textures
    water.textures = nil
    changed = true
  end

  if water.texture_variations_columns ~= nil
    or water.texture_variations_rows ~= nil
    or water.secondary_texture_variations_columns ~= nil
    or water.secondary_texture_variations_rows ~= nil then
    water.texture_variations_columns = nil
    water.texture_variations_rows = nil
    water.secondary_texture_variations_columns = nil
    water.secondary_texture_variations_rows = nil
    changed = true
  end

  return changed
end



-- Claude
--- Moves the obsolete FluidBox::minimum_temperature/maximum_temperature fields
--- to the machine-level temperature fields introduced in Factorio 2.1.22.
--- @param prototype table  Any prototype from data.raw
--- @return boolean  Whether the prototype was modified
local function correct_fluid_box_temperatures(prototype)
  if type(prototype) ~= "table" then
    return false
  end

  local changed = false

  local function convert(box,target,min_field,max_field)
    if type(box) ~= "table" then
      return
    end
    local minimum = box.minimum_temperature
    local maximum = box.maximum_temperature
    if minimum == nil and maximum == nil then
      return
    end
    --A value of zero previously meant "no limit", which is now represented by nil.
    if target and min_field and minimum and minimum ~= 0 and target[min_field] == nil then
      target[min_field] = minimum
    end
    if target and max_field and maximum and maximum ~= 0 and target[max_field] == nil then
      target[max_field] = maximum
    end
    box.minimum_temperature = nil
    box.maximum_temperature = nil
    changed = true
  end

  local input_temperature_types = {
    ["generator"] = true,
    ["boiler"] = true,
    ["mining-drill"] = true,
    ["fusion-generator"] = true,
    ["fusion-reactor"] = true,
  }

  local min_field
  local max_field
  if input_temperature_types[prototype.type] then
    min_field = "minimum_input_temperature"
    max_field = "maximum_input_temperature"
  end

  if prototype.type == "thruster" then
    convert(prototype.fuel_fluid_box,prototype,"minimum_fuel_temperature","maximum_fuel_temperature")
    convert(prototype.oxidizer_fluid_box,prototype,"minimum_oxidizer_temperature","maximum_oxidizer_temperature")
  else
    convert(prototype.fluid_box,prototype,min_field,max_field)
    convert(prototype.input_fluid_box,prototype,min_field,max_field)
    convert(prototype.output_fluid_box,prototype)
  end

  if type(prototype.energy_source) == "table" then
    convert(prototype.energy_source.fluid_box,prototype.energy_source,"minimum_input_temperature","maximum_input_temperature")
    convert(prototype.energy_source.output_fluid_box,prototype.energy_source)
  end

  if type(prototype.fluid_boxes) == "table" then
    for _,entry in pairs(prototype.fluid_boxes) do
      if type(entry) == "table" then
        convert(entry.fluid_box)
        convert(entry)
      end
    end
  end

  return changed
end



--Run at beginning of every data cycle. Checks if commonly used global variables set by engine still exist. Used to enforce a certain level of code quality among all mods.
function Public.check_global_variables()
    if not helpers.compare_versions then
        error("Another mod has overridden the 'helpers' global variable. More info: https://lua-api.factorio.com/latest/classes/LuaHelpers.html")
    end

    --Searches for prototypes using obsolete fields and replaces them with newer equivalents. Used to preserve the functionality of unmaintained mods on newer versions.
    for _,item in pairs(data.raw["item"]) do
        if item.fuel_category then
            item.fuel_categories = item.fuel_categories or {}
            table.insert(item.fuel_categories,item.fuel_category)
            item.fuel_category = nil
            table.insert(PlanetsLib.constants.items_corrected_fuel_category,item.name)
            -- Paranoidal fork: no tooltip line (home items keep their descriptions before the rocket).
            fuel_category_warnings[item.name] = true
            log("Item " .. item.name .. " using unsupported field ItemPrototype::fuel_category has been corrected. This item should be manually fixed, as this field is no longer supported by Wube as of Factorio 2.1.20.")
        end
        --Some mods write fuel_category during data-final-fixes, after this check has run.
        --Intercept those late writes and convert them to fuel_categories as well.
        local mt = getmetatable(item)
        if type(mt) ~= "table" then
            mt = nil
        end
        if not (mt and mt.PlanetsLib_fuel_category_guard) then
            local warned = fuel_category_warnings[item.name] == true
            local new_mt = mt or {}
            local old_newindex = new_mt.__newindex
            new_mt.PlanetsLib_fuel_category_guard = true
            new_mt.__newindex = function(t,k,v)
                if k == "fuel_category" then
                    local categories = rawget(t,"fuel_categories") or {}
                    local found = false
                    for _,category in ipairs(categories) do
                        if category == v then
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(categories,v)
                    end
                    rawset(t,"fuel_categories",categories)
                    if not warned then
                        warned = true
                        -- Paranoidal fork: no tooltip line (zzzparanoidal writes fuel_category on home items).
                        log("Item " .. tostring(t.name) .. " using unsupported field ItemPrototype::fuel_category has been corrected. This item should be manually fixed, as this field is no longer supported by Wube as of Factorio 2.1.20.")
                    end
                elseif old_newindex then
                    old_newindex(t,k,v)
                else
                    rawset(t,k,v)
                end
            end
            setmetatable(item,new_mt)
        end
    end
    for _,sound in pairs(data.raw["ambient-sound"]) do
        if sound.planet then
            if not sound.planets then
                sound.planets = {}
            end
            PlanetsLib.rro.soft_insert(sound.planets,sound.planet)
            log("Ambient sound " .. sound.name .. " using unsupported field AmbientSound::planet has been corrected. This sound should be manually fixed, as this field is no longer supported by Wube as of Factorio 2.1.13.")
            local planet = data.raw.planet[sound.planet]
            if planet then
                planet.localised_description = {"",planet.localised_description or "",{"tooltip.space-location-ambient-sounds-corrected"}}
            end
            sound.planet = nil
            
            
        end
    end
    for _,effect in pairs(data.raw["tile-effect"] or {}) do
        if effect.water and correct_water_textures(effect.water,effect.water.shader_variation) then
            effect.localised_description = {"",effect.localised_description or "",{"tooltip.tile-effect-water-textures-corrected"}}
            log("Tile effect " .. effect.name .. " using unsupported fields WaterTileEffectParameters::textures/texture_variations_* has been corrected. This tile effect should be manually fixed, as these fields are no longer supported by Wube as of Factorio 2.1.22.")
        end
    end
    for _,prototypes in pairs(data.raw) do
        if type(prototypes) == "table" then
            for _,prototype in pairs(prototypes) do
                if type(prototype) == "table" and correct_fluid_box_temperatures(prototype) then
                    -- Paranoidal fork: no tooltip line (home prototypes keep their descriptions before the rocket).
                    log("Prototype " .. tostring(prototype.name) .. " using unsupported fields FluidBox::minimum_temperature/maximum_temperature has been corrected. This prototype should be manually fixed, as these fields are no longer supported by Wube as of Factorio 2.1.22.")
                end
            end
        end
    end

    --Searches for techs containing duplicate research ingredients, and combines them together.
    for _,tech in pairs(data.raw["technology"]) do
        if tech.unit and tech.unit.ingredients then
            local ingredients = tech.unit.ingredients
            local new_ingredients = combine_science_packs(ingredients)
            if #ingredients ~= #new_ingredients then
                tech.unit.ingredients = new_ingredients
                tech.localised_description = {"",tech.localised_description or "",{"technology-description.technology-research-ingredients-corrected"}}
            end
            
        end
    end



end

return Public