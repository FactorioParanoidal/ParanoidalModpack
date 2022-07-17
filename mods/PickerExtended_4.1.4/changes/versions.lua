return {
    ['3.0.0'] = function()
        for _, player in pairs(game.players) do
            local gui = player.gui.center['picker_quick_picker']
            if gui then
                gui.destroy()
            end
        end
        global.notes_by_invis = global.notes_by_invis or {}
        global.notes_by_target = global.notes_by_target or {}
        global.n_note = global.n_note or 0
    end,
    ['4.0.0'] = function()
        global.notes_by_invis = nil
        global.notes_by_target = nil
        global.n_note = nil
    end
}
