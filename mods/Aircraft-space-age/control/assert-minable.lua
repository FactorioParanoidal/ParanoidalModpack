script.on_event(defines.events.on_tick, function(e)
    for index, player in pairs(game.connected_players) do
        if player and player.driving and player.vehicle then
            player.vehicle.minable_flag = true -- Factorio 2.1: LuaEntity::minable is read-only
            assert(player.vehicle.minable)
        end
    end
end)