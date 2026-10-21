local utils = {}

-- Normalizes an item reference (string, prototype, ItemFilter or ItemIDAndQualityIDPair) to its name
---@return string?
function utils.get_item_name(item)
    if item == nil then return end
    if type(item) == "string" then return item end
    local name = item.name
    if type(name) == "string" then return name end
    if name then return name.name end
end

---@param player LuaPlayer
---@return string?
function utils.get_cursor_name(player)
    if player.is_cursor_empty() then return end

    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read then
        return cursor.name
    end

    -- In 2.0 cursor_ghost is ItemIDAndQualityIDPair whose name is read as LuaItemPrototype
    return utils.get_item_name(player.cursor_ghost)
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