-- Mining drills and pumpjacks.
--   * Defective drills mine at m = 1/3 ... 13/15 of their speed: progress gained
--     between looks is scaled back (also productivity progress).
--   * Extra pollution for the slowdown: per minute ~1/m of standard (approximate).
--   * Resource drain of a defective drill is x2 ... x6 of standard (model.drain_multiplier),
--     at every research level. The engine drains the standard part; the rest is removed here
--     when the cycle is decided (or found completed unobserved).
--   * Loss: shortly BEFORE a cycle completes, the cycle may fail. The resource is
--     drained as if mined (with the defect drain), progress is reset, nothing is output.
-- Never touches output inventories, belts or furnaces fed by the drill.
local model = require("scripts.defects.model")
local M = {}

M.FINAL = 3
M.STEP = .75
M.MIN_TICKS = 2
M.NO_TARGET = 15
M.DEPLETED = 300 -- no resource left under the drill: nothing will start soon
M.RELAXED = 600 -- research 10: a drill that is not defective has nothing to handle

-- Prototype-derived caches by name (identical on every peer, rebuilt after load).
local mining_speeds, mining_times, energy_usages, drain_percents = {}, {}, {}, {}

local function mining_speed(entity)
    local name = entity.name
    local speed = mining_speeds[name]
    if not speed then
        speed = entity.prototype.mining_speed
        mining_speeds[name] = speed
    end
    return speed
end

local function cached_mining_time(target)
    local name = target.name
    local time = mining_times[name]
    if time == nil then
        time = target.prototype.mineable_properties.mining_time or false
        mining_times[name] = time
    end
    return time or nil
end

local function energy_usage(entity)
    local name = entity.name
    local energy = energy_usages[name]
    if not energy then
        energy = entity.prototype.energy_usage
        energy_usages[name] = energy
    end
    return energy
end

function M.pollute(entity, working_ticks, multiplier, ctx)
    if multiplier >= 1 or working_ticks <= 0 then return 0 end
    local surface = entity.surface
    local pollutant = surface.pollutant_type
    local per_joule = pollutant and ctx.emissions(entity)
    local rate = per_joule and per_joule[pollutant.name]
    if not rate or rate <= 0 then return 0 end
    local energy = energy_usage(entity) * (1 + entity.consumption_bonus)
    local amount = (1 / multiplier - 1) * working_ticks * energy * rate * (1 + entity.pollution_bonus)
    if amount > 0 then surface.pollute(entity.position, amount, entity.name) end
    return amount
end

local function drain_percent(entity)
    local name = entity.name
    local percent = drain_percents[name]
    if not percent then
        percent = entity.prototype.resource_drain_rate_percent or 100
        drain_percents[name] = percent
    end
    return percent
end

-- Removes `units` resource units from the target; a fractional part is removed by chance.
-- keep_last: a finite resource keeps at least one unit, so the engine finishes the running
-- cycle on it and depletes it itself. Returns "drained", "not-drained" or "depleted".
function M.remove(target, units, ctx, keep_last)
    local whole = math.floor(units + 1e-9)
    local part = units - whole
    if part > 1e-9 and ctx.random() < part then whole = whole + 1 end
    if whole <= 0 then return "not-drained" end
    local prototype = target.prototype
    local amount = target.amount
    if prototype.infinite_resource then
        local minimum = prototype.minimum_resource_amount or 0
        if amount <= minimum then return "not-drained" end
        target.amount = math.max(minimum, amount - whole * (prototype.infinite_depletion_resource_amount or 1))
        return "drained"
    end
    if amount > whole then
        target.amount = amount - whole
        return "drained"
    end
    if keep_last then
        if amount <= 1 then return "not-drained" end
        target.amount = 1
        return "drained"
    end
    target.deplete()
    return "depleted"
end

-- Extra drain of one completed cycle of a defective drill (the engine drained the standard part).
function M.extra(entity, target, drain, ctx)
    if drain <= 1 or not (target and target.valid) then return "not-drained" end
    return M.remove(target, drain_percent(entity) / 100 * (drain - 1), ctx, true)
end

-- A failed cycle still consumes what the mined unit would have consumed (defect drain included).
function M.drain(entity, target, ctx, drain)
    local properties = target.prototype.mineable_properties
    local fluid = properties.required_fluid
    if fluid and properties.fluid_amount and properties.fluid_amount > 0 then
        -- Approximation: fluid_amount is defined per 10 mining cycles.
        local fluidbox = entity.fluidbox
        local need = properties.fluid_amount / 10
        for index = 1, #fluidbox do
            local content = fluidbox[index]
            if need <= 0 then break end
            if content and content.name == fluid then
                local take = math.min(content.amount, need)
                local rest = content.amount - take
                fluidbox[index] = rest > 1e-9 and {name = content.name, amount = rest, temperature = content.temperature} or nil
                need = need - take
            end
        end
    end
    return M.remove(target, drain_percent(entity) / 100 * (drain or 1), ctx)
end

local function after_decision(left, full)
    if left < 1 then return math.max(1, math.floor(full / 2)) end
    return math.ceil(left) + 1
end

function M.step(record, level, ctx)
    local entity = record.entity
    -- The quality of a placed drill never changes.
    local multiplier = record.multiplier
    if not multiplier then
        multiplier = model.quality_multiplier(entity.quality.name)
        record.multiplier = multiplier
    end
    local drain = record.drain
    if not drain then
        drain = model.quality_drain_multiplier(entity.quality.name)
        record.drain = drain
    end
    -- Research 10: no loss any more; only a defective drill is still slowed down.
    if level == 10 and multiplier >= 1 then
        record.cycle = nil
        return M.RELAXED
    end
    local target = entity.mining_target
    if not target or not target.valid then
        record.cycle = nil
        if entity.status == defines.entity_status.no_minable_resources then return M.DEPLETED end
        return M.NO_TARGET
    end
    local native = mining_speed(entity) * (1 + entity.speed_bonus) / 60
    local mining_time = cached_mining_time(target)
    if native <= 0 or not mining_time or mining_time <= 0 then return 30 end
    local full = mining_time / native
    if full <= M.MIN_TICKS then
        record.cycle = nil
        return 30, "unsupported-speed"
    end

    local progress = entity.mining_progress
    local bonus = entity.bonus_mining_progress
    local cycle = record.cycle
    -- The resource entity itself identifies the cycle target (no string key per look).
    local source = cycle and cycle.source
    local same = source ~= nil and source.valid and source == target
    local warning
    if not same or progress + 1e-6 < cycle.progress then
        if same and not cycle.decided then
            warning = "missed-cycle"
            -- The engine completed this cycle unobserved: its defect drain is still owed.
            M.extra(entity, target, drain, ctx)
        end
        -- A wrap or retarget starts the new cycle at zero: slow that part too.
        -- On first registration the history is unknown and is left as is; so is a cycle of an older
        -- version (string key, no source).
        cycle = {source = target, progress = source ~= nil and 0 or progress, bonus = bonus, bonus_start = bonus}
        record.cycle = cycle
    end
    if not cycle.decided and multiplier < 1 then
        local gained = progress - cycle.progress
        if gained > 1e-9 then
            progress = cycle.progress + gained * multiplier
            entity.mining_progress = progress
            local bonus_gain = bonus - cycle.bonus
            if bonus_gain > 0 then
                bonus = cycle.bonus + bonus_gain * multiplier
                entity.bonus_mining_progress = bonus
            end
            M.pollute(entity, gained / native, multiplier, ctx)
        end
    end
    cycle.progress, cycle.bonus = progress, bonus
    local left = (mining_time - progress) / native
    if cycle.decided then return after_decision(left, full), warning end
    -- Land inside the FINAL window in one look (see crafter.approach).
    if left > M.FINAL then return math.max(1, math.floor(left - M.FINAL) + 1), warning end

    cycle.decided = true
    if ctx.stat then ctx.stat(entity.force.index, "drill.ops") end
    if level < 10 and model.roll_loss(level, ctx.random, ctx.initial_loss_percent) then
        if ctx.stat then ctx.stat(entity.force.index, "drill.loss") end
        if bonus > cycle.bonus_start then entity.bonus_mining_progress = cycle.bonus_start end
        entity.mining_progress = 0
        M.drain(entity, target, ctx, drain)
        local start = entity.bonus_mining_progress
        record.cycle = {source = target, progress = 0, bonus = start, bonus_start = start}
        record.failures = (record.failures or 0) + 1
        return math.max(1, math.floor(full - M.FINAL) + 1), warning
    end
    -- Successful cycle: the defect drain does not depend on research (also at level 10).
    M.extra(entity, target, drain, ctx)
    return after_decision(left, full), warning
end

return M
