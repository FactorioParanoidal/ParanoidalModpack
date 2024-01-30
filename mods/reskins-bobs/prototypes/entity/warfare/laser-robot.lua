-- Copyright (c) 2023 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.warfare.entities) then return end

-- Set input parameters
local inputs = {
    type = "combat-robot",
    icon_filename = reskins.bobs.directory .. "/graphics/icons/warfare/robots/bob-laser-robot.png",
    base_entity_name = "defender-robot",
    mod = "bobs",
    group = "warfare",
    particles = { ["small"] = 3 },
    tint = util.color("7f4eca"),
}

local function robot_animation()
    return
    {
        filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/bob-laser-robot.png",
        width = 32,
        height = 32,
        frame_count = 1,
        direction_count = 1,
        hr_version = {
            filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/hr-bob-laser-robot.png",
            width = 64,
            height = 64,
            frame_count = 1,
            direction_count = 1,
            scale = 0.5
        }
    }
end

local function robot_shadow()
    return
    {
        filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/bob-laser-robot-shadow.png",
        width = 32,
        height = 32,
        frame_count = 1,
        direction_count = 1,
        draw_as_shadow = true,
        hr_version = {
            filename = "__reskins-bobs__/graphics/entity/warfare/laser-robot/hr-bob-laser-robot-shadow.png",
            width = 64,
            height = 64,
            frame_count = 1,
            direction_count = 1,
            draw_as_shadow = true,
            scale = 0.5
        }
    }
end

-- Fetch entity
local name = "bob-laser-robot"
local robot = data.raw["combat-robot"][name]
if not robot then return end

reskins.lib.parse_inputs(inputs)
reskins.lib.create_explosions_and_particles(name, inputs)
reskins.lib.create_remnant(name, { type = inputs.type, base_entity_name = "defender" })
reskins.lib.construct_icon(name, 0, inputs)

-- Fetch remnant
local remnant = data.raw["corpse"][name .. "-remnants"]

-- Reskin remants
remnant.animation = {
    filename = reskins.bobs.directory .. "/graphics/entity/warfare/laser-robot/remnants/laser-robot-remnants.png",
    line_length = 1,
    width = 49,
    height = 47,
    frame_count = 1,
    variation_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    hr_version = {
        filename = reskins.bobs.directory .. "/graphics/entity/warfare/laser-robot/remnants/hr-laser-robot-remnants.png",
        line_length = 1,
        width = 98,
        height = 94,
        frame_count = 1,
        variation_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        scale = 0.5,
    }
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
