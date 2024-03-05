local me = {}
-------------------------------------------------------------------------------------
--Enable Recipes if tech researched
-------------------------------------------------------------------------------------
function me.reload_tech_unlock()
	--log("reload_tech_unlock")
	for _, force in pairs(game.forces) do
		for _, tech in pairs(force.technologies) do
			if string.find(tech.name, "^technology-.+-crane$") then
				--log("processing: " .. tech.name)
				local unlock_state = false
				if tech.researched then
					unlock_state = true
				end
				for _, effect in pairs(tech.effects) do
					if effect.type == "unlock-recipe" then
						force.recipes[effect.recipe].enabled = unlock_state
					--log(effect.recipe .. " enabled: " .. tostring(unlock_state))
					end
				end
			end
		end
	end
end
return me
