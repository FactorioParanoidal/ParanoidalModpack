-- Значение Beta 8: Rocket-Silo-Construction/prototypes/entities.lua, первая стадия стройки шахты (правка --drd).
local stage1 = data.raw["assembling-machine"]["rsc-silo-stage1"]
if stage1 and stage1.energy_source then
	stage1.energy_source.emissions_per_minute = { pollution = 2000 }
end
