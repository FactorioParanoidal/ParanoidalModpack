-- source: https://github.com/raiguard/Factorio-LtnManager/blob/master/src/prototypes/sprite.lua

local indicator_sprites = {{
    type = "sprite",
    name = "ltn-cleanup-signal-white",
    filename = "__core__/graphics/gui-new.png",
    position = {128, 96},
    size = 28,
    scale = 0.4,
    shift = {0, 1},
    tint = {255, 255, 255},
    flags = {"icon"}
}}
for i, t in ipairs(data.raw.lamp["small-lamp"].signal_to_color_mapping) do
    indicator_sprites[i + 1] = {
        type = "sprite",
        name = "ltn-cleanup-" .. t.name,
        filename = "__core__/graphics/gui-new.png",
        position = {128, 96},
        size = 28,
        scale = 0.4,
        shift = {0, 1},
        tint = t.color,
        flags = {"icon"}
    }
end
data:extend(indicator_sprites)
