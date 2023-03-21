local misc = require("__flib__.misc")
require("scripts.milestones_util")

local function get_timestamp(ticks, print_milliseconds)
    if print_milliseconds then
        local remaining_ticks = ticks % 60
        local milliseconds = math.floor((16.66666 * remaining_ticks) + 0.5) -- 16.666666 milliseconds per tick, rounded to int
        return misc.ticks_to_timestring(ticks) .. "." .. string.format("%03d", milliseconds)
    else
        return misc.ticks_to_timestring(ticks)
    end

end

local function add_milestone_label(milestone_flow, milestone, compact_list, show_estimations, print_milliseconds)
    local caption
    local tooltip
    local show_edit_button = false
    if milestone.completion_tick == nil then
        caption = {"", "[color=100,100,100]", {"milestones.incomplete_label"}, "[/color]"}
    else
        local precision_window_in_minutes = 0
        if milestone.lower_bound_tick ~= nil then
            precision_window_in_minutes = math.ceil((milestone.completion_tick - milestone.lower_bound_tick) / 2 / 60 / 60)
        end

        local label_name
        if compact_list then
            label_name = ""
        elseif milestone.type == "kill" then
            label_name = {"", {"milestones.killed_label"}, " "}
        elseif milestone.type == "technology" then
            label_name = {"", {"milestones.researched_label"}, " "}
        else
            label_name = {"", {"milestones.completed_label"}, " "}
        end

        if precision_window_in_minutes < 1 or (not show_estimations and precision_window_in_minutes < 60) then -- <1 minute, or doesn't want estimations shown. Just print the normal time.
            caption = {"", label_name, "[font=default-bold]", get_timestamp(milestone.completion_tick, print_milliseconds), "[img=quantity-time][/font]"}
        elseif precision_window_in_minutes < 60 then --<1 hour, print the in-between time then ± X minutes
            tooltip = milestone.type == "technology" and {"milestones.estimation_tooltip_technology"} or {"milestones.estimation_tooltip"}
            local in_between_tick = ceil_to_nearest_minute(milestone.lower_bound_tick - 1 + (milestone.completion_tick - (milestone.lower_bound_tick -1)) / 2)
            caption = {"", label_name, "[font=default-bold]", get_timestamp(in_between_tick, print_milliseconds), "[img=quantity-time][/font] ",
                        {"milestones.plus_minus_minutes", precision_window_in_minutes}}
        else -- Big window, print min-max
            tooltip = milestone.type == "technology" and {"milestones.estimation_tooltip_technology"} or {"milestones.estimation_tooltip"}
            local lower_tick = floor_to_nearest_minute(milestone.lower_bound_tick)
            local upper_tick = ceil_to_nearest_minute(milestone.completion_tick)
            caption = "[font=default-bold]" ..get_timestamp(lower_tick, false).. "[img=quantity-time][/font] - " ..
            "[font=default-bold]" ..get_timestamp(upper_tick, false).. "[img=quantity-time][/font]"
            show_edit_button = true
        end
    end

    milestone_flow.add{type="label", name="milestones_display_time", caption=caption, tooltip=tooltip}

    -- Optional edit button
    if show_edit_button then
        milestone_flow.add{type="sprite-button", name="milestones_edit_time", sprite="utility/rename_icon_small_white", style="milestones_small_button", 
            tooltip={"milestones.edit_time_tooltip"}, tags={action="milestones_edit_time"}}
    end
end

local function add_milestone_item(gui_table, milestone, print_milliseconds, compact_list, show_estimations)
    local milestone_flow = gui_table.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big_display", tags={index=milestone.sort_index}}
    local prototype = nil
    if milestone.type == "item" then
        prototype = game.item_prototypes[milestone.name]
    elseif milestone.type == "fluid" then
        prototype = game.fluid_prototypes[milestone.name]
    elseif milestone.type == "technology" then
        prototype = game.technology_prototypes[milestone.name]
    elseif milestone.type == "kill" then
        prototype = game.entity_prototypes[milestone.name]
    end

    if prototype == nil then
        log("Milestones error! Invalid milestone: " .. serpent.line(milestone))
        milestone_flow.add{type="label", caption={"", "[color=red]", {"", {"milestones.invalid_entry"}, " "}, milestone.name, "[/color]"}}
        return
    end

    -- Sprite
    local sprite_path_prefix = milestone.type == "kill" and "entity" or milestone.type
    local sprite_path = sprite_path_prefix .. "/" .. milestone.name
    local sprite_number
    local tooltip = milestone.tooltip   -- Milestone tooltip has precidence
    if milestone.quantity > 1 then
        sprite_number = milestone.quantity
        tooltip = tooltip or {"", milestone.quantity, "x ", prototype.localised_name}
    end
    if milestone.type == "technology" then
        local postfix = milestone.quantity == 1 and {"milestones.type_technology"} or "Level "..milestone.quantity
        tooltip = tooltip or {"", prototype.localised_name, " (", postfix, ")"}
    elseif milestone.type == "kill" then
        local prefix = milestone.quantity == 1 and "" or milestone.quantity .."x "
        tooltip = tooltip or {"", prefix, prototype.localised_name, " (", {"milestones.type_kill"}, ")"}
    else
        local prefix = milestone.quantity == 1 and "" or milestone.quantity .."x "
        tooltip = tooltip or {"", prefix, prototype.localised_name}
    end
    milestone_flow.add{type="sprite-button", sprite=sprite_path, number=sprite_number, tooltip=tooltip, style="transparent_slot"}

    -- Item name
    add_milestone_label(milestone_flow, milestone, compact_list, show_estimations, print_milliseconds)
end

local function find_complete_milestone_from_UI_flow(milestone_flow, global_force)
    local milestone_index = milestone_flow.tags.index
    for _, milestone in pairs(global_force.complete_milestones) do
        if milestone.sort_index == milestone_index then
            return milestone
        end
    end
    error("Couldn't find milestone from UI flow")
end

function enable_edit_time(player_index, element)
    local force = game.players[player_index].force
    local milestone_flow = element.parent
    local milestone = find_complete_milestone_from_UI_flow(milestone_flow, global.forces[force.name])

    milestone_flow.milestones_display_time.destroy()
    milestone_flow.milestones_edit_time.destroy()

    local default_value = misc.ticks_to_timestring(ceil_to_nearest_minute(milestone.completion_tick))
    local textfield = milestone_flow.add{type="textfield", name="milestones_edit_time_field",
        text=default_value, numeric=false,
        tags={action="milestones_confirm_edit_time_textfield"}, style="milestones_small_textfield"}
    textfield.focus()
    textfield.select_all()

    milestone_flow.add{type="sprite-button", name="milestones_confirm_edit_time", sprite="utility/check_mark_white", style="milestones_confirm_button",
        tooltip={"milestones.edit_time_confirm"}, tags={action="milestones_confirm_edit_time"}}
end

local function parse_exact_time_to_ticks(time_string)
    local time_parts = {}
    for part in string.gmatch(time_string, "[^:]+") do
        local number = tonumber(part)
        if not number or number < 0 then return nil end
        table.insert(time_parts, number)
    end
    if #time_parts == 3 then
        return time_parts[1]*60*60*60 + time_parts[2]*60*60 + time_parts[3]*60
    elseif #time_parts == 2 then
        return time_parts[1]*60*60 + time_parts[2]*60
    else
        return nil
    end
end

function confirm_edit_time(player_index, element)
    local force = game.players[player_index].force
    local milestone_flow = element.parent
    local milestone = find_complete_milestone_from_UI_flow(milestone_flow, global.forces[force.name])

    local time_quantity = milestone_flow.milestones_edit_time_field.text
    if time_quantity ~= nil then
        local completion_tick
        completion_tick = parse_exact_time_to_ticks(time_quantity)
        if completion_tick then -- Could still be nil in case of parse error
            milestone.completion_tick = completion_tick
            milestone.lower_bound_tick = nil
            sort_milestones(global.forces[force.name].complete_milestones)
            sort_milestones(global.forces[force.name].milestones_by_group[milestone.group])
        end
    end

    refresh_gui_for_force(force)
end

local function get_row_count(milestone_counts_by_group, column_count)
    row_count = 0
    for _, milestone_count_in_group in pairs(milestone_counts_by_group) do
        row_count = row_count + math.ceil(milestone_count_in_group / column_count) + 1
    end
    return row_count
end

local function get_column_count_with_groups(player, milestones_by_group, compact_list, show_estimations)
    local nb_groups = table_size(milestones_by_group)

    local real_width = player.display_resolution.width * (1 / player.display_scale)
    local target_width = real_width * 0.9
    -- 278px is about the max width of one column (3-digit hours time and 2-digit estimation)
    local max_column_width = 283
    if compact_list then
        max_column_width = max_column_width - 76
    end
    if show_estimations then
        max_column_width = math.max(max_column_width, 264) -- "XXX - XXX" estimation window is 264px
    else
        max_column_width = max_column_width - 47
    end
    local max_nb_columns = math.ceil(target_width / max_column_width) - 1
    local row_count = nb_groups * 2
    local column_count = 1
    local milestone_counts_by_group = {}
    for _group_name, group_milestones in pairs(milestones_by_group) do
        table.insert(milestone_counts_by_group, #group_milestones)
        column_count = math.max(column_count, #group_milestones)

        if column_count >= max_nb_columns then
            column_count = max_nb_columns
        end
    end

    -- This tries to keep 3 rows per column, which results in roughly 16:9 shape
    row_count = get_row_count(milestone_counts_by_group, column_count)
    while row_count < column_count * 3 do
        column_count = column_count - 1
        row_count = get_row_count(milestone_counts_by_group, column_count)
    end

    return column_count
end

local function add_n_empty_widgets(table, n)
    for i = 1, n, 1 do
        table.add({type="empty-widget"})
    end
end

function build_display_page(player)
    local main_frame = get_main_frame(player.index)
    main_frame.milestones_titlebar.milestones_main_label.caption = {"milestones.title"}
    main_frame.milestones_titlebar.milestones_settings_button.visible = true
    main_frame.milestones_titlebar.milestones_close_button.visible = true
    main_frame.milestones_dialog_buttons.visible = false

    local inner_frame = get_inner_frame(player.index)
    inner_frame.clear() -- Just in case the GUI didn't close through close_gui
    local display_scroll = inner_frame.add{type="scroll-pane", name="milestones_display_scroll", style="flib_naked_scroll_pane"}

    local global_force = global.forces[player.force.name]

    local print_milliseconds = settings.global["milestones_check_frequency"].value < 60
    local compact_list = settings.get_player_settings(player)["milestones_compact_list"].value
    local view_by_group = settings.get_player_settings(player)["milestones_list_by_group"].value
    local show_estimations = settings.get_player_settings(player)["milestones_show_estimations"].value

    local nb_groups = table_size(global_force.milestones_by_group)
    if view_by_group and nb_groups > 1 then
        local column_count = get_column_count_with_groups(player, global_force.milestones_by_group, compact_list, show_estimations)
        local milestones_table = display_scroll.add{type="table", column_count=column_count, style="milestones_table_style"}
        local i = 1
        for group_name, group_milestones in pairs(global_force.milestones_by_group) do
            -- Group title
            milestones_table.add({type="label", caption=group_name, style="caption_label"})
            add_n_empty_widgets(milestones_table, column_count-1)

            for _, milestone in pairs(group_milestones) do
                add_milestone_item(milestones_table, milestone, print_milliseconds, compact_list, show_estimations)
            end
            add_n_empty_widgets(milestones_table, column_count - (#group_milestones % column_count))

            -- Lines
            if i < nb_groups then -- Don't add line after the last group
                if column_count == 1 then
                    milestones_table.add({type="line"})
                else
                    milestones_table.add({type="line", style="milestones_line_left"})
                    for j = 2, column_count-1 do
                        milestones_table.add({type="line", style="milestones_line_center"})
                    end
                    milestones_table.add({type="line", style="milestones_line_right"})
                end
                i = i + 1
            end
        end
    else
        -- This tries to keep 3 rows per column, which results in roughly 16:9 shape
        local nb_milestones = #global_force.complete_milestones + #global_force.incomplete_milestones
        local column_count = math.max(
            math.min(
                math.ceil(math.sqrt(nb_milestones / 3)),
                8),
            1)

        local content_table = display_scroll.add{type="table", column_count=column_count, style="milestones_table_style"}
        for _, milestone in pairs(global_force.complete_milestones) do
            add_milestone_item(content_table, milestone, print_milliseconds, compact_list, show_estimations)
        end

        for _, milestone in pairs(global_force.incomplete_milestones) do
            add_milestone_item(content_table, milestone, print_milliseconds, compact_list, show_estimations)
        end
    end
end

function is_display_page_visible(player_index)
    return get_inner_frame(player_index).milestones_display_scroll ~= nil
end
