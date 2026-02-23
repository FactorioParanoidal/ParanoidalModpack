script.on_event(defines.events.on_research_finished, function(event)
    local tech = event.research.force.technologies
    if event.research.name == "steel-processing" then
        tech["EasyWindTurbine-1"].enabled = true
    elseif event.research.name == "engine-unit" then
        tech["EasyWindTurbine-2"].enabled = true
    elseif event.research.name == "advanced-circuit" then
        tech["EasyWindTurbine-3"].enabled = true
    elseif event.research.name == "processing-unit" then
        tech["EasyWindTurbine-4"].enabled = true
    elseif event.research.name == "utility-science-pack" then
        tech["EasyWindTurbine-5"].enabled = true
    end
end)