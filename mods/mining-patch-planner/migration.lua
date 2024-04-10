local conf = require("configuration")
local enums = require("mpp.enums")

local current_version = 010600 -- 1.6.0

-- resetting a GUI manually from console
-- /c __mining-patch-planner__ game.player.gui.screen.mpp_settings_frame.destroy()

---@param player LuaPlayer
local function reset_gui(player)
	local root = player.gui.left["mpp_settings_frame"] or player.gui.screen["mpp_settings_frame"]
	if root then
		root.destroy()
	end
	local cursor_stack = player.cursor_stack
	if cursor_stack and cursor_stack.valid and cursor_stack.valid_for_read and cursor_stack.name == "mining-patch-planner" then
		cursor_stack.clear()
	end
end

script.on_configuration_changed(function(config_changed_data)
	local version = global.version or 0
	if config_changed_data.mod_changes["mining-patch-planner"] and version < current_version then
		global.tasks = global.tasks or {}
		conf.initialize_deconstruction_filter()
		for player_index, data in pairs(global.players) do
			---@cast data PlayerData
			local player = game.players[player_index]
			reset_gui(player)
			--conf.initialize_global(player_index)
			conf.update_player_data(player_index)
		end
	else
		for player_index, data in pairs(global.players) do
			reset_gui(game.players[player_index])
		end
	end

	if version < 010504 then
		rendering.clear("mining-patch-planner")
	end

	if version < 010600 then
		for player_index, data in pairs(global.players) do
			---@cast data PlayerData
			local blueprints = data.blueprints
			local bp_inventory = data.blueprint_items

			for k, v in pairs(blueprints.flow) do
				v.destroy()
			end

			if bp_inventory and bp_inventory.valid then
				bp_inventory.clear()
				bp_inventory.resize(1)
			end

			blueprints.original_id = {}
			blueprints.mapping = {}
			blueprints.cache = {}
			blueprints.flow = {}
			blueprints.button = {}
			blueprints.delete = {}
			blueprints.original_id = {}
		end
	end

	global.version = current_version
end)
