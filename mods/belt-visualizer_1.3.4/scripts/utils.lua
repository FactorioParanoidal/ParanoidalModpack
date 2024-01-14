local utils = {}

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