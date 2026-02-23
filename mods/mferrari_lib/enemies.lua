

-- fixed for 2.0
function unit_flee_from_enemy(unit, radius)
local enemy = unit.surface.find_nearest_enemy{position=unit.position, max_distance=radius or 10, force=unit.force}
if enemy then 
    local BC = unit
	if unit.object_name=="LuaEntity" then BC = unit.commandable end
    if BC then 
        BC.set_command({type = defines.command.flee,distraction = defines.distraction.none, from=enemy})
        end
	end
end


function unit_attack_target(unit,target,distraction)
    if not distraction then distraction = defines.distraction.by_enemy end
    local BC = unit
	if unit.object_name=="LuaEntity" then BC = unit.commandable end
    if BC then 
        BC.set_command({type = defines.command.attack,distraction = distraction, target=target})
        end
end


function command_add_stay(command)
	command = {type = defines.command.compound, structure_type = defines.compound_command.return_last,
				commands = {command,
				{
					type = defines.command.stop,
					distraction = defines.distraction.none
				},
				}}
end

function unit_go_to_loc(unit,destination,distraction, stay)
    if not distraction then distraction = defines.distraction.by_enemy end
    local BC = unit
	if unit.object_name=="LuaEntity" then BC = unit.commandable end
    if BC then 
        local command = {type = defines.command.go_to_location,
                        pathfind_flags = {use_cache = true, low_priority=false, allow_destroy_friendly_entities=false},
                        distraction = distraction 
                        }
        if destination.x and destination.y then command.destination=destination 
        else command.destination_entity=destination end
        if stay then command_add_stay(command) end
		BC.set_command(command)			
        end
end	


function unit_go_to_entity(unit,destination, stay)
local CM = unit
if unit.object_name=="LuaEntity" then CM = unit.commandable end
local command = {type = defines.command.go_to_location, destination_entity = destination,
				pathfind_flags = {use_cache = false, low_priority=true, allow_destroy_friendly_entities=false},
				distraction = defines.distraction.none, radius=2
				}
if stay then command_add_stay(command) end
CM.set_command(command)			
end	

function unit_follows_player(unit, stay)
local characters = unit.surface.find_entities_filtered{type='character', force=unit.force, position=unit.position, radius=20}
if #characters>0 then
	unit_go_to_entity(unit,characters[1], stay)
end
end



function unit_attack_area(unit,position,radius, distraction) --- unit or group
    local CM = unit
	if unit.object_name=="LuaEntity" then CM = unit.commandable end
    if CM then 
		local command ={
			type = defines.command.attack_area,
			destination = position,
			distraction = distraction or defines.distraction.by_enemy,
			radius = radius or 20
		  }

        CM.set_command(command)
        end
end


function unit_atack_nearest_then_target(unit,target,dista)
local enemy = unit.surface.find_nearest_enemy{position=unit.position, max_distance=dista or 300, force=unit.force}
if enemy and enemy.valid then 
	local command = {
		type = defines.command.compound,
		structure_type = defines.compound_command.return_last,
		commands = {
		  {
			type = defines.command.attack_area,
			distraction = defines.distraction.by_enemy,
			destination = enemy.position,
			radius = 20
		  },
		  {
			type = defines.command.attack,
			target = target,
			distraction = defines.distraction.by_enemy
		  },
		}}
	local CM = unit
	if unit.object_name=="LuaEntity" then CM = unit.commandable end	
	CM.set_command(command)
	else unit_attack_target(unit,target) 
	end
end	



function get_nearby_enemies(unit, radius)
local e = unit.surface.find_nearest_enemy{position=unit.position, max_distance=radius, force=unit.force}
if e then 
	return unit.surface.find_entities_filtered{
		position = unit.position,
		radius = radius,
		type = "unit",
		force = e.force,
	}
else return {}
end
end




function group_set_command(group,position_1,position_2, position_3)
	local compound = defines.command.compound
	local structure = defines.compound_command.return_last
	local go_to = defines.command.attack_area   
	if not position_2 then position_2=position_1 end
	if not position_3 then position_3=position_2 end
		group.set_command(
		  { 
			type = compound,
			structure_type = structure,
			commands =
			{
			{type = go_to, destination = position_1, distraction = defines.distraction.by_anything, radius=50},
			{type = go_to, destination = position_2, distraction = defines.distraction.by_enemy, radius=30},
			{type = go_to, destination = position_3, distraction = defines.distraction.by_enemy, radius=30},
			{type = defines.command.wander, distraction = defines.distraction.by_enemy, radius=30},
			}
		  })
  --group.start_moving()
  end

function unit_wander(unit)
    local BC = unit
	if unit.object_name=="LuaEntity" then BC = unit.commandable end
    if BC then     
        local command = {type = defines.command.wander}
        --unit.set_command(command)
        BC.set_command(command)
        end
end

-- only for wdm ?
function get_random_big_nest(surface,position)
if not position then position={0,0} end
local nests = {"maf-big-spawner","maf_infected_ship"}
if prototypes.entity["tb_infected_ship"] then 
	local aux = GetLocalAux(surface,position)
	if aux and aux >0.65 then table.insert (nests,"tb_infected_ship") end
	end
return nests[math.random(#nests)]
end		


function get_worms_for_evolution(evolution, extra_evo, surface, position)
--check temperature ,aux (toxic)
local temp, aux 
if surface and position then 
	temp = GetLocalTemp(surface,position) 
	aux  = GetLocalAux(surface,position) 
	end

	local function is_valid_worm(name) 
		local add = true
		if string.find(name, "cold") and ((not temp) or (temp>10))  then add=false end
		if string.find(name, "explosive") and ((not temp) or (temp<40))  then add=false end
		if string.find(name, "toxic") and ((not aux) or (aux<0.6)) then add=false end
		if string.find(name, "kr-") or string.find(name, "RTPrimer") or string.find(name, "creative") then add=false end -- krastorio fake worms 
		if not (string.find(name, "worm")) then add=false end	
		return add
		end


if not evolution then evolution = get_evo_here(surface) end
local filter = {{filter = "type",type = "turret"},{filter = "build-base-evolution-requirement", comparison = "≤", value = evolution, mode = "and"}} 
local worms_p = prototypes.get_entity_filtered(filter)
local worms = {}


for name,proto in pairs (worms_p) do 
	if (not string.find(name, "boss")) and (not string.find(name, "mother"))  then 
		if proto.build_base_evolution_requirement ~= nil then
			if is_valid_worm(name) then table.insert(worms,name) end
			end 
		end
	end

local strong_worms = {}
if extra_evo then 
	local filter = {{filter = "type",type = "turret"},{filter = "build-base-evolution-requirement", comparison = "≤", value = evolution+extra_evo, mode = "and"},
		{filter = "build-base-evolution-requirement", comparison = "≥", value = evolution, mode = "and"}}
	local worms_p = prototypes.get_entity_filtered(filter)
	for name,proto in pairs (worms_p) do 
		if not string.find(name, "boss") then 
		if proto.build_base_evolution_requirement ~= nil then 
			if is_valid_worm(name) then table.insert(strong_worms,name) end
			end 
		end
		end
	end
return worms,strong_worms
end		


function CallWormAttack(surface,position,how_many,min_distance,max_distance,force,not_on_tiles)
if not max_distance then max_distance = min_distance + 5 end
local worms = get_worms_for_evolution(get_evo_here(surface,force),nil, surface, position)
--how_many = how_many + storage.settings.difficulty_level - 1
for w=1,how_many do
	local worm = worms[math.random(#worms)]
		for t=1,10 do
			local x = position.x + math.random(min_distance,max_distance)* RandomNegPos()
			local y = position.y + math.random(min_distance,max_distance)* RandomNegPos()
			local pos = surface.find_non_colliding_position(worm, {x=x,y=y}, 6, 2)
			-- avoid concrete
			if pos then 
				if not_on_tiles then 
					local tiles = surface.find_tiles_filtered{position=pos, radius=3, name=not_on_tiles, limit=1}
					if #tiles>0 then break end
					end
				create_remnants_particles (surface, math.random(20,40) , pos) 
				local wo = surface.create_entity{name=worm,force=force,position=pos}
				break
				end
		end
	end
end




function Call_Underground_Attack(surface,position,how_many,min_distance,max_distance,force,not_on_tiles)
if not max_distance then max_distance = min_distance + 5 end
for s=1,how_many do
	local name = "wdm-hole-spawner"
	for t=1,10 do
		local x = position.x + math.random(min_distance,max_distance)* RandomNegPos()
		local y = position.y + math.random(min_distance,max_distance)* RandomNegPos()
		local pos = surface.find_non_colliding_position(name, {x=x,y=y}, 6, 2)
		-- avoid concrete
		if pos then 
			if not_on_tiles then 
				local tiles = surface.find_tiles_filtered{position=pos, radius=3, name=not_on_tiles, limit=1}
				if #tiles>0 then break end
				end
			create_remnants_particles (surface, math.random(20,40) , pos) 
			local wo = surface.create_entity{name=name,force=force,position=pos}
			break
			end
		end
	end
end



function create_tatoo_for_unit(unit, color)
if unit and unit.valid then
if not color then color=colors.red end
local tatoo = rendering.draw_circle
	{
	color = color,
	radius = 0.18,
	filled = true,
	target = unit,
	surface = unit.surface,
	}

return tatoo
end
end



--## Get unit names for an evolution   @spawners = table list with spawner names or a string 
function get_units_for_evolution(evolution,extra_evo, spawners)
	local excluded_part_names = {"mother","boss","protomolecule","human"}
	local function may_add(name)
		for _,n in pairs (excluded_part_names) do
			if string.find(name, n) then return false end
			end
		return true	
		end
if not evolution then evolution = game.forces.enemy.get_evolution_factor() end
if type(spawners)=='string' then spawners = {spawners} end
if not spawners then -- if not passed, get all spawners
	spawners = {}
	local filter = {{filter = "type", type = "unit-spawner"}}
	for name,_ in pairs(prototypes.get_entity_filtered(filter)) do table.insert(spawners,name) end
	end
local unit_names = {}
local strong_units = {} -- for extra strong ones
	for _,name in pairs (spawners) do
		if may_add(name) then 
			local proto=prototypes.entity[name]
			for Y,RU in pairs (proto.result_units) do
				local uname = RU.unit
				local SP = RU['spawn_points']
				if not in_list(unit_names,uname) and prototypes.entity[uname] and prototypes.entity[uname].type=='unit' then 
					local emin = SP[1]['evolution_factor']
					local emax = SP[#SP]['evolution_factor']
					if SP[#SP]['weight']>0 then emax=2 end	
					if evolution>=emin and evolution<emax then
						if may_add(uname) then add_list(unit_names, uname) end
						end
					if extra_evo and evolution+extra_evo>=emin and evolution+extra_evo<emax then
						if may_add(uname) then add_list(strong_units, uname) end
						end
					end
				end
			end
		end
return unit_names,strong_units
end	





function CallFrenzyAttack(surface,target,limit,multiplier)
	--disable this bcause of space age
    --if surface.map_gen_settings.autoplace_controls and surface.map_gen_settings.autoplace_controls["enemy-base"] 
      --and surface.map_gen_settings.autoplace_controls["enemy-base"].size>0 then
local diff = 1 --= storage.settings.difficulty_level or
    local position
    if target.type and target.valid 
        then 
        position=target.position
        else
        position = target
        end
    
    local Min = 10
    local Max = 300
    local Dist = 1500
    
    local spawn = surface.find_entities_filtered({type = "unit-spawner",limit=1,position=position,radius=Dist})
    if #spawn>0 then
    local force = spawn[1].force
    
    local aliens = Max * get_evo_here(surface,force) 
    aliens = math.floor(aliens + (aliens * (diff-1))/2)
    
    if aliens < Min then aliens=Min end
    if limit and aliens>limit then aliens=limit end
    if multiplier then aliens=math.floor(aliens * multiplier) end 
    
        if target.type and target.valid then 
            local sent = surface.set_multi_command({
                command = {type=defines.command.attack, target=target, distraction = defines.distraction.by_anything },
                unit_count = aliens,
                force = force,
                unit_search_distance = Dist,
            })
            else
            local sent = surface.set_multi_command({
                command = {type=defines.command.attack_area, destination=position, radius=80 },  --, distraction = defines.distraction.by_anything
                unit_count = aliens,
                force = force,
                unit_search_distance = Dist,
            })
            end
        end
   -- end
    end


function get_evolut_1_to_10(evolution)
	return math.min(10, math.max(math.floor((evolution+0.02)*10),1))
	end

function get_evo_here(surface,force)
force=force or game.forces.enemy
if surface and surface.valid then return force.get_evolution_factor(surface) 
	else return force.get_evolution_factor() end
end


function raise_evo_here(surface,force,raise)
force=force or game.forces.enemy
if surface and surface.valid then 
	local evo = force.get_evolution_factor(surface)
	force.set_evolution_factor(math.min(1,evo+raise), surface)
	else
	local evo = force.get_evolution_factor() 
	force.set_evolution_factor(math.min(1,evo+raise))
	end
end


function get_random_lesser_boss(evolution,surface,no_spitter)
if not evolution then evolution = get_evo_here(surface) end
		local list = {'maf-boss-biter-','maf-boss-acid-spitter-'}
		if script.active_mods['ArmouredBiters'] then table.insert(list,'maf-boss-armoured-biter-') end
		
		if script.active_mods['Cold_biters'] then 
			if (not surface) or #surface.find_entities_filtered{name='cb-cold-spawner',limit=1}>0 then 
			table.insert(list,'maf-boss-frost-biter-')
			if not no_spitter then table.insert(list,'maf-boss-frost-spitter-') end
			end	end
		if script.active_mods['Explosive_biters'] then 
			if (not surface) or #surface.find_entities_filtered{name='explosive-biter-spawner',limit=1}>0 then 
			table.insert(list,'maf-boss-explosive-biter-')
			if not no_spitter then table.insert(list,'maf-boss-explosive-spitter-') end
			end	end
		
		if script.active_mods['Toxic_biters'] then 
			if (not surface) or #surface.find_entities_filtered{name='toxic-biter-spawner',limit=1}>0 then 
			table.insert(list,'maf-boss-toxic-biter-')
			if not no_spitter then table.insert(list,'maf-boss-toxic-spitter-')	end
			end	end
		
		if script.active_mods['Arachnids_enemy'] then 
			if (not surface) or #surface.find_entities_filtered{name='arachnid-spawner-unitspawner',limit=1}>0 then 
			table.insert(list,'maf-boss-arachnid-biter-')
			end	end

		if (not no_spitter) and prototypes.entity["cyborg_strafer-boss-1"] then 
			table.insert(list,"cyborg_strafer-boss-")
			end	

		if (not no_spitter) and script.active_mods['Electric_flying_enemies'] then 
			table.insert(list,"walking-electric-unit-boss-")
			end

		local n=math.min(10, math.max(math.ceil(evolution*10),1))
		return list[math.random(#list)] ..n
	end



function BOSS_spawn_here(surface,position,evolution,force,ignore_surface_check,no_spitter)
	local surf_check = surface
	if ignore_surface_check then surf_check=nil end
	local name = get_random_lesser_boss(evolution,surf_check,no_spitter)
	local p = surface.find_non_colliding_position(name, position, 20, 2)
	if p then 
		local boss = surface.create_entity{name = name,position=p,force=force}
		boss.ai_settings.allow_destroy_when_commands_fail=false 
		return boss
		end
	end

	
function get_random_boss_nest(surface,position)
	if not position then position={0,0} end
	local bosses = {"maf-big-boss-spawner", "maf_infected_ship"}
	if script.active_mods["ZombieHordeFaction"] then table.insert(bosses,"boss-zombie-spawner") end
	if prototypes.entity["tb_infected_ship_boss"] then table.insert (bosses,"tb_infected_ship_boss") -- from toxic biters mod
		--local aux = GetLocalAux(surface,position)
		--if aux and aux >0.65 then  end
		end
	return bosses[math.random(#bosses)]
	end		








--------------------------------------------------------------------------------------
-- HUMIES
function get_human_soldier_list(base_name,evolution,add_explosive)
if not evolution then evolution = game.forces.enemy.get_evolution_factor() end
local list = { 'machine_gunner','laser','electric'}
if evolution>0.2 then 
	table.insert(list,'sniper')  
	else
	table.insert(list,'melee')
	table.insert(list,'pistol_gunner')
	end
if evolution>0.35 then table.insert(list,'grenade') table.insert(list,'flamethrower') end
if evolution>0.60 then table.insert(list,'rocket') end
if add_explosive and evolution>0.75 then table.insert(list,'erocket') table.insert(list,'cluster_grenade') end

local n=math.min(10, math.max(math.ceil(evolution*10),1))
for x=1,#list do list[x]= base_name ..'_'.. list[x]..'_'..n end
return list
end


function get_random_human_soldier(base_name, evolution, add_explosive)
local list = get_human_soldier_list(base_name, evolution, add_explosive)
return list[math.random(#list)]
end




function create_soldiers_group(base_name,evolution,surface,spawn,pcount, attack1, attack2,attack3)
if not evolution then evolution = game.forces.enemy.get_evolution_factor() end
local qt = math.min(10, math.max(2,math.ceil(evolution * 10 + math.random(math.ceil(pcount/2)))))
local group 
local one_humie 
for x=1, qt do
	local humie = get_random_human_soldier(base_name, evolution)
	local position = surface.find_non_colliding_position(humie, spawn, 100, 1)
	if position then
		if not group then group = surface.create_unit_group{position = position, force = game.forces.enemy} end
		one_humie = surface.create_entity{name=humie, position= position, force= game.forces.enemy}
		group.add_member(one_humie)
		table.insert (storage.other_enemies,one_humie )
		end
	end
group_set_command(group,attack1,attack2,attack3)
return group, one_humie
end



function get_random_boss_human_soldier(evolution, add_explosive)
	if not evolution then evolution = game.forces.enemy.evolution_factor end
	local list = { 'wdm_pirate_boss_machine_gunner',
	'wdm_pirate_boss_laser',
	'wdm_pirate_boss_electric'}
	if evolution>0.94 then table.insert(list,'wdm_pirate_boss_sniper') table.insert(list,'wdm_pirate_boss_flamethrower')  end
	if evolution>0.96 then 
		table.insert(list,'wdm_pirate_boss_rocket') 
		table.insert(list,'wdm_pirate_boss_grenade')
		end
	if add_explosive and evolution>0.98 then 
		table.insert(list,'wdm_pirate_boss_erocket')
		table.insert(list,'wdm_pirate_boss_cluster_grenade') 
		table.insert(list,'wdm_pirate_boss_cannon_explosive') 
		end
	local n=math.min(10, math.max(math.ceil((evolution - 0.9) *100),1))
	return list[math.random(#list)] ..'_'.. get_evolut_1_to_10(evolution)
	end
	


function RemoveAliensInArea(surface, area)
    for _, entity in pairs(surface.find_entities_filtered{area = area, type={'unit-spawner','unit','turret'}}) do
		if string.sub(entity.force.name,1,5)=='enemy' then entity.destroy() end
    end
end


-- returns 1 to 10 based on game evolution for that force on nauvis
function get_evo_progress_10(force)
force = force or game.forces.enemy
local evolution = force.get_evolution_factor()
local p=math.min(10, math.max(math.ceil(evolution*10),1))
return p
end





function mf_create_special_defense_things_on_area(turret_prefix, surface,area,quantity,force,extras,only_this, extra_evo)
force =  force or game.forces.enemy
local evo=get_evo_here(surface,force) + (extra_evo or 0)

local tnames = {"_gun-turret", "_laser-turret", "_tesla-turret", "_rocket-turret"} --railgun ?
local things = {"land-mine"}

local ammo = {[1]="firearm-magazine",[2]="piercing-rounds-magazine",[3]="artillery-shell"}
if prototypes.item["rifle-magazine"] then ammo[1] = "rifle-magazine" end
if prototypes.item["armor-piercing-rifle-magazine"] then ammo[2] = "armor-piercing-rifle-magazine" end

for t=1,#tnames+1 do
	if t*(1/(#tnames+1))<=evo then table.insert(things,turret_prefix .. tnames[t] ) end
	end

if extras then concat_lists(things, extras) end
if only_this then things=only_this end

local ents = {}
for q=1,quantity do
	local name = things[math.random(#things)]
	local pos
	for x=1,10 do 
		local p=get_randon_pos_in_area(area)
		pos = surface.find_non_colliding_position(name, p, 3, 3)
		if pos then break end 
		end
	if pos then 
		local thing = surface.create_entity{name = name, position =pos,force = force, spawn_decorations=true}
		table.insert(ents,thing)
		if string.find(name, "gun-turret",nil,true)  then
			local bullet = ammo[1]
			if evo>0.3 then bullet = ammo[2] end
			thing.insert({name=bullet})
			end
		--if string.find(name, "flamethrower") or string.find(name, "artillery") then 
		--	table.insert(storage.recharge_turrets, thing)
		--	end	
		end
	end
return ents
end

