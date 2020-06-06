if not pc then
	pc = {
		config = {
			debug = false,
			data_update_interval = 600, --drd 60
			pollution_values_count = 60 -- keep that count of pollution values
		},
		button = nil,
		up = "↑",
		down = "↓",
		eq = "=",
		separator = '.',
		current_pollution_index = 0,
		pollution_values = {},
		pollution_average = {},
		pollution_deltas = {}
	}
end

local function format_value(num)
	local a = string.format('%d', num)
	n = #a % 3
	if n==0 then
		n=3
	else
		if n==1 and num<0 then
			n=4
		end
	end
	s1 = string.sub(a, 0, n)
	s2 = string.sub(a, n+1)
	return s1 .. s2:gsub("...", pc.separator .. '%1')
end

script.on_event(defines.events.on_tick, function()
	if game.tick % pc.config.data_update_interval ~= 0 then
		return
	end

	-- calculate pollution for all surfaces
	for i, surface in pairs(game.surfaces) do
		if not pc.pollution_values[surface.name] then
			pc.pollution_values[surface.name] = {}
			pc.pollution_average[surface.name] = 0.0
			pc.pollution_deltas[surface.name] = 0.0
			if pc.config.debug then
				game.players[1].print(string.format("PC > Surface %s created, current index: %d", surface.name, pc.current_pollution_index))
			end
		end
		local current_pollution = calc_pollution(surface)
		pc.pollution_values[surface.name][pc.current_pollution_index] = current_pollution

		-- recalculate average pollution value for surface
		local sum = 0.0
		for k, v in pairs(pc.pollution_values[surface.name]) do
			sum = sum + v
		end

		pc.pollution_average[surface.name] = sum / (#pc.pollution_values[surface.name] + 1)

		if pc.pollution_average[surface.name] ~= 0.0 then
			pc.pollution_deltas[surface.name] = (current_pollution - pc.pollution_average[surface.name]) / pc.pollution_average[surface.name]
		end
	end

	-- Show pollution values
	for i, player in pairs(game.players) do
		if player.gui.top.pc_button == nil then
			player.gui.top.add{type="button", name="pc_button"}
		end

		local is_changed = false
		if math.abs(pc.pollution_deltas[player.surface.name]) > 0.01 then
			is_changed = true
		end

		local char = pc.eq
		if is_changed then
			-- if current pollution is greater than average
			if pc.pollution_values[player.surface.name][pc.current_pollution_index] > pc.pollution_average[player.surface.name] then
				char = pc.up
			else
				char = pc.down
			end
		end
		player.gui.top.pc_button.caption = string.format("∑= %s %s %.2f", format_value(pc.pollution_average[player.surface.name]), char, pc.pollution_deltas[player.surface.name])
	end

	pc.current_pollution_index = pc.current_pollution_index + 1
	if pc.current_pollution_index >= pc.config.pollution_values_count then pc.current_pollution_index = 0 end
end)

function calc_pollution(surface)
	local pollution = 0.0
	for coord in surface.get_chunks() do
		pollution = pollution + surface.get_pollution({coord.x * 32, coord.y * 32})
	end
	return pollution
end

function isNAN(value)
	return value ~= value
end
