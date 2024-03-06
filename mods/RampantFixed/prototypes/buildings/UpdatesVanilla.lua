local vanillaUpdates = {}

function vanillaUpdates.addWallResistance()
    local walls = data.raw["wall"]

    for _,wall in pairs(walls) do
        local acidIndex
        local poisonIndex
        local explosionIndex
		
		if wall.resistances then
			for i = 1, #wall.resistances do
				local resistance = wall.resistances[i]
				if resistance.type == "acid" then
					acidIndex = i + 0
				elseif resistance.type == "poison" then	
					poisonIndex = i + 0
				elseif resistance.type == "explosion" then	
					explosionIndex = i + 0
				end
			end
			if acidIndex and (wall.resistances[acidIndex].percent > 0) then
				local resistance = wall.resistances[acidIndex]
				if (resistance.percent < 60) then
					resistance.percent = 60
				end
				if not poisonIndex then
					wall.resistances[#wall.resistances+1] = {type="poison",percent=75}
				elseif wall.resistances[poisonIndex].percent < 75 then
					wall.resistances[poisonIndex].percent = 75
				end
				if not explosionIndex then
					wall.resistances[#wall.resistances+1] = {type="explosion",decrease=40}
				elseif (wall.resistances[explosionIndex].decrease or 0) < 40 then
					wall.resistances[explosionIndex].decrease = 40
				end				
			end
		end	
    end

    walls = data.raw["gate"]
    for _,wall in pairs(walls) do
        local acidIndex
        local poisonIndex
        local explosionIndex
		if wall.resistances then
			for i = 1, #wall.resistances do
				local resistance = wall.resistances[i]
				if resistance.type == "acid" then
					acidIndex = i + 0
				elseif resistance.type == "poison" then	
					poisonIndex = i + 0
				elseif resistance.type == "explosion" then	
					explosionIndex = i + 0
				end
			end
			if acidIndex and (wall.resistances[acidIndex].percent > 0) then
				local resistance = wall.resistances[acidIndex]
				if (resistance.percent < 60) then
					resistance.percent = 60
				end
				if not poisonIndex then
					wall.resistances[#wall.resistances+1] = {type="poison",percent=75}
				elseif wall.resistances[poisonIndex].percent < 75 then
					wall.resistances[poisonIndex].percent = 75
				end
				if not explosionIndex then
					wall.resistances[#wall.resistances+1] = {type="explosion",decrease=40}
				elseif (wall.resistances[explosionIndex].decrease or 0) < 40 then
					wall.resistances[explosionIndex].decrease = 40
				end				
			end
		end	
    end
end

return vanillaUpdates
