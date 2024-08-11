-- https://www.lua.org/pil/11.4.html

local Queue = {}

function Queue.New()
    return { first = 0, last = -1 }
end

function Queue.Push(list, value)
    local last = list.last + 1
    list.last = last
    list[last] = value
end

function Queue.Pop(list)
    local first = list.first
    if first > list.last then
        return nil
    end
    local value = list[first]
    list[first] = nil
    list.first = first + 1
    return value
end

function Queue.Size(list)
    return list.last - list.first + 1
end

return Queue
