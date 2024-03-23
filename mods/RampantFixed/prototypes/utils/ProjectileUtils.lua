local projectileUtils = {}

function projectileUtils.makeClusterProjectile(attributes, attack)
   local n = attributes.name .. "-clusterProjectile-rampant"
	local speedModifier = 0.75
	local scaleModifier = 1.5
    local n = attributes.name .. "-projectile-rampant"

    data:extend({{
                type = "projectile",
                name = n,
                flags = {"not-on-map"},
                collision_box = attributes.attackCollisionBox or {{-0.025, -0.025}, {0.025, 0.025}},
                collision_mask = attributes.attackCollisionMask,
                direction_only = attributes.attackDirectionOnly,
                piercing_damage = attributes.attackPiercingDamage or 0,
                acceleration = attributes.attackAcceleration or 0.000001,
                max_speed = math.min(math.max(attributes.scale*0.60, 0.4), 0.7),
                force_condition = (settings.startup["rampantFixed--disableCollidingProjectiles"].value and "not-same") or nil,
                action = attack,
				light = {intensity = 1, size = 10, color = {r = 1.0, g = 0.0, b = 0.0}},		--attributes.tint2 or 
                animation =
                    {
                        filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
                        line_length = 5,
                        width = 22,
                        height = 84,
                        frame_count = 15,
                        shift = util.mul_shift(util.by_pixel(-2, 30), attributes.scale*1.2 or 1),
                        tint = attributes.tint2,
                        priority = "high",
                        scale = (attributes.scale*1.2 or 1)*scaleModifier,
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
                                line_length = 5,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), attributes.scale*1.2 or 1),
                                tint = attributes.tint2,
                                priority = "high",
                                scale = 0.5 * (attributes.scale*1.2 or 1),
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
                        shift = util.mul_shift(util.by_pixel(-2, 30), attributes.scale*1.2 or 1),
                        draw_as_shadow = true,
                        scale = (attributes.scale*1.2 or 1),
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
                                line_length = 15,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), attributes.scale*1.2 or 1),
                                draw_as_shadow = true,
                                priority = "high",
                                scale = 0.5 * (attributes.scale*1.2 or 1),
                                animation_speed = 1,
                            }
                    },
                -- rotatable = false,
                oriented_particle = true,
                shadow_scale_enabled = true,

    }})

    return n
end

function projectileUtils.makeProjectile(attributes, attack, animation, shadow)
    local n = attributes.name .. "-projectile-rampant"
	local projectile = {
                type = "projectile",
                name = n,
                flags = {"not-on-map"},
                collision_box = attributes.attackCollisionBox or {{-0.025, -0.025}, {0.025, 0.025}},
                collision_mask = attributes.attackCollisionMask,
                direction_only = attributes.attackDirectionOnly,
                piercing_damage = attributes.attackPiercingDamage or 0,
                acceleration = attributes.attackAcceleration or 0.000001,
                max_speed = math.min(math.max(attributes.scale*0.60, 0.4), 0.7),
                force_condition = (settings.startup["rampantFixed--disableCollidingProjectiles"].value and "not-same") or nil,
                action = attack,
                animation = animation or
                    {
                        filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
                        line_length = 5,
                        width = 22,
                        height = 84,
                        frame_count = 15,
                        shift = util.mul_shift(util.by_pixel(-2, 30), attributes.scale*1.2 or 1),
                        tint = attributes.tint2,
                        priority = "high",
                        scale = (attributes.scale*1.2 or 1),
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-head.png",
                                line_length = 5,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), attributes.scale*1.2 or 1),
                                tint = attributes.tint2,
                                priority = "high",
                                scale = 0.5 * (attributes.scale*1.2 or 1),
                                animation_speed = 1,
                            }
                    },
                shadow = shadow or
                    {
                        filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
                        line_length = 15,
                        width = 22,
                        height = 84,
                        frame_count = 15,
                        priority = "high",
                        shift = util.mul_shift(util.by_pixel(-2, 30), attributes.scale*1.2 or 1),
                        draw_as_shadow = true,
                        scale = (attributes.scale*1.2 or 1),
                        animation_speed = 1,
                        hr_version =
                            {
                                filename = "__base__/graphics/entity/acid-projectile/hr-acid-projectile-shadow.png",
                                line_length = 15,
                                width = 42,
                                height = 164,
                                frame_count = 15,
                                shift = util.mul_shift(util.by_pixel(-2, 31), attributes.scale*1.2 or 1),
                                draw_as_shadow = true,
                                priority = "high",
                                scale = 0.5 * (attributes.scale*1.2 or 1),
                                animation_speed = 1,
                            }
                    },
                -- rotatable = false,
                oriented_particle = true,
                shadow_scale_enabled = true,

    }
	if animation then
		projectile.animation.scale = 0.1 + (attributes.scale or 1)*0.5
		projectile.animation.tint = {r = attributes.tint2.r, g = attributes.tint2.g, b=attributes.tint2.b, a=0.05}		
	end
	if shadow then
		projectile.shadow.scale = 0.1 + (attributes.scale or 1)*0.5
	end
    data:extend({projectile})

    return n
end
 
return projectileUtils
