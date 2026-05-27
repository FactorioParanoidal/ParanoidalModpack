local mpp_util = require("mpp.mpp_util")
local belt_planner = require("mpp.belt_planner")

local task_runner = {}

function task_runner.mining_patch_task(state)
	local layout = algorithm.layouts[state.layout_choice]

	local last_callback = state._callback
	---@type TickResult
	local tick_result

	if not __DebugAdapter then
		tick_result = layout:tick(state)
	else
		local success
		success, tick_result = pcall(layout.tick, layout, state)
		if success == false then
			game.print(tick_result)
			tick_result = false
		end
	end

	if last_callback == tick_result then
		if __DebugAdapter then
			table.remove(storage.tasks, 1)
		else
			error("Layout "..state.layout_choice.." step "..tostring(tick_result).." called itself again")
		end
	elseif tick_result == nil then
		if __DebugAdapter then
			game.print(("Callback for layout %s after call %s has no result"):format(state.layout_choice, state._callback))
			table.remove(storage.tasks, 1)

			---@type PlayerData
			local player_data = storage.players[state.player.index]
			player_data.last_state = nil
			if state._preview_rectangle and state._preview_rectangle.valid then
				state._preview_rectangle.destroy()
			end
			mpp_util.update_undo_button(player_data)
		else
			error("Layout "..state.layout_choice.." missing a callback name")
		end
	elseif tick_result == false then
		local player = state.player
		if state.blueprint then state.blueprint.clear() end
		if state.blueprint_inventory then state.blueprint_inventory.destroy() end
		if state._preview_rectangle and state._preview_rectangle.valid then
			state._preview_rectangle.destroy()
		end
		
		---@type PlayerData
		local player_data = storage.players[player.index]
		state._previous_state = nil
		player_data.tick_expires = math.huge
		if __DebugAdapter then
			player_data.last_state = state
		else
			player_data.last_state = {
				type = state.type,
				player = state.player,
				surface = state.surface,
				resources = state.resources,
				coords = state.coords,
				layout_choice = state.layout_choice,
				direction_choice = state.direction_choice,
				belts = state.belts,
				belt_choice = state.belt_choice,
				belt_planner_belts = state.belt_planner_belts,
				_preview_rectangle = state._preview_rectangle,
				_collected_ghosts = state._collected_ghosts,
				_render_objects = state._render_objects,
				_lane_info_rendering = state._lane_info_rendering,
			}
		end

		state.player.play_sound{path="utility/build_blueprint_large"}
		table.remove(storage.tasks, 1)
		mpp_util.update_undo_button(player_data)
	elseif tick_result ~= true then
		state._callback = tick_result
	end
end

---@param state BeltinatorState
function task_runner.belt_plan_task(state)
	belt_planner.layout(state)
end

return task_runner
