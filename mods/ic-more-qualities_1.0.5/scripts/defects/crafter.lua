-- Crafting machines (assembling machines, furnaces, rocket silos).
-- One decision per completion attempt, taken shortly BEFORE the craft finishes:
--   loss    -> progress is reset and one more ingredient set is consumed, so the
--              failed attempt costs ingredients and time and yields nothing;
--   success -> finished products get a defect roll via result_quality,
--              intermediates/mixed outputs are forced to standard quality.
-- Never touches output inventories, belts or chests.
local model = require("scripts.defects.model")
local M = {}

M.FINAL = 3        -- decide when at most this many full-speed ticks remain
M.STEP = .75       -- otherwise look again after this fraction of the remainder
M.MAX_IDLE = 60
M.MIN_TICKS = 2    -- crafts this fast cannot be intercepted reliably

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

local function idle_delay(entity, ctx)
    local energy = ctx.min_energy(entity)
    local speed = entity.crafting_speed
    if not energy or speed <= 0 then return 30 end
    return math.min(M.MAX_IDLE, math.max(1, math.floor(energy * 60 / speed / 2)))
end

local function after_decision(left, full)
    -- Observe the next craft early; if the output is blocked, poll slowly
    -- enough to stay well inside the next craft's duration.
    if left < 1 then return math.max(1, math.floor(full / 2)) end
    return math.ceil(left) + 1
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
    record.debt = #debt > 0 and debt or nil
    record.debt_key = key
    record.craft = {key = key, progress = 0}
    record.failures = (record.failures or 0) + 1
end

-- Returns the delay in ticks until the next look, and an optional warning code.
function M.step(record, level, ctx)
    local entity = record.entity
    local recipe, recipe_quality = entity.get_recipe()
    if not recipe or not entity.is_crafting() then
        record.craft, record.debt = nil, nil
        return idle_delay(entity, ctx)
    end
    local quality = recipe_quality and recipe_quality.name or "normal"
    local energy = recipe.energy
    local speed = entity.crafting_speed
    if energy <= 0 or speed <= 0 then return 30 end
    local full = energy * 60 / speed
    if full <= M.MIN_TICKS then
        record.craft = nil
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
        craft = {key = key, recipe = recipe.name, progress = progress}
        record.craft = craft
    end
    if record.debt and record.debt_key ~= key then record.debt = nil end
    if record.debt then
        if not M.pay(entity, record.debt, quality) then
            -- Wait for the owed ingredients; the attempt cannot complete meanwhile.
            entity.crafting_progress = 0
            craft.progress = 0
            return math.max(1, math.floor(full / 2)), warning
        end
        record.debt = nil
    end
    craft.progress = progress
    local left = (1 - progress) * full

    if craft.decided then
        -- Research 10 also removes a defect this handler assigned to the running craft.
        if level == 10 and craft.defect then
            local current = entity.result_quality
            if current and model.is_defect(current.name) then entity.result_quality = "normal" end
            craft.defect = nil
        end
        return after_decision(left, full), warning
    end
    if left > M.FINAL then return math.max(1, math.floor(left * M.STEP)), warning end

    craft.decided = true
    local any_item, all_finished = false, true
    for _, product in pairs(recipe.products) do
        if product.type == "item" then
            any_item = true
            if not ctx.finished[product.name] then all_finished = false end
        end
    end
    local protected = ctx.exclude_finished and any_item and all_finished
    if level < 10 and not protected and model.production_failed(level, ctx.random()) then
        M.fail(record, entity, recipe, quality, progress)
        return math.max(1, math.floor(full * M.STEP)), warning
    end
    if any_item then
        local current = entity.result_quality
        local name = current and current.name
        if name and not all_finished then
            if name ~= "normal" then entity.result_quality = "normal" end
        elseif name and (name == "normal" or model.is_defect(name)) then
            -- Positive/foreign results (quality modules, quality ingredients) stay.
            local target = level == 10 and "normal" or model.quality_name(model.draw(level, ctx.random()))
            if target ~= name then entity.result_quality = target end
            craft.defect = model.is_defect(target) or nil
        end
    end
    return after_decision(left, full), warning
end

return M
