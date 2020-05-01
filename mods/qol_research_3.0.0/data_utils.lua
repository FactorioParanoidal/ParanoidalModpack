local category_list = require('categories').list
local data_utils = {}

--- Creates a table of count entries with a string that
--- can be used to order prototypes relative to eachother.
--- Example: create_ordering_table(5) => { 'a', 'b', 'c', 'd', 'e' }
function data_utils.create_ordering_table(count)
    -- print('creating ordering table for count', count)
    local digits = count <= 1 and 1 or math.ceil(math.log(count) / math.log(26))
    local current = {}
    for i = 1, digits do current[i] = i end
    local result = {}
    for v = 0, count - 1 do
        for i = digits, 1, -1 do
            current[i] = string.char(97 + v % 26)
            v = math.floor(v / 26)
        end
        result[#result + 1] = table.concat(current)
    end
    return result
end

function data_utils.create_ordering_table_for_settings()
    local count = #category_list * 3
    for _, category in ipairs(category_list) do
        if category.effect_settings then
            local c = 0
            for _ in pairs(category.effect_settings) do
                c = c + 1
            end
            count = math.max(count, c)
        end
    end

    return data_utils.create_ordering_table(count)
end

return data_utils
