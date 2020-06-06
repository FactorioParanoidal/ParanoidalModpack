--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: checkModuleMatching.lua
 * Description: Checks if a pair of locos are RET modular type, and if the module configurations match.
 *   Returns true if they are not modular locos.
 --]]

local moduleTypes = nil

local function isRelevantModule(name)
	
	if moduleTypes == nil then
		moduleTypes = {}
		game.print("MUTC is Caching RET module types")
		-- Cache table of allowable modules
		if game.technology_prototypes["ret-modular-locomotives"] then
			for _,effect in pairs(game.technology_prototypes["ret-modular-locomotives"].effects) do
				if effect.type == "unlock-recipe" and game.equipment_prototypes[effect.recipe] then
					moduleTypes[effect.recipe] = true
					--game.print("Cached module type " .. effect.recipe)
				end
			end
		end
	end
	
	if moduleTypes[name] then
		return true
	else
		return false
	end
	
end
 
 

function checkModuleMatching(loco1, loco2)

	-- Given a pair of locos that have same type and are in the right spot in the train to be a pair
	-- Check if they have modular locomotive grids
	if loco1.grid and loco1.grid.prototype.name=="modular-locomotive-grid" then
		-- Read grid contents of both locos
		local gridOne = loco1.grid.get_contents()
		local gridTwo = loco2.grid.get_contents()
		local matched = true
		for k,v in pairs(gridOne) do
			if isRelevantModule(k) and not(gridTwo[k] and gridTwo[k]==v) then
				matched = false
				break
			end
		end
		if matched then
			for k,v in pairs(gridTwo) do
				if isRelevantModule(k) and not(gridOne[k] and gridOne[k]==v) then
					matched = false
					break
				end
			end
		end
		
		return matched
	else
		-- Not a modular locomotive, always able to replace
		return true
	end
end

return checkModuleMatching
