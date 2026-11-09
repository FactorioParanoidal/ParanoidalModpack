--------------------------------------------------------------------------------
-- Factorio cursor helpers.
--------------------------------------------------------------------------------

local lib = {}

---Sets the player's cursor to a ghost of the given entity. Clears the
---cursor if the player is already holding something else.
---@param player LuaPlayer
---@param entity_name string
function lib.set_cursor_ghost(player, entity_name)
	local cursor_stack = player.cursor_stack
	if
		cursor_stack
		and cursor_stack.valid_for_read
		and cursor_stack.name ~= entity_name
	then
		player.clear_cursor()
	end
	player.cursor_ghost = entity_name
end

return lib
