-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "combat-robot",
	icon_filename = "__reskins-bobs__/graphics/icons/warfare/robots/bob-laser-robot.png",
	base_entity_name = "defender-robot",
	mod = "bobs",
	group = "warfare",
	particles = { ["small"] = 3 },
	tint = util.color("#7f4eca"),
}

---@return data.RotatedAnimation
local function robot_animation()
	---@type data.RotatedAnimation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/bob-laser-robot.png",
		width = 64,
		height = 64,
		scale = 0.5,
	}

	return animation
end

---@return data.RotatedAnimation
local function robot_shadow()
	---@type data.RotatedAnimation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/bob-laser-robot-shadow.png",
		width = 64,
		height = 64,
		draw_as_shadow = true,
		scale = 0.5,
	}

	return animation
end

local name = "bob-laser-robot"

local robot = data.raw["combat-robot"][name]
if not robot then
	return
end

reskins.lib.set_inputs_defaults(inputs)
reskins.lib.create_explosions_and_particles(name, inputs)
reskins.lib.create_remnant(name, { type = inputs.type, base_entity_name = "defender" })
reskins.lib.construct_icon(name, 0, inputs)

-- Fetch remnant
local remnant = data.raw["corpse"][name .. "-remnants"]

-- Reskin remants
remnant.animation = {
	filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/remnants/laser-robot-remnants.png",
	width = 98,
	height = 94,
	scale = 0.5,
}

-- Remnants are generated indirectly
robot.corpse = nil

-- Reskin entity
robot.idle = robot_animation()
robot.in_motion = robot_animation()
robot.shadow_idle = robot_shadow()
robot.shadow_in_motion = robot_shadow()

-- Setup destruction animation
reskins.bobs.make_robot_particle(robot)
