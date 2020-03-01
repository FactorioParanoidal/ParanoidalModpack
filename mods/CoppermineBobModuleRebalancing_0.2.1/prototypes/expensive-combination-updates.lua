if settings.startup["coppermine-bob-module-expensive-module-combination"].value then
  -- Insert our own items into module recipes

  for product, recipe in pairs(data.raw.recipe) do
    local match_start, match_end = product:find("-module")

    if match_start then
      local product_type = product:sub(1, match_end)
      local level = tonumber(product:sub(match_end + 2))
      local is_upgrade = false
      local initial = false
      local has_module_input = false
      local num_processors = 0

      for i, ingredient in pairs(recipe.ingredients) do
        local item = bobmods.lib.item.basic_item(ingredient)
        if item.name == "module-circuit-board" then
          initial = true
        end

        match_start, match_end = item.name:find("-module")

        if match_start then
          has_module_input = true

          local ingredient_type = item.name:sub(1, match_end)

          -- When the types match it means this is a straight upgrade recipe
          if product_type == ingredient_type then
            is_upgrade = true
          end
        end

        match_start, match_end = item.name:find("-processor")

        if match_start then
          num_processors = num_processors + 1
        end
      end

      -- First god modules, which are special
      if product_type == "god-module" then
        if level == nil then
          error("Module name '"..product..
            "' does not match the expected form of Bob's module names")
        end

        local dep_level = level + 3
        bobmods.lib.recipe.remove_ingredient(product, "speed-processor")
        bobmods.lib.recipe.remove_ingredient(product, "productivity-processor")
        bobmods.lib.recipe.remove_ingredient(product, "effectivity-processor")
        bobmods.lib.recipe.remove_ingredient(product, "pollution-clean-processor")
        bobmods.lib.recipe.remove_ingredient(product, "speed-processor-2")
        bobmods.lib.recipe.remove_ingredient(product, "productivity-processor-2")
        bobmods.lib.recipe.remove_ingredient(product, "effectivity-processor-2")
        bobmods.lib.recipe.remove_ingredient(product, "pollution-clean-processor-2")
        bobmods.lib.recipe.remove_ingredient(product, "speed-processor-3")
        bobmods.lib.recipe.remove_ingredient(product, "productivity-processor-3")
        bobmods.lib.recipe.remove_ingredient(product, "effectivity-processor-3")
        bobmods.lib.recipe.remove_ingredient(product, "pollution-clean-processor-3")
        bobmods.lib.recipe.add_ingredient(product, {"raw-speed-module-"..dep_level, 2})
        bobmods.lib.recipe.add_ingredient(product, {"raw-productivity-module-"..dep_level, 2})
        bobmods.lib.recipe.add_ingredient(product, {"green-module-"..dep_level, 4})
        bobmods.lib.recipe.replace_ingredient(product, "solder", "module-combining-solder")
        bobmods.lib.recipe.replace_ingredient(product, "module-case", "module-combining-case")
      -- Next deal with the combination recipes
      elseif not is_upgrade and not initial and has_module_input then
        bobmods.lib.recipe.add_ingredient(product, {"module-combining-case", 1})
        bobmods.lib.recipe.replace_ingredient(product, "solder", "module-combining-solder")
      -- Finally, upgrade recipes of combined modules
      elseif num_processors > 1 and (initial or has_module_input) then
        bobmods.lib.recipe.replace_ingredient(product, "module-case", "module-combining-case")
        bobmods.lib.recipe.replace_ingredient(product, "solder", "module-combining-solder")
      end
    end
  end

  -- Allow module lab to take module combining case as science ingredient
  table.insert(data.raw.lab["lab-module"].inputs, "module-combining-case")

  -- Replace tech requirement for combined module tech
  for tech_name, tech in pairs(data.raw.technology) do
    local match_start, match_end = tech_name:find("-module")

    if match_start then
      local module_type = tech_name:sub(1, match_end)

      if module_type == "raw-speed-module" or module_type == "raw-productivity-module" or
          module_type == "green-module" or module_type == "god-module" then
        bobmods.lib.tech.replace_science_pack(tech_name, "module-case", "module-combining-case")
      end
    end
  end

  -- Make our own items more expensive when other items are available
  if data.raw.item["alien-blue-alloy"] then
    bobmods.lib.recipe.replace_ingredient(
      "module-combining-solder", "cobalt-steel-alloy", "alien-blue-alloy")
    bobmods.lib.tech.add_prerequisite("module-merging", "alien-blue-research")
  end

  bobmods.lib.tech.add_prerequisite(
    "module-merging", "tungsten-alloy-processing")
  bobmods.lib.tech.add_prerequisite("module-merging", "zinc-processing")
  bobmods.lib.tech.add_prerequisite("module-merging", "advanced-electronics-3")

  -- Update god module tech prerequisites to match crafting requirements
  if data.raw.technology["god-module-1"] then
    for level=1,5 do
      local this_tech = "god-module-"..level
      local dep_level = level + 3
      bobmods.lib.tech.add_prerequisite(this_tech, "raw-speed-module-"..dep_level)
      bobmods.lib.tech.add_prerequisite(this_tech, "raw-productivity-module-"..dep_level)
      bobmods.lib.tech.add_prerequisite(this_tech, "green-module-"..dep_level)
    end
  end
end
