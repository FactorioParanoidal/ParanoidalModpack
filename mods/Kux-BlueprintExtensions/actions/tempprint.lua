-- Temporary blueprint support
local Tempprint = {}


function Tempprint.set_temporary(player)
    -- Makes a note of the item the player is currently holding.  If the cursor stack is cleaned, the item is removed.
    local stack = player.cursor_stack

    if not (stack.valid and stack.valid_for_read and stack.type == 'blueprint' and stack.item_number ~= 0) then return end

    local pdata = storage.playerdata[player.index]
    if not pdata then
        pdata = {}
        storage.playerdata[player.index] = pdata
    end

    pdata.temporary_item = {name=stack.name, item_number=stack.item_number}

    return true
end

function Tempprint.clear_temporary(player_index)
    local pdata = storage.playerdata[player_index]
    if not (pdata and pdata.temporary_item) then return end  -- No temporary item to clear
    pdata.temporary_item = nil
    return
end

function Tempprint.nuke_temporary(player_index)
    local pdata = storage.playerdata[player_index]
    if not (pdata and pdata.temporary_item) then return end  -- No temporary item to clear
    local tempitem = pdata.temporary_item

	local player = game.players[player_index]
    local stack = player.cursor_stack
    if not (stack and stack.valid and stack.valid_for_read and stack.type == 'blueprint' and stack.item_number ~= 0) then return end

    if stack.name == tempitem.name and stack.item_number == tempitem.item_number then
        stack.clear()
    end

    pdata.temporary_item = nil
    return true
end

local function clear_temporary_event(event)
    return Tempprint.clear_temporary(event.player_index)
end

script.on_event(mod.prefix.."cleared_cursor_proxy", function(event)
	---@cast event EventData.CustomInputEvent
	return Tempprint.nuke_temporary(event.player_index) end
)

EventDistributor.register(defines.events.on_player_configured_blueprint,clear_temporary_event)
EventDistributor.register(defines.events.on_player_cursor_stack_changed,clear_temporary_event)

return Tempprint