-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["RealisticReactorGlow"] then return end
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if not (reskins.bobs and reskins.bobs.triggers.power.nuclear) then return end

local reactors = {
    ["nuclear-reactor"] = {base = 1},
    ["nuclear-reactor-2"] = {base = 2},
    ["nuclear-reactor-3"] = {base = 3},
}

local light_color = ""
if reskins.lib.setting("RealisticReactorGlow-cyan") then
    light_color = "_cyan"
end

-- Fix lighting
for name, map in pairs(reactors) do
    local entity = data.raw.reactor[name]

    if not entity then goto continue end

    -- Lights
    entity.working_light_picture = {
        filename = "__RealisticReactorGlow__/graphics/entity/nuclear-reactor/reactor-lights-color"..light_color..".png",
        blend_mode = "additive",
        draw_as_glow = true,
        width = 160,
        height = 160,
        shift = { -0.03125, -0.1875 },
        hr_version = {
            filename = "__RealisticReactorGlow__/graphics/entity/nuclear-reactor/hr-reactor-lights-color"..light_color..".png",
            blend_mode = "additive",
            draw_as_glow = true,
            width = 320,
            height = 320,
            scale = 0.5,
            shift = { -0.03125, -0.1875 },
        }
    }

    -- Handle ambient-light
    entity.energy_source.light_flicker = {
        color = {0, 0, 0},
        minimum_light_size = 0,
        light_intensity_to_size_coefficient = 0,
    }

    entity.default_fuel_glow_color = nil
    entity.use_fuel_glow_color = nil

    -- Modify the icon
    local icon_path = reskins.compatibility.directory.."/graphics/icons/realisticreactorglow/nuclear-reactor/nuclear-reactor-"..map.base.."-color"..light_color..".png"
    entity.icons[1].icon = icon_path

    -- Modify the icon pictures
    local item = data.raw.item[name]
    if item.pictures and item.pictures.layers then
        item.pictures.layers[1].filename = icon_path
    end

    -- Label to skip to next iteration
    ::continue::
end