if not NE_Enemies then NE_Enemies = {} end
if not NE_Enemies.Settings then NE_Enemies.Settings = {} end

NE_Enemies.Settings.NE_Difficulty = settings.startup["NE_Difficulty"].value


----- List of all Entities --- Thanks for Darkfrei for this code!
local item_types = {}
local item_types_list = {}
local entity_types = {}
local entity_types_list = {}

local function is_value_in_list (value, list)
  for i, v in pairs (list) do
    if value == v then
      return true
    end
  end
  return false
end

for type_name, type_prot in pairs (data.raw) do
  for element_name, element_prot in pairs (type_prot) do
    if element_prot.minable 
    or element_prot.collision_box 
    or element_prot.selection_box 
    then
      if not entity_types[type_name] then
        entity_types[type_name] = {element_name}
      else
        if not is_value_in_list (element_name, entity_types[type_name]) then
          table.insert(entity_types[type_name], element_name)
        end
      end
      
      if not is_value_in_list (type_name, entity_types_list) then
        table.insert(entity_types_list, type_name)
      end
    end
    
    if element_prot.name and element_prot.type == "item" 
    or element_prot.stack_size
    or element_prot.place_result
    or element_prot.place_as_tile
    then
      if not item_types[type_name] then
        item_types[type_name] = {element_name}
      else
        if not is_value_in_list (element_name, item_types[type_name]) then
          table.insert(item_types[type_name], element_name)
        end
      end
      
      if not is_value_in_list (type_name, item_types_list) then
        table.insert(item_types_list, type_name)
      end
    end
  end
end


	
local ent_count = #entity_types_list
for i = 1, ent_count do
		
	--- Add the same amount of "ne_fire" Resistances as the current "fire" Resistances
	for _, ent_type in pairs(data.raw[entity_types_list[i]]) do
			
		if ent_type.type == "unit" then --or ent_type.type == "unit-spawner" then
			
			NE_Functions.add_immunity(ent_type, "ne_fire", 100) -- Units have a 100% Immunity to "ne_fire", this way they don't get damaged by own or other unit attack.
			
		elseif ent_type.resistances then

			local fire, nefire --store resistance subtables
			for _,res in pairs(ent_type.resistances) do
				  if res.type == 'fire' then
					if res.percent then
					  fire = res --has fire and percent, store subtable for later use
					  end
				  elseif res.type == 'ne_fire' then
					nefire = res --has nefire, store for later use
					end
				  end
			if fire then
			  if nefire then 
				if nefire.percent < fire.percent then
					if ent_type.type == "unit-spawner" then
						nefire.percent = 100 --update old nefire
					else
						nefire.percent = fire.percent --update old nefire
					end
					
				  end
			  else
					if ent_type.type == "unit-spawner" then
						table.insert(ent_type.resistances,{type='ne_fire',percent=100}) --add new nefire
					else
						table.insert(ent_type.resistances,{type='ne_fire',percent=fire.percent}) --add new nefire
					end
				
				end
			  end
			
		end
		
	end


	
		
	--- Add or Remove Wall Breaker Resistances
	for _, ent_type in pairs(data.raw[entity_types_list[i]]) do
		
		if ent_type.type == "wall" or ent_type.type == "gate" then
			NE_Functions.remove_immunity(ent_type, "ne_wallbreaker", -25) -- Walls and Gates get Wall Breaker Weakness
		else  -- Only give Wall Breaker Immunity to Items that currently have any Resistances.
			NE_Functions.add_immunity_only_to_entities_with_res(ent_type, "ne_wallbreaker", 100) -- All other entities, that have Resistances, get Wall Breaker Immunity
		end
	end


end



---- Electric poles ges 15% immunitiy to everything.	
--NE_Functions.Add_ALL_Damage_Resists(data.raw["electric-pole"],15)

--- Give new units immunity to damage. Ranges from 1% to 20%.
for i = 1, 20 do
	
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-biter-breeder-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-biter-fire-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-biter-fast-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-biter-wallbreaker-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-biter-tank-" .. i], i * 4) -- 4% to 80% resistance, Laser will be 5% to 100%

	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-spitter-breeder-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-spitter-fire-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-spitter-ulaunch-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-spitter-webshooter-" .. i], i) -- 1% to 20% resistance
	NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit["ne-spitter-mine-" .. i], i) -- 1% to 20% resistance
	
end
	
	
--- Tank Spawner - Yellow, has a high resistance
NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw["unit-spawner"]["ne-spawner-pink"], 20) -- 20% resistance to everything
	
	
	
--- Update Megladon Attack and Resistances
NE_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw["unit"]["ne-biter-megalodon"], 24 + NE_Enemies.Settings.NE_Difficulty) -- 25% resistance to everything
	
data.raw.unit["ne-biter-megalodon"].attack_parameters.ammo_type.action.action_delivery.target_effects = {}
for k, v in pairs(data.raw["damage-type"]) do
	local Damage_type = {type = "damage", damage = { amount = (20 + (NE_Enemies.Settings.NE_Difficulty * 5)), type = k}}
	table.insert(data.raw.unit["ne-biter-megalodon"].attack_parameters.ammo_type.action.action_delivery.target_effects, Damage_type)
end






