-- Adds new functions to the builtin table class.
-- Borrowed from Maraxsis
---Returns a new table with the results of calling a provided function on every element in the table.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): any
---@param ... any
---@return table
table.map = function(tbl, f, ...)
    local result = {}
    for k, v in pairs(tbl) do result[k] = f(v, k, ...) end
    return result
end

---Returns a new table with all elements that pass the test implemented by the provided function.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): boolean
---@param ... any
---@return table
table.filter = function(tbl, f, ...)
    local result = {}
    local is_array = #tbl > 0
    local is_function = type(f) == "function"
    if is_array then
        if is_function then
            for i, v in pairs(tbl) do if f(v, i, ...) then result[#result + 1] = v end end
        else
            for i, v in pairs(tbl) do if f == v then result[#result + 1] = v end end
        end
    else
        if is_function then
            for k, v in pairs(tbl) do if f(v, k, ...) then result[k] = v end end
        else
            for k, v in pairs(tbl) do if f == v then result[k] = v end end
        end
    end
    return result
end

---Inverse of table.filter. Returns a new array with all elements that pass the test deleted by the provided function.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): boolean
---@param ... any
---@return table
table.delete_if = function(tbl, f, ...)
    local result = {}
    local is_array = #tbl > 0
    local is_function = type(f) == "function"
    if is_array then
        if is_function then
            for i, v in pairs(tbl) do if not f(v, i, ...) then result[#result + 1] = v end end
        else
            for i, v in pairs(tbl) do if f ~= v then result[#result + 1] = v end end
        end
    else
        if is_function then
            for k, v in pairs(tbl) do if not f(v, k, ...) then result[k] = v end end
        else
            for k, v in pairs(tbl) do if f ~= v then result[k] = v end end        
        end
    end
    return result
end

---Returns the first element that satisfies the predicate.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): any
---@param ... any
---@return any, any
---@overload fun(tbl: table, v: any): any, any
table.find = function(tbl, f, ...)
    if type(f) == "function" then
        for k, v in pairs(tbl) do if f(v, k, ...) then return v, k end end
    else
        for k, v in pairs(tbl) do if v == f then return v, k end end
    end
    return nil
end

---Returns true if any element in the table passes the test implemented by the provided function.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): any
---@param ... any
---@return boolean
---@overload fun(tbl: table, v: any): boolean
table.any = function(tbl, f, ...)
    return table.find(tbl, f, ...) ~= nil
end

---Returns true if all elements in the table pass the test implemented by the provided function.
---@param tbl table
---@param f fun(v: any, k: any, ...: any): any
---@param ... any
---@return boolean
---@overload fun(tbl: table, v: any): boolean
table.all = function(tbl, f, ...)
    if type(f) == "function" then
        for k, v in pairs(tbl) do if not f(v, k, ...) then return false end end
    else
        for k, v in pairs(tbl) do if v ~= f then return false end end
    end
    return true
end

---Returns a boolean indicating whether the table has size 0.
---@param tbl table
---@return boolean
table.is_empty = function(tbl)
    return next(tbl) == nil
end

---Returns an array of the table's keys.
---@param tbl table
---@return any[]
table.keys = function(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do keys[#keys + 1] = k end
    return keys
end

---Returns an array of the table's values.
---@param tbl table
---@return any[]
table.values = function(tbl)
    local values = {}
    for _, v in pairs(tbl) do table.insert(values, v) end
    return values
end

---Returns the first element of the table.
---@param tbl table
---@return any
table.first = function(tbl)
    local _, v = next(tbl)
    return v
end

---Returns the last element of the table.
---@param tbl table
---@return any
table.last = function(tbl)
    local result
    for _, v in pairs(tbl) do result = v end
    return result
end

---Returns the last element of the array.
---@param tbl any[]
---@return any
table.array_last = function(tbl)
    local size = #tbl
    if size == 0 then return nil end
    return tbl[size]
end

---Returns a new table with keys and values swapped.
---@param tbl table
---@return table
table.invert = function(tbl)
    local result = {}
    for k, v in pairs(tbl) do result[v] = k end
    return result
end

---Returns a new table by merging the provided tables. If a key exists in multiple tables, the value from the last table is used.
---@param ... table
---@return table
table.merge = function(...)
    local result = {}
    for _, tbl in pairs {...} do
        for k, v in pairs(tbl) do result[k] = v end
    end
    return result
end

---Returns a new array by merging the provided tables. The values are appended in the order they are provided.
---@param ... table
---@return any[]
table.array_combine = function(...)
    local result = {}
    for _, tbl in pairs {...} do
        for _, v in pairs(tbl) do result[#result + 1] = v end
    end
    return result
end

---Reverses an array in-place and returns it.
---@param tbl any[]
---@return any[]
table.reverse = function(tbl)
    for i = 1, #tbl / 2 do
        tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
    end
    return tbl
end

local function shuffle(t)
    local keys = {}
    local n = 0
    for k in pairs(t) do
        n = n + 1
        keys[n] = k
    end

    while n > 1 do
        local k = math.random(n)
        keys[n], keys[k] = keys[k], keys[n]
        n = n - 1
    end

    return keys
end
-- ---Like normal pairs(), but in deterministic randomized order
-- ---@param t table
-- ---@return fun():any, any
-- function maraxsis.shuffled_pairs(t)
--     local shuffled_keys = shuffle(t)
--     local i = 0
--     return function()
--         i = i + 1
--         local key = shuffled_keys[i]
--         if key then
--             return key, t[key]
--         end
--     end
-- end

---Returns a new array with duplicates removed.
---@param tbl any[]
---@return any[]
table.dedupe = function(tbl)
    local seen = {}
    local result = {}
    for _, v in pairs(tbl) do
        if not seen[v] then
            table.insert(result, v)
            seen[v] = true
        end
    end
    return result
end
