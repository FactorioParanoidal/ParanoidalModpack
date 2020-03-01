--[[
    "name": "Unstoppable Trains",
    "title": "Increase damage dealt by locomotives",
    "author": "Skyshrim",
    "contact": "Skyshrim@gmail.com",
    "description": "CHANGES the base stats of the locomotive to reduce their vulurability to enemies.",
]]
local Data = require('__stdlib__/stdlib/data/data')

if settings.startup['picker-unstoppable-trains'].value then
    local loco = Data('locomotive', 'locomotive')
    loco.energy_per_hit_point = .000001
    loco.burner.effectivity = 25
    loco.reversing_power_modifier = 1
    loco.max_power = '12000kW'
    loco.weight = 200000
    loco.braking_force = 600
    loco.max_health = 10000
    loco.air_resistance = 0.075

    Data('cargo-wagon', 'cargo-wagon').weight = 10000
    Data('fluid-wagon', 'fluid-wagon').weight = 10000
    Data('artillery-wagon', 'artillery-wagon').weight = 10000
end
