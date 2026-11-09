local lib = require("lib/lib")
local Public = {}

function Public.get_rectangular_position_from_polar(distance, orientation)
	if distance == 0 then
		return 0, 0
	else
		return distance * math.sin(orientation * 2 * math.pi), -distance * math.cos(orientation * 2 * math.pi)
	end
end

function Public.get_polar_position_from_rectangular(x, y)
	local distance = math.sqrt(x * x + y * y)
	local orientation = (0.25 + math.atan2(y, x) / (2 * math.pi)) % 1

	return distance, orientation
end

function Public.get_absolute_position(location)
	-- grab the x/y values derived from existing distance/orientation
	local x, y = Public.get_rectangular_position_from_polar(location.distance, location.orientation)

	-- use any pre-existing origin values as an offset for the above derived values
	if location.origin then
		x = x + (location.origin.x or location.origin[1])
		y = y + (location.origin.y or location.origin[2])
	end

	return x, y
end

function Public.apply_native_orbit(location)
	local orbit = location.orbit

	-- do not modify pre-existing origin values
	if location.origin then return end

	-- no PlanetsLib orbit field detected, cannot be processed
	if not (orbit and orbit.parent) then return end

	-- if orbit.sprite was defined, ensure base game draws an orbit
	if orbit.sprite and location.draw_orbit == nil then location.draw_orbit = true end

	-- preserve the object's current absolute position before adding an origin
	local location_x, location_y = Public.get_absolute_position(location)
	-- grab the parent planet/space-location from the orbit field
	local parent = data.raw[orbit.parent.type][orbit.parent.name]
	-- get the parent's absolute x/y position, accounting for its own origin offset (if any)
	local parent_x, parent_y = Public.get_absolute_position(parent)

	-- apply the new origin values based on the parent x/y values,
	location.origin = { x = parent_x, y = parent_y }

	-- update the pre-existing absolute position relative to the new origin
	location.distance, location.orientation =
		Public.get_polar_position_from_rectangular(location_x - parent_x, location_y - parent_y)
end

Public.SPECIAL_PLACEHOLDERS_FOR_MISSING_PARENT = {
	-- Hopefully, nobody uses exactly these values in their mod!
	distance = 43168,
	orientation = 0.43168,
}

function Public.get_absolute_polar_position_from_orbit(orbit, return_special_placeholders_if_missing_parent)
	local parent = orbit.parent

	assert(
		parent.type == "planet" or parent.type == "space-location",
		"Parent types other than planet or space-location are not yet supported"
	)

	if parent.name == "star" then
		return orbit.distance, orbit.orientation
	end

	local parent_data = data.raw[parent.type][parent.name]

	if return_special_placeholders_if_missing_parent then
		if not parent_data then
			return Public.SPECIAL_PLACEHOLDERS_FOR_MISSING_PARENT.distance,
				Public.SPECIAL_PLACEHOLDERS_FOR_MISSING_PARENT.orientation
		end
	else
		assert(
			parent_data,
			string.format(
				"Tried to calculate the position corresponding to an orbit structure, but the parent %s '%s' was not found",
				parent.type,
				parent.name
			)
		)
	end

	local parent_distance = parent_data.distance
	local parent_orientation = parent_data.orientation

	if parent_data.orbit then -- Overwrite distance and orientation
		parent_distance, parent_orientation = Public.get_absolute_polar_position_from_orbit(parent_data.orbit)
	end

	-- Use the same polar convention as get_rectangular_position_from_polar /
	-- get_polar_position_from_rectangular so that orbit positions and the rest of
	-- the library agree. Note that the orbit's orientation is not rotated by the
	-- parent's orientation.
	local px, py = Public.get_rectangular_position_from_polar(parent_distance, parent_orientation)
	local ox, oy = Public.get_rectangular_position_from_polar(orbit.distance, orbit.orientation)

	return Public.get_polar_position_from_rectangular(px + ox, py + oy)
end

function Public.locations_ordered_by_orbits(locations)
	local ordered_locations = {}

	local visited = {}
	local temporary_marks = {}

	local function visit(location, ordered)
		if temporary_marks[location.name] then
			if not (location.orbit and location.orbit.parent and location.orbit.parent.name == location.name) then -- Self-parents are acceptable. Presumably this is only the case for data.raw["space-location"]["star"].
				error("Circular orbit dependency detected at " .. location.name)
			end
		end
		if not visited[location.name] then
			temporary_marks[location.name] = true

			if location.orbit and location.orbit.parent then
				local parent_type = location.orbit.parent.type
				local parent_name = location.orbit.parent.name

				if parent_name ~= location.name then
					local parent = data.raw[parent_type][parent_name]
					if parent then
						visit(parent, ordered)
					end
				end
			end

			temporary_marks[location.name] = false
			visited[location.name] = true
			table.insert(ordered, location)
		end
	end

	for _, location in pairs(locations) do
		if not visited[location.name] then
			visit(location, ordered_locations)
		end
	end

	return ordered_locations
end

function Public.is_parent(parent_prototype, child_prototype)
	Public.ensure_all_locations_have_orbits()

	if not (parent_prototype and parent_prototype.type and parent_prototype.name) then
		error("PlanetsLib.orbits.is_parent: invalid parent_prototype supplied")
	end
	if not (child_prototype and child_prototype.type and child_prototype.name) then
		error("PlanetsLib.orbits.is_parent: invalid child_prototype supplied")
	end

	if parent_prototype.type == child_prototype.type and parent_prototype.name == child_prototype.name then
		return false
	end

	local visited = {}
	local current = child_prototype

	while current do
		local orbit = current.orbit
		if not (orbit and orbit.parent) then
			return parent_prototype.type == "space-location" and parent_prototype.name == "star"
		end

		local parent = orbit.parent

		if parent.type == parent_prototype.type and parent.name == parent_prototype.name then
			return true
		end

		-- Prevent infinite loops
		local key = (parent.type or "") .. "|||||" .. (parent.name or "")
		if visited[key] then
			return false -- Circular dependency detected; bail out.
		end
		visited[key] = true

		local parent_data = data.raw[parent.type] and data.raw[parent.type][parent.name]
		if not parent_data then
			return false -- Broken reference – treat as no parent.
		end

		current = parent_data
	end

	return false
end

function Public.update_positions_of_all_children_via_orbits(parent_prototype)
	Public.ensure_all_locations_have_orbits()

	assert(
		parent_prototype.type == "planet" or parent_prototype.type == "space-location",
		"[PlanetsLib.orbits.update_positions_of_all_children_via_orbits] Parent types other than planet or space-location are not yet supported"
	)

	local parent_x, parent_y =
		Public.get_rectangular_position_from_polar(parent_prototype.distance, parent_prototype.orientation)

	local parent_orbital_x, parent_orbital_y = Public.get_rectangular_position_from_polar(
		Public.get_absolute_polar_position_from_orbit(parent_prototype.orbit)
	)

	local locations = {}

	for _, type in pairs({ "space-location", "planet" }) do
		for _, location in pairs(data.raw[type]) do
			locations[#locations + 1] = location
		end
	end

	local ordered_locations = Public.locations_ordered_by_orbits(locations)

	for _, location in pairs(ordered_locations) do
		if Public.is_parent(parent_prototype, location) then
			local child_x, child_y = Public.get_rectangular_position_from_polar(location.distance, location.orientation)

			local child_orbital_x, child_orbital_y = Public.get_rectangular_position_from_polar(
				Public.get_absolute_polar_position_from_orbit(location.orbit)
			)

			local orbital_delta_x, orbital_delta_y =
				child_orbital_x - parent_orbital_x, child_orbital_y - parent_orbital_y

			local child_new_x, child_new_y = parent_x + orbital_delta_x, parent_y + orbital_delta_y

			local child_new_distance, child_new_orientation =
				Public.get_polar_position_from_rectangular(child_new_x, child_new_y)

			if child_x ~= child_new_x or child_y ~= child_new_y then
                lib.detailed_log(
                    "PlanetsLib: updating "
                        .. location.name
                        .. " from x="
                        .. child_x
                        .. ", y="
                        .. child_y
                        .. " to x="
                        .. child_new_x
                        .. ", y="
                        .. child_new_y
                )

				location.distance = child_new_distance
				location.orientation = child_new_orientation
			end
		end
	end
end

function Public.ensure_all_locations_have_orbits()
	for _, type in pairs({ "space-location", "planet" }) do
		for _, location in pairs(data.raw[type]) do
			if
				not (
					location.orbit
					and location.orbit.parent
					and location.orbit.distance
					and (location.orbit.orientation or location.orbit.distance == 0)
				)
			then
				location.orbit = {
					parent = {
						type = "space-location",
						name = "star",
					},
					distance = location.distance,
					orientation = location.orientation,
				}
			end
		end
	end
end

return Public
