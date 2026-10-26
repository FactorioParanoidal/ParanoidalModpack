-- Water against the start fires (scripts/douse.lua, scripts/fire.lua): white steam clouds, the
-- left click that pours a barrel from the hand and the sounds of a burning cursor.
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")

local big = smoke_animations.trivial_smoke({name = "bnl-steam", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.7},
    duration = 720, fade_in_duration = 10, spread_duration = 720, start_scale = 1.1, end_scale = 4.5})
local small = smoke_animations.trivial_smoke({name = "bnl-steam-small", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.55},
    duration = 90, fade_in_duration = 5, spread_duration = 90, start_scale = 0.4, end_scale = 1.4})

data:extend({
    big,
    small,
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
