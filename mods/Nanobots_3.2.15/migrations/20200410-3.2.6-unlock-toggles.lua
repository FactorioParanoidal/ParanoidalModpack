for _, force in pairs(game.forces) do
    for _, shortcut in pairs(game.shortcut_prototypes) do
        for _, player in pairs(force.players) do
            local unlock = shortcut.technology_to_unlock
            if unlock and force.technologies[unlock.name].researched and shortcut.action == 'lua' and not player.is_shortcut_available(shortcut.name) then
                player.set_shortcut_available(shortcut.name, true)
                player.set_shortcut_toggled(shortcut.name, true)
            end
        end
    end
end
