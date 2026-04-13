
function Log(what)
helpers.write_file("mf_log.log", serpent.block(what), true)
end


function glow_on_entity(entity, scale, tint)
local render = rendering.draw_sprite{
        sprite = "mf_glow",
        target = entity,
        surface = entity.surface,
        tint = tint or {r = 1, g = 1, b = 1},
        x_scale = scale,
        y_scale = scale,
        render_layer = "radius-visualization",
        --time_to_live = length,
      }
end


-- Create a random direction vector to look in
function GetRandomVector(v)
v=v or 3
    local randVec = {x=0,y=0}   
    while ((randVec.x == 0) and (randVec.y == 0)) do
        randVec.x = math.random(-v,v)
        randVec.y = math.random(-v,v)
    end
    return randVec
end


function safe_vehicle_teleport(vehicle,surface,position)
if vehicle.valid and in_list({"car","spider-vehicle"},vehicle.type) then
local pos = surface.find_non_colliding_position(vehicle.name, position, 50, 1) --zero was freezing game if no tiles 
if pos then vehicle.teleport(pos, surface) else vehicle.teleport(position, surface) end
end
end


function safe_player_teleport(player,surface,position)
local pos = surface.find_non_colliding_position("character", position, 50, 1) --zero was freezing game if no tiles 
if pos then player.teleport(pos, surface) else player.teleport(position, surface) end
end

function get_gps_tag(position,surface)
	local r = '[gps='..math.floor(position.x)..','..math.floor(position.y)
	if surface then r=r..','..surface.name end
	r=r..']'
	return r	
	end
	

function get_localised_name(name,ico_first)
local lname = ''
local ico = ''
if prototypes.item[name]   then lname = prototypes.item[name].localised_name ico='[img=item/'..name..']'
 elseif prototypes.equipment[name] then lname = prototypes.equipment[name].localised_name  ico='[img=item/'..name..']' 
 elseif prototypes.fluid[name]  then lname = prototypes.fluid[name].localised_name  ico='[img=fluid/'..name..']'  
 elseif prototypes.entity[name] then lname = prototypes.entity[name].localised_name ico='[img=entity/'..name..']' 
 elseif prototypes.space_location[name] then lname = prototypes.space_location[name].localised_name ico='[space-location='..name..']' 
end


if not ico_first then
	return  lname, ico
	else return ico, lname end
end

function get_localized_name(name) -- just until all mods fix this typo
return get_localised_name(name)
end	


function check_container_for_items(container,items)
local has_all =true
for k=1,#items do 
	if container.get_item_count(items[k].name)<items[k].count then has_all=false break end
	end
return has_all 		
end


function remove_items_from_container(container,items)
for k=1,#items do 
	container.remove_item(items[k])
	end	
end


function check_container_for_items_pay_part(container,items)
local paid_all =true
local paid=0
for k=#items,1,-1 do
	local has = container.get_item_count(items[k].name)
	local count = items[k].count 
	local removed = container.remove_item(items[k])
	paid = paid + removed
	if removed==count then
		table.remove(items,k)
		else
		paid_all=false 
		if removed>0 then 
			paid = paid + removed
			items[k].count = items[k].count - removed
			end		
		end
	end
return paid_all, paid
end


function clear_chest(chest, inventory_type)
if not inventory_type then inventory_type=defines.inventory.chest end
local inv = chest.get_inventory(inventory_type)
if inv then inv.clear() end
end

function transfer_inventory_loose (entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    if inv_a then
        local contents = inv_a.get_contents()
        for _, stack in pairs(contents) do
            entity_b.insert(stack)
        end
    end
end

function transfer_quipment_grid_from_entities(entity_a, entity_b)
local grid_a = entity_a.grid
local grid_b = entity_b.grid
local t
if grid_a and grid_b then
	t=0
	local eq = grid_a.equipment
	for x=1,#eq do 
		local e=eq[x]
		local pos = e.position
		local name= e.name
		local added = grid_b.put{name=name, position=pos}
		if added then 
			t=t+1
			if e.type=='battery-equipment' then added.energy = e.energy end
			if e.type=='energy-shield-equipment' then added.shield = e.shield end
			grid_a.take{equipment=e}
			end
		end
	end
return t
end


function transfer_inventory (entity_a, entity_b, inventory_type, inventory_type_b, filters)
local tqt = 0
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type_b or inventory_type)
    if inv_a and inv_b then
        local contents = inv_a.get_contents()
        for _, stack in pairs(contents) do
            if (not filters) or (in_list(filters, stack.name)) then
				local qt = inv_b.insert(stack)
				tqt = tqt + qt
				if qt>0 then inv_a.remove({name=stack.name, count=qt, quality=stack.quality}) end
				end
        end
    end
return tqt	
end


function transfer_fluid (entity_a, entity_b)
local fluids = entity_a.get_fluid_contents()
local name,amt,name_b
for n,a in pairs (fluids) do
	name=n
	amt=a
	break
	end
local fluids_b = entity_b.get_fluid_contents()
for n,a in pairs (fluids_b) do
	name_b=n
	break
	end
local transfered=0
if name and amt and ((not name_b) or name==name_b) then
	entity_b.remove_fluid{name=name,amount=transfered}
	transfered = entity_b.insert_fluid({name=name,amount=amt})
	entity_a.remove_fluid{name=name,amount=transfered}
	end

return name, transfered	
end






function GetPositionAtDistance(surface,from,distance,name)
local pX, pY, position
for t=1,20 do 
	local x = math.random(distance, distance*2)
	local y = math.random(distance, distance*2)
	if math.random(2)==1 then x=x*-1 end
	if math.random(2)==1 then y=y*-1 end
	pX = from.x+x
	pY = from.y+y
	position = surface.find_non_colliding_position(name, {x=pX,y=pY}, distance, 1)
	if position~=nil then break end
end

return position
end


function get_players_near_position(surface,pos,howfar)
local pls={}
	for p, player in pairs(game.connected_players) do
		if player and player.valid and player.character and player.character.valid and surface==player.character.surface then
			if distance(pos,player.character.position)<=howfar then table.insert(pls,player) end
			end
	end
return pls
end


function get_players_near_object(object,howfar,force)
local pls={}
if object and object.valid then
	for p, player in pairs(game.connected_players) do
		if player and player.valid and player.character and player.character.valid and object.surface==player.character.surface then
			if distance(object.position,player.character.position)<=howfar then 
				if (not force) or (force==player.force) then table.insert(pls,player) end
				end
			end
		end
	end
return pls
end

function get_pos_near_enemy_nest(surface,spawn,pforce)
	local enemy = surface.find_nearest_enemy{position=spawn, max_distance=500, force=pforce}
	if enemy then
		local f = enemy.force
		local nests = surface.find_entities_filtered{type='unit-spawner', position=enemy.position, radius=300, force=f, limit=5}
		if #nests>0 then 
			spawn = get_random_pos_near(nests[math.random(#nests)].position,30)
			spawn = surface.find_non_colliding_position('assembling-machine-1', spawn, 0, 1)
			end
		end
return spawn 
end




--- @class FlyingTextOptions
--- @field color Color?
--- @field position MapPosition?
--- @field sound LuaPlayer.play_sound_param?

--- @param player LuaPlayer
--- @param text LocalisedString
--- @param options FlyingTextOptions?
function flying_text_with_sound(player, text, options)
  options = options or {}
  options.sound = options.sound or { path = "utility/cannot_build" }
  player.create_local_flying_text({
    color = options.color,
    create_at_cursor = not options.position,
    position = options.position,
    text = text,
  })
  player.play_sound(options.sound)
end


function entity_flying_text(entity, text, color,time_to_live)
if not color then color=colors.lightred end
rendering.draw_text{text=text,use_rich_text=true,color = color, surface=entity.surface, time_to_live=time_to_live or 80,
		target={entity=entity, offset={-2+math.random()*4,-3 + math.random()*2}}} 
end

function surface_flying_text(surface, position, text, options)
 options = options or {}
  options.sound = options.sound or "utility/cannot_build"
  options.color = options.color or colors.lightred
  rendering.draw_text{text=text,use_rich_text=true,color = options.color, surface=surface, time_to_live=options.time_to_live or 80,
  target=position} 
  surface.play_sound{path=options.sound, position=position}
end




function create_things_around(surface,things,how_many, position,radius, force)
local ents={}
for x=1,how_many do 
	local name = things[math.random(#things)]
	local p = surface.find_non_colliding_position(name, get_random_pos_near(position,radius),radius,2)
	if p then 
		local e = surface.create_entity{name=name, position=p, force=force}
		table.insert(ents,e)
		end
	end
if #ents>0 then return ents	end
end


function count_players_on_surface(surface, force)
local look_on = force or game
local c = 0
for _,p in pairs (look_on.connected_players) do
	if p.character and p.character.valid and surface==p.character.surface then c = c +1 end
	end
return c
end




function prepare_spidertron(spider,ammo)
if ammo then spider.insert(ammo) end
if script.active_mods['Krastorio2'] or script.active_mods['Krastorio2-spaced-out'] then spider.insert{name='kr-dt-fuel-cell', count=5} end
end


function validate_cost_items(list) --validate item list
for i=1,#list do 
	if (not prototypes.item[list[i].name]) or 
		list[i].name=="lithium" then 
		return false end
	end
return true
end




-- Give XP to team - RPGSystem
function GrantXP(forcename,XP)
	if remote.interfaces["RPG"] then
		remote.call("RPG","TeamXP",forcename,XP)
		end
end
function GrantXPPerc(forcename,XPPerc)
	if remote.interfaces["RPG"] then
		remote.call("RPG","TeamXPPerc",forcename,XPPerc)
		end
end
	
	

function forbidden_construction_give_back_item(event, message, color)
	if not color then color=colors.lightred end
	local entity = event.entity
		if entity.type=='entity-ghost' or entity.type=='tile-ghost' then return end
	
		if event.name==defines.events.script_raised_built and entity.name=="rsc-silo-stage2" then 
			entity.surface.spill_item_stack{position=entity.position,stack={name="rsc-excavation-site"}, enable_looted=false}
			if message then mf_print(entity.force,message,color) end
	
		elseif event.robot then 
			if event.stack then entity.surface.spill_item_stack{position=entity.position, stack=event.stack, enable_looted=false} end
			
		elseif event.consumed_items and event.player_index then --and event.stack.valid_for_read
			local contents = event.consumed_items.get_contents()   --name	:: string	count	quality	:: QualityID	
			local player=game.players[event.player_index]
			for _,stack in pairs(contents) do
				if player.character and player.character.valid then
					player.insert(stack)
					else
					entity.surface.spill_item_stack{position=entity.position, stack=stack, enable_looted=false}
					end
				end
			if message then	mf_print(player,message,color) end
			end
	if entity.valid then entity.destroy() end			
	end


function mf_print(to_who,message, color, icon)
icon=icon or ""	
message={"", icon, "[font=default-large-bold]", message, "[/font]"}
to_who.print(message,{color=color})
end	


function alert_force_with_sound(force, text, sound, color, icon)
force.play_sound{path=sound or 'mf_sound_alert'}
mf_print(force,text, color or colors.lightred, icon)
end



function translate_element_icon(element_icon, make_it_a_tag)
	if element_icon then
		local icon
		local name 
		local typ   
	if element_icon.type and element_icon.type=='virtual' then 
			name=element_icon.name
			typ="virtual"
			icon ='virtual-signal/'..element_icon.name 
		elseif element_icon.type then 
			name=element_icon.name
			typ=element_icon.type
			icon =element_icon.type..'/'..element_icon.name 
		elseif element_icon.name then
			name=element_icon.name
			typ="item"			
			icon ='item/'..element_icon.name
		else
			name=element_icon
			typ="item"				
			icon ='item/'..element_icon
		end
	if make_it_a_tag then 
		return {type=typ,name=name, quality=element_icon.quality}
		else return icon
		end
	end
	end


--based on evolution factor
function Get_XP_ratio(base)
	local progress = math.ceil(game.forces.enemy.get_evolution_factor()*100)
	return math.ceil(base * progress)
	end






function add_gui_text_list_for_items(tab_gui, items) --requires a tab with 3 columns
for a=1,#items do 
	local n, i = get_localized_name(items[a].name)
	tab_gui.add{type="label", caption=format_number(items[a].count)}
	tab_gui.add{type="label", caption=i}
	tab_gui.add{type="label", caption=n}
	end
end

function get_text_list_for_required_items(items)
	local List = {""}
	local sublist ={""}
	local count = 0
	for a=1,#items do 
		count=count+1
		local n, i = get_localised_name(items[a].name)
		concat_lists (List, {'\n' .. items[a].count .. i .. ' ',n})
	if count>8 then  -- more then 20 crashes the game
		table.insert (sublist,List)
		List = {""}
		count=0
		end	
	end
	if #items>8 then 
		if #sublist>1 then table.insert (sublist,List) end
		return sublist 
	else return List end
end

function get_icons_values_for_required_items_indexed(items)
local txt = ''
for name, count in pairs(items) do
	txt=txt.. count .. '[item='..name ..']' 
	end
return txt
end
function get_icons_values_for_required_items(items)
local txt = ''
for a=1,#items do 
	txt=txt.. items[a].count .. '[item='..items[a].name ..']' 
    if a<#items then txt=txt..',' end 
	end
return txt
end

function GetRandonRepairItems(force,nitems,add_this,always_add_this,mp,cap_stack)
	local function add_recipe(force,item,items) 
	if force.recipes[item] and force.recipes[item].enabled then table.insert(items,item) end
	end
if not mp then mp=1 end
if not nitems then nitems=4 end
local items = {} 
local list = {"repair-pack","copper-cable","iron-gear-wheel","electronic-circuit","stone-brick","pipe","steel-plate","iron-stick",
			"engine-unit",'plastic-bar','concrete','advanced-circuit','processing-unit','battery',"low-density-structure",  
			-- modded items
			'warponium-plate',
			'stone-tablet','iron-beam','motor','glass','electric-motor','silicon',
			--IR3
			'copper-pipe','copper-repair-tool','bronze-repair-tool','steel-repair-tool','copper-beam','copper-gear-wheel','tin-gear-wheel','copper-piston','iron-piston',
			'iron-plate-heavy','gold-cable','gold-foil','lead-plate-special','carbon-foil','chromium-rod','chromium-piston','chromium-plate-heavy','chromium-window',
			--EI
			'ei_insulated-wire','ei_steel-machanical-parts','ei_copper-beam','ei_copper-machanical-parts','ei_iron-beam','ei_iron-machanical-parts',
			'ei_gold-plate','ei_lead-plate','ei_glass','ei_ceramic',
			--K2
			'kr-imersium-plate','kr-ai-core','kr-automation-core','kr-electronic-components','kr-steel-gear-wheel', 'kr-steel-beam','kr-energy-control-unit',
			--SA
			"lithium-plate", "carbon-fiber", "tungsten-plate", "supercapacitor"
			}
for k=1,#list do add_recipe(force,list[k],items) end
if add_this then for a=1,#add_this do table.insert(items,add_this[a]) end end
local repairs = {}
for a=1,nitems do	
	local quant= math.ceil(math.random(100, 300) * mp)
	local it = math.random(#items)
	if cap_stack then quant = math.min(quant, prototypes.item[items[it]].stack_size) end 
	table.insert(repairs, {name=items[it], count=quant})
	table.remove(items, it)
	if #items<1 then break end
	end
if always_add_this then  for a=1,#always_add_this do table.insert(repairs, always_add_this[a]) end end

return repairs, get_icons_values_for_required_items(repairs), get_text_list_for_required_items(repairs)
end


function get_the_nearest_entity(entities,position)
if #entities>0 then 
local ent=entities[1]
local dist=distance(ent.position, position)
for _,e in pairs(entities) do 
    if distance(e.position, position)<dist then 
		ent=e
		dist = distance(ent.position, position)
		end
	end
return ent, dist
end
end



function entity_shock_hazard(entity,radius,quant,anything)
if entity and entity.valid then 
local enemy 
if anything then
	enemy = entity.surface.find_entities_filtered{position=entity.position, radius=radius}
	else
	enemy = entity.surface.find_enemy_units(entity.position, radius, entity.force)
	end
for k=#enemy,1,-1 do 
	if (not enemy[k].destructible) then table.remove(enemy,k) end
	end
if #enemy>0 then
for x=1,quant do
	local target = enemy[math.random(#enemy)]
	if entity and entity.valid and target and target.valid and target.destructible and target.health and target.health>0 then
		entity.surface.create_entity{name = 'electric-beam', position=entity.position, source = entity ,target=target.position, duration=40}
		end
	end
end
end
end


function surface_spill_stack_list (surface,position,stack_list, loot, force)
for _,stack in pairs (stack_list) do
	surface.spill_item_stack{position=position, stack=stack, enable_looted=loot, force=force}
	end
end


function spill_items_from_container(entity,define_inventory)
local inv = entity.get_inventory(define_inventory) 
    if inv and inv.valid then 
	for i = 1, #inv do
		local stack = inv[i]
		if stack and stack.valid and stack.valid_for_read then 
			entity.surface.spill_item_stack{position=entity.position, stack=stack, enable_looted=true, force=entity.force}
			end
		end
	end
end

function secure_destroy_spill_items(entity,define_inventory)
spill_items_from_container(entity,define_inventory)
entity.destroy()
end


function safe_build(name,surface,position,force)
local pos = surface.find_non_colliding_position(name, position, 0, 1)
if pos then
	return surface.create_entity{name = name, position = pos, force=force} 
end
end




function get_SA_space_locations(planet_only)
local names={}
local text={}
for location, space_location in pairs (prototypes.space_location) do
	if not space_location.hidden then
	if (not planet_only) or game.planets[location] then
	table.insert(names, location)
	table.insert(text,  {"","[space-location=" .. location.."]",space_location.localised_name}) -- 
	end	end end
return names,text
end






-- about_tiles  = {remove_tiles={}, replace_tiles={original=replace_for}, holes=0.1(%))
-- about_entity = {non_minable_all=true,indestructible_all=true,indestructibles[name]=true,non_minables[name]=true,replace_entities={original=replace_for}}
function mf_build_blueprint (blueprint, surface, center,force,direction,about_tiles,about_entity,noerrorlog,check_terrain)
local replaced = {}
local all_ents = {}
local bp = surface.create_entity({name="item-on-ground",position=center,force=force,stack={name="blueprint"}})
	if bp == nil then
		if not noerrorlog then game.print("Failed to create blueprint at " .. center.x .. " , " .. center.y) end
		return
	end
if bp.stack.import_stack(blueprint) ~= 0 then
   if not noerrorlog then game.print('ERROR Loading blueprint string!') end
   return
   end
local ghosts, retry
local tiles_to_correct = {}
for t=1,2 do
		ghosts = bp.stack.build_blueprint{
		surface=surface,
		force=force,
		position=center,
		build_mode =defines.build_mode.superforced,
		direction=direction,
		skip_fog_of_war=false
		}
		if #ghosts <1 then 
			if not noerrorlog then game.print('ERROR Building blueprint: No ghosts') end
			--return
			elseif check_terrain and t==1 then
				for _,g in pairs (ghosts) do 
					if g.type=="tile-ghost" then  ---places a landfill on water etc	
						if surface.get_tile(g.position.x, g.position.y).collides_with("is_object") then 
							table.insert(tiles_to_correct,{name = 'landfill', position=g.position})
							retry=true
							end
						end
					end
			end

		if retry and t==1 then 
			for _,g in pairs (ghosts) do g.destroy() end 
			surface.set_tiles(tiles_to_correct)	
		else break 
		end
		
		end --retry
	
	--priority - rails
	local ordered_ghosts = {}
	for g=#ghosts,1,-1 do 
		if not (ghosts[g] and ghosts[g].valid) then 
			table.remove(ghosts,g)
			elseif ghosts[g].ghost_name=='straight-rail' then 
			table.insert (ordered_ghosts,ghosts[g])
			table.remove(ghosts,g)
			end 
		end
		
	concat_lists(ordered_ghosts, ghosts)
	
	
	-- REvive ghosts
	for k,v in pairs(ordered_ghosts) do
		if v.valid then
			if about_tiles then
				if about_tiles.holes and about_tiles.holes[v.ghost_name] then if math.random()<about_tiles.holes[v.ghost_name] then v.destroy() end end
				if v and v.valid and about_tiles.remove_tiles and in_list(about_tiles.remove_tiles, v.ghost_name) then v.destroy() end
				if v and v.valid and about_tiles.replace_tiles and  about_tiles.replace_tiles[v.ghost_name] then 
					local p = v.position
					local n = v.ghost_name
					v.destroy()
					surface.set_tiles({{name = about_tiles.replace_tiles[n], position=p}})
					end
				end
			


			if v.valid then 
				local res,en=v.revive()
				if not res then
				for _,e in pairs(surface.find_entities_filtered{
					area=v.bounding_box,
					name=v.name,
					invert=true
					}) do e.destroy() end
					if v.revive()==nil then 
						if not noerrorlog then game.print('ERROR Could not revive blueprint ghost') end
						end
				else
				
				
				if en and en.valid and about_entity then
					if about_entity.replace_entities and about_entity.replace_entities[en.name] then 
						local p = en.position
						local n = en.name
						en.destroy()
						en = surface.create_entity({name=about_entity.replace_entities[n], position=p, force = force})
						table.insert (replaced, en)
						else
						table.insert (all_ents, en)
						end
					if about_entity.non_minable_all or (about_entity.non_minables and about_entity.non_minables[en.name]) then en.minable=false end
					if about_entity.indestructible_all or (about_entity.indestructibles and about_entity.indestructibles[en.name]) then en.destructible=false end
					end				
				
				end
				end
			end
		end	
bp.destroy()	
return replaced, all_ents
end




function create_resource_near_entity(entity,area,resource, increase_amount)
local surface = entity.surface
local empty = {}
local same_ore = {}
local tiles = surface.find_tiles_filtered{area = area}
for _,tile in pairs(tiles) do 
	if not Area.inside(entity.bounding_box, tile.position) then
		local ore = surface.find_entities_filtered{type="resource",position={x=tile.position.x+0.5,y=tile.position.y+0.5} ,radius=0.5}  
		if #ore==0 then table.insert(empty,tile.position) elseif ore[1].name==resource then table.insert(same_ore,ore[1]) end
		end
	end
if #empty>0 then 
	local pos = empty[math.random(#empty)]
	local new_o = surface.create_entity({name=resource, position=pos, amount=increase_amount + math.random(10)})
	create_stone_particles(surface, 25, new_o.position)
elseif #same_ore>0 then
	local ore = same_ore[math.random(#same_ore)]
	ore.amount=ore.amount+increase_amount + math.random(10)
	create_stone_particles(surface, 25, ore.position)
end
end
