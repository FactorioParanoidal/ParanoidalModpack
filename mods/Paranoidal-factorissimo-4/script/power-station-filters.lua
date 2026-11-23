-- Own only the pollution channel of existing serviced air cleaners; native physics removes the mass.
local M = {}
local rates = {0, 0.025, 0.05, 0.10}
local function quantize(value)
    return math.min(1000, math.max(-1000, math.floor(value * 10000 + 0.5) / 10000))
end
local function write(entity, value)
    local effect = entity.local_effect
    if not effect then return end
    effect.pollution = value
    entity.local_effect = effect
    return entity.local_effect.pollution or 0
end
local function forget(unit, entry)
    local factory = storage.factories and storage.factories[entry.factory_id]
    local state = factory and factory.power_station
    if state and state.filter_units then state.filter_units[unit] = nil end
    storage.factory_station_filter_effects[unit] = nil
end
local function release(unit, owner)
    local registry = storage.factory_station_filter_effects
    local entry = registry and registry[unit]
    if not entry or (owner and entry.factory_id ~= owner) then return end
    if entry.entity.valid then
        local effect = entry.entity.local_effect
        -- A different value is an external replacement, not permission to subtract our old delta.
        if effect and (effect.pollution or 0) == entry.written then write(entry.entity, entry.base) end
    end
    forget(unit, entry)
end

-- Get the un-clamped offset only when needed. Native effects expose already-clamped totals.
-- All temporary writes happen in this one Lua callback, with no intervening native simulation.
local function boosted_value(entity, base, rate)
    write(entity, base)
    local current = entity.pollution_bonus
    local limits = entity.prototype.effect_receiver.pollution_limits
    local target = math.min(limits.high, (1 + current) * (1 + rate) - 1)
    if target <= current then return base end
    if current > limits.low and current < limits.high then
        return quantize(base + target - current)
    end
    local left, right = base, 1000
    write(entity, right)
    local upper = entity.pollution_bonus
    if upper <= current then return base end
    target = math.min(target, upper)
    if upper > limits.low and upper < limits.high then return quantize(right + target - upper) end
    for _ = 1, 24 do
        local middle = (left + right) / 2
        local actual = write(entity, quantize(middle))
        local observed = entity.pollution_bonus
        if observed > limits.low and observed < limits.high then
            return quantize(actual + target - observed)
        end
        if observed <= limits.low then left = middle else right = middle end
    end
    return quantize(right)
end

function M.rate(tier)
    return rates[(tier or 0) + 1]
end

function M.clear(factory)
    local state = factory.power_station
    if not (state and state.filter_units) then return end
    for unit in pairs(state.filter_units) do release(unit, factory.id) end
    state.filter_units = {}
end

function M.apply(factory, entities, rate)
    local state = factory.power_station
    local registry = storage.factory_station_filter_effects or {}
    storage.factory_station_filter_effects = registry
    local units = {}
    if rate > 0 then
        for _, entity in ipairs(entities) do
            local unit = entity.unit_number
            local entry = registry[unit]
            if entry and entry.factory_id ~= factory.id then release(unit); entry = nil end
            local effect = entity.local_effect
            if effect then
                local current = effect.pollution or 0
                local base = entry and current == entry.written and entry.base or current
                local value = boosted_value(entity, base, rate)
                local actual = write(entity, value)
                if actual ~= base then
                    registry[unit] = {entity = entity, factory_id = factory.id, base = base, written = actual,
                        total = entity.pollution_bonus}
                    units[unit] = true
                elseif entry then
                    forget(unit, entry)
                end
            elseif entry then
                release(unit, factory.id)
            end
        end
    end
    for unit in pairs(state.filter_units or {}) do
        if not units[unit] then release(unit, factory.id) end
    end
    state.filter_units = units
end

function M.invalidate(entity)
    if entity and entity.valid and entity.unit_number then release(entity.unit_number) end
end

function M.prune(eligible, changed)
    for unit, entry in pairs(storage.factory_station_filter_effects or {}) do
        local factory = storage.factories and storage.factories[entry.factory_id]
        if not entry.entity.valid or not factory or not eligible(factory, entry.entity)
            or not entry.total or math.abs(entry.entity.pollution_bonus - entry.total) > 0.000001 then
            release(unit)
            if factory then changed(factory) end
        end
    end
end

function M.reset()
    for unit in pairs(storage.factory_station_filter_effects or {}) do release(unit) end
    storage.factory_station_filter_effects = {}
end

factorissimo.on_event(defines.events.on_entity_cloned, function(event)
    local source, destination = event.source, event.destination
    local registry = storage.factory_station_filter_effects
    local entry = source.valid and registry and registry[source.unit_number]
    if not (entry and destination.valid) then return end
    local a, b = source.local_effect, destination.local_effect
    if a and b and (a.pollution or 0) == entry.written and (b.pollution or 0) == entry.written then
        write(destination, entry.base)
    end
end)

return M
