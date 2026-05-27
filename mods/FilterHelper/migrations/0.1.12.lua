for player_index, player_global in pairs(storage.players) do
    player_global.player = game.get_player(player_index)
end
