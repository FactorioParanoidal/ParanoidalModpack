-- These two mods now run before the merged mod, whereas Immersive ran before them.
-- Restore only their known copies, not every modded fire/explosion in the pack.
local sounds = require("prototypes.library")
if mods.MIRV2 then
    for name, fire in pairs(data.raw.fire) do
        if name:match("^nuke%-fire%d+$") then fire.working_sound = table.deepcopy(sounds.fire_flame_sound) end
    end
end
if mods["paranoidal-picker-tools"] then
    local drop = data.raw.explosion["drop-planner"]
    if drop then
        drop.sound.variations = table.deepcopy(sounds.small_explosion_sound)
        for _, variation in ipairs(drop.sound.variations) do
            variation.filename = "__base__/sound/fight/laser-1.ogg"
            variation.volume = 0.5
        end
    end
end
