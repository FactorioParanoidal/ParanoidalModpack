-- Агрегатор точки росы из Beta 8 (DewPointAggregator 9.0.28 с балансом Paranoidal).
-- Без control.lua: вместо выбора рецепта по биому — один закреплённый скрытый рецепт.
local GRAPHICS = "__zzzparanoidal__/graphics/entity/dew-point-aggregator/"
local WATER_PER_SECOND = 150

local function pipe_connections()
	local connections = {}
	for _, offset in ipairs({ -1, 1 }) do
		connections[#connections + 1] = { flow_direction = "output", direction = defines.direction.north, position = { offset, -2 } }
		connections[#connections + 1] = { flow_direction = "output", direction = defines.direction.east, position = { 2, offset } }
		connections[#connections + 1] = { flow_direction = "output", direction = defines.direction.south, position = { offset, 2 } }
		connections[#connections + 1] = { flow_direction = "output", direction = defines.direction.west, position = { -2, offset } }
	end
	return connections
end

data:extend({
	{
		type = "recipe-category",
		name = "dpa",
	},
	{
		type = "assembling-machine",
		name = "dpa",
		icon = GRAPHICS .. "dpa-entity-icon.png",
		icon_size = 128,
		flags = { "placeable-neutral", "placeable-player", "player-creation" },
		minable = { mining_time = 1, result = "dpa" },
		max_health = 200,
		corpse = "big-remnants",
		resistances = { { type = "fire", percent = 70 } },
		collision_box = { { -2.4, -2.4 }, { 2.4, 2.4 } },
		selection_box = { { -2.5, -2.5 }, { 2.5, 2.5 } },
		crafting_categories = { "dpa" },
		fixed_recipe = "dpa-water",
		crafting_speed = 1,
		energy_source = {
			type = "electric",
			usage_priority = "secondary-input",
			drain = "160kW",
			emissions_per_minute = { pollution = -10 },
		},
		energy_usage = "1000kW",
		fluid_boxes = {
			{
				production_type = "output",
				filter = "water",
				volume = 1000,
				pipe_covers = pipecoverspictures(),
				pipe_connections = pipe_connections(),
			},
		},
		graphics_set = {
			animation = {
				layers = {
					{
						filename = GRAPHICS .. "dpa.png",
						width = 207,
						height = 199,
						frame_count = 8,
						line_length = 4,
						animation_speed = 2,
						scale = 0.8,
					},
					{
						filename = GRAPHICS .. "dpa-shadow.png",
						width = 277,
						height = 149,
						repeat_count = 8,
						scale = 0.8,
						shift = { 0.875, 0.625 },
						draw_as_shadow = true,
					},
				},
			},
		},
		working_sound = {
			sound = { filename = GRAPHICS .. "dpa-working.ogg", volume = 0.8 },
			idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		},
	},
	{
		type = "recipe",
		name = "dpa-water",
		category = "dpa",
		enabled = true,
		hidden = true,
		energy_required = 1,
		ingredients = {},
		results = { { type = "fluid", name = "water", amount = WATER_PER_SECOND } },
	},
	{
		type = "item",
		name = "dpa",
		icon = GRAPHICS .. "dpa-icon.png",
		icon_size = 32,
		subgroup = "extraction-machine",
		order = "b[fluids]-a[dpa]",
		place_result = "dpa",
		stack_size = 10,
	},
	{
		type = "recipe",
		name = "dpa",
		enabled = false,
		energy_required = 15,
		ingredients = {
			{ type = "item", name = "iron-plate", amount = 56 },
			{ type = "item", name = "iron-gear-wheel", amount = 20 },
			{ type = "item", name = "bob-basic-circuit-board", amount = 15 },
			{ type = "item", name = "engine-unit", amount = 16 },
			{ type = "item", name = "pipe", amount = 40 },
		},
		results = { { type = "item", name = "dpa", amount = 1 } },
	},
	{
		type = "technology",
		name = "dpa",
		icon = GRAPHICS .. "dpa-technology.png",
		icon_size = 128,
		prerequisites = { "fluid-handling", "engine" },
		effects = { { type = "unlock-recipe", recipe = "dpa" } },
		unit = {
			count = 40,
			ingredients = { { "automation-science-pack", 1 }, { "logistic-science-pack", 1 } },
			time = 30,
		},
		order = "a-f",
	},
})
