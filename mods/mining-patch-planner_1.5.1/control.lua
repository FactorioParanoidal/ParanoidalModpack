local conf = require("configuration")
local compatibility = require("compatibility")
require("migration")
local gui = require("gui")
local algorithm = require("algorithm")
local bp_meta = require("blueprintmeta")

---@class __MiningPatchPlanner__global
---@field tasks any

script.on_init(function()
	global.players = {}
	---@type State[]
	global.tasks = {}
	conf.initialize_deconstruction_filter()

	for _, player in pairs(game.players) do
		conf.initialize_global(player.index)
	end
end)

---@param event EventData
local function task_runner(event)
	if #global.tasks == 0 then
		return script.on_event(defines.events.on_tick, nil)
	end

	local state = global.tasks[1]
	local layout = algorithm.layouts[state.layout_choice]

	local tick_result = layout:tick(state)
	if tick_result == nil then
		error("Layout "..state.layout_choice.." missing a callback name")
	elseif tick_result == false then
		local player = state.player
		if state.blueprint then state.blueprint.clear() end
		if state.blueprint_inventory then state.blueprint_inventory.destroy() end
		rendering.destroy(state._preview_rectangle)

		---@type PlayerData
		local player_data = global.players[player.index]
		player_data.last_state, state._previous_state = state, nil

		table.remove(global.tasks, 1)
		player.play_sound{path="utility/build_blueprint_medium"}
	elseif tick_result ~= true then
		state._callback = tick_result
	end
end

script.on_event(defines.events.on_player_selected_area, function(event)
	---@cast event EventData.on_player_selected_area
	local player = game.get_player(event.player_index)
	if not player then return end
	local cursor_stack = player.cursor_stack
	if not cursor_stack or not cursor_stack.valid or not cursor_stack.valid_for_read then return end
	if cursor_stack and cursor_stack.valid and cursor_stack.valid_for_read and cursor_stack.name ~= "mining-patch-planner" then return end

	if #event.entities == 0 then return end

	for _, task in ipairs(global.tasks) do
		if task.player == player then
			return
		end
	end

	local state, error = algorithm.on_player_selected_area(event)

	--rendering.clear("mining-patch-planner")

	if state then
		table.insert(global.tasks, state)
		script.on_event(defines.events.on_tick, task_runner)
	elseif error then
		player.print(error)
	end
end)

script.on_load(function()
	if global.players then
		for _, ply in pairs(global.players) do
			---@cast ply PlayerData
			if ply.blueprints then
				for _, bp in pairs(ply.blueprints.cache) do
					setmetatable(bp, bp_meta)
				end
			end
		end
	end

	if global.tasks and #global.tasks > 0 then
		script.on_event(defines.events.on_tick, task_runner)
		for _, task in ipairs(global.tasks) do
			---@type Layout
			local layout = algorithm.layouts[task.layout_choice]
			layout:on_load(task)
		end
	end
end)

local function cursor_stack_check(e)
	local player = game.get_player(e.player_index)
	if not player then return end
	---@type PlayerData
	local player_data = global.players[e.player_index]
	if not player_data then return end
	local frame = player.gui.screen["mpp_settings_frame"]
	if player_data.blueprint_add_mode and frame and frame.visible then
		return
	end

	local cursor_stack = player.cursor_stack
	if (cursor_stack and
		cursor_stack.valid and
		cursor_stack.valid_for_read and
		cursor_stack.name == "mining-patch-planner"
	) then
		gui.show_interface(player)
		algorithm.on_gui_open(player_data)
	else
		gui.hide_interface(player)
		algorithm.on_gui_close(player_data)
	end
end

script.on_event(defines.events.on_player_cursor_stack_changed, cursor_stack_check)

script.on_event(defines.events.on_player_changed_surface, cursor_stack_check)

do
	local events = compatibility.get_se_events()
	for k, v in pairs(events) do
		script.on_event(v, cursor_stack_check)
	end
end

-- script.on_event(defines.events.on_player_main_inventory_changed, function(e)
-- 	--change_handler(e)
-- end)
