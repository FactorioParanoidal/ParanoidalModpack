-- Warp sectors as Space Age space locations: a gate and two points per sector, short routes between them (3-5 minutes
-- of flight for a small ship, user 2026-11-07), own sky, sun and asteroids. Unlocked by the warp drive technology.
local shared = require("shared")
local asteroid_util = require("__space-age__/prototypes/planet/asteroid-spawn-definitions")

local ROUTE_LENGTH = 12000 -- km; Nauvis-Vulcanus in Space Age: 15000
local DISTANCE = 60 -- star map: outside the (hidden) solar system
local nauvis = data.raw.planet.nauvis

-- Asteroid data in the format of asteroid-spawn-definitions.lua: the same density along the whole route.
local function asteroid_data(spec)
	local function range(probability, angle)
		return {{position = 0.1, probability = probability, angle_when_stopped = angle},
			{position = 0.9, probability = probability, angle_when_stopped = angle}}
	end
	local result = {type_ratios = {{position = 0.1, ratios = spec.ratios}, {position = 0.9, ratios = spec.ratios}}}
	for _, size in ipairs({"chunk", "small", "medium", "big", "huge"}) do
		if spec[size] then
			result["probability_on_range_" .. size] = range(spec[size], asteroid_util[size .. "_angle"])
		end
	end
	return result
end

-- The sky of a sector: Nauvis orbit as the base, another planet behind the platform (or none), a colour grade.
local function sky(sector)
	local parameters = table.deepcopy(nauvis.platform_surface_render_parameters or {})
	local planet = sector.backdrop and data.raw.planet[sector.backdrop]
	local backdrop = planet and planet.platform_surface_render_parameters
		and planet.platform_surface_render_parameters.platform_backdrop
	parameters.platform_backdrop = backdrop and table.deepcopy(backdrop) or nil
	if sector.lut then parameters.day_night_cycle_color_lookup = {{0.0, sector.lut}} end
	return parameters
end

local function icons(file, size, tint)
	return {{icon = file, icon_size = size, tint = tint}}
end

-- Route icon as Space Age draws it (data-updates.lua of space-age does it only for locations with a plain icon).
local function route_icons(from_gate, to_gate, tint)
	local function file(is_gate)
		return is_gate and "__space-age__/graphics/icons/solar-system-edge.png"
			or "__space-age__/graphics/icons/shattered-planet.png"
	end
	return {
		{icon = "__space-age__/graphics/icons/planet-route.png", icon_size = 64},
		{icon = file(from_gate), icon_size = 64, scale = 0.333, shift = {-6, -6}, tint = tint},
		{icon = file(to_gate), icon_size = 64, scale = 0.333, shift = {6, 6}, tint = tint},
	}
end

local prototypes = {}
for index, sector in ipairs(shared.sectors) do
	local definitions = asteroid_util.spawn_definitions(asteroid_data(sector.asteroids), 0.9)
	local route = asteroid_util.spawn_definitions(asteroid_data(sector.asteroids))
	local render = sky(sector)
	-- Gate in the middle, the two points slightly apart on the star map.
	local offsets = {gate = {0, 0}, [sector.points[2]] = {4, 0.015}, [sector.points[3]] = {-4, 0.015}}
	for order, point in ipairs(sector.points) do
		local is_gate = point == "gate"
		local offset = offsets[point]
		prototypes[#prototypes + 1] = {
			type = "space-location",
			name = shared.location(sector, point),
			icons = icons(is_gate and "__space-age__/graphics/icons/solar-system-edge.png"
				or "__space-age__/graphics/icons/shattered-planet.png", 64, sector.tint),
			starmap_icons = icons(is_gate and "__space-age__/graphics/icons/starmap-solar-system-edge.png"
				or "__space-age__/graphics/icons/starmap-shattered-planet.png", 512, sector.tint),
			subgroup = "planets",
			order = "z[paranoidal-warp]-" .. index .. "-" .. order,
			distance = DISTANCE + offset[1],
			orientation = sector.orientation + offset[2],
			magnitude = is_gate and 0.8 or 0.5,
			label_orientation = 0.15,
			gravity_pull = 0,
			draw_orbit = false,
			auto_save_on_first_trip = false,
			solar_power_in_space = sector.solar,
			asteroid_spawn_definitions = definitions,
			platform_surface_render_parameters = render,
		}
	end
	local p = sector.points
	for _, pair in ipairs({{p[1], p[2]}, {p[2], p[3]}, {p[3], p[1]}}) do
		prototypes[#prototypes + 1] = {
			type = "space-connection",
			name = shared.location(sector, pair[1]) .. "-to-" .. pair[2],
			icons = route_icons(pair[1] == "gate", pair[2] == "gate", sector.tint),
			subgroup = "planet-connections",
			order = "z[paranoidal-warp]-" .. index .. "-" .. pair[1] .. "-" .. pair[2],
			from = shared.location(sector, pair[1]),
			to = shared.location(sector, pair[2]),
			length = ROUTE_LENGTH,
			asteroid_spawn_definitions = route,
		}
	end
end
data:extend(prototypes)
