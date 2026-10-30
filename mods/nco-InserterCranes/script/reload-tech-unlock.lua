local me = {}
-------------------------------------------------------------------------------------
-- Crane technology name -> recipes it unlocks. Prototypes do not change while the
-- game runs, so the list is built once per session from the data stage result.
-------------------------------------------------------------------------------------
local crane_unlocks

local function get_crane_unlocks()
	if not crane_unlocks then
		crane_unlocks = {}
		for name, technology in pairs(prototypes.technology) do
			if name:find("^technology%-.+%-crane$") then
				local recipes = {}
				for _, effect in pairs(technology.effects) do
					if effect.type == "unlock-recipe" then
						recipes[#recipes + 1] = effect.recipe
					end
				end
				crane_unlocks[name] = recipes
			end
		end
	end
	return crane_unlocks
end
-------------------------------------------------------------------------------------
--Enable crane recipes if their technology is researched
-------------------------------------------------------------------------------------
function me.reload_tech_unlock()
	local unlocks = get_crane_unlocks()
	for _, force in pairs(game.forces) do
		local technologies, recipes = force.technologies, force.recipes
		for tech_name, recipe_names in pairs(unlocks) do
			local technology = technologies[tech_name]
			local researched = technology ~= nil and technology.researched
			for _, recipe_name in pairs(recipe_names) do
				local recipe = recipes[recipe_name]
				if recipe then
					recipe.enabled = researched
				end
			end
		end
	end
end
return me
