local utils = {}

utils.parse_string = function(str, args)
    local count = 1
    for _, r in pairs(args) do
        local var = '__' .. count .. '__'
        local s, e = string.find(str, var)
        while s ~= nil and e ~= nil do
            str = string.gsub(str, var, r)
            s, e = string.find(str, var)
        end
        count = count + 1
    end
    return str
end

return utils
