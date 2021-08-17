log("LIBORIO UTILCONTROL")
require("defines")

local local_get_biome = function(entity)
    local r = 10
	local aabb = entity.prototype.collision_box
    local box = { { entity.position.x - r - aabb.left_top.x, entity.position.y - r - aabb.left_top.y }, { entity.position.x + r + aabb.right_bottom.x, entity.position.y + r + aabb.right_bottom.y } }
    local tiles = entity.surface.find_tiles_filtered{area=box}
	local counts = { }
    counts["basic"] = #tiles
	for _,tile in pairs(tiles) do
		for type,fac in pairs(liborio.get_biomes()) do
			if type ~= "basic" and string.find(tile.name, type) then
                counts["basic"] = counts["basic"] - 1
                counts[type] = counts[type] and counts[type]+1 or 1
			end
        end
    end
    local max = 0
	local ret = "basic"
	for type,count in pairs(counts) do
		if count > max then
            ret = type
            max = count
        end
    end
	for _,tile in pairs(tiles) do
		if tile.name == ret then return ret end
    end
	return "basic"
	end
--[[updated, no longer required check for game as this function is specific to control]]
local local_print = function(arg, index)
	if index ~= nil then
            game.players[index].print(liborio.convert_to_string(message))
    else
		for i = 1, #game.players do local p = game.players[i]
			p.print(liborio.convert_to_string(arg))
		end
    end
end

--[[reduced logic no need to check nil]]
local local_is_valid = function(entity) return type(entity)=="table" and entity.valid end
local local_is_valid_and_persistant = function(entity)  return local_is_valid(entity) and not entity.to_be_deconstructed(entity.force) end

local local_get_entity_size = function(entity)
	if entity == nil then return {1,1} end	
	if entity.prototype.selection_box ~= nil then
        local size = {
                entity.prototype.selection_box["right_bottom"]["x"] - entity.prototype.selection_box["left_top"]["x"],
                entity.prototype.selection_box["right_bottom"]["y"] - entity.prototype.selection_box["left_top"]["y"]}
		if entity.direction == 0 or entity.direction == 4 then return size end
		return { size[2],size[1]}
	end
	return {1,1} 
	end

local local_get_technology = function(technology, force) 
	if force == nil then force = game.players[1].force end
	for _,t in pairs(force.technologies) do
		if t.name == technology then return t end
	end
	return nil
	end

local local_get_entities_to_northwest = function(entity, type, size)
    local wh = size or local_get_entity_size(entity)
	if wh == {0, 0} then wh = { 1, 1 } end
    local w,h = 0.5* wh[1], 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y-(h+0.5)}, {entity.position.x-(w+0.5), entity.position.y-h}}, type = type} end
	return entity.surface.find_entities({{entity.position.x-w, entity.position.y-(h+0.5)}, {entity.position.x-(w+0.5), entity.position.y-h}}) 
    end

local local_get_entities_to_northeast = function(entity, type)
    local wh = local_get_entity_size(entity)
	if wh == {0, 0} then wh = { 1, 1 } end
    local w,h = 0.5* wh[1], 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x+w, entity.position.y-(h+0.5)}, {entity.position.x+(w+0.5), entity.position.y-h}}, type = type} end
	return entity.surface.find_entities({{entity.position.x+w, entity.position.y-(h+0.5)}, {entity.position.x+(w+0.5), entity.position.y-h}}) 
    end

local local_get_entities_to_north = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h = (0.5 * wh[1]) - 0.2, 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y-(h+0.5)}, {entity.position.x+w, entity.position.y-h}}, type = type} end
	return entity.surface.find_entities({{entity.position.x-w, entity.position.y-(h+0.5)}, {entity.position.x+w, entity.position.y-h}})
    end

local local_get_entities_to_south = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h = (0.5 * wh[1]) - 0.2, 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y+h}, {entity.position.x+w, entity.position.y+h+(0.5)}}, type = type} end
	return entity.surface.find_entities({{entity.position.x-w, entity.position.y+h}, {entity.position.x+w, entity.position.y+h+(0.5)}}) 
    end

local local_get_entities_to_east = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h = 0.5 * wh[1], (0.5 * wh[2]) - 0.2
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x+w, entity.position.y-h}, {entity.position.x+(w+0.5), entity.position.y+h}}, type = type} end
	return entity.surface.find_entities({{entity.position.x+w, entity.position.y-h}, {entity.position.x+(w+0.5), entity.position.y+h}}) 
    end

local local_get_entities_to_west = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h = 0.5 * wh[1], (0.5 * wh[2]) - 0.2
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x-(w+0.5), entity.position.y-h}, {entity.position.x-w, entity.position.y+h}}, type = type} end
	return entity.surface.find_entities({{entity.position.x-(w+0.5), entity.position.y-h}, {entity.position.x-w, entity.position.y+h}}) 
    end

local local_get_entities_to_southeast = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h  = 0.5 * wh[1], 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x+w, entity.position.y-h}, {entity.position.x+(w+0.5), entity.position.y+(h+0.5)}}, type = type} end
	return entity.surface.find_entities({{entity.position.x+w, entity.position.y-h}, {entity.position.x+(w+0.5), entity.position.y+(h+0.5)}}) 
    end

local local_get_entities_to_southwest = function(entity, type)
    local wh = local_get_entity_size(entity)
    local w,h = 0.5 * wh[1], 0.5 * wh[2]
	if type ~= nil then return entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y-h}, {entity.position.x-(w+0.5), entity.position.y+(h+0.5)}}, type = type} end
	return entity.surface.find_entities({{entity.position.x-w, entity.position.y-h}, {entity.position.x-(w+0.5), entity.position.y+(h+0.5)}})
    end

local local_get_entities_to = function(direction, entity, type)
    local d = liborio.opposite_direction(direction)
	if d == defines.direction.north then return local_get_entities_to_north(entity, type) end
	if d == defines.direction.northeast then return local_get_entities_to_northeast(entity, type) end
	if d == defines.direction.east then return local_get_entities_to_east(entity, type) end
	if d == defines.direction.southeast then return local_get_entities_to_southeast(entity, type) end
	if d == defines.direction.south then return local_get_entities_to_south(entity, type) end
	if d == defines.direction.southwest then return local_get_entities_to_southwest(entity, type) end
	if d == defines.direction.west then return local_get_entities_to_west(entity, type) end
	if d == defines.direction.northwest then return local_get_entities_to_northwest(entity, type) end
	return {} 
    end
--Excluding the specified entity
local local_get_entities_to_excluding = function(direction, entity, type)
    local entities = local_get_entities_to(direction, entity, type)
    local ret = { }
	for index=1, #entities do
		local e = entities[index]
		if e ~= entity then
            table.insert(ret, e)
        end
    end
	return ret
    end
local local_get_entities_around = function(entity, tiles_away, findtype, name)
    local wh = local_get_entity_size(entity)
    local w,h = 0.5 * wh[1], 0.5 * wh[2]
	local entities = nil
	if type(tiles_away) == "number" then w = w + tiles_away h = h + tiles_away
    elseif type(tiles_away) == "string" then w = w + tonumber(tiles_away) h = h + tonumber(tiles_away) end
    entities = entity.surface.find_entities_filtered{area = {{entity.position.x-w, entity.position.y-h}, {entity.position.x+w, entity.position.y+h}}, type = findtype, name = name}
	for i, ent in pairs(entities) do	
		if ent == entity then
            table.remove(entities, i)
			break
		end
    end
	return entities
    end

local local_try_set_recipe = function(entity, recipe)
    local call = function(e, f)
        e.set_recipe(f)
    end
    local status, retval = pcall(call, entity, recipe)
	if status == true then return end
    end
local local_find_recipes_for = function(name, force)
	if force == nil then force = game.players[1].force end
    local recipes = { }
		for _,r in pairs(force.recipes) do
		if r.name == name then 
			table.insert(recipes,r)
		end
	end
	return recipes
	end

local local_transfer_fluid = function(from, findex, to, tindex, amount, max)
	if from == nil or to == nil then return end
    local from_boxes = from.fluidbox
    local from_box = from_boxes[findex]
    local to_boxes = to.fluidbox
    local to_box = to_boxes[tindex]
	if from_box == nil then return end
	if to_box == nil then
		if from_box.amount <= amount then

            from_boxes[findex] = nil
            to_boxes[tindex] = from_box
		else  				
			from_box.amount = from_box.amount - amount
            from_boxes[findex] = from_box

            from_box.amount = amount
            to_boxes[tindex] = from_box

        end
	else
		local tcap = to_boxes.get_capacity(tindex) - to_box.amount

        local tfer = math.min(tcap, math.min(from_box.amount, amount))
		if tfer <=0 then return end
        from_box.amount = math.max(from_box.amount - tfer,1)

        from_boxes[1] = from_box
        from_box.amount = to_box.amount + tfer
        to_boxes[tindex] = from_box

    end
	end
local local_transfer_fluid_and_convert = function(from, findex, to, tindex, amount, max, totype, temp)
	if from == nil or to == nil then return end
    local from_boxes = from.fluidbox
    local from_box = from_boxes[findex]
    local to_boxes = to.fluidbox
    local to_box = to_boxes[tindex]
	if temp == nil then temp = game.fluid_prototypes[totype] end
    local fluid_prototype = game.fluid_prototypes[totype]
	if from_box == nil then return end
	if to_box == nil then 
		if from_box.amount <= amount then
            from_boxes[findex] = nil					
			if local_is_int(temp) then from_box.temperature = temp end
            from_box.name = totype
            to_boxes[tindex] = from_box					
		else		
            from_box.amount = from_box.amount - amount
            from_boxes[findex] = from_box
            from_box.amount = amount					
			if local_is_int(temp) then from_box.temperature = temp end
            from_box.name = totype
            to_boxes[tindex] = from_box
        end
	else

        local tcap = to_boxes.get_capacity(tindex) - to_box.amount
        local tfer = math.min(tcap, math.min(from_box.amount, amount))
		if tfer <=0 then return end
        from_box.amount = math.max(from_box.amount - tfer, 1)
        from_boxes[1] = from_box
        from_box.amount = to_box.amount + tfer
		if local_is_int(temp) then from_box.temperature = temp end
        from_box.name = totype
        to_boxes[tindex] = from_box
    end
	end
local local_get_connected_input_fluid = function(entity, box)
    local call = function(e, b)
		if not e.fluidbox or b > #e.fluidbox then return nil end	
		local inpipe = e.fluidbox.get_connections(b)	
		if inpipe == nil then return nil end
		for i = 1, #inpipe do local ip = inpipe[i]	
			if ip ~= nil then			
				for j = 1, #ip do local jp = ip[j]
					if jp ~= nil and local_is_valid(ip.owner) and ip.owner.fluidbox ~= nil then
						for m = 1, #ip.owner.fluidbox do mp = ip.owner.fluidbox.get_connections(m)	
							if mp ~= nil then
								for mx = 1, #mp do mpx = mp[mx]
									if mpx.owner == e then
										return { entity = ip.owner, box = m}
                                    end
                                end
                            end
                        end

                    end
                end

            end
        end

    end
    local status, retval = pcall(call, entity, box)
	if status == true then return retval end
	end
local local_addable_fluid = function(entity, amount, index)
    local cap = 100
	if entity.fluidbox[index].get_capacity then
        cap = entity.fluidbox[index].get_capacity(index)
    end
    local avail = cap - entity.fluidbox[index].amount
	return math.min(avail, math.abs(amount)) 
	end
local local_removeable_fluid = function(fluid, amount) return math.min(fluid.amount, math.abs(amount)) end
local local_change_fluidbox_fluid = function(entity, amount, pollution_source)
    local delta = 0
    local used = 0
    local abs_amount = math.abs(amount)
    if entity.fluidbox ~= nil then
		for i = 1, #entity.fluidbox do	
			local fluid = entity.fluidbox[i]
            local current_fluid = "water"
			if fluid ~= nil and fluid.amount > 0 then
                local innerDelta = 0
				current_fluid = fluid.name
				if amount< 0 then
                    innerDelta = local_removeable_fluid(fluid, amount)
                    fluid.amount = fluid.amount-innerDelta
					if fluid.amount <= 0 then
                        entity.fluidbox[i] = nil			
					else
                        entity.fluidbox[i] = fluid
                    end
				else
                    innerDelta = local_addable_fluid(entity, amount, i)
                    fluid.amount = fluid.amount - innerDelta
					if fluid.amount <= 0 then
                        entity.fluidbox[i] = nil			
					else
                        entity.fluidbox[i] = fluid
                    end
                end
                used = used + innerDelta 
				if pollution_source ~= nil then
					if liborio.is_pollutant(current_fluid) == true then
                        pollution_source.surface.pollute(pollution_source.position,0.01)
                    end
                end
				if used >= amount then
					if(amount< 0) then return used* -1 end
					return used
                end
            end
        end
    end
	if(amount< 0) then return used* -1 end
	return used
	end

local local_get_signal_position_from = function(entity)
    local left_top = entity.prototype.selection_box.left_top
    local right_bottom = entity.prototype.selection_box.right_bottom
    --Calculating center of the selection box
    local center = (left_top.x + right_bottom.x) / 2
    local width = math.abs(left_top.x) + right_bottom.x
    -- Set Shift here if needed, The offset looks better as it doesn't cover up fluid input information
    -- Ignore shift for 1 tile entities
    local x = (width > 1.25 and center - 0.5) or center
    local y = right_bottom.y
    --Calculating bottom center of the selection box
    return {x = entity.position.x + x, y = entity.position.y + y}
	end

local local_set_new_signal = function(entity, name, variation)
    local signal = entity.surface.create_entity{name = name, position = local_get_signal_position_from(entity), force = entity.force}
    signal.graphics_variation = variation
    signal.destructible = false
    return signal
	end

liborio.print = local_print
liborio.is_valid = local_is_valid
liborio.entity.is_valid_and_persistant = local_is_valid_and_persistant
liborio.entity.get_entity_size = local_get_entity_size
liborio.entity.get_entities_to = local_get_entities_to
liborio.entity.get_entities_to_northwest = local_get_entities_to_northwest
liborio.entity.get_entities_to_norteast = local_get_entities_to_norteast
liborio.entity.get_entities_to_north = local_get_entities_to_north
liborio.entity.get_entities_to_east = local_get_entities_to_east
liborio.entity.get_entities_to_south = local_get_entities_to_south
liborio.entity.get_entities_to_west = local_get_entities_to_west
liborio.entity.get_entities_to_southeast = local_get_entities_to_southeast
liborio.entity.get_entities_to_southwest = local_get_entities_to_southwest
liborio.entity.get_entities_around = local_get_entities_around
liborio.entity.get_entities_to_excluding = local_get_entities_to_excluding
liborio.entity.try_set_recipe = local_try_set_recipe

liborio.tech.get_technology = local_get_technology

liborio.recipe.find_recipes_for = local_find_recipes_for

liborio.fluid.transfer_fluid = local_transfer_fluid
liborio.fluid.transfer_fluid_and_convert = local_transfer_fluid_and_convert
liborio.fluid.get_connected_input_fluid = local_get_connected_input_fluid
liborio.fluid.change_fluidbox_fluid = local_change_fluidbox_fluid

liborio.signal.get_posistion_from = local_get_signal_position_from
liborio.signal.set_new_signal = local_set_new_signal

liborio.get_biome = local_get_biome