return function(player)
  if not global.players[player.index].settings.show_evolution then
    return
  end

  local evolution = game.forces.enemy.evolution_factor * 100
  return {
    "",
    { "statsgui.evolution" },
    string.format(" = %.2f", evolution),
    "%",
  }
end
