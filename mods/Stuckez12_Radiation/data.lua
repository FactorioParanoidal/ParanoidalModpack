require("prototypes.include_prototypes")
require("prototypes.simulations.tips_n_tricks")

local menu_simulations = require("menu-simulations.menu_simulations")

local sounds = {
    {
        name = "LowRadiation",
        dir = "__Stuckez12_Radiation__/sounds/low_radiation/low-radiation-",
        count = 7
    },
    {
        name = "MediumRadiation",
        dir = "__Stuckez12_Radiation__/sounds/medium_radiation/medium-radiation-",
        count = 7
    },
    {
        name = "HighRadiation",
        dir = "__Stuckez12_Radiation__/sounds/high_radiation/high-radiation-",
        count = 7
    }
}

for _, sound in pairs(sounds) do
    local variations = {}
    
    for i = 1, sound.count do
        table.insert(variations, {
            filename = sound.dir .. i .. ".wav",
            volume = 1.0
        })
    end

    data:extend({
        {
            type = "sound",
            name = sound.name,
            variations = variations
        }
    })
end

data:extend({
    {
        type = "damage-type",
        name = "Stuckez12-radiation"
    }
})

local gui_logo = {
    {
        name = "GUILowRadiation",
        dir = "__Stuckez12_Radiation__/graphics/screen_effect/low_radiation",
        count = 10
    },
    {
        name = "GUIMediumRadiation",
        dir = "__Stuckez12_Radiation__/graphics/screen_effect/medium_radiation",
        count = 10
    },
    {
        name = "GUIHighRadiation",
        dir = "__Stuckez12_Radiation__/graphics/screen_effect/high_radiation",
        count = 10
    }
}

for _, gui in pairs(gui_logo) do
    local sprites = {}
    local name = gui.name
    local dir = gui.dir

    for i = 1, gui.count do
        table.insert(sprites, {
            type = "sprite",
            name = name .. tostring(i),
            filename = dir .. "/radiation_logo_" .. tostring(i) .. ".png",
            width = 384,
            height = 384
        })
    end

    data:extend(sprites)
end


data:extend({
    {
        type = "sprite",
        name = "no_sprite",
        filename = "__Stuckez12_Radiation__/graphics/screen_effect/no_sprite.png",
        width = 32,
        height = 32
    }
})

if settings.startup["Stuckez12-Radiation-Menu-Simulations"].value then
    local main_menu_simulations = data.raw["utility-constants"]["default"].main_menu_simulations
    main_menu_simulations.Stuckez12_Radiation_train_sim = menu_simulations.train_sim
    main_menu_simulations.Stuckez12_Radiation_edge_patch = menu_simulations.edge_patch
    main_menu_simulations.Stuckez12_Radiation_patch_dies = menu_simulations.patch_dies
    main_menu_simulations.Stuckez12_Radiation_mining_patch = menu_simulations.mining_patch
    main_menu_simulations.Stuckez12_Radiation_rad_factory = menu_simulations.rad_factory
    main_menu_simulations.Stuckez12_Radiation_biter_breach = menu_simulations.biter_breach
    main_menu_simulations.Stuckez12_Radiation_rad_nuke = menu_simulations.rad_nuke
    main_menu_simulations.Stuckez12_Radiation_rad_corpse = menu_simulations.rad_corpse
    main_menu_simulations.Stuckez12_Radiation_rad_spider = menu_simulations.rad_spider
end
