require("util")

mf_mod_name = "Big-Monsters" -- used on cameras
mf_camera_chart = true
mf_Camera_Default_Icon="[img=utility/gps_map_icon]"
require "__mferrari_lib__/cameras"
require "__mferrari_lib__/mf_lib"
require "__mferrari_lib__/particles"
require "__mferrari_lib__/stdlib/area/chunk"
require "__mferrari_lib__/stdlib/area/area"


-- Skip event spawning on peaceful surfaces or on maps generated with
-- enemy-base size = 0 (i.e. no enemies expected). Can be overridden via
-- runtime setting "bm-events-when-peaceful" (default off).
-- Paranoidal: also during the truce of RampantFixed on the surface (remote getTruceInfo: the evolution or the
-- peace period of its planet setting is not reached yet).
local function rampant_truce(surface)
    local rampant = remote.interfaces["rampantFixed"]
    if not (rampant and rampant["getTruceInfo"]) then return false end
    local info = remote.call("rampantFixed", "getTruceInfo", {surfaceIndex = surface.index})
    return (info ~= nil) and (info.truce == true)
end

local function bm_peaceful_skip(surface)
    if not surface or not surface.valid then return true end
    if settings.global["bm-events-when-peaceful"] and settings.global["bm-events-when-peaceful"].value then return false end
    if surface.peaceful_mode then return true end
    local ac = surface.map_gen_settings and surface.map_gen_settings.autoplace_controls
    if ac and ac["enemy-base"] and ac["enemy-base"].size == 0 then return true end
    if rampant_truce(surface) then return true end
    return false
end

-- Silo events respect the same surface / player force lists as the regular events.
local function bm_target_allowed(surface, force)
    if not (surface and surface.valid and force and force.valid) then return false end
    return in_list(storage.surfaces, surface.name) ~= nil and in_list(storage.player_forces, force.name) ~= nil
end

-- Removes invalid entities from an array in place, keeping the order.
local function compact_valid_entities(list)
    local n = 0
    for i = 1, #list do
        local e = list[i]
        list[i] = nil
        if e and e.valid then
            n = n + 1
            list[n] = e
        end
    end
end


function ReadRunTimeSettings(event)
storage.chances = storage.chances or {}  -- in priority order of danger
storage.chances.volcano       = {min_evo=settings.global["bm-volcano-min_evo"].value  		, chance=settings.global["bm-volcano-chance"].value, max_evo=settings.global["bm-volcano-max_evo"].value}
storage.chances.spidertron    = {min_evo=settings.global["bm-spidertron-min_evo"].value  	, chance=settings.global["bm-spidertron-chance"].value		, evo_adjust_in_planet=0.10}
storage.chances.demolisher    = {min_evo=settings.global["bm-demolisher-min_evo"].value  	, chance=settings.global["bm-demolisher-chance"].value		, evo_adjust_in_planet=0.10}
storage.chances.flying_saucer = {min_evo=settings.global["bm-flying-saucer-min_evo"].value  , chance=settings.global["bm-flying-saucer-chance"].value	, evo_adjust_in_planet=0.10}
storage.chances.biterzilla    = {min_evo=settings.global["bm-biterzilla-min_evo"].value 	, chance=settings.global["bm-biterzilla-chance"].value		, evo_adjust_in_planet=0.15}
storage.chances.worms         = {min_evo=settings.global["bm-worms-min_evo"].value  		, chance=settings.global["bm-worms-chance"].value			, evo_adjust_in_planet=0.20}
storage.chances.soldiers      = {min_evo=settings.global["bm-soldiers-min_evo"].value 		, chance=settings.global["bm-soldiers-chance"].value		, evo_adjust_in_planet=0.25}
storage.chances.gleba_invaders= {min_evo=settings.global["bm-gleba-invaders-min_evo"].value , chance=settings.global["bm-gleba-invaders-chance"].value	, evo_adjust_in_planet=0.50}
storage.chances.invasion      = {min_evo=settings.global["bm-invasion-min_evo"].value 		, chance=settings.global["bm-invasion-chance"].value		, evo_adjust_in_planet=0.50}
storage.chances.swarm         = {min_evo=0, chance=settings.global["bm-swarm-chance"].value , max_evo=settings.global["bm-swarm-max_evo"].value}

storage.allowed_planets = {"fulgora","gleba","vulcanus"}
storage.spawn_on_sa_planets = settings.global["bm-spawn_on_sa_planets"].value 


if not script.active_mods["space-age"] then 
	storage.chances.gleba_invaders.chance=0
	storage.chances.demolisher.chance=0
	storage.allowed_planets = {}
	storage.spawn_on_sa_planets = false
	end

storage.enable_silo_attack  = settings.global["bm-enable-silo-attack"].value
storage.show_cameras 	   	= settings.global["bm-show-cameras"].value
storage.show_alerts 		= settings.global["bm-show-alerts"].value
storage.play_sound_alert    = settings.global["bm-play-sound-alert"].value
storage.days 			   	= settings.global["bm-event-days"].value
storage.allow_nuker  	   	= settings.global["bm-allow-nuker"].value
storage.difficulty_level    = settings.global["bm-difficulty-level"].value
storage.spidertron_nuke     = settings.global["bm-spidertron-nuke"].value
storage.tree_events_chance  = settings.global["bm-tree-events-chance"].value/100
storage.spawn_near_nests    = settings.global["bm-spawn_near_nests"].value 


if event and event.setting_type=='runtime-per-user' and event.player_index then
	local player = game.get_player(event.player_index)
	if player and player.valid then
		if event.setting=='bm_draggable_camera' then
			storage.enable_drag_camera[player.name] = settings.get_player_settings(player)["bm_draggable_camera"].value
		elseif event.setting=='bm_camera_size' then
			storage.camera_size[player.name] = settings.get_player_settings(player)["bm_camera_size"].value
			end
		end
	end
	
end
script.on_event(defines.events.on_runtime_mod_setting_changed, ReadRunTimeSettings)


function setup_mod_vars()
storage.player_forces    = storage.player_forces or {'player'}
storage.surfaces         = storage.surfaces or {'nauvis'}
storage.bm_volcano       = storage.bm_volcano or {}
storage.biterzillas      = storage.biterzillas or {}
storage.invasions        = storage.invasions or {}
storage.gleba_invasions  = storage.gleba_invasions or {}
storage.rocket_silos     = storage.rocket_silos or {}
storage.other_enemies    = storage.other_enemies or {}
storage.next_wave        = storage.next_wave or {}
storage.vanilla_biter_spawners = {"biter-spawner","spitter-spawner"}


ReadRunTimeSettings()
storage.next_event       = storage.next_event or (game.tick + (storage.days * 7 * 60 * 60))
storage.next_silo_event  = storage.next_silo_event or (game.tick + (storage.days * 4 * 60 * 60))
end

function on_init()
cam_on_init()
setup_mod_vars()
RegisterModEvents()
end
script.on_init(on_init)

function on_configuration_changed()
cam_on_init()
setup_mod_vars()
-- Paranoidal: targets picked by the old AI could be out of reach forever
for _, ZI in pairs(storage.biterzillas) do ZI.target = nil ZI.stuck = nil ZI.last_hp = nil ZI.last_dist = nil end
end
script.on_configuration_changed(on_configuration_changed)

function on_load()
RegisterModEvents()
end
script.on_load(on_load)


-- camera events
local function on_gui_click(event)
cam_on_gui_click(event)
end
script.on_event(defines.events.on_gui_click, on_gui_click)


function alert_force(force,message)
if storage.show_alerts then 
	mf_print(force,{"bm-txt-alert"}, colors.lightred, maf_icons.warning)
	mf_print(force,message, colors.lightred, maf_icons.info)
	end
end


------------------------------------------------------------------------------------------

-- the evolution bonus is meant for the extra planets only (Nauvis is a planet too in 2.0)
function get_planet_evo(surface, adjust) 
local evo = get_evo_here(surface)
if surface and surface.valid and adjust and game.planets[surface.name] and in_list(storage.allowed_planets, surface.name) then
	evo = evo + adjust
	end
return evo
end



-- Events are tried from the most dangerous one (each rolls its own chance). Was pairs() over storage.chances:
-- the order of the string keys, not the danger, decided which chances came first.
local EVENT_ORDER = {"volcano", "spidertron", "demolisher", "flying_saucer", "biterzilla", "worms", "soldiers",
                     "gleba_invaders", "invasion", "swarm"}

function pick_event(excludes,surface)
local the_event
local evo
if not excludes then excludes={} end
for _, event in ipairs(EVENT_ORDER) do
	local chances = storage.chances[event]
	if chances and not in_list(excludes,event) then
	evo = get_planet_evo(surface, chances.evo_adjust_in_planet)
	if chances.chance>0 and evo >= chances.min_evo and math.random(100) <= chances.chance then 
		if (not chances.max_evo) or (chances.max_evo>=evo) then 
			the_event = event
			break
			end
		end
		end
	end
return the_event, evo
end







function Play_sound_alert(force,id)
if storage.play_sound_alert then
local sound 
if id==1 then
		if script.active_mods['mferrari-mod-sounds'] then sound = 'mferrari_tense_music_1m' else sound='mf_sound_alarm_1' end
	elseif id==2 then
		if script.active_mods['mferrari-mod-sounds'] then sound = 'mferrari_tense_music_2m' else sound='mf_sound_alarm_2' end
	elseif id==3 then	
		if script.active_mods['mferrari-mod-sounds'] then sound = 'mferrari_tense_music_3m' else sound='mf_sound_siren' end
	end
if script.active_mods['mferrari-mod-sounds'] then force.play_sound{path=sound,override_sound_type='ambient' } else force.play_sound{path=sound} end  
end
end



function validate_surfaces_list()
for s=#storage.surfaces,1,-1 do
	if not (game.surfaces[storage.surfaces[s]] and game.surfaces[storage.surfaces[s]].valid) then table.remove(storage.surfaces,s) end
end
end


--the_event = biterzilla,soldiers,worms,volcano,invasion,swarm
function CreateNewEvent(the_event,surfacename, forcename)
validate_surfaces_list()

local sufaces_tab = table.deepcopy(storage.surfaces)
if surfacename then add_list(sufaces_tab, surfacename) end


for s=1,#sufaces_tab do
local next_waves={}
local surface = game.surfaces[sufaces_tab[s]]
local evo
if not the_event then the_event,evo=pick_event(nil,surface) end
if not evo then evo=get_evo_here(surface) end 

for p=1,#storage.player_forces do
	local pforce = game.forces[storage.player_forces[p]]
	if surface and the_event and pforce and (not surfacename or surface.name==surfacename) and (not forcename or pforce.name==forcename) then
		if bm_peaceful_skip(surface) then break end
		local player_spawn = pforce.get_spawn_position(surface)
		local pcount = count_players_on_surface(surface, pforce)

		if pcount>0 then 
			local target  
			
			if the_event=='swarm' then 
					local last_building = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local attack = {surface=surface,target=last_building}   --(at.surface,at.target,at.limit,at.multiplier)
					table.insert (next_waves,attack) 	
					--CallFrenzyAttack(surface,last_building)  --- now on waves
					alert_force(pforce,{"bm-txt-swarm"})
					Play_sound_alert(pforce,1)	
						
				elseif the_event=='invasion' then 
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					create_invasion(surface,target,pcount,evo)
					alert_force(pforce,{"bm-txt-invasion"})
					Play_sound_alert(pforce,1)	
					if storage.show_cameras then CreateCameraForForce(pforce,target,surface,nil,nil,120,0.15) end
					
					
				elseif the_event=='volcano' then
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					local volcano = create_volcano(surface, target, pcount)
					if volcano then  
						alert_force(pforce,{"bm-txt-volcano"})
						Play_sound_alert(pforce,2)		
						if storage.show_cameras then CreateCameraForForce(pforce,volcano,surface,nil,nil,120,0.15) end
						end

				
				elseif the_event=='worms' then
					local last_building, player_chunks = FindTeamAttackCorner(surface, pforce, player_spawn,1)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local target = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					local bigworm = create_bigworm(surface,target,pcount,evo)
					if bigworm then  
						alert_force(pforce,{"bm-txt-worm"})
						Play_sound_alert(pforce,2)	
						if storage.show_cameras then CreateCameraForForce(pforce,bigworm,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='soldiers' then  
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local group, humie = create_soldiers_group(surface,spawn,pcount,attack1, attack2, player_spawn,evo)
						alert_force(pforce,{"bm-txt-human_soldiers"})
						Play_sound_alert(pforce,2)
						if storage.show_cameras then CreateCameraForForce(pforce,humie,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='gleba_invaders' and script.active_mods["space-age"] then  
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local attacks = {attack1, attack2, player_spawn}
						create_gleba_drop_invasion(surface,spawn,pforce,attacks,evo)
						end


				elseif the_event=='biterzilla' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local group, zilla = create_biterzilla(surface,spawn,pcount,attack1, attack2, player_spawn,nil,evo)
						alert_force(pforce,{"bm-txt-biterzilla"})
						Play_sound_alert(pforce,3)
						if storage.show_cameras then CreateCameraForForce(pforce,zilla,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='spidertron' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					local rchunk = player_chunks[math.random(#player_chunks)]
					--local attack2 = {x= rchunk.x*32+math.random(31), y= rchunk.y*32+math.random(31)}
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local spider = create_spidertron(surface,spawn,pcount,evo)
						alert_force(pforce,{"bm-txt-spidertron"})
						Play_sound_alert(pforce,3)	
						if storage.show_cameras then CreateCameraForForce(pforce,spider,surface,nil,nil,120,0.15) end
						end

				elseif the_event=='demolisher' and script.active_mods["space-age"] then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,15)
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local worm = create_demolisher(surface,spawn,evo)
						if worm then
							alert_force(pforce,{"bm-txt-demolisher"})
							Play_sound_alert(pforce,3)	
							if storage.show_cameras then CreateCameraForForce(pforce,worm,surface,nil,nil,120,0.15) end
							end
						end


				elseif the_event=='flying_saucer' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,4)
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local spider = create_flying_saucer(surface,spawn,pcount,evo)
						alert_force(pforce,{"bm-txt-ufo"})
						Play_sound_alert(pforce,3)	
						if storage.show_cameras then CreateCameraForForce(pforce,spider,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='ultimate_boss' then
					local attack1, player_chunks, spawn = FindTeamAttackCorner(surface, pforce, player_spawn,10)
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local group, zilla = create_biterzilla(surface,spawn,pcount,attack1, nil, player_spawn,'bm_fake_human_ultimate_boss_cannon_20',evo)
						alert_force(pforce,{"bm-txt-ultimate_boss"})
						Play_sound_alert(pforce,3)	
						if storage.show_cameras then CreateCameraForForce(pforce,zilla,surface,nil,nil,120,0.15) end
						end

				end
			
			end --pcount>0

		end --the_event
	end -- p

if #next_waves>0 then 
	local waves = 2 + math.ceil(storage.difficulty_level) + math.floor (evo* 6)
	for w=1,waves do
		local tick = game.tick + ((w-1)*60*40 )
		local new_wave = {tick=tick, event_name=the_event, attacks=next_waves}
		table.insert(storage.next_wave,new_wave)
		end
	end

end
end





function Create_Position_Event(the_event, surface, position, pforce)
if not (surface and surface.valid) then return end
if bm_peaceful_skip(surface) then return end
local pcount = math.max(1,count_players_on_surface(surface, pforce)) --1 min to avoid crashes
local evo = get_evo_here(surface)

			if the_event=='swarm' then 
					CallFrenzyAttack(surface,position)
					alert_force(pforce,{"bm-txt-swarm"})
						
				elseif the_event=='invasion' then 
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 60, 1)
					if target then 
						create_invasion(surface,target,pcount,evo)
						alert_force(pforce,{"bm-txt-invasion"})
						Play_sound_alert(pforce,1)	
						if storage.show_cameras then CreateCameraForForce(pforce,target,surface,nil,nil,120,0.15) end
						end
					
					
				elseif the_event=='volcano' then
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 50, 1)
					if target then 
						local volcano = create_volcano(surface, target, pcount)
						if volcano then  
							alert_force(pforce,{"bm-txt-volcano"})
							Play_sound_alert(pforce,2)	
							if storage.show_cameras then CreateCameraForForce(pforce,volcano,surface,nil,nil,120,0.15) end
							end
						end

				
				elseif the_event=='worms' then
					local target = get_random_pos_near(position,150)
					target = surface.find_non_colliding_position('rocket-silo', target, 50, 1)
					if target then 
						local bigworm = create_bigworm(surface,target,pcount,evo)
						if bigworm then  
							alert_force(pforce,{"bm-txt-worm"})
							Play_sound_alert(pforce,2)	
							if storage.show_cameras then CreateCameraForForce(pforce,bigworm,surface,nil,nil,120,0.15) end
							end
						end


				elseif the_event=='soldiers' then
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local group, humie = create_soldiers_group(surface,spawn,pcount,position,nil,nil,evo)
						alert_force(pforce,{"bm-txt-human_soldiers"})
						Play_sound_alert(pforce,2)	
						if storage.show_cameras then CreateCameraForForce(pforce,humie,surface,nil,nil,120,0.15) end
						end

						
				elseif the_event=='gleba_invaders' and script.active_mods["space-age"] then  
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local attacks = {position, position, position}
						create_gleba_drop_invasion(surface,spawn,pforce,attacks,evo)
						end


				elseif the_event=='biterzilla' then
					local spawn = surface.find_nearest_enemy{position=position, max_distance=500, force=pforce}
					if spawn then
						spawn = get_random_pos_near(spawn.position,30)
						local group, zilla = create_biterzilla(surface,spawn,pcount,position,nil,nil,nil,evo)
						alert_force(pforce,{"bm-txt-biterzilla"})
						Play_sound_alert(pforce,3)	
						if storage.show_cameras then CreateCameraForForce(pforce,zilla,surface,nil,nil,120,0.15) end
						end


				elseif the_event=='flying_saucer' then
					local spawn=position
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local spider = create_flying_saucer(surface,spawn,pcount,evo)
						alert_force(pforce,{"bm-txt-ufo"})
						Play_sound_alert(pforce,3)	
						if storage.show_cameras then CreateCameraForForce(pforce,spider,surface,nil,nil,120,0.15) end
						end

				elseif the_event=='demolisher' and script.active_mods["space-age"] then
					local spawn=position
					if spawn then
						if storage.spawn_near_nests then spawn = get_pos_near_enemy_nest(surface,spawn,pforce) end 
						local worm = create_demolisher(surface,spawn,evo)
						if worm then
							alert_force(pforce,{"bm-txt-demolisher"})
							Play_sound_alert(pforce,3)	
							if storage.show_cameras then CreateCameraForForce(pforce,worm,surface,nil,nil,120,0.15) end
							end
						end
						
				end

end 



function Create_Silo_Attack(the_event)
if not the_event then the_event=pick_event() end
if the_event then 
for s=#storage.rocket_silos,1,-1 do
	local silo=storage.rocket_silos[s]
	if not (silo and silo.valid) then table.remove(storage.rocket_silos,s)
		else

		local pforce = silo.force
		local surface = silo.surface
		local pcount = count_players_on_surface(surface, pforce)		
		if pcount>0 and #pforce.connected_players>0 and bm_target_allowed(surface, pforce) then Create_Position_Event(the_event, surface, silo.position, pforce) end
		end
	end
end
end



script.on_nth_tick(60*60, function (event)
compact_valid_entities(storage.other_enemies)

if storage.days>0 then

	if storage.next_event<game.tick then 
		CreateNewEvent()
		storage.next_event = game.tick + (storage.days * (7 + math.random(-2,2)) * 60 * 60)
		end

	if storage.next_silo_event < game.tick and storage.enable_silo_attack then 
		Create_Silo_Attack()
		storage.next_silo_event = game.tick + (storage.days * (7 + math.random(-4,-2)) * 60 * 60)
		end
	end
end)






function FindTeamAttackCorner(surface, force, initial_position, chunk_distance)
local directionVec=GetRandomVector()
if not chunk_distance then chunk_distance=4 end
local enemy_spawn
local nothing = 0
local chunkPos = Chunk.from_position(initial_position)  --{x=0,y=0}  initial_position
local steps = 0
-- copies: chunkPos is moved along the search vector below
local player_chunks = {table.deepcopy(chunkPos)}
local last_building = table.deepcopy(chunkPos)
    -- Keep checking chunks in the direction of the vector
    while(not enemy_spawn) do
		chunkPos.x = chunkPos.x + directionVec.x
        chunkPos.y = chunkPos.y + directionVec.y
        steps = steps + 1
        -- Set some absolute limits (Paranoidal: also at most 600 chunks walked, one area search each)
        if ((math.abs(chunkPos.x) > 2000) or (math.abs(chunkPos.y) > 2000)) or (steps > 600) then break
        
        elseif (surface.is_chunk_generated(chunkPos)) then
			local area = Chunk.to_area(chunkPos) 
			local builds = surface.find_entities_filtered{force=force,area=area,limit=1}
			if #builds>0 then 
				last_building = table.deepcopy(chunkPos)
				table.insert (player_chunks,table.deepcopy(chunkPos))
				nothing = 0 -- only consecutive empty chunks count
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





--------------------------------------------------------------------------------------
function create_soldiers_group(surface,spawn,pcount, attack1, attack2,attack3,evo)
local qt = math.min(10, math.max(2,math.ceil(evo * 10 + math.random(math.ceil(pcount/2)))))  + (storage.difficulty_level-1) * 12
local group 
local one_humie 
for x=1, qt do
	local humie = get_random_human_soldier()
	local position = surface.find_non_colliding_position(humie, spawn, 100, 1)
	if position then
		if not group then group = surface.create_unit_group{position = position, force = game.forces.enemy} end
		one_humie = surface.create_entity{name=humie, position= position, force= game.forces.enemy}
		if one_humie and one_humie.valid then 
			one_humie.ai_settings.allow_destroy_when_commands_fail=false
			group.add_member(one_humie) table.insert (storage.other_enemies,one_humie ) 
			end
		end
	end
	
if evo>0.91 and math.random(2)==1 then 
	local humie = get_random_boss_human_soldier(0) 
	local position = surface.find_non_colliding_position(humie, spawn, 100, 1)
	if position then
		if not group then group = surface.create_unit_group{position = position, force = game.forces.enemy} end
		one_humie = surface.create_entity{name=humie, position=position, force = game.forces.enemy}
		if one_humie and one_humie.valid then
			one_humie.ai_settings.allow_destroy_when_commands_fail=false
			group.add_member(one_humie) table.insert(storage.other_enemies,one_humie)
			end
		end
	end
	
if group then group_set_command(group,attack1,attack2,attack3) end
return group, one_humie
end

function create_invasion(surface,position,pcount,evo)
local qt = math.min(25, math.max(1,math.ceil(evo * 20 + math.random(math.ceil(pcount/2))))) + storage.difficulty_level - 1
table.insert (storage.invasions, {name="bm-spawner", surface=surface, position=position, quant=qt})
if evo>0.8 then 
	if math.random(1,2)==1 then CallWormAttack(surface,position,math.ceil((qt+ storage.difficulty_level )/2),0,25) end 
	end
end


function create_gleba_drop_invasion(surface,position,pforce,attacks,evo)
local pos = surface.find_non_colliding_position("mf-gleba-spawner",get_random_pos_near(position,20), 50, 1)
if pos then 
	local proj = "mf_alienpod_arrival_projectile_1"
	if evo>0.7 then proj = "mf_alienpod_arrival_projectile_2" end
	local pod=surface.create_entity{name=proj, position={pos.x + 5*RandomNegPos(), pos.y-60}, target=pos, force="enemy"}
	alert_force(pforce,{"bm-txt-gleba-invasion"})
	Play_sound_alert(pforce,2)
	if storage.show_cameras then CreateCameraForForce(pforce,{object=pod,final_position=pos},surface,nil,nil,120,0.25) end
	-- spawner tracking for gleba invasions is disabled upstream, so nothing is queued in storage.gleba_invasions
	end
end


	
function get_random_human_soldier(evolution,surface)
if not evolution then evolution = get_evo_here(surface) end
local list = { 'bm_fake_human_machine_gunner',
'bm_fake_human_laser',
'bm_fake_human_electric'}
if evolution>0.17 then 
	table.insert(list,'bm_fake_human_sniper')  
	else
	table.insert(list,'bm_fake_human_melee')
	table.insert(list,'bm_fake_human_pistol_gunner')
	end
if evolution>0.3 then table.insert(list,'bm_fake_human_grenade') table.insert(list,'bm_fake_human_flamethrower') end
if evolution>0.60 then table.insert(list,'bm_fake_human_rocket') table.insert(list,'bm_fake_human_cannon')  end
if evolution>0.75 then table.insert(list,'bm_fake_human_erocket') table.insert(list,'bm_fake_human_cluster_grenade') table.insert(list,'bm_fake_human_cannon_explosive') end
if storage.allow_nuker and evolution>0.96 then table.insert(list,'bm_fake_human_nuke_rocket') end

local n=math.min(10, math.max(math.ceil(evolution*10),1))
return list[math.random(#list)] ..'_'..n
end


function get_random_boss_human_soldier(evolution,surface)
if not evolution then evolution = get_evo_here(surface) end
local list = { 'bm_fake_human_boss_machine_gunner',
'bm_fake_human_boss_laser',
'bm_fake_human_boss_electric',
'bm_fake_human_boss_flamethrower'
}
if evolution>0.94 then table.insert(list,'bm_fake_human_boss_sniper') end
if evolution>0.96 then 
	table.insert(list,'bm_fake_human_boss_rocket') 
	table.insert(list,'bm_fake_human_boss_grenade')
	end
if evolution>0.98 then 
	table.insert(list,'bm_fake_human_boss_erocket')
	table.insert(list,'bm_fake_human_boss_cluster_grenade') 
	table.insert(list,'bm_fake_human_boss_cannon_explosive') 
	end
local n=math.min(10, math.max(math.ceil((evolution - 0.9) *100),1))
return list[math.random(#list)] ..'_'..n
end




function Call_next_wave(event)
local event_name = event.event_name
if event_name == 'swarm' then
	local attacks = event.attacks
	for a=1,#attacks do
		local at = attacks[a]
		if at.surface and at.surface.valid and not bm_peaceful_skip(at.surface) then CallFrenzyAttack(at.surface,at.target,at.limit,at.multiplier) end
		end
	end
end





--------------------------------------------------------
function create_biterzilla(surface,spawn,pcount, attack1, attack2, attack3,specific_zilla,evo)
if not (surface and surface.valid) then return end
local zilla, name, group
if evo<0.9 and (not specific_zilla) then
	name = get_random_lesser_boss(evo,surface)
	else

	local list = {"biterzilla1","biterzilla2","biterzilla3","maf-giant-acid-spitter","maf-giant-fire-spitter","bm-motherbiterzilla"}
	if storage.chances.soldiers.chance>0 then table.insert(list,"big_human") end
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

if specific_zilla then name=specific_zilla end

local position = surface.find_non_colliding_position(name, spawn, 0, 1)
	if position then
		group = surface.create_unit_group{position = position, force = game.forces.enemy}
		create_remnants_particles (surface, math.random(60,100) , position) 
		zilla = surface.create_entity{name=name, position=position, force = game.forces.enemy}
		if not (zilla and zilla.valid) then
			group.destroy()
			return nil, nil
			end
		zilla.ai_settings.allow_destroy_when_commands_fail=false 
		surface.create_entity{name="bm-large-tunnel", position=position, force = game.forces.neutral}
		group.add_member(zilla)
		
		local effect 
		if specific_zilla then effect='all_buff' 
			elseif (string.find(name, "human") and evo>0.6 and math.random (3)==1) then effect='defender_capsules' 
			elseif (string.find(name, "human") and evo>0.85 and math.random (3)==1) then effect='grenade_launcher' end
		table.insert (storage.biterzillas, {entity=zilla, effect = effect})
		-- Paranoidal: full health. From 0.9 evolution the health was cut to a fifth plus a share per player (a third
		-- for one player), while the weaker bosses below 0.9 kept all of it

		if pcount>1 and evo>0.95 then
		   if math.random(1,2)==1 then
		      CallFrenzyAttack(surface,attack1)
		      else
		      if storage.chances.invasion.chance>=math.random(100) then create_invasion(surface,attack1,pcount,evo) end
		      end
			end   
		end

if group then group_set_command(group,attack1,attack2, attack3) end
return group, zilla
end



function create_spidertron(surface,spawn,pcount,evo)
if not (surface and surface.valid) then return end
local spider
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
		table.insert (storage.biterzillas, {entity=spider, effect = effect})
		-- Paranoidal: full health, as the other bosses (was cut like them, then multiplied by the difficulty)
		end

return spider
end




function create_demolisher(surface,spawn,evo)
if not (surface and surface.valid) then return end
local worm
local N="small"
if evo>0.96 then N="big"
	elseif evo>0.93 then N="medium"
	end
local name= "mf_".. N .. "-demolisher"
local position = surface.find_non_colliding_position(name, spawn, 0, 1)
	if position then
		create_remnants_particles (surface, math.random(60,100) , position) 
		worm = surface.create_entity{name=name, position=position, force = game.forces.enemy}
		surface.create_entity{name="bm-large-tunnel", position=position, force = game.forces.neutral}
		surface.create_entity{name="small-demolisher-trail-upper", position=position, force = game.forces.neutral}
		surface.create_entity{name="small-demolisher-trail-lower", position=position, force = game.forces.neutral}
		table.insert (storage.biterzillas, {entity=worm})
		end
return worm
end



function create_flying_saucer(surface,spawn,pcount,evo)
local spider
local N=1
if evo>0.98 then N=8
	elseif evo>0.96 then N=7
	elseif evo>0.9 then N=6
	elseif evo>0.85 then N=5
	elseif evo>0.8  then N=4
	elseif evo>0.75 then N=3
	elseif evo>0.7  then N=2
	end
local name='maf_flying_saucer_' .. N
local position = surface.find_non_colliding_position(name, spawn, 0, 1)
	if position then
		create_remnants_particles (surface, math.random(60,100) , position) 
		spider = surface.create_entity{name=name, position=position, force = game.forces.enemy}
		spider.insert({name='flying-saucer-laser-ammo',count=1}) 
		local effect 
		if evo>0.8 and math.random (3)==1 then effect='defender_capsules' end 
		table.insert (storage.biterzillas, {entity=spider, effect = effect})
		-- Paranoidal: full health, as the other bosses
		end
return spider
end




-- Paranoidal: boss spidertron / flying saucer AI.
-- Target priority: player character near -> turret near -> current target -> military target near -> nearest enemy.
-- The boss stops on the straight line at BM_SPIDER_ENGAGE tiles (inside rocket ~36 and laser 40 range) and circles the target.
-- A target that is neither damaged nor approached for 3 move cycles is ignored for 5 minutes.
local BM_SPIDER_ENGAGE   = 22
local BM_SPIDER_RANGE    = 36
local BM_SPIDER_PLAYER_R = 60
local BM_SPIDER_LOCAL_R  = 50
local BM_SPIDER_TURRETS  = {"ammo-turret", "electric-turret", "fluid-turret", "artillery-turret"}
local BM_SPIDER_ROCKETS  = {"rocket", "explosive-rocket"}
local BM_SPIDER_TURRET_SET = {}
for _, t in pairs(BM_SPIDER_TURRETS) do BM_SPIDER_TURRET_SET[t] = true end

local function bm_enemy_forces(force)
local list = {}
for _, f in pairs(game.forces) do
	if f ~= force and force.is_enemy(f) then list[#list+1] = f end
	end
return list
end

local function bm_valid_target(ZI, e)
if not (e and e.valid and e.destructible and e.health) then return false end
local un = e.unit_number
if un and ZI.ignore and ZI.ignore[un] and ZI.ignore[un] > game.tick then return false end
return true
end

local function bm_nearest(spider, ZI, filter)
local best, bd
local p = spider.position
for _, e in pairs(spider.surface.find_entities_filtered(filter)) do
	if bm_valid_target(ZI, e) then
		local d = distance_squared(p, e.position)
		if not bd or d < bd then best, bd = e, d end
		end
	end
return best
end

local function bm_spider_pick_target(spider, ZI)
local forces = bm_enemy_forces(spider.force)
if #forces == 0 then return nil end
local pos = spider.position
local current = ZI.target
if not bm_valid_target(ZI, current) then current = nil end
if current and current.type == 'character' then return current end
local e = bm_nearest(spider, ZI, {position=pos, radius=BM_SPIDER_PLAYER_R, type='character', force=forces})
if e then return e end
if current and BM_SPIDER_TURRET_SET[current.type] then return current end
e = bm_nearest(spider, ZI, {position=pos, radius=BM_SPIDER_LOCAL_R, type=BM_SPIDER_TURRETS, force=forces})
if e then return e end
if current then return current end
e = bm_nearest(spider, ZI, {position=pos, radius=BM_SPIDER_LOCAL_R, is_military_target=true, force=forces})
if e then return e end
e = spider.surface.find_nearest_enemy{position=pos, max_distance=1500, force=spider.force}
if bm_valid_target(ZI, e) then return e end
-- the nearest one is ignored: any other building near
return bm_nearest(spider, ZI, {position=pos, radius=BM_SPIDER_LOCAL_R*2, force=forces, limit=300})
end

-- Fallback fire: the target is in range, but the vehicle auto targeting does not shoot it (no rocket spent for 2 s).
function bm_spider_fallback_fire(spider, ZI)
if game.tick % 120 ~= 0 then return end
local ammo = 0
for _, n in pairs(BM_SPIDER_ROCKETS) do ammo = ammo + spider.get_item_count(n) end
local prev = ZI.ammo_prev
ZI.ammo_prev = ammo
if prev and ammo < prev then return end
local t = ZI.target
if not (t and t.valid and t.health) then return end
if distance(t.position, spider.position) > BM_SPIDER_RANGE then return end
if ZI.saucer then
	spider.surface.create_entity{name='flying-saucer-laser-projectile', position=spider.position, target=t, source=spider, force=spider.force, speed=1}
	else
	spider.surface.create_entity{name='explosive-rocket', position=spider.position, target=t, source=spider, force=spider.force, speed=0.4}
	end
end

-- ZI: the record in storage.biterzillas
function Spidertron_Moves(spider, ZI)
ZI = ZI or {}
if storage.spidertron_nuke and spider.get_item_count('maf-small-atomic-rocket') < 5 then
	spider.insert{name='maf-small-atomic-rocket',count=5}
	end

local FI = spider.get_fuel_inventory() 
if FI then 
	if FI.get_item_count('solid-fuel')<20 and FI.can_insert{name='solid-fuel', count=20} then spider.insert {name='solid-fuel', count=20} end 
	end

local rocket = get_evo_here(spider.surface)>0.95 and 'explosive-rocket' or 'rocket'
if spider.get_item_count(rocket) < 200 then spider.insert{name=rocket,count=400} end

local spos = spider.position
local target = bm_spider_pick_target(spider, ZI)
if target ~= ZI.target then ZI.target = target ZI.stuck = 0 ZI.last_hp = nil ZI.last_dist = nil end
if not target then
	spider.autopilot_destination = get_random_pos_near(spos, 30)
	return
	end

local tpos = target.position
local d  = distance(tpos, spos)
local hp = target.health
-- no damage and no approach: blocked (water, cliffs) or out of weapons reach
if ZI.last_hp and hp >= ZI.last_hp and ZI.last_dist and d > ZI.last_dist - 1 then ZI.stuck = (ZI.stuck or 0) + 1 else ZI.stuck = 0 end
ZI.last_hp, ZI.last_dist = hp, d
if ZI.stuck >= 3 then
	if target.unit_number then
		ZI.ignore = ZI.ignore or {}
		for un, t in pairs(ZI.ignore) do if t <= game.tick then ZI.ignore[un] = nil end end
		ZI.ignore[target.unit_number] = game.tick + 5*60*60
		end
	ZI.target, ZI.stuck, ZI.last_hp, ZI.last_dist = nil, 0, nil, nil
	spider.autopilot_destination = get_random_pos_near(spos, 30)
	return
	end

if d <= BM_SPIDER_ENGAGE + 8 then
	-- circle the target
	ZI.orbit = ZI.orbit or (math.random(2) == 1 and 1 or -1)
	local a = math.atan2(spos.y - tpos.y, spos.x - tpos.x) + ZI.orbit * 0.6
	spider.autopilot_destination = {x = tpos.x + math.cos(a) * BM_SPIDER_ENGAGE, y = tpos.y + math.sin(a) * BM_SPIDER_ENGAGE}
	ZI.last_dist = nil -- circling is not a missed approach
	else
	spider.autopilot_destination = get_pos_near_from_aproach(tpos, spos, BM_SPIDER_ENGAGE, 2)
	end
end





-- The boss kind is resolved once per tracked entity instead of string searches every second.
-- Mother biterzillas are checked first: their names also contain "biterzilla1" / "biterzilla2".
function classify_zilla(ZI, zilla)
local name = zilla.name
local kind = false
if string.find(name, "motherbiterzilla", 1, true) then kind = 'mother'
	elseif string.find(name, "biterzilla1", 1, true) then kind = 'fire'
	elseif string.find(name, "biterzilla2", 1, true) then kind = 'electric'
	elseif string.find(name, "human", 1, true) then kind = 'human'
	end
ZI.kind     = kind
ZI.ultimate = string.find(name, "bm_fake_human_ultimate_boss", 1, true) ~= nil
ZI.saucer   = string.find(name, "flying_saucer", 1, true) ~= nil
ZI.spider   = zilla.type == 'spider-vehicle'
end


local tick_zillas = 60
script.on_nth_tick(tick_zillas, function (event)
cam_on_tick(event)

for i=#storage.invasions,1,-1 do
	local inv =storage.invasions[i] 
	local surface = inv.surface
	if inv.quant>0 and surface.valid and not bm_peaceful_skip(surface) then
		local position = inv.surface.find_non_colliding_position(inv.name, inv.position, 200, 4)
		if position ~= nil then
			create_remnants_particles (surface, math.random(20,40) , position)
			local invader = surface.create_entity{name=inv.name, position=position, force = game.forces.enemy}
			table.insert(storage.other_enemies, invader)
			end
		inv.quant=inv.quant-1
		else inv.quant=0
		end
	if inv.quant<1 then table.remove(storage.invasions,i) end
	end
	
-- gleba invasion spawner tracking is disabled upstream: drop entries left by older versions
if storage.gleba_invasions[1] then storage.gleba_invasions = {} end






-- ZILLAS 
for z=#storage.biterzillas,1,-1 do
	local ZI = storage.biterzillas[z]
	local zilla  = ZI.entity
	local effect = ZI.effect
	if not (zilla and zilla.valid) then table.remove(storage.biterzillas,z) 
	else
	if ZI.kind == nil then classify_zilla(ZI, zilla) end
	local kind = ZI.kind
	
	if kind == 'fire' then
		if math.random(1,4)==1 then
			local xx = zilla.position.x + math.random(-5,5) 		
			local yy = zilla.position.y + math.random(-5,5) 		
			zilla.surface.create_entity{name ="mf-cluster-fire-projectile-big", target_position={x=xx,y=yy}, position={x=xx,y=yy}, source=zilla, force=zilla.force, speed=1}
			end	
		elseif kind == 'electric' then
				if math.random(3)==1 then  zilla.surface.create_entity{name="electric-shock2", position=zilla.position, force=zilla.force}  end
		elseif kind == 'mother' then if math.random(1,4)==1 then Brood(zilla) end
		elseif kind == 'human' and math.random(1,40)==1 then BroodHumans(zilla)
		end

	if ZI.saucer then zilla.color={r=math.random(),g=math.random(),b=math.random()} end


		if ZI.ultimate then
		   if math.random(1,10)==1 then BroodHumans(zilla, 2) end end
		
		if effect and (effect=='defender_capsules' or effect=='all_buff') then 
			local ent = {'destroyer','defender'}
			if math.random(3)==1 then zilla.surface.create_entity{name=ent[math.random(#ent)],  position=zilla.position,target=zilla,force=zilla.force} end
			end
		if effect and (effect=='grenade_launcher' or effect=='all_buff') and math.random(5)==1 then
			local d=35
			if effect=='all_buff' then d=60 end
			local enemy = zilla.surface.find_nearest_enemy{position=zilla.position, max_distance=d, force=zilla.force} --zilla.force
			if enemy and enemy.valid and enemy.name~='entity-ghost' and enemy.type~='entity-ghost' and enemy.destructible and enemy.health then
				local weap = {'explosive-rocket','grenade'}
				if ZI.ultimate then table.insert(weap,'mf-small-atomic-rocket') table.insert(weap,'cluster-grenade') end
				zilla.surface.create_entity{name=weap[math.random(#weap)], target=enemy, position=zilla.position, force=zilla.force, speed=0.4}
				end
		end	
		
	if ZI.spider and zilla.valid then
		if game.tick % (tick_zillas*4) == 0 then Spidertron_Moves(zilla, ZI) end
		if zilla.valid then bm_spider_fallback_fire(zilla, ZI) end
		end
		
	end
end
	
end)



script.on_nth_tick(60*3, function (event)

	if #storage.next_wave>0 and storage.next_wave[1].tick < game.tick  then 
		Call_next_wave(storage.next_wave[1])
		table.remove(storage.next_wave,1)
		end

for k=#storage.bm_volcano,1,-1 do
	local V=storage.bm_volcano[k]
	local volcano = V.volcano
	local tick  = V.tiltick
	if volcano and volcano.valid then
		local pos = volcano.position
		pos.y=pos.y-4
		volcano.surface.pollute(pos,75)
		volcano.surface.create_trivial_smoke{name='fire-smoke-on-adding-fuel', position=pos} 
		volcano.surface.create_trivial_smoke{name='turbine-smoke', position=pos}


		if game.tick > tick then
			volcano.die()
			table.remove(storage.bm_volcano,k)
			else -- erupt!!!
			
			if prototypes.entity["big-demolisher-fissure-explosion"] then 
				volcano.surface.create_entity{name="big-demolisher-fissure-explosion", position=pos, force = game.forces.enemy}
				else
				volcano.surface.create_entity{name="big-artillery-explosion", position=pos, force = game.forces.enemy}
				end
			local area = 50
			local xx = pos.x + math.random(-area,area) 		
			local yy = pos.y + math.random(-area,area) 		
			volcano.surface.create_entity{name ="mf-cluster-fire-projectile-big", target_position={x=xx,y=yy}, position={x=xx,y=yy}, source=pos, force= game.forces.enemy, speed=4, move_stuck_players=true}
			end
		else
		table.remove(storage.bm_volcano,k)
		end
	end
end)


function create_volcano(surface, target, pcount)
local duration = (60 * 60) + ((pcount + storage.difficulty_level) * 60 * 20)
local volcano
local position = surface.find_non_colliding_position("bm-volcano", target, 200, 1)
	if position ~= nil then
		surface.create_entity{name="nuke-explosion", position=position, force = game.forces.enemy} --big-artillery-explosion
		volcano = surface.create_entity{name="bm-volcano", position=position, force = game.forces.enemy}
		if prototypes.entity["big-demolisher-fissure-explosion"] then 
			surface.create_entity{name="big-demolisher-fissure-explosion", position=position, force = game.forces.enemy}
			end
		table.insert(storage.bm_volcano, {volcano=volcano, tiltick=game.tick + duration})
		end
return volcano
end


--------------------------------------------------------------------------
function create_bigworm(surface,target,pcount,evo)
local worm = "maf-behemoth-worm-turret"  
if evo > 0.80 then worm = "maf-colossal-worm-turret" end
if evo > 0.9 then 
	if math.random(1,2)==1 then worm = "maf-worm-boss-fire-shooter" else worm = "bm-worm-boss-acid-shooter" end
	end

local qt = math.min(4, 1 + math.floor(pcount/4)) + storage.difficulty_level - 1
local the_worm
for x=1,qt do
	local position = surface.find_non_colliding_position(worm, target, 150, 1)
	if position then
		create_remnants_particles (surface, math.random(30,60) , position) 
		the_worm = surface.create_entity{name=worm, position= position, force= game.forces.enemy}
		table.insert (storage.other_enemies,the_worm )
		end
	end
	
-- normal worms for reinforced attack
if pcount>2 then 
	local qt = math.min(25, math.max(1,math.ceil(evo * 12 + math.random(math.ceil(pcount/2))))) + storage.difficulty_level - 1
	CallWormAttack(surface,target,qt,0,20)
	end
	
return the_worm
end


-- Paranoidal: the children are units of a nest near the mother (Rampant factions, Bob, vanilla), vanilla biters if
-- there is none. Unit lists are prototype data: cached per nest and evolution step (same on every peer).
local brood_nest_query = {type = "unit-spawner", force = nil, position = nil, radius = 160, limit = 1}
local brood_units = {}
local function brood_children(mother, evo)
	brood_nest_query.force = mother.force
	brood_nest_query.position = mother.position
	local nests = mother.surface.find_entities_filtered(brood_nest_query)
	local nest = nests[1] and nests[1].name or ""
	local step = math.floor(evo * 20)
	local key = nest .. ":" .. step
	local list = brood_units[key]
	if not list then
		-- from the step, not the exact evolution: a peer that fills its cache later gets the same list
		local stepEvo = step / 20
		list = {}
		if nest ~= "" then list = get_units_for_evolution(stepEvo, nil, {nest}) end
		if #list == 0 then list = get_units_for_evolution(stepEvo, nil, storage.vanilla_biter_spawners) end
		brood_units[key] = list
		end
	return list
end

function Brood(mother)
local x = mother.position.x
local y = mother.position.y 
local r = 10
if mother.surface.count_entities_filtered({force=mother.force, area={{x-r,y-r},{x+r,y+r}}, limit=51}) > 50 then return end
local Min = 2
local Max = 6
local num = math.random(Min,Max) + storage.difficulty_level - 1

local group
if mother.commandable and mother.commandable.parent_group then group=mother.commandable.parent_group end
local children = brood_children(mother, get_evo_here(mother.surface))
if #children == 0 then return end
for k=1,num do
	local name= children[math.random(#children)]
	local pos = mother.surface.find_non_colliding_position(name, mother.position, 10, 1)
		if pos then 
			mother.surface.create_entity{name="bm-acid-splash-fire", position=pos, force = mother.force}
			local child = mother.surface.create_entity{name=name, position=pos, force = mother.force}
			if group and child and child.valid then group.add_member(child) end
			end
	end
end


function BroodHumans(mother, extra)
extra=extra or 0
local x = mother.position.x
local y = mother.position.y 
local r = 10
local max_units = 5 + storage.difficulty_level + extra*3
if mother.surface.count_entities_filtered({type="unit", force= mother.force, area={{x-r,y-r},{x+r,y+r}}, limit=max_units+1}) > max_units then return end
local num = math.random(3+ extra)  + storage.difficulty_level - 1

local group
if mother.commandable and mother.commandable.parent_group then group=mother.commandable.parent_group end
for k=1,num do
	local name= get_random_human_soldier( get_evo_here(mother.surface),mother.surface )
	local pos = mother.surface.find_non_colliding_position(name, mother.position, 15, 1)
		if pos then 
			local child = mother.surface.create_entity{name=name, position=pos, force = mother.force}
			if group and child and child.valid then group.add_member(child) end
			end
	end
end


--------------------------------------------------------------------------------------


local function create_rocks(entity,quant)
local rocks = {'big-rock','huge-rock','big-sand-rock'}
entity.surface.create_entity{name='huge-rock', position=entity.position, force = game.forces.neutral}	
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
script.on_event(defines.events.on_entity_died, On_Remove, filters)



function On_Built(event)
local entity = event.created_entity or event.entity 
if entity and entity.valid and entity.type~='entity-ghost' then
	local surface = entity.surface
--	local name=entity.name 
	table.insert (storage.rocket_silos,entity)
	if storage.enable_silo_attack and not bm_peaceful_skip(surface) and bm_target_allowed(surface, entity.force) then CallFrenzyAttack(surface,entity,nil,1.5) end
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
local surface = ent.surface
if ent.type=='tree' and in_list(storage.surfaces, surface.name)  then
	if math.random()<=storage.tree_events_chance then
		local the_event=pick_event({'biterzilla','volcano',"spidertron", "demolisher", "flying_saucer","soldiers"})
		if the_event then 
			local pforce = player.force
			Create_Position_Event(the_event, surface, ent.position, pforce)	
			end
		end
	end
end
local filters = {{filter = "type", type = "tree"}}
script.on_event(defines.events.on_player_mined_entity, player_mined_entity, filters) 





script.on_event(defines.events.on_surface_created, function(event)
if storage.spawn_on_sa_planets then 
local surface_index=event.surface_index
local surface=game.surfaces[surface_index]
if in_list(storage.allowed_planets, surface.name) then
	remote.call( "bigmonster", "add_surface", surface.name)
	end
end
end)








-- warptorio
function on_warptorio_warp(event)
storage.surfaces = {}
local newsurface = event.newsurface
local planet     = event.newplanet
if planet and newsurface then 
	local flags      = planet.flags
	if (not flags) or (not in_list(flags,"rest")) then
		add_list(storage.surfaces, newsurface.name)
		end
	end
end



-- player body abduction mod
function on_corpse_feasted(event)
local corpse=event.corpse
local attack=event.attack_target
if corpse and corpse.valid and attack and attack.valid then 
	local evo = get_evo_here(corpse.surface)
	local surface = corpse.surface
	---if corpse.get_item_count("rocket-launcher")>0 then 
	if storage.chances.biterzilla.min_evo<=evo and math.random(100) <= storage.chances.biterzilla.chance*2 then
		local pforce
		if corpse.character_corpse_player_index and game.players[corpse.character_corpse_player_index] and game.players[corpse.character_corpse_player_index].valid then 
			pforce = game.players[corpse.character_corpse_player_index].force
			end
		local boss_name=get_random_boss_human_soldier() 
		local position = surface.find_non_colliding_position(boss_name, corpse.position, 30, 1)
		if not position then return end
		local boss = surface.create_entity{name=boss_name, position=position, force = game.forces.enemy}
		if not (boss and boss.valid) then return end
		boss.ai_settings.allow_destroy_when_commands_fail=false 
		table.insert (storage.biterzillas, {entity=boss})
		if pforce then 
			alert_force(pforce,{"bm-txt-biterzilla"})
			Play_sound_alert(pforce,3)
			end
		else
		local humie = get_random_human_soldier(evo,surface)
		local position = surface.find_non_colliding_position(humie, corpse.position, 30, 1)
		if position then surface.create_entity{name=humie, position= position, force= game.forces.enemy} end
		end
end
end


function RegisterModEvents()
if remote.interfaces["warptorio2"] then 
  local warp_event = remote.call("warptorio2","get_event", "on_post_warp")
  script.on_event(warp_event, function(event)
    on_warptorio_warp(event)
  end)	
end


if remote.interfaces["PlayerBodyAbduction"] then 
  local pba_event = remote.call("PlayerBodyAbduction", "get_on_corpse_feasted")
  script.on_event(pba_event, function(event)
    on_corpse_feasted(event)
  end)	
end
end




--------------------------------------------------------------------------------------


-- INTERFACE
	
--------------------------------------------------------------------------------------

local interface = {}


function interface.destroy_all()
storage.invasions = {}
	
for _, zilla in pairs(storage.biterzillas) do
	if zilla.entity.valid then
		zilla.entity.destroy()
	end
end
storage.biterzillas = {}

for k=#storage.bm_volcano,1,-1 do
	local V=storage.bm_volcano[k]
	local volcano = V.volcano
	if volcano and volcano.valid then volcano.destroy() end 
	end
storage.bm_volcano = {}

for _, e in pairs(storage.other_enemies) do if e and e.valid then e.destroy() end end 
storage.other_enemies = {}
end

local event_names = {'biterzilla','soldiers','worms','volcano','invasion','gleba_invaders','swarm','spidertron','demolisher','flying_saucer','ultimate_boss'} 

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
if surfacename then del_list(storage.surfaces, surfacename) end
end

function interface.add_surface(surfacename)
if surfacename then add_list(storage.surfaces, surfacename) end
end

-- exclude / include player forces to be targeted
function interface.exclude_player_force(forcename)
if forcename then del_list(storage.player_forces, forcename) end
end

function interface.add_player_force(forcename)
if forcename then add_list(storage.player_forces, forcename) end
end

function interface.add_planet(planet_name)
if planet_name then add_list(storage.allowed_planets, planet_name) end
end

function interface.remove_planet(planet_name)
if planet_name then del_list(storage.allowed_planets, planet_name) end
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
 /c remote.call( "bigmonster", "create_event", "gleba_invaders")
 /c remote.call( "bigmonster", "create_event", "swarm")
 /c remote.call( "bigmonster", "create_event", "spidertron")
 /c remote.call( "bigmonster", "create_event", "demolisher") 
 /c remote.call( "bigmonster", "create_event", "flying_saucer")

 /c remote.call( "bigmonster", "create_event", "ultimate_boss")


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


include/remove SA planet name
/c remote.call( "bigmonster", "add_planet", planet_name)
/c remote.call( "bigmonster", "remove_planet", planet_name)


include player force to be targeted
/c remote.call( "bigmonster","add_player_force",forcename)
exclude player force to be targeted
/c remote.call( "bigmonster","exclude_player_force",forcename)

destroy all mod enemies
/c remote.call( "bigmonster","destroy_all")
]]


