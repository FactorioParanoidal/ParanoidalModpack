local projectileUtils = {}

local animation_default = {}
animation_default.animation =
{
  filename = "__base__/graphics/entity/acid-projectile/acid-projectile-head.png",
  line_length = 5,
  width = 42,
  height = 164,
  frame_count = 15,
  -- shift = util.mul_shift(util.by_pixel(-2, 31), 0.25 + 0.25 * attributes.scale),
  -- tint = attributes.tint2,
  -- scale = 0.2 + 0.2 * attributes.scale,
  priority = "high",
  animation_speed = 1
}
animation_default.shadow =
{
  filename = "__base__/graphics/entity/acid-projectile/acid-projectile-shadow.png",
  line_length = 15,
  width = 42,
  height = 164,
  frame_count = 15,
  -- shift = util.mul_shift(util.by_pixel(-2, 31), 0.25 + 0.25 * attributes.scale),
  -- scale = 0.2 + 0.2 * attributes.scale,
  draw_as_shadow = true,
  priority = "high",
  animation_speed = 1
}

function projectileUtils.makeClusterProjectile(attributes, attack)
   local n = attributes.name .. "-clusterProjectile-rampant"
	local speedModifier = 0.75
	local scaleModifier = 1.5
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
		light = {intensity = 1, size = 10, color = {r = 1.0, g = 0.0, b = 0.0}},		--attributes.tint2 or 
		animation = util.table.deepcopy(animation_default.animation),
		shadow = util.table.deepcopy(animation_default.shadow),
	   -- rotatable = false,
		oriented_particle = true,
		shadow_scale_enabled = true,
	}
	projectile.animation.tint = attributes.tint2
	projectile.animation.shift = util.mul_shift(util.by_pixel(-2, 31), (0.2 + 0.15 * attributes.scale) * scaleModifier)
	projectile.animation.scale = (0.1 + 0.1 * attributes.scale) * scaleModifier
 	
	projectile.shadow.shift = util.mul_shift(util.by_pixel(-2, 31), (0.2 + 0.15 * attributes.scale) * scaleModifier)
	projectile.shadow.scale = (0.1 + 0.1 * attributes.scale) * scaleModifier	
	
    data:extend({projectile})

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
                animation = animation or util.table.deepcopy(animation_default.animation),
                shadow = shadow or util.table.deepcopy(animation_default.shadow),
                -- rotatable = false,
                oriented_particle = true,
                shadow_scale_enabled = true,

    }

	projectile.animation.tint = attributes.tint2
	projectile.animation.shift = util.mul_shift(util.by_pixel(-2, 31), (0.2 + 0.15 * attributes.scale))
	projectile.animation.scale = (0.1 + 0.1 * attributes.scale)
 	
	projectile.shadow.shift = util.mul_shift(util.by_pixel(-2, 31), (0.2 + 0.15 * attributes.scale))
	projectile.shadow.scale = (0.1 + 0.1 * attributes.scale)	

    data:extend({projectile})

    return n
end
 
return projectileUtils
