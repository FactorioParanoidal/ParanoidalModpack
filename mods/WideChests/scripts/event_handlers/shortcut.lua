local function on_shortcut(event)
	if event.prototype_name == MergingChests.merge_shortcut_name then
		local player = game.players[event.player_index]
		if player.clear_cursor() then
			local stack = player.cursor_stack
			if stack and stack.can_set_stack({ name = MergingChests.merge_selection_tool_name }) then
				stack.set_stack({ name = MergingChests.merge_selection_tool_name })
			end
		end
	end
end

script.on_event(defines.events.on_lua_shortcut, on_shortcut)
