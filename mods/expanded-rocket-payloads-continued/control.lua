--when satellite tracking tech is researched the mod's payloads get added to the UI for payloads launched

script.on_event(defines.events.on_research_finished, function(event)
    if event.research.name == 'satellite-tracking' then
        if not remote.interfaces["silo_script"] or not remote.interfaces["silo_script"]["add_tracked_item"] then return end
         remote.call("silo_script", "add_tracked_item", "advanced-probe")
         remote.call("silo_script", "add_tracked_item", "space-lab")
         remote.call("silo_script", "add_tracked_item", "space-telescope")
         remote.call("silo_script", "add_tracked_item", "space-shuttle")
         remote.call("silo_script", "add_tracked_item", "spy-shuttle")
         remote.call("silo_script", "add_tracked_item", "mining-shuttle")
         remote.call("silo_script", "add_tracked_item", "orbital-solar-collector")
         remote.call("silo_script", "add_tracked_item", "observation-satellite")
         remote.call("silo_script", "add_tracked_item", "fabricator-shuttle")
    end
end)