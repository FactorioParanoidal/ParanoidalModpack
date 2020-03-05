require "util"

LabRadius = 8 --in chunks
LabNameStub = "BPL_TheLab"

function LabName(force)
    return LabNameStub .. force.name
end

function IsLab(surface)
    return string.starts(surface.name, LabNameStub)
end

function DestroyEntity(entity, player_index)
	if (not entity.valid) then
		return
	end
    if (entity.type == "deconstructible-tile-proxy") then
        DestroyDeconstructibleTileProxy(entity)
        return
    end
    if (entity.type == "transport-belt") then
        ClearTransportLines(entity, 2)
    end
    if (entity.type == "underground-belt") then
        ClearTransportLines(entity, 4)
    end
    if (entity.type == "splitter") then
        ClearTransportLines(entity, 8)
    end
    if (entity.type == "loader") then
        ClearTransportLines(entity, 2)
    end

    script.raise_event(defines.events.on_pre_player_mined_item, 
        {player_index = player_index, entity = entity}) 

    entity.destroy()
end

function ClearTransportLines(entity, count)
    for i = 1, count do
        entity.get_transport_line(i).clear()
    end
end

function DestroyDeconstructibleTileProxy(entity)
    local hiddenTile = entity.surface.get_hidden_tile(entity.position)
    --if not hiddenTile then return end

    entity.surface.set_tiles {{name = hiddenTile, position = entity.position}}
    entity.destroy()
end

function DestroyTile(tile, surface)
    --if not tile.hidden_tile then return end

    surface.set_tiles {{name = tile.hidden_tile, position = tile.position}}
end

function IsBlueprintOrBook(itemStack)
    return itemStack.is_blueprint or itemStack.is_blueprint_book
end

EmptyBlueprintString = "0eNqrrgUAAXUA+Q=="

function ReviveEntity(entity, player_index)
    if entity.type == "entity-ghost" then
        _, revived, request = entity.revive({true})
        if not revived then return end

        if request then
            for requestName, requestCount in pairs(request.item_requests) do
                request.proxy_target.insert {name = requestName, count = requestCount}
            end
            request.destroy()
        end

        script.raise_event(defines.events.on_built_entity, 
            {player_index = player_index, created_entity = revived})
    elseif entity.type == "tile-ghost" then
        entity.revive()
    end
end

function DisableLab(lab)
    lab.active = false
end