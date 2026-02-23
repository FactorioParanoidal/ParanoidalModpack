for _, player in pairs(game.players) do
    if player.gui.screen.overlay then
        player.gui.screen.overlay.destroy()
    end

    local screen_flow = player.gui.screen

    local res = player.display_resolution
    local sprite_size = 384

    if screen_flow.radiation_logo then
        screen_flow.radiation_logo.location = {
            (res.width - sprite_size) / 2,
            (res.height - sprite_size) / 2
        }
    end
end
