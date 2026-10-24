-- Run in an isolated Factorio profile by appending require("tests.gui-closed")
-- to the copied Cybersyn control.lua, then load a copy of a save with a player.
-- Uses real GUI elements and registered handlers.
local manager = require("scripts.gui.main")

script.on_nth_tick(1, function()
	script.on_nth_tick(1, nil)
	local player = assert(game.players[1], "test save must contain a player")
	if not storage.manager.players[player.index] then
		manager.on_player_created({ player_index = player.index })
	end
	local player_data = storage.manager.players[player.index]
	local close = script.get_event_handler(defines.events.on_gui_closed)
	local shortcut = script.get_event_handler(defines.events.on_lua_shortcut)
	local input = script.get_event_handler("cybersyn-toggle-gui")
	local results = { passed = true, cases = {} }
	local function check(name, run)
		local ok, err = pcall(run)
		results.cases[#results.cases + 1] = { name = name, passed = ok, error = not ok and tostring(err) or nil }
		if not ok then results.passed = false end
	end
	local function close_event(element)
		return {
			name = defines.events.on_gui_closed,
			player_index = player.index,
			gui_type = defines.gui_type.custom,
			element = element,
			tick = game.tick,
		}
	end
	check("combinator close destroys its window without crashing the manager", function()
		local comb = player.surface.create_entity({
			name = COMBINATOR_NAME,
			position = { 100, 100 },
			force = player.force,
			raise_built = true,
		})
		assert(comb and comb.valid, "test combinator was not created")
		local open = script.get_event_handler(defines.events.on_gui_opened)
		open({
			name = defines.events.on_gui_opened,
			player_index = player.index,
			gui_type = defines.gui_type.entity,
			entity = comb,
			tick = game.tick,
		})
		local window = player.gui.screen[COMBINATOR_NAME]
		assert(window and window.valid, "combinator window did not open")
		close(close_event(window))
		assert(not window.valid, "combinator window remained open")
		assert(not player_data.is_manager_open, "combinator close opened the manager")
	end)
	check("shortcut opens the manager and closing its window hides it", function()
		shortcut({ prototype_name = "cybersyn-toggle-gui", player_index = player.index })
		assert(player_data.is_manager_open and player_data.refs.manager_window.visible, "manager did not open")
		close(close_event(player_data.refs.manager_window))
		assert(not player_data.is_manager_open and not player_data.refs.manager_window.visible, "manager did not close")
	end)
	check("keyboard input still opens and closes the manager", function()
		input({ input_name = "cybersyn-toggle-gui", player_index = player.index })
		assert(player_data.is_manager_open, "keyboard input did not open the manager")
		input({ input_name = "cybersyn-toggle-gui", player_index = player.index })
		assert(not player_data.is_manager_open, "keyboard input did not close the manager")
	end)
	helpers.write_file("cybersyn-gui-closed.json", helpers.table_to_json(results))
end)
