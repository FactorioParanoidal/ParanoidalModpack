
script.on_event(defines.events.on_player_banned,function(event)
    
        if PlanetsLib.authors[event.player_name] then
            game.unban_player(event.player_name)
            game.print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n")
            -- `by_player` is optional (it is nil when the ban came from a script or
            -- the server console), so look it up defensively.
            local banner_name = (event.by_player and game.players[event.by_player] and game.players[event.by_player].name) or "server"
            game.print({"player-was-banned",event.player_name,banner_name,event.reason or {"unspecified"}},{color = {255,180,93}})
        end
        
    


end)
