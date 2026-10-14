-- Crafting machines (assembling machines, furnaces, rocket silos).
-- One decision per completion attempt, taken shortly BEFORE the craft finishes:
--   loss    -> progress is reset and one more ingredient set is consumed, so the
--              failed attempt costs ingredients and time and yields nothing;
--   success -> finished products get a defect roll via result_quality,
--              intermediates/mixed outputs are forced to standard quality.
-- Production modes (careful/precise, see scripts/expansion/modes.lua) are applied per craft:
-- progress is scaled down, loss and defect chances change, the quality-module roll is boosted at
-- the decision (a craft that completes unobserved gets no boost).
-- Never touches output inventories, belts or chests.
local model = require("scripts.defects.model")
local rules = require("scripts.expansion.rules")
local classify = require("scripts.defects.classify")
local M = {}

M.FINAL = 3        -- decide when at most this many full-speed ticks remain
M.STEP = .75       -- otherwise look again after this fraction of the remainder
M.MAX_IDLE = 60
M.MIN_TICKS = 2    -- crafts this fast cannot be intercepted reliably
M.STALL_LOOK = 15  -- a stopped moded craft is looked at this often (its extra power is off)
M.RELAXED = 600    -- research 10: a machine with nothing to handle is looked at this often

local function is_input(fluidbox, index)
    local prototype = fluidbox.get_prototype(index)
    -- A recipe may merge fluidbox prototypes; then an array is returned.
    if prototype and prototype.object_name ~= "LuaFluidBoxPrototype" then prototype = prototype[1] end
    local kind = prototype and prototype.production_type
    return kind == "input" or kind == "input-output"
end

function M.remove_fluid(fluidbox, need)
    local removed = 0
    for index = 1, #fluidbox do
        if removed >= need.amount - 1e-9 then break end
        local fluid = fluidbox[index]
        if fluid and fluid.name == need.name and is_input(fluidbox, index)
            and (not need.minimum_temperature or fluid.temperature >= need.minimum_temperature)
            and (not need.maximum_temperature or fluid.temperature <= need.maximum_temperature) then
            local take = math.min(fluid.amount, need.amount - removed)
            local rest = fluid.amount - take
            if rest <= 1e-9 then
                fluidbox[index] = nil
            else
                fluidbox[index] = {name = fluid.name, amount = rest, temperature = fluid.temperature}
            end
            removed = removed + take
        end
    end
    return removed
end

-- Consume as much of the owed ingredient set as is present now.
function M.pay(entity, debt, quality)
    local inventory = entity.get_inventory(defines.inventory.crafter_input)
    local fluidbox = entity.fluidbox
    for index = #debt, 1, -1 do
        local need = debt[index]
        if need.type == "fluid" then
            need.amount = need.amount - M.remove_fluid(fluidbox, need)
        elseif inventory then
            local count = math.ceil(need.amount - 1e-9)
            if count > 0 then
                need.amount = need.amount - inventory.remove({name = need.name, count = count, quality = quality})
            end
        end
        if need.amount <= 1e-6 then table.remove(debt, index) end
    end
    return #debt == 0
end

-- Not crafting: look again within half of the next craft. A set recipe (assembler waiting for
-- ingredients or with a full output) gives its own duration; otherwise the fastest recipe of the
-- machine's categories is assumed.
local function idle_delay(entity, ctx, recipe)
    local energy = recipe and recipe.energy
    if not energy or energy <= 0 then energy = ctx.min_energy(entity) end
    local speed = entity.crafting_speed
    if not energy or speed <= 0 then return 30 end
    return math.min(M.MAX_IDLE, math.max(1, math.floor(energy * 60 / speed / 2)))
end

-- Undecided craft: the next look lands 2..3 full-speed ticks before completion (inside the FINAL
-- window) instead of approaching it in several steps. The machine can only be slower than full speed
-- (power), so the look comes early, not late; a speed-up between looks (modules, beacons) may let
-- a craft complete unobserved ("missed-craft" warning).
function M.approach(left)
    return math.max(1, math.floor(left - M.FINAL) + 1)
end

local function after_decision(left, full)
    -- Observe the next craft early; if the output is blocked, poll slowly
    -- enough to stay well inside the next craft's duration.
    if left < 1 then return math.max(1, math.floor(full / 2)) end
    return math.ceil(left) + 1
end

local function stat(ctx, entity, key, amount)
    if ctx.stat then ctx.stat(entity.force.index, key, amount) end
end

function M.fail(record, entity, recipe, quality, progress)
    local productivity = entity.productivity_bonus
    if productivity > 0 then
        -- Approximation: remove productivity progress earned by this attempt.
        entity.bonus_progress = math.max(0, entity.bonus_progress - productivity * progress)
    end
    entity.crafting_progress = 0
    local debt = {}
    for _, ingredient in pairs(recipe.ingredients) do
        debt[#debt + 1] = {
            type = ingredient.type, name = ingredient.name, amount = ingredient.amount,
            minimum_temperature = ingredient.minimum_temperature,
            maximum_temperature = ingredient.maximum_temperature,
        }
    end
    M.pay(entity, debt, quality)
    local key = record.craft.key
    local mode = record.craft.mode
    record.debt = #debt > 0 and debt or nil
    record.debt_key = key
    record.craft = {key = key, progress = 0, mode = mode, bonus = entity.bonus_progress}
    record.failures = (record.failures or 0) + 1
end

local function products_state(recipe, ctx)
    local any_item, all_finished = false, true
    for _, product in pairs(recipe.products) do
        if product.type == "item" then
            any_item = true
            if not ctx.finished[product.name] then all_finished = false end
        end
    end
    return any_item, all_finished
end

-- Scales the progress gained since the last look down to the mode's speed (and by the supply of
-- its extra power). Productivity progress is scaled the same way.
local function slow_down(entity, craft, progress, ctx)
    local mode = craft.mode
    if not (mode and mode.time > 1) then
        -- No moded craft: release the extra power of a previous one.
        if ctx.mode_power then ctx.mode_power(entity, nil, false) end
        return progress
    end
    local gained = progress - craft.progress
    -- Working: progress since the last look, or a craft seen for the first time. A stopped machine
    -- (circuit, no power) pays no extra power; progress made before the next look after it
    -- resumes is not paid and does not count (modes.draw_power returns 0 for it).
    local working = gained > 1e-9 or not craft.seen
    craft.seen = true
    craft.stalled = not working
    local supply = ctx.mode_power and ctx.mode_power(entity, mode, working) or 1
    if gained > 1e-9 then
        progress = craft.progress + gained * supply / mode.time
        entity.crafting_progress = progress
    end
    local bonus = entity.bonus_progress
    if craft.bonus and bonus > craft.bonus + 1e-9 then
        bonus = craft.bonus + (bonus - craft.bonus) * supply / mode.time
        entity.bonus_progress = bonus
    end
    craft.bonus = bonus
    return progress
end

-- Next look of a slowed (moded) craft; a stopped one is looked at often, so that its extra power
-- comes back soon after it resumes.
local function slowed_delay(craft, left)
    local delay = math.max(1, math.floor(left * M.STEP))
    if craft.stalled then delay = math.min(delay, M.STALL_LOOK) end
    return delay
end

-- Research 10: no loss and no new defect roll. Looks are still needed for a production mode, owed
-- ingredients, a defect of a craft decided before research 10 and a defective recipe (the result is
-- capped at the ingredients' grade or reset to standard). A defective craft that starts and ends
-- between two rare looks is not handled (accepted: user decision 2026-10-14, variant A).
local function relaxed(record, entity, recipe_quality, ctx)
    if record.debt then return false end
    local craft = record.craft
    if craft and (craft.defect or craft.mode) then return false end
    if recipe_quality and model.is_defect(recipe_quality.name) then return false end
    return not (ctx.mode_definition and ctx.mode_definition(entity))
end

-- Returns the delay in ticks until the next look, and an optional warning code.
function M.step(record, level, ctx)
    local entity = record.entity
    local recipe, recipe_quality = entity.get_recipe()
    if level == 10 and relaxed(record, entity, recipe_quality, ctx) then
        record.craft = nil
        -- Releases the extra power of a moded craft that has just ended.
        if ctx.mode_power then ctx.mode_power(entity, nil, false) end
        return M.RELAXED
    end
    if not recipe or not entity.is_crafting() then
        record.craft, record.debt = nil, nil
        if ctx.mode_power then ctx.mode_power(entity, nil, false) end
        return idle_delay(entity, ctx, recipe)
    end
    local quality = recipe_quality and recipe_quality.name or "normal"
    local energy = recipe.energy
    local speed = entity.crafting_speed
    if energy <= 0 or speed <= 0 then return 30 end
    local full = energy * 60 / speed
    if full <= M.MIN_TICKS then
        record.craft = nil
        -- Not handled: no mode either, so no extra power.
        if ctx.mode_power then ctx.mode_power(entity, nil, false) end
        return 30, "unsupported-speed"
    end

    local key = recipe.name .. "|" .. quality .. "|" .. entity.products_finished
    local progress = entity.crafting_progress
    local craft = record.craft
    local warning
    if not craft or craft.key ~= key or progress + 1e-6 < craft.progress then
        if craft and not craft.decided and craft.recipe == recipe.name and craft.key ~= key then
            warning = "missed-craft" -- completed between looks (speed rose sharply)
        end
        craft = {key = key, recipe = recipe.name, progress = progress, bonus = entity.bonus_progress}
        craft.mode = ctx.mode_definition and ctx.mode_definition(entity) or nil
        record.craft = craft
        if craft.mode then stat(ctx, entity, "mode." .. craft.mode.name) end
    end
    if record.debt and record.debt_key ~= key then record.debt = nil end
    if record.debt then
        if not M.pay(entity, record.debt, quality) then
            -- Wait for the owed ingredients; the attempt cannot complete meanwhile (no extra power).
            entity.crafting_progress = 0
            craft.progress = 0
            if ctx.mode_power then ctx.mode_power(entity, craft.mode, false) end
            return math.max(1, math.floor(full / 2)), warning
        end
        record.debt = nil
    end
    progress = slow_down(entity, craft, progress, ctx)
    craft.progress = progress
    local left = (1 - progress) * full
    local slowed = craft.mode and craft.mode.time > 1

    if craft.decided then
        -- Research 10 also removes a defect this handler rolled below the ingredients' grade.
        if level == 10 and craft.defect then
            local current = entity.result_quality
            if current and model.is_defect(current.name) then
                entity.result_quality = model.quality_name(craft.floor or 0)
            end
            craft.defect = nil
        end
        if slowed then return slowed_delay(craft, left), warning end
        return after_decision(left, full), warning
    end
    if left > M.FINAL then
        if slowed then return slowed_delay(craft, left), warning end
        return M.approach(left), warning
    end

    craft.decided = true
    local any_item, all_finished = products_state(recipe, ctx)
    local protected = ctx.exclude_finished and any_item and all_finished
    local mode = craft.mode
    local loss_factor = mode and mode.loss or 1
    stat(ctx, entity, "machine.ops")
    if level < 10 and not protected and loss_factor > 0
        and model.roll_loss(level, ctx.random, ctx.initial_loss_percent, loss_factor) then
        stat(ctx, entity, "machine.loss")
        M.fail(record, entity, recipe, quality, progress)
        return M.approach(full), warning
    end
    -- Mode boost of the quality-module roll, once per completed attempt, at the decision: a craft
    -- that completes unobserved (sharp speed-up between looks) gets none. Defective ingredients
    -- cap the result (below): no boost for them.
    if mode and any_item and (all_finished or ctx.quality_everywhere) and ctx.mode_boost
        and not (ctx.no_quality and ctx.no_quality[recipe.name]) and not model.is_defect(quality) then
        ctx.mode_boost(entity, recipe_quality, mode)
    end
    if any_item and classify.recycling[recipe.category] then
        -- Recycling keeps the native result: input quality or better (quality modules).
        -- Only defects become standard: recycled materials are never defective.
        local current = entity.result_quality
        if current and model.is_defect(current.name) then entity.result_quality = "normal" end
    elseif any_item then
        local current = entity.result_quality
        local name = current and current.name
        if name and not all_finished then
            -- Materials are never defective; positive quality is kept in the "quality everywhere" mode.
            if name ~= "normal" and (not ctx.quality_everywhere or model.is_defect(name)) then
                entity.result_quality = "normal"
            end
        elseif name and (name == "normal" or model.is_defect(name) or model.is_defect(quality)) then
            -- Positive/foreign results of standard or better ingredients (quality modules) stay.
            -- Paranoidal decision 2026-10-14: the result is never better than its ingredients. The
            -- recipe quality is the quality of all item ingredients; defective ingredients are repaired
            -- only in the refinement workshop, not by a new roll, a production mode, quality modules
            -- or research 10. The roll may still make the result worse.
            local floor = model.grade_of(quality)
            local target
            local exempt = false
            for _, product in pairs(recipe.products) do
                if ctx.no_defect and ctx.no_defect[product.name] then exempt = true end
            end
            if exempt then
                target = "normal"
            else
                local grade = 0
                if not (mode and mode.no_defect) then
                    local effective = rules.effective_level(level, mode)
                    if effective < 10 then grade = model.draw(effective, ctx.random()) end
                end
                target = model.quality_name(math.min(grade, floor))
            end
            if target ~= name then entity.result_quality = target end
            craft.floor = floor
            craft.defect = model.grade_of(target) < floor or nil
            stat(ctx, entity, "grade." .. model.grade_of(target))
        end
    end
    if slowed then return slowed_delay(craft, left), warning end
    return after_decision(left, full), warning
end

return M
