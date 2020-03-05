--overhead_line.lua

require("util")
require("config")
require("rail_search")

function respawn_pole_children(pole)
	local wire = global.wire_for_pole[pole.unit_number]
	if not wire or not wire.valid then
		local wire_pos = wire_pos_for_pole(pole.position, fix_pole_dir(pole))
		global.wire_for_pole[pole.unit_number] = pole.surface.create_entity {
			name = "ret-pole-wire",
			force = pole.force,
			position = wire_pos
		}
	end

	local power = global.power_for_pole[pole.unit_number]
	if not power or not power.valid then
		local power_name = "ret-pole-energy-straight"
		if fix_pole_dir(pole) % 2 == 1 then power_name = "ret-pole-energy-diagonal" end

		local new_power = pole.surface.create_entity{
			name = power_name,
			force = pole.force,
			position = pole.position
		}

		new_power.electric_buffer_size = config.pole_enable_buffer

		global.power_for_pole[pole.unit_number] = new_power
	end

	local holder = global.graphic_for_pole[pole.unit_number]
	if not holder or not holder.valid then
		local direction = fix_pole_dir(pole)
		local holder_name = "ret-pole-holder-straight"
		if direction % 2 == 1 then holder_name = "ret-pole-holder-diagonal" end

		global.graphic_for_pole[pole.unit_number] = pole.surface.create_entity{
			name = holder_name,
			force = pole.force,
			position = pole.pos,
			direction = direction - (direction % 2)
		}
	end
end


-- Displays particles on the rail according to the powered parameter
function display_powered_state(rail, powered)
	local surface = rail.surface

	local e = surface.find_entity("ret-disconnected-particle", rail.position)
	if e then e.destroy() end
	e = surface.find_entity("ret-connected-particle", rail.position)
	if e then e.destroy() end

	local particle = "ret-disconnected-particle"
	if powered then particle = "ret-connected-particle" end

	surface.create_entity {
		name = particle,
		position = rail.position,
		movement = {0, 0},
		height = 0,
		vertical_speed = 0,
		frame_speed = 0
	}
end

-- Marks all rails in the successful search results as powered 
function mark_powered_rails(pole, search_results, show_particles)
	for _, success in ipairs(search_results.success) do
		local other_pole = success.pole
		for _, rail in ipairs(success.path) do
			local d1 = util.distance(rail.position, pole.position)
			local d2 = util.distance(rail.position, other_pole.position)
			if d1 <= d2 then
				global.power_for_rail[rail.unit_number] = global.power_for_pole[pole.unit_number]
			else
				global.power_for_rail[rail.unit_number] = global.power_for_pole[other_pole.unit_number]	
			end
			if show_particles then
				display_powered_state(rail, true)
			end
		end
	end
end

-- Marks all rails in the successful search results as unpowered
function remove_powered_rails(search_results, show_particles)
	for _, success in pairs(search_results.success) do
		for _, rail in pairs(success.path) do
			global.power_for_rail[rail.unit_number] = nil
			if show_particles then
				display_powered_state(rail, false)
			end
		end
	end
end

-- Deletes all copper wires to other poles and reconnects only neighboring poles
function rewire_pole(pole, search_results, circuit_wire, remove_other_lines)
	-- disconnect all wires to neighbour overhead lines
	local wire = global.wire_for_pole[pole.unit_number]

	if not wire or not wire.valid then
		respawn_pole_children(pole)
		wire = global.wire_for_pole[pole.unit_number]
	end

	for _, neighbour in pairs(wire.neighbours.copper) do
		if neighbour.name == "ret-pole-wire" or remove_other_lines then
			wire.disconnect_neighbour(neighbour)
		end
	end

	-- reconnect proper wires
	for _, success in pairs(search_results.success) do
		local neighbour = global.wire_for_pole[success.pole.unit_number]
		if not neighbour or not neighbour.valid then
			respawn_pole_children(success.pole)
			neighbour = global.wire_for_pole[success.pole.unit_number]
		end
		wire.connect_neighbour(neighbour)

		if enable_circuit_wire and circuit_wire then
			pole.connect_neighbour(
				{wire = defines.wire_type.red, target_entity = success.pole})
			pole.connect_neighbour(
				{wire = defines.wire_type.green, target_entity = success.pole})
		end
	end
end

-- Calls rewire_pole on all the neighbours of this pole
function rewire_neighbours(pole)
	local search_results = search_next_poles(pole, config.pole_max_wire_distance)
	for _, success in pairs(search_results.success) do
		local new_search = search_next_poles(success.pole, config.pole_max_wire_distance)
		rewire_pole(success.pole, new_search)
	end
end

-- Displays a message for all failed search_results
function display_failures(pole, search_results, player)
	for _, failure in pairs(search_results.failure) do 
		if failure.curve then
			rendering.draw_text {
				text = {"message.ret-connect-failure"},
				surface = failure.pole.surface,
				target = failure.pole,
				target_offset = {0, 0},
				scale_with_zoom = true,
				color = {r=1, g=0.25},
				players = {player},
				time_to_live = 240
			}
			rendering.draw_text {
				text = {"message.ret-connect-failure-curve"},
				surface = failure.pole.surface,
				target = failure.pole,
				target_offset = {0.5, 0.5},
				scale_with_zoom = true,
				color = {r=1, g=0.5},
				players = {player},
				time_to_live = 240
			}
		else
			local distance = util.distance(failure.pole.position, pole.position)
			local too_far = math.ceil(distance - config.pole_max_wire_distance)
			rendering.draw_text {
				text = {"message.ret-connect-failure"},
				surface = failure.pole.surface,
				target = failure.pole,
				target_offset = {0, 0},
				scale_with_zoom = true,
				color = {r=1, g=0.25},
				players = {player},
				time_to_live = 240
			}
			rendering.draw_text {
				text = {"message.ret-connect-failure-distance", too_far},
				surface = failure.pole.surface,
				target = failure.pole,
				target_offset = {0.5, 0.5},
				scale_with_zoom = true,
				color = {r=1, g=0.5},
				players = {player},
				time_to_live = 240
			}
		end
	end
end

-- Moves the wires so that a zigzag pattern is created
function zigzag_pole_wire(start_pole, search_results)
	local other_nonstandard = 0
	local has_straight = false
	local has_vertical

	for _, success in pairs(search_results.success) do
		if not success.has_curve then
			has_straight = true
			has_vertical = success.path[1].direction == defines.direction.north
			local pole = success.pole
			local wire = global.wire_for_pole[pole.unit_number]
			if not wire or not wire.valid then
				respawn_pole_children(pole)
				wire = global.wire_for_pole[pole.unit_number]
			end
			local mode = find_wire_mode(pole, wire)
			if mode ~= 2 then
				if other_nonstandard == 0 then
					other_nonstandard = mode
				elseif other_nonstandard ~= mode then
					other_nonstandard = 2
				end
			end
		end
	end

	local invert = {[0] = 3, [1] = 3, [2] = 2, [3] = 1}

	if has_straight and (has_vertical or not enable_zigzag_vertical_only) then
		local wire = global.wire_for_pole[start_pole.unit_number]
		if not wire or not wire.valid then
			respawn_pole_children(pole)
			wire = global.wire_for_pole[pole.unit_number]
		end
		local position = wire_pos_for_pole(start_pole.position, 
							fix_pole_dir(start_pole), invert[other_nonstandard])
		wire.teleport(position)
	end
end

-- Powers rails up to the next poles. Options may contain show_failures,
-- show_particles and/or install_circuit_wire
function install_pole(pole, options, ignore, player) 
	local next_poles = search_next_poles(pole, config.pole_max_wire_distance, ignore)
	if options.show_failures and player then display_failures(pole, next_poles, player) end
	mark_powered_rails(pole, next_poles, options.show_particles)
	if enable_zigzag_wire then zigzag_pole_wire(pole, next_poles) end
	rewire_pole(pole, next_poles, options.install_circuit_wire, options.remove_other_wires)
end

-- Unpowers rails up to the next poles.
function uninstall_pole(pole, show_particles)
	local next_poles = search_next_poles(pole, config.pole_max_wire_distance)
	remove_powered_rails(next_poles, show_particles)
	for _, success in pairs(next_poles.success) do
		install_pole(success.pole, {show_particles = show_particles}, pole)
	end
end

-- Returns a power provider for the given locomotive or nil if none was found
function find_power_provider(locomotive)
	local surface = locomotive.surface
	local entities = surface.find_entities(around_position(locomotive.position, 1))
	local lookup = global.power_for_rail

	for _, entity in pairs(entities) do
		local power = lookup[entity.unit_number]
		if power and power.valid then return power end
	end
	return nil
end

-- Installs poles next to the given rail entity
function update_poles_near_rail(rail, player)
	local nearby_poles = search_nearby_poles(rail, config.pole_max_wire_distance / 2 + 2)
	for _, success in pairs(nearby_poles.success) do
		install_pole(success.pole, {show_particles = enable_connect_particles})
	end
end

-- Unpowers the section of rail up to the next poles.
function unpower_nearby_rails(rail)
	local nearby_poles = search_nearby_poles(rail, config.pole_max_wire_distance / 2 + 2)
	for _, success in pairs(nearby_poles.success) do
		for _, spot in pairs(success.path) do
			global.power_for_rail[spot.unit_number] = nil
			if enable_connect_particles then display_powered_state(spot, false) end
		end
		install_pole(success.pole, {}, rail)
	end
end
