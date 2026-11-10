-- Pure input normalisation shared by imports, remote presets and the editor.
local M = {}
local TYPES = {item = true, fluid = true, item_consumption = true, fluid_consumption = true,
    technology = true, kill = true, group = true, alias = true}
local QUALITY_TYPES = {item = true, item_consumption = true, kill = true, alias = true}
local MAX_ENTRIES = 10000

function M.finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

function M.parse_next(value)
    if type(value) ~= "string" then return nil end
    local operator, operand = value:match("^%s*([xX*+])%s*(.-)%s*$")
    operand = tonumber(operand)
    if not M.finite(operand) then return nil end
    if operator == "*" or operator == "X" then operator = "x" end
    if operator == "x" and operand > 1 or operator == "+" and operand > 0 then
        return operator, operand
    end
end

function M.next_quantity(quantity, formula)
    local operator, operand = M.parse_next(formula)
    if not operator or not M.finite(quantity) then return nil end
    local value = operator == "+" and quantity + operand or quantity * operand
    if M.finite(value) and value > quantity then return value end
end

local function array_length(value, maximum)
    if type(value) ~= "table" or getmetatable(value) ~= nil then return nil end
    local count = 0
    for key in pairs(value) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then return nil end
        count = count + 1
        if count > maximum then return nil end
    end
    for i = 1, count do if rawget(value, i) == nil then return nil end end
    return count
end

function M.mod_names(value, optional)
    if value == nil and optional then return {} end
    local count = array_length(value, MAX_ENTRIES)
    if not count then return nil end
    local result = {}
    for i = 1, count do
        if type(value[i]) ~= "string" or value[i] == "" then return nil end
        result[i] = value[i]
    end
    return result
end

local function localised_copy(value, seen, depth)
    if type(value) == "string" or M.finite(value) then return value end
    if type(value) ~= "table" or depth > 20 or seen[value] then return nil end
    local count = array_length(value, 21)
    if not count or count < 1 or type(value[1]) ~= "string" then return nil end
    seen[value] = true
    local result = {}
    for i = 1, count do
        local child = localised_copy(value[i], seen, depth + 1)
        if child == nil then seen[value] = nil; return nil end
        result[i] = child
    end
    seen[value] = nil
    return result
end

local function invalid(field, row)
    return nil, {"milestones.message_invalid_import_field", tostring(row or ""), field}
end

function M.normalize(value)
    local count = array_length(value, MAX_ENTRIES)
    if not count then return invalid("array (maximum " .. MAX_ENTRIES .. " entries)") end
    local result, target_types = {}, {}
    for i = 1, count do
        local row = value[i]
        if type(row) ~= "table" or getmetatable(row) ~= nil then return invalid("entry", i) end
        local kind = row.type
        if type(kind) ~= "string" or not TYPES[kind] then return invalid("type", i) end
        if type(row.name) ~= "string" or row.name == "" then return invalid("name", i) end
        local item = {type = kind, name = row.name}
        if kind ~= "group" then
            local quantity = type(row.quantity) == "number" and row.quantity
                or type(row.quantity) == "string" and tonumber(row.quantity)
            if not M.finite(quantity) or quantity < (kind == "alias" and 0 or 1)
                or quantity <= 0 then return invalid("quantity", i) end
            if kind == "technology" and quantity % 1 ~= 0 then return invalid("quantity (whole research level)", i) end
            item.quantity = quantity
        end
        if row.next ~= nil then
            if kind == "group" or kind == "alias" or not M.next_quantity(item.quantity, row.next) then
                return invalid("next (must strictly increase a finite quantity)", i)
            end
            if kind == "technology" then
                local _, operand = M.parse_next(row.next)
                if operand % 1 ~= 0 then return invalid("next (whole research levels)", i) end
            end
            item.next = row.next
        end
        if row.quality ~= nil then
            if not QUALITY_TYPES[kind] or type(row.quality) ~= "string" or row.quality == "" then
                return invalid("quality", i)
            end
            item.quality = row.quality
        end
        if row.hidden ~= nil then
            if row.hidden == true or row.hidden == "true" then item.hidden = true
            elseif row.hidden ~= false and row.hidden ~= "false" then return invalid("hidden", i) end
        end
        if row.tooltip ~= nil then
            item.tooltip = localised_copy(row.tooltip, {}, 1)
            if item.tooltip == nil then return invalid("tooltip", i) end
        end
        if kind == "alias" then
            if type(row.equals) ~= "string" or row.equals == "" or row.equals == row.name then
                return invalid("equals", i)
            end
            item.equals = row.equals
        elseif kind ~= "group" then
            local old = target_types[row.name]
            if old == nil then target_types[row.name] = kind
            elseif old ~= kind then target_types[row.name] = false end
        end
        -- Repeated group headers are intentional: addons append to existing groups.
        result[i] = item
    end
    for i, row in ipairs(result) do
        if row.type == "alias" then
            local target = target_types[row.equals]
            if target == false then return invalid("equals (ambiguous target)", i) end
            if target and row.quality and not QUALITY_TYPES[target] then return invalid("quality", i) end
        end
    end
    return result
end

return M
