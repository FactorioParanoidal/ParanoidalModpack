require "scripts.util"

function ClearVersion001()
    for _, player in pairs(game.players) do
        local player_index = player.index
        DestroyData(player_index)
        DestroyGui(player_index)
    end

    for _, surface in pairs(game.surfaces) do
        if string.starts(surface.name, "TheLab") then
            game.delete_surface(surface)
        end
    end
end

function DestroyData(player_index)
    local player = game.players[player_index]
    local data = global[player_index]

    if not data then return end

    ReturnToTheWorld(player_index)
    global[player_index] = nil
end

function ReturnToTheWorld(player_index)
    local player = game.players[player_index]
    local data = global[player_index]

    if not data.inTheLab then return end

    player.cheat_mode = false
    player.game_view_settings.show_research_info = true

    player.teleport({0, 0}, data.character.surface)
    player.character = data.character 
end

function DestroyGui(player_index)
    local player = game.players[player_index]
    local gui = player.gui.left["labFlow"]

    if not gui then return end

    player.gui.left["labFlow"].destroy()
end