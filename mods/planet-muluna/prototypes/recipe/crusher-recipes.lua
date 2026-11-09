local rro = Muluna.rro
local dual_icon = require("lib.dual-item-icon").dual_icon
local dual_icon_reversed = require("lib.dual-item-icon").dual_icon_reversed

local function crushing_icon(icon_dir,icon_size)
return {
    {
        icon = icon_dir,
        icon_size=64,
        --scale=0.3,
        shift = {0,-3},
        scale=50/128,
        draw_background = true
    },
    {
        icon = "__muluna-graphics__/graphics/icons/generic-crushing.png",
        icon_size=64,
        scale=0.5,
        draw_background = true
    },
}

end

local function advanced_crushing_icon(icon_dir,product_1,product_2)
    return {
        {
            icon = product_1,
            icon_size=64,
            scale = 0.25,
            shift = {-8,8},
            draw_background = true
        },
        {
            icon = product_1,
            icon_size=64,
            scale = 0.25,
            shift = {8,-8},
            draw_background = true
        },
        {
            icon = product_2,
            icon_size=64,
            scale = 0.25,
            shift = {-8,-8},
            draw_background = true
        },
        {
            icon = product_2,
            icon_size=64,
            scale = 0.25,
            shift = {8,8},
            draw_background = true
        },
        {
            icon = icon_dir,
            icon_size=64,
            scale=0.4,
            -- shift = {0,-3},
            --scale = 0.5,
            --scale=50/128,
            draw_background = true
        },
        
        -- {
        --     icon = "__muluna-graphics__/graphics/icons/generic-crushing.png",
        --     icon_size=64,
        --     scale=0.5,
        --     draw_background = true
        -- },
    }

end
-- New icons

table.insert(data.raw["character"]["character"].crafting_categories,
data.raw["recipe"]["oxide-asteroid-crushing"].categories[1]  

)
if mods["crushing-industry"] then
    table.insert(data.raw["character"]["character"].crafting_categories,
        "basic-crushing"
    )
end

local anorthite_crushing = table.deepcopy(data.raw["recipe"]["oxide-asteroid-crushing"])
anorthite_crushing.name = "anorthite-crushing"


anorthite_crushing.icons = {
{
    icon = "__muluna-graphics__/graphics/icons/anorthite-chunk.png",
    icon_size=64,
    --scale=0.3,
    shift = {0,-3},
    scale=50/128,
    draw_background = true
},
{
    icon = "__muluna-graphics__/graphics/icons/asteroid-crushing.png",
    icon_size=64,
    scale=0.5,
    draw_background = true
},

}
anorthite_crushing.order="b-a-d"
anorthite_crushing.results = {{type = "item",name = "alumina",amount = 20},{type = "item", name = "anorthite-chunk", amount = 1, independent_probability = 0.3,ignored_by_productivity = 1}}
anorthite_crushing.ingredients = {{type = "item",name = "anorthite-chunk",amount = 1,ignored_by_productivity = 1}}

-- anorthite_crushing.surface_conditions={
--     PlanetsLib.surface_conditions.restrict_to_surface("muluna")
-- }


local advanced_anorthite_crushing = Muluna.rro.util_merge{table.deepcopy(anorthite_crushing),

{
    name = "advanced-anorthite-crushing",
    order = "g[advanced-anorthite-crushing]",
    icons = advanced_crushing_icon(
        "__muluna-graphics__/graphics/icons/anorthite-chunk.png",
        data.raw["item"]["alumina"].icon,
        data.raw["item"]["silicon"].icon
    ),
}


}

advanced_anorthite_crushing.results = {{type = "item",name = "alumina",amount = 10},{type = "item",name = "silicon",amount = 4},{type = "item", name = "anorthite-chunk", amount = 1, independent_probability = 0.1,ignored_by_productivity=1}}
advanced_anorthite_crushing.hide_from_signal_gui = false

Muluna:extend{advanced_anorthite_crushing}



local alumina_crushing=table.deepcopy(anorthite_crushing)
alumina_crushing.icons = crushing_icon(data.raw["item"]["alumina"].icon,64)
alumina_crushing.name="alumina-crushing"
alumina_crushing.results = {{type = "item", name = "alumina", amount = 1,ignored_by_productivity=1, independent_probability = 1/20 },{type = "item",name = "alumina-crushed",amount = 2}}
alumina_crushing.ingredients = {{type = "item",name = "alumina",amount = 1}}
alumina_crushing.energy_required = 1
alumina_crushing.order="b-aa-a"
alumina_crushing.rigor_sensitivity=mods["rigor-module"] and 0.5 or nil

local aluminum_crushing=table.deepcopy(anorthite_crushing)
aluminum_crushing.icons = crushing_icon("__muluna-graphics__/graphics/icons/metal-plate-aluminium.png",64)
aluminum_crushing.name="aluminum-crushing"
aluminum_crushing.results = {{type = "item", name = "aluminum-plate", amount = 1,ignored_by_productivity=1, independent_probability = 1/20 },{type = "item",name = "aluminum-crushed",amount = 2}}
aluminum_crushing.ingredients = {{type = "item",name = "aluminum-plate",amount = 1}}
aluminum_crushing.energy_required = 1
aluminum_crushing.order="b-aa-b"
aluminum_crushing.rigor_sensitivity=mods["rigor-module"] and 0.5 or nil

local stone_crushing=table.deepcopy(anorthite_crushing)

stone_crushing.results = {{type = "item", name = "stone", amount = 1,ignored_by_productivity=1, independent_probability = 1/10},{type = "item",name = "muluna-breccia",amount = 3}}
stone_crushing.ingredients = {{type = "item",name = "stone",amount = 2}}
stone_crushing.name="stone-crushing"
stone_crushing.energy_required=1
stone_crushing.order="b-aa-c"
stone_crushing.icons = crushing_icon(data.raw.item["stone"].icon,data.raw.item["stone"].icon_size)
stone_crushing.rigor_sensitivity=mods["rigor-module"] and 1 or nil


local aluminum_plate = table.deepcopy(data.raw["recipe"]["iron-plate"])
aluminum_plate.ingredients = {{type = "item",name = "alumina",amount = 1}}
aluminum_plate.results = {{type = "item",name = "aluminum-plate",amount = 1}}
aluminum_plate.name = "aluminum-plate"
aluminum_plate.enabled = false

local aluminum_cable = table.deepcopy(data.raw["recipe"]["copper-cable"])

aluminum_cable.name = "aluminum-cable"
aluminum_cable.ingredients = {{type = "item",name = "aluminum-plate",amount = 1}}
aluminum_cable.auto_recycle = false

aluminum_cable.localised_name = {"item-name.aluminum-cable"}
aluminum_cable.icons = dual_icon("copper-cable","aluminum-plate")
aluminum_cable.subgroup="muluna-products"
aluminum_cable.allow_decomposition = false
aluminum_cable.allow_as_intermediate = false
aluminum_cable.hide_from_signal_gui = false
--aluminum_cable.results = {{type = "item",name = "aluminum-cable",amount = 2}}

-- table.insert(data.raw["technology"]["asteroid-productivity"].effects, {
--     effect = "enable-recipe",
--     recipe = ""
-- })


local wood_crushing = table.deepcopy(anorthite_crushing)
wood_crushing.name = "woodchips"
--wood_crushing.ingredients = {{type = "item",name = "wood",amount = 6}}
--wood_crushing.results = {{type = "item",name = "woodchips",amount = 10},{type = "item", name = "wood", amount = 1,ignored_by_productivity=1}}

wood_crushing.results = {{type = "item", name = "wood", amount = 1,ignored_by_productivity=1, independent_probability = 1/20 },{type = "item",name = "woodchips",amount = 2}}
wood_crushing.ingredients = {{type = "item",name = "wood",amount = 1}}
wood_crushing.energy_required = 0.5
wood_crushing.rigor_sensitivity=mods["rigor-module"] and 0.5 or nil

if mods["Age-of-Production"] then
    rro.soft_insert(wood_crushing.categories ,"woodworking")
end

wood_crushing.icons=crushing_icon(data.raw.item["wood"].icon,data.raw.item["wood"].icon_size)
wood_crushing.order="b-aa-c"

local tree_crushing = table.deepcopy(wood_crushing)

tree_crushing.name = "muluna-tree-crushing"

tree_crushing.results = {{type = "item", name = "muluna-sapling", amount = 1,ignored_by_productivity=1, independent_probability = 1/20 },{type = "item",name = "wood",amount = 4}}
tree_crushing.ingredients = {{type = "item",name = "muluna-sapling",amount = 1}}
tree_crushing.icons=crushing_icon(data.raw.item["muluna-sapling"].icon,data.raw.item["muluna-sapling"].icon_size)
tree_crushing.order="b-aa-b"
tree_crushing.rigor_sensitivity=mods["rigor-module"] and 0.5 or nil


local regolith_sorting = {
    type = "recipe",
    name = "muluna-regolith-sorting",
    group = "space",
    subgroup = "space-crushing",
    categories = data.raw["recipe"]["oxide-asteroid-crushing"].categories,
    order = "h[muluna-regolith-sorting]",
    --categories = {"recycling"},
    auto_recycle = false,
    allow_decomposition = false,
    allow_as_intermediate = false,
    enabled = false,
    ingredients = {
        {
            type = "item",
            name = "muluna-lunar-regolith",
            amount = 1,
        }
    },
    energy_required = 1,
    results = {
        {
            type = "item",
            name = "stone",
            amount = 1,
            --independent_probability = 0.50,
        },
        {
            type = "item",
            name = "muluna-breccia",
            amount = 1,
            --independent_probability = 0.50,
        },
        {
            type = "item",
            name = "uranium-ore",
            amount = 1,
            independent_probability = 0.01,
        }


    },
    icons = crushing_icon(data.raw.item["muluna-lunar-regolith"].icon,data.raw.item["muluna-lunar-regolith"].icon_size)
}

if settings.startup["muluna-hardcore-classic-wood-gasification"].value == false then
    wood_crushing = nil
end

local regolith_recycling = table.deepcopy(regolith_sorting)
local recycling_lib = require("__recycler__.recycling") --mods["recycler"]

regolith_recycling.name = "muluna-regolith-recycling"
regolith_recycling.categories = {"recycling"}
regolith_recycling.energy_required = regolith_sorting.energy_required / 4
regolith_recycling.results[3].independent_probability = 0.02
regolith_recycling.icons = generate_recycling_recipe_icons_from_item(data.raw.item["muluna-lunar-regolith"])
regolith_recycling.order = regolith_recycling.order .. "a"

local data_tape = table.deepcopy(data.raw["recipe"]["electronic-circuit"])

rro.deep_replace(data_tape,"electronic-circuit","muluna-basic-hard-drive")

data_tape.ingredients = {
    {type = "item", name }
}



local recipes = {anorthite_crushing,alumina_crushing,aluminum_crushing,stone_crushing,aluminum_plate,aluminum_cable,tree_crushing,regolith_sorting}
if wood_crushing then
    table.insert(recipes,wood_crushing)
end

for _,recipe in pairs(recipes) do
    if #recipe.results > 1 then  
          recipe.hide_from_signal_gui = false
    end 
    if mods["rigor-module"] then
        recipe.rigor_compatibility_mode_whitelist=true
    end
    
    
    
end



Muluna:extend(recipes)




if not data.raw["recipe"]["silicon-cell"] then

Muluna:extend{{ --Moshine recipe
    type = "recipe",
    name = "silicon-cell",
    categories = {"crafting","electromagnetics"},
    energy_required = 2,
    ingredients =
    {
      {type = "item", name = "silicon", amount = 5},
      {type = "item", name = "electronic-circuit", amount = 1},
    },
    results = {{type = "item", name = "silicon-cell", amount = 1}},
    allow_productivity = true,
    enabled = false,
  }}

end

if not data.raw["recipe"]["silicon-carbide"] then

Muluna:extend{{ --Moshine recipe
    type = "recipe",
    name = "silicon-carbide",
    categories = {"crafting-with-fluid"},
    energy_required = 8,
    ingredients =
    {
      {type = "item", name = "silicon", amount = 2},
      {type = "item", name = "carbon", amount = 1},
      {type = "fluid", name = "sulfuric-acid", amount = 10},
    },
    results = {{type = "item", name = "silicon-carbide", amount = 2}},
    allow_productivity = true,
    enabled = false,
  },}

end

Muluna:extend{{
    type = "recipe",
    name = "muluna-basic-hard-drive",
    categories = {"crafting-with-fluid"},
    ingredients = {
        {type = "item", name = "iron-plate",amount = 1},
        {type = "item", name = "plastic-bar", amount = 5},
        {type = "fluid", name = "lubricant", amount = 10}
    },
    enabled = false,
    energy_require = 5,
    results = {{type = "item", name = "muluna-basic-hard-drive", amount = 1}}, 
}}


