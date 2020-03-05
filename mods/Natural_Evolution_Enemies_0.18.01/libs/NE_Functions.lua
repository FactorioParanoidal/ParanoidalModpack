-----------------------
--NE Functions--
-----------------------


function NE_Functions.add_immunity(ent_type, immunity, amount)

	 if not ent_type.resistances then ent_type.resistances = {} end
	 table.insert(ent_type.resistances, {type = immunity, percent = amount})

end


--[[	 
function NE_Functions.add_immunity(Raw, immunity, amount)

		local Resist_being_Added = {type = immunity, percent = amount}
		if Raw.resistances == nil then 
			Raw.resistances = {}
			table.insert(Raw.resistances, Resist_being_Added)
		else
			local found = false
			for _, resistance in pairs(Raw.resistances) do
				if resistance.type == Resist_being_Added.type and resistance.percent > Resist_being_Added.percent then
					found = true
					break
				elseif resistance.type == Resist_being_Added.type and resistance.percent < Resist_being_Added.percent then
					found = true
					table.insert(Raw.resistances, Resist_being_Added)
					break
				end
			end
				
			if not found then
				table.insert(Raw.resistances, Resist_being_Added)
			end
				
		end

	 
end
]]

function NE_Functions.add_immunity_only_to_entities_with_res(ent_type, immunity, amount)
	 --- Only add to entities the already has resistances.
	 if ent_type.resistances then 
		local Resist_being_Added = {type = immunity, percent = amount}
		
				local found = false
				for _, resistance in pairs(ent_type.resistances) do
					if resistance.type == Resist_being_Added.type and resistance.percent then
						if resistance.percent < Resist_being_Added.percent then
							resistance.percent = Resist_being_Added.percent
						end
						found = true
					end            
				end
				
				if not found then
					table.insert(ent_type.resistances, Resist_being_Added)
				end
				
	end

end



function NE_Functions.remove_immunity(ent_type, immunity, amount)
	if not ent_type.resistances then ent_type.resistances = {} end
	table.insert(ent_type.resistances, {type = immunity, percent = amount})
end





-- Adds a resistance of a single damage type to an entity
function NE_Functions.Add_Damage_Resists(D_Type, Raw, percent)
	if data.raw["damage-type"][D_Type] ~= nil then
		local Resist_being_Added = {type = D_Type, percent = percent}
		for i,d in pairs(Raw) do
			--- entity had no resistances, so add them.
			if d.resistances == nil then 
				d.resistances = {}
				table.insert(d.resistances, Resist_being_Added)
			else
				local found = false
				for _, resistance in pairs(d.resistances) do
					if resistance.type == Resist_being_Added.type and resistance.percent then
						if resistance.percent < Resist_being_Added.percent then
							resistance.percent = Resist_being_Added.percent
						end
						found = true
					end            
				end
				
				if not found then
					table.insert(d.resistances, Resist_being_Added)
				end
			end
		end
	end
end
	
	
-- Adds a resistance of all damage types to an item type
function NE_Functions.Add_ALL_Damage_Resists(Raw, Percent)
	if Raw ~= nil then	
		for k, v in pairs(data.raw["damage-type"]) do
			NE_Functions.Add_Damage_Resists(v.name, Raw, Percent)
		end
	end
end



-- Adds a resistance of a single damage type to an entity
local function Add_Damage_Resists_to_Units(D_Type, Raw, percent)
	
	if data.raw["damage-type"][D_Type] ~= nil then
		local Resist_being_Added = {type = D_Type, percent = percent}

		if Raw.resistances == nil then 
			Raw.resistances = {}
			table.insert(Raw.resistances, Resist_being_Added)
		else
			local found = false
			
			for _, resistance in pairs(Raw.resistances) do
				if resistance.type == Resist_being_Added.type and resistance.percent then
					if resistance.percent < Resist_being_Added.percent then
						resistance.percent = Resist_being_Added.percent
					end
					found = true
					break
			
				elseif resistance.type == Resist_being_Added.type and resistance.percent < Resist_being_Added.percent then
					found = true
					table.insert(Raw.resistances, Resist_being_Added)
					break
				end
			end
				
			if not found then
				table.insert(Raw.resistances, Resist_being_Added)
			end
				
		end
	
	end

end
	

-- Adds a resistance of ALL damage types to an item type
function NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(Raw, Percent)
	if Raw ~= nil then	
		for k, v in pairs(data.raw["damage-type"]) do
			if v.name == "NE_Conversion" then -- NE Buildings Damage Type
				Add_Damage_Resists_to_Units(v.name, Raw, -5)
			else
				Add_Damage_Resists_to_Units(v.name, Raw, Percent)
			end
		end
	end
end

