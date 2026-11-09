local rro = Muluna.rro
-- Paranoidal fork: planet discoveries keep the space platform thruster as a prerequisite (the build's platform set);
-- upstream replaced it by the space science technology everywhere.

data.raw["recipe"]["crusher"].subgroup = "smelting-machine"
data.raw["item"]["crusher"].subgroup = "smelting-machine"
data.raw["assembling-machine"]["crusher"].subgroup = "smelting-machine"
data.raw["item"]["crusher"].order = "ca[crusher]"

--Factorio 2.1.24 removed the crusher's heating energy and pollution emission.
--Restore the 2.1.23 values so the crusher behaves the same on the stable and
--experimental releases. crusher-2 copies this prototype, so the values have to
--be restored before prototypes/entity/crusher-2.lua runs.
local vanilla_crusher = data.raw["assembling-machine"]["crusher"]
if vanilla_crusher then
    vanilla_crusher.heating_energy = vanilla_crusher.heating_energy or "200kW"
    vanilla_crusher.energy_source.emissions_per_minute =
        vanilla_crusher.energy_source.emissions_per_minute or {}
    vanilla_crusher.energy_source.emissions_per_minute["pollution"] =
        vanilla_crusher.energy_source.emissions_per_minute["pollution"] or 1
end
