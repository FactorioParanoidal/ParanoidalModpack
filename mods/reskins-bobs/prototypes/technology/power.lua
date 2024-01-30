-- Copyright (c) 2023 Kirazy
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
    -- Heat pipes
    -- ["bob-heat-pipe-1"] = {}, -- heat pipes
    -- ["bob-heat-pipe-2"] = {}, -- silver pipes
    -- ["bob-heat-pipe-3"] = {}, -- gold pipes
}

if reskins.bobs.triggers.power.accumulators then
    -- Accumulators
    technologies["electric-energy-accumulators"] = {tier = 1, prog_tier = 2, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}

    if reskins.lib.migration.is_version_or_newer(mods["bobpower"], "1.1.6") then
        technologies["bob-electric-energy-accumulators-2"] = {tier = 2, prog_tier = 3, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}
        technologies["bob-electric-energy-accumulators-3"] = {tier = 3, prog_tier = 4, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}
    else
        technologies["electric-energy-accumulators"].technology_icon_layers = 1
        technologies["bob-electric-energy-accumulators-2"] = {tier = 1, prog_tier = 2, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}
        technologies["bob-electric-energy-accumulators-3"] = {tier = 2, prog_tier = 3, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}
        technologies["bob-electric-energy-accumulators-4"] = {tier = 3, prog_tier = 4, icon_name = "accumulator", technology_icon_size = 128, technology_icon_mipmaps = 0}
    end
end

if reskins.bobs.triggers.power.poles then
    -- Electric poles
    technologies["electric-energy-distribution-1"] = {icon_name = "power-poles", tier = 1, prog_tier = 2} -- t2 poles
    technologies["electric-pole-2"] = {icon_name = "power-poles", tier = 2, prog_tier = 3} -- t3 poles
    technologies["electric-pole-3"] = {icon_name = "power-poles", tier = 3, prog_tier = 4} -- t4 poles
    technologies["electric-pole-4"] = {icon_name = "power-poles", tier = 4, prog_tier = 5} -- t5 poles
    technologies["electric-energy-distribution-2"] = {icon_name = "substation", tier = 1, prog_tier = 2} -- t2 substation
    technologies["electric-substation-2"] = {icon_name = "substation", tier = 2, prog_tier = 3} -- t3 substation
    technologies["electric-substation-3"] = {icon_name = "substation", tier = 3, prog_tier = 4} -- t4 substation
    technologies["electric-substation-4"] = {icon_name = "substation", tier = 4, prog_tier = 5} -- t5 substation
end

if reskins.bobs.triggers.power.steam then
    -- Boilers
    technologies["bob-boiler-2"] = {tier = 2, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra}
    technologies["bob-boiler-3"] = {tier = 3, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra}
    technologies["bob-boiler-4"] = {tier = 4, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra}
    technologies["bob-boiler-5"] = {tier = 5, icon_name = "boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = boiler_icon_extra}

    -- Oil boilers
    technologies["bob-oil-boiler-1"] = {tier = 1, prog_tier = 2, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra}
    technologies["bob-oil-boiler-2"] = {tier = 2, prog_tier = 3, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra}
    technologies["bob-oil-boiler-3"] = {tier = 3, prog_tier = 4, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra}
    technologies["bob-oil-boiler-4"] = {tier = 4, prog_tier = 5, icon_name = "oil-boiler", technology_icon_size = 128, technology_icon_mipmaps = 0, technology_icon_extras = oil_boiler_icon_extra}

    -- Heat exchangers
    technologies["bob-heat-exchanger-1"] = {tier = 1, prog_tier = 3, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-base"}
    technologies["bob-heat-exchanger-2"] = {tier = 2, prog_tier = 4, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-silver-aluminum"}
    technologies["bob-heat-exchanger-3"] = {tier = 3, prog_tier = 5, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-gold-copper"}

    if reskins.lib.migration.is_version_or_newer(mods["bobpower"], "1.1.6") then
        technologies["bob-heat-exchanger-1"].prog_tier = 2

        technologies["bob-heat-exchanger-2"].prog_tier = 3
        technologies["bob-heat-exchanger-2"].icon_base = "heat-exchanger-aluminum-invar"

        technologies["bob-heat-exchanger-3"].prog_tier = 4
        technologies["bob-heat-exchanger-3"].icon_base = "heat-exchanger-silver-titanium"

        technologies["bob-heat-exchanger-4"] = {tier = 4, prog_tier = 5, icon_name = "heat-exchanger", technology_icon_size = 128, technology_icon_mipmaps = 0, icon_base = "heat-exchanger-gold-copper"}
    end

    -- Steam engines
    technologies["bob-steam-engine-2"] = {tier = 2, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0}
    technologies["bob-steam-engine-3"] = {tier = 3, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0}
    technologies["bob-steam-engine-4"] = {tier = 4, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0}
    technologies["bob-steam-engine-5"] = {tier = 5, icon_name = "steam-engine", technology_icon_size = 128, technology_icon_mipmaps = 0}

    -- Steam turbines
    technologies["bob-steam-turbine-1"] = {tier = 1, prog_tier = 3, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0}
    technologies["bob-steam-turbine-2"] = {tier = 2, prog_tier = 4, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0}
    technologies["bob-steam-turbine-3"] = {tier = 3, prog_tier = 5, icon_name = "steam-turbine", technology_icon_size = 128, technology_icon_mipmaps = 0}
end

if reskins.bobs.triggers.power.fluidgenerator then
    -- Fluid generators
    technologies["fluid-generator-1"] = {tier = 1, prog_tier = 2, icon_name = "fluid-generator"}
    technologies["fluid-generator-2"] = {tier = 2, prog_tier = 3, icon_name = "fluid-generator"}
    technologies["fluid-generator-3"] = {tier = 3, prog_tier = 4, icon_name = "fluid-generator"}
    technologies["hydrazine-generator"] = {tier = 4, prog_tier = 5, icon_name = "fluid-generator", tint = reskins.bobs.hydrazine_tint}
end

if reskins.bobs.triggers.power.heatsources then
    -- Heat sources
    -- technologies["fluid-reactor-1"] = {} -- t3 fluid burning heat sources
    -- technologies["fluid-reactor-2"] = {} -- t4 fluid heat source
    -- technologies["fluid-reactor-3"] = {} -- t5
    -- technologies["burner-reactor-1"] = {} -- t3 burner heat sources
    -- technologies["burner-reactor-2"] = {} -- t4 burner
    -- technologies["burner-reactor-3"] = {} -- t5
end

if reskins.bobs.triggers.power.solar then
    -- Solar Panels
    technologies["solar-energy"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"}
    technologies["bob-solar-energy-2"] = {tier = 1, prog_tier = 2, icon_name = "solar-energy"}
    technologies["bob-solar-energy-3"] = {tier = 2, prog_tier = 3, icon_name = "solar-energy"}
    technologies["bob-solar-energy-4"] = {tier = 3, prog_tier = 4, icon_name = "solar-energy"}

    if reskins.lib.migration.is_version_or_newer(mods["bobpower"], "1.1.6") then
        technologies["bob-solar-energy-2"] = {tier = 2, prog_tier = 3, icon_name = "solar-energy"}
        technologies["bob-solar-energy-3"] = {tier = 3, prog_tier = 4, icon_name = "solar-energy"}
        technologies["bob-solar-energy-4"] = nil
    end
end

reskins.lib.create_icons_from_list(technologies, inputs)