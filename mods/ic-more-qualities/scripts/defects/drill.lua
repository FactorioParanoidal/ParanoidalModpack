-- Defective mining drills and pumpjacks (standard and positive drills are never tracked: they have
-- nothing to handle).
--   * Defective drills mine at m = 1/3 ... 13/15 of their speed (model.multiplier).
--   * Extra pollution for the slowdown: per minute ~1/m of standard (approximate).
--   * Resource drain of a defective drill is x2 ... x6 of standard (model.drain_multiplier), at every
--     research level. The engine drains the standard part; the rest is removed here when the cycle is
--     committed (or found completed unobserved).
-- Rewritten 2026-10-29: the cycle is slowed by rewinding the engine progress ahead of time instead of
-- approaching the end in many small steps. The script keeps the slowed ("virtual") progress V of the cycle;
-- on every look V gains m times the engine progress made since the last look, and the engine progress is
-- set to the lowest value from which the engine at full speed finishes exactly when the slowed cycle
-- would: T - (T - V) / m. While that is below 0 the engine progress is set to 0 and the next look comes
-- just before the engine could complete; once it is positive the cycle is committed (extra drain) and the
-- engine finishes it alone. About 1/m + 1 looks per cycle; the progress bar of a defective drill fills and
-- restarts that many times per cycle.
-- Never touches output inventories, belts or furnaces fed by the drill.
local model = require("scripts.defects.model")
local M = {}

M.FINAL = 3       -- the uncommitted engine may not come closer than this many full-speed ticks to the end
M.MIN_TICKS = 2
M.NO_TARGET = 15
M.DEPLETED = 300  -- no resource left under the drill: nothing will start soon

-- Prototype-derived caches by name (identical on every peer, rebuilt after load).
local mining_speeds, mining_times, energy_usages, drain_percents, emissions = {}, {}, {}, {}, {}

local function per_name(cache, name, entity, read)
    local value = cache[name]
    if value == nil then
        value = read(entity.prototype)
        if value == nil then value = false end
        cache[name] = value
    end
    return value or nil
end

local function read_speed(prototype) return prototype.mining_speed / 60 end
local function read_time(prototype) return prototype.mineable_properties.mining_time end
local function read_energy(prototype) return prototype.energy_usage end
local function read_drain(prototype) return prototype.resource_drain_rate_percent or 100 end
local function read_emissions(prototype)
    local source = prototype.electric_energy_source_prototype or prototype.burner_prototype
    return source and source.emissions_per_joule
end

function M.pollute(entity, working_ticks, multiplier, name)
    if multiplier >= 1 or working_ticks <= 0 then return 0 end
    name = name or entity.name
    local per_joule = per_name(emissions, name, entity, read_emissions)
    if not per_joule then return 0 end
    local surface = entity.surface
    local pollutant = surface.pollutant_type
    local rate = pollutant and per_joule[pollutant.name]
    if not rate or rate <= 0 then return 0 end
    local energy = per_name(energy_usages, name, entity, read_energy) * (1 + entity.consumption_bonus)
    local amount = (1 / multiplier - 1) * working_ticks * energy * rate * (1 + entity.pollution_bonus)
    if amount > 0 then surface.pollute(entity.position, amount, name) end
    return amount
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
    return M.remove(target, per_name(drain_percents, entity.name, entity, read_drain) / 100 * (drain - 1), ctx, true)
end

-- Returns the delay in ticks until the next look (false: stop tracking) and an optional warning code.
function M.step(record, level, ctx)
    local entity = record.entity
    -- The quality of a placed drill never changes: both factors are kept on the record.
    local multiplier, drain = record.multiplier, record.drain
    if not (multiplier and drain) then
        local quality = entity.quality.name
        multiplier, drain = model.quality_multiplier(quality), model.quality_drain_multiplier(quality)
        record.multiplier, record.drain = multiplier, drain
    end
    if multiplier >= 1 then return false end
    local target = entity.mining_target
    if not target then
        record.cycle = nil
        if entity.status == defines.entity_status.no_minable_resources then return M.DEPLETED end
        return M.NO_TARGET
    end
    local name = record.name
    if not name then
        name = entity.name
        record.name = name
    end
    local speed = record.speed
    if not speed then
        speed = per_name(mining_speeds, name, entity, read_speed)
        record.speed = speed
    end
    local cycle = record.cycle
    local source = cycle and cycle.source
    local same = source ~= nil and source.valid and source == target
    local mining_time = same and cycle.time or per_name(mining_times, target.name, target, read_time)
    local native = speed * (1 + entity.speed_bonus)
    if native <= 0 or not mining_time or mining_time <= 0 then return 30 end
    local full = mining_time / native
    if full <= M.MIN_TICKS then
        record.cycle = nil
        return 30, "unsupported-speed"
    end

    local progress = entity.mining_progress
    local bonus = entity.bonus_mining_progress
    local previous = same and cycle.engine
    local warning
    if not previous or progress + 1e-6 < previous then
        -- A wrap (progress below the value written last) only shows a completion the engine reached after the
        -- cycle was committed or while the engine progress was positive; a cycle completed from 0 between two
        -- looks after a sharp speed-up is not seen.
        if previous and not cycle.committed then
            warning = "missed-cycle"
            -- The engine completed this cycle unobserved: its defect drain is still owed.
            M.extra(entity, target, drain, ctx)
        end
        -- A wrap or retarget starts the new cycle at zero: the engine progress since then is slowed too.
        -- On first registration (also a cycle of an older version) the history is unknown and kept as is.
        local start = (cycle and cycle.engine ~= nil) and 0 or progress
        cycle = {source = target, time = mining_time, engine = start, virtual = start, bonus = bonus}
        record.cycle = cycle
    end
    local virtual = cycle.virtual
    if not cycle.committed then
        local gained = progress - cycle.engine
        if gained > 1e-9 then
            virtual = virtual + gained * multiplier
            local bonus_gain = bonus - cycle.bonus
            if bonus_gain > 0 then
                bonus = cycle.bonus + bonus_gain * multiplier
                entity.bonus_mining_progress = bonus
            end
            M.pollute(entity, gained / native, multiplier, name)
        end
        if virtual > mining_time then virtual = mining_time end
        -- Lowest engine progress from which full speed finishes together with the slowed cycle.
        local engine = mining_time - (mining_time - virtual) / multiplier
        if engine > 0 then
            cycle.committed = true
            -- The defect drain does not depend on research (also at level 10).
            M.extra(entity, target, drain, ctx)
        else
            engine = 0
        end
        if math.abs(engine - progress) > 1e-9 then entity.mining_progress = engine end
        cycle.engine, cycle.virtual, cycle.bonus = engine, virtual, bonus
        progress = engine
    end
    local left = (mining_time - progress) / native
    if cycle.committed then
        if left < 1 then return math.max(1, math.floor(full / 2)), warning end
        return math.ceil(left) + 1, warning
    end
    -- Land a few full-speed ticks before the engine could complete the cycle.
    return math.max(1, math.floor(left - M.FINAL) + 1), warning
end

return M
