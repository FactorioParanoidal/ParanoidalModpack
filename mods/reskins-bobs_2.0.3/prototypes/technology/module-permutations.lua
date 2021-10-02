-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if reskins.lib.setting("cp-override-modules") == false then --[[ Do nothing ]] elseif mods["CircuitProcessing"] then return end
if not (reskins.bobs and reskins.bobs.triggers.modules.technologies) then return end

-- Modules
local modules_map = {
    ["speed"] = {color = "blue", is_exception = true},
    ["effectivity"] = {color = "yellow", is_exception = true},
    ["productivity"] = {color = "red", is_exception = true},
    ["pollution-create"] = {color = "brown"},
    ["pollution-clean"] = {color = "pine"},
    ["raw-speed"] = {color = "cyan"},
    ["green"] = {color = "green"},
    ["raw-productivity"] = {color = "pink"},
}

-- Setup inputs
local inputs = {
    directory = reskins.bobs.directory,
    mod = "bobs",
    group = "modules",
    type = "technology",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

-- Setup input defaults
reskins.lib.parse_inputs(inputs)

for class, map in pairs(modules_map) do
    -- Do all tiers
    for tier = 1, 8 do
        -- Naming convention exception handling
        local name = class.."-module-"..tier
        if tier == 1 and map.is_exception then
            name = class.."-module"
        end

        -- Fetch technology
        local technology = data.raw[inputs.type][name]

        -- Check if technology exists, if not, skip this iteration
        if not technology then goto continue end

        -- Setup icon path
        inputs.technology_icon_filename = reskins.bobs.directory.."/graphics/technology/modules/module/"..map.color.."/"..map.color.."_"..tier..".png"

        reskins.lib.construct_technology_icon(name, inputs)

        -- Label to skip to next iteration
        ::continue::
    end
end

-- Reskin God module technologies
if reskins.lib.setting("bobmods-modules-enablegodmodules") then
    if not data.raw.technology["god-module-6"] then
        for i = 1, 5 do
            -- Fetch technology
            local name = "god-module-"..i
            local technology = data.raw[inputs.type][name]

            -- Check if technology exists, if not, skip this iteration
            if not technology then goto continue end

            -- Setup icon path
            inputs.technology_icon_filename = reskins.bobs.directory.."/graphics/technology/modules/god-module/"..name..".png"
            inputs.technology_icon_layers = 1

            reskins.lib.construct_technology_icon(name, inputs)

            -- Label to skip to next iteration
            ::continue::

        end
    end
end