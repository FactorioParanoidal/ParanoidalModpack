-- Handcraft-result quality adapter. Only touches the NEW event result stack,
-- before Factorio inserts it into the player inventory. No inventory rescans.
local model = require("scripts.defects.model")
local M = {}
local rebuildable = {
    item = true, module = true, capsule = true, gun = true, ammo = true, tool = true,
    ["repair-tool"] = true, armor = true, ["rail-planner"] = true, ["item-with-entity-data"] = true,
}

-- finished: {name = true} from the data-stage classification.
function M.handle(event, player, create_inventory, random, finished)
    local stack = event.item_stack
    if not player or not player.valid or not stack or not stack.valid_for_read then
        return "ignored"
    end
    local old_quality = stack.quality.name
    local is_finished = finished[stack.name] == true
    -- Finished products keep positive/foreign quality (e.g. quality ingredients).
    if is_finished and old_quality ~= "normal" and not model.is_defect(old_quality) then
        return "preserved-quality"
    end
    -- Intermediates and raw materials are always white, including positive quality.
    if not is_finished and old_quality == "normal" then return "excluded-intermediate" end

    local prototype = stack.prototype
    local kind = prototype.type
    if not rebuildable[kind] then return "unsupported-item", stack.name end
    -- LuaItemStack inherits LuaItemCommon: read grid/ammo/durability from the
    -- stack itself. stack.item is nil for items without extra data.
    local grid = stack.grid
    if grid and next(grid.equipment) then return "occupied-grid", stack.name end
    if kind == "item-with-entity-data" and (stack.entity_label or stack.entity_color) then
        return "entity-data", stack.name
    end

    local quality = "normal"
    if is_finished then
        local level = model.completed_level(player.force.technologies)
        -- One crafting completion gets one roll; no extra inventory slots required.
        quality = level == 10 and "normal" or model.quality_name(model.draw(level, random()))
    end
    if quality == old_quality then return "unchanged" end

    local definition = {
        name = stack.name, count = stack.count, quality = quality,
        health = stack.health, spoil_percent = stack.spoil_percent,
    }
    if kind == "ammo" then definition.ammo = stack.ammo end
    if kind == "tool" or kind == "repair-tool" then
        local old_max = prototype.get_durability(old_quality)
        local new_max = prototype.get_durability(quality)
        if not old_max or not new_max or old_max <= 0 then
            return "unsupported-durability", stack.name
        end
        definition.durability = math.min(1, stack.durability / old_max) * new_max
    end

    -- Build a candidate first. A failed construction/swap leaves the actual
    -- event result intact. On success the temporary inventory holds the OLD
    -- result and is destroyed, so items cannot be duplicated.
    local temporary = create_inventory(1)
    if not temporary[1].set_stack(definition) then
        temporary.destroy()
        return "candidate-rejected", stack.name
    end
    if not stack.swap_stack(temporary[1]) then
        temporary.destroy()
        return "swap-rejected", stack.name
    end
    temporary.destroy()
    return "changed", quality
end

return M
