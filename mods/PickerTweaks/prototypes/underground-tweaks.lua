--[[
    "name": "longer-belts-redux",
    "title": "Longer Underground Belt (Aligned) ",
    "author": "Peppe",
    "homepage": "https://www.reddit.com/r/factorio/comments/53wjk1/the_longer_underground_belt_mod_that_gets_it_right/",
    "description": "Extends underground belt distance based on their speed.
                    Fixed optional mod bob's logistics.  Credit Schmendrick, Loren1350, for past versions",
-]] --
local Data = require('__stdlib__/stdlib/data/data')

local function _sort_by_speed(a, b)
    return a.speed < b.speed
end

if settings.startup['picker-underground-lengths'].value then
    local gap = settings.startup['picker-underground-bus-gap'].value

    local undergrounds = {}
    for name, entity in Data:pairs('underground-belt') do
        if entity.minable and entity.minable.result == name then
            undergrounds[#undergrounds + 1] = entity
        end
    end

    table.sort(undergrounds, _sort_by_speed)

    for i, ent in ipairs(undergrounds) do
        ent.max_distance = ((gap + 1) * i) + (i - 1)
    end
end
