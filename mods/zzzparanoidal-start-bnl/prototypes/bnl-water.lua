-- Water against the start fires (scripts/douse.lua, scripts/fire.lua): white steam clouds, the
-- left click that pours a barrel from the hand, the sounds of a burning cursor and the harmless
-- burning sticker of a character (the damage is scripted).
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")

-- The look of the vanilla fire sticker, a little brighter; no damage, no fire spread (the vanilla
-- one deals 1000/s and throws burning flames around).
local sticker_animation = {
    filename = "__base__/graphics/entity/fire-flame/fire-flame-01.png",
    line_length = 10,
    width = 84,
    height = 130,
    frame_count = 90,
    blend_mode = "normal",
    animation_speed = 1,
    scale = 0.4,
    tint = {r = 1, g = 1, b = 1, a = 0.5},
    shift = {-0.0078125, -0.18125},
    draw_as_glow = true,
}

local big = smoke_animations.trivial_smoke({name = "bnl-steam", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.7},
    duration = 720, fade_in_duration = 10, spread_duration = 720, start_scale = 1.1, end_scale = 4.5})
local small = smoke_animations.trivial_smoke({name = "bnl-steam-small", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.55},
    duration = 90, fade_in_duration = 5, spread_duration = 90, start_scale = 0.4, end_scale = 1.4})

data:extend({
    big,
    small,
    {
        type = "sticker",
        name = "bnl-burning-sticker",
        flags = {"not-on-map"},
        hidden = true,
        animation = sticker_animation,
        duration_in_ticks = 10 * 60, -- scripts/douse.lua sets time_to_live from config.fire.misuse
        target_movement_modifier = 0.8,
    },
    -- the burning cursor after fuel was poured on a fire (scripts/douse.lua): loud, for that player
    {
        type = "sound",
        name = "bnl-cursor-fire",
        category = "game-effect",
        filename = "__base__/sound/fight/flamethrower-mid.ogg",
        volume = 1,
    },
    {
        type = "sound",
        name = "bnl-cursor-crackle",
        category = "game-effect",
        variations = {
            {filename = "__base__/sound/fight/fire-impact-1.ogg", volume = 0.8},
            {filename = "__base__/sound/fight/fire-impact-2.ogg", volume = 0.8},
            {filename = "__base__/sound/fight/fire-impact-3.ogg", volume = 0.8},
            {filename = "__base__/sound/fight/fire-impact-4.ogg", volume = 0.8},
            {filename = "__base__/sound/fight/fire-impact-5.ogg", volume = 0.8},
        },
    },
    {
        -- raw left click: also fires when the click opens a GUI or mines; scripts/douse.lua checks the hand
        type = "custom-input",
        name = "bnl-douse",
        key_sequence = "mouse-button-1",
        consuming = "none",
    },
})
