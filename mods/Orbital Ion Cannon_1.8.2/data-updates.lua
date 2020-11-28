-- if data.raw["tool"]["science-pack-4"] and settings.startup["ion-cannon-bob-updates"].value then
	-- data.raw["technology"]["orbital-ion-cannon"].unit.ingredients[5] = {"science-pack-4", 2}
	-- data.raw["technology"]["auto-targeting"].unit.ingredients[5] = {"science-pack-4", 1}
-- end

if not data.raw["assembling-machine"]["assembling-machine-4"] then
	data.raw["assembling-machine"]["assembling-machine-3"].ingredient_count = 8
else
	data.raw["assembling-machine"]["assembling-machine-4"].ingredient_count = 8
end
