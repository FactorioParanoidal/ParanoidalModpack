require("scripts.gui_display_page")
require("scripts.gui_settings_page")
require("scripts.gui_import_export")

local function get_frame(player_index, frame_name)
    local global_player = global.players[player_index]
    if not global_player[frame_name] or not global_player[frame_name].valid then
        reinitialize_player(player_index)
    end
    return global.players[player_index][frame_name]
end

function get_outer_frame(player_index)
    return get_frame(player_index, "outer_frame")
end

function get_main_frame(player_index)
    return get_frame(player_index, "main_frame")
end

function get_inner_frame(player_index)
    return get_frame(player_index, "inner_frame")
end

function build_gui_frames(player)
    local screen_element = player.gui.screen
    local outer_frame = screen_element.add{type="frame", name="milestones_outer_frame", style="outer_frame", visible=false}
    local main_frame = outer_frame.add{type="frame", name="milestones_main_frame", direction="vertical"}

    local titlebar = main_frame.add{type="flow", name="milestones_titlebar", style="flib_titlebar_flow", direction="horizontal"}
    titlebar.add{
        type="label",
        name="milestones_main_label",
        style="frame_title",
        caption={"milestones.title"},
        ignored_by_interaction=true
    }
    titlebar.add{type="empty-widget", style="flib_titlebar_drag_handle", ignored_by_interaction=true}
    local settings_button = titlebar.add{
        type="sprite-button",
        name="milestones_settings_button",
        style="frame_action_button",
        sprite="milestones_settings_white", 
        hovered_sprite="milestones_settings_black", 
        clicked_sprite="milestones_settings_black", 
        mouse_button_filter={"left"},
        tooltip = {"milestones.settings_instructions"},
        tags={
            action="milestones_open_settings"
        }
    }
    if not player.admin then
        settings_button.enabled = false
        settings_button.tooltip = {"milestones.settings_disabled"}
        settings_button.sprite = "milestones_settings_disabled"
        settings_button.hovered_sprite = "milestones_settings_disabled"
        settings_button.clicked_sprite = "milestones_settings_disabled"
    end
    titlebar.add{
        type="sprite-button",
        name="milestones_pin_button",
        style="frame_action_button",
        mouse_button_filter={"left"},
        sprite="milestones_pin_white",
        hovered_sprite="milestones_pin_black",
        clicked_sprite="milestones_pin_black",
        tooltip = {"milestones.pin_instructions"},
        tags={
            action="milestones_pin_gui"
        }
    }
    titlebar.add{
        type="sprite-button",
        name="milestones_close_button",
        style="frame_action_button",
        mouse_button_filter={"left"},
        sprite="utility/close_white",
        hovered_sprite="utility/close_black",
        clicked_sprite="utility/close_black",
        tooltip = {"gui.close-instruction"},
        tags={
            action="milestones_close_gui"
        }
    }
    titlebar.drag_target = outer_frame

    local inner_frame = main_frame.add{type="frame", name="milestones_inner_frame", direction="vertical", style="inside_shallow_frame"}

    local dialog_buttons_bar = main_frame.add{type="flow", style="dialog_buttons_horizontal_flow", name="milestones_dialog_buttons", direction="horizontal"}
    dialog_buttons_bar.add{type="button", style="back_button", caption={"milestones.settings_back"}, tags={action="milestones_cancel_settings"}}
    dialog_buttons_bar.add{type="empty-widget", style="flib_dialog_footer_drag_handle", ignored_by_interaction=true}
    dialog_buttons_bar.add{type="button", style="confirm_button", caption={"milestones.settings_confirm"}, tags={action="milestones_confirm_settings"}}
    dialog_buttons_bar.drag_target = outer_frame

    -- Import/export side menu

    local import_export_frame = outer_frame.add{type="frame", name="milestones_settings_import_export", style="inner_frame_in_outer_frame", direction="vertical", visible=false}
    local import_export_titlebar = import_export_frame.add{type="flow", name="milestones_settings_import_export_titlebar", style="flib_titlebar_flow", direction="horizontal"}
    import_export_titlebar.add{
        type="label",
        name="milestones_settings_import_export_titlebar_label",
        style="frame_title",
        ignored_by_interaction=true
    }
    import_export_titlebar.add{type="empty-widget", style="flib_titlebar_drag_handle", ignored_by_interaction=true}
    import_export_titlebar.drag_target = outer_frame

    import_export_frame.add{type="flow", name="milestones_settings_import_export_inside", direction="vertical"}

    return outer_frame, main_frame, inner_frame
end

local function update_settings_button(player) -- In case permissions changed
    local main_frame = get_main_frame(player.index)
    settings_button = main_frame.milestones_titlebar.milestones_settings_button

    if player.admin then
        settings_button.enabled = true
        settings_button.tooltip = {"milestones.settings_instructions"}
        settings_button.sprite = "milestones_settings_white"
        settings_button.hovered_sprite = "milestones_settings_black"
        settings_button.clicked_sprite = "milestones_settings_black"
    else
        settings_button.enabled = false
        settings_button.tooltip = {"milestones.settings_disabled"}
        settings_button.sprite = "milestones_settings_disabled"
        settings_button.hovered_sprite = "milestones_settings_disabled"
        settings_button.clicked_sprite = "milestones_settings_disabled"
    end
end

local function open_gui(player)
    local global_player = global.players[player.index]
    local outer_frame = get_outer_frame(player.index)
    build_display_page(player)
    update_settings_button(player)
    outer_frame.visible = true
    outer_frame.bring_to_front()
    player.opened = get_main_frame(player.index)
    player.set_shortcut_toggled("milestones_toggle_gui", true)

    if not global_player.opened_once_before then -- Open in the center the first time
        outer_frame.force_auto_center()
        global_player.opened_once_before = true
    end
end

local function close_gui(player)
    local outer_frame = get_outer_frame(player.index)
    outer_frame.visible = false
    outer_frame.auto_center = false -- Remove auto_center from the force_auto_center() that we did for the first open
    get_inner_frame(player.index).clear()

    local import_export_frame = outer_frame.milestones_settings_import_export
    local import_export_inside_frame = import_export_frame.milestones_settings_import_export_inside
    import_export_inside_frame.clear()
    import_export_frame.visible = false

    player.set_shortcut_toggled("milestones_toggle_gui", false)
    if player.opened == get_main_frame(player.index) then
        player.opened = nil
    end
end

local function toggle_gui(player)
    local visible = get_outer_frame(player.index).visible
    if visible == false then
        open_gui(player)
    else
        close_gui(player)
    end
end

function refresh_gui_for_player(player)
    if is_display_page_visible(player.index) then
        get_inner_frame(player.index).clear()
        build_display_page(player)
    end
end

function refresh_gui_for_force(force)
    for _, player in pairs(force.players) do
        refresh_gui_for_player(player)
    end
end

local function toggle_pinned(player, element)
    local global_player = global.players[player.index]
    global_player.pinned = not global_player.pinned
    if global_player.pinned then
        element.style = "flib_selected_frame_action_button"
        element.sprite = "milestones_pin_black"
        player.opened = nil
    else
        element.style = "frame_action_button"
        element.sprite = "milestones_pin_white"
        local main_frame = get_main_frame(player.index)
        if player.opened == nil then
            player.opened = main_frame
        elseif player.opened ~= main_frame then
            close_gui(player)
        end
    end
end

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element and event.element.name == "milestones_main_frame" then

        local player = game.get_player(event.player_index)
        local global_player = global.players[event.player_index]
        if global_player.one_time_prevent_close then
            global_player.one_time_prevent_close = false
            player.opened = get_main_frame(player.index)
        elseif not global_player.pinned then
            close_gui(player)
        end
    end
end)

script.on_event(defines.events.on_player_display_resolution_changed, function(event)
    local player = game.players[event.player_index]
    refresh_gui_for_player(player)
end)

script.on_event(defines.events.on_player_display_scale_changed, function(event)
    local player = game.players[event.player_index]
    refresh_gui_for_player(player)
end)

-- Quickbar shortcut
script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name == "milestones_toggle_gui" then
        local player = game.get_player(event.player_index)
        toggle_gui(player)
    end
end)

-- Keyboard shortcuts
script.on_event("milestones_toggle_gui", function(event)
    local player = game.get_player(event.player_index)
    toggle_gui(player)
end)

-- Override `E` on the settings page
script.on_event("milestones_confirm_settings", function(event)
    if is_settings_page_visible(event.player_index) then
        confirm_settings_page(event.player_index)
        global.players[event.player_index].one_time_prevent_close = true
    end
end)

-- Override `Escape` on the settings page
script.on_event("milestones_cancel_settings", function(event)
    if is_settings_page_visible(event.player_index) then
        cancel_settings_page(event.player_index)
        global.players[event.player_index].one_time_prevent_close = true
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_close_gui" then
        local player = game.get_player(event.player_index)
        close_gui(player)
    elseif event.element.tags.action == "milestones_pin_gui" then
        local player = game.get_player(event.player_index)
        toggle_pinned(player, event.element)
    elseif event.element.tags.action == "milestones_open_settings" then
        local player = game.get_player(event.player_index)
        get_inner_frame(player.index).clear()
        build_settings_page(player)
    elseif event.element.tags.action == "milestones_cancel_settings" then
        cancel_settings_page(event.player_index)
    elseif event.element.tags.action == "milestones_confirm_settings" then
        confirm_settings_page(event.player_index)
    elseif event.element.tags.action == "milestones_swap_setting" then
        swap_settings(event.player_index, event)
    elseif event.element.tags.action == "milestones_delete_settings" then
        delete_selected_settings(event.player_index)
    elseif event.element.tags.action == "milestones_add_setting" then
        add_setting(event.player_index, event.element)
    elseif event.element.tags.action == "milestones_edit_time" then
        enable_edit_time(event.player_index, event.element)
    elseif event.element.tags.action == "milestones_confirm_edit_time" then
        confirm_edit_time(event.player_index, event.element)
    elseif event.element.tags.action == "milestones_open_import" then
        toggle_import_export_page(event.player_index, event.element, true)
    elseif event.element.tags.action == "milestones_open_export" then
        toggle_import_export_page(event.player_index, event.element, false)
    elseif event.element.tags.action == "milestones_close_import_export" then
        close_import_export_page(event.player_index)
    elseif event.element.tags.action == "milestones_import_settings" then
        import_settings(event.player_index)
    elseif event.element.tags.action == "milestones_settings_infinity_button" then
        toggle_infinity_button(event.element)
    elseif event.element.tags.action == "milestones_select_setting" then -- have to use on_gui_click instead of on_gui_checked_state_changed so we can check for shift
        select_setting(event)
    end
end)

-- Textfield enter
script.on_event(defines.events.on_gui_confirmed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_confirm_edit_time_textfield" then
        confirm_edit_time(event.player_index, event.element)
    end
end)

-- Checkboxes
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.name == "milestones_export_encoded_checkbox" then
        toggle_export_encoded(event.element)
    end
end)

-- Dropdowns
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if not event.element then return end
    if not event.element.tags then return end
    if event.element.tags.action == "milestones_change_preset" then
        preset_dropdown_changed(event)
    end
end)
