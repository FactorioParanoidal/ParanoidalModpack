-- Mode twins keep the recipe, quality and fluid layout. Factorio 2.1 fast replacement can nevertheless
-- discard fluid. Capture whole segments, not the apparent amount of each connected fluidbox: multiple
-- boxes can refer to the same segment. Restore its exact state once, never add it to fluid left in pipes.
local M = {}

function M.capture(entity)
    local saved, seen = {}, {}
    for index = 1, entity.fluids_count do
        local segment = entity.has_fluid_segment(index)
        local id = segment and entity.get_fluid_segment_id(index)
        if not segment or not seen[id] then
            local fluid
            if segment then fluid = entity.get_fluid_segment_fluid(index)
            else fluid = entity.get_fluid(index) end
            if fluid and fluid.amount > 0 then
                saved[#saved + 1] = {index = index, segment = segment, fluid = fluid}
            end
            if segment then seen[id] = true end
        end
    end
    return saved
end

function M.restore(entity, saved)
    for _, entry in ipairs(saved) do
        local current
        if entry.segment then current = entity.get_fluid_segment_fluid(entry.index)
        else current = entity.get_fluid(entry.index) end
        local fluid = entry.fluid
        if not (current and current.name == fluid.name and current.amount == fluid.amount and current.temperature == fluid.temperature) then
            local restored
            if entry.segment then restored = entity.set_fluid_segment_fluid(entry.index, fluid)
            else restored = entity.set_fluid(entry.index, fluid) end
            if math.abs(restored - fluid.amount) > 0.000001 then
                log("IC modes: fluid restoration truncated for " .. entity.name .. " storage " .. entry.index
                    .. ": " .. restored .. "/" .. fluid.amount .. " " .. fluid.name)
            end
        end
    end
end

return M
