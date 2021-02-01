-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobplates"] then return end

-- Battery
local inputs = {
    mod = "bobs",
    group = "plates",
    icon_name = "battery",
    tier_labels = false,
    make_icon_pictures = false,
}

-- Setup input defaults
reskins.lib.parse_inputs(inputs)

-- Batteries
local batteries = {
    ["battery"] = {1, 2, "battery", "ff781f"},
    ["lithium-ion-battery"] = {2, 3, "battery-2", "41ffdd"},
    ["silver-zinc-battery"] = {3, 4, "battery-3", "3dff40"},
}

for name, map in pairs(batteries) do
    -- Fetch item
    local item = data.raw.item[name]

    -- Check if item exists, if not, skip this iteration
    if not item then goto continue end

    -- Parse map
    local tier = map[1]
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map[2]
    end
    local technology = map[3]

    -- Determine what tint we're using
    if reskins.lib.setting("bobmods-colorupdate") then
        inputs.tint = reskins.lib.tint_index["tier-"..tier]
    else
        inputs.tint = util.color(map[4])
    end

    -- Specify crafting recipe tint
    data.raw["recipe"][name].crafting_machine_tint.primary = inputs.tint

    reskins.lib.construct_icon(name, tier, inputs)

    if data.raw.technology[technology] then
        reskins.lib.construct_technology_icon(technology, inputs)
    end

    -- Label to skip to next iteration
    ::continue::
end