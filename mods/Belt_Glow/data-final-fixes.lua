local frame_map = {
    [16] = "__Belt_Glow__/graphics/glow/1.png",
    [32] = "__Belt_Glow__/graphics/glow/2.png",
    [64] = "__Belt_Glow__/graphics/glow/3.png"
}

for name, belt in pairs(data.raw["transport-belt"]) do
    if not belt.belt_animation_set then goto continue end
    local anim_set = belt.belt_animation_set.animation_set
    if not anim_set or anim_set.layers or anim_set.scale ~= 0.25 then goto continue end

    if anim_set.filename and string.find(anim_set.filename, "factorio_hd_age") then
        local frames = anim_set.frame_count or 0
        if frame_map[frames] then
            local glow = util.table.deepcopy(anim_set)
            glow.filename = frame_map[frames]
            glow.size = (anim_set.size or 256) / 2
            glow.scale = 0.5
            glow.draw_as_light = true
            glow.blend_mode = "normal"

            anim_set.layers = { util.table.deepcopy(anim_set), glow }

            anim_set.filename = nil
            anim_set.scale = nil
            anim_set.size = nil
            anim_set.frame_count = nil
            anim_set.direction_count = nil
        end
    end
    ::continue::
end