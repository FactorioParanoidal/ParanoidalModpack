-- from KaoExtended
local color = data.raw['trivial-smoke']['train-smoke'].color
color.r = 0
color.g = 0
color.b = 0
-- end from KaoExtended
--баланс поездов
--локомотив мк1
data.raw.locomotive.locomotive.max_health = 1200
data.raw.locomotive.locomotive.weight = 2000
data.raw.locomotive.locomotive.max_speed = 1.2
data.raw.locomotive.locomotive.max_power = "800kW"
data.raw.locomotive.locomotive.reversing_power_modifier = 0.5
data.raw.locomotive.locomotive.braking_force = 14
data.raw.locomotive.locomotive.friction_force = 0.27
data.raw.locomotive.locomotive.air_resistance = 0.008
data.raw.locomotive.locomotive.energy_per_hit_point = 5
data.raw.locomotive.locomotive.energy_source.effectivity = 0.8
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
--вагон мк1
data.raw["cargo-wagon"]["cargo-wagon"].weight = 1000
data.raw["cargo-wagon"]["cargo-wagon"].max_speed = 1.5
data.raw["cargo-wagon"]["cargo-wagon"].braking_force = 3
data.raw["cargo-wagon"]["cargo-wagon"].friction_force = 0.3
data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["cargo-wagon"]["bob-cargo-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--вагон-цистерна мк1
data.raw["fluid-wagon"]["fluid-wagon"].weight = 1000
data.raw["fluid-wagon"]["fluid-wagon"].max_speed = 1.5
data.raw["fluid-wagon"]["fluid-wagon"].braking_force = 3
data.raw["fluid-wagon"]["fluid-wagon"].friction_force = 0.3
data.raw["fluid-wagon"]["fluid-wagon"].air_resistance = 0.007
-------------------------------------------------------------------------------------------------
data.raw["fluid-wagon"]["bob-fluid-wagon-3"].max_speed = 10
-------------------------------------------------------------------------------------------------
--артиллерийский вагон мк1
data.raw["artillery-wagon"]["artillery-wagon"].weight = 4000
data.raw["artillery-wagon"]["artillery-wagon"].max_speed = 1.5
data.raw["artillery-wagon"]["artillery-wagon"].braking_force = 3
data.raw["artillery-wagon"]["artillery-wagon"].friction_force = 0.5
data.raw["artillery-wagon"]["artillery-wagon"].air_resistance = 0.0065
-------------------------------------------------------------------------------------------------
data.raw["artillery-wagon"]["bob-artillery-wagon-3"].max_speed = 5

-- баланс электрички
if mods["BatteryElectricTrain"] then
	data.raw.locomotive["bet-locomotive"].max_health = 2000
	data.raw.locomotive["bet-locomotive"].max_speed = 2
	data.raw.locomotive["bet-locomotive"].max_power = "1000kW"
	data.raw.locomotive["bet-locomotive"].reversing_power_modifier = 1
	data.raw.locomotive["bet-locomotive"].braking_force = 20
	data.raw.locomotive["bet-locomotive"].friction_force = 0.25
	data.raw.locomotive["bet-locomotive"].air_resistance = 0.004
	data.raw.locomotive["bet-locomotive"].resistances[1] = { type = "fire", decrease = 50, percent = 70 }
	data.raw.locomotive["bet-locomotive"].resistances[2] = { type = "physical", decrease = 30, percent = 50 }
	data.raw.locomotive["bet-locomotive"].resistances[3] = { type = "impact", decrease = 100, percent = 80 }
	data.raw.locomotive["bet-locomotive"].resistances[4] = { type = "explosion", decrease = 30, percent = 50 }
	data.raw.locomotive["bet-locomotive"].resistances[5] = { type = "acid", decrease = 70, percent = 80 }
end
