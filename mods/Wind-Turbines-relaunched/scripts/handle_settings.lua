---
--- Thin layer around settings.
---
--- Created by xyzzycgn.
--- DateTime: 06.08.25 17:15
---

local translate = {
    CLASSICAL = 0,
    SURFACE = 1,
    ["SURFACE+PRESSURE"] = 2,
}

local handle_settings = {}

--- @return uint
local function windModeAsNumber()
    return translate[handle_settings.windMode()]
end

--- @return uint
function handle_settings.WindPower()
    return settings.startup['texugo-wind-power'].value
end

--- @return boolean
function handle_settings.WindTurbine4()
    return settings.startup["texugo-wind-turbine4"].value
end

--- @return uint
function handle_settings.windMode()
    return settings.startup["texugo-wind-mode"].value
end

--- @return boolean
function handle_settings.useExtendedCollisionArea()
    return settings.startup['texugo-wind-extended-collision-area'].value
end

--- @return boolean
function handle_settings.useSurfaceWindSpeed()
    return windModeAsNumber() > 0
end

--- @return boolean
function handle_settings.scaleWithPressure()
    return windModeAsNumber() == 2
end

--- combined scaling factor of max increase by quality and/or pressure
--- @return number
function handle_settings.scaleWithQualityAndPressure()
    local scale = handle_settings.useSurfaceWindSpeed() and handle_settings.scaleWithPressure() and 20 or 1
    return mods["space-age"] and (scale * 3.5) or scale
end
-- ###############################################################

--- Flag whether the more expensive recipes should be used for construction of turbines
--- @return boolean
function handle_settings.constructionMoreExpensive()
    return settings.startup["texugo-wind-expensive-recipes"].value
end

return handle_settings