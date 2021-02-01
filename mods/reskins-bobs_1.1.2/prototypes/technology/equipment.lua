-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
local do_vehicle, do_personal = true, true
if not mods["bobvehicleequipment"] then do_vehicle = false end
if not mods["bobequipment"] then do_personal = false end

if (not do_vehicle) and (not do_personal) then return end

local inputs = {
    type = "technology",
    mod = "bobs",
    group = "equipment",
    icon_name = "modular-equipment",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
}

local technology = {
    ["roboport-modular-equipment-1"] = {tier = 1, prog_tier = 2},
    ["roboport-modular-equipment-2"] = {tier = 2, prog_tier = 3},
    ["roboport-modular-equipment-3"] = {tier = 3, prog_tier = 4},
    ["roboport-modular-equipment-4"] = {tier = 4, prog_tier = 5},
}

for name, map in pairs(technology) do
    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index["tier-"..tier]

    inputs.icon_base = inputs.icon_name.."-"..map.tier

    -- Do personals
    if do_personal then
        if not data.raw[inputs.type]["personal-"..name] then goto vehicle end

        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{scale = 1} }

        reskins.lib.construct_technology_icon("personal-"..name, inputs)
    end

    -- Do vehicles
    ::vehicle::
    if do_vehicle then
        if not data.raw[inputs.type]["vehicle-"..name] then goto continue end

        inputs.technology_icon_extras = { reskins.lib.technology_equipment_overlay{scale = 1, is_vehicle = true} }

        reskins.lib.construct_technology_icon("vehicle-"..name, inputs)
    end

    -- Label to skip to next iteration
    ::continue::
end