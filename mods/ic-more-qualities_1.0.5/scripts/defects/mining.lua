-- Manual and robot mining loss for natural sources: ore, trees, fish and rocks.
-- Buildings/wrecks are never affected: deconstruction returns them intact.
local model = require("scripts.defects.model")
local M = {}
local natural = {resource = true, tree = true, fish = true}
M.event_types = {"resource", "tree", "fish", "simple-entity"}

function M.is_natural(entity)
    if natural[entity.type] then return true end
    return entity.type == "simple-entity" and entity.prototype.count_as_rock_for_filtered_deconstruction == true
end

-- One roll per mining event; the whole event buffer is the batch.
function M.handle(entity, buffer, force, random)
    if not entity or not entity.valid or not buffer or not buffer.valid or not force then return "ignored" end
    if not M.is_natural(entity) then return "not-natural" end
    if buffer.is_empty() then return "empty" end
    local level = model.completed_level(force.technologies)
    if level == 10 then return "loss-free" end
    if not model.production_failed(level, random()) then return "survived" end
    -- The resource amount/tree is already consumed by the engine.
    buffer.clear()
    return "lost"
end

return M
