
function count_force_players_in_surface(force, surface)
local c=0
if surface and surface.valid then 
	for _,pl in pairs(force.players) do
		if pl.character and pl.character.valid and pl.character.surface==surface then c=c+1 end
	end
	end
return c
end

function  getPlanetTempAuxMoist(surface)
	local avg_temp=0
	local avg_aux=0
	local avg_moist=0
	local c=0
	local stat
		for chunk in surface.get_chunks() do
			c=c+1
			local position = {x=chunk.x * 32, y=chunk.y * 32}
			stat = surface.calculate_tile_properties({"temperature","aux","moisture"},{position})
			if stat.temperature then avg_temp = avg_temp + stat.temperature[1] end 
			if stat.aux then avg_aux = avg_aux + stat.aux[1] end 
			if stat.moisture then avg_moist = avg_moist + stat.moisture[1] end 
			if c>6 then break end  --heavy processing  - limited to 6
			end
	return avg_temp/c, avg_aux/c, avg_moist/c
	end



function  getPlanetTemperature(surface)
	local avg_temp=0
	local c=0
	local temp
		for chunk in surface.get_chunks() do
			c=c+1
			local position = {x=chunk.x * 32, y=chunk.y * 32}
			temp = surface.calculate_tile_properties({'temperature'},{position})
			if temp.temperature then avg_temp = avg_temp + temp.temperature[1] end  --heavy processing  - limited to 6
			if c>6 then break end
			end
	return avg_temp/c
	end
	
function  getTemperatureAtEntity(entity)
	local t
	if entity and entity.valid then 
		local temp = entity.surface.calculate_tile_properties({'temperature'},{entity.position})
		if temp.temperature then t = temp.temperature[1] end
		end
	return temp
end
	

function GetLocalAux(surface,position)
	local aux
	local calc = surface.calculate_tile_properties({'aux'},{position}) 
	if calc and calc.aux then
		aux = calc.aux[1] end
	return aux
	end	
		
function GetLocalTemp(surface,position)
	local temp 
	local calc = surface.calculate_tile_properties({'temperature'},{position})
	if calc and calc.temperature then
		temp = calc.temperature[1] end
	return temp
end	



-- Function to find random coordinates to a given direction
function FindRandomDistantChunk(initial_position, chunk_distance)
local directionVec = GetRandomVector()
if not initial_position then  initial_position = {x=0,y=0} end
local ini_chunk = Chunk.from_position(initial_position)
local chunkPos = Chunk.from_position(initial_position)
    -- Keep going in the direction of the vector
while distance(ini_chunk,chunkPos)<chunk_distance do
	chunkPos.x = chunkPos.x + directionVec.x
	chunkPos.y = chunkPos.y + directionVec.y
	end
return chunkPos
end


function get_tiles_positions(tiles)
	local positions = {}
	for _, tile in pairs(tiles) do
		table.insert(positions, tile.position)
	end
	return positions
end

function get_chunk_area_tiles(chunk)
local area = Chunk.to_area(chunk)
area = {left_top=area.left_top,right_bottom={x=area.right_bottom.x-1,y=area.right_bottom.y-1}}
return area
end


function chunk_has_tiles(surface,chunk,diff_from)
local area = get_chunk_area_tiles(chunk)
local tiles = surface.find_tiles_filtered{area=area,name=diff_from or "out-of-map",invert=true, limit=1}
return #tiles>0
end



-- Function to find empty chunk with out-of-map in a random or given direction
-- min_chunk_distance = distance from last occupied
-- return_pos: boolean - want a return in position *32
-- returns chunk
function FindOutOfMapPlace(surface, initial_position, min_chunk_distance, directionVec, return_pos, ignore_initial_position)
	directionVec = directionVec or GetRandomVector()
	if not initial_position then  initial_position = {x=0,y=0} end
	local last_occupied
	local new_chunk=  Chunk.from_position(initial_position)
	while chunk_has_tiles(surface,new_chunk) or ignore_initial_position do
		ignore_initial_position=nil
		last_occupied = table.deepcopy(new_chunk)
		while distance(last_occupied,new_chunk)<min_chunk_distance do
			new_chunk.x = new_chunk.x + directionVec.x
			new_chunk.y = new_chunk.y + directionVec.y
			end
		if not (surface.is_chunk_generated(new_chunk)) then
			surface.request_to_generate_chunks(new_chunk,1)
			surface.force_generate_chunk_requests()
			end
		end
	if return_pos then 
		return {x=new_chunk.x*32 + 15,y=new_chunk.y*32 + 15}
	else return new_chunk
	end
end


-- Function to find coordinates of the edge of the map in a random or given direction
-- returns chunks: last_generated, ungenerated
function FindMapEdges(surface, initial_position, min_chunk_distance, max_chunk_distance, directionVec,force_min_generation)
	directionVec = directionVec or GetRandomVector()
	if not initial_position then  initial_position = {x=0,y=0} end
	local ungenerated, last_generated
	local init_chunk = Chunk.from_position(initial_position)
	local chunkPos = Chunk.from_position(initial_position)
	
		if min_chunk_distance then 
			while distance(init_chunk,chunkPos)<min_chunk_distance do
				chunkPos.x = chunkPos.x + directionVec.x
				chunkPos.y = chunkPos.y + directionVec.y
				if (surface.is_chunk_generated(chunkPos)) then last_generated = table.deepcopy(chunkPos) 
					elseif force_min_generation then
					surface.request_to_generate_chunks(chunkPos,1)
					surface.force_generate_chunk_requests()
					last_generated = table.deepcopy(chunkPos)
				end
				end
			end
				
		-- Keep checking chunks in the direction of the vector	
		for x=1, 500 do
			-- If chunk is already generated, keep looking
			if (surface.is_chunk_generated(chunkPos)) then
				last_generated = table.deepcopy(chunkPos)
				chunkPos.x = chunkPos.x + directionVec.x
				chunkPos.y = chunkPos.y + directionVec.y
				
				if max_chunk_distance and distance(init_chunk,chunkPos)>max_chunk_distance-2 then break end
			-- Found a possible ungenerated area
			else 
				ungenerated = chunkPos
				break
			end
		end
		return last_generated, ungenerated
	end
	
	
-- Function to generate a resource patch, of a certain size/amount at a pos.
function GenerateResourcePatch(surface, resourceName, diameter, pos, amount, check_for_tile, circle)
	local res_list = resourceName
	if type(resourceName)=='string' then res_list = {resourceName} end
	local ENABLE_RESOURCE_SHAPE_CIRCLE=math.random(2)==1
	if circle then ENABLE_RESOURCE_SHAPE_CIRCLE=true end
	local t_amount=0
	local midPoint = math.floor(diameter/2)
	if ENABLE_RESOURCE_SHAPE_CIRCLE then pos={x=pos.x-midPoint, y=pos.y-midPoint} end
		for y=0, diameter do
			for x=0, diameter do
				if (not ENABLE_RESOURCE_SHAPE_CIRCLE or ((x-midPoint)^2 + (y-midPoint)^2 < midPoint^2)) then
					local p = {pos.x+x, pos.y+y}
					if (not check_for_tile) or (not surface.get_tile(p).collides_with("water_tile")) then
						local rname = res_list[math.random(#res_list)]
						local ore = surface.create_entity({name=rname, amount=amount,position=p}) 
						t_amount = t_amount + amount
						end
				end
			end
		end
	return t_amount
	end
	

function GenerateOrganicResourcePatch(surface, resourceName, diameter, center_pos, amount, check_for_tile, add_stones)
    local res_list = type(resourceName) == "string" and {resourceName} or resourceName
    local total_amount_created = 0
    local radius = diameter / 2
    
    -- Semente aleatória para o ruído da mancha
    local seed_x = math.random(1000)
    local seed_y = math.random(1000)

    for dy = -radius, radius do
        for dx = -radius, radius do
            local world_x = center_pos.x + dx
            local world_y = center_pos.y + dy
            
            -- 1. Distância normalizada e Ruído
            local distance_from_center = math.sqrt(dx*dx + dy*dy) / radius
            local noise = (
                math.sin((world_x + seed_x) * 0.2) * 0.5 +
                math.sin((world_y + seed_y) * 0.2) * 0.5 +
                math.sin((world_x - world_y) * 0.4) * 0.2
            ) * 0.3

            local threshold = distance_from_center + noise

            -- 2. Se estiver dentro do limite da mancha orgânica
            if threshold < 0.8 then 
                local p = {x = world_x, y = world_y}
                
                if not check_for_tile or not surface.get_tile(p.x, p.y).collides_with("water_tile") then
                    
                    -- 3. Criação do Recurso (Minério)
                    local richness_factor = 1.2 - threshold
                    local final_amount = math.floor(amount * math.max(0.1, richness_factor))
                    
                    local rname = res_list[math.random(#res_list)]
                    local ore = surface.create_entity({
                        name = rname, 
                        amount = final_amount, 
                        position = p
                    })
                    
                    if ore then
                        total_amount_created = total_amount_created + final_amount
                    end

                    -- 4. Distribuição de PEDRAS (add_stones)
                    -- Só acontece se a tabela for passada e estivermos no "coração" da mancha
                    if add_stones and type(add_stones) == "table" and #add_stones > 0 then
                        -- threshold < 0.4 garante que as pedras fiquem no centro, 
                        -- deixando a borda (entre 0.4 e 0.8) limpa.
                        if threshold < 0.4 and math.random() < 0.15 then 
                            local stone_name = add_stones[math.random(#add_stones)]
                            surface.create_entity({
                                name = stone_name,
                                position = p,
                                raise_built = true -- Útil para triggar eventos de outros mods
                            })
                        end
                    end
                end
            end
        end
    end

    return total_amount_created
end


	
function is_this_area_empty(chunk,surface,area_size) 				
local valid = true
for y=(chunk.y*32) + (32/2) - area_size, (chunk.y*32) + (32/2) + area_size do
for x=(chunk.x*32) + (32/2) - area_size, (chunk.x*32) + (32/2) + area_size do
	local p = {x=x,y=y}
	if surface.get_tile(p) and surface.get_tile(p).name~= 'out-of-map' then 
		valid=false
		break
		end
	end
	end
return valid
end
		
		
function FindEmptyPlace(surface, area_size, initial_position, min_chunks, max_tries)
max_tries = max_tries or 500
local directionVec = GetRandomVector()
local position = table.deepcopy(initial_position)
local chunkPos = Chunk.from_position(initial_position)  --{x=0,y=0}  initial_position
 if min_chunks then
    while(true) do
		chunkPos.x = chunkPos.x + directionVec.x
		chunkPos.y = chunkPos.y + directionVec.y
		if distance(chunkPos,Chunk.from_position(initial_position))>=min_chunks then break end
		end
	end

--[[ 
	end]]
	
	local tries = 0
    -- Keep checking chunks in the direction of the vector
    while(true) do
        tries = tries +1    
		
        -- Set some absolute limits.
        if tries > max_tries then
			position.x = (chunkPos.x*32) + (32/2)
            position.y = (chunkPos.y*32) + (32/2)
			break			
		
        -- If chunk is already generated, keep looking
        elseif (not surface.is_chunk_generated(chunkPos)) then
            surface.request_to_generate_chunks(chunkPos,1)
			surface.force_generate_chunk_requests()

        -- Found a possible generated area
        elseif not is_this_area_empty(chunkPos,surface,area_size) then
            chunkPos.x = chunkPos.x + directionVec.x
            chunkPos.y = chunkPos.y + directionVec.y
		
		else 
			position.x = (chunkPos.x*32) + (32/2)
            position.y = (chunkPos.y*32) + (32/2)
           break
        end
		end

	
    return position
	
end
		
	
		
		
--a circle of tiles
function CreateRoundRoom(surface,entrance, centerPos, radius,tiles,border_entity,force,clear_entity)

local area = GetAreaAroundPos (centerPos,radius)
    local tileRadSqr = radius^2

    local place_tiles = {}
	local place_border_entity = {} 
    for i=area.left_top.x,area.right_bottom.x,1 do
        for j=area.left_top.y,area.right_bottom.y,1 do
            -- This ( X^2 + Y^2 ) is used to calculate if something
            -- is inside a circle area.
            local distVar = math.floor((centerPos.x - i)^2 + (centerPos.y - j)^2)
			local p={x=i,y=j}
		
            if (distVar < tileRadSqr) then
				local ti = surface.get_tile(p)
				if ti and ti.valid and ti.name == 'out-of-map' then 
					table.insert(place_tiles, {name = tiles[math.random(#tiles)], position=p})
					if clear_entity then 
						local e = surface.find_entities_filtered{position=p,name=clear_entity}
						for _,ent in pairs (e) do ent.destroy() end
						end
							
					-- Create a circle of entities on borders.
					if border_entity then
						local d = distance(p,centerPos) 
						if d>=radius-1 and d<=radius+1 then
							if (not entrance) or distance(p,entrance)>3 then
								table.insert(place_border_entity,p)
							end
							end
						end					
					end
				end
        end
    end

    surface.set_tiles(place_tiles)
	for _, p in pairs(place_border_entity) do 
		surface.create_entity({name=border_entity[math.random(#border_entity)], position=p, force=force or 'neutral'})
		end
	
return {center=centerPos,size=radius-2}	
end		
		
		

function CreateRectRoom(surface,entrance,direction, size,tiles,border_entity,force,clear_entity,collapse)
local dx=direction.x
local dy=direction.y
local xx=entrance.x
local yy=entrance.y
local width  = math.max(size,9)	
local length = math.random (width-4,width+20)	
local LE = 0
local place_tiles = {}
local last_rock_cap = {}
local previous=0
local place_border_entity = {}

	for L=1, length do
	LE = L
		if L%3==0 then if dx~=0 then yy=yy+math.random(-1,1) else xx=xx+math.random(-1,1)  end end
		last_rock_cap = {}
		if dx~=0 then 
			xx=xx+dx  
			for y=-width,width do 
				local p = {x=xx,y=yy+y}
				if surface.get_tile(p).name == 'out-of-map' then 			
					table.insert(place_tiles, {name = tiles[math.random(#tiles)], position=p})
					--local r = surface.find_entities_filtered{position=p,name=rock_list, limit=1}
					if y==-width or y==width or L==length then table.insert(place_border_entity,p)
						else
						table.insert(last_rock_cap,p)
						end 
					if L==1 then 
						if distance(p,entrance)>3 then table.insert(place_border_entity,p) end
						end
					else 
						if clear_entity then 
							local e = surface.find_entities_filtered{position=p,name=clear_entity}
							for _,ent in pairs (e) do ent.destroy() end
							end					
						previous=previous+1 
					    if (not collapse) and previous > 10 then break  end
					end
				end
			else
			yy=yy+dy			
			for x=-width,width do
				local p = {x=xx+x,y=yy}
				if surface.get_tile(p).name == 'out-of-map' then 			
					table.insert(place_tiles, {name = tiles[math.random(#tiles)], position=p})
					--local r = surface.find_entities_filtered{position=p,name=rock_list, limit=1}
					if x==-width or x==width or L==length then table.insert(place_border_entity,p)
						else
						table.insert(last_rock_cap,p)
						end 
					
					if L==1 then 
						if distance(p,entrance)>3 then table.insert(place_border_entity,p) end
						end
					else
						if clear_entity then 
							local e = surface.find_entities_filtered{position=p,name=clear_entity}
							for _,ent in pairs (e) do ent.destroy() end
							end
					
						previous=previous+1 
					    if (not collapse) and previous > 10 then break  end
						end
				end
			end
		
		if (not collapse) and previous>10 then 
			for c=1,#last_rock_cap do table.insert(place_border_entity,last_rock_cap[c])  end
			break 
			end
		end

surface.set_tiles(place_tiles)

for _, p in pairs(place_border_entity) do 
	surface.create_entity({name=border_entity[math.random(#border_entity)], position=p, force=force or 'neutral'})
	end

local center = {x=math.ceil((xx+entrance.x)/2),y=math.ceil((yy+entrance.y)/2)}
return {center=center,size=math.floor(LE/2)}
end		



	
function AddTile(name,area,surface,entity_in_border, irregular, only_on_tile, avoid_neighbor_tile)
local function tile_check_add(position, land)
	if (not only_on_tile) or (surface.get_tile(position) and surface.get_tile(position).name == only_on_tile) then
		local t_name=name
		if type(name)=="table" then t_name=name[math.random(#name)] end
		if (not avoid_neighbor_tile) or (not is_this_tile_pos_neighboring(surface,position,avoid_neighbor_tile)) then
		table.insert(land, {name=t_name, position=position})
			end
		end
	end

	local land = {}
	local x1,x2, y1,y2
	if area[1] then 
		x1,x2 = area[1].x , area[2].x
		y1,y2 = area[1].y , area[2].y
	else	
		x1,x2 = area.left_top.x , area.right_bottom.x
		y1,y2 = area.left_top.y , area.right_bottom.y		
	end
	
local border = {}	
	
	local dx = 0
	for y=y1,y2 do
		if irregular then dx = dx + math.random(-1,1) end
		for x=x1,x2 do
			if not surface.is_chunk_generated(Chunk.from_position({x=x,y=y})) then
				surface.request_to_generate_chunks(Chunk.from_position({x=x,y=y}),1)
				surface.force_generate_chunk_requests()
				end

			if surface.is_chunk_generated(Chunk.from_position({x=x,y=y})) then
				if irregular then 
					if y==y1 and math.random(2)==1 then 
						local new_p = {x=x+dx, y=y-1}
						if surface.is_chunk_generated(Chunk.from_position(new_p)) then 
							tile_check_add(new_p, land)
							border['x'..x..'x'..y] = {x=x,y=y}
							end
						end
					if y==y2 and math.random(2)==1 then
						local new_p = {x=x+dx, y=y+1}
						if surface.is_chunk_generated(Chunk.from_position(new_p)) then 						
							tile_check_add(new_p, land)
							border['x'..x..'x'..y] = {x=x,y=y}
							end
						end
					end
				if y==y1 or y==y2 or x==x1 or x==x2 then border['x'..x..'x'..y] = {x=x,y=y} end 
				tile_check_add({x=x+dx, y=y}, land)
				end
			end 
		end
	surface.set_tiles(land)
	
if entity_in_border then
	local force = entity_in_border.force
	for _,pos in pairs(border) do 
		local en =  entity_in_border.names[math.random(#entity_in_border.names)]
		surface.create_entity({name=en, position=pos, force = force})
		end
	end

end


function AddRiver(river,surface)
	local waterTiles = {}
	local water = {}
	local x1,x2 = river[1].x , river[2].x
	local y1,y2 = river[1].y , river[2].y
	
	surface.destroy_decoratives{area=river}
	for y=y1,y2 do
		for x=x1,x2 do
			if y==y1 or y==y2 or x==x1 or x==x2 or y==y1+1 or y==y2-1 or x==x1+1 or x==x2-1 then 
				--if (x==x1 or x==x2 or math.random(0,3)>0) then 
				table.insert(water, {name="water", position={x=x, y=y}}) 
				--if (y==y1 or y==y2 or x==x1 or x==x2 or math.random(0,3)>0) then table.insert(water, {name="water", position={x=-x, y=-y}}) end
				else
				table.insert(waterTiles, {name="deepwater", position={x=x, y=y}})
				end
			end 
		end
	surface.set_tiles(waterTiles)
	surface.set_tiles(water)
end


function ClearArea(area,surface,except)
local entities = surface.find_entities(area)			
for _, e in pairs(entities) do 
	if e and e.valid and e.type and e.type~="character" then 
	if (not except) or (e.name~=except) then
		e.destructible=true
		e.destroy() 
		end
	end 
	end 
	--if e.type == "simple-entity" or e.type == "resource" or e.type == "tree" then e.destroy()	end
end	


function is_this_tile_pos_neighboring(surface,pos,tile_name)
	local checks = {{pos.x+1, pos.y}, {pos.x-1, pos.y}, {pos.x, pos.y+1}, {pos.x, pos.y-1}, {pos.x+1, pos.y+1}, {pos.x+1, pos.y-1}, {pos.x-1, pos.y+1}, {pos.x-1, pos.y-1}}
	for _, check_pos in ipairs(checks) do
		if surface.get_tile(check_pos[1], check_pos[2]).name == tile_name then
			return true
		end
	end
	return false
end


function add_water_lake(surface, center_pos, size, water_tile_names, fish_proba)
    local max_radius = size / 2
    local created_tiles = {}
    local names = type(water_tile_names) == "string" and {water_tile_names} or water_tile_names
    local seed = math.random(1000)

    for dy = -max_radius, max_radius do
        for dx = -max_radius, max_radius do
            local world_x = center_pos.x + dx
            local world_y = center_pos.y + dy
            local p = {x = world_x, y = world_y}

            -- 1. CHECAGEM DE VIZINHANÇA (Buffer contra out-of-map)
            -- Verifica a posição atual e as 4 adjacentes para garantir um recuo
            local is_safe = true
            local checks = {
                {p.x, p.y}, {p.x+1, p.y}, {p.x-1, p.y}, {p.x, p.y+1}, {p.x, p.y-1}
            }
            
            for _, pos in ipairs(checks) do
                if surface.get_tile(pos[1], pos[2]).name == "out-of-map" then
                    is_safe = false
                    break
                end
            end

            if is_safe then
                local angle = math.atan(dy, dx)
                local dist = math.sqrt(dx*dx + dy*dy)

                -- 2. RUÍDO DE FORMA
                local shape_variation = (
                    math.sin(angle * 3 + seed) * 0.15 + 
                    math.cos(angle * 2 - seed) * 0.1
                ) * max_radius

                -- 3. RUÍDO DE BORDA
                local edge_detail = (
                    math.sin(world_x * 0.4) * 0.5 + 
                    math.cos(world_y * 0.4) * 0.5
                )

                -- 4. PREENCHIMENTO SÓLIDO (Sem buracos)
                local core_radius = max_radius * 0.5
                local dynamic_border = (max_radius * 0.4) + shape_variation + edge_detail

                if dist < core_radius or dist < (core_radius + dynamic_border) then
                    local chosen_name = names[math.random(#names)]
                    table.insert(created_tiles, {name = chosen_name, position = p})

                    if fish_proba and dist < (max_radius * 0.3) and math.random() < fish_proba then
                        surface.create_entity({name = "fish", position = p})
                    end
                end
            end
        end
    end

    if #created_tiles > 0 then
        surface.set_tiles(created_tiles, true)
    end

    return created_tiles
end



function AddFishArea(surface,area, ratio)
local solo = {}
	local x1,x2, y1,y2
	if area[1] then 
		x1,x2 = area[1].x , area[2].x
		y1,y2 = area[1].y , area[2].y
	else	
		x1,x2 = area.left_top.x , area.right_bottom.x
		y1,y2 = area.left_top.y , area.right_bottom.y		
	end
	for y=y1,y2,1 do
		for x=x1,x2,1 do
		local tile = surface.get_tile(x, y)
		if (tile.valid) and in_list({"water","deepwater","water-green","deepwater-green","water-shallow","water-mud"}, tile.name) then 
			if math.random()<=ratio then
				surface.create_entity({name = "fish",position = {x=x,y=y}})
				end
			end
		end end
end


function FillWaterWith(surface,area,withwhat)
if not withwhat then withwhat={"grass-1"} end
if type(withwhat)=='string' then withwhat = {withwhat} end
local solo = {}
local tiles = surface.find_tiles_filtered{area=area, collision_mask="water_tile"}
local ground  = surface.find_tiles_filtered{area=area, collision_mask="ground_tile", limit=1}
if #ground>0 then withwhat={ground[1].name} end
for _,tile in pairs(tiles) do 
	table.insert(solo, {name=withwhat[math.random(#withwhat)], position=tile.position}) 
	end
if #solo>0 then surface.set_tiles(solo)	end
--FillWith(surface,area,{"water","deepwater","water-green","deepwater-green","water-shallow","water-mud"},withwhat)
end


function FillWith(surface,area,what,withwhat)
local solo = {}
	local x1,x2, y1,y2
	if area[1] then 
		x1,x2 = area[1].x , area[2].x
		y1,y2 = area[1].y , area[2].y
	else	
		x1,x2 = area.left_top.x , area.right_bottom.x
		y1,y2 = area.left_top.y , area.right_bottom.y		
	end
	for y=y1,y2,1 do
		for x=x1,x2,1 do
		local tile = surface.get_tile(x, y)
		if (tile.valid) and ((not what) or in_list(what, tile.name)) then 
			local tn = withwhat
			if type(tn)=='table' then tn = withwhat[math.random(#withwhat)] end
			table.insert(solo, {name=tn, position={x=x, y=y}}) 
			end
		end
	end

if #solo>0 then 
	surface.set_tiles(solo)	
	return solo	
	end
end
	

function FillBondariesWith(surface,area,withwhat,max_distance,min_distance)
local solo = {}
	local x1,x2, y1,y2
	if area[1] then 
		x1,x2 = area[1].x , area[2].x
		y1,y2 = area[1].y , area[2].y
	else	
		x1,x2 = area.left_top.x , area.right_bottom.x
		y1,y2 = area.left_top.y , area.right_bottom.y		
	end
	for y=y1,y2 do
		for x=x1,x2 do
			if max_distance then

				if math.abs(y)>max_distance or math.abs(x)>max_distance and surface.get_tile(x, y) and surface.get_tile(x, y).valid then 
					table.insert(solo, {name=withwhat, position={x=x, y=y}}) 
					--if withwhat=='deepwater' then if math.random(40)==1 then surface.create_entity{name='fish', position={x=x, y=y},force=game.forces.neutral} end end --desyncs
					end
			end
			if min_distance then
				if math.abs(y)<min_distance and math.abs(x)<min_distance and surface.get_tile(x, y) and surface.get_tile(x, y).valid then 
				table.insert(solo, {name=withwhat, position={x=x, y=y}}) end
			end
		end
	end

if #solo>0 then
	surface.set_tiles(solo)
	end
end


function position_adjust_distance_from_center(position, distance)
local x = position.x
local y = position.y
if math.abs(x)>math.abs(distance) then if x>0 then x=x+distance else x=x-distance end end
if math.abs(y)>math.abs(distance) then if y>0 then y=y+distance else y=y-distance end end
return {x=x,y=y}
end
		
		
--a circle of tiles
function FillCircle(surface, centerPos, radius,tiles)
local area = GetAreaAroundPos (centerPos,radius)
    local tileRadSqr = radius^2
    local place_tiles = {}
    for i=area.left_top.x,area.right_bottom.x,1 do
        for j=area.left_top.y,area.right_bottom.y,1 do
            -- This ( X^2 + Y^2 ) is used to calculate if something is inside a circle area.
            local distVar = math.floor((centerPos.x - i)^2 + (centerPos.y - j)^2)
			local p={x=i,y=j}
            if (distVar < tileRadSqr) then table.insert(place_tiles, {name = tiles[math.random(#tiles)], position=p}) end
        end
    end
    surface.set_tiles(place_tiles)
end		


function clear_and_fill_area(surface, position, area_size, fill, except)
local area = GetAreaAroundPos(position, area_size)
ClearArea(area,surface,except)
if fill then FillWaterWith(surface,area) end
end


function get_empty_mapgen(tile, property_expression_names)
local m = {
	autoplace_settings = {
		tile = {
		  settings = {
			[tile] = {
			  frequency = 1,
			  richness = 1,
			  size = 1
			}
		  },
		  treat_missing_as_default = false
		}
	  },
	  cliff_settings = {
		cliff_elevation_0 = 0,
		cliff_elevation_interval = 0,
		cliff_smoothing = 0,
		control = "",
		name = "",
		richness = 1
	  },
	  default_enable_all_autoplace_controls = false,
	  height = 2000000,
	  no_enemies_mode = false,
	  peaceful_mode = false,
	  property_expression_names = {},
	  seed = 1,
	  starting_area = 1,
	  starting_points = {
		{
		  x = 0,
		  y = 0
		}
	  },
	  width = 2000000
	}

if property_expression_names then m.property_expression_names=property_expression_names end
return m  
end




function set_empty_mapgen(tile,m)
m.terrain_segmentation = "none"
m.water = "none"
m.autoplace_controls = {}
m.default_enable_all_autoplace_controls = false
m.autoplace_settings = {
      ["entity"] = {
        treat_missing_as_default = false,
      },
      ["tile"] = {
        treat_missing_as_default = false,
        settings = {
          [tile] = {
            frequency = 1,
            size = 1,
            richness = 1,
          },
        },
      },
      ["decorative"] = {
        treat_missing_as_default = false,
      },
    }  
m.cliff_settings= {
      cliff_elevation_0 = 1024,
    }
end