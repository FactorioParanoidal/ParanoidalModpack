local projectileUtils = require("ProjectileUtils")
local makeProjectile = projectileUtils.makeProjectile

local spawnUtils = {}

-- + !КДА 2021.11
-- function droneUtils.createSpawnProjectile(attributes, entityName)
    -- local n = "spawn" .. entityName .. "-projectile-rampant"
	-- data:extend({{
		-- type = "projectile",
		-- name = n,
		-- flags = {"not-on-map"},
		-- collision_box = {{-0.025, -0.025}, {0.025, 0.025}},
		-- collision_mask = {"layer-13"},
		-- direction_only = false,
		-- piercing_damage = 0,
		-- acceleration = 0.000001,
		-- max_speed = 0.7,
		-- force_condition = "not-same",
		-- action = attack,
		-- animation =
			-- {
				-- filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
				-- line_length = 5,
				-- width = 22,
				-- height = 84,
				-- frame_count = 15,
				-- shift = util.mul_shift(util.by_pixel(-2, 30), 1),
-- --                        tint = attributes.tint2,
				-- priority = "high",
				-- scale = 1,
				-- animation_speed = 1,
				-- hr_version =
					-- {
						-- filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
						-- line_length = 5,
						-- width = 42,
						-- height = 164,
						-- frame_count = 15,
						-- shift = util.mul_shift(util.by_pixel(-2, 31), 1),
						-- tint = attributes.tint2,
						-- priority = "high",
						-- scale = 1,
						-- animation_speed = 1,
					-- }
			-- },
		-- shadow =
			-- {
				-- filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
				-- line_length = 15,
				-- width = 22,
				-- height = 84,
				-- frame_count = 15,
				-- priority = "high",
				-- shift = util.mul_shift(util.by_pixel(-2, 30), 1),
				-- draw_as_shadow = true,
				-- scale = 1,
				-- animation_speed = 1,
				-- hr_version =
					-- {
						-- filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
						-- line_length = 15,
						-- width = 42,
						-- height = 164,
						-- frame_count = 15,
						-- shift = util.mul_shift(util.by_pixel(-2, 31), 1),
						-- draw_as_shadow = true,
						-- priority = "high",
						-- scale = 0.5,
						-- animation_speed = 1,
					-- }
			-- },
		-- -- rotatable = false,
		-- oriented_particle = true,
		-- shadow_scale_enabled = true,

    -- }})
    -- return n
-- end

local function makeClusterSpawnProjectile(entityName)
    local name = "clusterSpawnProjectile_"..entityName .. "-rampant"
    data:extend({{
	---------------
                type = "projectile",
				name = name,
                flags = {"not-on-map"},
                collision_box = {{-0.025, -0.025}, {0.025, 0.025}},
                --direction_only = attributes.attackDirectionOnly,
                piercing_damage = 0,
                acceleration = 0.000001,
                max_speed = 1,
                force_condition = "not-same",
                action =
                    {
                        type = "direct",
                        action_delivery =
                            {
                                type = "instant",
                                target_effects ={{type = "create-entity", entity_name = entityName, show_in_tooltip = true}}
                            }
                    },
				animation =
                    {
                        filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
                        line_length = 5,
                        width = 22,
                        height = 84,
                        frame_count = 15,
                        shift = util.mul_shift(util.by_pixel(-2, 30), 0.1),
                        tint = {r = 0, g = 0, b = 0},
                        priority = "high",
                        scale = 0.1,
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
                                line_length = 5,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), 0.1 ),
                                tint = {r = 0, g = 0, b = 0},
                                priority = "high",
                                scale = 0.5 * 0.1 ,
                                animation_speed = 1,
                            }
                    },
                shadow =
                    {
                        filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
                        line_length = 15,
                        width = 22,
                        height = 84,
                        frame_count = 15,
                        priority = "high",
                        shift = util.mul_shift(util.by_pixel(-2, 30), 0.1),
                        draw_as_shadow = true,
                        scale = 0.1,
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
                                line_length = 15,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), 0.1),
                                draw_as_shadow = true,
                                priority = "high",
                                scale = 0.5 * 0.1,
                                animation_speed = 1,
                            }
                    },
    }})
    return name
end

local function makeSpawnClusterTargetEffects(entityName, spawnCounts)
	local targetEffects = {}
	target_effects = {{
		type="nested-result",
		repeat_count = spawnCounts,
		action = {
			{
				type = "cluster",
				cluster_count = 10,	-- ?
				distance = 3,
				distance_deviation = 3,
				action_delivery =
					{
						type = "instant",
						{{type = "create-entity",
							show_in_tooltip = true,
							entity_name = entityName,
							check_buildability = true
							}}
						--type = "projectile", {{
						-- projectile = makeClusterSpawnProjectile(entityName),
						-- duration = 20,
						-- direction_deviation = 0.6,
						-- starting_speed = 2,
						-- starting_speed_deviation = 0.3
					}
			}
		}
	}}
	
end

--function createSpawnAttack(attributes, spawnBall, animation)	
	 
        -- type = "projectile",
        -- ammo_category = "biological",
        -- range_mode = "bounding-box-to-bounding-box",
        -- cooldown = attributes.cooldown or 15,
        -- warmup = attributes.warmup,
        -- cooldown_deviation = 0.15,
        -- projectile_creation_distance = 0.6,
        -- range = attributes.range or 4,
        -- min_attack_distance = (attributes.range and (attributes.range - 2)) or 4,
        -- lead_target_for_projectile_speed = 0.95,	
        -- use_shooter_direction = true,
        -- ammo_type =
            -- {
                -- category = "biological",
                -- clamp_position = true,
                -- target_type = "position",
                -- action ={type = "direct",
					-- action_delivery = function (attributes)
					-- local returnValue
					-- local spawnLvl = attributes.effectiveLevel+template.spawnStep
					-- if spawnLvl < 1 then
						-- spawnLvl = 1
					-- elseif spawnLvl>10 then	
						-- spawnLvl = 10
					-- end	
					-- --if template.spawnCounts == 1 then
						-- returnValue = {type = "instant", target_effects = {}}
						-- local target_effects = returnValue["target_effects"]
						-- target_effects[1] = {
							-- type = "create-entity",
							-- show_in_tooltip = true,
							-- --trigger_created_entity = attributes.triggerCreated,
							-- entity_name = attributes.SpawnOnHit_1sPart .. "-v" ..attributes.variation .. "-t" ..spawnLvl.. "" .. "-rampant",	--(attributes.effectiveLevel-attributes.effectiveLevelDecrease)
							-- check_buildability = true
							-- }
					-- --end
					-- -------------
					
-- --					{type = "projectile",
-- --						projectile = projectile or "defender-bullet",
-- --						starting_speed = attributes.startingSpeed or 0.6,	
-- --						max_range = attributes.maxRange or (attributes.range + 1) or 4
-- --						}
                    -- }
            -- },
        -- animation = animation
    -- }








-- -----------
               -- return
                    -- {
                        -- {
                            -- type="nested-result",
                            -- action = {
                                -- {
                                    -- type = "cluster",
                                    -- cluster_count = attributes.clusters,
                                    -- distance = attributes.clusterDistance,
                                    -- distance_deviation = 3,
                                    -- action_delivery =
                                        -- {
                                            -- type = "projectile",
                                            -- projectile = makeLaser(attributes),
                                            -- duration = 20,
                                            -- direction_deviation = 0.6,
                                            -- starting_speed = attributes.startingSpeed,
                                            -- starting_speed_deviation = 0.3
                                        -- },
                                    -- repeat_count = 2
                                -- }
                            -- }
                        -- }
                    -- }
	
-- end

function spawnUtils.createSpawnBall(attributes, entityName, spawnCounts)
    local templateArea = {
        type = "area",
        radius = 2,
        force = "not-same",
        ignore_collision_condition = true,
    }

    local target_effects
		target_effects = {{type = "create-entity",
			show_in_tooltip = true,
			entity_name = entityName,
			repeat_count = spawnCounts,
			check_buildability = false
			}}
	
    local templateActions = {
        templateArea,
        {
            type = "direct",
            action_delivery = {
                type = "instant",
				source_effects = attributes.sourceEffect and attributes.sourceEffect(attributes),
				target_effects = target_effects
            }
        }
    }

    local name
    name = makeProjectile(attributes, templateActions)

    return name
end

return spawnUtils