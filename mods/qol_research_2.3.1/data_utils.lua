local flua = require('flua')
local data_utils = {}

--- Creates a table of count entries with a string that
--- can be used to order prototypes relative to eachother.
--- Example: create_ordering_table(5) => { 'a', 'b', 'c', 'd', 'e' }
function data_utils.create_ordering_table(count)
    -- print('creating ordering table for count', count)
    local digits = count <= 1 and 1 or math.ceil(math.log(count) / math.log(26))
    local current = flua.range(digits):list()
    return flua.range(0, count - 1):map(function (v)
        for i = digits, 1, -1 do
            current[i] = string.char(97 + v % 26)
            v = math.floor(v / 26)
        end
        return table.concat(current)
    end):list()
end

return data_utils