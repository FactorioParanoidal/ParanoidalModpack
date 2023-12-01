local Events = {}

Events.on_daylight_changed_event = script.generate_event_name()

function Events.SendDaylightChangedEvent(player_index, surface_name, daytime)
    script.raise_event(Events.on_daylight_changed_event, {
        surface_name = surface_name,
        player_index = player_index,
        daytime = daytime,
    })
end

return Events
