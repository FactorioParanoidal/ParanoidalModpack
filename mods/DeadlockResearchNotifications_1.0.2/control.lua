script.on_init(function()
	if settings.startup["deadlock-force-research-queue"].value then game.forces["player"].research_queue_enabled = true end
end)

script.on_event(defines.events.on_research_finished, function(event)
	event.research.force.print({"", "[color=192,255,192]", {"notification.research-complete", event.research.name}, "[/color]"})
end)
