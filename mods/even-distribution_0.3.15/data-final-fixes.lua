-- Autotrash Modifications --

if settings.startup["early-autotrash-research"].value then

	local tech = data.raw.technology["character-logistic-trash-slots-1"]
	tech.prerequisites = { "logistics" }
	tech.unit = {
		count = mods["SeaBlock"] and 15 or 30,
		ingredients = { {"automation-science-pack", 1} },
		time = 15
    }

	tech = data.raw.technology["auto-character-logistic-trash-slots"]
	tech.prerequisites = { "character-logistic-trash-slots-1" }
	tech.unit = {
		count = mods["SeaBlock"] and 25 or 50,
		ingredients = { {"automation-science-pack", 1} },
		time = 15
    }
	
	tech = data.raw.technology["character-logistic-trash-slots-2"]
	if mods.IndustrialRevolution then
		tech.prerequisites = { "robotics", "character-logistic-trash-slots-1" }
	else
		tech.prerequisites = { "logistic-robotics", "character-logistic-trash-slots-1" }
	end

end