-- Launch failure effects created by control.lua.
-- re2-rocket-blast: the "big explosion" outcome (the nuclear one is the vanilla atomic-rocket).
-- re2-rocket-debris-N: burning pieces of the rocket thrown around the silo; they land on whatever is
-- there, explode and start a ground fire (put out by the fire safety turrets of zzzparanoidal).
local wreck = "__base__/graphics/entity/crash-site-spaceship/spaceship-wreck-small-"

local chart_picture = {
	filename = "__base__/graphics/entity/artillery-projectile/artillery-shoot-map-visualization.png",
	flags = {"icon"},
	width = 64,
	height = 64,
	priority = "high",
	scale = 0.25,
}

local function area_damage(radius, amount)
	return {
		type = "nested-result",
		action = {
			type = "area",
			radius = radius,
			action_delivery = {
				type = "instant",
				target_effects = {{type = "damage", damage = {amount = amount, type = "explosion"}}},
			},
		},
	}
end

local blast_effects = {
	area_damage(6, 1500),
	area_damage(14, 300),
	{type = "create-entity", entity_name = "massive-explosion"},
	{type = "create-entity", entity_name = "big-explosion", repeat_count = 10, offset_deviation = {{-7, -7}, {7, 7}}},
	{type = "create-entity", entity_name = "medium-explosion", repeat_count = 12, offset_deviation = {{-12, -12}, {12, 12}}},
	{type = "create-fire", entity_name = "fire-flame", initial_ground_flame_count = 6, repeat_count = 14,
		offset_deviation = {{-12, -12}, {12, 12}}},
	{type = "create-entity", entity_name = "big-scorchmark-tintable", check_buildability = true},
	{type = "invoke-tile-trigger", repeat_count = 1},
	{
		type = "destroy-decoratives",
		include_soft_decoratives = true,
		include_decals = false,
		invoke_decorative_trigger = true,
		decoratives_with_trigger_only = false,
		radius = 10,
	},
	{
		type = "camera-effect",
		duration = 60,
		ease_in_duration = 5,
		ease_out_duration = 60,
		delay = 0,
		strength = 6,
		full_strength_max_distance = 30,
		max_distance = 120,
	},
	{type = "show-explosion-on-chart", scale = 0.4},
}

local prototypes = {
	{
		type = "projectile",
		name = "re2-rocket-blast",
		flags = {"not-on-map"},
		hidden = true,
		acceleration = 0,
		action = {type = "direct", action_delivery = {type = "instant", target_effects = blast_effects}},
	},
}

-- {width, height} of spaceship-wreck-small-N.png and its shadow (base/prototypes/entity/crash-site.lua)
local pieces = {
	{156, 152, 178, 122},
	{146, 102, 92, 76},
	{164, 148, 156, 114},
	{168, 142, 164, 100},
	{164, 120, 148, 78},
	{166, 114, 160, 104},
}

for index, size in ipairs(pieces) do
	prototypes[#prototypes + 1] = {
		type = "artillery-projectile",
		name = "re2-rocket-debris-" .. index,
		flags = {"not-on-map"},
		hidden = true,
		reveal_map = false,
		map_color = {r = 1, g = 0.4, b = 0},
		rotatable = false,
		picture = {filename = wreck .. index .. ".png", width = size[1], height = size[2], scale = 0.3, priority = "high"},
		shadow = {filename = wreck .. index .. "-shadow.png", width = size[3], height = size[4], scale = 0.3,
			priority = "high", draw_as_shadow = true},
		chart_picture = chart_picture,
		action = {type = "direct", action_delivery = {type = "instant", target_effects = {
			area_damage(2.5, 60),
			{type = "create-entity", entity_name = "explosion"},
			{type = "create-fire", entity_name = "fire-flame", initial_ground_flame_count = 4},
			{type = "create-entity", entity_name = "small-scorchmark-tintable", check_buildability = true},
			{type = "show-explosion-on-chart", scale = 0.05},
		}}},
	}
end

data:extend(prototypes)
