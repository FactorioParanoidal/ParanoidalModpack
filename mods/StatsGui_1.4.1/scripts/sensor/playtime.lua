local misc = require("__flib__.misc")

return function(player)
  if not global.players[player.index].settings.show_playtime then
    return
  end

  return { "", { "statsgui.playtime" }, " = ", misc.ticks_to_timestring(game.ticks_played) }
end
