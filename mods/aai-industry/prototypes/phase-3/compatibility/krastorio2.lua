local data_util = require("data-util")

function convert_prereqs(old_prereq, new_prereq)
  for tech, proto in pairs(data.raw.technology) do
    if proto.prerequisites and data_util.table_contains(proto.prerequisites, old_prereq) then
      data_util.tech_remove_prerequisites(tech, {old_prereq})
      data_util.tech_add_prerequisites(tech, {new_prereq})
    end
  end
end

function merge_ingredients(recipe)
  if not data.raw.recipe[recipe] then return end
  if not data.raw.recipe[recipe].ingredients then return end
  deduplicated_ingredients = {}
  for _, ingredient in pairs(data.raw.recipe[recipe].ingredients) do
    if deduplicated_ingredients[ingredient.name] then
      deduplicated_ingredients[ingredient.name].amount = deduplicated_ingredients[ingredient.name].amount + ingredient.amount
    else
      deduplicated_ingredients[ingredient.name] = ingredient
    end
  end

  data.raw.recipe[recipe].ingredients = {}
  for _, ingredient in pairs(deduplicated_ingredients) do
    table.insert(data.raw.recipe[recipe].ingredients, ingredient)
  end
end

if mods["Krastorio2"] then
  data.raw.technology["basic-logistics"].prerequisites = {}
  data.raw.recipe["automation-science-pack"].category = "basic-crafting"
  data.raw.recipe["kr-blank-tech-card"].category = "basic-crafting"

  merge_ingredients("repair-pack")
  data_util.replace_or_add_ingredient("repair-pack","iron-plate","iron-plate",3)
  data_util.replace_or_add_ingredient("repair-pack","copper-plate","copper-plate",3)

  merge_ingredients("solar-panel")
  data_util.replace_or_add_ingredient("solar-panel", aai_glass_name, aai_glass_name, 10)

  -- Technology Prereq Conversion
  -- Sand
  convert_prereqs("sand-processing", "kr-stone-processing")
  data.raw.technology["sand-processing"] = nil
  -- Glass
  convert_prereqs("glass-processing", "kr-stone-processing")
  data.raw.technology["glass-processing"] = nil

  -- Tech kr-laboratory should go.
  if data.raw.technology["kr-laboratory"] then
    data.raw.technology["kr-laboratory"] = nil
  end

  -- Fuel prerequisite
  if settings["startup"]["aai-fuel-processor"].value then
    data_util.tech_add_prerequisites("kr-fuel", {"fuel-processing"})
  end

  -- AAI Industry locks this behind electricity, but K2 needs it for the Basic Tech Card.
  data_util.enable_recipe("copper-cable")
  data_util.enable_recipe("sand")

  data_util.tech_remove_ingredients("basic-automation", {"automation-science-pack"})
  data_util.tech_remove_prerequisites("basic-automation", {"automation-science-pack"})
  data_util.tech_remove_prerequisites("basic-automation", {"electricity"})
  data_util.remove_ingredient("assembling-machine-1", "iron-plate")
  data_util.replace_or_add_ingredient("assembling-machine-1", "kr-iron-beam", "kr-iron-beam", 3)
  data_util.replace_or_add_ingredient("assembling-machine-1", "iron-gear-wheel", "iron-gear-wheel", 3)

  data_util.tech_add_prerequisites("basic-automation", {"kr-automation-core"})
  data_util.tech_add_prerequisites("kr-basic-fluid-handling", {"electricity"})
  
  -- -- -- Recipes fixes
  data_util.replace_or_add_ingredient("burner-assembling-machine", "motor", "kr-automation-core", 2)

  data_util.replace_or_add_ingredient("electric-mining-drill", "iron-gear-wheel", "iron-gear-wheel", 3)
  data_util.replace_or_add_ingredient("electric-mining-drill", "electric-motor", "electric-motor", 3)

  data_util.remove_ingredient("burner-inserter", "kr-automation-core")

  -- -- -- Entities fixes
  data.raw["lab"]["burner-lab"].inputs = { "kr-basic-tech-card", "automation-science-pack" }

  data_util.tech_remove_prerequisites("automation", {"electronics"})
  data_util.tech_add_prerequisites("automation-2", {"automation"})

  data_util.remove_recipes_from_technologies({"inserter"})
  data_util.tech_lock_recipes("logistics", {"inserter"})

  data_util.tech_add_prerequisites("automation-science-pack", "kr-automation-core")
  data_util.tech_add_prerequisites("kr-automation-core", "burner-mechanics")
  data_util.tech_remove_prerequisites("automation-science-pack", {"automation","kr-laboratory", "burner-mechanics"})

  data_util.tech_remove_prerequisites("steam-power", {"fluid-handling"})
  data_util.tech_add_prerequisites("steam-power", {"basic-fluid-handling"})

  -- balance electronic circuit recipes
  data_util.remove_ingredient("electronic-circuit", "iron-plate")
  data_util.remove_ingredient("electronic-circuit", "wood")
  data_util.replace_or_add_ingredient("electronic-circuit", "copper-cable", "copper-cable", 3)
  data_util.recipe_set_time("electronic-circuit", data.raw.recipe["electronic-circuit-wood"].energy_required)
  data_util.recipe_set_result_count("electronic-circuit", 1)
  
  data_util.replace_or_add_ingredient("electronic-circuit-wood", "wood", "wood", 3)

  -- Krastorio2 alters the icon for the electronic circuit, so we adjust the icon here to catch this update.
  data_util.sub_icons(
    data.raw.item["electronic-circuit"].icon,
    data.raw.item["wood"].icon
  )

  -- fix fuel categories
  data_util.add_fuel_category(data.raw["burner-generator"]["burner-turbine"].burner, "kr-vehicle-fuel")
  data_util.add_fuel_category(data.raw["assembling-machine"]["burner-assembling-machine"].energy_source, "kr-vehicle-fuel")
  data_util.add_fuel_category(data.raw["lab"]["burner-lab"].energy_source, "kr-vehicle-fuel")

  local fuel = data.raw.item["processed-fuel"]
  if fuel then
    fuel.fuel_acceleration_multiplier = 1.2
    fuel.fuel_top_speed_multiplier = 1.05
    fuel.fuel_category = "kr-vehicle-fuel"
  end

  -- Compensate for the processed fuel exploit. Alternative could be to reduce wood flue value.
  -- 40 * 2MJ * 1.1 = in 60s. = 1466 kW
  -- 20 * 2MJ * 1.1 = in 120s. = 366 kW
  -- can get even more energy value with coke recipe.
  -- changes make player choose between energy production at the cost of stone, or free wood but much larger footprint.
  local sand_wood = table.deepcopy(data.raw.recipe["wood"])
  sand_wood.name = "kr-grow-wood-with-sand"
  data:extend({sand_wood})
  data_util.replace_or_add_ingredient("kr-grow-wood-with-sand", aai_sand_name, aai_sand_name, 10)
  data_util.recipe_set_result_count("kr-grow-wood-with-sand", 40)
  data_util.recipe_set_time("kr-grow-wood-with-sand", 60)
  data_util.replace_or_add_ingredient("kr-grow-wood-with-sand", "water", "water", 200, true)
  data_util.tech_lock_recipes("kr-greenhouse", "kr-grow-wood-with-sand")

  data_util.recipe_set_result_count("wood", 20)
  data_util.recipe_set_time("wood", 120)
  data_util.replace_or_add_ingredient("wood", "water", "water", 800, true)

  data_util.recipe_set_result_count("kr-wood-with-fertilizer", 80)
  data_util.recipe_set_time("kr-wood-with-fertilizer", 60)
  data_util.replace_or_add_ingredient("kr-wood-with-fertilizer", "water", "water", 400, true)
  data_util.replace_or_add_ingredient("kr-wood-with-fertilizer", aai_sand_name, aai_sand_name, 5)

  data.raw["assembling-machine"]["kr-greenhouse"].energy_usage = "350kW" -- still positive energy but much slower.
  data_util.recipe_set_result_count("kr-fertilizer", 5)

  for i = 0, 9 do
    data_util.recipe_set_result_count("tree-0"..i, 1)
  end

  -- Strike a balance between AAI and K2 choices about the advanced circuit plastic costs
  data_util.replace_or_add_ingredient("kr-electronic-components", "plastic-bar", "plastic-bar", 4)

  -- Strike a balance between AAI and K2 choices about the engine unit recipe
  data_util.tech_add_prerequisites("engine", {"steel-processing"})
  data_util.replace_or_add_ingredient("engine-unit", "iron-plate", "steel-plate", 1)

  data.raw.recipe["chemical-science-pack"].ingredients = {
    {type = "item", name = aai_glass_name, amount = 5},
    {type = "item", name = "engine-unit", amount = 1},
    {type = "item", name = "advanced-circuit", amount = 5},
    {type = "item", name = "kr-blank-tech-card", amount = 5},
    {type = "fluid", name = "sulfuric-acid", amount = 50}
  }
  data.raw.recipe["chemical-science-pack"].results = {
    {type = "item", name = "chemical-science-pack", amount = 5}
  }

  -- need to use assembler (makes burner assembler required to be used at least once)
  local recipes = {"kr-blank-tech-card", "kr-biters-research-data", "kr-matter-research-data", "kr-matter-research-data", "kr-space-research-data",
    "automation-science-pack", "logistic-science-pack", "military-science-pack", "chemical-science-pack", "production-science-pack", "utility-science-pack"}
  for _, recipe_name in pairs(recipes) do
    local recipe = data.raw.recipe[recipe_name]
    if recipe then
      if recipe.category == "crafting" or recipe.category == nil then
        recipe.category = "basic-crafting"
      end
      recipe.always_show_made_in = true
    end
  end

  data_util.techs_add_ingredients({"kr-basic-fluid-handling", "kr-steam-engine", "automation"}, {"automation-science-pack"}, false)
  data_util.tech_remove_ingredients("gun-turret", {"automation-science-pack"})
  data_util.tech_remove_prerequisites ("gun-turret", {"automation-science-pack"})

  -- 3 way compatibility fix with AAI, K2, and Bob's Logistics
  if mods["boblogistics"] then
    data_util.tech_lock_recipes(
      "kr-basic-fluid-handling",
      {
        "bob-valve",
        "copper-pipe",
        "copper-pipe-to-ground",
        "stone-pipe",
        "stone-pipe-to-ground"
      })
  end

end
