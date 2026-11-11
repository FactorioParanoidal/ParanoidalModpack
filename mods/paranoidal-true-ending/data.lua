-- Paranoidal True Ending (Space Age branch only, ПР-084): the solar system edge ends chapter 1, victory needs a platform
-- that reaches the Shattered Planet with the Ark in its hub. Beyond the edge the route has three legs, each more
-- dangerous: edge -> halfway (a stop where promethium can be mined) -> debris belt -> Shattered Planet.
-- Based on True Ending Is Shattered Planet 0.3.1 by Talandar (MIT, see LICENSE).
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")
local names = require("shared.names")

-- Leg lengths in km (Space Age: 4 000 000 from the edge to the Shattered Planet) and the share of Space Age's
-- Shattered Planet trip each leg takes; the debris belt leg has more huge asteroids.
local LEGS = {
	{name = names.first_leg, from = names.edge, to = names.halfway, length = 2000000, cut = {0.001, 0.5}, scale = 1},
	{name = names.second_leg, from = names.halfway, to = names.belt, length = 1200000, cut = {0.5, 0.8}, scale = 1},
	{name = names.third_leg, from = names.belt, to = names.target, length = 800000, cut = {0.8, 0.999}, scale = 1.25},
}

-- Part [a, b] of Space Age's Shattered Planet trip as a trip of its own (positions 0.001 .. 0.999), huge asteroids
-- multiplied by scale. The ends are literal 0.001 / 0.999: a stop samples a trip at an exact position.
local function leg_trip(a, b, scale)
	local trip = asteroid_util.shattered_planet_trip
	local function at(points, position)
		local low = asteroid_util.find_lower_point(position, points)
		local high = asteroid_util.find_higher_point(position, points)
		return low, high
	end
	local function map(position)
		return 0.001 + (position - a) / (b - a) * 0.998
	end
	local huge = {}
	for _, edge in ipairs({{a, 0.001}, {b, 0.999}}) do
		local low, high = at(trip.probability_on_range_huge, edge[1])
		local probability, angle = asteroid_util.interpolate_points(low, high, edge[1])
		huge[#huge + 1] = {position = edge[2], probability = probability * scale, angle_when_stopped = angle}
	end
	local ratios = {}
	local low, high = at(trip.type_ratios, a)
	ratios[1] = {position = 0.001, ratios = asteroid_util.interpolate_point_ratio(low, high, a)}
	for _, point in ipairs(trip.type_ratios) do
		if point.position > a and point.position < b then
			ratios[#ratios + 1] = {position = map(point.position), ratios = point.ratios}
		end
	end
	low, high = at(trip.type_ratios, b)
	ratios[#ratios + 1] = {position = 0.999, ratios = asteroid_util.interpolate_point_ratio(low, high, b)}
	-- Other sizes: none, but with points at both ends. Space Age's defaults span 0.1 .. 0.9 only, and sampling a stop
	-- outside them indexes a point without a probability (error).
	local function none(size)
		local angle = asteroid_util[size .. "_angle"]
		return {{position = 0.001, probability = 0, angle_when_stopped = angle},
			{position = 0.999, probability = 0, angle_when_stopped = angle}}
	end
	return {has_promethium_asteroids = true, probability_on_range_huge = huge, type_ratios = ratios,
		probability_on_range_chunk = none("chunk"), probability_on_range_small = none("small"),
		probability_on_range_medium = none("medium"), probability_on_range_big = none("big")}
end

local trips = {}
for index, leg in ipairs(LEGS) do trips[index] = leg_trip(leg.cut[1], leg.cut[2], leg.scale) end

data:extend({
	{
		type = "space-location",
		name = names.halfway,
		icon = "__space-age__/graphics/icons/solar-system-edge.png",
		starmap_icon = "__space-age__/graphics/icons/starmap-solar-system-edge.png",
		starmap_icon_size = 512,
		order = "f[solar-system-edge]-a[halfway]",
		subgroup = "planets",
		gravity_pull = -10,
		distance = 65,
		orientation = 0.25,
		magnitude = 0.6,
		label_orientation = 0.15,
		draw_orbit = false,
		auto_save_on_first_trip = false,
		asteroid_spawn_influence = 1,
		-- a platform waiting here meets the asteroids of the middle of Space Age's trip
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(trips[1], 0.999),
	},
	{
		type = "space-location",
		name = names.belt,
		icon = "__space-age__/graphics/icons/huge-promethium-asteroid.png",
		starmap_icons = {{icon = "__space-age__/graphics/icons/starmap-solar-system-edge.png", icon_size = 512,
			tint = {r = 1, g = 0.45, b = 0.35, a = 1}}},
		order = "f[solar-system-edge]-b[debris-belt]",
		subgroup = "planets",
		gravity_pull = -10,
		distance = 74,
		orientation = 0.25,
		magnitude = 0.8,
		label_orientation = 0.15,
		draw_orbit = false,
		auto_save_on_first_trip = false,
		asteroid_spawn_influence = 1,
		asteroid_spawn_definitions = asteroid_util.spawn_definitions(trips[3], 0.001),
	},
})

for index, leg in ipairs(LEGS) do
	local connection = data.raw["space-connection"][leg.name]
	if not connection then
		connection = {type = "space-connection", name = leg.name, subgroup = "planet-connections", order = "i-" .. index}
		data:extend({connection})
		connection = data.raw["space-connection"][leg.name]
	end
	connection.from = leg.from
	connection.to = leg.to
	connection.length = leg.length
	connection.asteroid_spawn_definitions = asteroid_util.spawn_definitions(trips[index])
end

-- The Ark: crafted on a platform from the materials of every planet of the build (planet ingredients are added in
-- data-updates, when every planet mod has defined them).
data:extend({
	{
		type = "item",
		name = names.ark,
		icons = {
			{icon = "__space-age__/graphics/icons/space-platform-hub.png", icon_size = 64,
				tint = {r = 1, g = 0.85, b = 0.55, a = 1}},
			{icon = "__space-age__/graphics/icons/promethium-asteroid-chunk.png", icon_size = 64, scale = 0.25,
				shift = {8, 8}},
		},
		subgroup = "space-related",
		order = "z[paranoidal-ark]",
		stack_size = 1,
		weight = 1000000,
	},
	{
		type = "recipe",
		name = names.ark,
		categories = {"cryogenics"},
		enabled = false,
		energy_required = 600,
		surface_conditions = {{property = "gravity", min = 0, max = 0}},
		ingredients = {
			{type = "item", name = "promethium-asteroid-chunk", amount = 250},
			{type = "item", name = "quantum-processor", amount = 50},
			{type = "item", name = "low-density-structure", amount = 100},
		},
		results = {{type = "item", name = names.ark, amount = 1}},
		allow_productivity = false,
	},
	{
		type = "technology",
		name = names.technology,
		icon = "__space-age__/graphics/icons/starmap-shattered-planet.png",
		icon_size = 512,
		essential = true,
		effects = {
			{type = "unlock-space-location", space_location = names.belt},
			{type = "unlock-space-location", space_location = names.target, use_icon_overlay_constant = true},
			{type = "unlock-recipe", recipe = names.ark},
		},
		prerequisites = {names.promethium_technology},
		-- every science pack of the build is set in data-updates
		unit = {count = 20000, ingredients = {{"promethium-science-pack", 1}}, time = 120},
	},
})

-- The promethium science pack opens only the way to the halfway point (Space Age: the Shattered Planet itself).
local promethium = data.raw.technology[names.promethium_technology]
if promethium then
	promethium.effects = promethium.effects or {}
	for i = #promethium.effects, 1, -1 do
		local effect = promethium.effects[i]
		if effect.type == "unlock-space-location" and effect.space_location == names.target then
			table.remove(promethium.effects, i)
		end
	end
	table.insert(promethium.effects, 1, {type = "unlock-space-location", space_location = names.halfway,
		use_icon_overlay_constant = true})
end
