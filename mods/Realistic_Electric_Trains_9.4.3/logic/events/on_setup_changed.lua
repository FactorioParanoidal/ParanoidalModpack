--on_setup_changed.lua
--Event handler for caching the runtime settings and updating when configuration changes

function on_settings_changed(event)
	ticks_per_update = settings.startup["ret-ticks-per-update"].value

	enable_connect_particles = settings.global["ret-enable-connect-particles"].value
	enable_failure_text = settings.global["ret-enable-failure-text"].value
	enable_modular_info = settings.global["ret-enable-modular-info"].value
	enable_zigzag_wire = settings.global["ret-enable-zigzag-wire"].value
	enable_zigzag_vertical_only = settings.global["ret-enable-zigzag-vertical-only"].value
	remove_wires_on_build = settings.global["ret-remove-wires-on-build"].value
	enable_circuit_wire = settings.global["ret-enable-circuit-wire"].value
	enable_rewire_neighbours = settings.global["ret-enable-rewire-neighbours"].value
	max_pole_search_distance = settings.global["ret-max-pole-search-distance"].value
end

function on_configuration_changed(event)
	if event.mod_changes.Realistic_Electric_Trains then
		ingame_migration(event)
	end

	if not global.fuel_for_loco then
		global.fuel_for_loco = {}
	end

	if not global.electric_loco_registry then
		global.electric_loco_registry = {}
		global.electric_loco_registry["ret-electric-locomotive"] = "ret-dummy-fuel-1"
		global.electric_loco_registry["ret-electric-locomotive-mk2"] = "ret-dummy-fuel-2"
		global.electric_loco_registry["ret-modular-locomotive"] = "ret-dummy-fuel-modular"
	end
end

-- Performs migration with the global table
function ingame_migration(event)
	local changes = event.mod_changes.Realistic_Electric_Trains
	local old_version = changes.old_version

	if not old_version or old_version < "0.2.0" then
		-- Changing the pole-energy entities to energy-straight and energy-diagonal
		local rail_mapping = {}
		for k, v in pairs(global.power_for_rail) do
			if v.valid then
				rail_mapping[k] = v.unit_number
			else
				global.power_for_rail[k] = nil
			end
		end 

		local new_entities = {}
		local count = 0
		for key, old_entity in pairs(global.power_for_pole) do
			if old_entity.valid and old_entity.name == "ret-pole-energy-straight" then
				local surface = old_entity.surface
				local position = old_entity.position
				local name = "ret-pole-energy-straight"
				local base = surface.find_entities_filtered{
					position = position,
					name = {"ret-pole-base-straight", "ret-pole-base-diagonal", 
							"ret-signal-pole-base", "ret-chain-pole-base"}}
				if base[1] and (base[1].direction % 2 == 1 or base[1].name == "ret-pole-base-diagonal") then 
					name = "ret-pole-energy-diagonal"
				end
				count = count + 1
				local force = old_entity.force 
				local unit_number = old_entity.unit_number
				local buffer = old_entity.electric_buffer_size
				local energy = old_entity.energy
				
				old_entity.destroy()
				local new_entity = surface.create_entity {
					name = name, 
					position = position,
					force = force
				}
				new_entity.electric_buffer_size = buffer
				new_entity.energy = energy
				new_entities[unit_number] = new_entity
				global.power_for_pole[key] = new_entity
			else
				global.power_for_pole[key] = nil
			end
		end

		for k, v in pairs(global.power_for_rail) do
			global.power_for_rail[k] = new_entities[rail_mapping[k]]
		end

		-- Changing the electric_locos map to an array
		local new_array = {}
		for _, loco in pairs(global.electric_locos) do
			table.insert(new_array, loco)
		end
		global.electric_locos = new_array

		game.print(string.format("Migrated Realistic Electric Trains from %s: Replaced %d entities", old_version, count))
		old_version = "0.2.0"
	end
end

