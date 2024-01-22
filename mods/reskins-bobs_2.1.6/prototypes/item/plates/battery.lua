-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.plates.items) then return end

-- Battery
local inputs = {
    mod = "bobs",
    group = "plates",
    icon_name = "battery",
    technology_icon_size = 256,
    technology_icon_mipmaps = 4,
    tier_labels = false,
    make_icon_pictures = false,
}

-- Setup input defaults
reskins.lib.parse_inputs(inputs)

-- Batteries
local batteries = {
    ["battery"] = { tier = 1, prog_tier = 2, technology = "battery", tint = "ff781f" },
    ["lithium-ion-battery"] = { tier = 2, prog_tier = 3, technology = "battery-2", tint = "41ffdd" },
    ["silver-zinc-battery"] = { tier = 3, prog_tier = 4, technology = "battery-3", tint = "3dff40" },
}

for name, map in pairs(batteries) do
    -- Fetch item
    local item = data.raw.item[name]

    -- Check if item exists, if not, skip this iteration
    if not item then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    if reskins.lib.setting("bobmods-colorupdate") then
        inputs.tint = reskins.lib.tint_index[tier]
    else
        inputs.tint = util.color(map.tint)
    end

    -- Specify crafting recipe tint
    data.raw["recipe"][name].crafting_machine_tint.primary = inputs.tint

    reskins.lib.construct_icon(name, tier, inputs)

    if data.raw.technology[map.technology] then
        reskins.lib.construct_technology_icon(map.technology, inputs)
    end

    -- Label to skip to next iteration
    ::continue::
end
