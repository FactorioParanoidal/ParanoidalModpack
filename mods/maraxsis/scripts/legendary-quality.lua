local function do_check(force)
    local vanilla = force.technologies["legendary-quality"]
    if not vanilla then return end
    local modded = force.technologies["maraxsis-legendary-quality"]
    if not modded then return end

    if not vanilla.researched and not modded.researched then return end

    vanilla.researched = true
    modded.researched = true
    modded.enabled = false
    modded.visible_when_disabled = false
end

maraxsis.on_nth_tick(2953, function()
    for _, force in pairs(game.forces) do
        do_check(force)
    end
end)

maraxsis.on_event(defines.events.on_research_finished, function()
    for _, force in pairs(game.forces) do
        do_check(force)
    end
end)
