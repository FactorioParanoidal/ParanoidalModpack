--[[
    "name": "AutoTrashFix",
    "title": "Auto Trash Fix",
    "author": "Tain",
    "description": "If you request an item with count > auto trash count, increases auto trash count."
--]]

local Event = require('__stdlib__/stdlib/event/event')

local function on_gui_opened(event)
    local player = game.players[event.player_index]
    if player.opened_self and not game.active_mods['AutoTrash'] and player.mod_settings['picker-fix-trash-filters'].value then
        local character = player.character
        if character then
            for i = 1, character.request_slot_count do
                local request = character.get_request_slot(i)
                if request then
                    local filters = character.auto_trash_filters
                    for trashKey, trashVal in pairs(filters) do
                        if request.name == trashKey then
                            if request.count > trashVal then
                                filters[trashKey] = request.count
                                player.auto_trash_filters = filters
                            end
                        end
                    end
                end
            end
        end
    end
end
Event.register(defines.events.on_gui_opened, on_gui_opened)
