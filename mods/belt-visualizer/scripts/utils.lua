local utils = {}

---@param player LuaPlayer
---@return string?
function utils.get_cursor_name(player)
    if player.is_cursor_empty() then return end

    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read then
        return cursor.name
    end

    local ghost = player.cursor_ghost  --[[@as LuaItemPrototype?]]
    if ghost then
        return ghost.name
    end
end

---@param entity LuaEntity
---@return string
function utils.get_belt_type(entity)
    return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

function utils.empty_check(type)
    return type == "splitter" and {left = {{}, {}}, right = {{}, {}}} or {{}, {}}
end

function utils.check_entity(data, unit_number, lane, path, sides)
    local checked = data.checked[unit_number]
    if sides then
        for side in pairs(sides) do
            checked[side][lane][path] = true
        end
    else
        checked[lane][path] = true
    end
end

return utils