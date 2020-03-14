--on_tick.lua
-- Tick handler

do

	function on_tick(event)
		-- Power all locomotives
		local offset = event.tick % ticks_per_update
		local locos = global.electric_locos

		local locos_to_remove = {}

		for i = #locos - offset, 1, -ticks_per_update do
			if locos[i].valid and global.electric_loco_registry[locos[i].name] then
				update_locomotive(locos[i])
			else
				-- delete locomotives that cannot be updated anymore
				table.insert(locos_to_remove, i)
			end
		end

		-- locos_to_remove is ordered descending, thus we can simply remove the
		-- indices one after another without risking id issues.
		for _, remove in ipairs(locos_to_remove) do
			table.remove(locos, remove)
		end

	end



	function get_fuel_data(locomotive)
		local fuel_item = global.electric_loco_registry[locomotive.name]

		if fuel_item then
			if fuel_item == "ret-dummy-fuel-modular" then
				-- Find the correct modular fuel if requested
				local c = get_module_counts(locomotive)
				local suffix = get_module_string(c.s, c.p, c.e, c.b)
				local stats = get_module_stats(c.s, c.p, c.e, c.b)
				local proto = game.item_prototypes["ret-dummy-fuel-modular-" .. suffix]
				if not proto then
					proto = game.item_prototypes["ret-dummy-fuel-modular-"]
				end
				return {
					item = proto,
					power = stats.power,
					transfer = calc_transfer_rate(locomotive.name) * stats.power
				}
			else

				-- Use the given item
				local proto = game.item_prototypes[fuel_item]
				return {
					item = proto,
					power = 1,
					transfer = calc_transfer_rate(locomotive.name)
				}
			end
		else
			return nil
		end
	end


	function calc_transfer_rate(prototype_name) 
		local prototype = game.entity_prototypes[prototype_name]
		local efficiency_modifier = 1.05
		if prototype.burner_prototype.effectivity < 1 then
			efficiency_modifier = efficiency_modifier / prototype.burner_prototype.effectivity
		end
		-- max_energy_usage is in J/t instead of J/s as in data
		return prototype.max_energy_usage * efficiency_modifier * ticks_per_update
	end


	function update_locomotive(loco)
		local burner = loco.burner

		-- Get fuel data for this specific locomotive
		local fuel_data = global.fuel_for_loco[loco.unit_number]
		local updated = false
		if not fuel_data then
			updated = true
			fuel_data = get_fuel_data(loco)
			global.fuel_for_loco[loco.unit_number] = fuel_data
			--game.print(string.format("Updated %d with %s", loco.unit_number, fuel_data.item.name))
		end

		if not fuel_data then return end

		-- Refresh the burning item when the type was changed or the fuel ran out
		if burner.remaining_burning_fuel <= 0 or updated then
			burner.currently_burning = fuel_data.item
		end

		-- Calculate the missing energy and multiply in the power factor of this locomotive
		local missing_energy = (fuel_data.item.fuel_value - burner.remaining_burning_fuel) * fuel_data.power
		if missing_energy > 0 then
			local power_provider = find_power_provider(loco)

			if power_provider then
				local charge = take_power(power_provider, missing_energy, fuel_data.transfer)
				if charge > 0 then
					burner.remaining_burning_fuel =
							burner.remaining_burning_fuel + charge / fuel_data.power
				end
			end
		end
	end


	local enable_buffer = config.pole_enable_buffer

	function take_power(power_provider, missing_energy, max_transfer)
		if power_provider.energy >= enable_buffer then
			-- pole is powered, we can draw some power from it
			local requested = math.min(missing_energy, max_transfer)

			-- take stored power immediately
			local power = math.min(requested, power_provider.energy - enable_buffer)
			power_provider.energy = power_provider.energy - power

			-- if still more power is needed, increase the buffer to at most double
			-- the maximum transfer (double is needed for two consecutive locos)
			-- otherwise, reduce buffer size as much as possible
			requested = requested - power
			if requested > 0 then
				local max_buffer = max_transfer * 2 + enable_buffer
				local buffer_increase = math.min(requested, max_buffer - power_provider.electric_buffer_size)
				power = power + buffer_increase
				power_provider.electric_buffer_size = power_provider.electric_buffer_size + buffer_increase
			else
				local deficit = power_provider.electric_buffer_size - power_provider.energy
				power_provider.electric_buffer_size = deficit + enable_buffer
				power_provider.energy = enable_buffer
			end

			return power
		else
			-- no power can be drawn
			return 0
		end
	end
end


return on_tick
