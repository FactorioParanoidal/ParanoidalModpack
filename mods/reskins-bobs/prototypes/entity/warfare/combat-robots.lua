-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Setup capsule projectiles
local capsule_projectiles = {
	"bob-laser-robot-capsule",
	"destroyer-capsule",
	"distractor-capsule",
	"defender-capsule",
}

---Reskins capsule projectiles
---@param name string
local function reskin_capsule_projectile(name)
	local projectile = data.raw["projectile"][name]
	if not projectile then
		return
	end

	projectile.animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/capsules/" .. name .. ".png",
		priority = "high",
		flags = { "no-crop" },
		size = 48,
		scale = 0.5,
	}

	projectile.shadow = {
		filename = "__reskins-bobs__/graphics/entity/warfare/capsules/combat-robot-capsule-shadow.png",
		priority = "high",
		flags = { "no-crop" },
		size = 48,
		scale = 0.5,
	}
end

for _, name in pairs(capsule_projectiles) do
	reskin_capsule_projectile(name)
end
