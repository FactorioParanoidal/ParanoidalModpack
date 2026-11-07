-- Stage 3 (user 2026-11-07): the comfort field generator (one per platform, constant power, its craft rate is the field
-- strength), the void shield (an accumulator that only charges; control.lua spends its energy on asteroids), the red
-- alert siren and the two technologies.
local shared = require("shared")
local warp_util = require("prototypes.util")

local FIELD_TINT = {r = 0.55, g = 0.85, b = 1}
local SHIELD_TINT = {r = 0.55, g = 0.45, b = 1}
local thruster_item = data.raw.item.thruster
local subgroup = thruster_item and thruster_item.subgroup or "space-related"
local order = (thruster_item and thruster_item.order or "z") .. "-z[paranoidal-warp-"

-- Field generator: a recoloured cryogenic plant; its hidden recipe needs nothing, makes nothing and runs all the time.
local field = warp_util.machine(data.raw["assembling-machine"]["cryogenic-plant"], shared.field, shared.field_recipe, "5MW",
	FIELD_TINT)

-- Void shield: a recoloured accumulator that takes energy and never gives it back.
local shield = table.deepcopy(data.raw.accumulator.accumulator)
shield.name = shared.shield
shield.icon = nil
shield.icons = warp_util.icons(data.raw.accumulator.accumulator, SHIELD_TINT)
shield.minable = {mining_time = 0.5, result = shared.shield}
shield.placeable_by = nil
shield.fast_replaceable_group = nil
shield.next_upgrade = nil
shield.energy_source = {type = "electric", usage_priority = "tertiary", buffer_capacity = "100MJ",
	input_flow_limit = "5MW", output_flow_limit = "0W"}
shield.surface_conditions = {{property = "gravity", min = 0, max = 0}}
shield.default_output_signal = nil
warp_util.tint_layers(shield.chargable_graphics, SHIELD_TINT)

data:extend({
	{type = "recipe-category", name = shared.field_recipe},
	field,
	shield,
	{
		type = "item",
		name = shared.field,
		icons = field.icons,
		subgroup = subgroup,
		order = order .. "field]",
		place_result = shared.field,
		stack_size = 1,
		weight = 500000, -- 500 kg
	},
	{
		type = "item",
		name = shared.shield,
		icons = shield.icons,
		subgroup = subgroup,
		order = order .. "shield]",
		place_result = shared.shield,
		stack_size = 10,
		weight = 200000, -- 200 kg: five per rocket
	},
	{
		type = "recipe",
		name = shared.field,
		enabled = false,
		energy_required = 60,
		ingredients = {
			{type = "item", name = "steel-plate", amount = 100},
			{type = "item", name = "processing-unit", amount = 100},
			{type = "item", name = "low-density-structure", amount = 50},
			{type = "item", name = "electric-engine-unit", amount = 20},
		},
		results = {{type = "item", name = shared.field, amount = 1}},
	},
	{
		type = "recipe",
		name = shared.shield,
		enabled = false,
		energy_required = 30,
		ingredients = {
			{type = "item", name = "accumulator", amount = 5},
			{type = "item", name = "processing-unit", amount = 20},
			{type = "item", name = "low-density-structure", amount = 10},
			{type = "item", name = "steel-plate", amount = 20},
		},
		results = {{type = "item", name = shared.shield, amount = 1}},
	},
	{
		type = "recipe",
		name = shared.field_recipe,
		icons = field.icons, -- a recipe without results needs its own icon
		subgroup = subgroup,
		categories = {shared.field_recipe},
		enabled = true,
		hidden = true,
		hidden_in_factoriopedia = true,
		energy_required = 1,
		ingredients = {},
		results = {},
		allow_productivity = false,
		allow_quality = false,
	},
	{
		type = "sound",
		name = shared.alert_sound,
		filename = "__base__/sound/silo-alarm-short.ogg",
		volume = 0.5,
	},
	{
		type = "technology",
		name = shared.field_technology,
		icons = {{icon = "__space-age__/graphics/technology/space-platform.png", icon_size = 256, tint = FIELD_TINT}},
		effects = {{type = "unlock-recipe", recipe = shared.field}},
		prerequisites = {shared.technology},
		unit = {count = 500, time = 60, ingredients = warp_util.science},
	},
	{
		type = "technology",
		name = shared.shield_technology,
		icons = {{icon = "__space-age__/graphics/technology/space-platform.png", icon_size = 256, tint = SHIELD_TINT}},
		effects = {{type = "unlock-recipe", recipe = shared.shield}},
		prerequisites = {shared.field_technology},
		unit = {count = 1000, time = 60, ingredients = warp_util.science},
	},
})
