-- Mining drills and pumpjacks.
--   * Defective drills mine at m = 1/3 ... 13/15 of their speed: progress gained
--     between looks is scaled back (also productivity progress).
--   * Extra pollution for the slowdown: per minute ~1/m of standard (approximate).
--   * Loss: shortly BEFORE a cycle completes, the cycle may fail. The resource is
--     drained as if mined, progress is reset, nothing is output.
-- Never touches output inventories, belts or furnaces fed by the drill.
local model = require("scripts.defects.model")
local M = {}

M.FINAL = 3
M.STEP = .75
M.MIN_TICKS = 2
M.NO_TARGET = 15

function M.pollute(entity, working_ticks, multiplier, ctx)
    if multiplier >= 1 or working_ticks <= 0 then return 0 end
    local surface = entity.surface
    local pollutant = surface.pollutant_type
    local per_joule = pollutant and ctx.emissions(entity)
    local rate = per_joule and per_joule[pollutant.name]
    if not rate or rate <= 0 then return 0 end
    local energy = entity.prototype.energy_usage * (1 + entity.consumption_bonus)
    local amount = (1 / multiplier - 1) * working_ticks * energy * rate * (1 + entity.pollution_bonus)
    if amount > 0 then surface.pollute(entity.position, amount, entity.name) end
    return amount
end

-- A failed cycle still consumes what the mined unit would have consumed.
function M.drain(entity, target, ctx)
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
    local percent = entity.prototype.resource_drain_rate_percent or 100
    if percent < 100 and ctx.random() >= percent / 100 then return "not-drained" end
    local prototype = target.prototype
    if prototype.infinite_resource then
        if target.amount > (prototype.minimum_resource_amount or 0) then target.amount = target.amount - 1 end
        return "drained"
    end
    if target.amount > 1 then
        target.amount = target.amount - 1
        return "drained"
    end
    target.deplete()
    return "depleted"
end

local function after_decision(left, full)
    if left < 1 then return math.max(1, math.floor(full / 2)) end
    return math.ceil(left) + 1
end

function M.step(record, level, ctx)
    local entity = record.entity
    local target = entity.mining_target
    if not target or not target.valid then
        record.cycle = nil
        return M.NO_TARGET
    end
    local native = entity.prototype.mining_speed * (1 + entity.speed_bonus) / 60
    local mining_time = target.prototype.mineable_properties.mining_time
    if native <= 0 or not mining_time or mining_time <= 0 then return 30 end
    local full = mining_time / native
    if full <= M.MIN_TICKS then
        record.cycle = nil
        return 30, "unsupported-speed"
    end

    local multiplier = model.quality_multiplier(entity.quality.name)
    local progress = entity.mining_progress
    local bonus = entity.bonus_mining_progress
    local position = target.position
    local target_key = target.name .. "@" .. position.x .. "," .. position.y
    local cycle = record.cycle
    local warning
    if not cycle or cycle.target ~= target_key or progress + 1e-6 < cycle.progress then
        if cycle and not cycle.decided and cycle.target == target_key then
            warning = "missed-cycle"
        end
        -- A wrap or retarget starts the new cycle at zero: slow that part too.
        -- On first registration the history is unknown and is left as is.
        cycle = {target = target_key, progress = cycle and 0 or progress, bonus = bonus, bonus_start = bonus}
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
    if left > M.FINAL then return math.max(1, math.floor(left * M.STEP)), warning end

    cycle.decided = true
    if level < 10 and model.production_failed(level, ctx.random()) then
        if bonus > cycle.bonus_start then entity.bonus_mining_progress = cycle.bonus_start end
        entity.mining_progress = 0
        M.drain(entity, target, ctx)
        local start = entity.bonus_mining_progress
        record.cycle = {target = target_key, progress = 0, bonus = start, bonus_start = start}
        record.failures = (record.failures or 0) + 1
        return math.max(1, math.floor(full * M.STEP)), warning
    end
    return after_decision(left, full), warning
end

return M
