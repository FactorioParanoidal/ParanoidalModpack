local util = require ("util")

local droneUtils = {}

function droneUtils.makeDrone(attributes)
    local n = attributes.name .. "-drone-rampant"
    local resistances = {}
    for k,v in pairs(attributes.resistances) do
        v.type = k
        resistances[#resistances+1] = v
    end
    -- attributes.name = name
	local scale = attributes.scale	-- 0.5 or 
    local drone = {
        type = "combat-robot",
        name = n,
		localised_name = {
            "",
            {"rampant."..attributes.faction},
            {"rampant."..attributes.unitName},
            {"rampant.t"..attributes.tier}
        },
        icon = "__base__/graphics/icons/defender.png",
        icon_size = 32,
        flags = {"placeable-off-grid", "not-on-map", "not-repairable", "breaths-air"},	--, "hidden"
        subgroup="capsule",
        order="e-a-a",
        max_health = attributes.health or 60,
        healing_per_tick = attributes.healing,
        alert_when_damaged = false,
        resistances = resistances,
        collision_box = {{0, 0}, {0, 0}},
        selection_box = {{-0.5, -1.5}, {0.5, -0.5}},
        distance_per_frame = attributes.distancePerFrame or 0,
        time_to_live = attributes.ttl or (60 * 45),
        follows_player = attributes.followsPlayer,
        friction = attributes.friction or 0.01,
        range_from_player = attributes.rangeFromPlayer or 6.0,
        speed = attributes.movement or 0,
        destroy_action = attributes.death,
        attack_parameters = attributes.attack,
        idle =
            {
                layers =
                    {
                        {
                                filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
                                priority = "high",
                                line_length = 16,
                                width = 56,
                                height = 59,
                                tint = attributes.tint2,
                                frame_count = 1,
                                direction_count = 16,
                                shift = util.by_pixel(0, 0.25),
                                scale = scale * 0.5
                            },
                        {
                                filename = "__base__/graphics/entity/defender-robot/defender-robot-mask.png",
                                priority = "high",
                                line_length = 16,
                                width = 28,
                                height = 21,
                                tint = attributes.tint2,
                                frame_count = 1,
                                direction_count = 16,
                                shift = util.by_pixel(0, -4.75),
                                -- apply_runtime_tint = true,
                                scale = scale * 0.5
                            },
                    }
            },
        shadow_idle =
            {
                    filename = "__base__/graphics/entity/defender-robot/defender-robot-shadow.png",
                    priority = "high",
                    line_length = 16,
                    width = 88,
                    height = 50,
                    frame_count = 1,
                    direction_count = 16,
                    shift = util.by_pixel(25.5, 19),
                    scale = scale * 0.5
                },
        in_motion =
            {
                layers =
                    {
                        {
                                filename = "__base__/graphics/entity/defender-robot/defender-robot.png",
                                priority = "high",
                                line_length = 16,
                                width = 56,
                                tint = attributes.tint,
                                height = 59,
                                frame_count = 1,
                                direction_count = 16,
                                shift = util.by_pixel(0, 0.25),
                                y = 59,
                                scale = scale * 0.5
                            },
                        {
                                filename = "__base__/graphics/entity/defender-robot/defender-robot-mask.png",
                                priority = "high",
                                line_length = 16,
                                width = 28,
                                height = 21,
                                frame_count = 1,
                                direction_count = 16,
                                tint = attributes.tint2,
                                shift = util.by_pixel(0, -4.75),
                                y = 21,
                                scale = scale * 0.5
                            },
                    }
            },
        shadow_in_motion =
            {
                    filename = "__base__/graphics/entity/defender-robot/defender-robot-shadow.png",
                    priority = "high",
                    line_length = 16,
                    width = 88,
                    height = 50,
                    frame_count = 1,
                    direction_count = 16,
                    shift = util.by_pixel(25.5, 19),
                    scale = scale * 0.5
                }
    }
	
	if attributes.additionalFlags then
		for i = 1, #attributes.additionalFlags do
			drone.flags[#drone.flags+1] = attributes.additionalFlags[i]
		end
	end
	
	drone.collision_mask =  {layers={trigger_target=true}, not_colliding_with_itself=true}
	drone.collision_box = {{0, 0}, {0, 0}}
	-- Paranoidal: every wasp and egg had the same defender icon, cut to its upper left quarter (icon_size 32 of a 64 px
	-- icon). The full icon in the colour of the sprite with the tier number (as on the units) tells them apart in the
	-- entity lists (turret priority targets); eggs (egg, worm-egg) show the defender capsule, the drones of worms
	-- (worm-wasp, worm-egg) a small worm in the lower left corner.
	local unitName = attributes.unitName or ""
	drone.icon = string.find(unitName, "egg", 1, true) and "__base__/graphics/icons/defender-capsule.png"
		or "__base__/graphics/icons/defender.png"
	drone.icon_size = 64
	drone.icons = {
		{icon = drone.icon, icon_size = 64, tint = attributes.tint2},
		{icon = "__RampantFixed__/graphics/icons/signal/signal_" .. ((attributes.tier < 10) and attributes.tier or "A") .. ".png",
			tint = attributes.labelTint, scale = 0.25, icon_size = 64, shift = {5, -10}}
	}
	if string.sub(unitName, 1, 5) == "worm-" then
		drone.icons[3] = {icon = "__base__/graphics/icons/small-worm.png", icon_size = 64, scale = 0.2, shift = {-9, 9}}
	end
    return drone
end

function droneUtils.createCapsuleProjectile(attributes, entityName)
    local n = attributes.name .. "-capsule-rampant"

    local actions = {
        {
            type = "direct",
            force = "not-same",
            action_delivery =
                {
                    type = "instant",
                    source_effects = attributes.sourceEffect and attributes.sourceEffect(attributes),
                    target_effects =
                        {
                            {
                                type = "create-entity",
                                show_in_tooltip = true,
                                trigger_created_entity = attributes.triggerCreated,
                                entity_name = entityName,
                                check_buildability = attributes.checkBuildability
                            },
                            {
                                type = "damage",
								force = "not-same",
                                damage = {amount = attributes.damage or 5, type = attributes.damageType or "physical"}
                            }
                        }
                }
        }
    }

    -- if attributes.sourceEffect then
    -- 	actions[#actions+1] = attributes.sourceEffect(attributes)
    -- end
	local acceleration = attributes.acceleration or 0.01
 	acceleration = acceleration * ((attributes.attackModifiers and attributes.attackModifiers.accelerationModifier) or 1)
	

    local cap = {
        type = "projectile",
        name = n,
        flags = {"not-on-map"},
        collision_box = attributes.collisionBox or {{-0.01, -0.01}, {0.01, 0.01}},
        collision_mask = attributes.collisionMask,
        direction_only = attributes.attackDirectionOnly,
        piercing_damage = attributes.piercingDamage or 0,
        force_condition = "not-same",
        acceleration = acceleration,
        action = actions,
        light = {intensity = 0.5, size = 4},
        enable_drawing_with_mask = true,
        animation = {
            layers = {
                {
                    filename = "__base__/graphics/entity/combat-robot-capsule/defender-capsule.png",
                    flags = { "no-crop" },
                    frame_count = 1,
                    width = 28,
                    height = 20,
                    tint = attributes.tint2,
                    scale = attributes.scale,
                    priority = "high"
                },
                {
                    filename = "__base__/graphics/entity/combat-robot-capsule/defender-capsule-mask.png",
                    flags = { "no-crop" },
                    frame_count = 1,
                    width = 28,
                    height = 20,
                    tint = attributes.tint2,
                    scale = attributes.scale,
                    priority = "high",
                },
            },
        },
        shadow =
            {
                filename = "__base__/graphics/entity/combat-robot-capsule/defender-capsule-shadow.png",
                flags = { "no-crop" },
                frame_count = 1,
                width = 26,
                height = 20,
                scale = attributes.scale,
                priority = "high"
            },
        smoke = {
            {
                name = "the-soft-smoke-rampant",
                deviation = {0.15, 0.15},
                frequency = 1,
                position = {0, 0},
                starting_frame = 3,
                starting_frame_deviation = 5,
                starting_frame_speed_deviation = 5
            }
        }
    }
	
	if attributes.additionalFlags then
		for i = 1, #attributes.additionalFlags do
			cap.flags[#cap.flags+1] = attributes.additionalFlags[i]
		end
	end

    data:extend({cap})
    return n
end

return droneUtils
