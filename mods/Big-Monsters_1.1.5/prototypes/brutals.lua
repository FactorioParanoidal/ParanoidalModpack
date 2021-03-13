local Enemies = table.deepcopy(data.raw.unit)
local NewE
local TabNew = {}

for k,Proto in pairs (Enemies) do
  if (string.find(Proto.name, "spitter") or string.find(Proto.name, "biter") ) and
	(not (string.find(Proto.name, "boss") or string.find(Proto.name, "brutal") )) then
	
	Proto.hide_resistances = false
	NewE = table.deepcopy(Proto)
  
	if NewE.attack_parameters and NewE.attack_parameters.ammo_type and NewE.attack_parameters.ammo_type.action and
		NewE.attack_parameters.ammo_type.action.action_delivery and
		NewE.attack_parameters.ammo_type.action.action_delivery.target_effects and 
		NewE.attack_parameters.ammo_type.action.action_delivery.target_effects.damage then
		
		NewE.name = "brutal-" .. Proto.name
		NewE.movement_speed = NewE.movement_speed * 1.30
		local h = NewE.max_health * 20
		if h>25000 then h=25000 end	
		NewE.max_health = h
		NewE.localised_name = {"",'Brutal ',{'entity-name.'..Proto.name}}
		if (string.find(Proto.name, "biter")) then
			local dmg = NewE.attack_parameters.ammo_type.action.action_delivery.target_effects.damage.amount
			dmg=math.floor(dmg*2)
			NewE.attack_parameters.ammo_type = make_unit_melee_ammo_type(dmg)
			end
		table.insert (TabNew,NewE)
	
		end
	end
end


for k=1,#TabNew do
data:extend{TabNew[k]}
if (string.find(TabNew[k].name, "mutant1")) then
	JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[TabNew[k].name], 6)  -- % all resists
	else
	JB_Functions.Add_ALL_Damage_Resists_to_Unit_type(data.raw.unit[TabNew[k].name], 9,'laser')  -- % all resists
	end
end
