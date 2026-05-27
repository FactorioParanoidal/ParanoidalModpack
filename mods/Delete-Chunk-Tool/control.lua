local function delete_chunk(surface, chunk, destroy_all)
    if not surface.valid then
        return
    end

	local area = {top_left = {chunk.x * 32, chunk.y * 32}, bottom_right = {(chunk.x * 32) + 32, (chunk.y * 32) + 32}}

    if destroy_all then
		local players_in_chunk = surface.find_entities_filtered {area = area, type = "character"}
        if players_in_chunk and #players_in_chunk > 0 then
            game.print(string.format("Error: player(s) in chunk (%d, %d)", chunk.x, chunk.y))
        else
            surface.delete_chunk(chunk)
        end
    else
		local entities_in_chunk = surface.find_entities_filtered {area = area, force = "player"}
        if entities_in_chunk and #entities_in_chunk > 0 then
            game.print(string.format("Error: entities of force player in chunk (%d, %d)", chunk.x, chunk.y))
        else
            surface.delete_chunk(chunk)
        end
    end
end

local function on_player_selected_area(event, destroy_all)
    local item = event.item
    local player = game.players[event.player_index]

    if item == "chunk-eraser" then
        if not player.admin then
            player.print("Error: not an administrator")
            return
        end

    local surface = event.surface or player.surface
    local area = event.area




        for x = math.floor((area.left_top.x-16)/32+0.5), math.floor((area.right_bottom.x-16)/32+0.5), 1 do
        for y = math.floor((area.left_top.y-16)/32+0.5), math.floor((area.right_bottom.y-16)/32+0.5), 1 do
                local chunk = {}
                chunk.x = x
                chunk.y = y
                delete_chunk(surface, chunk, destroy_all)
        end
        end
    end
end

script.on_event(
    defines.events.on_player_selected_area,
    function(event)
        on_player_selected_area(event, false)
    end
)

script.on_event(
    defines.events.on_player_alt_selected_area,
    function(event)
        on_player_selected_area(event, true)
    end
)

script.on_event(
    defines.events.on_player_dropped_item,
    function(event)
        if event.entity ~= nil and event.entity.stack ~= nil and event.entity.stack.name == "chunk-eraser" then
            event.entity.stack.clear()
        end
    end
)
