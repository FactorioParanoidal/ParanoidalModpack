return function(pattern, count, volume)
    local list = {}
    for i = 1, count do list[i] = {filename = string.format(pattern, i), volume = volume} end
    return list
end
