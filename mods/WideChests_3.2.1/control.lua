require("init")
require("util")

function MergingChests.GetChestSize(data, entity)
	if entity.name == data.id then
		return 1, 1
	elseif string.starts_with(entity.name, "wide-"..data.id) then
		return tonumber(string.sub(entity.name, string.len("wide-"..data.id.."-") + 1)), 1
	elseif string.starts_with(entity.name, "high-"..data.id) then
		return 1, tonumber(string.sub(entity.name,  string.len("high-"..data.id.."-") + 1))
	elseif string.starts_with(entity.name, data.type.."-warehouse-") then
		local width, height = table.unpack(string.split(string.sub(entity.name, string.len(data.type.."-warehouse-") + 1), "x"))
		return tonumber(width), tonumber(height)
	elseif string.starts_with(entity.name, data.type.."-trashdump-") then
		local width, height = table.unpack(string.split(string.sub(entity.name, string.len(data.type.."-trashdump-") + 1), "x"))
		return tonumber(width), tonumber(height)
	else
		return 0, 0
	end
end

function MergingChests.MoveInventories(from, to)
	local j = 1
	local l = 1
	local toInventory = to[j].get_inventory(1)
	local bar = 0
	
	for _, entity in ipairs(from) do
		bar = bar + entity.get_inventory(1).get_bar() - 1
	end
	
	for i = 1, #from do
		local fromInventory = from[i].get_inventory(1)
		
		for k = 1, #fromInventory do
			if fromInventory[k].valid_for_read then
				toInventory[l].set_stack(fromInventory[k])
				l = l + 1
				
				if l > #toInventory then
					j = j + 1
					
					if j > #to then
						-- should never happen but just to be sure
						goto setbar
					end
					
					toInventory = to[j].get_inventory(1)
					l = 1
				end
			end
		end
	end
	
	-- evenly distribute bar count over chests
	::setbar::
	local remainingBar = bar
	local remainingEntites = #to
	for _, entity in ipairs(to) do
		local singleBar = math.round(remainingBar / remainingEntites)
		entity.get_inventory(1).set_bar(singleBar + 1)
		remainingBar = remainingBar - singleBar
		remainingEntites = remainingEntites - 1
	end
end

function MergingChests.ReconnectCircuits(from, to)
	local fromSet = { }
	for _, entity in ipairs(from) do
		fromSet[entity] = entity
	end
	
	local connections = { }
	local red = false
	local green = false
	for _, entity in ipairs(from) do
		for __, connection in ipairs(entity.circuit_connection_definitions) do
			if not fromSet[connection.target_entity] then
				table.insert(connections, connection)
				
				red = red or connection.wire == defines.wire_type.red
				green = green or connection.wire == defines.wire_type.green
			end
		end
	end
	
	if #connections > 0 then
		--connect all "to" entities together
		for i = 1, #to - 1 do
			if red then
				to[i].connect_neighbour{wire = defines.wire_type.red, target_entity = to[i + 1]}
			end
			
			if green then
				to[i].connect_neighbour{wire = defines.wire_type.green, target_entity = to[i + 1]}
			end
		end
		
		for _, connection in ipairs(connections) do
			local closestEntity = nil
			local min = nil
			
			for __, entity in ipairs(to) do
				local diffX = entity.position.x - connection.target_entity.position.x
				local diffY = entity.position.y - connection.target_entity.position.y
				
				if not min or (diffX * diffX + diffY * diffY < min) then
					min = diffX * diffX + diffY * diffY
					closestEntity = entity
				end
			end
			
			closestEntity.connect_neighbour(connection)
		end
	end
end

-- merging functions
function MergingChests.FindChestsBounds(data, entities)
	local minX, minY, maxX, maxY = nil, nil, nil, nil
	
	for _, entity in ipairs(entities) do
		local width, height = MergingChests.GetChestSize(data, entity)
		local offsetX = width / 2
		local offsetY = height / 2
		
		local floorX = math.floor(entity.position.x)
		local floorY = math.floor(entity.position.y)
		
		if not minX or (minX > floorX) then minX = floorX end
		if not minY or (minY > floorY) then minY = floorY end
		if not maxX or (maxX < floorX) then maxX = floorX end
		if not maxY or (maxY < floorY) then maxY = floorY end
	end
	
	return { minX = minX, minY = minY, maxX = maxX, maxY = maxY }
end

function MergingChests.SortIntoGroups(data, entities)
	local mapBounds = MergingChests.FindChestsBounds(data, entities)
	local chestMap = { }

	-- fill map
	for _, entity in ipairs(entities) do
		chestMap[math.floor(entity.position.x)] = chestMap[math.floor(entity.position.x)] or { }
		
		chestMap[math.floor(entity.position.x)][math.floor(entity.position.y)] = entity
	end

	local groups = { }
	local merged = false

	repeat
		merged = false
		
		local xStart, yStart, width, height = MergingChests.FindLargestChest(chestMap, mapBounds)
		
		if width > 1 or height > 1 then
			-- fill new group and used entities remove from map
			local newGroup = { }
			for x = xStart, xStart + width - 1 do
				for y = yStart, yStart + height - 1 do
					table.insert(newGroup, chestMap[x][y])

					chestMap[x][y] = nil
				end
			end

			table.insert(groups, { entities = newGroup, width = width, height = height, position = { x = xStart + width / 2, y = yStart + height / 2 } })
			merged = true
		end
	until not merged

	return groups
end

function MergingChests.FindLargestChest(map, area)
	local maxX = 0
	local maxY = 0
	local maxWidth = 0
	local maxHeight = 0
	
	local row = { }
	for x = area.minX, area.maxX do
		for y = area.minY, area.maxY do
			if map[x] and map[x][y] then
				row[y] = (row[y] or 0) + 1
			else
				row[y] = 0
			end
		end
		
		local y, width, height = MergingChests.FindLargestAreaUnderHistogram(row, area.minY, area.maxY)
		
		if width * height > maxWidth * maxHeight then
			maxX = x - width + 1
			maxY = y
			maxWidth = width
			maxHeight = height
		end
	end

	return maxX, maxY, maxWidth, maxHeight
end

function MergingChests.FindLargestAreaUnderHistogram(row, min, max)
	local maxY = 0
	local maxWidth = 0
	local maxHeight = 0
	
	local stack = { }
	local top = 0
	local y = 0
	local n = max - min + 1
	
	local function CalculateAreaAndUpdate()
		local peak = stack[top]
		top = top - 1

		local width = row[peak + min]
		local height = top == 0 and y or (y - stack[top] - 1)

		if maxWidth * maxHeight < width * height and MergingChests.CheckWhitelist(width, height) then
			maxY = y + min - height
			maxWidth = width
			maxHeight = height
		end
	end
	
	while y < n do
		if top == 0 or row[stack[top] + min] <= row[y + min] then
			top = top + 1
			stack[top] = y
			y = y + 1
		else
			CalculateAreaAndUpdate()
		end
	end
	
	while top > 0 do
		CalculateAreaAndUpdate()
	end
	
	return maxY, maxWidth, maxHeight
end

function MergingChests.CreateMergedChest(data, group, player)
	local newChestName
	if group.width > settings.startup["warehouse-threshold"].value and group.height > settings.startup["warehouse-threshold"].value then
		newChestName = data.type.."-trashdump-"..group.width.."x"..group.height
	elseif group.width > 1 and group.height > 1 then
		newChestName = data.type.."-warehouse-"..group.width.."x"..group.height
	elseif group.width > 1 then
		newChestName = "wide-"..data.type.."-chest-"..group.width
	elseif group.height > 1 then
		newChestName = "high-"..data.type.."-chest-"..group.height
	end
	
	return player.surface.create_entity{name = newChestName, position = group.position, force = player.force}
end

-- splitting functions
function MergingChests.CreateSplitedChests(data, entity, player)
	local width, height = MergingChests.GetChestSize(data, entity)
	local position = { x = entity.position.x - (width - 1) / 2, y = entity.position.y - (height - 1) / 2 }
	
	local entities = { }
	
	for dX = 0, width - 1 do
		for dY = 0, height - 1 do
			table.insert(entities, entity.surface.create_entity{name = data.id, position = { x = position.x + dX, y = position.y + dY }, force = player.force})
		end
	end
	
	return entities
end

-- event handlers
function MergingChests.OnPlayerSelectedArea(event)
	if event.item and event.item == "merge-chest-selector" then
		local player = game.players[event.player_index]
		
		-- use event entities and remove everything but mergable chests
		local chestGroups = groupByName(event.entities)
		for id, entities in pairs(chestGroups) do
			local data = MergingChests.MergableChestIdToData[id]
			for _, group in ipairs(MergingChests.SortIntoGroups(data, entities)) do
				if #group.entities > 1 then
					local newChest = MergingChests.CreateMergedChest(data, group, player)
					
					MergingChests.MoveInventories(group.entities, { newChest })
					MergingChests.ReconnectCircuits(group.entities, { newChest })
					
					for _, entity in ipairs(group.entities) do
						entity.destroy()
					end
				end
			end
		end
	end
end

function MergingChests.OnPlayerAltSelectedArea(event)
	if event.item and event.item == "merge-chest-selector" then
		local player = game.players[event.player_index]
		
		-- use event entities and remove everything but merged chests
		for _, data in pairs(MergingChests.MergableChestIdToData) do
			local entities = event.entities
			for i = #entities, 1, -1 do
				local entity = entities[i]
				if math.max(MergingChests.GetChestSize(data, entity)) > 1 then
				
					local newEntities = MergingChests.CreateSplitedChests(data, entity, player)
					
					MergingChests.MoveInventories({ entity }, newEntities)
					MergingChests.ReconnectCircuits({ entity }, newEntities)
					
					table.remove(entities, i)
					entity.destroy()
				end
			end
		end
	end
end

function MergingChests.OnShortCut(event)
	if event.prototype_name == "merge-chest-selector" then
		local player = game.players[event.player_index]
		if player.clear_cursor() then
			local stack = player.cursor_stack
			if player.cursor_stack and stack.can_set_stack({ name = "merge-chest-selector" }) then
				stack.set_stack({ name = "merge-chest-selector" })
			end
		end
	end
end

script.on_event(defines.events.on_player_selected_area, MergingChests.OnPlayerSelectedArea)
script.on_event(defines.events.on_player_alt_selected_area, MergingChests.OnPlayerAltSelectedArea)
script.on_event(defines.events.on_lua_shortcut, MergingChests.OnShortCut)