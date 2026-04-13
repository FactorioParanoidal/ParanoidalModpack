local belt_glow_types = {
    -- 原版
    ["transport-belt"] = {glow_type = 1, color = {r=1, g=0.8, b=0.2}},
    ["fast-transport-belt"] = {glow_type = 2, color = {r=1, g=0, b=0}},
    ["express-transport-belt"] = {glow_type = 2, color = {r=0, g=1, b=1}},
    ["turbo-transport-belt"] = {glow_type = 3, color = {r=0.6, g=1, b=0}},
    -- castra
    ["military-transport-belt"] = {glow_type = 3, color = {r=0.44, g=0.33, b=0.22}},
    -- K2
    ["kr-advanced-transport-belt"] = {glow_type = 2, color = {r=0, g=0.8, b=0.3}},
    ["kr-superior-transport-belt"] = {glow_type = 2, color = {r=0.9, g=0, b=0.9}},
    -- matts-logistics  
    ["extreme-express-transport-belt"] = {glow_type = 2, color = {r=0, g=0.2, b=1}},
    ["extreme-fast-transport-belt"] = {glow_type = 2, color = {r=1, g=0.34, b=0}},
    ["ultimate-transport-belt"] = {glow_type = 2, color = {r=0.6, g=0.6, b=0.6}},
    ["ultra-express-transport-belt"] = {glow_type = 2, color = {r=0.5, g=0, b=1}},
    ["ultra-fast-transport-belt"] = {glow_type = 2, color = {r=0.1, g=1, b=0}},
}

for belt_name, glow_config in pairs(belt_glow_types) do
    local belt = data.raw["transport-belt"][belt_name]
    if belt then
        local anim = belt.belt_animation_set.animation_set
        local glow = util.table.deepcopy(anim)
        
        -- 直接使用 glow_type 数字作为文件名
        glow.filename = "__Belt_Glow__/graphics/glow/" .. glow_config.glow_type .. ".png"
        glow.draw_as_glow = true
        glow.blend_mode = "additive"
        glow.tint = glow_config.color
        
        -- 保持原动画，添加发光层
        belt.belt_animation_set.animation_set = { layers = {anim, glow} }
    end
end

--高级传送带(advancedBelts)mod兼容性
    local advancedBelts = {
        "extreme-belt",
        "ultimate-belt", 
        "high-speed-belt"
    }

    for _, name in ipairs(advancedBelts) do
        local belt = data.raw["transport-belt"][name]
        if belt and belt.belt_animation_set and belt.belt_animation_set.animation_set and belt.belt_animation_set.animation_set.layers then
            local layers = belt.belt_animation_set.animation_set.layers
            if layers[2] then
                layers[2].draw_as_glow = true
                layers[2].blend_mode = "additive"
            end
        end
    end