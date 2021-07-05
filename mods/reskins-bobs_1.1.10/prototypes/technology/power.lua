-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.technologies) then return end

-- Setup standard inputs
local inputs = {
    mod = "bobs",
    group = "power",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

-- Setup boiler and oil-boiler icon_extras
local boiler_icon_extra = {
    {
        icon = reskins.bobs.directory.."/graphics/technology/power/boiler/boiler-technology-light.png",
        icon_size = 128,
        icon_mipmaps = 0,
        tint = {1, 1, 1, 0}
    }
}

local oil_boiler_icon_extra = {
    {
        icon = reskins.bobs.directory.."/graphics/technology/power/oil-boiler/oil-boiler-technology-light.png",
        icon_size = 128,
        icon_mipmaps = 0,
        tint = {1, 1, 1, 0}
    }
}

-- Solar Energy
local technologies = {
    -- Solar Panels
    ["solar-energy"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"},
    ["bob-solar-energy-2"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"},
    ["bob-solar-energy-3"] = {tier = 2, prog_tier = 3, icon_name = "solar-energy"},
    ["bob-solar-energy-4"] = {tier = 3, prog_tier = 4, icon_name = "solar-energy"},

    -- Boilers
    ["bob-boiler-2"] = {tier = 2, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra},
    ["bob-boiler-3"] = {tier = 3, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra},
    ["bob-boiler-4"] = {tier = 4, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra},
    ["bob-boiler-5"] = {tier = 5, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra},

    -- Oil boilers
    ["bob-oil-boiler-1"] = {tier = 1, prog_tier = 2, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra},
    ["bob-oil-boiler-2"] = {tier = 2, prog_tier = 3, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra},
    ["bob-oil-boiler-3"] = {tier = 3, prog_tier = 4, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra},
    ["bob-oil-boiler-4"] = {tier = 4, prog_tier = 5, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra},

    -- Heat Exchangers
    ["bob-heat-exchanger-1"] = {tier = 1, prog_tier = 3, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-1"},
    ["bob-heat-exchanger-2"] = {tier = 2, prog_tier = 4, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-2"},
    ["bob-heat-exchanger-3"] = {tier = 3, prog_tier = 5, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-3"},

    -- Steam Engines
    ["bob-steam-engine-2"] = {tier = 2, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-steam-engine-3"] = {tier = 3, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-steam-engine-4"] = {tier = 4, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-steam-engine-5"] = {tier = 5, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0},

    -- Steam Turbines
    ["bob-steam-turbine-1"] = {tier = 1, prog_tier = 3, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-steam-turbine-2"] = {tier = 2, prog_tier = 4, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-steam-turbine-3"] = {tier = 3, prog_tier = 5, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0},

    -- Accumulators
    ["electric-energy-accumulators"] = {tier = 1, prog_tier = 2, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_layers = 1},
    ["bob-electric-energy-accumulators-2"] = {tier = 1, prog_tier = 2, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-electric-energy-accumulators-3"] = {tier = 2, prog_tier = 3, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["bob-electric-energy-accumulators-4"] = {tier = 3, prog_tier = 4, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0},

    -- Fluid generators
    ["fluid-generator-1"] = {tier = 1, prog_tier = 2, icon_name = "fluid-generator", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["fluid-generator-2"] = {tier = 2, prog_tier = 3, icon_name = "fluid-generator", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["fluid-generator-3"] = {tier = 3, prog_tier = 4, icon_name = "fluid-generator", technology_icon_size = 128, technology_icon_mipmaps = 0},
    ["hydrazine-generator"] = {tier = 4, prog_tier = 5, icon_name = "fluid-generator", technology_icon_size = 128, technology_icon_mipmaps = 0, tint = reskins.bobs.hydrazine_tint},

    -- Heat pipes
    -- ["bob-heat-pipe-1"] = {}, -- heat pipes
    -- ["bob-heat-pipe-2"] = {}, -- silver pipes
    -- ["bob-heat-pipe-3"] = {}, -- gold pipes

    -- Electric poles
    -- ["electric-energy-distribution-1"] = {}, -- t2 poles
    -- ["electric-pole-2"] = {}, -- t3 poles
    -- ["electric-pole-3"] = {}, -- t4 poles
    -- ["electric-pole-4"] = {}, -- t5 poles
    -- ["electric-energy-distribution-2"] = {}, -- t2 substation
    -- ["electric-substation-2"] = {}, -- t3 substation
    -- ["electric-substation-3"] = {}, -- t4 substation
    -- ["electric-substation-4"] = {}, -- t5 substation

    -- Heat sources
    -- ["fluid-reactor-1"] = {}, -- t3 fluid burning heat sources
    -- ["fluid-reactor-2"] = {}, -- t4 fluid heat source
    -- ["fluid-reactor-3"] = {}, -- t5
    -- ["burner-reactor-1"] = {}, -- t3 burner heat sources
    -- ["burner-reactor-2"] = {}, -- t4 burner
    -- ["burner-reactor-3"] = {}, -- t5
}

reskins.lib.create_icons_from_list(technologies, inputs)