-- Ненужные рецепты скрываем

data.raw.recipe["slag-processing-yi"].enabled = false
data.raw.recipe["slag-processing-yi"].hidden = true

data.raw.recipe["y-crusher-recipe"].enabled = false
data.raw.recipe["y-crusher-recipe"].hidden = true

data.raw.recipe["y-heat-form-press-recipe"].enabled = false
data.raw.recipe["y-heat-form-press-recipe"].hidden = true

data.raw.recipe["y-ac-copper2uc-recipe"].hidden = true
data.raw.recipe["y-ac-iron2uc-recipe"].hidden = true
data.raw.recipe["y-ac-wood2uc-recipe"].hidden = true
data.raw.recipe["y-ac-coal2uc-recipe"].hidden = true
data.raw.recipe["y-ac-stone2uc-recipe"].hidden = true
data.raw.recipe["y-ac-iron2uc-recipe"].hidden = true


-- Ненужные технологии скрываем

data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-advanced-inserters"].hidden = true
data.raw.technology["yi-basic-transport"].hidden = true
data.raw.technology["yi-advanced-transport"].hidden = true
data.raw.technology["yi-lights"].hidden = true
data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-inserters"].hidden = true
data.raw.technology["yi-inserters"].hidden = true

-- Ненужные вещи из рецептов удаляем

-- bobmods.lib.recipe.remove_result("Recipename", "Itemname")
-- bobmods.lib.recipe.remove_ingredient ("Recipename", "itemname")
-- bobmods.lib.recipe.add_new_ingredient ("Recipename", {type="item", name="Itemname", amount=2})
-- table.insert( data.raw["recipe"]["Recipename"].ingredients, {"Itemname", 14})

bobmods.lib.recipe.remove_result ("angels-ore1-chunk", "y-res1")
bobmods.lib.recipe.remove_result ("angels-ore3-chunk", "y-res2")
bobmods.lib.recipe.remove_result ("angels-ore1-crystal", "y-res1")
bobmods.lib.recipe.remove_result ("angels-ore3-crystal", "y-res2")
bobmods.lib.recipe.remove_result ("angels-ore1-pure", "y-res1")
bobmods.lib.recipe.remove_result ("angels-ore3-pure", "y-res2")





-- заменяем ингриды и результат у рецептов
--Уникомпозит
data.raw.recipe["angelsore-chunk-mix-yi1-processing"].category = "ore-sorting-4"
data.raw.recipe["angelsore-chunk-mix-yi1-processing"].ingredients = {
          {type = "item", name = "angels-ore1-pure", amount = 4},
          {type = "item", name = "angels-ore3-pure", amount = 4},
          {type = "item", name = "angels-ore5-pure", amount = 4},
          {type = "item", name = "solid-sodium", amount = 20},
        }
		
data.raw.recipe["angelsore-chunk-mix-yi1-processing"].results = {
          {type = "item", name = "y-res1", amount = 1}
        }
--Энергоминерал
data.raw.recipe["angelsore-chunk-mix-yi2-processing"].category = "ore-sorting-4"
data.raw.recipe["angelsore-chunk-mix-yi2-processing"].ingredients = {
          {type = "item", name = "angels-ore2-pure", amount = 4},
          {type = "item", name = "angels-ore4-pure", amount = 4},
          {type = "item", name = "angels-ore6-pure", amount = 4},
          {type = "item", name = "solid-white-phosphorus", amount = 20},
        }
		
data.raw.recipe["angelsore-chunk-mix-yi2-processing"].results = {
          {type = "item", name = "y-res2", amount = 1}
        }
		
data.raw.recipe["y-c22-recipe"].ingredients = {
          {type = "item", name = "angels-ore2-pure", amount = 4},
          {type = "item", name = "angels-ore4-pure", amount = 4},
          {type = "item", name = "angels-ore6-pure", amount = 4},
          {type = "item", name = "solid-white-phosphorus", amount = 20},
		
      --  icons = {          {icon = "__angelsrefining__/graphics/icons/sort-icon.png", icon_size = 32},
      --    {icon = "__Yuoki__/graphics/icons/yi-res-2-pur.png", icon_size = 32, scale = 0.5, shift = {10, 10}},        },
	  

--[[
	  
      {
        type = "recipe",
        name = "yellow-waste-water-purification-yi",
        category = "water-treatment",
        subgroup = "water-treatment",
        energy_required = 1,
        enabled = false,
        ingredients = {
          {type = "fluid", name = "water-yellow-waste", amount = 100}
        },
        results = {
          {type = "fluid", name = "y-con_water", amount = 20},
          {type = "fluid", name = "water-purified", amount = 70},
          {type = "item", name = "sulfur", amount = 1}
        },
        icons = angelsmods.functions.create_liquid_recipe_icon(
          {
            "y-con_water",
            "water-purified",
            mods["angelspetrochem"] and {"__angelspetrochem__/graphics/icons/solid-sulfur.png", 32} or "sulfur"
          },
          "wss"
        ),--
        order = "a[yellow-waste-water-purification-yi]"
      }
	  })
]]--	  





--[[
	{ type = "recipe",
    name = "angelsore-chunk-mix-yi1-processing",
    category = "crafting",
  --category = "crafting-with-fluid",
	enabled = false,
	energy_required = 10,
    ingredients =
    {
          {type="item", name="thorium-232", amount=3, catalyst_amount=2},
          {type="item", name="plutonium-239", amount=1, catalyst_amount=1},
          {type="item", name="lead-plate", amount=5, catalyst_amount=5},

          {type="item", name="plutonium-239", amount=1, probability=0.1},
		--{type="fluid", name = "liquid-sulfuric-acid", amount = 10},
    },
    results =
    {
      {"plutonium-239", 41},
      {"uranium-238", 2}
    },
	result_count = 1
  },
]]--


		






