game.reload_script()

local techs =
{
	["water-pumpjack"] = "water-pumpjack-1",
	["water-miner_2"] = "water-pumpjack-2",
	["water-miner_3"] = "water-pumpjack-3",
	["water-miner_4"] = "water-pumpjack-4",
	["water-miner_5"] = "water-pumpjack-5",
	
	["offshore-pump-tech_2"] = "offshore-pump-2",
	["offshore-pump-tech_3"] = "offshore-pump-3",
	["offshore-pump-tech_4"] = "offshore-pump-4"
}

for _, force in pairs(game.forces) do
force.reset_recipes()
force.reset_technologies()

	for old_tech, new_tech in pairs(techs) do

		if force.technologies[old_tech] then
			if force.technologies[new_tech] and force.technologies[old_tech].researched then
				force.technologies[new_tech].researched = true --automatically unlock it
			end
		end
	end
end