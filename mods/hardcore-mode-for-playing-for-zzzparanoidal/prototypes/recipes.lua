require(
    "__make-moded-technology-tree-mods-protocol__.prototypes.copying-for-modes.copy-to-normal-expensive-mode-recipe-data"
)
local function copy_salvaged_recipe(name, new_name)
    local result = flib.copy_prototype(data.raw["recipe"][name], new_name)
    result.ingredients = {}
    result.result = new_name
    if result.normal then
        result.normal = nil
    end
    if result.expensive then
        result.expensive = nil
    end
    return result
end
local coal_bi_bio_farm_recipe = flib.copy_prototype(data.raw["recipe"]["bi-bio-farm"], "coal-bi-bio-farm")

local function fixBiBioFarmIngredients(ingredients)
    table.insert(
        ingredients,
        {
            type = "item",
            name = "stone-furnace",
            amount = 5
        }
    )
    _table.each(
        ingredients,
        function(ingredient)
            if ingredient.name == "bi-bio-greenhouse" then
                ingredient.name = "coal-bi-bio-greenhouse"
            end
            if ingredient.name == "glass" then
                ingredient.name = "iron-plate"
            end
        end
    )
end
fixBiBioFarmIngredients(coal_bi_bio_farm_recipe.normal.ingredients)
fixBiBioFarmIngredients(coal_bi_bio_farm_recipe.expensive.ingredients)

local function fixBiBioFarmResult(recipeData)
    recipeData.result = "coal-bi-bio-farm"
end

fixBiBioFarmResult(coal_bi_bio_farm_recipe.normal)
fixBiBioFarmResult(coal_bi_bio_farm_recipe.expensive)

local coal_bi_bio_greenhouse_recipe =
    flib.copy_prototype(data.raw["recipe"]["bi-bio-greenhouse"], "coal-bi-bio-greenhouse")

local function fixBiBioGreenHouseIngredients(ingredients)
    table.insert(
        ingredients,
        {
            type = "item",
            name = "stone-furnace",
            amount = 1
        }
    )
    _table.each(
        ingredients,
        function(ingredient)
            if ingredient.name == "small-lamp" then
                ingredient.name = "deadlock-copper-lamp"
            end
        end
    )
end

local function fixBiBioGreenHouseResult(recipeData)
    recipeData.result = "coal-bi-bio-greenhouse"
end

fixBiBioGreenHouseIngredients(coal_bi_bio_greenhouse_recipe.normal.ingredients)
fixBiBioGreenHouseIngredients(coal_bi_bio_greenhouse_recipe.expensive.ingredients)
fixBiBioGreenHouseResult(coal_bi_bio_greenhouse_recipe.normal)
fixBiBioGreenHouseResult(coal_bi_bio_greenhouse_recipe.expensive)

-- скопипащенные рецепты.
data:extend(
    {
        coal_bi_bio_farm_recipe,
        coal_bi_bio_greenhouse_recipe
    }
)

local salvaged_offshore_pump_0_recipe
if mods["P-U-M-P-S"] then
    salvaged_offshore_pump_0_recipe = copy_salvaged_recipe("offshore-pump-0", "salvaged-offshore-pump-0")
else
    salvaged_offshore_pump_0_recipe = copy_salvaged_recipe("offshore-pump", "salvaged-offshore-pump-0")
end
salvaged_offshore_pump_0_recipe.ingredients = {
    {
        type = "item",
        name = "wood",
        amount = 40
    },
    {
        type = "item",
        name = "salvaged-iron-gear-wheel",
        amount = 8
    },
    {
        type = "item",
        name = "bi-wood-pipe",
        amount = 3
    }
}

data.raw["recipe"]["bi-wood-pipe"]["normal"].ingredients = { { "wood", 12 } }
data.raw["recipe"]["bi-wood-pipe"]["expensive"].ingredients = { { "wood", 16 } }
data.raw["recipe"]["bi-wood-pipe-to-ground"]["normal"].ingredients = { { "wood", 16 }, { "bi-wood-pipe", 5 } }
data.raw["recipe"]["bi-wood-pipe-to-ground"]["expensive"].ingredients = { { "wood", 20 }, { "bi-wood-pipe", 6 } }
local salvaged_ore_crusher_recipe = copy_salvaged_recipe("burner-ore-crusher", "salvaged-ore-crusher")
salvaged_ore_crusher_recipe.ingredients = {
    {
        type = "item",
        name = "wood",
        amount = 120
    },
    {
        type = "item",
        name = "salvaged-iron-gear-wheel",
        amount = 16
    },
    {
        type = "item",
        name = "salvaged-mining-drill-bit-mk0",
        amount = 4
    },
    -- для жидкостей
    {
        type = "item",
        name = "bi-wood-pipe",
        amount = 6
    }
}
local salvaged_mining_drill_bit_mk0_recipe =
    copy_salvaged_recipe("mining-drill-bit-mk0", "salvaged-mining-drill-bit-mk0")
local basic_coal_production_wood_recipe = {
    type = "recipe",
    name = "basic-coal-production-wood",
    icons = {
        {
            icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/seedling.png",
            icon_size = 64,
            icon_mipmaps = 4
        },
        {
            icon = "__base__/graphics/icons/fluid/water.png",
            icon_size = 64,
            icon_mipmaps = 4,
            scale = 0.25,
            shift = { -8, 8 }
        },
        {
            icon = "__base__/graphics/icons/coal.png",
            icon_size = 64,
            icon_mipmaps = 4,
            scale = 0.25,
            shift = { 0, 8 }
        }
    },
    ingredients = {
        {
            type = "fluid",
            name = "water",
            amount = 100
        },
        {
            type = "item",
            name = "coal-seedling",
            amount = 4
        },
        {
            type = "item",
            name = "coal",
            amount = 2
        }
    },
    results = {
        {
            type = "item",
            name = "wood",
            amount = 9
        },
        {
            type = "item",
            name = "coal-tree-seed",
            amount = 16
        }
    },
    category = "biofarm-mod-farm",
    subgroup = "bio-bio-farm-fluid-3",
    energy_required = 10,
    enabled = false
}
local basic_coal_production_seedling_recipe = {
    type = "recipe",
    name = "basic-coal-production-seedling",
    icons = {
        {
            icon = "__zzzparanoidal__/graphics/Bio_Industries_graphics/graphics/icons/tree_seed.png",
            icon_size = 64,
            icon_mipmaps = 4
        },
        {
            icon = "__base__/graphics/icons/fluid/water.png",
            icon_size = 64,
            icon_mipmaps = 4,
            scale = 0.25,
            shift = { -8, 8 }
        },
        {
            icon = "__base__/graphics/icons/coal.png",
            icon_size = 64,
            icon_mipmaps = 4,
            scale = 0.25,
            shift = { 0, 8 }
        }
    },
    ingredients = {
        {
            type = "fluid",
            name = "water",
            amount = 100
        },
        {
            type = "item",
            name = "coal-tree-seed",
            amount = 4
        },
        {
            type = "item",
            name = "coal",
            amount = 2
        }
    },
    results = {
        {
            type = "item",
            name = "coal-seedling",
            amount = 1
        }
    },
    subgroup = "bio-bio-farm-fluid-1",
    category = "biofarm-mod-greenhouse",
    energy_required = 25,
    enabled = false
}
data:extend(
    {
        salvaged_mining_drill_bit_mk0_recipe,
        salvaged_offshore_pump_0_recipe,
        salvaged_ore_crusher_recipe,
        basic_coal_production_wood_recipe,
        basic_coal_production_seedling_recipe
    }
)


local salvaged_mining_drill_recipe = data.raw["recipe"]["salvaged-mining-drill"]
local salvaged_mining_drill_recipe_ingredients = {
    {
        type = "item",
        name = "salvaged-mining-drill-bit-mk0",
        amount = 2
    },
    -- для жидкостей
    {
        type = "item",
        name = "bi-wood-pipe",
        amount = 6
    }
}
salvaged_mining_drill_recipe.ingredients = salvaged_mining_drill_recipe_ingredients
_table.each(
    GAME_MODES,
    function(mode)
        merge_recipe_for_modes(salvaged_offshore_pump_0_recipe, mode)
        merge_recipe_for_modes(salvaged_ore_crusher_recipe, mode)
        merge_recipe_for_modes(salvaged_mining_drill_bit_mk0_recipe, mode)
        merge_recipe_for_modes(basic_coal_production_wood_recipe, mode)
        merge_recipe_for_modes(basic_coal_production_seedling_recipe, mode)
        merge_recipe_for_modes(salvaged_mining_drill_recipe, mode)
    end
)
-- рецепты, которые описывают использование предметов в машинах или реакторах
local riteg1_to_used_up_riteg1_recipe_data = {
    enabled = false,
    energy_required = 30,
    ingredients = {
        { "RITEG-1", 1 }
    },
    result = "used-up-RITEG-1"
}

data:extend(
    {
        {
            normal = riteg1_to_used_up_riteg1_recipe_data,
            expensive = riteg1_to_used_up_riteg1_recipe_data,
            icons = {
                { icon = "__RITEG__/graphics/icons/RITEG-1.png" },
                { icon = "__RITEG__/graphics/icons/recycling.png", scale = 0.5, shift = { 8, 8 } }
            },
            icon_size = 32,
            name = "used-up-RITEG-1",
            type = "recipe"
        }
    }
)
--конец рецепты, которые описывают использование предметов в машинах или реакторах
-- возвращаем дешёвый вариант производства припоя.
local angels_solder_mixture_smelting_recipe = data.raw["recipe"]["angels-solder-mixture-smelting"]
if angels_solder_mixture_smelting_recipe then
    local angels_solder_mixture_smelting_recipe_results = { { type = "item", name = "solder", amount = 2 } }
    --
    angels_solder_mixture_smelting_recipe.normal.results = angels_solder_mixture_smelting_recipe_results
    angels_solder_mixture_smelting_recipe.expensive.results = angels_solder_mixture_smelting_recipe_results
end
