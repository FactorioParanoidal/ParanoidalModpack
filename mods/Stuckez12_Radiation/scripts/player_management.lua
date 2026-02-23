local player_management = {}

function player_management.verify_character_references()
    local active_characters = {}

    for _, char in pairs(storage.active_characters) do
        if char and char.valid then
            table.insert(active_characters, char)
        end
    end

    storage.active_characters = active_characters
end


function player_management.add_character_reference(character)
    if not (character and character.valid) then return end

    table.insert(storage.active_characters, character)
end


function player_management.remove_character_reference(character)
    storage.active_characters[character] = nil
end


function player_management.add_all_player_references()
    for _, player in pairs(game.connected_players) do
        if player.valid and player.character then player_management.add_character_reference(player.character) end
    end
end


function player_management.add_player(event)
    local player = game.get_player(event.player_index)
    
    if player and player.character then player_management.add_character_reference(player.character) end
end


return player_management
