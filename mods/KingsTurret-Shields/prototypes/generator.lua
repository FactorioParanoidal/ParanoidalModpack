-- Shield generator: a building that protects the turrets of its force within a radius with one
-- shared energy buffer. The buffer is a hidden electric-energy-interface under the building
-- (kts-gen-<size>-<rate>), one prototype per pair of completed research levels: the input flow
-- limit and the drain are prototype-only properties. The building itself has no energy source and
-- never changes, so blueprints, ghosts and robots only ever see one entity name.
local shared = require("kts_shared")

local cfg = shared.read(settings.startup)
local max_level = cfg.research and cfg.max_level or 0
local path = shared.root .. "/graphics/"
local GEN = shared.generator
local half = shared.generator_size / 2

local function buffer_flags()
	return {
		"placeable-off-grid", "not-on-map", "not-blueprintable", "not-deconstructable", "not-repairable",
		"not-flammable", "not-selectable-in-game", "not-upgradable", "not-in-kill-statistics",
		"not-in-made-in", "no-copy-paste", "hide-alt-info",
	}
end

local list = {}
for size = 0, max_level do
	for rate = 0, max_level do
		local stats = shared.stats(cfg, size, rate)
		list[#list + 1] = {
			type = "electric-energy-interface",
			name = shared.buffer_name(size, rate),
			localised_name = {"entity-name.kts-shield-buffer"},
			localised_description = {"entity-description.kts-shield-buffer"},
			icon = path .. "entity_icon.png",
			icon_size = 128,
			flags = buffer_flags(),
			hidden = true,
			max_health = 1,
			-- Collides with nothing; the box only decides which poles power the buffer: those whose
			-- supply area reaches the generator footprint.
			collision_box = {{-half + 0.1, -half + 0.1}, {half - 0.1, half - 0.1}},
			collision_mask = {layers = {}},
			selectable_in_game = false,
			allow_copy_paste = false,
			gui_mode = "none",
			energy_source = {
				type = "electric",
				usage_priority = "secondary-input",
				buffer_capacity = shared.energy(stats.buffer, "J"),
				input_flow_limit = shared.energy(stats.recharge + stats.drain, "W"),
				output_flow_limit = "0W",
				drain = shared.energy(stats.drain, "W"),
			},
		}
	end
end

-- The radius picture is a disc inscribed in its square; the engine stretches it to 2 * distance
-- (SchallPickupTower uses the same form: a one-tile sprite and the range as distance).
local RADIUS_PX = 256

list[#list + 1] = {
	type = "simple-entity-with-owner",
	name = GEN,
	localised_description = {"entity-description." .. GEN, tostring(cfg.radius)},
	icon = path .. "entity_icon.png",
	icon_size = 128,
	flags = {"placeable-player", "player-creation"},
	minable = {mining_time = 0.5, result = GEN},
	max_health = 500,
	corpse = "accumulator-remnants",
	dying_explosion = "accumulator-explosion",
	damaged_trigger_effect = {
		type = "create-entity", entity_name = "spark-explosion", offset_deviation = {{-0.5, -0.5}, {0.5, 0.5}},
		offsets = {{0, 1}}, damage_type_filters = "fire",
	},
	collision_box = {{-half + 0.1, -half + 0.1}, {half - 0.1, half - 0.1}},
	selection_box = {{-half, -half}, {half, half}},
	render_layer = "object",
	picture = {
		layers = {
			{
				filename = "__base__/graphics/entity/accumulator/accumulator.png",
				priority = "high", width = 130, height = 189, shift = {0, -11 / 32}, scale = 0.5,
				tint = {0.55, 0.8, 1, 1},
			},
			{
				filename = "__base__/graphics/entity/accumulator/accumulator-shadow.png",
				priority = "high", width = 234, height = 106, shift = {29 / 32, 6 / 32}, scale = 0.5,
				draw_as_shadow = true,
			},
		},
	},
	radius_visualisation_specification = {
		sprite = {
			filename = path .. "radius-visualization.png", width = RADIUS_PX, height = RADIUS_PX,
			scale = 32 / RADIUS_PX, priority = "extra-high-no-scale",
		},
		distance = cfg.radius,
	},
}

list[#list + 1] = {
	type = "item",
	name = GEN,
	icon = path .. "entity_icon.png",
	icon_size = 128,
	subgroup = "defensive-structure",
	order = "z[kts-shield-generator]",
	place_result = GEN,
	stack_size = 10,
}

-- Price: a proposal (2026-10-21), only items that exist by the base research.
list[#list + 1] = {
	type = "recipe",
	name = GEN,
	enabled = not cfg.research,
	energy_required = 20,
	ingredients = {
		{type = "item", name = "steel-plate", amount = 20},
		{type = "item", name = "electronic-circuit", amount = 20},
		{type = "item", name = "iron-gear-wheel", amount = 20},
		{type = "item", name = "copper-cable", amount = 40},
	},
	results = {{type = "item", name = GEN, amount = 1}},
}

data:extend(list)
