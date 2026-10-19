-- Paranoidal: data-final-fixes part of the reinforced hull technologies: optional prerequisites
-- and the wall drawn over the building picture (from the final wall icons of the mod set).

local F = "__factorissimo-2-notnotmelon__"
local HULL = require("prototypes.hull-config")

local technologies = data.raw.technology

-- Item icon layers are drawn for a 32 unit frame (64 px / 2), a technology icon frame has 128 units.
-- `fraction` is the share of the technology frame the wall takes, it is placed in the lower right corner.
local fraction = 0.55
local k = 4 * fraction
local corner = 64 - 64 * fraction

local function wall_layers(names)
    for _, name in ipairs(names) do
        local item = data.raw.item[name]
        if item then
            if item.icons then return item.icons end
            if item.icon then return {{icon = item.icon, icon_size = item.icon_size or 64}} end
        end
    end
    return {{icon = "__base__/graphics/icons/wall.png", icon_size = 64}}
end

for _, hull in ipairs(HULL) do
    local technology = technologies["factory-hull-" .. hull.level]
    if technology then
        for _, name in ipairs(hull.optional_prerequisites) do
            if technologies[name] then table.insert(technology.prerequisites, name) end
        end
        for i = #technology.prerequisites, 1, -1 do
            if not technologies[technology.prerequisites[i]] then table.remove(technology.prerequisites, i) end
        end

        local icons = {{icon = F .. "/graphics/technology/factory-architecture-" .. hull.level .. ".png", icon_size = 256}}
        for _, layer in ipairs(wall_layers(hull.walls)) do
            local size = layer.icon_size or 64
            local shift = layer.shift or {0, 0}
            icons[#icons + 1] = {
                icon = layer.icon,
                icon_size = size,
                tint = layer.tint,
                scale = (layer.scale or (32 / size)) * k,
                shift = {(shift[1] or shift.x or 0) * k + corner, (shift[2] or shift.y or 0) * k + corner},
            }
        end
        technology.icons = icons
        technology.icon = nil
    end
end
