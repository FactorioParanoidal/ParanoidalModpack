-- Empty handcraft result: only the newly produced event stack, never inventories.
local model = require("scripts.defects.model")
local M = {}

function M.handle(event, player, random, finished, exclude_finished, initial_percent)
    local stack = event.item_stack
    if not player or not player.valid or not stack or not stack.valid_for_read then
        return "ignored"
    end
    if exclude_finished and finished[stack.name] == true then
        return "protected-finished"
    end
    local level = model.completed_level(player.force.technologies)
    if level == 10 then return "loss-free" end
    if not model.roll_loss(level, random, initial_percent) then return "survived" end
    -- Ingredients have already been spent. Discard this event's entire result,
    -- including positive quality. No refund, reroll or old-stock conversion.
    stack.clear()
    return "empty-result"
end

-- Auto-crafted prerequisites of a queued craft are exempt from loss and
-- quality changes: the parent craft expects them. Conservative: any queued
-- recipe using this item protects it, because the engine timing of queue
-- updates relative to on_player_crafted_item is not documented.
function M.queued_prerequisite(queue, recipe_name, item_name, recipe_prototypes)
    for _, entry in pairs(queue or {}) do
        if entry.recipe == recipe_name then
            if entry.prerequisite then return true end
        else
            local recipe = recipe_prototypes[entry.recipe]
            for _, ingredient in pairs(recipe and recipe.ingredients or {}) do
                if ingredient.type == "item" and ingredient.name == item_name then return true end
            end
        end
    end
    return false
end

return M
