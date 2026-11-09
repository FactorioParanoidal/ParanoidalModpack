local util = require("util")
local orbits = require("lib.orbits")

local Public = {}
local starmap_layers = {}

-- Orbits help us construct the system. In data-final-fixes, it's now better to rely on the game variables (distance and orientation) for the position of each space location for compatibility reasons.

function Public.update_starmap_layers(planet)
	if planet.sprite_only and (planet.starmap_icon or planet.starmap_icons) then
		local magnitude = planet.magnitude or 1

		-- get the absolute position, including the origin offset
		local x, y = orbits.get_absolute_position(planet)
		x, y = x * 32, y * 32

		if planet.starmap_icons then
			for _, sprite in pairs(planet.starmap_icons) do
				local scaled_sprite = util.table.deepcopy(sprite)
				scaled_sprite.scale = scaled_sprite.scale * (magnitude * 32)

				Public.add_sprite_to_starmap(sprite, { x = x, y = y })
			end
		elseif planet.starmap_icon then
			local icon_size = planet.starmap_icon_size or 64

			Public.add_sprite_to_starmap({
				filename = planet.starmap_icon,
				size = icon_size,
				scale = (magnitude * 32) / icon_size,
			}, { x = x, y = y })
		end
	end

	if planet.orbit and planet.orbit.sprite then
		Public.try_draw_orbit_of_planet(planet)

		return { should_disable_default_orbit_sprite = true }
	end
	
	return { should_disable_default_orbit_sprite = false }
end

-- Deprecated
-- This function is no longer needed, but kept for legacy compatibility since it was in Public.
-- Factorio's native origin field now provides this functionality directly.
function Public.try_draw_orbit_of_planet(planet)
	local orbit = planet.orbit
	local parent = orbit.parent

	assert(
		parent.type == "planet" or parent.type == "space-location",
		"Parent types other than planet or space-location are not yet supported"
	)

	local parent_data = data.raw[parent.type][parent.name]

	if not parent_data then
		log("[PLANETSLIB] Not drawing orbit of " .. planet.name .. " because parent " .. parent.name .. " is not found")
	end

	if parent_data.type == "planet" and parent_data.hidden then
		-- When mods hide a planet, they usually want to hide the orbit graphics of its moons, because those moons will now sit in empty space.
		log(
			"[PLANETSLIB] Not drawing orbit of "
				.. planet.name
				.. " because parent "
				.. parent.name
				.. " is a hidden planet"
		)
	end

	local parent_x, parent_y =
		orbits.get_rectangular_position_from_polar(parent_data.distance * 32, parent_data.orientation)

	if orbit.sprite.layers then
		for _, layer in pairs(orbit.sprite.layers) do
			Public.add_sprite_to_starmap(layer, { x = parent_x, y = parent_y }, planet.name)
		end
	else
		Public.add_sprite_to_starmap(orbit.sprite, { x = parent_x, y = parent_y }, planet.name)
	end
end

function Public.add_sprite_to_starmap(sprite, extra_displacement, orbit_name)
	local sprite_copy = util.table.deepcopy(sprite)

	local shift_x = 0
	local shift_y = 0

	if sprite_copy.shift then
		if sprite_copy.shift.x then
			shift_x = shift_x + sprite_copy.shift.x
			shift_y = shift_y + sprite_copy.shift.y
		else
			shift_x = shift_x + sprite_copy.shift[1]
			shift_y = shift_y + sprite_copy.shift[2]
		end
	end

	-- attach a marker for this orbit so we can modify it later
	sprite_copy.planetslib_orbit_name = orbit_name
	-- also preserve the original shift, before applying displacement
	sprite_copy.planetslib_orbit_shift = { shift_x, shift_y }

	if extra_displacement then
		if extra_displacement.x and extra_displacement.y then
			shift_x = shift_x + extra_displacement.x
			shift_y = shift_y + extra_displacement.y
		else
			shift_x = shift_x + extra_displacement[1]
			shift_y = shift_y + extra_displacement[2]
		end
	end

	sprite_copy.shift = {
		shift_x,
		shift_y,
	}

	table.insert(starmap_layers, sprite_copy)
end

-- Now begins the algorithm:

local locations = {}

for _, type in pairs({ "space-location", "planet" }) do
	for _, location in pairs(data.raw[type]) do
		locations[#locations + 1] = location
	end
end

local ordered_locations = orbits.locations_ordered_by_orbits(locations)

for _, location in pairs(ordered_locations) do
	local result = Public.update_starmap_layers(location)
	if result.should_disable_default_orbit_sprite then
		location.draw_orbit = false
	end
end

if #starmap_layers > 0 then
	data.raw["utility-sprites"]["default"].starmap_star = { layers = starmap_layers }
end

return Public
