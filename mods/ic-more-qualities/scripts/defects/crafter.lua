-- Crafting machines (assembling machines, furnaces, rocket silos). Rewritten 2026-10-29 for performance
-- (review/ic-perf-audit-20261029/REPORT.md).
--
-- The engine fixes the result quality when a craft starts and keeps a value written by script until the
-- craft completes, also when modules or beacons change meanwhile (engine check test-runs/ic-h1b-20261029).
-- So every craft that needs handling is decided at the FIRST look during it and the next look comes right
-- after its expected end, when a fed machine has just started the next craft:
--   * a finished product (before quality control 10): a defect roll, capped at the ingredients' grade;
--   * a defective recipe (defective ingredients): result capped at their grade, exempt products and
--     materials become standard, recycling gives standard results;
--   * a recipe of the registry "ic-normal-result" at a positive quality: the result becomes standard;
--   * production modes (scripts/expansion/modes.lua): progress is slowed on every look, extra power is
--     drawn, the quality-module roll is boosted at the decision.
-- A machine whose current recipe needs none of this sleeps (DORMANT ticks); opening its window, pasting
-- settings, a production mode or a lost quality-control level wake it (scripts/defects/automation.lua).
-- Never touches output inventories, belts or chests.
local model = require("scripts.defects.model")
local rules = require("scripts.expansion.rules")
local M = {}

M.MIN_TICKS = 2    -- crafts this fast cannot be seen reliably
M.STALL_LOOK = 15  -- a stopped moded craft is looked at this often (its extra power is off)
M.MAX_IDLE = 60    -- longest idle look of a machine that can start a watched craft by itself
M.DORMANT = 300    -- a machine with nothing to handle until its recipe changes

local is_defect, grade_of, quality_name = model.is_defect, model.grade_of, model.quality_name
local GRADE_KEYS = {}
for grade = -5, 0 do GRADE_KEYS[grade] = "grade." .. grade end

-- Idle look so that a craft started right after it is still running at the next one: half of `energy`
-- seconds at the current speed.
local function half_of(entity, energy, cap)
    local speed = entity.crafting_speed
    if not energy or energy <= 0 or speed <= 0 then return 30 end
    return math.min(cap, math.max(1, math.floor(energy * 30 / speed)))
end

-- A recycler takes any item put in: within half of the shortest recycling of an item that can be defective
-- (data stage: at least defects-final.recycling_minimum). With a production mode every recycling craft is
-- slowed, so the shortest of all.
local function recycler_idle(entity, machine, moded)
    local energy = machine.min_energy
    if not moded then
        energy = machine.watched_min
        if not energy then return M.DORMANT end
    end
    return half_of(entity, energy, M.MAX_IDLE)
end

-- No recipe, or a recipe that needs nothing: a furnace picks its recipe by itself, an assembler only by
-- the player (window, paste, blueprint), a script or the circuit network.
local function sleep(entity, record, machine, ctx, moded)
    if machine.recycler then return recycler_idle(entity, machine, moded) end
    if not machine.relevant and not moded then return false end
    local kind = record.type
    if kind == "furnace" then return half_of(entity, machine.min_energy, M.MAX_IDLE) end
    if kind == "assembling-machine" then
        -- Recipe set by the circuit network: it changes without any event.
        local behavior = entity.get_control_behavior()
        if behavior and behavior.circuit_set_recipe then return half_of(entity, machine.min_energy, M.MAX_IDLE) end
    end
    return M.DORMANT
end

-- Does a craft of this recipe at this quality need a decision?
local function needs(recipe, quality, level)
    if not recipe.any_item then return false end
    if recipe.recycling then return is_defect(quality) end
    if is_defect(quality) then return true end
    if recipe.normal_result and quality ~= "normal" then return true end
    return level < 10 and recipe.roll and quality == "normal"
end

local function stat(ctx, record, key)
    if ctx.stat then ctx.stat(record.force_index, key) end
end

-- The decision of one craft, at its first look.
local function decide(entity, record, recipe_name, recipe, quality, quality_name_, level, definition, ctx)
    if recipe.recycling then
        -- Recycling keeps the native result (input quality or better); only defects become standard.
        if is_defect(quality_name_) and is_defect(entity.result_quality.name) then entity.result_quality = "normal" end
        return
    end
    -- Registry "ic-normal-result": ingredient quality does not carry over (no mode boost either). Defective
    -- ingredients take the usual path below (no repair route).
    if recipe.normal_result and quality_name_ ~= "normal" and not is_defect(quality_name_) then
        if entity.result_quality.name ~= "normal" then entity.result_quality = "normal" end
        return
    end
    local current = entity.result_quality.name
    -- Mode boost of the quality-module roll: defective ingredients cap the result, no boost for them.
    if definition and (recipe.all_finished or ctx.quality_everywhere) and ctx.mode_boost
        and not (ctx.no_quality and ctx.no_quality[recipe_name]) and not is_defect(quality_name_) then
        if ctx.mode_boost(entity, quality, definition) then current = entity.result_quality.name end
    end
    if not recipe.all_finished then
        -- Materials are never defective; positive quality is kept in the "quality everywhere" mode.
        if current ~= "normal" and (not ctx.quality_everywhere or is_defect(current)) then
            entity.result_quality = "normal"
        end
        return
    end
    -- Positive/foreign results of standard or better ingredients (quality modules) stay.
    if not (current == "normal" or is_defect(current) or is_defect(quality_name_)) then return end
    -- Paranoidal decision 2026-10-14: never better than the ingredients (the recipe quality); defects are
    -- repaired only in the refinement workshop. The roll may still make the result worse.
    local floor = grade_of(quality_name_)
    local target
    if recipe.exempt then
        target = "normal"
    else
        local grade = 0
        if not (definition and definition.no_defect) then
            local effective = rules.effective_level(level, definition)
            if effective < 10 then grade = model.draw(effective, ctx.random()) end
        end
        if floor < grade then grade = floor end
        target = quality_name(grade)
    end
    if target ~= current then entity.result_quality = target end
    stat(ctx, record, GRADE_KEYS[grade_of(target)])
end

-- Scales the progress gained since the last look down to the mode's speed (and by the supply of its
-- extra power). Productivity progress is scaled the same way.
local function slow_down(entity, craft, definition, progress, ctx)
    local gained = progress - craft.progress
    -- Working: progress since the last look, or a craft seen for the first time. A stopped machine
    -- (circuit, no power) pays no extra power; progress made before the next look after it resumes is
    -- not paid and does not count (modes.draw_power returns 0 for it).
    local working = gained > 1e-9 or not craft.seen
    craft.seen = true
    craft.stalled = not working or nil
    local supply = ctx.mode_power and ctx.mode_power(entity, definition, working) or 1
    if gained > 1e-9 then
        progress = craft.progress + gained * supply / definition.time
        entity.crafting_progress = progress
    end
    local bonus = entity.bonus_progress
    if craft.bonus and bonus > craft.bonus + 1e-9 then
        bonus = craft.bonus + (bonus - craft.bonus) * supply / definition.time
        entity.bonus_progress = bonus
    end
    craft.bonus = bonus
    craft.progress = progress
    return progress
end

-- Next look of a slowed craft: one full-speed tick before the engine would complete it (the engine runs at
-- full speed between looks); a stopped one is looked at often, so its extra power comes back soon.
local function slowed_delay(craft, left)
    local delay = math.max(1, math.floor(left) - 1)
    if craft.stalled then delay = math.min(delay, M.STALL_LOOK) end
    return delay
end

-- Returns the delay in ticks until the next look (false: stop tracking), and an optional warning code.
-- ctx: {machine(record, entity), recipe(name), modes (storage records or nil), mode_power, mode_boost,
-- release_power, random, quality_everywhere, no_quality, stat}.
function M.step(record, level, ctx)
    local entity = record.entity
    local machine = ctx.machine(record, entity)
    local mode_records = ctx.modes
    local mode_record = mode_records and mode_records[record.id]
    local recipe_object, quality = entity.get_recipe()
    local craft = record.craft
    if not recipe_object then
        record.craft = nil
        if mode_record then ctx.release_power(entity) end
        return sleep(entity, record, machine, ctx, mode_record ~= nil)
    end
    local recipe_name = recipe_object.name
    local recipe = ctx.recipe(recipe_name)
    local quality_name_ = quality and quality.name or "normal"
    if not (recipe and entity.is_crafting()) then
        -- Waiting with a recipe (ingredients, output space): the next craft can start right after this look.
        record.craft = nil
        if mode_record then ctx.release_power(entity) end
        if machine.recycler then return recycler_idle(entity, machine, mode_record ~= nil) end
        if recipe and (needs(recipe, quality_name_, level) or (mode_record and mode_record.mode ~= "normal")) then
            return half_of(entity, recipe.energy, M.DORMANT)
        end
        return sleep(entity, record, machine, ctx, mode_record ~= nil)
    end

    local speed = entity.crafting_speed
    local energy = recipe.energy
    if energy <= 0 or speed <= 0 then return 30 end
    local full = energy * 60 / speed
    if full <= M.MIN_TICKS then
        record.craft = nil
        if mode_record then ctx.release_power(entity) end
        return 30, "unsupported-speed"
    end
    local finished = entity.products_finished
    local progress = entity.crafting_progress
    if not craft or craft.finished ~= finished or craft.recipe ~= recipe_name or craft.quality ~= quality_name_
        or progress + 1e-6 < craft.progress then
        -- A new craft: its mode is the one selected now; it keeps it to its end.
        local mode = mode_record and mode_record.mode
        local definition = mode and mode ~= "normal" and rules.modes[mode] or nil
        if not (definition or needs(recipe, quality_name_, level)) then
            record.craft = nil
            if mode_record then ctx.release_power(entity) end
            if machine.recycler then
                return math.min(recycler_idle(entity, machine, false), math.ceil((1 - progress) * full) + 1)
            end
            return sleep(entity, record, machine, ctx, mode_record ~= nil)
        end
        craft = craft or {}
        craft.finished, craft.recipe, craft.quality, craft.progress = finished, recipe_name, quality_name_, progress
        craft.mode, craft.seen, craft.stalled = definition and mode or nil, nil, nil
        craft.bonus = definition and entity.bonus_progress or nil
        record.craft = craft
        if definition then stat(ctx, record, "mode." .. mode) end
        decide(entity, record, recipe_name, recipe, quality, quality_name_, level, definition, ctx)
    end
    local definition = craft.mode and rules.modes[craft.mode]
    if definition then
        progress = slow_down(entity, craft, definition, progress, ctx)
        return slowed_delay(craft, (1 - progress) * full)
    end
    -- A normal craft: release the extra power of a moded craft that has just ended.
    if mode_record then ctx.release_power(entity) end
    craft.progress = progress
    local left = (1 - progress) * full
    -- Completed but held (output blocked): poll well inside the next craft's duration.
    if left < 1 then return math.max(1, math.floor(full / 2)) end
    local after = math.ceil(left) + 1
    if machine.recycler then return math.min(after, recycler_idle(entity, machine, false)) end
    return after
end

return M
