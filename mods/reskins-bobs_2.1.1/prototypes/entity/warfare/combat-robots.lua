-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Setup capsule projectiles
local capsule_projectiles = {
    "bob-laser-robot-capsule",
    "destroyer-capsule",
    "distractor-capsule",
    "defender-capsule",
}

---Reskins capsule projectiles
---@param name string
local function capsule_projectile(name)
    local projectile = data.raw["projectile"][name]
    if not projectile then return end

    projectile.animation = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/capsules/"..name..".png",
        priority = "high",
        flags = { "no-crop" },
        frame_count = 1,
        size = 48,
        scale = 0.5,
    }

    projectile.shadow = {
        filename = reskins.bobs.directory.."/graphics/entity/warfare/capsules/combat-robot-capsule-shadow.png",
        priority = "high",
        flags = { "no-crop" },
        frame_count = 1,
        size = 48,
        scale = 0.5,
    }

end

for _, name in pairs(capsule_projectiles) do
    capsule_projectile(name)
end