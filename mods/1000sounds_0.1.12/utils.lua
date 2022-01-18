local utils = {}

function utils.string(o) return '"' .. tostring(o) .. '"' end

function utils.recurse(o, indent)
    if indent == nil then indent = '' end
    local indent2 = indent .. '  '
    if type(o) == 'table' then
        local s = indent .. '{' .. '\n'
        local first = true
        for k, v in pairs(o) do
            if first == false then s = s .. ', \n' end
            if type(k) ~= 'number' then k = utils.string(k) end
            s = s .. indent2 .. '[' .. k .. '] = ' .. utils.recurse(v, indent2)
            first = false
        end
        return s .. '\n' .. indent .. '}'
    else
        return utils.string(o)
    end
end

function utils.var_dump(...)
    local args = {...}
    if #args > 1 then
        utils.var_dump(args)
    else
        game.print(utils.recurse(args[1]))
    end
end

return utils
