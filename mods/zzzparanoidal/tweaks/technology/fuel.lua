require("__zzzparanoidal__.paralib")
-- баланс электрички
if mods["BatteryElectricTrain"] then
	paralib.bobmods.lib.tech.add_prerequisite("bet-fuel-2", "bob-battery-2")
	paralib.bobmods.lib.tech.add_prerequisite("bet-fuel-3", "bob-battery-3")
	paralib.bobmods.lib.tech.add_prerequisite("bet-fuel-4", "speed-module-3")
end

