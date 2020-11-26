-- Activate and toggle the shortcuts in an existing game if the research is complete.
for _, player in pairs(game.players) do
    local force = player.force
    for _, shortcut in pairs(game.shortcut_prototypes) do
        if shortcut.name:find('^toggle%-') and not player.is_shortcut_available(shortcut.name) then
            local tech = shortcut.technology_to_unlock
            if tech and force.technologies[tech.name].researched then
                player.set_shortcut_available(shortcut.name, true)
                player.set_shortcut_toggled(shortcut.name, true)
            end
        end
    end
end
