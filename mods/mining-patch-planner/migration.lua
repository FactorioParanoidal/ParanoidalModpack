local current_version = require("mpp.version")
local conf = require("configuration")
local enums = require("mpp.enums")

-- resetting a GUI manually from console
-- /c __mining-patch-planner__ game.player.gui.screen.mpp_settings_frame.destroy()

---@param player LuaPlayer
local function reset_gui(player, player_data)
	local root = player.gui.left["mpp_settings_frame"] or player.gui.screen["mpp_settings_frame"]
	if root then
		root.destroy()
	end
	local cursor_stack = player.cursor_stack
	if cursor_stack and cursor_stack.valid and cursor_stack.valid_for_read and cursor_stack.name == "mining-patch-planner" then
		cursor_stack.clear()
	end
	
	player_data.gui = {
		section = {},
		tables = {},
		selections = {},
		advanced_settings = nil,
		filtering_settings = nil,
		blueprint_add_button = nil,
		blueprint_add_section = nil,
		blueprint_receptacle = nil,
		layout_dropdown = nil,
		quality_toggle = nil,
	}
end

script.on_configuration_changed(function(config_changed_data)
	local version = storage.version or 0
	storage.version = current_version
	local game_players = game.players
	
	if version < 010700 then -- do a clean slate before 1.7
		rendering.clear("mining-patch-planner")
		
		if storage.players then
			for player_index, data in pairs(storage.players) do
				local mpp_root = game_players[player_index].gui.screen.mpp_settings_frame
				if mpp_root and mpp_root.valid then
					mpp_root.destroy()
				end
				
				---@cast data PlayerData
				data.last_state = nil
				local bp_inventory = data.blueprint_items
				if bp_inventory and bp_inventory.valid then
					bp_inventory.destroy()
				end
			end
		end
		
		local scr_inv = storage.script_inventory
		if scr_inv and scr_inv.valid then
			scr_inv.destroy()
		end
		
		local t = List()
		for k, _ in pairs(storage) do
			t:push(k)
		end
		for _, key in ipairs(t) do
			storage[key] = nil
		end
		
		conf.initialize_storage()
	end
	
	if version < 010706 then
		if storage.tasks and #storage.tasks > 1 then
			for k, state in pairs(storage.tasks) do
				if state._preview_rectangle and state._preview_rectangle.valid then
					state._preview_rectangle.destroy()
				end
			end
			storage.tasks = {}
		end
	end
	
	if config_changed_data.mod_changes["mining-patch-planner"] and version < current_version then
		storage.tasks = storage.tasks or {}
		conf.initialize_deconstruction_filter()
		for player_index, data in pairs(storage.players) do
			---@cast data PlayerData
			local player = game_players[player_index]
			reset_gui(player, data)
			--conf.initialize_global(player_index)
			conf.update_player_data(player_index)
			conf.update_player_quality_data(player_index)
		end
	else
		for player_index, data in pairs(storage.players) do
			reset_gui(game_players[player_index], data)
			conf.update_player_quality_data(player_index)
		end
	end
	
end)
