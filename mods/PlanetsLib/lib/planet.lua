local util = require("util")
local orbits = require("lib.orbits")
local lib = require("lib/lib")

local Public = {}

function Public.extend(config)
	Public.verify_extend_fields(config)

	local planet = {}

	local distance, orientation = orbits.get_absolute_polar_position_from_orbit(config.orbit, true)

	planet.distance = distance
	planet.orientation = orientation

	for k, v in pairs(config) do -- This will not include distance, orientation due to validity checks.
		planet[k] = v
	end

	if planet.orbit.parent then --Adds encoded parent body to surface properties.
		if planet.orbit.parent.type == "planet" then
			local parent = data.raw["planet"][config.orbit.parent.name]
			local parent_planet_str = parent
				and parent["surface_properties"]
				and parent["surface_properties"]["planet-str"]
			if parent_planet_str ~= nil then
				planet["surface_properties"] = planet["surface_properties"] or {}
				planet["surface_properties"]["parent-planet-str"] = parent_planet_str
			end
		end
	end

	if planet.orbit.draw_orbit then
		planet.draw_orbit = planet.orbit.draw_orbit
	end

	if planet.special_properties then
		error("special_properties is an invalid field.")
		-- local special_properties = planet.special_properties
		-- PlanetsLib.constants.planet_properties[planet.name] = special_properties
		-- planet.special_properties = nil
	end

	data:extend({ planet })
end

local function resolve_space_location(planet)
	if type(planet) ~= "string" then
		return planet
	end
	return (data.raw["planet"] or {})[planet] or (data.raw["space-location"] or {})[planet]
end

function Public.is_space_location(planet)
	if not planet then
		return false
	end
	local prototype = resolve_space_location(planet)
	return prototype ~= nil and (prototype.type == "planet" or prototype.type == "space-location")
end

function Public.is_space_location_or_space_platform(planet)
	if not planet then
		return false
	end
	if planet == "space-platform" then
		return true
	end
	return Public.is_space_location(planet)
end
-- TODO: Add checks to ensure the structure of orbit is correct.
function Public.verify_extend_fields(config)
	if PlanetsLib.current_stage == "data-final-fixes" then
        error("PlanetsLib:extend() - This function can only be run before data-final-fixes. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib.")
	end
	if not Public.is_space_location(config) then
		error(
			"PlanetsLib:extend() - extend only takes a planet or space-location prototype. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if not config.orbit then
		error(
			"PlanetsLib:extend() - 'orbit' field is required. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if not Public.is_space_location(config.orbit.parent) then
		error(
			"PlanetsLib:extend() - 'orbit.parent' must be a space location. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if config.distance then
		error(
			"PlanetsLib:extend() - 'distance' should be specified in the 'orbit' field. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if config.orientation then
		error(
			"PlanetsLib:extend() - 'orientation' should be specified in the 'orbit' field. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if not config.orbit.parent then
		error(
			"PlanetsLib:extend() - 'orbit.parent' field is required with an object containing 'type' and 'name' fields. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
end

local function update_data_orbit(location, orbit)
	lib.detailed_log("--------------------------------")
	lib.detailed_log(
		"PlanetsLib:update called on "
		.. location.name
		.. ", changing orbit from "
		.. serpent.line(location.orbit)
		.. " to "
		.. serpent.line(orbit)
		.. " and updating the positions of children appropriately:"
	)

	location.orbit = orbit

	local current_x, current_y = orbits.get_rectangular_position_from_polar(
		location.distance,
		location.orientation
	)

	local parent_prototype = data.raw[orbit.parent.type][orbit.parent.name]

	if not parent_prototype then
		error("PlanetsLib.update: update called with invalid parent: " .. orbit.parent.name)
	end

	local parent_x, parent_y =
		orbits.get_rectangular_position_from_polar(parent_prototype.distance, parent_prototype.orientation)

	local orbit_x, orbit_y = orbits.get_rectangular_position_from_polar(orbit.distance, orbit.orientation)

	local new_x, new_y = parent_x + orbit_x, parent_y + orbit_y

	lib.detailed_log(
		"PlanetsLib: updating "
		.. location.name
		.. " from x="
		.. current_x
		.. ", y="
		.. current_y
		.. " to x="
		.. new_x
		.. ", y="
		.. new_y
	)

	local new_distance, new_orientation = orbits.get_polar_position_from_rectangular(new_x, new_y)

	location.distance = new_distance
	location.orientation = new_orientation

	orbits.update_positions_of_all_children_via_orbits(location)

	lib.detailed_log("--------------------------------")
end

local function update_final_orbit(location, orbit)
	location.orbit = orbit

	-- grab the new parent and its absolute x/y position
	local parent = data.raw[orbit.parent.type][orbit.parent.name]
	if not parent then	-- ensure parent is valid
		error("PlanetsLib.update: update called with invalid parent: " .. orbit.parent.name)
	end
	local parent_x, parent_y = orbits.get_absolute_position(parent)
	-- update the location origin using the parent x/y values
	location.origin = {
		x = parent_x,
		y = parent_y,
	}
	location.distance = orbit.distance
	location.orientation = orbit.orientation
	-- finally, update starmap layers with matching name
	for _, layer in pairs(data.raw["utility-sprites"]["default"].starmap_star.layers) do
		if layer.planetslib_orbit_name == location.name then
			-- make sure to recalculate using the original shift (if any)
			layer.shift = {
				layer.planetslib_orbit_shift[1] + parent_x * 32,
				layer.planetslib_orbit_shift[2] + parent_y * 32,
			}
		end
	end
	-- apply origin changes to all child objects
	local locations = {}
	for _, type in pairs({ "space-location", "planet" }) do
		for _, prototype in pairs(data.raw[type]) do
			locations[#locations + 1] = prototype
		end
	end
	-- ordered to ensure we process all parents before their children
	local ordered_locations = orbits.locations_ordered_by_orbits(locations)
	for _, child in ipairs(ordered_locations) do
		if orbits.is_parent(location, child) then
			local child_parent = data.raw[child.orbit.parent.type][child.orbit.parent.name]
			local child_parent_x, child_parent_y = orbits.get_absolute_position(child_parent)
			-- only update the origin; keep distance/orientation unchanged
			child.origin = {
				x = child_parent_x,
				y = child_parent_y,
			}
			-- update any custom orbit sprite layers attached to this child
			for _, layer in pairs(data.raw["utility-sprites"]["default"].starmap_star.layers) do
				if layer.planetslib_orbit_name == child.name then
					layer.shift = {
						layer.planetslib_orbit_shift[1] + child_parent_x * 32,
						layer.planetslib_orbit_shift[2] + child_parent_y * 32,
					}
				end
			end
		end
	end
end

function Public.update(config)
	Public.verify_update_fields(config)

	orbits.ensure_all_locations_have_orbits()

	local location = data.raw[config.type][config.name]

	for k, v in pairs(config) do
		if k == "orbit" then
			-- native origin processing during data-final-fixes
			if PlanetsLib.current_stage == "data-final-fixes" then
				update_final_orbit(location, v)
			else	-- standard processing during data and data-updates
				update_data_orbit(location, v)
			end
		elseif k == "special_properties" then
			error("PlanetsLib:update() - special_properties is an invalid field.")
			-- if not PlanetsLib.constants.planet_properties[config.name] then
			-- 		PlanetsLib.constants.planet_properties[config.name] = {}
			-- end
			-- for field,value in pairs(v) do

			-- 	PlanetsLib.constants.planet_properties[config.name][field] = value
			-- end
		else
			location[k] = v
		end
	end
end

-- TODO: Add checks to ensure the structure of orbit is correct.
function Public.verify_update_fields(config)
	if not config.name then
		error(
			"PlanetsLib:update() - 'name' field is required. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if (not config.type) or (not Public.is_space_location(config)) then
		error(
			"PlanetsLib:update() - type='planet' or type='space-location' is required. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if config.orbit and not Public.is_space_location(config.orbit.parent) then
		error(
			"PlanetsLib:update() - 'orbit.parent' must be a space location. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if config.distance then
		error(
			"PlanetsLib:update() - update 'orbit' instead of 'distance'. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if config.orientation then
		error(
			"PlanetsLib:update() - update 'orbit' instead of 'orientation'. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end

	if not data.raw[config.type][config.name] then
		error("PlanetsLib:update() - " .. config.type .. " not found: " .. config.name)
	end
end

--- Clones music tracks from source_planet to target_planet.
--- Does not overwrite existing music for target_planet.
--- Options specified in `options`:
--- track_types(table): Allows the selection of only tracks matching one or more track types.
--- modifier_function(function): Function applied to each borrowed track: Expected form: modifier_function = function(track) {Apply changes to track table here} end
-- @param source_planet
-- @param target_planet
-- @param options table Table of options (track_types)
function Public.borrow_music(source_planet, target_planet, options)
	assert(
		Public.is_space_location_or_space_platform(source_planet),
		"PlanetsLib.borrow_music() - Invalid parameter 'source_planet'. Field is required to be either `space-platform` or a `space-location` or `planet` prototype."
	)
	assert(
		Public.is_space_location_or_space_platform(target_planet),
		"PlanetsLib.borrow_music() - Invalid parameter 'target_planet'. Field is required to be either `space-platform` or a `space-location` or `planet` prototype."
	)

	if not options then
		options = {}
	end

	if options.modifier_function then
		assert(
			debug.getinfo(options.modifier_function, "u").nparams == 1,
			"options.modifier_function can only have one parameter."
		)
	end

	local source_name = source_planet.name or source_planet
	local target_name = target_planet.name or target_planet
	if source_name == target_name then
		return
	end

	if source_name == "space-platform" then
		source_name = nil
	end
	if target_name == "space-platform" then
		target_name = nil
	end

	for _, music in pairs(data.raw["ambient-sound"]) do
		if options.track_types and not PlanetsLib.rro.contains(options.track_types, music.track_type) then
			goto continue
		end

		local do_copy = false
		if not source_name then -- copy from space platform
			if not music.planets and not music.surface_names and not music.play_on_all_surfaces then
				do_copy = true
			end
		elseif PlanetsLib.rro.contains(music.planets, source_name) then 
			if target_name and not options.modifier_function then
				table.insert(music.planets, target_name) -- New in Factorio 2.1: Ambient sounds can be played for multiple planets, making borrow_music()'s old approach of copying tracks mostly obsolete. We will avoid making new tracks unless a modifier function is provided.
			else -- copy to space platform
				do_copy = true
			end
		end

		if do_copy then
			local copied_music = util.table.deepcopy(music)
			copied_music.name = music.name .. "-" .. (target_planet.name or target_planet)

			if target_name then
				copied_music.planets = { target_name }
			else
				copied_music.planets = nil
				copied_music.surface_names = nil
			end

			if options.modifier_function then
				options.modifier_function(copied_music) -- options.modifier_function gives the opportunity to apply changes to the track's parameters through a function.
			end

			data:extend({ copied_music })
		end
		::continue::
	end
end

--- This function sets `default_import_location` based on an item name and planet.
--- `default_import_location` is used by the space platform GUI to
--- define the default planet where an item will be imported from.
function Public.set_default_import_location(item_name, planet)
	for item_prototype in pairs(defines.prototypes.item) do
		local item = (data.raw[item_prototype] or {})[item_name]
		if item then
			item.default_import_location = planet
			return
		end
	end

	error("PlanetsLib.set_default_import_location() - Item not found: " .. item_name, 2)
end

--- PlanetsLib.set_special_properties(planet,properties)
--- Assigns special properties to a planet stored in a mod-data object.
--- Special properties are displayed as surface properties, but they are not intended to be used as surface properties.
--- Like vanilla's robot-energy-multiplier, these special properties influence the behavior of entities, either through data-final-fixes or through a runtime script.
--- Can be retrieved with PlanetsLib.get_special_property(planet,(string) property?)
--- Can not be called during data-final-fixes, to allow variables defined as special properties to be used by PlanetsLib for particular functions
--- List of special properties that PlanetsLib will use in the future::
--- rocket_part_multiplier: Multiplies the parts required by rocket silos by this value via entity replacements.
--- rocket_lift_multiplier: Multiplies the lift of rockets launched from rocket silos by this value via entity replacements.
function Public.set_special_properties(planet,properties)
	assert(PlanetsLib.current_stage ~= "data-final-fixes", "PlanetsLib.set_special_properties(planet,properties) - This function must be called before data-final-fixes.")
	local planet_name = type(planet) == "table" and planet.name or planet
	if not PlanetsLib.constants.planet_special_properties[planet_name] then
		PlanetsLib.constants.planet_special_properties[planet_name] = table.deepcopy(properties)
	else
		PlanetsLib.constants.planet_special_properties[planet_name] = PlanetsLib.rro.merge(
			PlanetsLib.constants.planet_special_properties[planet_name],
			table.deepcopy(properties)
		)
	end
	return PlanetsLib.constants.planet_special_properties[planet_name]
end

--- PlanetsLib.get_special_property(planet,property)
function Public.get_special_property(planet,property)
	local planet_name = type(planet) == "table" and planet.name or planet
	local properties = PlanetsLib.constants.planet_special_properties[planet_name]
	if property == nil then
		return properties
	end
	return properties and properties[property]
end

--- PlanetsLib.get_special_properties(planet)
function Public.get_special_properties(planet)
	local planet_name = type(planet) == "table" and planet.name or planet
	return PlanetsLib.constants.planet_special_properties[planet_name]
end

local function sorted_keys(tbl)
    local keys = {}

    for k in pairs(tbl) do
        keys[#keys + 1] = k
    end

    table.sort(keys)

    return keys
end


local radius_scaling_limit=1.25 --How much a sprite can be acceptably scaled by
Public.get_orbit_sprite = function(radius)
	error("PlanetsLib.get_orbit_sprite(): This function is now obsolete. Enable SpaceLocationPrototype::draw_orbit instead.")
end


return Public
