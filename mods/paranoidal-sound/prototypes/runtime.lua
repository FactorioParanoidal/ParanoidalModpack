local variants = require("prototypes.variants")

local inputs = {["switch-gun-key"] = "next-weapon", ["switch-gun-key-tank"] = "next-weapon", ["switch-gun-key-car"] = "next-weapon", ["switch-gun-key-spider"] = "next-weapon", ["tank-moving-key-W"] = "move-up", ["tank-moving-key-A"] = "move-left", ["tank-moving-key-S"] = "move-down", ["tank-moving-key-D"] = "move-right", ["car-moving-key-W"] = "move-up", ["car-moving-key-A"] = "move-left", ["car-moving-key-S"] = "move-down", ["car-moving-key-D"] = "move-right"}
for name, control in pairs(inputs) do
    data:extend{{type = "custom-input", name = name, key_sequence = "", linked_game_control = control}}
end

data:extend{
    {type = "sound", name = "select-cannon", variations = variants("__paranoidal-sound__/sound/immersive/ui/select-cannon-%d.ogg", 3, 0.3)},
    {type = "sound", name = "select-smg", variations = variants("__paranoidal-sound__/sound/immersive/ui/select-smg-%d.ogg", 3, 0.25)},
    {type = "sound", name = "select-machine-gun", variations = variants("__paranoidal-sound__/sound/immersive/ui/select-machine-gun-%d.ogg", 3, 0.2)},
    {type = "sound", name = "car-engine-loads", variations = variants("__paranoidal-sound__/sound/immersive/driving/car-engine-load-%d.ogg", 4, 0.55)},
    {type = "sound", name = "car-engine-loads-reverse", variations = variants("__paranoidal-sound__/sound/immersive/driving/car-engine-load-reverse-%d.ogg", 4, 0.5)},
    {type = "sound", name = "car-steering", variations = variants("__paranoidal-sound__/sound/immersive/driving/car-steer-%d.ogg", 4, 0.4)},
    {type = "sound", name = "tank-engine-loads", variations = variants("__paranoidal-sound__/sound/immersive/driving/tank-engine-load-%d.ogg", 4, 0.5)},
    {type = "sound", name = "tank-engine-loads-reverse", variations = variants("__paranoidal-sound__/sound/immersive/driving/tank-engine-load-reverse-%d.ogg", 4, 0.3)},
    {type = "sound", name = "tank-engine-loads-rotation", variations = variants("__paranoidal-sound__/sound/immersive/driving/tank-engine-load-rotation-%d.ogg", 4, 0.4)},
    -- Retained prototype ID for saved/externally spawned effects; no tick emitter.
    {type = "projectile", name = "tracks-noise", acceleration = 0, flags = {"not-on-map"},
     animation = {{filename = "__paranoidal-sound__/graphics/dummy.png", priority = "low",
                   width = 32, height = 32, frame_count = 1, line_length = 1, animation_speed = 1}},
     light = {intensity = 0, size = 0},
     working_sound = {apparent_volume = 1, sound = variants("__paranoidal-sound__/sound/immersive/driving/unused/tank-tracks-%d.ogg", 3, 0.4)}}
}
