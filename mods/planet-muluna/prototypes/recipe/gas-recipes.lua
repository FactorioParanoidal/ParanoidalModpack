local dual_icon = require("lib.dual-item-icon").dual_icon
local rro = Muluna.rro

local function generate_void_icons(fluid_icons)
    local icons = fluid_icons
    if not icons then return end

    icons = table.deepcopy(icons)
    table.insert(icons, 1, {
        icon = "__core__/graphics/filter-blacklist.png",
        icon_size = 101,
    })
    return icons
end

table.insert(data.raw["assembling-machine"]["chemical-plant"].crafting_categories , "muluna-greenhouse")
Muluna:extend{
     {
        type="recipe-category",
        name="muluna-greenhouse",
      },
    {
        type = "recipe",
        name = "muluna-tree-growth-greenhouse",
        enabled = false,
        categories = {"muluna-greenhouse"},
        icons = dual_icon("muluna-sapling","carbon-dioxide"),
        ingredients = {
            {type = "item",name = "tree-seed", amount=10}, --Reminder: 1 tree seed = 2 wood
            {type = "fluid",name = "carbon-dioxide", amount=10000,fluidbox_index = 1},
            {type = "fluid",name = "water", amount=500,fluidbox_index = 2},
        },
        results = {
            {type = "item",name = "muluna-sapling", amount=10},
            {type = "fluid",name = "oxygen", amount=10000,ignored_by_productivity=10000,fluidbox_index = 1}
        },
        energy_required=5*60,
        subgroup="muluna-forestry",
        max_productivity = 3,
        allow_quality = true,
        can_set_quality = false,
        auto_recycle=false,
        allow_productivity = true,
        hide_from_signal_gui = false,
        surface_conditions = {
            {
                property = "temperature",
                max = 314
            }
        }
    },
    -- {
    --     type = "recipe",
    --     name = "muluna-sapling-growth-greenhouse",
    --     enabled = false,
    --     categories = {"muluna-greenhouse"},
    --     --icons = dual_icon("muluna-sapling","carbon-dioxide"),
    --     ingredients = {
    --         {type = "item",name = "tree-seed", amount=10}, --Reminder: 1 tree seed = 2 wood
    --         {type = "fluid",name = "carbon-dioxide", amount=10000,fluidbox_index = 1},
    --         {type = "fluid",name = "water", amount=500, fluidbox_index = 2},
    --     },
    --     results = {
    --         {type = "item",name = "muluna-sapling", amount=10},
    --         {type = "fluid",name = "oxygen", amount=10000,ignored_by_productivity=10000, fluidbox_index = 1}
    --     },
    --     energy_required=5*60,
    --     auto_recycle=false,
    --     subgroup="muluna-forestry",
    --     main_product = "muluna-sapling",
    --     max_productivity = 3,
    --     allow_productivity = true,
    --     hide_from_signal_gui = false,
    --     surface_conditions = {
    --         {
    --             property = "temperature",
    --             max = 314
    --         }
    --     }
    -- },
    {
        type = "recipe",
        name = "muluna-tree-growth-greenhouse-water-saving",
        enabled = false,
        categories = {"muluna-greenhouse"},
        icons = dual_icon("muluna-sapling","water"),
        ingredients = {
            {type = "item",name = "tree-seed", amount=10}, --Reminder: 1 tree seed = 2 wood
            {type = "fluid",name = "carbon-dioxide", amount=10000,fluidbox_index = 1},
            {type = "fluid",name = "water", amount=250, fluidbox_index = 2},
        },
        results = {
            {type = "item",name = "muluna-sapling", amount=10},
            {type = "fluid",name = "oxygen", amount=10000,ignored_by_productivity=10000, fluidbox_index = 1}
        },
        energy_required=10*60,
        auto_recycle=false,
        subgroup="muluna-forestry",
        max_productivity = 3,
        allow_productivity = true,
        allow_quality = true,
        can_set_quality = false,
        hide_from_signal_gui = false,
        surface_conditions = {
            {
                property = "temperature",
                max = 314
            }
        }
    },
    
    -- {
    --     type = "recipe",
    --     name = "muluna-tree-growth-greenhouse-quick",
    --     enabled = false,
    --     categories = {"muluna-greenhouse"},
    --     icons = dual_icon("wood","express-transport-belt"),
    --     ingredients = {
    --         {type = "item",name = "tree-seed", amount=10}, --Reminder: 1 tree seed = 2 wood
    --         {type = "fluid",name = "carbon-dioxide", amount=10000},
    --         {type = "fluid",name = "water", amount=1000},
    --     },
    --     results = {
    --         {type = "item",name = "muluna-sapling", amount=10},
    --         {type = "fluid",name = "oxygen", amount=10000,ignored_by_productivity=10000}
    --     },
    --     energy_required=3*60,
    --     subgroup="muluna-forestry",
    --     max_productivity = 3,
    --     allow_productivity = true,
    --     hide_from_signal_gui = false,
    --     surface_conditions = {
    --         {
    --             property = "temperature",
    --             max = 314
    --         }
    --     }
    -- },
    -- {
    --     type = "recipe",
    --     name = "muluna-electrolysis",
    --     enabled = false,
    --     icons = dual_icon("oxygen","hydrogen"),
    --     --icon = "__muluna-graphics__/graphics/icons/maraxsis-water.png",
    --     --icon_size = 64,
    --     categories = {"chemistry"},
    --     ingredients = {
    --         {type = "fluid",name = "water", amount=30},
    --     },
    --     results = {
    --         {type = "fluid",name = "oxygen", amount=100},
    --         {type = "fluid",name = "hydrogen", amount=200}
    --     },
    --     energy_required=2,
    --     subgroup="muluna-products"
    -- },
    {
        type = "recipe",
        name = "oxygen-venting",
        enabled = false,
        hidden_in_factoriopedia = true,
        icons = generate_void_icons({{icon = "__muluna-graphics__/graphics/icons/oxygen.png", icon_size = 64}}),
        categories = {"chemistry"},
        ingredients = {
            {type = "fluid",name = "oxygen", amount=54},
        },
        results = {},
        -- surface_conditions = {
        --     {
        --         property = "pressure",
        --         max = 50,
        --     }
        -- },
        energy_required=0.1,
        subgroup="muluna-products",
        hide_from_signal_gui = false
    },
    {
        type = "recipe",
        name = "carbon-dioxide-venting",
        enabled = false,
        hidden_in_factoriopedia = true,
        icons = generate_void_icons({{icon = "__muluna-graphics__/graphics/icons/molecule-carbon-dioxide.png", icon_size = 64}}),
        categories = {"chemistry"},
        ingredients = {
            {type = "fluid",name = "carbon-dioxide", amount=54},
        },
        results = {},
        -- surface_conditions = {
        --     {
        --         property = "pressure",
        --         max = 50,
        --     }
        -- },
        energy_required=0.1,
        subgroup="muluna-products",
        hide_from_signal_gui = false
    },
    -- {
    --     type = "recipe",
    --     name = "muluna-atmosphere-separation",
    --     icon = data.raw["item"]["wood"].icon,
    --     categories = {"chemistry"},
    --     ingredients = {
    --         {type = "item",name = "atmosphere", amount=100}
    --     },
    --     results = {
    --         {type = "item",name = "oxygen", amount=20},
    --         {type = "item",name = "nitrogen", amount=80}
    --     },
    --     energy_required=10*60,

    -- },
    { 
        type = "recipe",
        name = "controlled-combustion",
        --icons = dual_icon("carbon-dioxide","oxygen"),
        enabled = false,
        icon = "__muluna-graphics__/graphics/icons/molecule-carbon-dioxide.png",
        icon_size = 64,
        categories = {"double-boiler"},
        ingredients = {
            --{type = "item",name = "carbon", amount=1},
            {type = "fluid",name = "oxygen", amount=10}
        },
        results = {
            {type = "fluid",name = "carbon-dioxide", amount=10, temperature = 165}
        },
        energy_required=1/6,
        subgroup="muluna-products",
        hide_from_signal_gui = false

    },
    {
        type = "recipe",
        name = "carbon-dioxide",
        localised_name={"fluid-name.carbon-dioxide"},
        categories = {"chemistry"},
        energy_required = 10,
        ingredients = {},
        results = {
            {type = "fluid", name = "carbon-dioxide", amount = 100, temperature = 25}
        },
        enabled = false,
        main_product = "carbon-dioxide",
        subgroup="fluid-recipes",
        order=(data.raw["recipe"]["ice-melting"].order or "") .."b[carbon-dioxide]",
        surface_conditions = {{
            property = "carbon-dioxide",
            min = 90,

        }}
    },
    { 
        type = "recipe",
        name = "controlled-combustion-atmosphere",
        enabled = false,
        icons = dual_icon("carbon-dioxide","maraxsis-atmosphere"),
        --icon = "__muluna-graphics__/graphics/icons/molecule-carbon-dioxide.png",
        --icon_size = 64,
        categories = {"double-boiler"},
        ingredients = {
            --{type = "item",name = "carbon", amount=1},
            {type = "fluid",name = "maraxsis-atmosphere", amount=50}
        },
        results = {
            {type = "fluid",name = "carbon-dioxide", amount=10, temperature = 165}
        },
        energy_required=1/6,
        subgroup="muluna-products",
        hide_from_signal_gui = false,
    },
    -- { 
    --     type = "recipe",
    --     name = "helium-separation",
    --     enabled = false,
    --     icons = {   
    --             {
    --                 icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --                 icon_size = 64,
    --                 tint = {1,0.8,1},
    --                 scale = 0.5,
    --                 shift = {16,0}
    --             },
    --             {
    --                 icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --                 icon_size = 64,
    --                 tint = {1,0.6,1},
    --                 scale = 0.5,
    --                 shift = {-16,0}
    --             },   
    --     },
    --     --icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --     --icon_size = 64,
    --     categories = {"chemistry"},
    --     ingredients = {
    --         {type = "fluid",name = "helium", amount=1000}
    --     },
    --     results = {
    --         {type = "fluid",name = "helium-4", amount=993},
    --         {type = "fluid",name = "helium-3", amount=7}
    --     },
    --     energy_required=2,
    --     subgroup="muluna-products",
    --     allow_productivity = false,

    -- },
    -- { 
    --     type = "recipe",
    --     name = "kovarex-helium-enrichment",
    --     localised_name = {"recipe-name.kovarex-muluna-helium-enrichment"},
    --     enabled = false,
    --     icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --     allow_productivity = true,
    --     --icon_size = 64,
    --     icons = {   
    --         {
    --             icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --             icon_size = 64,
    --             tint = {1,0.6,1},
    --             scale = 0.5,
    --             shift = {16,0},
    --             draw_background = true,
    --         },
    --         {
    --             icon = "__muluna-graphics__/graphics/icons/molecule-noble-gas.png",
    --             icon_size = 64,
    --             tint = {1,0.6,1},
    --             scale = 0.5,
    --             shift = {-16,0},
    --             draw_background = true,
    --         },
           
    -- },
    --     categories = {"chemistry"},
    --     ingredients = {
    --         {type = "fluid",name = "helium-4", amount=60},
    --         {type = "fluid",name = "helium-3", amount=400}
    --     },
    --     results = {
    --         {type = "fluid",name = "helium-4", amount=10},
    --         {type = "fluid",name = "helium-3", amount=402, ignored_by_productivity=400}
    --     },
    --     energy_required=0.2,
    --     subgroup="muluna-products"

    -- },
    {
        type = "recipe",
        categories = {"chemistry"},
        enabled = false,
        name = "cellulose",
        ingredients = {
            {type = "item",name = "woodchips", amount=40},
            {type = "fluid",name = "sulfuric-acid", amount=5}
        },
        energy_required = 16,
        results = {
            {type = "item",name = "cellulose", amount=40},
        },
        auto_recycle=false,
        allow_productivity = true,
    },
    {
        type = "recipe",
        name = "muluna-microcellular-plastic",
        enabled = false,
        categories = {"chemistry","cryogenics",mods["maraxsis"] and "maraxsis-hydro-plant" or nil},
        ingredients = {
            {type = "item",name = "muluna-diffused-plastic", amount = 1},
            {type = "fluid",name = "steam", amount = 25}
        },
        results = {
            {type = "item",name = "muluna-microcellular-plastic", amount = 1},
        },
        energy_required = 1,
        allow_productivity = true,
        auto_recycle = false,
    },
    --local steam_condensing = 
    {   
        type = "recipe",
        name = "muluna-steam-condensation",
        enabled = false,
        categories = {"chemistry","cryogenics"},
        subgroup="muluna-products",
        icons = dual_icon("water","cooled-steam"),
        ingredients = {
            {type = "fluid" , name = "cooled-steam" , amount = 1000}
        },
        results = {
            {type = "fluid", name = "water", amount = 25}
        },
        allow_productivity = true,
        hide_from_signal_gui = false,
    
    },

    -- {
    --     type = "recipe",
    --     categories = {"chemistry"},
    --     name = "heavy-oil-cellulose",
    --     ingredients = {
    --         {type = "item",name = "cellulose", amount=40},
    --         {type = "fluid",name = "steam", amount=100}
    --     },
    --     energy_required = 8,
    --     results = {
    --         {type = "fluid",name = "heavy-oil", amount=100},
    --     },
    --     allow_productivity = true,
    -- },


}

if settings.startup["muluna-hardcore-classic-wood-gasification"].value == false then
    rro.replace(data.raw["recipe"]["cellulose"].ingredients,{type = "item",name = "woodchips", amount="_any"},{type = "item",name = "wood", amount=20})
    
end

local divider = 40 --I'm too tired to do mental math. This will simplify the ratio calculations.
local probability = 1
local oxygen_from_oxidizer = {
    type = "recipe",
    name = "muluna-oxygen-from-oxidizer",
    enabled = false,
    categories = {"chemistry"},
    icons = dual_icon("oxygen","thruster-oxidizer"),
    energy_required = 0.1,
    subgroup="muluna-products",
    ingredients = {
        { --At 300% productivity using advanced oxidizer recipe, you will reclaim 100% of your water.
            type = "fluid",
            name = "thruster-oxidizer",
            amount = 4000/divider,
        }
    },
    results = {
        {
            type = "fluid",
            name = "oxygen",
            amount = 8000/divider,
            ignored_by_productivity=8000/divider,
        },
    },
    hide_from_signal_gui = false,
}

if not mods["Krastorio2-spaced-out"] then
    Muluna:extend{oxygen_from_oxidizer}
end


local diffusion = {
        type = "recipe",
        name = "muluna-diffused-plastic",
        enabled = false,
        categories = {"chemistry","cryogenics"},
        ingredients = {
            {type = "item",name = "plastic-bar", amount = 1},
            {type = "fluid",name = "carbon-dioxide", amount = 10}
        },
        results = {
            --{type = "item",name = "muluna-diffused-plastic", amount = 1},
            {type = "fluid",name = "carbon-dioxide", amount = 2.5} --Because I want to make finding the perfect combination of productivity vs speed more challenging
        },
        rigor_sensitivity=mods["rigor-module"] and 2 or nil,
        rigor_compatibility_mode_whitelist=mods["rigor-module"] and true or nil,
        energy_required = 10,
        main_product = "muluna-diffused-plastic",
        --icons = data.raw["item"][].icons,
        --allow_productivity = false,
        auto_recycle = false,
        allow_quality = false,
    }

    local steps = 20
    for i = 1,steps,1 do
        table.insert(diffusion.results,{
            type = "item",
            name = "muluna-diffused-plastic",
            amount = 1,
            shared_probability = {
                min = (i-1)/steps,
                max = i/steps
            },
            percent_spoiled = (i-1)/steps,
            ignored_by_productivity = 1,
            reset_freshness_on_craft = settings.startup["muluna-easy-simple-nanofoamed-polymers"].value == true,
        })
    end
    diffusion.results[2].rigor_product=mods["rigor-module"] and true or nil

Muluna:extend{diffusion}

local greenhouse_recipes_with_nutrients = {}
local recipe_icons_vulcanus = {dual_icon("muluna-sapling","fluoroketone-cold","carbon-dioxide"),dual_icon("muluna-sapling","fluoroketone-cold","water")}
local recipe_icons_heated = {dual_icon("muluna-sapling","fluoroketone-hot","carbon-dioxide"),dual_icon("muluna-sapling","fluoroketone-hot","water")}

    -- Nutrient-using greenhouse recipes
    local greenhouse_recipes = {"muluna-tree-growth-greenhouse","muluna-tree-growth-greenhouse-water-saving"}
    local recipe_icons = {dual_icon("muluna-sapling","nutrients","carbon-dioxide"),dual_icon("muluna-sapling","nutrients","water")}
    greenhouse_recipes_with_nutrients = table.deepcopy(greenhouse_recipes)
    for i,recipe_name in ipairs(greenhouse_recipes) do
        local recipe
        local recipe_vulcanus
        local recipe_heated
        if data.raw["recipe"][recipe_name] then
            local original_recipe = data.raw["recipe"][recipe_name]
            recipe = table.deepcopy(original_recipe)
            recipe.name = original_recipe.name .. "-nutrients"
            table.insert(greenhouse_recipes_with_nutrients,recipe.name)
            local nutrients = {type="item",name="nutrients",amount=5}
            if mods["fluid-nutrients"] then
                nutrients["fluidbox_index"] = 4
            end
            table.insert(recipe.ingredients,nutrients)
            recipe.results[1].amount=recipe.results[1].amount*1.5
            rro.replace(recipe.results,{type = "fluid",name = "oxygen", amount=10000,ignored_by_productivity=10000,fluidbox_index = 1},{type = "fluid",name = "oxygen", amount=15000,ignored_by_productivity=15000,fluidbox_index = 1})
            rro.replace(recipe.ingredients,{type = "fluid",name = "carbon-dioxide", amount=10000,fluidbox_index = 1},{type = "fluid",name = "carbon-dioxide", amount=15000,fluidbox_index = 1})
            --recipe.energy_required = recipe.energy_required*0.6
            recipe.icons = recipe_icons[i]

            recipe_vulcanus = table.deepcopy(recipe)
            recipe_vulcanus.name = original_recipe.name .. "-vulcanus"
            recipe_vulcanus.icons = recipe_icons_vulcanus[i]
            for _,item in pairs(recipe_vulcanus.ingredients) do
                if item.name == "carbon-dioxide" then
                    item.amount = 20000
                    item.ignored_by_productivity = 20000
                end
                if item.name == "water" then
                    --item.amount = 20000
                    --item.ignored_by_productivity = 20000
                    table.insert(recipe_vulcanus.ingredients,{type = "fluid",name = "fluoroketone-cold", amount=500*(500/item.amount), fluidbox_index = 3})
                    table.insert(recipe_vulcanus.results,{type = "fluid",name = "fluoroketone-hot", amount=500*(500/item.amount),ignored_by_productivity=500*(500/item.amount),fluidbox_index = 2})
                end
            end
            --table.insert(recipe_vulcanus.ingredients,{type = "fluid",name = "fluoroketone-cold", amount=500, fluidbox_index = 3})
            --table.insert(recipe_vulcanus.results,{type = "fluid",name = "fluoroketone-hot", amount=500,ignored_by_productivity=500,fluidbox_index = 2})
            for _,item in pairs(recipe_vulcanus.results) do
                if item.name == "wood" then
                    item.amount = 80
                end
                if item.name == "muluna-sapling" then
                    item.amount = 20
                end
                if item.name == "oxygen" then
                    item.amount = 20000
                    item.ignored_by_productivity = 20000
                end
            end
            recipe_vulcanus.surface_conditions = nil
            -- recipe_heated = table.deepcopy(recipe_vulcanus)
            -- recipe_vulcanus.surface_conditions = {
            --     {
            --         property = "temperature",
            --         min = 330
            --     },
            -- }
            -- recipe_heated.surface_conditions = {
            --     {
            --         property = "temperature",
            --         max = 275
            --     },
            -- }
            -- recipe_heated.name = original_recipe.name .. "-heated"
            -- for _,item in pairs(recipe_heated.results) do
            --     if item.name == "fluoroketone-hot" then
            --         item.name = "fluoroketone-cold"
            --     end
            -- end
            -- for _,item in pairs(recipe_heated.ingredients) do
            --     if item.name == "fluoroketone-cold" then
            --         item.name = "fluoroketone-hot"
            --     end
            -- end
            Muluna:extend{recipe,recipe_vulcanus}
            if data.raw["technology"]["muluna-fertilized-greenhouses"] then
                table.insert(data.raw["technology"]["muluna-fertilized-greenhouses"].effects,{type = "unlock-recipe", recipe = recipe.name})
            end
            if data.raw["technology"]["muluna-fertilized-greenhouses-vulcanus"] then
                table.insert(data.raw["technology"]["muluna-fertilized-greenhouses-vulcanus"].effects,{type = "unlock-recipe", recipe = recipe_vulcanus.name})
            end
        end
    end 

if data.raw.planet["maraxsis"] then
    
    Muluna:extend{{
        type = "recipe",
        name = "hydrogen-venting",
        enabled = false,
        hidden_in_factoriopedia = true,
        icons = generate_void_icons({{icon = "__muluna-graphics__/graphics/icons/hydrogen.png", icon_size = 64}}),
        categories = {"chemistry"},
        ingredients = {
            {type = "fluid",name = "hydrogen", amount=54},
        },
        results = {},
        -- surface_conditions = {
        --     {
        --         property = "pressure",
        --         max = 50,
        --     }
        -- },
        energy_required=0.1,
        subgroup="muluna-products",
        hide_from_signal_gui = false,
    }}
end
