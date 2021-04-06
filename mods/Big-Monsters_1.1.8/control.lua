util = require("util")
colors = require("colors")
require("utils")
require "cameras"
require "particles"
require "stdlib/area/chunk"
require "stdlib/area/area"


function ReadRunTimeSettings(event)
global.chances = global.chances or {}  -- in priority order of danger
global.chances.volcano    = {min_evo=settings.global["bm-volcano-min_evo"].value  ,chance=settings.global["bm-volcano-chance"].value}
global.chances.spidertron = {min_evo=settings.global["bm-spidertron-min_evo"].value  , chance=settings.global["bm-spidertron-chance"].value}
global.chances.biterzilla = {min_evo=settings.global["bm-biterzilla-min_evo"].value  , chance=settings.global["bm-biterzilla-chance"].value}
global.chances.worms      = {min_evo=settings.global["bm-worms-min_evo"].value  ,chance=settings.global["bm-worms-chance"].value}
global.chances.brutals    = {min_evo=settings.global["bm-brutals-min_evo"].value  , chance=settings.global["bm-brutals-chance"].value}
global.chances.soldiers   = {min_evo=settings.global["bm-soldiers-min_evo"].value  ,chance=settings.global["bm-soldiers-chance"].value}
global.chances.invasion   = {min_evo=settings.global["bm-invasion-min_evo"].value  , chance=settings.global["bm-invasion-chance"].value}
global.chances.swarm      = {min_evo=0,   chance=settings.global["bm-swarm-chance"].value}

global.enable_silo_attack = settings.global["bm-enable-silo-attack"].value
global.show_cameras = settings.global["bm-show-cameras"].value
global.show_alerts = settings.global["bm-show-alerts"].value
global.days = settings.global["bm-event-days"].value
global.allow_nuker = settings.global["bm-allow-nuker"].value
global.difficulty_level = settings.global["bm-difficulty-level"].value
global.spidertron_nuke = settings.global["bm-spidertron-nuke"].value
global.tree_events_chance = settings.global["bm-tree-events-chance"].value/100
end
script.on_event(defines.events.on_runtime_mod_setting_changed, ReadRunTimeSettings)


function setup_mod_vars()
global.player_forces    = global.player_forces or {'player'}
global.surfaces         = global.surfaces or {'nauvis'}
global.bm_volcano       = global.bm_volcano or {}
global.biterzillas      = global.biterzillas or {}
global.invasions        = global.invasions or {}
global.rocket_silos     = global.rocket_silos or {}
global.other_enemies    = global.other_enemies or {}


ReadRunTimeSettings()
global.next_event       = global.next_event or (game.tick + (global.days * 7 * 60 * 60))
global.next_silo_event  = global.next_silo_event or (game.tick + (global.days * 4 * 60 * 60))
end

function on_init()
cam_on_init()
setup_mod_vars()
end
script.on_init(on_init)

function on_configuration_changed()
cam_on_init()
setup_mod_vars()
end
script.on_configuration_changed(on_configuration_changed)

-- camera events
local function on_gui_click(event)
cam_on_gui_click(event)
end
script.on_event(defines.events.on_gui_click, on_gui_click)

local function on_tick(event)
cam_on_tick(event)
end
script.on_event(defines.events.on_tick, on_tick )

------------------------------------------------------------------------------------------


function pick_event(excludes)
local the_event
if not excludes then excludes={} end
for event, chances in pairs (global.chances) do
	if not in_list(excludes,event) then 
    if game.forces.enemy.evolution_factor >= chances.min_evo and math.random(100) <= chances.chance then 
		the_event = event
		break
		end
		end
	end
return the_event
end

--the_event = biterzilla,soldiers,worms,volcano,invasion,swarm
function CreateNewEvent(the_event,surfacename, forcename)

local sufaces_tab = table.deepcopy(global.surfaces)
if surfacename then add_list(sufaces_tab, surfacename) end

for s=1,#sufaces_tab do
local surface = game.surfaces[sufaces_tab[s]]
if not the_event then the_event=pick_event() end

for p=1,#global.player_forces do
	local pforce = game.forces[global.player_forces[p]]
	if surface and the_event and pforce and (not surfacename or surface.name==surfacename) and (not forcename or pforce.name==forcename) then 
		local player_spawn = pforce.get_spawn_position(surface)
		local pcount = #pforce.connected_players 
	    
		
		if pcount>0 then 
			local target  
			
			if the_event=='swarm' then 
					local last_building = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					CallFrenzyAttack(surface,last_building)
					if global.show_alerts then 
						pforce.print({"bm-txt-alert"},colors.lightred)
						pforce.print({"bm-txt-swarm"},colors.lightred)
						pforce.play_sound{path='tc_sound_alarm_1'}
						end
						
				elseif the_event=='invasion' then 
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					create_invasion(surface,target,pcount)
					if global.show_alerts then 
						pforce.print({"bm-txt-alert"},colors.lightred)
						pforce.print({"bm-txt-invasion"},colors.lightred)
						pforce.play_sound{path='tc_sound_alarm_1'}
						end	
					if global.show_cameras then CreateCameraForForce(pforce,target,surface,nil,nil,120,0.15) end
					
					
				elseif the_event=='volcano' then
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					local volcano = create_volcano(surface, target, pcount)
					if volcano then  
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-volcano"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,volcano,surface,nil,nil,120,0.15) end
						end

				
				elseif the_event=='worms' then
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					local bigworm = create_bigworm(surface,target,pcount)
					if bigworm then  
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-worm"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,bigworm,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='soldiers' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						local group, humie = create_soldiers_group(surface,spawn,pcount,attack1, attack2, player_spawn)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-human_soldiers"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,humie,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='brutals' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						local group, brutal = create_brutals_group(surface,spawn,pcount,attack1, attack2, player_spawn)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-brutals"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,brutal,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='biterzilla' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						local group, zilla = create_biterzilla(surface,spawn,pcount,attack1, attack2, player_spawn)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-biterzilla"},colors.lightred)
							pforce.play_sound{path='tc_sound_siren'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,zilla,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='spidertron' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						local spider = create_spidertron(surface,spawn,pcount)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-biterzilla"},colors.lightred)
							pforce.play_sound{path='tc_sound_siren'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,spider,surface,nil,nil,120,0.15) end
						end


				end
			
			end --pcount>0

		end --the_event
	end -- p

end
end



function Create_Position_Event(the_event, surface, position, pforce)
local pcount = #pforce.connected_players  
			
			if the_event=='swarm' then 
					CallFrenzyAttack(surface,position)
					if global.show_alerts then 
						pforce.print({"bm-txt-alert"},colors.lightred)
						pforce.print({"bm-txt-swarm"},colors.lightred)
						pforce.play_sound{path='tc_sound_alarm_1'}
						end
						
				elseif the_event=='invasion' then 
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 60, 1)
					if target then 
						create_invasion(surface,target,pcount)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-invasion"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_1'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,target,surface,nil,nil,120,0.15) end
						end
					
					
				elseif the_event=='volcano' then
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 50, 1)
					if target then 
						local volcano = create_volcano(surface, target, pcount)
						if volcano then  
							if global.show_alerts then 
								pforce.print({"bm-txt-alert"},colors.lightred)
								pforce.print({"bm-txt-volcano"},colors.lightred)
								pforce.play_sound{path='tc_sound_alarm_2'}
								end	
							if global.show_cameras then CreateCameraForForce(pforce,volcano,surface,nil,nil,120,0.15) end
							end
						end

				
				elseif the_event=='worms' then
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 50, 1)
					if target then 
						local bigworm = create_bigworm(surface,target,pcount)
						if bigworm then  
							if global.show_alerts then 
								pforce.print({"bm-txt-alert"},colors.lightred)
								pforce.print({"bm-txt-worm"},colors.lightred)
								pforce.play_sound{path='tc_sound_alarm_2'}
								end	
							if global.show_cameras then CreateCameraForForce(pforce,bigworm,surface,nil,nil,120,0.15) end
							end
						end


				elseif the_event=='soldiers' then
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local group, humie = create_soldiers_group(surface,spawn,pcount,position)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-human_soldiers"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,humie,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='brutals' then
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local group, brutal = create_brutals_group(surface,spawn,pcount,position)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-brutals"},colors.lightred)
							pforce.play_sound{path='tc_sound_alarm_2'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,brutal,surface,nil,nil,120,0.15) end
						end

				elseif the_event=='biterzilla' then
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local group, zilla = create_biterzilla(surface,spawn,pcount,position)
						if global.show_alerts then 
							pforce.print({"bm-txt-alert"},colors.lightred)
							pforce.print({"bm-txt-biterzilla"},colors.lightred)
							pforce.play_sound{path='tc_sound_siren'}
							end	
						if global.show_cameras then CreateCameraForForce(pforce,zilla,surface,nil,nil,120,0.15) end
						end

				end

end 

function Create_Silo_Attack(the_event)
if not the_event then the_event=pick_event() end
if the_event then 
for s=#global.rocket_silos,1,-1 do
	local silo=global.rocket_silos[s]
	if not (silo and silo.valid) then table.remove(global.rocket_silos,s)
		else

		local pforce = silo.force
		local pcount = #pforce.connected_players 
		local surface = silo.surface
		
		if pcount>0 then Create_Position_Event(the_event, surface, silo.position, pforce) end
		end
	end
end
end



script.on_nth_tick(60*60, function (event)
if global.next_event<game.tick and global.days>0 then 
	CreateNewEvent()
	global.next_event = game.tick + (global.days * (7 + math.random(-2,2)) * 60 * 60)
	end

if global.next_silo_event < game.tick and global.enable_silo_attack then 
	Create_Silo_Attack()
	global.next_silo_event = game.tick + (global.days * (7 + math.random(-4,-2)) * 60 * 60)
	end
end)








function FindTeamAttackCorner(surface, force, initial_position, chunk_distance)
local directionVec=GetRandomVector()
if not chunk_distance then chunk_distance=4 end
local enemy_spawn
local nothing = 0
local chunkPos = Chunk.from_position(initial_position)  --{x=0,y=0}  initial_position
local player_chunks = {chunkPos}
local last_building = chunkPos
    -- Keep checking chunks in the direction of the vector
    while(not enemy_spawn) do
		chunkPos.x = chunkPos.x + directionVec.x
        chunkPos.y = chunkPos.y + directionVec.y
        -- Set some absolute limits.
        if ((math.abs(chunkPos.x) > 2000) or (math.abs(chunkPos.y) > 2000)) then break
        
        elseif (surface.is_chunk_generated(chunkPos)) then
			local area = Chunk.to_area(chunkPos) 
			local builds = surface.find_entities_filtered{force=force,area=area,limit=1}
			if #builds>0 then 
				last_building = table.deepcopy(chunkPos)
				table.insert (player_chunks,table.deepcopy(chunkPos))
				else
				nothing = nothing + 1 
				if nothing >= chunk_distance then enemy_spawn = chunkPos end 
				end
			
        -- Found an ungenerated area
        else break end
		end

last_building = {x= last_building.x*32+math.random(31), y= last_building.y*32+math.random(31)}
if enemy_spawn then 
	enemy_spawn = {x= enemy_spawn.x*32+math.random(31), y= enemy_spawn.y*32+math.random(31)}
	enemy_spawn = surface.find_non_colliding_position('rocket-silo', enemy_spawn, 100, 1)
	end

return last_building, player_chunks, enemy_spawn
end




function group_set_command(group,position_1,position_2, position_3)
  local def = defines
  local compound = def.command.compound
  local structure = def.compound_command.return_last
  local go_to = def.command.attack_area   
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



--------------------------------------------------------------------------------------
function create_soldiers_group(surface,spawn,pcount, attack1, attack2,attack3)
local qt = math.min(10, math.max(2,math.ceil(game.forces.enemy.evolution_factor * 10 + math.random(math.ceil(pcount/2)))))  + (global.difficulty_level-1) * 12
local group 
local one_humie 
for x=1, qt do
	local humie = get_random_human_soldier()
	local position = surface.find_non_colliding_position(humie, spawn, 100, 1)
	if position then
		if not group then group = surface.create_unit_group{position = position, force = game.forces.enemy} end
		one_humie = surface.create_entity{name=humie, position= position, force= game.forces.enemy}
		if one_humie and one_humie.valid then group.add_member(one_humie) table.insert (global.other_enemies,one_humie ) end
		end
	end
	
if game.forces.enemy.evolution_factor>0.91 and math.random(2)==1 then 
	local humie = get_random_boss_human_soldier(0) 
	local position = surface.find_non_colliding_position(humie, spawn, 100, 1)
	if not group then group = surface.create_unit_group{position = position, force = game.forces.enemy} end
	one_humie = surface.create_entity{name=humie, position=position, force = game.forces.enemy}
	if one_humie and one_humie.valid then group.add_member(one_humie) table.insert(global.other_enemies,one_humie) end
	end
	
group_set_command(group,attack1,attack2,attack3)
return group, one_humie
end

function create_invasion(surface,position,pcount)
local qt = math.min(25, math.max(1,math.ceil(game.forces.enemy.evolution_factor * 20 + math.random(math.ceil(pcount/2))))) + global.difficulty_level - 1
table.insert (global.invasions, {name="bm-spawner", surface=surface, position=position, quant=qt})
if game.forces.enemy.evolution_factor>0.8 then 
	if math.random(1,2)==1 then CallWormAttack(surface,position,math.ceil((qt+ global.difficulty_level )/2),0,25) end 
	end
end


function get_random_human_soldier(evolution)
if not evolution then evolution = game.forces.enemy.evolution_factor end
local list = { 'tc_fake_human_machine_gunner',
'tc_fake_human_laser',
'tc_fake_human_electric'}
if evolution>0.17 then 
	table.insert(list,'tc_fake_human_sniper')  
	else
	table.insert(list,'tc_fake_human_melee')
	table.insert(list,'tc_fake_human_pistol_gunner')
	end
if evolution>0.3 then table.insert(list,'tc_fake_human_grenade') end
if evolution>0.60 then table.insert(list,'tc_fake_human_rocket') end
if evolution>0.75 then table.insert(list,'tc_fake_human_erocket') table.insert(list,'tc_fake_human_cluster_grenade') end
if global.allow_nuker and evolution>0.96 then table.insert(list,'tc_fake_human_nuke_rocket') end

local n=math.min(10, math.max(math.ceil(evolution*10),1))
return list[math.random(#list)] ..'_'..n
end


function get_random_boss_human_soldier(evolution)
if not evolution then evolution = game.forces.enemy.evolution_factor end
local list = { 'tc_fake_human_boss_machine_gunner',
'tc_fake_human_boss_laser',
'tc_fake_human_boss_electric'}
if evolution>0.94 then table.insert(list,'tc_fake_human_boss_sniper') end
if evolution>0.96 then 
	table.insert(list,'tc_fake_human_boss_rocket') 
	table.insert(list,'tc_fake_human_boss_grenade')
	end
if evolution>0.98 then 
	table.insert(list,'tc_fake_human_boss_erocket')
	table.insert(list,'tc_fake_human_boss_cluster_grenade') 
	end
local n=math.min(10, math.max(math.ceil((evolution - 0.9) *100),1))
return list[math.random(#list)] ..'_'..n
end



function get_brutals_for_evolution(evolution,extra_evo)
local brutals = {}
local biters = get_units_for_evolution(evolution,extra_evo)
for b=1,#biters do
	local brut = 'brutal-'..biters[b]
	if game.entity_prototypes[brut] then 
		table.insert(brutals,brut)
		end
	end
return brutals
end

function create_brutals_group(surface,spawn,pcount, attack1, attack2,attack3)
local qt = math.min(10, math.max(2,math.ceil(game.forces.enemy.evolution_factor * 10 + math.random(math.ceil(pcount/2))))) + (global.difficulty_level-1) * 10
local group 
local one_brutal 
local brutals = get_brutals_for_evolution(nil,0.1)
for x=1, qt do
	local brutal = brutals[math.random(#brutals)]
	local position = surface.find_non_colliding_position(brutal, spawn, 200, 1)
	if position then
		if not group then 
			group = surface.create_unit_group{position = position, force = game.forces.enemy} 
			surface.create_entity{name="bm-large-tunnel", position=position, force = game.forces.neutral}
			create_remnants_particles (surface, math.random(30,50) , position) 
			end
		one_brutal = surface.create_entity{name=brutal, position= position, force= game.forces.enemy}
		create_tatoo_for_unit(one_brutal) 
		group.add_member(one_brutal)
		table.insert (global.other_enemies,one_brutal )
		end
	end
group_set_command(group,attack1,attack2,attack3)
return group, one_brutal
end


function get_random_lesser_boss(evolution)
if not evolution then evolution = game.forces.enemy.evolution_factor end
local list = {'maf-boss-biter-','maf-boss-acid-spitter-'}
if game.active_mods['ArmouredBiters'] then table.insert(list,'maf-boss-armoured-biter-') end
local n=math.min(10, math.max(math.ceil(evolution*10),1))
return list[math.random(#list)] ..n
end



function CallFrenzyAttack(surface,target,limit,multiplier)
if surface.map_gen_settings.autoplace_controls and surface.map_gen_settings.autoplace_controls["enemy-base"] 
   and surface.map_gen_settings.autoplace_controls["enemy-base"].size>0 then

local position
if target.type and target.valid 
	then 
	position=target.position
	else
	position = target
	end

local Min = global.difficulty_level * 10
local Max = 270 + global.difficulty_level * 30
local Dist = 1500

local spawn = surface.find_entities_filtered({type = "unit-spawner",limit=1,position=position,radius=Dist})
if #spawn>0 then
local force = spawn[1].force


local aliens = Max * force.evolution_factor
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
			command = {type=defines.command.attack_area, destination=position, radius=50, distraction = defines.distraction.by_anything },
			unit_count = aliens,
			force = force,
			unit_search_distance = Dist,
		})
		end
	end
end
end



function CallWormAttack(surface,position,how_many,min_distance,max_distance,force)
local worms = get_worms_for_evolution()
for w=1,how_many do
	local worm = worms[math.random(#worms)]
		for t=1,10 do
			local x = position.x + math.random(min_distance,max_distance)* RandomNegPos()
			local y = position.y + math.random(min_distance,max_distance)* RandomNegPos()
			local pos = surface.find_non_colliding_position(worm, {x=x,y=y}, 6, 2)
			if pos then 
				create_remnants_particles (surface, math.random(20,40) , pos) 
				local wo = surface.create_entity{name=worm,force=force,position=pos}
				table.insert (global.other_enemies,wo )
				break
				end
		end
	end
end


--------------------------------------------------------


function create_biterzilla(surface,spawn,pcount, attack1, attack2, attack3)
local zilla, name, group

local evo = game.forces.enemy.evolution_factor
if evo<0.9 then 
	name = get_random_lesser_boss()

	else

	local list = {"biterzilla1","biterzilla2","biterzilla3","maf-giant-acid-spitter","maf-giant-fire-spitter","bm-motherbiterzilla"}
	if global.chances.soldiers.chance>0 then table.insert(list,"big_human") end
	name = list[math.random(#list)]
	if name=="big_human" then name=get_random_boss_human_soldier() 
	elseif string.find(name, "zilla") or string.find(name, "maf")  then 
		local N=1
		if evo>0.98 then N=5 
			elseif evo>0.96 then N=4
			elseif evo>0.94 then N=3
			elseif evo>0.92 then N=2
			end
		name=name..N
		end 
	end

local position = surface.find_non_colliding_position(name, spawn, 0, 1)
	if position then
		group = surface.create_unit_group{position = position, force = game.forces.enemy}
		create_remnants_particles (surface, math.random(60,100) , position) 
		zilla = surface.create_entity{name=name, position=position, force = game.forces.enemy}
		surface.create_entity{name="bm-large-tunnel", position=position, force = game.forces.neutral}
		group.add_member(zilla)
		
		local effect 
		if evo>0.6 and math.random (3)==1 then effect='defender_capsules' end 
		if evo>0.85 and math.random (3)==1 then effect='grenade_launcher' end
		table.insert (global.biterzillas, {entity=zilla, effect = effect})

		if evo>=0.9 then 
			local hpe = (pcount*zilla.health/10) * game.forces.enemy.evolution_factor
			if game.forces.enemy.evolution_factor>0.95 then hpe = hpe*1.5 end
			zilla.health  = (zilla.health/5) + hpe
			end

		if pcount>1 and game.forces.enemy.evolution_factor>0.95 then
		   if math.random(1,2)==1 then
		      CallFrenzyAttack(surface,attack1)
		      else
		      create_invasion(surface,attack1,pcount)
		      end
			end   
		end

group_set_command(group,attack1,attack2, attack3)
return group, zilla
end



function create_spidertron(surface,spawn,pcount)
local spider
local evo = game.forces.enemy.evolution_factor
local N=1
if evo>0.98 then N=5 
	elseif evo>0.96 then N=4
	elseif evo>0.94 then N=3
	elseif evo>0.92 then N=2
	end
local name='bm-spidertron_' .. N
	
local position = surface.find_non_colliding_position(name, spawn, 0, 1)
	if position then
		create_remnants_particles (surface, math.random(60,100) , position) 
		spider = surface.create_entity{name=name, position=position, force = game.forces.enemy}
		surface.create_entity{name="bm-large-tunnel", position=position, force = game.forces.neutral}
		local effect 
		if evo>0.6 and math.random (3)==1 then effect='defender_capsules' end 
		if evo>0.85 and math.random (3)==1 then effect='grenade_launcher' end
		table.insert (global.biterzillas, {entity=spider, effect = effect})

		if evo>=0.9 then 
			local hpe = (pcount*spider.health/10) * game.forces.enemy.evolution_factor
			if game.forces.enemy.evolution_factor>0.95 then hpe = hpe*1.5 end
			spider.health  = ((spider.health/5) + hpe) * global.difficulty_level
			end
		end

return spider
end



function Spidertron_Moves(spider)
if global.spidertron_nuke then 	
	spider.insert{name='maf-small-atomic-rocket',count=5}
	end

if game.forces.enemy.evolution_factor>0.95 then spider.insert{name='explosive-rocket',count=400} else spider.insert{name='rocket',count=400} end

local enemy = spider.surface.find_nearest_enemy{position=spider.position, max_distance=1500, force=spider.force} --zilla.force
	if enemy and enemy.valid then
		spider.autopilot_destination = get_random_pos_near(enemy.position,40)
		end
end





local tick_zillas = 61
script.on_nth_tick(tick_zillas, function (event)
for i=#global.invasions,1,-1 do
	local inv =global.invasions[i] 
	local surface = inv.surface
	if inv.quant>0 and surface.valid then 
		local position = inv.surface.find_non_colliding_position(inv.name, inv.position, 200, 4)
		if position ~= nil then
			create_remnants_particles (surface, math.random(20,40) , position)
			local invader = surface.create_entity{name=inv.name, position=position, force = game.forces.enemy}
			table.insert(global.other_enemies, invader)
			end
		inv.quant=inv.quant-1
		else inv.quant=0
		end
	if inv.quant<1 then table.remove(global.invasions,i) end
	end
	
	
-- ZILLAS 
for z=#global.biterzillas,1,-1 do
	local ZI = global.biterzillas[z]
	local zilla  = ZI.entity
	local effect = ZI.effect
	if not (zilla and zilla.valid) then table.remove(global.biterzillas,z) 
	else
	
	if string.find(zilla.name, "biterzilla1") then 
		if math.random(1,4)==1 then
			local xx = zilla.position.x + math.random(-5,5) 		
			local yy = zilla.position.y + math.random(-5,5) 		
			zilla.surface.create_entity{name ="maf-cluster-fire-projectile", target_position={x=xx,y=yy}, position={x=xx,y=yy}, source=zilla, force=zilla.force, speed=1}
			end	
		elseif string.find(zilla.name, "biterzilla2") then 
				if math.random(1,3)==1 then  zilla.surface.create_entity{name="electric-shock2", position=zilla.position, force=zilla.force}  end
		elseif string.find(zilla.name, "motherbiterzilla") then if math.random(1,4)==1 then Brood(zilla) end
		elseif string.find(zilla.name, "tc_fake_human_boss") and math.random(1,40)==1 then BroodHumans(zilla) 
		elseif effect and effect=='defender_capsules' then 
			local ent = {'destroyer','defender'}
				if math.random(3)==1 then zilla.surface.create_entity{name=ent[math.random(#ent)],  position=zilla.position,target=zilla,force=zilla.force} end
		elseif effect and effect=='grenade_launcher' and math.random(5)==1 then
			local enemy = zilla.surface.find_nearest_enemy{position=zilla.position, max_distance=35, force=zilla.force} --zilla.force
			if enemy and enemy.valid and enemy.name~='entity-ghost' and enemy.type~='entity-ghost' and enemy.destructible and enemy.health then
				local weap = {'explosive-rocket','grenade'}
				zilla.surface.create_entity{name=weap[math.random(#weap)], target=enemy, position=zilla.position, force=zilla.force, speed=0.4}
				end
		end	
		
	if 	zilla.type == 'spider-vehicle' and game.tick % (tick_zillas*18) ==0 then Spidertron_Moves(zilla) end 
		
	end
end
	
end)



script.on_nth_tick(60*3, function (event)
for k=#global.bm_volcano,1,-1 do
	local V=global.bm_volcano[k]
	local volcano = V.volcano
	local tick  = V.tiltick
	if volcano and volcano.valid then
		local pos = volcano.position
		volcano.surface.pollute(pos,75)
		volcano.surface.create_trivial_smoke{name='fire-smoke-on-adding-fuel', position=pos} 
		volcano.surface.create_trivial_smoke{name='turbine-smoke', position=pos}
		if game.tick > tick then
			volcano.die()
			table.remove(global.bm_volcano,k)
			else -- erupt!!!
			volcano.surface.create_entity{name="big-artillery-explosion", position=pos, force = game.forces.neutral}
			local area = 50
			local xx = pos.x + math.random(-area,area) 		
			local yy = pos.y + math.random(-area,area) 		
			volcano.surface.create_entity{name ="maf-cluster-fire-projectile", target_position={x=xx,y=yy}, position={x=xx,y=yy}, source=volcano, force= game.forces.enemy, speed=4}
			end
		else
		table.remove(global.bm_volcano,k)
		end
	end
end)


function create_volcano(surface, target, pcount)
local duration = (60 * 60) + ((pcount + global.difficulty_level) * 60 * 20)
local volcano
local position = surface.find_non_colliding_position("bm-volcano", target, 200, 1)
	if position ~= nil then
		surface.create_entity{name="nuke-explosion", position=position, force = game.forces.enemy} --big-artillery-explosion
		volcano = surface.create_entity{name="bm-volcano", position=position, force = game.forces.enemy}
		table.insert(global.bm_volcano, {volcano=volcano, tiltick=game.tick + duration})
		end
return volcano
end


--------------------------------------------------------------------------
function create_bigworm(surface,target,pcount)
local worm = "maf-behemoth-worm-turret"  
if game.forces.enemy.evolution_factor > 0.80 then worm = "maf-colossal-worm-turret" end
if game.forces.enemy.evolution_factor > 0.9 then 
	if math.random(1,2)==1 then worm = "bm-worm-boss-fire-shooter" else worm = "bm-worm-boss-acid-shooter" end
	end
local worm = "maf-behemoth-worm-turret"  

local qt = math.min(4, 1 + math.floor(pcount/4)) + global.difficulty_level - 1
local the_worm
for x=1,qt do
	local position = surface.find_non_colliding_position(worm, target, 150, 1)
	if position then
		create_remnants_particles (surface, math.random(30,60) , position) 
		the_worm = surface.create_entity{name=worm, position= position, force= game.forces.enemy}
		table.insert (global.other_enemies,the_worm )
		end
	end
	
-- normal worms for reinforced attack
if pcount>2 then 
	local qt = math.min(25, math.max(1,math.ceil(game.forces.enemy.evolution_factor * 12 + math.random(math.ceil(pcount/2))))) + global.difficulty_level - 1
	CallWormAttack(surface,target,qt,0,20)
	end
	
return the_worm
end


function Brood(mother)
local x = mother.position.x
local y = mother.position.y 
local r = 10
local Units = mother.surface.find_entities_filtered({force=mother.force, area={{x-r,y-r},{x+r,y+r}}})
if #Units>50 then return end
local Min = 2
local Max = 6
local num = math.random(Min,Max) + global.difficulty_level - 1

local group = mother.unit_group 
local children = get_units_for_evolution()
for k=1,num do
	local name= children[math.random(#children)]
	local pos = mother.surface.find_non_colliding_position(name, mother.position, 10, 1)
		if pos then 
			mother.surface.create_entity{name="bm-acid-splash-fire", position=pos, force = mother.force}
			local child = mother.surface.create_entity{name=name, position=pos, force = mother.force}
			if group then group.add_member(child) end
			end
	end
end


function BroodHumans(mother)
local x = mother.position.x
local y = mother.position.y 
local r = 10
local Units = mother.surface.find_entities_filtered({force= mother.force, area={{x-r,y-r},{x+r,y+r}}})
if #Units>2 then return end
local num = math.random(3) + global.difficulty_level - 1

local group = mother.unit_group 
for k=1,num do
	local name= get_random_human_soldier()
	local pos = mother.surface.find_non_colliding_position(name, mother.position, 15, 1)
		if pos then 
			local child = mother.surface.create_entity{name=name, position=pos, force = mother.force}
			if group then group.add_member(child) end
			end
	end
end


--------------------------------------------------------------------------------------


local function create_rocks(entity,quant)
local rocks = {'rock-big','rock-huge','sand-rock-big'}
entity.surface.create_entity{name='rock-huge', position=entity.position, force = game.forces.neutral}	
for q=1,quant do
	local rock = rocks[math.random(#rocks)]
	local position = entity.surface.find_non_colliding_position(rock, entity.position, 10, 1)
		if position ~= nil then
		entity.surface.create_entity{name="big-artillery-explosion", position=position, force = game.forces.neutral}	
		entity.surface.create_entity{name=rock, position=position, force = game.forces.neutral}	
		end
	end
end

function On_Remove(event)
	if event.entity and event.entity.name == "bm-volcano" then
		create_rocks(event.entity,12)
		end
end
local filters = {{filter = "name", name = "bm-volcano"}}
script.on_event(defines.events.on_entity_died, On_Remove)



function On_Built(event)
local entity = event.created_entity or event.entity 
if entity and entity.valid and entity.type~='entity-ghost' then
	local surface = entity.surface
	local name=entity.name 
	table.insert (global.rocket_silos,entity)
	if global.enable_silo_attack then CallFrenzyAttack(surface,entity,nil,1.5) end
	end
end		
local filters = {{filter = "name", name = "rsc-silo-stage1"}, {filter = "name", name = "rsc-silo-stage1-serlp"}, {filter = "name", name = "rocket-silo"}}
script.on_event(defines.events.on_built_entity, On_Built, filters) 
script.on_event(defines.events.on_robot_built_entity, On_Built, filters) 
script.on_event(defines.events.script_raised_built, On_Built, filters) 



function player_mined_entity(event)
local player = game.players[event.player_index]	
if not player.valid then return end
local ent = event.entity
if ent.type=='tree' then 
	if math.random()<=global.tree_events_chance then
		local the_event=pick_event({'biterzilla','volcano'})
		if the_event then 
			local pforce = player.force
			local surface = ent.surface
			Create_Position_Event(the_event, surface, ent.position, pforce)	
			end
		end
	end
end
local filters = {{filter = "type", type = "tree"}}
script.on_event(defines.events.on_player_mined_entity, player_mined_entity, filters) 




--------------------------------------------------------------------------------------


-- INTERFACE
	
--------------------------------------------------------------------------------------

local interface = {}


function interface.destroy_all()
global.invasions = {}
	
for _, zilla in pairs(global.biterzillas) do
	if zilla.entity.valid then
		zilla.entity.destroy()
	end
end
global.biterzillas = {}

for k=#global.bm_volcano,1,-1 do
	local V=global.bm_volcano[k]
	local volcano = V.volcano
	if volcano and volcano.valid then volcano.destroy() end 
	end
global.bm_volcano = {}

for _, e in pairs(global.other_enemies) do if e and e.valid then e.destroy() end end 
global.other_enemies = {}
end

local event_names = {'biterzilla','brutals','soldiers','worms','volcano','invasion','swarm','spidertron'}

function interface.create_event(the_event,surfacename,forcename)
if (not the_event) or in_list(event_names, the_event) then
	CreateNewEvent(the_event,surfacename, forcename)
	end
end
function interface.create_silo_event(the_event)
if (not the_event) or in_list(event_names, the_event) then
	Create_Silo_Attack(the_event)
	end
end

-- exclude / include surfaces for disasters
function interface.exclude_surface(surfacename)
if surfacename then del_list(global.surfaces, surfacename) end
end

function interface.add_surface(surfacename)
if surfacename then add_list(global.surfaces, surfacename) end
end

-- exclude / include player forces to be targeted
function interface.exclude_player_force(forcename)
if forcename then del_list(global.player_forces, forcename) end
end

function interface.add_player_force(forcename)
if forcename then add_list(global.player_forces, forcename) end
end

remote.add_interface( "bigmonster", interface )


--[[
 Usage for creating events: create_event(eventname,surfacename,forcename)
 Use these event names 'biterzilla','soldiers','worms','volcano','invasion','swarm'
 nil will create a random event

 Examples:
 Call specific events for all surfaces and all player forces
 /c remote.call( "bigmonster", "create_event", "biterzilla")
 /c remote.call( "bigmonster", "create_event", "soldiers")
 /c remote.call( "bigmonster", "create_event", "worms")
 /c remote.call( "bigmonster", "create_event", "volcano")
 /c remote.call( "bigmonster", "create_event", "invasion")
 /c remote.call( "bigmonster", "create_event", "swarm")
 /c remote.call( "bigmonster", "create_event", "spidertron")


 Call specific event for nauvis surface only, to all player forces
 /c remote.call( "bigmonster", "create_event", "biterzilla", "nauvis")

 Call specific event for all registered surfaces, to specific player force
 /c remote.call( "bigmonster", "create_event", "volcano", nil, "player")

 Call random event for all registered surfaces, to specific player force
 /c remote.call( "bigmonster", "create_event", nil, nil, "player")


 Call an event for attacking All Silos - eventname = all above
 /c remote.call( "bigmonster", "create_silo_event", eventname)


include surfaces for disasters
/c remote.call( "bigmonster", "add_surface", surfacename)
exclude surfaces for disasters
/c remote.call( "bigmonster", "exclude_surface", surfacename)


include player force to be targeted
/c remote.call( "bigmonster","add_player_force",forcename)
exclude player force to be targeted
/c remote.call( "bigmonster","exclude_player_force",forcename)

destroy all mod enemies
/c remote.call( "bigmonster","destroy_all")
]]


