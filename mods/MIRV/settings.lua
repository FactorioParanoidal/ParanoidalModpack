data:extend({
  {
    type = "bool-setting",
    name = "mirv-auto-launch",
    setting_type = "startup",
    default_value = true
  },
  {
    type = "bool-setting",
    name = "mirv-pollution-on-detonation",
    setting_type = "startup",
    default_value = true
  },
})

--/c
--[[

  start_zoom = 2 zoom = start_zoom trigger_zoom = 1 end_zoom = 0.2 trigger_duration = 15 * 60 nuke_zoom_duration = 8 * 60
  start_daytime = 0.5
  end_daytime = 1
  triggered = false
  player = game.player
  player.surface.daytime = 0.5

  script.on_event(defines.events.on_tick, function()
    if not triggered then
      zoom = zoom - ((start_zoom - trigger_zoom) / trigger_duration)
      player.zoom = zoom
      if player.surface.daytime < 0.8 then
        player.surface.daytime = player.surface.daytime + (0.3 / trigger_duration)
      end
      if zoom <= trigger_zoom then
        triggered = true
        remote.call("mirv", "call_nuke", player.surface, player.position, player)
      end
    else
      zoom = zoom - (trigger_zoom - end_zoom) / nuke_zoom_duration
      player.zoom = math.max(zoom, end_zoom)
      if zoom <= end_zoom then
        script.on_event(defines.events.on_tick, nil)
      end
    end
  end)
  ]]