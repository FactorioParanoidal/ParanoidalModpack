-- Inventory-related methods
local Inventory = {}

-- TODO: Consider the Cursor Inventory too (otherwise items can be lost during transition)
-- TODO: Consider Filters (otherwise they are lost during transition)

-- Extracts a Player Cursor's Blueprint as a string (if present)
---@param player LuaPlayer
function Inventory.GetCursorBlueprintString(player)
    local blueprint = nil
    if player.is_cursor_blueprint() then
        if player.character
                and player.character.cursor_stack
                and player.character.cursor_stack.valid
                and player.character.cursor_stack.valid_for_read
        then
            blueprint = player.character.cursor_stack.export_stack()
        elseif player.cursor_stack
                and player.cursor_stack.valid
                and player.cursor_stack.valid_for_read
        then
            blueprint = player.cursor_stack.export_stack()
        else
            player.print{"messages.blueprint-in-cursor-from-library"}
        end
    end
    return blueprint
end

-- Whether a Player's Cursor can non-destructively be replaced
---@param player LuaPlayer
function Inventory.WasCursorSafelyCleared(player)
    if not player or not player.cursor_stack.valid then
        return false
    end
    if player.is_cursor_empty() then return true end
    if player.is_cursor_blueprint() then return true end

    --[[ TODO:
    This doesn't usually happen, since the "source location" of the item
    seems to be lost after swapping the character.
    ]]
    if not player.cursor_stack_temporary then
        player.clear_cursor()
        return true
    end

    return false
end

-- Whether a Player's Inventory is vulnerable to going missing due to lack of a body
function Inventory.ShouldPersist(controller)
    return controller ~= nil and (controller == defines.controllers.god or controller == defines.controllers.editor)
end

-- Ensure a Player's Inventory isn't full
---@param player LuaPlayer
function Inventory.Prune(player)
    local inventory = player.get_main_inventory()
    if not inventory then
        return
    end

    if inventory.count_empty_stacks() == 0 then
        player.create_local_flying_text({
            text = {"messages.god-inventory-almost-full"},
            position = player.position,
        })
        player.surface.spill_item_stack({
            position = player.position,
            stack = inventory[#inventory],
            allow_belts = false,
        })
        inventory[#inventory].clear()
    end
end

-- Create a backing inventory the same size as another
---@param from LuaInventory
function Inventory.Initialize(from)
    if not from then
        return nil
    end
    return game.create_inventory(#from)
end

-- Persist one Inventory into another mod-created one
---@param from LuaInventory
---@param to LuaInventory | nil
function Inventory.Persist(from, to)
    if not from then
        return nil
    end
    if not to then
        to = game.create_inventory(#from)
    else
        to.resize(#from)
    end
    for i = 1, #from do
        to[i].set_stack(from[i])
    end
    return to
end

-- Restore one Inventory into another
---@param from LuaInventory
---@param to LuaInventory
function Inventory.Restore(from, to)
    if not from or not to then
        return
    end
    local transition = math.min(#from, #to)
    for i = 1, transition do
        to[i].set_stack(from[i])
    end
    if transition < #to then
        for i = transition + 1, #to do
            to[i].set_stack()
        end
    end
end

return Inventory
