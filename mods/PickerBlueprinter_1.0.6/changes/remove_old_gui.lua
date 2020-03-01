return {
    ['1.0.4'] = function()
        for _, player in pairs(game.players) do
            local flow = player.gui.left.picker_main_flow
            if flow then
                local oldframe = flow.picker_bp_tools
                if oldframe then
                    oldframe.destroy()
                end
            end
        end
    end
}
