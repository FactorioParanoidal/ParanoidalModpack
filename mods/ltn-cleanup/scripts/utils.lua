local utils = {}

function utils.build_reverse_index(values)
    local index = {}
    for k, v in pairs(values) do
        index[v] = k
    end
    return index
end

function utils.get_first_or_random(list)
    if #list == 1 then
        return list[1]
    elseif #list ~= 0 then
        return list[math.random(#list)]
    end
end

return utils
