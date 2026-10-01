-- User Beta 8: aai-industry/prototypes/torches.lua.
-- Standalone port: preserve fuel, mining return, light and the unusual 1TW buffer.
-- Registered late: no existing 2.0 prototype/early consumer owns this object.
assert(not data.raw.item.torch and not data.raw.recipe.torch
	and not data.raw["burner-generator"].torch, "Beta 8 torch conflicts with an existing prototype")

local path = "__zzzparanoidal__/graphics/torch/"
local body = {
	filename = path .. "torch.png", priority = "extra-high",
	width = 91, height = 80, shift = { 0.45, -0.45 },
	repeat_count = 60, frame_count = 1, scale = 0.5,
}
local shadow = table.deepcopy(body)
shadow.filename = path .. "torch-shadow.png"
shadow.draw_as_shadow = true
local flame = {
	filename = "__base__/graphics/entity/oil-refinery/oil-refinery-fire.png",
	line_length = 10, width = 40, height = 81, frame_count = 60,
	animation_speed = 0.1, draw_as_glow = true, shift = { -0.025, -1.1 },
	-- Base 2.0 uses the double-resolution sheet (40x81 instead of 20x40).
	scale = 0.25,
}
local function directions(layers)
	local animation = { layers = layers }
	return { north = animation, east = table.deepcopy(animation),
		south = table.deepcopy(animation), west = table.deepcopy(animation) }
end

data:extend({
	{
		type = "item", name = "torch", icon = path .. "torch-icon.png", icon_size = 64,
		subgroup = "energy", order = "c-a", place_result = "torch", stack_size = 64,
	},
	{
		type = "recipe", name = "torch", enabled = true,
		ingredients = {
			{ type = "item", name = "wood", amount = 3 },
			{ type = "item", name = "coal", amount = 1 },
		},
		results = { { type = "item", name = "torch", amount = 1 } },
		energy_required = 0.1,
	},
	{
		type = "burner-generator", name = "torch", icon = path .. "torch-icon.png", icon_size = 64,
		flags = { "placeable-player", "player-creation" }, fast_replaceable_group = "torches",
		max_health = 25, collision_box = { { -0.2, -0.2 }, { 0.2, 0.2 } },
		selection_box = { { -0.4, -0.4 }, { 0.4, 0.4 } }, max_power_output = "0.01W",
		minable = { mining_time = 0.1, result = "wood", count = 3 },
		-- The recipe pays for this coal; placement uses the native Beta 8 trigger.
		created_effect = {
			type = "direct", action_delivery = {
				type = "instant", source_effects = { { type = "insert-item", item = "coal" } },
			},
		},
		animation = directions({ body, shadow, flame }),
		idle_animation = directions({ table.deepcopy(body), table.deepcopy(shadow) }),
		burner = {
			type = "burner", fuel_categories = { "chemical" }, effectivity = 0.00001,
			fuel_inventory_size = 1, emissions_per_minute = { pollution = 2 },
			smoke = { { name = "smoke", deviation = { 0, 0 }, position = { 0.1, -1.3 }, frequency = 1 } },
			light_flicker = {
				light_intensity_to_size_coefficient = 5, color = { r = 0.6, g = 0.4, b = 0.1 },
				minimum_intensity = 1, maximum_intensity = 1,
			},
		},
		energy_source = {
			type = "electric", usage_priority = "secondary-output",
			buffer_capacity = "1TW", render_no_network_icon = false,
		},
	},
})
