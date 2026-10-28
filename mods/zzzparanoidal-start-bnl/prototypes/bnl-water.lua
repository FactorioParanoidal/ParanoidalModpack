-- Water against the start fires (scripts/douse.lua, scripts/fire.lua): white steam clouds and the
-- left click that pours a barrel from the hand.
local smoke_animations = require("__base__.prototypes.entity.smoke-animations")

local big = smoke_animations.trivial_smoke({name = "bnl-steam", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.7},
    duration = 720, fade_in_duration = 10, spread_duration = 720, start_scale = 1.1, end_scale = 4.5})
local small = smoke_animations.trivial_smoke({name = "bnl-steam-small", color = {r = 0.95, g = 0.95, b = 0.95, a = 0.55},
    duration = 90, fade_in_duration = 5, spread_duration = 90, start_scale = 0.4, end_scale = 1.4})

data:extend({
    big,
    small,
    {
        -- raw left click: also fires when the click opens a GUI or mines; scripts/douse.lua checks the hand
        type = "custom-input",
        name = "bnl-douse",
        key_sequence = "mouse-button-1",
        consuming = "none",
    },
})
