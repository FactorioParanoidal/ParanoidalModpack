local frame_map = {
    [16] = "__Belt_Glow__/graphics/glow/1.png",
    [32] = "__Belt_Glow__/graphics/glow/2.png",
    [64] = "__Belt_Glow__/graphics/glow/3.png"
}

for name, belt in pairs(data.raw["transport-belt"]) do
    if not belt.belt_animation_set then goto continue end
    local anim_set = belt.belt_animation_set.animation_set
    if not anim_set then goto continue end

    local layers = anim_set.layers or {anim_set}
    local is_ramp = false
    for _, layer in pairs(layers) do
        if layer.filename and string.find(layer.filename, "BeltRamp") then
            is_ramp = true
            break
        end
    end

    if is_ramp then
        for _, layer in pairs(layers) do
            if layer.filename and string.find(layer.filename, "BeltRampArrows%.png") then
                layer.draw_as_glow, layer.draw_as_light, layer.blend_mode = true, true, "normal"
            end
        end
        goto continue
    end

    if not anim_set.layers then anim_set.layers = {util.table.deepcopy(anim_set)} end
    for _, layer in pairs(anim_set.layers) do
        if layer.filename and string.find(layer.filename, "glow.png") then goto continue end
    end

    local base = anim_set.layers[1]
    local frames = base.frame_count or (base.hr_version and base.hr_version.frame_count) or 0
    if frame_map[frames] then
        local glow = util.table.deepcopy(base)
        glow.filename, glow.draw_as_light, glow.blend_mode = frame_map[frames], true, "normal"
        table.insert(anim_set.layers, glow)
    end
    ::continue::
end

for name, belt in pairs(data.raw["transport-belt"]) do
    if string.find(name, "^se%-deep%-space%-transport%-belt%-") then
        local layers = belt.belt_animation_set and belt.belt_animation_set.animation_set.layers
        if layers and layers[2] then
            layers[2].draw_as_glow, layers[2].blend_mode = true, "additive"
        end
    end
end