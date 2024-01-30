for _, player in pairs(game.players) do
    local flow = player.gui.left['picker_main_flow']
    if flow then flow.destroy() end
end
