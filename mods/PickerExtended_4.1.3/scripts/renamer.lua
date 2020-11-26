-------------------------------------------------------------------------------
--[Picker Renamer]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')
local Player = require('__stdlib__/stdlib/event/player')

local function spawn_rename_gui(player, pdata)
    local frame = player.gui.center.picker_rename_frame
    if not frame then
        frame = player.gui.center.add {type = 'frame', name = 'picker_rename_frame'}
        frame.add {type = 'button', name = 'picker_rename_x', caption = ' X ', style = 'picker-rename-button'}
        frame.add {type = 'textfield', name = 'picker_rename_textfield'}
        frame.add {type = 'button', name = 'picker_rename_button', caption = 'OK', style = 'picker-rename-button'}
    end
    frame.picker_rename_textfield.text = pdata.rename_ent and pdata.rename_ent.valid and pdata.rename_ent.backer_name
    return frame
end

Gui.on_click(
    'picker_rename_x',
    function(event)
        game.players[event.player_index].gui.center.picker_rename_frame.destroy()
        global.players[event.player_index].rename_ent = nil
    end
)

Gui.on_click(
    'picker_rename_button',
    function(event)
        local player, pdata = Player.get(event.player_index)
        if pdata.rename_ent and pdata.rename_ent.valid then
            pdata.rename_ent.backer_name = player.gui.center.picker_rename_frame.picker_rename_textfield.text
        end
        player.gui.center.picker_rename_frame.destroy()
        pdata.rename_ent = nil
    end
)

local function picker_rename(event)
    local player, pdata = Player.get(event.player_index)
    local selection = player.selected
    if selection then
        if selection.supports_backer_name() then
            global.players[event.player_index].rename_ent = selection
            spawn_rename_gui(player, pdata)
        else
            player.print({'picker.selection-not-renamable'})
        end
    end
end
Event.register('picker-rename', picker_rename)

return picker_rename
