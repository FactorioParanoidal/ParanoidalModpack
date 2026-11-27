if not mods["BottleneckLite"] then return end

local entity_types = {"assembling-machine", "furnace", "rocket-silo", "mining-drill"}
local graphics_fields = {"graphics_set", "graphics_set_flipped", "wet_mining_graphics_set"}

for _, entity_type in ipairs(entity_types) do
    for _, entity in pairs(data.raw[entity_type] or {}) do
        for _, field in ipairs(graphics_fields) do
            local graphics = entity[field]
            for _, visual in ipairs(graphics and graphics.working_visualisations or {}) do
                local animation = visual.animation
                if visual.apply_tint == "status" and animation
                    and animation.filename == "__BottleneckLite__/graphics/solid.png" then
                    animation.filename = "__zzzparanoidal__/graphics/bottleneck/outlined-dot.png"
                    animation.scale = animation.scale * 22 / 15
                    animation.draw_as_glow = false
                    visual.render_layer = "higher-object-above"
                end
            end
        end
    end
end
