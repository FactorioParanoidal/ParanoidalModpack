if mods["BatteryElectricTrain"] then
	--баланс акб
	data.raw.item["bet-fuel-1-full"].fuel_acceleration_multiplier = 1.5
	data.raw.item["bet-fuel-1-full"].fuel_top_speed_multiplier = 1

	data.raw.item["bet-fuel-2-full"].fuel_acceleration_multiplier = 2
	data.raw.item["bet-fuel-2-full"].fuel_top_speed_multiplier = 1.5

	data.raw.item["bet-fuel-3-full"].fuel_acceleration_multiplier = 2.5
	data.raw.item["bet-fuel-3-full"].fuel_top_speed_multiplier = 2

	data.raw.item["bet-fuel-4-full"].fuel_acceleration_multiplier = 3.5
	data.raw.item["bet-fuel-4-full"].fuel_top_speed_multiplier = 3
end
