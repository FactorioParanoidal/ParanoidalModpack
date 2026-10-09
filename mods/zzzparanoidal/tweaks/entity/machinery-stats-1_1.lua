-- Значения Beta 8: angelsrefining/prototypes/buildings/liquifier.lua и extendedangels/prototypes/buildings/petrochem.lua (1.1).
local machines = data.raw["assembling-machine"]
local liquifiers = {
	["angels-liquifier-2"] = "150kW",
	["angels-liquifier-3"] = "200kW",
	["angels-liquifier-4"] = "300kW",
}

for name, energy in pairs(liquifiers) do
	local machine = machines[name]
	if machine then machine.energy_usage = energy end
end

local advanced_chemical_plant = machines["angels-advanced-chemical-plant-3"]
if advanced_chemical_plant then
	advanced_chemical_plant.energy_source.emissions_per_minute = { pollution = 6 }
end
