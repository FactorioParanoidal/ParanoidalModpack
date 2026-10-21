--- Taking back what we added to a player's undo queue.
local undo = {}

--- The shape of a player's undo queue, enough to find anything added to it afterwards
---@alias UndoState { item_count: uint, action_count: uint }

---@param player LuaPlayer
---@return UndoState
local function save_undo_state(player)
    local undo_stack = player.undo_redo_stack
    local item_count = undo_stack.get_undo_item_count()
    return {
        item_count = item_count,
        -- an action can either start a new undo item or be appended to the most recent one
        action_count = item_count > 0 and #undo_stack.get_undo_item( 1 ) or 0,
    }
end

--- Take back out of the player's undo queue whatever was added since `save_undo_state`
---@param player LuaPlayer
---@param undo_state UndoState
local function restore_undo_state(player, undo_state)
    local undo_stack = player.undo_redo_stack
    while undo_stack.get_undo_item_count() > undo_state.item_count do
        undo_stack.remove_undo_item( 1 )
    end
    if undo_state.item_count == 0 then return end
    -- removing the last action of an item removes the item too, which would take an older one with it
    local action_index = #undo_stack.get_undo_item( 1 )
    while action_index > undo_state.action_count and action_index > 1 do
        undo_stack.remove_undo_action( 1, action_index )
        action_index = action_index - 1
    end
end

undo.save_undo_state = save_undo_state
undo.restore_undo_state = restore_undo_state

return undo
