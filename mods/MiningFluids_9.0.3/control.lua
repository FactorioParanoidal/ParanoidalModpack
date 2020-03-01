script.on_event(defines.events.on_player_created, function(event)
  local player = game.players[event.player_index]
  --player.insert{name="iron-plate", count=8}
  --player.insert{name="pistol", count=1}
  --player.insert{name="firearm-magazine", count=10}
  --player.insert{name="electric-mining-drill", count = 3}
  --player.insert{name="stone-furnace", count = 1}
  --player.insert{name="pipe", count = 50}
  --player.insert{name="pipe-to-ground", count = 50}
  --player.insert{name="offshore-pump", count = 3}
  --player.insert{name="steam-engine", count = 2}
  --player.insert{name="boiler", count = 2}
  --player.insert{name="small-electric-pole", count = 30}
  player.force.chart(player.surface, {{player.position.x - 200, player.position.y - 200}, {player.position.x + 200, player.position.y + 200}})
end)