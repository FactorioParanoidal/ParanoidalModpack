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
    icon_name = "field",
    base_entity = "assembling-machine-1",
    mod = "compatibility",
    particles = {["big"] = 1, ["medium"] = 2},
    group = "extendedangels",
    make_remnants = false,
}

local tier_map = {
    ["crop-farm"] = {tier = 1, prog_tier = 0, field = "basic"},
    ["crop-farm-2"] = {tier = 2, prog_tier = 1, field = "basic"},
    ["crop-farm-3"] = {tier = 3, prog_tier = 2, field = "basic"},
    ["temperate-farm"] = {tier = 1, prog_tier = 2, field = "temperate"},
    ["temperate-farm-2"] = {tier = 2, prog_tier = 3, field = "temperate"},
    ["temperate-farm-3"] = {tier = 3, prog_tier = 4, field = "temperate"},
    ["swamp-farm"] = {tier = 1, prog_tier = 2, field = "swamp"},
    ["swamp-farm-2"] = {tier = 2, prog_tier = 3, field = "swamp"},
    ["swamp-farm-3"] = {tier = 3, prog_tier = 4, field = "swamp"},
    ["desert-farm"] = {tier = 1, prog_tier = 2, field = "desert"},
    ["desert-farm-2"] = {tier = 2, prog_tier = 3, field = "desert"},
    ["desert-farm-3"] = {tier = 3, prog_tier = 4, field = "desert"},
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

    -- Setup icon details
    inputs.icon_base = "field-"..map.field

    -- Determine what tint we're using
    inputs.tint = map.tint or reskins.lib.tint_index[tier]

    reskins.lib.setup_standard_entity(name, tier, inputs)

    -- Reskin entities
    table.insert(entity.working_visualisations, {
        always_draw = true,
        animation = {
            layers = {
                -- Mask
                {
                    filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/field/field-mask.png",
                    priority = "extra-high",
                    width = 224,
                    height = 224,
                    shift = {0, 0},
                    tint = inputs.tint,
                },
                -- Highlights
                {
                    filename = reskins.compatibility.directory.."/graphics/entity/extendedangels/field/field-highlights.png",
                    priority = "extra-high",
                    width = 224,
                    height = 224,
                    shift = {0, 0},
                    blend_mode = reskins.lib.blend_mode,
                }
            }
        }
    })

    -- Label to skip to next iteration
    ::continue::
end