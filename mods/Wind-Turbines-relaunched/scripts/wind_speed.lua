---
--- Created by xyzzycgn.
--- DateTime: 21.08.25 08:18
---

--- ensures that return value is in range low <= x <= high
--- @param x number value to check
--- @param low number low border
--- @param high number high border
local function in_range(x, low, high)
    if (x < low) then
        return low
    elseif x > high then
        return high
    else
        return x
    end
end

--- initializes wind speed
--- @return initial speed in interval [0, 1],  initial delta in interval [-0.05, 0.05]
local function init()
    return {
        v = math.random(),
        delta_v = (math.random() - 0.5) / 10
    }
end

local function windspeed(surface_index)
    storage.wind_speed_on_surface = storage.wind_speed_on_surface or {}
    local wsos = storage.wind_speed_on_surface[surface_index] or init()

    local v = in_range(wsos.v + wsos.delta_v, 0, 1)

    local min = -0.01
    local max = 0.01
    if wsos.delta_v < 0 then
        min = -0.01 - wsos.delta_v / 5
    elseif wsos.delta_v > 0 then
        max = 0.01 - wsos.delta_v / 5
    end

    local delta_v = in_range(wsos.delta_v + math.random() * (max - min) + min, -0.05, 0.05)

    wsos.v = v
    wsos.delta_v = delta_v

    storage.wind_speed_on_surface[surface_index] = wsos

    return v
end

return {
    init = init,
    windspeed = windspeed,
}
