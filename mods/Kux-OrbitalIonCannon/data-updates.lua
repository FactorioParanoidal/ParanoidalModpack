require("mod")

-- if data.raw["tool"]["science-pack-4"] and settings.startup["ion-cannon-bob-updates"].value then
	-- data.raw["technology"]["orbital-ion-cannon"].unit.ingredients[5] = {"science-pack-4", 2}
	-- data.raw["technology"]["auto-targeting"].unit.ingredients[5] = {"science-pack-4", 1}
-- end

local am = data.raw["assembling-machine"]["assembling-machine-4"]
if not am then am = data.raw["assembling-machine"]["assembling-machine-3"] end
if type(am.ingredient_count)=="number" and am.ingredient_count < 8 then am.ingredient_count = 8 end
