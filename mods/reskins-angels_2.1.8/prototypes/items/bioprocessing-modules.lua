-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if reskins.lib.setting("cp-override-modules") == false then --[[ Do nothing ]] elseif mods["CircuitProcessing"] then return end
if not (reskins.bobs and reskins.bobs.triggers.modules.items) then return end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.items) then return end

local modules_map = {
    ["angels-bio-yield"] = {"orange", true},
}

for class, map in pairs(modules_map) do
    local inputs = {
        directory = reskins.bobs.directory,
        mod = "bobs",
        type = "module",
        make_icon_pictures = false,
    }

    -- Setup input defaults
    reskins.lib.parse_inputs(inputs)

    -- Parse map
    local color = map[1]
    local is_exception = map[2]

    -- Do all tiers
    for tier = 1, 8 do
        -- Naming convention exception handling
        local name = class.."-module-"..tier
        if tier == 1 and is_exception then
            name = class.."-module"
        end

        -- Fetch entity
        local entity = data.raw[inputs.type][name]

        -- Check if entity exists, if not, skip this iteration
        if not entity then goto continue end

        -- Setup icon path
        inputs.icon_filename = reskins.bobs.directory.."/graphics/icons/modules/module/"..color.."/"..color.."_"..tier..".png"

        reskins.lib.construct_icon(name, 0, inputs)

        -- Set beacon art style
        entity.art_style = "artisan-reskin"

        -- Overwrite beacon_tint property
        entity.beacon_tint = reskins.bobs.module_color_map[color]

        -- Label to skip to next iteration
        ::continue::
    end
end