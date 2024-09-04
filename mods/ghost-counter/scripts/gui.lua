Gui = {}

---Toggles mod GUI on or off
---@param player_index uint Player index
---@param state boolean true -> on, false -> off
function Gui.toggle(player_index, state)
    local playerdata = get_make_playerdata(player_index)
    state = state or not playerdata.is_active

    if state then
        playerdata.is_active = true

        -- Create mod gui and register event handler
        Gui.make_gui(player_index)
        register_inventory_monitoring(true)
        register_logistics_monitoring(true)
    else
        playerdata.is_active = false
        playerdata.job = {
            area={},
            ghosts={},
            requests={},
            requests_sorted={}
        }
        -- Destroy mod GUI and remove references to it
        if playerdata.gui.root and playerdata.gui.root.valid then
            local last_location = playerdata.gui.root.location --[[@as GuiLocation.0]]
            playerdata.gui.root.destroy()
            playerdata.gui = {last_location=last_location}
        end

        -- Unbind event hooks if no no longer needed
        if not is_inventory_monitoring_needed() then register_inventory_monitoring(false) end
        if not is_logistics_monitoring_needed() then register_logistics_monitoring(false) end
    end
end

---Make mod GUI
---@param player_index uint Player index
function Gui.make_gui(player_index)
    local playerdata = get_make_playerdata(player_index)
    local screen = playerdata.luaplayer.gui.screen
    local window_loc_x, window_loc_y

    -- Restore previous saved location, if any
    if playerdata.gui.last_location then
        local location = playerdata.gui.last_location
        local resolution = playerdata.luaplayer.display_resolution

        window_loc_x = location.x < resolution.width and location.x or nil
        window_loc_y = location.y < resolution.height and location.y or nil
    end

    -- Destory existing mod GUI if one exists
    if screen[NAME.gui.root_frame] then
        local location = screen[NAME.gui.root_frame].location
        window_loc_x, window_loc_y = location.x, location.y
        screen[NAME.gui.root_frame].destroy()
    end

    playerdata.gui.root = screen.add{
        type="frame",
        name=NAME.gui.root_frame,
        direction="vertical",
        style=NAME.style.root_frame
    }

    do
        local resolution = playerdata.luaplayer.display_resolution
        local x = window_loc_x or 50
        local y = window_loc_y or (resolution.height / 2) - 300
        playerdata.gui.root.location = {x, y}
    end

    -- Create title bar
    local titlebar_flow = playerdata.gui.root.add{
        type="flow",
        direction="horizontal",
        style=NAME.style.titlebar_flow
    }
    titlebar_flow.drag_target = playerdata.gui.root
    titlebar_flow.add{
        type="label",
        caption="Ghost Counter",
        ignored_by_interaction=true,
        style="frame_title"
    }
    titlebar_flow.add{
        type="empty-widget",
        ignored_by_interaction=true,
        style=NAME.style.titlebar_space_header
    }

    local hide_empty = playerdata.options.hide_empty_requests
    titlebar_flow.add{
        type="sprite-button",
        name=NAME.gui.hide_empty_button,
        tooltip={"ghost-counter-gui.hide-empty-requests-tooltip"},
        sprite=hide_empty and NAME.sprite.hide_empty_black or NAME.sprite.hide_empty_white,
        hovered_sprite=NAME.sprite.hide_empty_black,
        clicked_sprite=hide_empty and NAME.sprite.hide_empty_white or NAME.sprite.hide_empty_black,
        style=hide_empty and NAME.style.titlebar_button_active or NAME.style.titlebar_button
    }
    titlebar_flow.add{
        type="sprite-button",
        name=NAME.gui.close_button,
        sprite="utility/close_white",
        hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",
        tooltip={"ghost-counter-gui.close-button-tooltip"},
        style="close_button"
    }

    local deep_frame = playerdata.gui.root.add{
        type="frame",
        direction="vertical",
        style=NAME.style.inside_deep_frame
    }

    local toolbar = deep_frame.add{
        type="frame",
        direction="horizontal",
        style=NAME.style.topbar_frame
    }
    toolbar.add{
        type="sprite-button",
        name=NAME.gui.get_signals_button,
        sprite=NAME.sprite.get_signals_white,
        hovered_sprite=NAME.sprite.get_signals_black,
        clicked_sprite=NAME.sprite.get_signals_black,
        tooltip={"ghost-counter-gui.get-signals-tooltip"},
        style=NAME.style.get_signals_button
    }
    toolbar.add{
        type="empty-widget",
        style=NAME.style.topbar_space
    }
    toolbar.add{
        type="sprite-button",
        name=NAME.gui.craft_all_button,
        sprite=NAME.sprite.craft_all_white,
        hovered_sprite=NAME.sprite.craft_all_black,
        clicked_sprite=NAME.sprite.craft_all_black,
        tooltip={"ghost-counter-gui.craft-all-tooltip"},
        style=NAME.style.get_signals_button
    }
    toolbar.add{
        type="button",
        name=NAME.gui.request_all_button,
        caption={"ghost-counter-gui.request-all-caption"},
        tooltip={"ghost-counter-gui.request-all-tooltip"},
        style=NAME.style.ghost_request_all_button
    }
    toolbar.add{
        type="sprite-button",
        name=NAME.gui.cancel_all_button,
        sprite=NAME.sprite.cancel_white,
        hovered_sprite=NAME.sprite.cancel_black,
        clicked_sprite=NAME.sprite.cancel_black,
        tooltip={"ghost-counter-gui.cancel-all-tooltip"},
        style=NAME.style.ghost_cancel_all_button
    }

    playerdata.gui.requests_container = deep_frame.add{
        type="scroll-pane",
        name=NAME.gui.scroll_pane,
        style=NAME.style.scroll_pane
    }

    Gui.make_list(player_index)
end

---Creates the list of request frames in the GUI
---@param player_index uint Player index
function Gui.make_list(player_index)
    local playerdata = get_make_playerdata(player_index)

    -- Create a new row frame for each request
    playerdata.gui.requests = {}
    for _, request in pairs(playerdata.job.requests_sorted) do
        Gui.make_row(player_index, request)
    end
end

---Returns request button properties based on request fulfillment and other criteria
---@param request table `request` table
---@param one_time_request table `playerdata.logistic_requests[request.name]`
---@return boolean enabled Whehter button should be enabled
---@return string style Style that should be applied to the button
---@return LocalisedString tooltip Tooltip shown for button
function make_request_button_properties(request, one_time_request)
    local logistic_request = request.logistic_request or {}

    local enabled = ((logistic_request.min or 0) < request.count) or one_time_request and true or
                        false
    local style =
        ((logistic_request.min or 0) < request.count) and NAME.style.ghost_request_button or
            NAME.style.ghost_request_active_button

    local str = "[item=" .. request.name .. "] "

    local tooltip
    if enabled then
        tooltip = ((logistic_request.min or 0) < request.count) and
            {"ghost-counter-gui.set-temporary-request-tooltip", request.count, str} or
            {"ghost-counter-gui.unset-temporary-request-tooltip"}
    else
        tooltip = {"ghost-counter-gui.existing-logistic-request-tooltip"}
    end

    return enabled, style, tooltip
end

---Updates the list of request frames in the GUI
---@param player_index uint Player index
function Gui.update_list(player_index)
    local playerdata = get_make_playerdata(player_index)
    if not playerdata.is_active or not playerdata.gui.requests then return end

    local indices = {count=1, sprite=2, label=3, inventory=4, request=5}

    -- Update gui elements with new values
    for name, frame in pairs(playerdata.gui.requests) do
        local request = playerdata.job.requests[name]

        if request.count > 0 or not playerdata.options.hide_empty_requests then
            frame.visible = true
            -- Update ghost count
            frame.children[indices.count].caption = request.count

            -- Update amont in inventory
            frame.children[indices.inventory].caption = request.inventory

            -- Calculate amount missing
            local diff = request.count - request.inventory

            -- If amount needed exceeds amount in inventory, show request button
            local request_element = frame.children[indices.request]
            if diff > 0 then
                local enabled, style, tooltip = make_request_button_properties(request,
                                           playerdata.logistic_requests[request.name])

                if request_element.type == "button" then
                    request_element.enabled = enabled
                    request_element.style = style
                    request_element.caption = diff
                    request_element.tooltip = tooltip
                else
                    frame.children[indices.request].destroy()
                    frame.add{
                        type="button",
                        caption=diff,
                        enabled=enabled,
                        style=style,
                        tooltip=tooltip,
                        tags={ghost_counter_request=request.name}
                    }
                end
                -- Otherwise create request-fulfilled checkmark previous element was a request button
            elseif request_element.type == "button" then
                request_element.destroy()

                local sprite_container = frame.add{
                    type="flow",
                    direction="horizontal",
                    style=NAME.style.ghost_request_fulfilled_flow
                }
                sprite_container.add{
                    type="sprite",
                    sprite="utility/check_mark_white",
                    resize_to_sprite=false,
                    style=NAME.style.ghost_request_fulfilled_sprite
                }
            end
        else
            frame.visible = false
        end
    end
end

---Generates the row frame for a given request table
---@param player_index uint Player index
---@param request table `request` table, containing name, count, inventory, etc.
function Gui.make_row(player_index, request)
    local playerdata = get_make_playerdata(player_index)
    local parent = playerdata.gui.requests_container

    local localized_name = game.item_prototypes[request.name].localised_name

    -- Row frame
    local frame = parent.add{type="frame", direction="horizontal", style=NAME.style.row_frame}
    playerdata.gui.requests[request.name] = frame

    -- Ghost (item) count
    frame.add{type="label", caption=request.count, style=NAME.style.ghost_number_label}

    -- Item sprite
    frame.add{
        type="sprite",
        sprite="item/" .. request.name,
        resize_to_sprite=false,
        style=NAME.style.ghost_sprite
    }

    -- Item or tile localized name
    frame.add{type="label", caption=localized_name, style=NAME.style.ghost_name_label}

    -- Amount in inventory
    frame.add{type="label", caption=request.inventory, style=NAME.style.inventory_number_label}

    -- Calculate amount missing
    local diff = request.count - request.inventory

    -- Show one-time request logistic button
    if diff > 0 then
        local enabled, style, tooltip = make_request_button_properties(request,
                                   playerdata.logistic_requests[request.name])

        frame.add{
            type="button",
            caption=diff,
            enabled=enabled,
            style=style,
            tooltip=tooltip,
            tags={ghost_counter_request=request.name}
        }
    else -- Show request fulfilled sprite
        local sprite_container = frame.add{
            type="flow",
            direction="horizontal",
            style=NAME.style.ghost_request_fulfilled_flow
        }
        sprite_container.add{
            type="sprite",
            sprite="utility/check_mark_white",
            resize_to_sprite=false,
            style=NAME.style.ghost_request_fulfilled_sprite
        }
    end

    -- Hide frame if ghost count is 0 and player toggled hide empty requests
    frame.visible = request.count > 0 or not playerdata.options.hide_empty_requests and true or
                        false
end

---Event handler for GUI button clicks
---@param event EventData.on_gui_click Event table
function Gui.on_gui_click(event)
    local player_index = event.player_index
    local element = event.element
    local element_name = element.name

    if element.name == NAME.gui.close_button then
        -- Close button
        Gui.toggle(player_index, false)
    elseif element.tags and element.tags.ghost_counter_request then
        -- One-time logistic request/craft button
        local playerdata = get_make_playerdata(player_index)
        local request_name = element.tags.ghost_counter_request --[[@as string]]
        if event.shift == true then
            local request = playerdata.job.requests[request_name]
            if request then
                local result, crafted = craft_request(event.player_index, request)
                local player = game.get_player(player_index) --[[@as LuaPlayer]]
                if result == "no-crafts-needed" then
                    player.create_local_flying_text{
                        text={"ghost-counter-message.crafts-not-needed"},
                        create_at_cursor=true
                    }
                elseif result == "attempted" and crafted == 0 then
                    player.create_local_flying_text{
                        text={"ghost-counter-message.crafts-attempted-none"},
                        create_at_cursor=true
                    }
                end
            end
        else
            if not playerdata.logistic_requests[request_name] then
                make_one_time_logistic_request(player_index, request_name)
                Gui.update_list(player_index)
            else
                restore_prior_logistic_request(player_index, request_name)
                Gui.update_list(player_index)
            end
        end
    elseif element_name == NAME.gui.hide_empty_button then
        local playerdata = get_make_playerdata(player_index)
        local new_state = not playerdata.options.hide_empty_requests
        playerdata.options.hide_empty_requests = new_state

        element.style = new_state and NAME.style.titlebar_button_active or
                            NAME.style.titlebar_button
        element.sprite = new_state and NAME.sprite.hide_empty_black or NAME.sprite.hide_empty_white
        element.clicked_sprite = new_state and NAME.sprite.hide_empty_white or
                                     NAME.sprite.hide_empty_black

        Gui.update_list(player_index)
    elseif element_name == NAME.gui.get_signals_button then
        make_combinators_blueprint(event.player_index)
    elseif element_name == NAME.gui.craft_all_button then
        local playerdata = get_make_playerdata(player_index)
        for _, request in pairs(playerdata.job.requests) do
            craft_request(player_index, request)
        end
    elseif element_name == NAME.gui.request_all_button then
        local playerdata = get_make_playerdata(player_index)
        for _, request in pairs(playerdata.job.requests) do
            if request.count > 0 and not playerdata.logistic_requests[request.name] then
                make_one_time_logistic_request(player_index, request.name)
            end
        end

        Gui.update_list(player_index)
    elseif element_name == NAME.gui.cancel_all_button then
        cancel_all_one_time_requests(player_index)

        Gui.update_list(player_index)
    end
end
script.on_event(defines.events.on_gui_click, Gui.on_gui_click)
