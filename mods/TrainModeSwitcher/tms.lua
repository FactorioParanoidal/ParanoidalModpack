function tms_toggle(event)
    local player = game.players[event.player_index]

    if not player or not player.valid then
        return
    end

    if player.selected then
        if player.selected.train and player.selected.train.valid then
            local train = player.selected.train

            if train.manual_mode == true then
                train.manual_mode = false
            else
                train.manual_mode = true
            end
        end
    else
        tms_provide_selectiontool(event)
    end
end

function tms_provide_selectiontool(event)
    local player = game.players[event.player_index]

    if not player or not player.valid then
        return
    end

    if player.cursor_stack and player.cursor_stack.valid and player.cursor_stack.valid_for_read and player.cursor_stack.name == "tms-switcher" then
        return
    end

    if not player.clear_cursor() then
        return
    end

    player.cursor_stack.set_stack({
        name = "tms-switcher",
        count = 1
    })
end

function tms_enact(player, event, alt)
    local config = settings.get_player_settings(player)

    local trains_switched = {}
    for _, ent in pairs(event.entities) do
        if ent.valid then
            if ent.train and ent.train.valid then
                local train = ent.train

                if not trains_switched[train.id] then
                    if config['tms-alt-mode'].value then
                        if alt then
                            train.manual_mode = true
                        else
                            train.manual_mode = false
                        end
                    elseif train.manual_mode == true then
                        train.manual_mode = false
                    else
                        train.manual_mode = true
                    end

                    trains_switched[train.id] = true
                end
            end
        end
    end
end

function tms_selectiontool(event)
    local player = game.players[event.player_index]

    if not player or not player.valid or not event.entities or event.item ~= "tms-switcher" then
        return
    end

    tms_enact(player, event, false)
end

function tms_selectiontool_alt(event)
    local player = game.players[event.player_index]

    if not player or not player.valid or not event.entities or event.item ~= "tms-switcher" then
        return
    end

    tms_enact(player, event, true)
end

function tms_shortcut(event)
    local player = game.players[event.player_index]

    if not player or not player.valid or not event.prototype_name or event.prototype_name ~= "tms-toggle" then
        return
    end

    tms_toggle(event)
end