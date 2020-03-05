require "common"

local function is_miniloader(entity)
	return string.find(entity.name, "miniloader%-loader$") ~= nil
end

local function is_miniloader_inserter(entity)
	return entity.name:find("miniloader%-inserter$") ~= nil
end

local function get_loader_inserters(entity)
	return entity.surface.find_entities_filtered {
		position = entity.position,
		type = "inserter"
	}
end

local function on_miniloader_mined(event)
	local entity = event.entity
	local inserters = get_loader_inserters(entity)
	if event.buffer and inserters[1] then
		local _, item_to_place = next(inserters[1].prototype.items_to_place_this)
		event.buffer.insert{count=1, name=item_to_place.name}
	end
	for i = 1, #inserters do
		-- return items to player / robot if mined
		if event.buffer and inserters[i] ~= entity and inserters[i].held_stack.valid_for_read then
			event.buffer.insert(inserters[i].held_stack)
		end
		inserters[i].destroy()
	end
end

local function on_miniloader_inserter_mined(event)
	local entity = event.entity
	local loader = entity.surface.find_entities_filtered {
		position = entity.position,
		type = "loader"
	}[1]
	if loader then
		if event.buffer then
			for i = 1, 2 do
				local tl = loader.get_transport_line(i)
				for j = 1, #tl do
					event.buffer.insert(tl[j])
				end
				tl.clear()
			end
		end
		loader.destroy()
	end

	local inserters = get_loader_inserters(entity)
	for i = 1, #inserters do
		if inserters[i] ~= entity then
			-- return items in inserter hand to player / robot if mined
			if event.buffer and inserters[i].held_stack.valid_for_read then
				event.buffer.insert(inserters[i].held_stack)
			end
			inserters[i].destroy()
		end
	end
end

function OnMarkedForDeconstruction(event)
    if not IsLab(event.entity.surface) then
        return
    end

	-- Bugfix for Miniloaders
	if (is_miniloader(event.entity)) then
		on_miniloader_mined(event)
	elseif (is_miniloader_inserter(event.entity)) then
		on_miniloader_inserter_mined(event)
	end
    DestroyEntity(event.entity, event.player_index)
end

function OnBuiltEntity(event)
    if not IsLab(event.created_entity.surface) then
        return
    end

    local entity = event.created_entity

    if entity.type == "entity-ghost" or entity.type == "tile-ghost" then
        ReviveEntity(entity, event.player_index)
        return
    end

    if entity.type == "lab" then
        DisableLab(entity)
        return
    end
end
