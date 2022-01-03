-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobores"] then return end

local ores = {
    -- Pure Bob's
    "ground-water",
    "lithia-water",
    "gem-ore",
    "lead-ore",
    "rutile-ore",
    "sulfur",
    "thorium-ore",
    "tin-ore",
    "bauxite-ore",
    "cobalt-ore",
    "gold-ore",
    "nickel-ore",
    "quartz",
    "silver-ore",
    "tungsten-ore",
    "zinc-ore",
}

for _, name in pairs(ores) do
    -- Check for autoplace controls, skip if it does not exist
    local control = data.raw["autoplace-control"][name]
    if not control then goto continue end

    -- Setup rich text localized name
    control.localised_name = {"", "[entity="..name.."] ", {"entity-name."..name}}

    -- Label to skip to next iteration
    ::continue::
end