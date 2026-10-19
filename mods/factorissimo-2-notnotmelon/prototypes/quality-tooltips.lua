-- Factory characteristics in tooltips and Factoriopedia.
-- Paranoidal: factories are immune to quality and defects, so the values are the same for every quality
-- and no per-quality values are listed.

local fluid_port = require("prototypes.fluid-port")

local function add_factory_info(entity, interior_space, connections)
    if not entity then return end
    entity.custom_tooltip_fields = entity.custom_tooltip_fields or {}
    for _, info in pairs {
        {"interior-space", interior_space},
        {"connections", tostring(connections)},
        {"fluid-transfer-speed", string.format("%.0f", fluid_port.pumping_speed * 60) .. "/s"},
    } do
        table.insert(entity.custom_tooltip_fields, {
            name = {"description." .. info[1]},
            value = info[2],
        })
    end
end

local tanks = data.raw["storage-tank"]
local factories = {
    ["factory-1"] = {"30×30", 16},
    ["factory-2"] = {"46×46", 24},
    ["factory-3"] = {"60×60", 32},
    ["factory-4"] = {"90×90", 40}, -- Paranoidal
}
for name, info in pairs(factories) do
    add_factory_info(tanks[name], info[1], info[2])
    add_factory_info(tanks["space-" .. name], info[1], info[2])
end
