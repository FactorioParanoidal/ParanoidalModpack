-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.items) then
	return
end

---@type CreateIconsFromListInputs
local inputs = {
	mod = "bobs",
	group = "warfare",
	make_icon_pictures = false,
	flat_icon = true,
}

local plasma_tint = util.color("#1280b2")
local uranium_tint = util.color("#12b222")

---@param subgroup string
---@param light_name? LightSpriteNames
---@param tint? data.Color
---@return CreateIconsFromListOverrides
local function get_item_overrides(subgroup, light_name, tint)
	---@type CreateIconsFromListOverrides
	local override = {
		subgroup = subgroup,
	}

	if light_name then
		override.icon_picture_extras = { reskins.lib.sprites.get_sprite_light_layer(light_name, tint) }
		override.make_icon_pictures = true
	end

	return override
end

---@param subgroup string
---@param light_name? LightSpriteNames
---@param tint? data.Color
---@return CreateIconsFromListOverrides
local function get_ammo_overrides(subgroup, light_name, tint)
	local override = get_item_overrides(subgroup, light_name, tint)
	override.type = "ammo"

	return override
end

---@type CreateIconsFromListTable
local items = {
	-- Robot tools
	["bob-robot-tool-combat"] = { tier = 1, prog_tier = 2, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true },
	["bob-robot-tool-combat-2"] = { tier = 2, prog_tier = 3, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true },
	["bob-robot-tool-combat-3"] = { tier = 3, prog_tier = 4, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true },
	["bob-robot-tool-combat-4"] = { tier = 4, prog_tier = 5, icon_name = "robot-tool-combat", flat_icon = false, make_icon_pictures = true },

	-- Bullets
	["bob-bullet"] = get_item_overrides("bullets"),
	["bob-acid-bullet"] = get_item_overrides("bullets"),
	["bob-ap-bullet"] = get_item_overrides("bullets"),
	["bob-electric-bullet"] = get_item_overrides("bullets", "electric-bullet"),
	["bob-flame-bullet"] = get_item_overrides("bullets"),
	["bob-he-bullet"] = get_item_overrides("bullets"),
	["bob-plasma-bullet"] = get_item_overrides("bullets", "aura-bullet", plasma_tint),
	["bob-poison-bullet"] = get_item_overrides("bullets"),
	["bob-uranium-bullet"] = get_item_overrides("bullets", "aura-bullet", uranium_tint),

	-- Projectiles
	["bob-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-acid-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-ap-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-electric-bullet-projectile"] = get_item_overrides("projectiles", "electric-projectile"),
	["bob-flame-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-he-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-plasma-bullet-projectile"] = get_item_overrides("projectiles", "aura-projectile", plasma_tint),
	["bob-poison-bullet-projectile"] = get_item_overrides("projectiles"),
	["bob-uranium-bullet-projectile"] = get_item_overrides("projectiles", "aura-projectile", uranium_tint),

	-- Magazines
	["bob-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-acid-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-ap-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-electric-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-flame-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-he-bullet-magazine"] = get_ammo_overrides("magazines"),
	["bob-plasma-bullet-magazine"] = get_ammo_overrides("magazines", "rounds-magazine"),
	["bob-poison-bullet-magazine"] = get_ammo_overrides("magazines"),
	["uranium-rounds-magazine"] = get_ammo_overrides("magazines", "rounds-magazine"),

	-- Warheads
	["bob-rocket-warhead"] = get_item_overrides("warheads"),
	["bob-acid-rocket-warhead"] = get_item_overrides("warheads"),
	["bob-piercing-rocket-warhead"] = get_item_overrides("warheads"),
	["bob-electric-rocket-warhead"] = get_item_overrides("warheads", "electric-warhead"),
	["bob-explosive-rocket-warhead"] = get_item_overrides("warheads"),
	["bob-flame-rocket-warhead"] = get_item_overrides("warheads"),
	["bob-plasma-rocket-warhead"] = get_item_overrides("warheads", "aura-warhead", plasma_tint),
	["bob-poison-rocket-warhead"] = get_item_overrides("warheads"),

	-- Rockets
	["bob-rocket"] = get_ammo_overrides("rockets"),
	["bob-acid-rocket"] = get_ammo_overrides("rockets"),
	["bob-piercing-rocket"] = get_ammo_overrides("rockets"),
	["bob-electric-rocket"] = get_ammo_overrides("rockets", "electric-rocket"),
	["bob-flame-rocket"] = get_ammo_overrides("rockets"),
	["bob-explosive-rocket"] = get_ammo_overrides("rockets"),
	["bob-plasma-rocket"] = get_ammo_overrides("rockets", "aura-rocket", plasma_tint),
	["bob-poison-rocket"] = get_ammo_overrides("rockets"),

	-- Shotgun Shells
	["bob-better-shotgun-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-acid-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-ap-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-electric-shell"] = get_ammo_overrides("shells", "electric-shotgun-shell"),
	["bob-shotgun-explosive-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-flame-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-plasma-shell"] = get_ammo_overrides("shells", "aura-shotgun-shell", plasma_tint),
	["bob-shotgun-poison-shell"] = get_ammo_overrides("shells"),
	["bob-shotgun-uranium-shell"] = get_ammo_overrides("shells", "aura-shotgun-shell", uranium_tint),

	-- Laser rifle batteries
	["bob-laser-rifle-battery"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#b3b3b3")),
	["bob-laser-rifle-battery-ruby"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#fa1928")),
	["bob-laser-rifle-battery-sapphire"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#0033ff")),
	["bob-laser-rifle-battery-emerald"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#13e35c")),
	["bob-laser-rifle-battery-amethyst"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#d414ff")),
	["bob-laser-rifle-battery-topaz"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#f0b414")),
	["bob-laser-rifle-battery-diamond"] = get_ammo_overrides("laser-rifle-batteries", "laser-rifle-battery", util.color("#ffffff")),

	-- Artillery shells
	["bob-atomic-artillery-shell"] = get_ammo_overrides("artillery-shells", "atomic-artillery-shell", uranium_tint),
	["bob-distractor-artillery-shell"] = get_ammo_overrides("artillery-shells"),
	["bob-explosive-artillery-shell"] = get_ammo_overrides("artillery-shells"),
	["bob-fire-artillery-shell"] = get_ammo_overrides("artillery-shells"),
	["bob-poison-artillery-shell"] = get_ammo_overrides("artillery-shells"),

	-- Cannon shells
	["bob-scatter-cannon-shell"] = get_ammo_overrides("cannon-shells"),

	-- Mines
	["bob-distractor-mine"] = { subgroup = "mines" },
	["bob-poison-mine"] = { subgroup = "mines" },
	["bob-slowdown-mine"] = { subgroup = "mines" },

	-- Components
	["bob-laser-rifle-battery-case"] = { subgroup = "components" },
	["bob-bullet-casing"] = { subgroup = "components" },
	["bob-magazine"] = { subgroup = "components" },
	["bob-cordite"] = { subgroup = "components" },
	["bob-rocket-engine"] = { subgroup = "components" },
	-- ["rocket-body"] = {subgroup = "components"},
	["bob-petroleum-jelly"] = { subgroup = "components" },
	["bob-shot"] = { subgroup = "components/shot" },
	["bob-shotgun-shell-casing"] = { subgroup = "components" },

	-- Weapons
	["bob-laser-rifle"] = { type = "gun", subgroup = "weapons" },
	["bob-rifle"] = { type = "gun", subgroup = "weapons" },
	["bob-sniper-rifle"] = { type = "gun", subgroup = "weapons" },
	["bob-spidertron-gatling-gun"] = { type = "gun", subgroup = "weapons" },
	["bob-spidertron-cannon"] = { type = "item", subgroup = "weapons" },
	["bob-spidertron-cannon-1"] = { type = "gun", image = "bob-spidertron-cannon", subgroup = "weapons" },
	["bob-spidertron-cannon-2"] = { type = "gun", image = "bob-spidertron-cannon", subgroup = "weapons" },

	-- Armor
	-- ["heavy-armor-2"] = { type = "armor", subgroup = "armor" },
	-- ["heavy-armor-3"] = { type = "armor", subgroup = "armor" },
	["bob-power-armor-mk3"] = { type = "armor", subgroup = "armor" },
	["bob-power-armor-mk4"] = { type = "armor", subgroup = "armor" },
	["bob-power-armor-mk5"] = { type = "armor", subgroup = "armor" },

	-- Robots
	["bob-defender-robot"] = { icon_filename = "__base__/graphics/icons/defender.png" },
	["bob-distractor-robot"] = { icon_filename = "__base__/graphics/icons/distractor.png" },
	["bob-destroyer-robot"] = { icon_filename = "__base__/graphics/icons/destroyer.png" },
	["bob-laser-robot"] = { type = "item", subgroup = "robots" },

	-- Capsules
	["bob-fire-capsule"] = { type = "capsule", subgroup = "capsules" },
	["defender-capsule"] = { type = "capsule", subgroup = "capsules" },
	["distractor-capsule"] = { type = "capsule", subgroup = "capsules" },
	["destroyer-capsule"] = { type = "capsule", subgroup = "capsules" },
	["bob-laser-robot-capsule"] = { type = "capsule", subgroup = "capsules" },

	-- Drone tank
	["bob-robot-drone-frame"] = { type = "item", subgroup = "drone" },
	["bob-robot-drone-frame-large"] = { type = "item", subgroup = "drone" },

	-- Mech parts
	["bob-mech-armor-plate"] = { type = "item", subgroup = "mech-parts" },
	-- TODO: https://github.com/kirazy/reskins-bobs/issues/32 Model and render out robot/mech brains
	-- ["mech-brain"] = {type = "item", subgroup = "mech-parts"},
	["bob-mech-frame"] = { type = "item", subgroup = "mech-parts" },
	["bob-mech-foot"] = { type = "item", subgroup = "mech-parts" },
	["bob-mech-hip"] = { type = "item", subgroup = "mech-parts" },
	["bob-mech-knee"] = { type = "item", subgroup = "mech-parts" },
	["bob-mech-leg"] = { type = "item", subgroup = "mech-parts" },
	["bob-mech-leg-segment"] = { type = "item", subgroup = "mech-parts" },
}

reskins.internal.create_icons_from_list(items, inputs)

-- Handle shot variations
local shot_item = data.raw.item["shot"]

if shot_item then
	shot_item.pictures = reskins.internal.create_sprite_variations("bobs", "warfare/components", "shot", 5)
end
