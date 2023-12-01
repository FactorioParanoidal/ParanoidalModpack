return function(player)
  if not global.players[player.index].settings.show_daytime then
    return
  end

  local days = math.floor(1 + ((game.tick + 12500) / 25000))

  local daytime = player.surface.daytime + 0.5
  local daytime_minutes = math.floor(daytime * 24 * 60)
  local daytime_hours = math.floor(daytime_minutes / 60) % 24
  daytime_minutes = daytime_minutes - (daytime_minutes % 15)

  return {
    "",
    { "statsgui.time" },
    " = " .. string.format("%d:%02d", daytime_hours, daytime_minutes % 60),
    ", ",
    { "statsgui.day" },
    " " .. days,
  }
end
