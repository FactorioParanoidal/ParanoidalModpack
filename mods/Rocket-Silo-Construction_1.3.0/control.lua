require("util")
require("utils")
require("particles")
local ticks_1_s  =    60

-- CUSTOM EVENT HANDLING --
-- if your mod creates the stage 1 construction site via script, you should add the "raise_built=true" to your create_entity, so here
-- it will fire the script_raised_built event
-- A custom event is raised upon each finished construction stage, named "on_silo_stage_finished"
--(remote interface is lower in the file, there I describe how to subscribe to my event)
local on_silo_stage_finished = script.generate_event_name() --uint  returns event.created_entity



function ModSetup()
if global.rsc_silo_under_construction==nil then global.rsc_silo_under_construction={} end
global.automated_forces = global.automated_forces or {}
global.st_insert_material_work = settings.startup["rsc-st-work-for-insert-material"].value
global.st_remove_stone_work    = settings.startup["rsc-st-work-for-remove-stone"].value
global.st_not_removable_silo   = settings.startup["rsc-st-not-removable-silo"].value
global.st_not_removable_site   = settings.startup["rsc-st-not-removable-site"].value
global.st_dont_place_tiles     = settings.startup["rsc-st-dont-place-tiles"].value
global.st_enable_se_cargo = false
global.st_enable_se_probe = false
if settings.startup["rsc-st-enable-se-cargo-silo"] then global.st_enable_se_cargo =settings.startup["rsc-st-enable-se-cargo-silo"].value end
if settings.startup["rsc-st-enable-se-probe-silo"] then global.st_enable_se_probe =settings.startup["rsc-st-enable-se-probe-silo"].value end


for f=1, #game.forces do
	local force = game.forces[f]
	if force and force.technologies then 
		if force.technologies['rocket-silo'] and force.technologies['rocket-silo'].researched then 
			force.recipes['rsc-excavation-site'].enabled = true
			end
		if force.technologies['se-rocket-launch-pad'] and force.technologies['se-rocket-launch-pad'].researched then 
			if global.st_enable_se_cargo then force.recipes['rsc-serlp-excavation-site'].enabled=true end
			force.recipes['se-rocket-launch-pad'].enabled = not global.st_enable_se_cargo
			end
		if force.technologies['se-space-probe'] and force.technologies['se-space-probe'].researched then 
			if global.st_enable_se_probe then force.recipes['rsc-sesprs-excavation-site'].enabled=true end
			force.recipes['se-space-probe-rocket-silo'].enabled = not global.st_enable_se_probe
			end
		end
	end
end


function On_Init() 
ModSetup()
end

function on_configuration_changed(data)
ModSetup()
end
script.on_configuration_changed(on_configuration_changed)
script.on_init(On_Init)



local function FillWith(surface,position,area,withwhat)
if (not global.st_dont_place_tiles) and (not remote.interfaces["warptorio2"]) then
if remote.interfaces["space-exploration"] then 
	local Zone = remote.call("space-exploration", "get_zone_from_name", {zone_name = surface.name})
	if Zone then 
		local zone_index = Zone.index
		local is_space = remote.call("space-exploration", "get_zone_is_space", {zone_index = zone_index})
		if is_space then return end
		end
	end

local solo = {}

	local X = position.x
	local Y = position.y
	
	local x1,x2 = X-area , X+area
	local y1,y2 = Y-area , Y+area
	for y=y1,y2 do
		for x=x1,x2 do
		table.insert(solo, {name=withwhat, position={x=x, y=y}}) 
		end
	end

if #solo>0 then
	surface.set_tiles(solo)
	end
end	
end


local function CallFrenzyAttack(target)
if (target and target.valid) then 
	if target.surface.map_gen_settings and target.surface.map_gen_settings.autoplace_controls and 
		target.surface.map_gen_settings.autoplace_controls["enemy-base"] and target.surface.map_gen_settings.autoplace_controls["enemy-base"].size>0 then
		local Min = 30
		local Max = 50
		local Dist = 400
		local aliens = math.random(Min,Max)
		local spawn = target.surface.find_entities_filtered({type = "unit-spawner",limit=1,position=target.position, radius=Dist})
		if #spawn>0 then
			local force = spawn[1].force
			local sent = target.surface.set_multi_command({
					command = {type=defines.command.attack_area, destination=target.position, radius=50, distraction = defines.distraction.by_anything },
					unit_count = aliens,
					force = force,
					unit_search_distance = Dist,
				})
			end
	end
end
end



function upgrade_construction_site(silo_data)

local silo=silo_data.silo
if silo and silo.valid then

local name=silo.name
local upgrade_to
local last_user = silo.last_user
local final_building = 'rocket-silo'  -- default

if silo_data.final_building ~= nil then final_building=silo_data.final_building end

local work = global.st_insert_material_work
local position=silo.position
local surface=silo.surface
local force=silo.force

if name=='rsc-silo-stage1'       then upgrade_to='rsc-silo-stage2' 
  elseif name=='rsc-silo-stage2' then upgrade_to='rsc-silo-stage3'  work = global.st_remove_stone_work
  elseif name=='rsc-silo-stage3' then upgrade_to='rsc-silo-stage4'  FillWith(surface,position,5,'concrete') 
  elseif name=='rsc-silo-stage4' then upgrade_to='rsc-silo-stage5' 
  elseif name=='rsc-silo-stage5' then upgrade_to='rsc-silo-stage6'  FillWith(surface,position,6,'concrete') FillWith(surface,position,5,'refined-hazard-concrete-left') 
  elseif name=='rsc-silo-stage6' then upgrade_to=final_building 

  elseif name=='rsc-silo-stage1-serlp' then upgrade_to='rsc-silo-stage2-serlp' 
  elseif name=='rsc-silo-stage2-serlp' then upgrade_to='rsc-silo-stage3-serlp'  work = global.st_remove_stone_work
  elseif name=='rsc-silo-stage3-serlp' then upgrade_to='rsc-silo-stage4-serlp'  FillWith(surface,position,6,'concrete') 
  elseif name=='rsc-silo-stage4-serlp' then upgrade_to='rsc-silo-stage5-serlp' 
  elseif name=='rsc-silo-stage5-serlp' then upgrade_to='rsc-silo-stage6-serlp' FillWith(surface,position,7,'concrete') FillWith(surface,position,6,'refined-hazard-concrete-left') 
  elseif name=='rsc-silo-stage6-serlp' then upgrade_to=final_building 

  elseif name=='rsc-silo-stage1-sesprs' then upgrade_to='rsc-silo-stage2-sesprs' 
  elseif name=='rsc-silo-stage2-sesprs' then upgrade_to='rsc-silo-stage3-sesprs'  work = global.st_remove_stone_work
  elseif name=='rsc-silo-stage3-sesprs' then upgrade_to='rsc-silo-stage4-sesprs' 
  elseif name=='rsc-silo-stage4-sesprs' then upgrade_to='rsc-silo-stage5-sesprs' 
  elseif name=='rsc-silo-stage5-sesprs' then upgrade_to='rsc-silo-stage6-sesprs' 
  elseif name=='rsc-silo-stage6-sesprs' then upgrade_to=final_building end


silo.destroy()
local new_stage = surface.create_entity{name = upgrade_to, position = position, force=force, raise_built=true}
if math.random(0,1)==0 then CallFrenzyAttack(new_stage) end

if last_user then new_stage.last_user = last_user end

if  upgrade_to~=final_building then 
	local silo_data = {silo=new_stage,bar_back=nil,progress_bar=nil,work_value=work,final_building=final_building}
	table.insert (global.rsc_silo_under_construction,silo_data)
	check_construction_site(silo_data)
	if global.st_not_removable_site then new_stage.minable=false end
	else
	if global.st_not_removable_silo then new_stage.minable=false end
	end

	
script.raise_event(on_silo_stage_finished, {created_entity = new_stage})
end
end




function check_construction_site(silo_data)
local entity=silo_data.silo
local progress=entity.products_finished 
local max_progress=silo_data.work_value

if progress>=max_progress then 
	entity.active  = false
	if entity.get_output_inventory().get_item_count()<1 or in_list(global.automated_forces,entity.force.name) then
		upgrade_construction_site(silo_data) 
		return 
		end
		
	end

local visible_to
if not in_list(global.automated_forces,entity.force.name) then visible_to = {entity.force} end
	

local background = silo_data.bar_back
  if not background then
    background = rendering.draw_line
    {
      color = {r = 1, b = 1, g = 1},
      width = 10,
      from = entity,
      from_offset = {-33/32, 1},
      to = entity,
      to_offset = {33/32, 1},
      surface = entity.surface,
      forces = visible_to
    }
    silo_data.bar_back = background
  end

  local progress_bar = silo_data.progress_bar
  if not progress_bar then
    progress_bar = rendering.draw_line
    {
      color = {r = 0, g = 1, b = 0},
      width = 8,
      from = entity,
      from_offset = {-1, 1},
      to = entity,
      to_offset = {1, 1},
      surface = entity.surface,
      forces = visible_to
    }
    silo_data.progress_bar = progress_bar
  end
  rendering.set_to(silo_data.progress_bar, entity, {(2 * (progress / max_progress)) - 1, 1})

if (entity.is_crafting() and entity.crafting_progress>0 and entity.crafting_progress<1) or (not visible_to)  then 
if (entity.energy>0 or (not visible_to)) then
	if (string.find(entity.name, 'stage1') or string.find(entity.name, 'stage3')) then 
		if math.random(5)==1 then create_remnants_particles(entity.surface, 8 + math.random(20), get_random_pos_near(entity.position,3),2) 
		elseif math.random(3)==1 then create_stone_particles(entity.surface, 8 + math.random(30), get_random_pos_near(entity.position,3),2) end
		end
	for x=1,2 do 
		local p = get_random_pos_near(entity.position,2)
		entity.surface.create_trivial_smoke{name='fire-smoke-on-adding-fuel', position=p} 
		entity.surface.create_trivial_smoke{name='turbine-smoke', position=p} 
		end
	end
	end
end

script.on_nth_tick(ticks_1_s, function (event)
		
	for k, silo_data in pairs (global.rsc_silo_under_construction) do 
		local silo = silo_data.silo
		if silo and silo.valid then 
			check_construction_site(silo_data)
			else
			table.remove (global.rsc_silo_under_construction,k)
			end
		end
end)


function On_Built(event)
local ent = event.created_entity
if not ent then ent = event.entity end
local sufix = ''
if ent and ent.valid then
if string.sub(ent.name,1,15) == 'rsc-silo-stage1' then
	local surface = ent.surface
	local final_building = 'rocket-silo'
	local work_value=global.st_remove_stone_work
	if ent.name == 'rsc-silo-stage1-serlp' then final_building = 'se-rocket-launch-pad'  sufix='-serlp'
	   elseif ent.name == 'rsc-silo-stage1-sesprs' then final_building = 'se-space-probe-rocket-silo'  sufix='-sesprs'
	   end
	
	-- if space explorarion mod present - if in orbit, then construction starts in stage 4 - no excavation required
	if remote.interfaces["space-exploration"] then
		local Zone = remote.call("space-exploration", "get_zone_from_name", {zone_name = surface.name})
		if Zone then 
			local zone_index = Zone.index
			local is_space = remote.call("space-exploration", "get_zone_is_space", {zone_index = zone_index})
			if is_space then
				local position = ent.position
				local force=ent.force
				local player_index=event.player_index
				ent.destroy()
				local stage4 = 'rsc-silo-stage4' .. sufix
				ent=surface.create_entity{name=stage4, force=force, position = position, raise_built=true}
				if player_index then ent.last_user = game.players[player_index] end
				work_value=global.st_insert_material_work	
				end
			end
	end

	local silo_data = 
		{
		silo=ent,
		bar_back=nil,
		progress_bar=nil,
		work_value=work_value,
		final_building=final_building
		}
	table.insert (global.rsc_silo_under_construction,silo_data)
	check_construction_site(silo_data)
	if global.st_not_removable_site then ent.minable=false end
	end
end
end
--local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built}
local filters = {{filter = "name", name = "rsc-silo-stage1"}, {filter = "name", name = "rsc-silo-stage1-serlp"}, {filter = "name", name = "rsc-silo-stage1-sesprs"}}
script.on_event(defines.events.on_built_entity, On_Built, filters) 
script.on_event(defines.events.on_robot_built_entity, On_Built, filters) 
script.on_event(defines.events.script_raised_built, On_Built,filters) 
script.on_event(defines.events.script_raised_revive, On_Built,filters)





function on_entity_cloned(event)
local destination = event.destination
local list = {}

if string.sub(destination.name,1,14)=='rsc-silo-stage' then
	for k,silo_data in pairs (global.rsc_silo_under_construction) do
		if silo_data.silo == event.source then
		   global.rsc_silo_under_construction[k].silo = destination
		   global.rsc_silo_under_construction[k].bar_back=nil
		   global.rsc_silo_under_construction[k].progress_bar=nil
		   break
		   end
		end
	end
end
script.on_event(defines.events.on_entity_cloned, on_entity_cloned)




local function upgrade_silos_now(force_name)
local tabcopy = table.deepcopy(global.rsc_silo_under_construction)
local force 
if force_name then force = game.forces[force_name] end

	for k, silo_data in pairs (tabcopy) do 
	if (not force_name) or (force and silo_data.silo.force == force) then 
		upgrade_construction_site(silo_data)
		end
	end
end




-- INTERFACE  --
--------------------------------------------------------------------------------------
local interface = {}

-- /c remote.call("RocketSiloCon","UpgradeConstruction")
function interface.UpgradeConstruction()
upgrade_silos_now()
end
-- /c remote.call("RocketSiloCon","UpgradeForceConstruction","player")
function interface.UpgradeForceConstruction(force_name)
upgrade_silos_now(force_name)
end

function interface.add_automated_force(force_name)
add_list(global.automated_forces, force_name)
end



--[[ HOW TO subscribe to my custom event:
	script.on_event(remote.call("RocketSiloCon", "get_on_silo_stage_finished"), function(event)
		--do your stuff
	end)
	WARNING: this has to be done within on_init and on_load, otherwise the game will error about the remote.call
	returns {created_entity = new_stage}
	
	if your dependency on my mod is optional, remember to check if the remote interface exists before calling it:
	if remote.interfaces["RocketSiloCon"] then
		--interface exists
	end]]

function interface.get_on_silo_stage_finished()
return on_silo_stage_finished
end
		-- Returns :
		-- event.created_entity = The new entity created (next stage building)

remote.add_interface("RocketSiloCon", interface )