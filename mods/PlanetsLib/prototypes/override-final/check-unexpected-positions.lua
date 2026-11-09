local orbits = require("lib.orbits")
local lib = require("lib/lib")

-- If the position/orientation of a location's parent prototype doesn't match its orbit, that implies the position has been moved by another mod. In this code we adjust the position of its children accordingly.

local locations = {}

for _, type in pairs({ "space-location", "planet" }) do
	for _, location in pairs(data.raw[type]) do
		locations[#locations + 1] = location
	end
end

local ordered_locations = orbits.locations_ordered_by_orbits(locations)

for _, location in pairs(ordered_locations) do
	if location.orbit and location.orbit.distance and location.orbit.orientation and location.orbit.parent then
		local parent = location.orbit.parent
		local parent_data = data.raw[parent.type][parent.name]

		local parent_distance_via_orbit, parent_orientation_via_orbit =
			orbits.get_absolute_polar_position_from_orbit(parent_data.orbit)

		if
			parent_data.distance ~= parent_distance_via_orbit
			or (parent_data.orientation ~= parent_orientation_via_orbit and parent_data.distance ~= 0)
        then
            lib.detailed_log("--------------------------------")
            lib.detailed_log(
                "PlanetsLib: parent "
                    .. parent.name
                    .. " was unexpectedly found at "
                    .. parent_data.distance
                    .. ", "
                    .. parent_data.orientation
                    .. " when its orbit implied it should be at "
                    .. parent_distance_via_orbit
                    .. ", "
                    .. parent_orientation_via_orbit
                    .. ". Adjusting its orbit to match, and the positions of all its children."
            )

			local parent_x_via_orbit, parent_y_via_orbit =
				orbits.get_rectangular_position_from_polar(parent_distance_via_orbit, parent_orientation_via_orbit)

			local parent_x, parent_y =
				orbits.get_rectangular_position_from_polar(parent_data.distance, parent_data.orientation)

			local delta_x_to_update_orbit = parent_x - parent_x_via_orbit
			local delta_y_to_update_orbit = parent_y - parent_y_via_orbit

			local parent_orbit_x, parent_orbit_y =
				orbits.get_rectangular_position_from_polar(parent_data.orbit.distance, parent_data.orbit.orientation)

			local new_parent_orbital_distance, new_parent_orbital_orientation =
				orbits.get_polar_position_from_rectangular(
					parent_orbit_x + delta_x_to_update_orbit,
					parent_orbit_y + delta_y_to_update_orbit
				)

			parent_data.orbit.distance = new_parent_orbital_distance
			parent_data.orbit.orientation = new_parent_orbital_orientation

			orbits.update_positions_of_all_children_via_orbits(parent_data)
            lib.detailed_log("--------------------------------")
		end
	end
end
