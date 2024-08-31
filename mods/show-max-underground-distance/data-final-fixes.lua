local hover = settings.startup["show-max-underground-distance-on-hover"].value
local icon = settings.startup["show-max-underground-distance-icon"].value

local rvs_template = {
    sprite = {
        filename = string.format("__show-max-underground-distance__/graphics/%s.png", icon),
        priority = "high",
        size = 32
    },
    distance = 1,
    draw_on_selection = hover
}

for i, proto in pairs(data.raw["underground-belt"]) do
    local rvs = table.deepcopy(rvs_template)
    rvs.offset = {0, -proto.max_distance}
    proto.radius_visualisation_specification = rvs
end

for i, proto in pairs(data.raw["pipe-to-ground"]) do
	--0.0.4 fix for pipelayer with undefined fluidbox ends, 0.0.5 fix for undefined max_underground_distance
    if #proto.fluid_box.pipe_connections > 1 and proto.fluid_box.pipe_connections[2].max_underground_distance then
        local rvs = table.deepcopy(rvs_template)
        rvs.offset = {0, proto.fluid_box.pipe_connections[2].max_underground_distance}
        proto.radius_visualisation_specification = rvs
    end
end