local extend = KuxCoreLib.PrototypeData.extend

local utils = {}
function utils.merge(common, data, final_fixes)
	--print("merge", order_index, common, data, final_fixes)
	local merged = {}
	--merge common-- << extend(common)
	for k,v in pairs(common) do merged[k] = v end

	--merge data-- << x:int(data)
	for k,v in pairs(data) do merged[k] = type(k)~="number" and v or nil end

	--merge final_fixes--
	for k,v in pairs(final_fixes) do merged[k] = v; end

	--clean up--
	merged.prefix = nil

	return merged
end
local isSpaceTravel = feature_flags["space_travel"]
local fx = {common = {}}

--- CreateEntityTriggerEffectItem - 'create-entity'
---@class KuxCoreLib.PrototypeData.Extent.CreateEntityTriggerEffectItem : data.CreateEntityTriggerEffectItem
---@field type string?
---@field entity_name string?
---@field [1] string entity_name
---[View documentation](https://lua-api.factorio.com/latest/types/CreateEntityTriggerEffectItem.html)

--- CreateEntityTriggerEffectItem - 'create-entity' constructor <br>
--- [1] name, [<parameters ...>](https://lua-api.factorio.com/latest/types/CreateEntityTriggerEffectItem.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.CreateEntityTriggerEffectItem
function fx.create_entity(t)
	local d = utils.merge(fx["common"], t, {
		type          = "create-entity",
		entity_name   = t[1]
	})
	return d
end

--- DamageTriggerEffectItem - 'damage'
---@class KuxCoreLib.PrototypeData.Extent.DamageTriggerEffectItem : data.DamageTriggerEffectItem
---@field type string?
---@field entity_name string?
---@field [1] DamageTypeID damage_type
---@field [2] string damage_amount
---[View documentation](https://lua-api.factorio.com/latest/types/DamageTriggerEffectItem.html)

--- DamageTriggerEffectItem - 'damage' constructor <br>
--- [1] damage_type, [2] damage_amount, [<parameters ...>](https://lua-api.factorio.com/latest/types/DamageTriggerEffectItem.html) <br>
---@param t KuxCoreLib.PrototypeData.Extent.DamageTriggerEffectItem
function fx.damage(t)
	local d = utils.merge(fx["common"], t, {
		type          = "damage",
		damage   = {type = t[1], amount = t[2]}
	})
	return d
end


---------------------------------------------------------------------------------------------------
--TODO rename "crosshairs" to "orbital-ion-cannon-projectile"

local function create_projectile(name, radius, damageFactor)
	local explosion_damage, laser_damage, electric_damage = 0, 0, 0
	do
		local explosion1 = settings.startup["ion-cannon-explosion-damage"].value --[[@as double]]
		local laser1     = settings.startup["ion-cannon-laser-damage"].value --[[@as double]]
		local electric1  = settings.startup["ion-cannon-electric-damage"].value --[[@as double]]
		if name == "crosshairs" then
			explosion_damage = explosion1
			laser_damage     = laser1
			electric_damage  = 0
		elseif name == "crosshairs-mk2" then
			local total1 = explosion1 + laser1 + electric1
			-- MK2 Adjust damage values proportionally
			local total2 = (explosion1 + laser1) * damageFactor
			explosion_damage = total2 * (explosion1 / total1)
			laser_damage     = total2 * (laser1 / total1)
			electric_damage  = total2 * (electric1 / total1)
		end
	end

	local heatup_multiplier = settings.startup["ion-cannon-heatup-multiplier"].value --[[@as double]]

	data:extend({
		{
			type = "projectile",
			name = name, -- "crosshairs"
			flags = {"not-on-map"},
			acceleration = .0009 / (heatup_multiplier*heatup_multiplier),
			action = {
				{
					type = "direct",
					action_delivery = {
						type = "instant",
						target_effects = {
							fx.create_entity{"huge-explosion"},
							fx.create_entity{"ion-cannon-beam"},
							fx.create_entity{"enormous-scorchmark",check_buildability = true},
							fx.create_entity{"ion-cannon-explosion", trigger_created_entity = true },
							{ type = "show-explosion-on-chart", scale = radius / 20 },
						}
					}
				},
				{
					type = "area",
					radius = radius * 0.8,
					action_delivery = {
						type = "instant",
						target_effects = {
							{ type = "create-fire", entity_name = "fire-flame" },
							{ type = "create-fire", entity_name = "fire-flame-on-tree" }
						}
					}
				},
				{
					type = "area",
					radius = radius * 0.8,
					action_delivery = {
						type = "instant",
						target_effects = {
							fx.damage{"laser"    , laser_damage },
							fx.damage{"explosion", explosion_damage},
							fx.damage{"electric", electric_damage}
						}
					}
				},
				{
					type = "area",
					radius = radius,
					action_delivery = {
						type = "instant",
						target_effects = {
							{ type = "create-sticker", sticker = "fire-sticker" },
							{ type = "create-fire", entity_name = "fire-flame" },
							{ type = "create-fire", entity_name = "fire-flame-on-tree" }
						}
					}
				}
			},
			light = {intensity = 0, size = 0},
			animation = {
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1
			},
			shadow = {
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1
			}
		},

		{
			type = "projectile",
			name = "dummy-"..name,
			flags = {"not-on-map"},
			acceleration = .0009 / (settings.startup["ion-cannon-heatup-multiplier"].value * settings.startup["ion-cannon-heatup-multiplier"].value),
			action = {
				{
					type = "area",
					radius = radius * 0.8,
					action_delivery = {
						type = "instant",
						target_effects = {
							fx.damage{"laser"    , settings.startup["ion-cannon-laser-damage"].value * damageFactor},
							fx.damage{"explosion", settings.startup["ion-cannon-explosion-damage"].value * damageFactor}
						}
					}
				},
				{
					type = "area",
					radius = radius --[[@as double]],
					action_delivery = {
						type = "instant",
						target_effects = {
							{ type = "create-fire", entity_name = "fire-flame" }
						}
					}
				}
			},
			light = {intensity = 0, size = 0},
			animation = {
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1
			},
			shadow = {
				filename = "__core__/graphics/empty.png",
				priority = "low",
				width = 1,
				height = 1,
				frame_count = 1
			}
		}
	})
end
local radius = settings.startup["ion-cannon-radius"].value --[[@as double]]
create_projectile("crosshairs", radius, 1.0)
if isSpaceTravel then
	create_projectile("crosshairs-mk2", radius *1.5, 10)
end

local x = extend()

--x:sound{"ion-cannon-klaxon", mod.path.."sound/Klaxon.ogg", volume = 1.0}
data:extend{
	{
		type = "sound",
		name = "ion-cannon-klaxon",
		variations = { { filename = mod.path.."sound/Klaxon.ogg", volume = 1.0 }, }
	}
}

local NO_ANIMATION = {
	filename = "__core__/graphics/empty.png",
	priority = "low",
	width = 1,
	height = 1,
	frame_count = 1
}

--WIP
data:extend{{ type = "explosion", name = "ion-cannon-klaxon-build",
	sound = { { filename = mod.path.."sound/Klaxon.ogg", volume = 1.0 } },
	flags = {"not-on-map"},
	animations = {NO_ANIMATION},
}}



data:extend{ { type = "simple-entity", name = "ion-cannon-target",
	icon = mod.path.."graphics/crosshairs64.png",
	icon_size = 64,
	flags = {"placeable-off-grid", "not-on-map"},
	max_health = 1,
	render_layer = "air-object",
	final_render_layer = "air-object",
	collision_box = {{0,0}, {0,0}},
	selection_box = {{0,0}, {0,0}},
	resistances = {},
	animations = { {
		filename = mod.path.."graphics/crosshairs_anim.png",
		priority = "low",
		width = 64,
		height = 64,
		frame_count = 32,
		animation_speed = 0.35,
		line_length = 8,
		shift = {0, -1},
		scale = 1,
	} },
	-- pictures =
	-- {
		-- {
			-- filename = mod.path.."graphics/crosshairsEntity.png",
			-- priority = "low",
			-- width = 64,
			-- height = 64,
			-- scale = 1,
			-- shift = {0, -1},
			-- frame_count = 1
		-- },
	-- }

	-- WIP: audible up to 32 tiles away
	-- working but does not have the expected effect. too quiet in the distance
	-- volume: 50 no effect, max_distance: 50 no effect
	build_sound =  { filename = mod.path.."sound/Klaxon.ogg", volume = 1 }, -- audible up to 10 tiles away, too short
}}

data:extend{
	{
		type = "smoke-with-trigger",
		name = "ion-cannon-explosion",
		flags = {"not-on-map"},
		show_when_smoke_off = true,
		animation = {
			filename = mod.path.."graphics/explosion.png",
			priority = "low",
			width = 192,
			height = 192,
			frame_count = 25,
			animation_speed = 0.2,
			line_length = 5,
			scale = 5 * (radius / 15),
		},
		slow_down_factor = 0,
		affected_by_wind = false,
		cyclic = false,
		duration = 60 * 5,
		spread_duration = 10,
	}
}

data:extend{
	{
		type = "smoke-with-trigger",
		name = "ion-cannon-beam",
		flags = {"not-on-map"},
		show_when_smoke_off = true,
		animation = {
			filename = mod.path.."graphics/IonBeam.png",
			priority = "low",
			width = 110,
			height = 1871,
			frame_count = 1,
			animation_speed = 0.01,
			line_length = 1,
			shift = {-0.1, -27.5},
			scale = 1,
		},
		slow_down_factor = 0,
		affected_by_wind = false,
		cyclic = false,
		duration = 60 * 2,
		fade_away_duration = 60 * 1,
		spread_duration = 10,
	}
}



data:extend{
	{
		type = "explosion",
		name = "huge-explosion",
		flags = {"not-on-map"},
		animations = {
			{
				--filename = "__base__/graphics/entity/medium-explosion/medium-explosion.png", --removed in 2.0.33
				filename = mod.path.."graphics/medium-explosion.png",
				priority = "high",
				width = 112,
				height = 94,
				scale = 0.8,
				frame_count = 54,
				line_length = 6,
				shift = {-0.56, -0.96},
				animation_speed = 0.5
			},
		},
		light = {intensity = 2, size = radius * 3},
		sound = {
			{ filename = mod.path.."sound/OrbitalIonCannon.ogg", volume = 1.4 },
		},
		created_effect = {
			type = "direct",
			action_delivery = {
				type = "instant",
				target_effects = {
					{
						type = "create-particle",
						repeat_count = 60,
						particle_name = "explosion-remnants-particle",
						initial_height = 0.5,
						speed_from_center = 0.15,
						speed_from_center_deviation = 0.15,
						initial_vertical_speed = 0.1,
						initial_vertical_speed_deviation = 0.15,
						offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}}
					}
				}
			}
		}
	}
}


local yuge_crater = util.table.deepcopy(data.raw["corpse"]["big-scorchmark"])
yuge_crater.name = "enormous-scorchmark"
yuge_crater.order = "d[remnants]-b[scorchmark]-b[yuge]"
--[[
yuge_crater.animation = {
	width = yuge_crater.ground_patch.sheet.width,
	height = yuge_crater.ground_patch.sheet.height,
	frame_count = 1,
	direction_count = 1,
	filename = "__base__/graphics/entity/scorchmark/big-scorchmark.png"
}

yuge_crater.animation.filename = "__Kux-OrbitalIonCannon__/graphics/yuge-scorchmark.png"
yuge_crater.animation.width=yuge_crater.animation.width*4
yuge_crater.animation.height=yuge_crater.animation.height*4
]]

yuge_crater.ground_patch.sheet.filename = "__Kux-OrbitalIonCannon__/graphics/yuge-scorchmark.png"
yuge_crater.ground_patch.sheet.width=yuge_crater.ground_patch.sheet.width*4
yuge_crater.ground_patch.sheet.height=yuge_crater.ground_patch.sheet.height*4

yuge_crater.ground_patch_higher.sheet.filename = "__Kux-OrbitalIonCannon__/graphics/yuge-scorchmark-top.png"
yuge_crater.ground_patch_higher.sheet.width=yuge_crater.ground_patch_higher.sheet.width*4
yuge_crater.ground_patch_higher.sheet.height=yuge_crater.ground_patch_higher.sheet.height*4

--yuge_crater.animation.scale = settings.startup["ion-cannon-radius"].value / 16
yuge_crater.ground_patch.sheet.scale = settings.startup["ion-cannon-radius"].value / 16
yuge_crater.ground_patch_higher.sheet.scale = settings.startup["ion-cannon-radius"].value / 16


data:extend({yuge_crater})

if not settings.startup["ion-cannon-flames"].value then
	local function createAction(radiusFactor, damageFactor)
		return {
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value * radiusFactor,
				action_delivery =
				{
					type = "instant",
					target_effects = {
						{ type = "damage", damage = {amount = settings.startup["ion-cannon-laser-damage"].value / 2, type = "laser"} },
						{ type = "damage", damage = {amount = settings.startup["ion-cannon-explosion-damage"].value / 2, type = "explosion"} }
					}
				}
			},
			{
				type = "direct",
				action_delivery =
				{
					type = "instant",
					target_effects = {
						{ type = "create-entity", entity_name = "huge-explosion" },
						{ type = "create-entity", entity_name = "ion-cannon-beam" },
						{ type = "create-entity", entity_name = "enormous-scorchmark", check_buildability = true },
						{ type = "create-entity", entity_name = "ion-cannon-explosion", trigger_created_entity = true }
					}
				}
			},
			{
				type = "area",
				radius = settings.startup["ion-cannon-radius"].value * radiusFactor,
				action_delivery =
				{
					type = "instant",
					target_effects = {
						{ type = "create-fire", entity_name = "fire-flame-on-tree" },
						{ type = "damage", damage = {amount = settings.startup["ion-cannon-laser-damage"].value / 2 * damageFactor, type = "laser"}},
						{ type = "damage", damage = {amount = settings.startup["ion-cannon-explosion-damage"].value / 2 * damageFactor, type = "explosion"}}
					}
				}
			}
		}
	end
	data.raw["projectile"]["crosshairs"].action = createAction(1, 1)
	if isSpaceTravel then
		data.raw["projectile"]["crosshairs"].action = createAction(1.5, 10)
	end
end


