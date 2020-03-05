--on_remove.lua
--Event handler for entities being destroyed

do

	-- Removes a pole and deletes all child entities
	function destroy_pole(pole)
		-- disconnect from neighbours
		uninstall_pole(pole, enable_connect_particles)

		-- remove wire, power and graphic
		local wire = global.wire_for_pole[pole.unit_number]
		if wire and wire.valid then wire.destroy() end
		global.wire_for_pole[pole.unit_number] = nil

		local power = global.power_for_pole[pole.unit_number]
		if power and power.valid then power.destroy() end
		global.power_for_pole[pole.unit_number] = nil

		local graphic = global.graphic_for_pole[pole.unit_number]
		if graphic and graphic.valid then graphic.destroy() end
		global.graphic_for_pole[pole.unit_number] = nil
	end

	-- Removes a locomotive from the global table
	function deregister_locomotive(locomotive)
		local id = locomotive.unit_number
		for n, loco in ipairs(global.electric_locos) do
			if loco.unit_number == id then
				table.remove(global.electric_locos, n)
				break
			end
		end
		global.fuel_for_loco[locomotive.unit_number] = nil
	end

	-- Unpowers a track segment when a rail is removed
	function remove_rail(rail)
		local power_provider = global.power_for_rail[rail.unit_number]
		if power_provider and power_provider.valid then
			unpower_nearby_rails(rail)
		end
	end

	-- Handles the events on_entity_died, on_pre_player_mined_item & on_robot_pre_mined
	function on_entity_removed(event)
		local e = event.entity
		local n = e.name

		if n == "ret-pole-base-straight" or
		   n == "ret-pole-base-diagonal" or
		   n == "ret-signal-pole-base" or
		   n == "ret-chain-pole-base" then
				destroy_pole(e)

		elseif global.electric_loco_registry[n] then
				deregister_locomotive(e)

		elseif e.type == "straight-rail" or e.type == "curved-rail" then
				remove_rail(e)
		end
	end

end

return on_entity_removed
