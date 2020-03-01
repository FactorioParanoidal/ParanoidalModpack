--FUEL VALUES ANGELS CARBON

data.raw["item"]["coal-crushed"].fuel_value = "3.5MJ"
data.raw["item"]["solid-coke"].fuel_value = "4.5MJ"
data.raw["item"]["solid-carbon"].fuel_value = "5.5MJ"
data.raw["item"]["pellet-coke"].fuel_value = "19MJ"


data.raw["pump"]["pump"].hidden = true
data.raw["pump"]["bob-pump-2"].hidden = true
data.raw["pump"]["bob-pump-3"].hidden = true
data.raw["pump"]["bob-pump-4"].hidden = true

--bobmods.lib.recipe.replace_ingredient ("fast-underground-belt", "iron-gear-wheel", "steel-gear-wheel")

-- MODULES
--[[
  bobmods.lib.recipe.replace_ingredient("speed-module-3", "processing-unit", "standart-io")
  bobmods.lib.recipe.replace_ingredient("productivity-module-3", "processing-unit", "standart-io")
  bobmods.lib.recipe.replace_ingredient("effectivity-module-3", "processing-unit", "standart-io")
  
  bobmods.lib.recipe.replace_ingredient("speed-module-4", "processing-unit", "advanced-io")
  bobmods.lib.recipe.replace_ingredient("productivity-module-4", "processing-unit", "advanced-io")
  bobmods.lib.recipe.replace_ingredient("effectivity-module-4", "processing-unit", "advanced-io")

  bobmods.lib.recipe.replace_ingredient("speed-module-5", "processing-unit", "advanced-io")
  bobmods.lib.recipe.replace_ingredient("productivity-module-5", "processing-unit", "advanced-io")
  bobmods.lib.recipe.replace_ingredient("effectivity-module-5", "processing-unit", "advanced-io")

  bobmods.lib.recipe.replace_ingredient("speed-module-6", "processing-unit", "predictive-io")
  bobmods.lib.recipe.replace_ingredient("productivity-module-6", "processing-unit", "predictive-io")
  bobmods.lib.recipe.replace_ingredient("effectivity-module-6", "processing-unit", "predictive-io")

  bobmods.lib.recipe.replace_ingredient("speed-module-7", "processing-unit", "predictive-io")
  bobmods.lib.recipe.replace_ingredient("productivity-module-7", "processing-unit", "predictive-io")
  bobmods.lib.recipe.replace_ingredient("effectivity-module-7", "processing-unit", "predictive-io")  
 ]]
  

	
                -- missed circuits in modules
  
					-- see oberhaul prototypes 
  
				-- modules effects tweak
				
    --code from CoppermineBobModuleRebalancing
--[[				
for name, item in pairs(data.raw.module) do
    local subgroup = item.subgroup

    local level_string = item.name:match("%d+")
    local level = 1

    if level_string then
      level = tonumber(level_string)
    end

    if subgroup == "speed-module" then
      item.effect = {
        speed = {bonus = 0.1 * level},
        consumption = {bonus = 0.175 * level}
      }
    end

    if subgroup == "effectivity-module" then
      item.effect = {
        speed = {bonus = -0.04 * level},
        consumption = {bonus = -0.1 * level}
      }
    end

    if subgroup == "productivity-module" then
      item.effect = {
        productivity = {bonus = 0.05 * level},
        consumption = {bonus = 0.2 * level * level},
        pollution = {bonus = 0.15 * level},
        speed = {bonus = -0.1 * level}
      }
    end

    if subgroup == "raw-speed-module" then
      item.effect = {
        speed = {bonus = 0.1 * level},
        consumption = {bonus = 0.1 * level}
      }
    end

    if subgroup == "raw-productivity-module" then
      item.effect = {
        productivity = {bonus = 0.05 * level},
        consumption = {bonus = 0.1 * level * level},
        pollution = {bonus = 0.05 * level},
        speed = {bonus = -0.05 * level}
      }
    end

    --if subgroup == "god-module" then
    --  item.effect = {
    --    productivity = {bonus = 0.1 * level},
    --  }
    --end
  end
  ]]