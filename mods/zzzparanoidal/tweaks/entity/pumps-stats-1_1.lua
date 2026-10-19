-- Значения Beta 8: zzzparanoidal/prototypes/offshore-pump и angelsrefining/prototypes/buildings/seafloor-pump.lua (1.1).
local pumps = data.raw["offshore-pump"]

local offshore = {
	{ name = "offshore-mk0-pump", speed = 5, energy = "900kW", pollution = 9, mining_time = 1 },
	{ name = "offshore-pump", speed = 20, energy = "1200kW", pollution = 1, mining_time = 0.1 },
	{ name = "offshore-mk2-pump", speed = 40, energy = "2000kW", pollution = 1, mining_time = 1 },
	{ name = "offshore-mk3-pump", speed = 60, energy = "2800kW", pollution = 1, mining_time = 1 },
	{ name = "offshore-mk4-pump", speed = 80, energy = "3700kW", pollution = 1, mining_time = 1 },
}

for _, spec in ipairs(offshore) do
	local pump = pumps[spec.name]
	if pump then
		pump.pumping_speed = spec.speed
		pump.energy_usage = spec.energy
		pump.energy_source.emissions_per_minute = { pollution = spec.pollution }
		if spec.name == "offshore-mk0-pump" then
			pump.energy_source.fuel_categories = { "chemical" }
		end
		pump.max_health = 150
		pump.minable.mining_time = spec.mining_time
		pump.resistances = { { type = "fire", percent = 70 }, { type = "impact", percent = 30 } }
		pump.circuit_wire_max_distance = 9
		pump.fluid_box.volume = 100
		pump.fluid_box.filter = "water"
	end
end

-- Донные насосы: скорость, питание, выбросы и здоровье 1.1 — в prototypes/seafloor-pumps/tiers.lua.
for _, name in ipairs({ "angels-seafloor-pump", "paranoidal-seafloor-pump-2", "paranoidal-seafloor-pump-3" }) do
	local pump = pumps[name]
	if pump then
		pump.minable.mining_time = 1
		pump.resistances = { { type = "fire", percent = 70 } }
		pump.circuit_wire_max_distance = 9
		pump.fluid_box.volume = 100
		pump.fluid_box.filter = "angels-water-viscous-mud"
	end
end

local groundwater = pumps["angels-ground-water-pump"]
if groundwater then
	groundwater.pumping_speed = 1
	-- Void-питание 2.0 сохраняет нулевое потребление из внешних источников, как в 1.1.
	groundwater.max_health = 100
	groundwater.minable.mining_time = 0.1
	groundwater.resistances = { { type = "fire", percent = 70 }, { type = "impact", percent = 30 } }
	groundwater.circuit_wire_max_distance = 9
	groundwater.fluid_box.volume = 100
	groundwater.fluid_box.filter = "water"
end
