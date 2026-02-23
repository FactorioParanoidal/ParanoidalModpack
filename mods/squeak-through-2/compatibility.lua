local cmu = require("collision-mask-util")

-- IndustrialRevolution3
-- do
--     local distance = 1.2 - 1/256

--     local vaporiser = data.raw["furnace"]["steel-vaporiser"]
--     if vaporiser then
--         vaporiser.fluid_boxes[1].pipe_connections[1].position[1] = -distance
--         vaporiser.fluid_boxes[2].pipe_connections[1].position[1] = distance
--     end

--     local cleaner = data.raw["assembling-machine"]["steel-cleaner"]
--     if cleaner then
--         cleaner.fluid_boxes[1].pipe_connections[1].position[2] = -distance
--         cleaner.fluid_boxes[2].pipe_connections[1].position[2] = distance
--     end
-- end

-- RealisticReactors
do
    local prototype = data.raw["constant-combinator"]["realistic-reactor-interface"]
    if prototype then
        prototype.collision_mask = cmu.get_mask(prototype)
        cmu.remove_layer(prototype.collision_mask, "player-layer")
    end
end