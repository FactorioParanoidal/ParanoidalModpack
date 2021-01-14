
local function resetLogisticTechEffects(force)
	local trashslots = 0
	local autotrash = false
	local requests = false

	for _,tech in pairs(force.technologies) do
		if tech.researched then
			for _,effect in pairs(tech.effects) do
				if effect.type == "character-logistic-trash-slots" then
					trashslots = trashslots + effect.modifier
				elseif effect.type == "character-logistic-requests" then
					requests = requests or effect.modifier
				end
			end
		end
	end

	force.character_trash_slot_count  = trashslots
	force.character_logistic_requests = requests
end

for _,force in pairs(game.forces) do
	 if force.technologies["enable-logistics-tab"] then
     	   force.technologies["enable-logistics-tab"].researched = true
 	 end
	resetLogisticTechEffects(force) 
end


log("Even Distribution: Migrated to version 1.0.0")
