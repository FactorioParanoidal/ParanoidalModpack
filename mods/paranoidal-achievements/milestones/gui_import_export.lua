require("milestones.gui_settings_page")

function toggle_import_export_page(player_index, button_element, import)
    if button_element.style.name == "flib_selected_tool_button" then
        close_import_export_page(player_index)
    else
        close_import_export_page(player_index)
        build_import_export_page(player_index, button_element, import)
    end
end

local function milestones_table_to_json(milestones)
    -- Never rewrite serialised strings: group names may themselves contain JSON punctuation.
    return helpers.table_to_json(milestones)
end

function build_import_export_page(player_index, button_element, import)
    local exported
    if not import then
        local err
        exported, err = validate_milestones(get_resulting_milestones_array(player_index))
        if not exported then game.get_player(player_index).print(err); return end
    end
    local titlebar_caption = import and {"milestones.settings_import_title"} or {"milestones.settings_export_title"}

    local outer_frame = get_outer_frame(player_index)
    local import_export_frame = outer_frame.milestones_settings_import_export
    import_export_frame.milestones_settings_import_export_titlebar.milestones_settings_import_export_titlebar_label.caption = titlebar_caption

    local inside_frame = import_export_frame.milestones_settings_import_export_inside
    inside_frame.clear()

    if import then
        inside_frame.add{type="label", caption={"milestones.settings_import_description"}, style="bold_label"}
    else
        local sub_title_flow = inside_frame.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_center"}
        sub_title_flow.add{type="label", caption={"milestones.settings_export_encoded"}, style="bold_label"}
        sub_title_flow.add{type="checkbox", name="milestones_export_encoded_checkbox", state=false}
    end
    local scroll = inside_frame.add{type="scroll-pane", name="milestones_import_export_scroll"}
    local textbox = scroll.add{type="text-box", name="milestones_settings_import_export_textbox", style="milestones_import_export_textbox", horizontal_scroll_policy="dont-show-but-allow-scrolling"}
    local player = game.get_player(player_index)
    textbox.style.width = math.max(200, math.min(600, math.floor(player.display_resolution.width / player.display_scale * 0.45)))
    if not import then
        textbox.text = milestones_table_to_json(exported)
        textbox.read_only = true
    end

    local button_frame = inside_frame.add{type="flow", direction="horizontal"}
    button_frame.add{type="empty-widget", style="flib_horizontal_pusher"}
    if import then
        button_frame.add{type="button", style="dialog_button", caption={"milestones.settings_import"}, tags={action="milestones_import_settings"}}
    else
        button_frame.add{type="button", style="dialog_button", caption={"gui.close"}, tags={action="milestones_close_import_export"}}
    end

    textbox.select_all()
    textbox.focus()
    import_export_frame.visible = true
    outer_frame.force_auto_center()

    button_element.style = "flib_selected_tool_button"
end

function toggle_export_encoded(checkbox_element)
    local export_textbox = checkbox_element.parent.parent.milestones_import_export_scroll.milestones_settings_import_export_textbox
    if checkbox_element.state then
        export_textbox.text = helpers.encode_string(export_textbox.text)
        export_textbox.word_wrap = true
    else
        export_textbox.text = helpers.decode_string(export_textbox.text)
        export_textbox.word_wrap = false
    end
    export_textbox.select_all()
    export_textbox.focus()
end

function close_import_export_page(player_index)
    local outer_frame = get_outer_frame(player_index)
    local import_export_frame = outer_frame.milestones_settings_import_export
    local inside_frame = import_export_frame.milestones_settings_import_export_inside

    inside_frame.clear()
    import_export_frame.visible = false

    local settings_flow = get_inner_frame(player_index).milestones_settings_outer_flow
    if settings_flow then
        local button_flow = settings_flow.milestones_preset_flow
        button_flow.milestones_import_button.style = "tool_button"
        button_flow.milestones_export_button.style = "tool_button"
    end
end

function import_settings(player_index)
    local import_string = get_outer_frame(player_index)
                              .milestones_settings_import_export
                              .milestones_settings_import_export_inside
                              .milestones_import_export_scroll
                              .milestones_settings_import_export_textbox.text

    if string.len(import_string) == 0 then
        return
    end
    local imported_milestones, err = convert_and_validate_imported_json(import_string)
    if imported_milestones == nil then
        game.players[player_index].print(err)
    else
        switch_to_milestones_set(imported_milestones, player_index)
        local preset_dropdown = get_inner_frame(player_index).milestones_settings_outer_flow.milestones_preset_flow.milestones_preset_dropdown
        preset_dropdown.caption = {"milestones.settings_imported"}
        preset_dropdown.tags = {action="milestones_change_preset", imported=true} -- For some reason, can't just change a single tag
        close_import_export_page(player_index)
    end
end
