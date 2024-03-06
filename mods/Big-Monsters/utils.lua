local format_time   = util.formattime
function format_time_from_tick(ThatTick)
  if game.tick > ThatTick then return format_time(game.tick-ThatTick)
  else return format_time(ThatTick - game.tick)
  end
end



-- Get a random 1 or -1
function RandomNegPos()
    if (math.random(0,1) == 1) then
        return 1
    else
        return -1
    end
end


-- Create a random direction vector to look in
function GetRandomVector()
    local randVec = {x=0,y=0}   
    while ((randVec.x == 0) and (randVec.y == 0)) do
        randVec.x = math.random(-3,3)
        randVec.y = math.random(-3,3)
    end
    return randVec
end



-- Find random coordinates within a given distance away
-- maxTries is the recursion limit basically.
function FindUngeneratedCoordinates(minDistChunks, maxDistChunks, surface)
    local position = {x=0,y=0}
    local chunkPos = {x=0,y=0}

    local maxTries = 100
    local tryCounter = 0

    local minDistSqr = minDistChunks^2
    local maxDistSqr = maxDistChunks^2

    while(true) do
        chunkPos.x = math.random(0,maxDistChunks) * RandomNegPos()
        chunkPos.y = math.random(0,maxDistChunks) * RandomNegPos()

        local distSqrd = chunkPos.x^2 + chunkPos.y^2

        -- Enforce a max number of tries
        tryCounter = tryCounter + 1
        if (tryCounter > maxTries) then
            DebugPrint("FindUngeneratedCoordinates - Max Tries Hit!")
            break
 
        -- Check that the distance is within the min,max specified
        elseif ((distSqrd < minDistSqr) or (distSqrd > maxDistSqr)) then
            -- Keep searching!
        
        -- Check there are no generated chunks in a 10x10 area.
        elseif IsChunkAreaUngenerated(chunkPos, 5, surface) then
            position.x = (chunkPos.x*32) + (32/2)
            position.y = (chunkPos.y*32) + (32/2)
            break -- SUCCESS
        end       
    end

    return position
end


function make_composite_icon_rb(icon1, tint1, icon2, tint2)
return {
	{icon=icon1,icon_size = 64, icon_mipmaps = 4, tint=tint1},
	{icon=icon2,icon_size = 64, icon_mipmaps = 4, tint=tint2,priority="medium",shift={8,8},scale=0.3}}
end

function safe_player_teleport(player,surface,position)
local pos = surface.find_non_colliding_position("character", position, 0, 2)
player.teleport(pos, surface) 
end

function get_localized_name(name)
local lname = ''
if game.item_prototypes[name]   then lname = game.item_prototypes[name].localised_name
 elseif game.equipment_prototypes[name]    then lname = game.equipment_prototypes[name].localised_name  
 elseif game.entity_prototypes[name] then lname = game.entity_prototypes[name].localised_name end
return  lname 
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


function getDayTimeString(player)
 local daytime = player.surface.daytime + 0.5
 local dayminutes = math.floor(daytime * 24 * 60) % 60
 local dayhour = math.floor(daytime * 24 ) % 24
return string.format("%02d:%02d", dayhour, dayminutes)
end







function tech_has_prereq(force,tech)
local valid = not force.technologies[tech].researched
local pre = game.technology_prototypes[tech].prerequisites

if valid then	
for k,req in pairs (pre) do
    if not force.technologies[req.name].researched then 
		valid=false
		break
		end
	end end
return valid
end
-- get all avalilable techs for force
function get_techs_available_for_force(force)
local available = {}
for name,tech in pairs (force.technologies) do
	if tech.enabled and tech_has_prereq(force,name) then table.insert(available,name) end
	end
return available
end



function get_tech_level(force,techname,lastlevel)
local level = 0
for t=lastlevel,1,-1 do
    if force.technologies[techname..'-'..t].researched then 
		level = t
		break
		end
	end
return level
end



function format_evolution(force)
 return string.format("%.2f", math.floor(force.evolution_factor * 1000) / 10)
end


function  getPlanetTemperature(surface)
local avg_temp=0
local c=0
local temp
	for chunk in surface.get_chunks() do
		c=c+1
		local position = {x=chunk.x * 32, y=chunk.y * 32}
		temp = surface.calculate_tile_properties({'temperature'},{position})
		avg_temp = avg_temp + temp.temperature[1]
		end
return avg_temp/c
end

function  getTemperatureAtEntity(entity)
local temp
if entity and entity.valid then temp = entity.surface.calculate_tile_properties({'temperature'},{entity.position}).temperature[1] end
return temp
end

function transfer_inventory_loose (entity_a, entity_b, inventory_type)
    local inv_a = entity_a.get_inventory(inventory_type)
    if inv_a then
        local contents = inv_a.get_contents()
        for item_type, item_count in pairs(contents) do
            entity_b.insert({name=item_type, count=item_count})
        end
    end
end

function transfer_inventory (entity_a, entity_b, inventory_type, inventory_type_b, filters)
local tqt = 0
    local inv_a = entity_a.get_inventory(inventory_type)
    local inv_b = entity_b.get_inventory(inventory_type_b or inventory_type)
    if inv_a and inv_b then
        local contents = inv_a.get_contents()
        for item_type, item_count in pairs(contents) do
            if (not filters) or (in_list(filters, item_type)) then
				local qt = inv_b.insert({name=item_type, count=item_count})
				tqt = tqt + qt
				if qt>0 then inv_a.remove({name=item_type, count=qt}) end
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





function get_gps_tag(position,surface)
local r = '[gps='..math.floor(position.x)..','..math.floor(position.y)
if surface then r=r..','..surface.name end
r=r..']'
return r	
end


function Log(what)
game.write_file("big_monster.log", serpent.block(what), true)
end

function dLog(what)
log(serpent.block(what))
end


function to_table(pos_arr)
    if #pos_arr == 2 then
        return { x = pos_arr[1], y = pos_arr[2] }
    end
    return pos_arr
end

function distance_squared(pos1, pos2)
    pos1 = to_table(pos1)
    pos2 = to_table(pos2)
    local axbx = pos1.x - pos2.x
    local ayby = pos1.y - pos2.y
    return axbx * axbx + ayby * ayby
end


--------------------------------------------------------------------------------------
function square_area( origin, radius )
	return {
		{x=origin.x - radius, y=origin.y - radius},
		{x=origin.x + radius, y=origin.y + radius}
	}
end

function get_area_center(area)
local x1 = area.left_top.x
local y1 = area.left_top.y
local x2 = area.right_bottom.x
local y2 = area.right_bottom.y
return {x= math.floor(x1 + x2) /2,y= math.floor(y1 + y2) /2}
end

-- Get an area given a position and distance.
-- Square length = 2x distance
function GetAreaAroundPos(pos, dist)

    return {left_top=
                    {x=pos.x-dist,
                     y=pos.y-dist},
            right_bottom=
                    {x=pos.x+dist,
                     y=pos.y+dist}}
end


function create_retangle_area(pos,hight,width,adjust_w,adjust_h)
local h = math.ceil(hight/2)
local w = math.ceil(width/2)
adjust_w = adjust_w or 0
adjust_h = adjust_h or 0
    return {left_top=
                    {x=pos.x-w + adjust_w,
                     y=pos.y-h + adjust_h},
            right_bottom=
                    {x=pos.x+w,
                     y=pos.y+h}}
end


function get_random_pos_near(pos,dist)
return {x=pos.x+math.random(-dist,dist),y=pos.y+math.random(-dist,dist)}
end

--------------------------------------------------------------------------------------
function distance( pos1, pos2 )
	local dx = pos2.x - pos1.x
	local dy = pos2.y - pos1.y
	return( math.sqrt(dx*dx+dy*dy) )
end

--------------------------------------------------------------------------------------
function distance_square( pos1, pos2 )
	return( math.max(math.abs(pos2.x - pos1.x),math.abs(pos2.y - pos1.y)) )
end

--------------------------------------------------------------------------------------
function pos_offset( pos, offset )
	return { x=pos.x + offset.x, y=pos.y + offset.y }
end

--------------------------------------------------------------------------------------
function surface_area(surf)
	local x1, y1, x2, y2 = 0,0,0,0
	
	for chunk in surf.get_chunks() do
		if chunk.x < x1 then
			x1 = chunk.x
		elseif chunk.x > x2 then
			x2 = chunk.x
		end
		if chunk.y < y1 then
			y1 = chunk.y
		elseif chunk.y > y2 then
			y2 = chunk.y
		end
	end
	
	return( {{x1*32-8,y1*32-8},{x2*32+40,y2*32+40}} )
end

--------------------------------------------------------------------------------------
function iif( cond, val1, val2 )
	if cond then
		return val1
	else
		return val2
	end
end


--for k,v in Sort_a_Table(your_table, function(t,a,b) return t[b] > t[a] end) do
function Sort_a_Table(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

--------------------------------------------------------------------------------------
function add_list(list, obj)
	-- to avoid duplicates...
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			return(false)
		end
	end
	table.insert(list,obj)
	return(true)
end

--------------------------------------------------------------------------------------
function del_list(list, obj)
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			table.remove( list, i )
			return(true)
		end
	end
	return(false)
end

--------------------------------------------------------------------------------------
function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return(k)
		end
	end
	return(nil)
end

--------------------------------------------------------------------------------------
function size_list(list)
	local n = 0
	for i in pairs(list) do
		n = n + 1
	end
	return(n)
end

--------------------------------------------------------------------------------------
function concat_lists(list1, list2)
	-- add list2 into list1 , do not avoid duplicates...
	for i, obj in pairs(list2) do
		table.insert(list1,obj)
	end
end

function concat_lists_no_dup(list1, list2)
	-- add list2 into list1 , Avoiding duplicates...
	for i, obj in pairs(list2) do
		add_list(list1,obj)
	end
end


function add_technology_prerequisite(technology, prerequisite)
if not data.raw.technology[technology].prerequisites then data.raw.technology[technology].prerequisites={} end
if not in_list(data.raw.technology[technology].prerequisites, prerequisite) then
	table.insert(data.raw.technology[technology].prerequisites,prerequisite)
	end
end

function add_recipe_unlock(technology, recipe)
  if data.raw.technology[technology] and data.raw.recipe[recipe] then
    local addit = true
    if not data.raw.technology[technology].effects then
      data.raw.technology[technology].effects = {}
    end
    for i, effect in pairs(data.raw.technology[technology].effects) do
      if effect.type == "unlock-recipe" and effect.recipe == recipe then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].effects,{type = "unlock-recipe", recipe = recipe}) end
  else
    if not data.raw.technology[technology] then
      log("Technology " .. technology .. " does not exist.")
    end
    if not data.raw.recipe[recipe] then
      log("Recipe " .. recipe .. " does not exist.")
    end
  end
end

function update_science_pack_amount(technology, amount)
  if data.raw.technology[technology] then
	local new ={}	
	for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
		table.insert (new,{ingredient[1], ingredient[2] + amount})
    end
	data.raw.technology[technology].unit.ingredients = new
	end
end

function add_new_science_pack(technology, pack, amount)
  if data.raw.technology[technology] and data.raw.tool[pack] then
    local addit = true
    for i, ingredient in pairs(data.raw.technology[technology].unit.ingredients) do
      if ingredient[1] == pack or ingredient.name == pack then addit = false end
    end
    if addit then table.insert(data.raw.technology[technology].unit.ingredients,{pack, amount}) end
  else
    if not data.raw.technology[technology] then
      log("Technology " .. technology .. " does not exist.")
    end
    if not data.raw.tool[pack] then
      log("Science pack " .. new .. " does not exist.")
    end
  end
end




function FindUnchartedChunk(surface, MinDist,MaxDist)
local X1=0
local X2=0
local Y1=0
local Y2=0

	for chunk in surface.get_chunks() do
		local X,Y = chunk.x, chunk.y
		if game.forces["player"].is_chunk_charted(surface,({X,Y})) then
			if X<X1 then X1=X end
			if X>X2 then X2=X end
			if Y<Y1 then Y1=Y end
			if Y>Y2 then Y2=Y end
			end
	end

	
 local dX1 = MinDist*-1
 local dX2 = MinDist
 local dY1 = MinDist*-1
 local dY2 = MinDist
 
 if X1*-1>=MinDist then dX1 = X1 -1 end
 if X2>=MinDist then dX2 = 1 + X2 end
 if Y1*-1>=MinDist then dY1 = Y1-1 end
 if Y2>=MinDist then dY2 = 1 + Y2 end
 
 
 local Max = MaxDist
 
 
local t 
local novoX
local novoY

  for a=1,100 do
	t = math.random(1,4)

	if t==1 then  
		if Max<dX1*-1 then Max=1 end
		novoX=math.random(dX1-Max,dX1) 
		novoY=math.random(dY1-Max,dY2+Max)
	elseif t==2 then 	
		if Max<dX2 then Max=1 end
		novoX=math.random(dX2,dX2+Max) 
		novoY=math.random(dY1-Max,dY2+Max)
	elseif t==3 then		
		if Max<dY1*-1 then Max=1 end
		novoY=math.random(dY1-Max,dY1) 
		novoX=math.random(dX1-Max,dX2+Max)
	elseif t==4 then
		if Max<dY2 then Max=1 end
		novoY=math.random(dY2,dY2+Max) 
		novoX=math.random(dX1-Max,dX2+Max)
	end
	--game.forces.player.print("tentativa " .. a)
	if surface.is_chunk_generated({novoX,novoY}) then break end
   end --for
 
if not surface.is_chunk_generated({novoX,novoY}) then
   surface.request_to_generate_chunks({novoX*32+15,novoY*32+15}, 1)
--   game.print("requesting to generate at " .. novoX .. ',' .. novoY)
   end
   
 --game.print("retornando chunk " .. novoX .. ',' .. novoY)  
 return {x=novoX,y=novoY}
	
end		  



--try to find a randon charted chunk 100 times. If not. return an uncharted, but requested chunck
function FindRandomChunk(surface,MinDist,MaxDist)

local X_Min = MinDist
local X_Max = MaxDist
local Y_Min = MinDist
local Y_Max = MaxDist

local X,Y
  for a=1,100 do
	X=math.random(X_Min, X_Max)
	Y=math.random(Y_Min, Y_Max)
	if math.random(0,1)==0 then X=X-1 end
	if math.random(0,1)==0 then Y=Y-1 end
	if surface.is_chunk_generated({X,Y}) then break end
   end 

if not surface.is_chunk_generated({X,Y}) then
    surface.request_to_generate_chunks({X*32+15,Y*32+15}, 1)
	surface.force_generate_chunk_requests()
--    game.forces.player.print("requesting to generate at " .. X .. ',' .. Y)
	end

return {x=X,y=Y}
 
end


function fire_item_projectile(item,from,to,target_position)
local projectile_name = 'projectile_item_'..item
if from and from.valid and game.entity_prototypes[projectile_name] then
        local proj = from.surface.create_entity{
            name = projectile_name,
            position = from.position,
            target = to,
			target_position=target_position,
            speed = 0.02 } --0.2
		if not proj then game.print('invalid') end	
	end
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
		if player and player.valid and player.character and player.character.valid and surface==player.surface then
			if distance(pos,player.position)<=howfar then table.insert(pls,player) end
			end
	end
return pls
end
function get_players_near_object(object,howfar,force)
local pls={}
if object and object.valid then
	for p, player in pairs(game.connected_players) do
		if player and player.valid and player.character and player.character.valid and object.surface==player.surface then
			if distance(object.position,player.position)<=howfar then 
				if (not force) or (force==player.force) then table.insert(pls,player) end
				end
			end
		end
	end
return pls
end


function unit_attack_target(unit,target)
unit.set_command({type = defines.command.attack,distraction = defines.distraction.by_enemy, target = target,
				pathfind_flags = {use_cache = false, low_priority=true, allow_destroy_friendly_entities=false}})
end
function unit_go_to(unit,destination)
local command = {type = defines.command.go_to_location, destination_entity = destination,
				pathfind_flags = {use_cache = false, low_priority=true, allow_destroy_friendly_entities=false},
				distraction = defines.distraction.none
				}
unit.set_command(command)			
end				
function unit_go_to_loc(unit,destination)
local command = {type = defines.command.go_to_location, destination  = destination,
				pathfind_flags = {use_cache = true, low_priority=true, allow_destroy_friendly_entities=false},
				distraction = defines.distraction.by_enemy
				}
unit.set_command(command)			
end	
	
	
function get_worms_for_evolution(evolution, extra_evo, surface, position)
if not evolution then evolution = game.forces.enemy.evolution_factor end
local filter = {{filter = "type",type = "turret"},{filter = "build-base-evolution-requirement", comparison = "≤", value = evolution, mode = "and"}} 
local worms_p = game.get_filtered_entity_prototypes(filter)
local worms = {}

--check temperature 
local temp 
if surface and position then 
	temp = surface.calculate_tile_properties({'temperature'},{position})
	temp = temp.temperature[1]
	end

for name,proto in pairs (worms_p) do 
	if not string.find(name, "boss") then 
		if proto.build_base_evolution_requirement ~= nil then
			local add = true
			if temp then if (string.find(name, "cold") and temp>10) or (string.find(name, "explosive") and temp<40) then add=false end end
			if string.find(name, "kr-") or string.find(name, "RTPrimer") then add=false end -- krastorio fake worms 
			if not (string.find(name, "worm")) then add=false end
			if add then table.insert(worms,name) end
			end 
		end
	end

local strong_worms = {}

if extra_evo then 
	local filter = {{filter = "type",type = "turret"},{filter = "build-base-evolution-requirement", comparison = "≤", value = evolution+extra_evo, mode = "and"},
		{filter = "build-base-evolution-requirement", comparison = "≥", value = evolution, mode = "and"}}
	local worms_p = game.get_filtered_entity_prototypes(filter)
	for name,proto in pairs (worms_p) do 
		if not string.find(name, "boss") then 
		if proto.build_base_evolution_requirement ~= nil then 
			local add = true
			if temp then if (string.find(name, "cold") and temp>10) or (string.find(name, "explosive") and temp<40) then add=false end end
			if string.find(name, "kr-") or string.find(name, "RTPrimer") then add=false end -- krastorio and RenaiTransportation fake worms 
			if not (string.find(name, "worm")) then add=false end
			if add then table.insert(strong_worms,name) end
			end 
		end
		end
	end
return worms,strong_worms
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
end
end



function get_units_for_evolution(evolution,extra_evo)
if not evolution then evolution = game.forces.enemy.evolution_factor end
local filter = {{filter = "type", type = "unit-spawner"}}
local spawners = game.get_filtered_entity_prototypes(filter)
local unit_names = {}
local strong_units = {} -- for extra strong ones

	for name,proto in pairs (spawners) do
		if not (string.find(name, "protomolecule") or string.find(name, "boss") or string.find(name, "entity-proxy") ) then 
			for Y,RU in pairs (proto.result_units) do
				local uname = RU.unit
				local SP = RU['spawn_points']
				if not in_list(unit_names,uname) and game.entity_prototypes[uname] and game.entity_prototypes[uname].type=='unit' then 
					local emin = SP[1]['evolution_factor']
					local emax = SP[#SP]['evolution_factor']
					if SP[#SP]['weight']>0 then emax=2 end	
					if evolution>=emin and evolution<emax then				
						table.insert(unit_names, uname)
						end
						
					if extra_evo and evolution+extra_evo>=emin and evolution+extra_evo<emax then
						table.insert(strong_units, uname)
						end
						
					end
				end
			end
		end
return unit_names,strong_units
end	







local is_sprite = function(array)
  return array.width and array.height and (array.filename or array.stripes or array.filenames)
end

function hack_tint(array, tint)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite(v)  then
        v.tint = tint
      end
      hack_tint(v, tint)
    end
  end
end


 
function hack_scale(array, scale)
  for k, v in pairs (array) do
    if type(v) == "table" then
      if is_sprite(v) then
        v.scale = (v.scale or 1) * scale
        if v.shift then
          v.shift[1], v.shift[2] = v.shift[1] * scale, v.shift[2] * scale
        end
      end
      if v.source_offset then
        v.source_offset[1] = v.source_offset[1] * scale
        v.source_offset[2] = v.source_offset[2] * scale
      end
      if v.projectile_center then
        v.projectile_center[1] = v.projectile_center[1] * scale
        v.projectile_center[2] = v.projectile_center[2] * scale
      end
      if v.projectile_creation_distance then
        v.projectile_creation_distance = v.projectile_creation_distance * scale
      end
      hack_scale(v, scale)
    end
  end
end

  
function scale_box(box, scale)
  box[1][1] = box[1][1] * scale
  box[1][2] = box[1][2] * scale
  box[2][1] = box[2][1] * scale
  box[2][2] = box[2][2] * scale
  return box
end
