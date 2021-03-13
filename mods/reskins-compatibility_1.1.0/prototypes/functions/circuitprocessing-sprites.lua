-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Compatibility
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not reskins.lib.setting("reskins-compatibility-do-circuitprocessing-circuit-style") then return end

local circuits = {
    ["basic-circuit-board"] = {tier = 1},
    ["electronic-circuit"] = {tier = 2},
    ["advanced-circuit"] = {tier = 3},
    ["processing-unit"] = {tier = 4},
    ["advanced-processing-unit"] = {tier = 5},
}

for circuit, map in pairs(circuits) do
    -- Make standard sprites
    -- data:extend({
    --     {
    --         type = "sprite",
    --         name = "reskins-bob-"..circuit.."-vanilla",
    --         filename = reskins.bobs.directory.."/graphics/icons/sprites/circuits/vanilla/"..circuit..".png",
    --         size = 40,
    --         mipmap_count= 2,
    --         flags = {"gui-icon"},
    --     }
    -- })

    -- Fetch tint
    local tint = reskins.lib.tint_index[map.tier]

    -- Make tier colored sprites
    data:extend({
        {
            type = "sprite",
            name = "reskins-compatibility-"..circuit.."-tier",
            layers = {
                {
                    filename = reskins.lib.directory.."/graphics/icons/sprites/circuits/"..circuit.."/"..circuit.."-base.png",
                    size = 40,
                    mipmap_count = 2,
                    flags = {"gui-icon"},
                },
                {
                    filename = reskins.lib.directory.."/graphics/icons/sprites/circuits/"..circuit.."/"..circuit.."-mask.png",
                    size = 40,
                    tint = tint,
                    mipmap_count = 2,
                    flags = {"gui-icon"},
                },
                {
                    filename = reskins.lib.directory.."/graphics/icons/sprites/circuits/"..circuit.."/"..circuit.."-highlights.png",
                    size = 40,
                    blend_mode = "additive",
                    mipmap_count = 2,
                    flags = {"gui-icon"},
                }
            },
            flags = {"gui-icon"}
        }
    })
end