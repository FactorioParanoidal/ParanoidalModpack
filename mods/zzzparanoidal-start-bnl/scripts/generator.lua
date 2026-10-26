-- Salvaged generator: production and buffer follow the entity quality (also defects).
local config = require("shipwreck-config")
local spec = config.generator
local M = {}

local PRODUCTION = spec.production_kw * 1000 / 60 -- J per tick
local BUFFER = spec.buffer_mj * 1000000 -- J

function M.filters()
    if not prototypes.entity[spec.name] then return nil end
    return {{filter = "name", name = spec.name}}
end

function M.apply(entity)
    if not (entity and entity.valid and entity.name == spec.name) then return end
    local quality = entity.quality
    entity.power_production = PRODUCTION * quality.default_multiplier
    entity.electric_buffer_size = BUFFER * quality.accumulator_capacity_multiplier
end

function M.on_built(event)
    M.apply(event.entity or event.destination)
end

-- Configuration change: values of existing generators follow the current config.
function M.refresh()
    if not prototypes.entity[spec.name] then return end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({name = spec.name})) do M.apply(entity) end
    end
end

return M
