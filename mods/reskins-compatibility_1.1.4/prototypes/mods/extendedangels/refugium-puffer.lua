-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["extendedangels"] then return end
if not (reskins.angels and reskins.angels.triggers.bioprocessing.entities) then return end

-- Set input parameters
local inputs = {
    type = "assembling-machine",
    icon_name = "refugium-puffer",
    base_entity = "assembling-machine-1",
    mod = "compatibility",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "extendedangels",
    make_remnants = false,
}

local tier_map = {
    ["bio-refugium-puffer"] = {tier = 1},
    ["bio-refugium-puffer-2"] = {tier = 2},
    ["bio-refugium-puffer-3"] = {tier = 3},
}

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
    -- Fetch entity
    local entity = data.raw[inputs.type][name]

    -- Check if entity exists, if not, skip this iteration
    if not entity then goto continue end

    -- Handle tier
    local tier = map.tier
    if reskins.lib.setting("reskins-lib-tier-mapping") == "progression-map" then
        tier = map.prog_tier or map.tier
    end

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    table.insert(entity.working_visualisations, {
        always_draw = true,
        animation = {
            layers = {
                -- Base patch
                {
                    filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/refugium-puffer/refugium-puffer-base-patch.png",
                    priority = "extra-high",
                    width = 224,
                    height = 256,
                    shift = {0, -0.5},
                },
                -- Mask
                {
                    filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/refugium-puffer/refugium-puffer-mask.png",
                    priority = "extra-high",
                    width = 224,
                    height = 256,
                    shift = {0, -0.5},
                    tint = inputs.tint,
                },
                -- Highlights
                {
                    filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/refugium-puffer/refugium-puffer-highlights.png",
                    priority = "extra-high",
                    width = 224,
                    height = 256,
                    shift = {0, -0.5},
                    blend_mode = reskins.lib.blend_mode,
                }
            }
        }
    })

    -- Label to skip to next iteration
    ::continue::
end