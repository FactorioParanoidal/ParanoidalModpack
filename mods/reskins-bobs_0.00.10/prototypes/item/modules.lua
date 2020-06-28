-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--     
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobmodules"] then return end
if reskins.lib.setting("reskins-bobs-do-bobmodules") == false then return end

-- Modules
local color_map = {
    ["blue"] = {"70b6ff", "30d2ff"},
    ["brown"] = {"9c7c60", "fff0d9"},
    ["cyan"] = {"70f1ff", "30ffd2"},
    ["green"] = {"95e26c", "2bff2b"},
    ["pine"] = {"7a9e96", "bfffd2"},
    ["pink"] = {"f96bcd", "ffbfe9"},
    ["red"] = {"f27c52", "ff9999"},
    ["yellow"] = {"ffdd45", "ffff66"},
}

local modules_map = {
    ["speed"] = {"blue", true},
    ["effectivity"] = {"yellow", true},
    ["productivity"] = {"red", true},
    ["pollution-create"] = {"brown"},
    ["pollution-clean"] = {"pine"},
    ["raw-speed"] = {"cyan"},
    ["green"] = {"green"},
    ["raw-productivity"] = {"pink"},
}

for class, map in pairs(modules_map) do
    inputs = {
        directory = reskins.bobs.directory,
        mod = "bobs",
        type = "module",
    }

    -- Setup input defaults
    reskins.lib.parse_inputs(inputs)

    -- Parse map
    local color = map[1]
    local is_exception = map[2]

    -- Do all tiers
    for tier = 1, 8 do
        -- Naming convention exception handling
        if tier == 1 and is_exception then
            name = class.."-module"
        else
            name = class.."-module-"..tier
        end

        -- Fetch entity
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        -- Setup icon path
        inputs.icon_filename = inputs.directory.."/graphics/icons/modules/module/"..color.."/"..color.."_"..tier..".png"

        reskins.lib.construct_icon(name, 0, inputs)

        -- Set beacon art style
        entity.art_style = "artisan-reskin"

        -- Overwrite beacon_tint property
        entity.beacon_tint = {
            primary = util.color(color_map[color][1]),
            secondary = util.color(color_map[color][2])
        }

        -- Label to skip to next iteration
        ::continue::
    end    
end