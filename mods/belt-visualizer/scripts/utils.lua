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

local function quality_name(quality)
    return type(quality) == "string" and quality or (quality and quality.name)
end

local quality_order = {}
do
    local index = 0
    for name in pairs(prototypes.quality) do
        index = index + 1
        quality_order[name] = index
    end
end

function utils.matches_item_filter(filter, name, quality)
    if type(filter) == "string" then return name == filter and quality == "normal" end
    local wanted_name = utils.get_item_name(filter)
    if wanted_name and wanted_name ~= name then return false end
    local wanted = quality_name(filter.quality)
    if not wanted then return true end
    local comparator = filter.comparator or "="
    if comparator == "=" then return quality == wanted end
    if comparator == "≠" or comparator == "!=" then return quality ~= wanted end
    local a, b = quality_order[quality], quality_order[wanted]
    if not (a and b) then return false end
    if comparator == ">" then return a > b end
    if comparator == "<" then return a < b end
    if comparator == "≥" or comparator == ">=" then return a >= b end
    if comparator == "≤" or comparator == "<=" then return a <= b end
    return false
end

---@param player LuaPlayer
---@return string?, string?
function utils.get_cursor_item(player)
    if player.is_cursor_empty() then return end

    local cursor = player.cursor_stack
    if cursor and cursor.valid_for_read then
        return cursor.name, cursor.quality.name
    end

    local ghost = player.cursor_ghost
    if ghost then return utils.get_item_name(ghost), quality_name(ghost.quality) or "normal" end
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