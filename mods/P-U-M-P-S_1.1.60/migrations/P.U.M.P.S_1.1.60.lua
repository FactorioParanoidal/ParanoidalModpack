game.reload_script()

local techs =
{
	["water-miner-1"] = "water-pumpjack-1",
	["water-miner-2"] = "water-pumpjack-2",
	["water-miner-3"] = "water-pumpjack-3",
	["water-miner-4"] = "water-pumpjack-4",
	["water-miner-5"] = "water-pumpjack-5",
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