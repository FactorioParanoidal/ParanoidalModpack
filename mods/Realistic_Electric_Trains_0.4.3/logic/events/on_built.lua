--on_build.lua
--Event handler for entities being built

require("logic.positions")
require("logic.overhead_line")

do
	local placer_to_base = {
		["ret-pole-placer"] = "ret-pole-base",
		["ret-signal-pole-placer"] = "ret-signal-pole-base",
		["ret-chain-pole-placer"] = "ret-chain-pole-base"
	}

	function revive_or_create(surface, entity)
		local ghosts = surface.find_entities_filtered{
			ghost_name = entity.name, 
			area = around_position(entity.position, 0.1)
		}

		if ghosts[1] then
			local _, revived = ghosts[1].revive()
			-- As the pole decorators are placeable off-grid they sometimes
			-- move a tiny fraction to the side
			revived.teleport(entity.position)
			return revived
		end
		return surface.create_entity(entity)
	end


	-- initializes a newly placed pole. The entity can either be a placer or the
	-- pole base entity.
	function create_pole(entity, player)
		local entity_name = entity.name
		local pos = { x = entity.position.x, y = entity.position.y }
		local force = entity.force
		local direction = entity.direction
		local surface = entity.surface

		local pole

		if placer_to_base[entity_name] then
			-- Replace placer entity
			local pole_name, pole_direction = 
				fix_pole_build_name_and_dir(placer_to_base[entity_name], direction)

			pole = revive_or_create(surface, {
				name = pole_name,
				force = force,
				position = pos,
				direction = pole_direction,
				fast_replace = true
			})
		else
			-- The given entity is the base
			pole = entity
			direction = fix_pole_dir(pole)
		end

		-- create wire, power and the pole rendering element
		local wire_pos = wire_pos_for_pole(pole.position, direction)

		local wire = surface.create_entity {
			name = "ret-pole-wire",
			force = force,
			position = wire_pos
		}

		local power_name = "ret-pole-energy-straight"
		if direction % 2 == 1 then power_name = "ret-pole-energy-diagonal" end

		local power = revive_or_create(surface, {
			name = power_name,
			force = force,
			position = pos
		})

		local holder_name = "ret-pole-holder-straight"
		if direction % 2 == 1 then holder_name = "ret-pole-holder-diagonal" end

		local wire_holder = revive_or_create(surface, {
			name = holder_name,
			force = force,
			position = pos,
			direction = direction - (direction % 2)
		})


		-- Setup the connectivity check for the pole
		power.electric_buffer_size = config.pole_enable_buffer
		power.energy = 0

		-- store objects for fetching later
		global.wire_for_pole[pole.unit_number] = wire
		global.power_for_pole[pole.unit_number] = power
		global.graphic_for_pole[pole.unit_number] = wire_holder


		-- connect to the next poles
		install_pole(pole, {
				show_failures = enable_failure_text, 
				show_particles = enable_connect_particles,
				install_circuit_wire = true,
				remove_other_wires = remove_wires_on_build
		}, nil, player)

		if enable_rewire_neighbours then
			rewire_neighbours(pole)
		end
	end

	-- Registers the given locomotive entity in the global table
	function register_locomotive(locomotive)
		table.insert(global.electric_locos, locomotive)
	end

	-- Updates nearby poles when a rail is placed down
	function add_rail(rail)
		update_poles_near_rail(rail)
	end

	-- Deletes duplicate ghosts that have been placed over existing pole 
	-- decorators due to small differences in position for off-grid entities
	function delete_duplicate_ghosts(ghost)
		local n = ghost.ghost_name
		if n == "ret-pole-energy-straight" or n == "ret-pole-energy-diagonal" or
		   n == "ret-pole-holder-straight" or n == "ret-pole-holder-diagonal" then
				local other = ghost.surface.find_entities_filtered{
					area = around_position(ghost.position, 0.1), name = n
				}
				if other[1] then
					ghost.destroy()
					return
				end
				local other = ghost.surface.find_entities_filtered{
					area = around_position(ghost.position, 0.1), ghost_name = n
				}
				if other[1] then
					ghost.destroy()
					return
				end
		end
	end

	local is_placer_or_base = {
		["ret-pole-placer"] = true,
		["ret-signal-pole-placer"] = true,
		["ret-chain-pole-placer"] = true,
		["ret-pole-base-straight"] = true,
		["ret-pole-base-diagonal"] = true,
		["ret-signal-pole-base"] = true,
		["ret-chain-pole-base"] = true
	}

	-- Handles the events on_built_entity & on_robot_built_entity
	--  & script_raised_built (contains event.entity)
	function on_entity_built(event)
		local e = event.created_entity or event.entity
		local n = e.name

			if is_placer_or_base[n] then
				create_pole(e, event.player_index)

			elseif global.electric_loco_registry[n] then
				register_locomotive(e)

			elseif e.type == "straight-rail" or e.type == "curved-rail" then
				add_rail(e)

			elseif n == "entity-ghost" then
				delete_duplicate_ghosts(e)
			end
	end
end

return on_entity_built
