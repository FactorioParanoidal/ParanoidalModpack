-- from some corpse marker
script.on_event(defines.events.on_pre_player_died, function(event)
    local player = game.players[event.player_index]
    player.force.add_chart_tag(player.surface, {position=player.position, text='Corpse: '..player.name..'; Time: '..math.floor(game.tick/60/60/60)..':'..(math.floor(game.tick/60/60)%60), icon={type="virtual",name="signal-info"}})
end)

if (settings.global["paranoidal-disable-vanilla-evolution"] or {}).value then
    script.on_init(function() game.map_settings.enemy_evolution.enabled = false end)
end
