-- Handcraft-result quality adapter. Only touches the NEW event result stack,
-- before Factorio inserts it into the player inventory. No inventory rescans.
local model = require("scripts.defects.model")
local M = {}
local rebuildable = {
    item = true, module = true, capsule = true, gun = true, ammo = true, tool = true,
    ["repair-tool"] = true, armor = true, ["rail-planner"] = true, ["item-with-entity-data"] = true,
}

-- finished: {name = true} from the data-stage classification. level: completed quality-control level of
-- the player's force (nil: counted here). normal_result: the recipe is in the registry "ic-normal-result".
function M.handle(event, player, create_inventory, random, finished, everywhere, no_defect, level, normal_result)
    local stack = event.item_stack
    if not player or not player.valid or not stack or not stack.valid_for_read then
        return "ignored"
    end
    local old_quality = stack.quality.name
    local is_finished = finished[stack.name] == true
    -- Registry "ic-normal-result": a positive result becomes standard (defects take the usual path).
    local forced = normal_result and old_quality ~= "normal" and not model.is_defect(old_quality)
    if not forced then
        -- Finished products keep positive/foreign quality (e.g. quality ingredients).
        if is_finished and old_quality ~= "normal" and not model.is_defect(old_quality) then
            return "preserved-quality"
        end
        -- Intermediates and raw materials are always white, including positive quality.
        if not is_finished and old_quality == "normal" then return "excluded-intermediate" end
        -- "Quality everywhere": materials keep positive quality (only defects are reset).
        if not is_finished and everywhere and not model.is_defect(old_quality) then return "excluded-intermediate" end
    end

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
    if not forced and is_finished and not (no_defect and no_defect[stack.name]) then
        level = level or model.completed_level(player.force.technologies)
        -- One crafting completion gets one roll; no extra inventory slots required.
        local grade = level == 10 and 0 or model.draw(level, random())
        -- Paranoidal decision 2026-10-14: never better than the ingredients. A handcrafted result has
        -- their quality; defective ingredients are repaired only in the refinement workshop.
        quality = model.quality_name(math.min(grade, model.grade_of(old_quality)))
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

-- Item ingredients per recipe name (prototype data, the same on every peer; rebuilt after load).
local ingredient_sets = {}
function M.reset_cache() ingredient_sets = {} end

local function ingredient_set(recipe_name, recipe_prototypes)
    local set = ingredient_sets[recipe_name]
    if not set then
        set = {}
        local recipe = recipe_prototypes[recipe_name]
        for _, ingredient in pairs(recipe and recipe.ingredients or {}) do
            if ingredient.type == "item" then set[ingredient.name] = true end
        end
        ingredient_sets[recipe_name] = set
    end
    return set
end

-- Auto-crafted prerequisites of a queued craft are exempt from the defect roll: the parent craft expects
-- them. The queue is crafted from its head, so the first entry that decides wins (in queue order):
--   * an entry of the same recipe: the craft belongs to it -> its prerequisite flag;
--   * an entry that uses the item: the craft's own entry is already gone (its last craft; the engine
--     timing is not documented) and the parent waits -> protected.
-- A manually queued batch is therefore not protected by a consumer queued after it (the old "any queued
-- consumer" rule let a whole batch skip defects); at most the last craft of such a batch can still be.
function M.queued_prerequisite(queue, recipe_name, item_name, recipe_prototypes)
    for _, entry in ipairs(queue or {}) do
        if entry.recipe == recipe_name then return entry.prerequisite == true end
        if ingredient_set(entry.recipe, recipe_prototypes)[item_name] then return true end
    end
    return false
end

return M
