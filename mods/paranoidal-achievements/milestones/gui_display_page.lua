local flib_format = require("__flib__.format")
local identity = require("milestones.identity")
local schema = require("milestones.schema")
require("milestones.milestones_util")

local PAGE_SIZE = 120
local empty_set_label = {type="label", caption={"", "[color=100,100,100]", {"milestones.no_visible_milestones"}, "[/color]"}, style="caption_label"}

local function get_timestamp(ticks, print_milliseconds)
    if print_milliseconds then
        local milliseconds = math.floor((1000 / 60 * (ticks % 60)) + 0.5)
        return flib_format.time(ticks) .. "." .. string.format("%03d", milliseconds)
    end
    return flib_format.time(ticks)
end

local function add_milestone_label(flow, milestone, compact, estimations, milliseconds, can_edit)
    local caption, tooltip, editable
    if milestone.completion_tick == nil then
        caption = {"", "[color=100,100,100]", {"milestones.incomplete_label"}, "[/color]"}
    else
        local window = milestone.lower_bound_tick and
            math.ceil((milestone.completion_tick - milestone.lower_bound_tick) / 7200) or 0
        local label = compact and "" or {"", {"milestones." .. (milestone.type == "kill" and "killed_label"
            or milestone.type == "technology" and "researched_label" or "completed_label")}, " "}
        if window < 1 or not estimations and window < 60 then
            caption = {"", label, "[font=default-bold]", get_timestamp(milestone.completion_tick, milliseconds), "[img=quantity-time][/font]"}
        elseif window < 60 then
            tooltip = {milestone.type == "technology" and "milestones.estimation_tooltip_technology" or "milestones.estimation_tooltip"}
            local middle = ceil_to_nearest_minute((milestone.lower_bound_tick - 1 + milestone.completion_tick) / 2)
            caption = {"", label, "[font=default-bold]", get_timestamp(middle, milliseconds),
                "[img=quantity-time][/font] ", {"milestones.plus_minus_minutes", window}}
        else
            tooltip = {milestone.type == "technology" and "milestones.estimation_tooltip_technology" or "milestones.estimation_tooltip"}
            caption = "[font=default-bold]" .. get_timestamp(floor_to_nearest_minute(milestone.lower_bound_tick), false)
                .. "[img=quantity-time][/font] - [font=default-bold]"
                .. get_timestamp(ceil_to_nearest_minute(milestone.completion_tick), false) .. "[img=quantity-time][/font]"
            editable = can_edit
        end
    end
    flow.add{type="label", name="milestones_display_time", caption=caption, tooltip=tooltip}
    if editable then
        flow.add{type="sprite-button", name="milestones_edit_time", sprite="rename_icon_small_white", style="milestones_small_button",
            tooltip={"milestones.edit_time_tooltip"}, tags={action="milestones_edit_time"}}
    end
end

local function add_milestone_item(parent, milestone, force_index, milliseconds, compact, estimations, can_edit)
    local flow = parent.add{type="flow", direction="horizontal", style="milestones_horizontal_flow_big_display",
        tags={milestone_id=milestone.id, force_index=force_index}}
    local prototype = get_milestone_prototype(milestone)
    if not prototype or milestone.quality and not prototypes.quality[milestone.quality] then
        flow.add{type="label", caption={"", {"milestones.invalid_entry"}, " ", milestone.name}}
        return
    end
    local sprite = sprite_prefix(milestone) .. "/" .. milestone.name
    local number = milestone.quantity > 1 and milestone.quantity or nil
    local tooltip = milestone.tooltip
    if not tooltip then
        if milestone.type == "technology" then
            local postfix = milestone.quantity == 1 and {"milestones.type_technology"} or "Level " .. milestone.quantity
            if prototype.hidden then postfix = {"milestones.type_event"} end
            tooltip = {"", prototype.localised_name, " (", postfix, ")"}
        else
            local prefix = milestone.quantity == 1 and "" or milestone.quantity .. "x "
            local quality = milestone.quality and {"", " (", prototypes.quality[milestone.quality].localised_name, ")"} or ""
            local kind = milestone.type == "kill" and {"milestones.type_kill"}
                or (milestone.type == "item_consumption" or milestone.type == "fluid_consumption") and {"milestones.type_consumption"}
            tooltip = {"", prefix, prototype.localised_name, quality, kind and {"", " (", kind, ")"} or ""}
        end
    end
    if milestone.quality then
        local icon = flow.add{type="sprite-button", sprite=sprite, tooltip=tooltip, style="transparent_slot"}
        icon.add{type="sprite-button", sprite="quality/" .. milestone.quality, style="milestones_quality_sprite_button"}
        icon.add{type="sprite-button", sprite="", number=number, style="transparent_slot"}
    else
        flow.add{type="sprite-button", sprite=sprite, number=number, tooltip=tooltip, style="transparent_slot"}
    end
    add_milestone_label(flow, milestone, compact, estimations, milliseconds, can_edit)
end

local function editable_milestone(player_index, element)
    local player = game.get_player(player_index)
    if not player or not player.admin then
        if player then player.print{"milestones.message_settings_permission_denied"} end
        return nil
    end
    if not (element and element.valid) then return nil end
    local own, force = get_display_storage_force(player.force)
    local flow = element.parent
    local milestone = own and force.index == flow.tags.force_index and identity.find_complete(own, flow.tags.milestone_id)
    if not milestone then
        storage.players[player_index].editing_milestone_id = nil
        player.print{"milestones.message_stale_view"}
        refresh_gui_for_player(player)
        return nil
    end
    return milestone, own, force, flow
end

function enable_edit_time(player_index, element)
    local milestone, _, _, flow = editable_milestone(player_index, element)
    if not milestone then return end
    storage.players[player_index].editing_milestone_id = milestone.id
    flow.milestones_display_time.destroy()
    flow.milestones_edit_time.destroy()
    local field = flow.add{type="textfield", name="milestones_edit_time_field",
        text=flib_format.time(math.min(game.tick, ceil_to_nearest_minute(milestone.completion_tick))),
        tags={action="milestones_confirm_edit_time_textfield"}, style="milestones_small_textfield"}
    field.focus()
    field.select_all()
    flow.add{type="sprite-button", name="milestones_confirm_edit_time", sprite="utility/check_mark_white", style="milestones_confirm_button",
        tooltip={"milestones.edit_time_confirm"}, tags={action="milestones_confirm_edit_time"}}
end

local function parse_exact_time_to_ticks(value)
    local hours, minutes, seconds = value:match("^%s*(%d+):(%d%d?):(%d%d?)%s*$")
    if hours then
        hours, minutes, seconds = tonumber(hours), tonumber(minutes), tonumber(seconds)
        if minutes >= 60 then return nil end
    else
        minutes, seconds = value:match("^%s*(%d+):(%d%d?)%s*$")
        hours, minutes, seconds = 0, tonumber(minutes), tonumber(seconds)
    end
    if not minutes or not seconds or seconds >= 60 then return nil end
    local tick = (hours * 3600 + minutes * 60 + seconds) * 60
    if schema.finite(tick) and tick >= 0 and tick <= game.tick then return tick end
end

function confirm_edit_time(player_index, element)
    local milestone, own, force, flow = editable_milestone(player_index, element)
    if not milestone then return end
    local field = flow.milestones_edit_time_field
    local tick = field and parse_exact_time_to_ticks(field.text)
    if not tick then game.get_player(player_index).print{"milestones.message_invalid_time"}; return end
    milestone.completion_tick, milestone.lower_bound_tick = tick, nil
    storage.players[player_index].editing_milestone_id = nil
    sort_milestones(own.complete_milestones)
    sort_milestones(own.milestones_by_group[milestone.group])
    refresh_gui_for_force(force)
end

local function display_records(own, grouped, show_incomplete)
    local records = {}
    if grouped then
        local groups = {}
        for name, milestones in pairs(own.milestones_by_group) do
            local visible = filter_hidden_milestones(milestones, show_incomplete)
            if #visible > 0 then
                local order = math.huge
                for _, milestone in ipairs(visible) do order = math.min(order, milestone.sort_index) end
                groups[#groups + 1] = {name=name, records=visible, order=order}
            end
        end
        table.sort(groups, function(a, b) return a.order == b.order and a.name < b.name or a.order < b.order end)
        for _, group in ipairs(groups) do
            for _, milestone in ipairs(group.records) do records[#records + 1] = {milestone=milestone, group=group.name} end
        end
    else
        for _, milestone in ipairs(own.complete_milestones) do records[#records + 1] = {milestone=milestone} end
        for _, milestone in ipairs(filter_hidden_milestones(own.incomplete_milestones, show_incomplete)) do
            records[#records + 1] = {milestone=milestone}
        end
    end
    return records
end

local function empty_cells(parent, count)
    for _ = 1, count do parent.add{type="empty-widget"} end
end

function build_display_page(player)
    local main = get_main_frame(player.index)
    main.milestones_titlebar.milestones_main_label.caption = {"milestones.title"}
    main.milestones_titlebar.milestones_settings_button.visible = true
    main.milestones_titlebar.milestones_close_button.visible = true
    main.milestones_dialog_buttons.visible = false
    local inner = get_inner_frame(player.index)
    inner.clear()
    local own, force = get_display_storage_force(player.force)
    local records = {}
    local options = settings.get_player_settings(player)
    local grouped = options["milestones_list_by_group"].value
    if own then
        identity.ensure(own)
        records = display_records(own, grouped, options["milestones_show_incomplete"].value)
    end
    local state = storage.players[player.index]
    local pages = math.max(1, math.ceil(#records / PAGE_SIZE))
    local page = math.max(1, math.min(state.display_page or 1, pages))
    state.display_page = page
    if pages > 1 then
        local bar = inner.add{type="flow", direction="horizontal"}
        bar.add{type="button", caption="<", enabled=page > 1, tooltip={"milestones.previous_page"}, tags={action="milestones_display_page", direction=-1}}
        bar.add{type="label", caption={"milestones.page", page, pages}}
        bar.add{type="button", caption=">", enabled=page < pages, tooltip={"milestones.next_page"}, tags={action="milestones_display_page", direction=1}}
    end
    local scroll = inner.add{type="scroll-pane", name="milestones_display_scroll", style="flib_naked_scroll_pane"}
    scroll.style.maximal_height = math.max(120, math.floor(player.display_resolution.height / player.display_scale - 180))
    if #records == 0 then scroll.add(empty_set_label); return end
    local compact = options["milestones_compact_list"].value
    local estimations = options["milestones_show_estimations"].value
    local milliseconds = settings.global["milestones_check_frequency"].value < 60
    local first, last = (page - 1) * PAGE_SIZE + 1, math.min(page * PAGE_SIZE, #records)
    local max_columns = math.max(1, math.floor((player.display_resolution.width / player.display_scale * 0.9 - 32) / (compact and 264 or 283)))
    local columns = math.max(1, math.min(8, max_columns, math.ceil(math.sqrt((last - first + 1) / 3))))
    local content = scroll.add{type="table", column_count=columns, style="milestones_table_style"}
    local group, count = nil, 0
    for i = first, last do
        local record = records[i]
        if grouped and record.group ~= group then
            if group then
                empty_cells(content, (columns - count % columns) % columns)
                for _ = 1, columns do content.add{type="line"} end
            end
            group, count = record.group, 0
            content.add{type="label", caption=group, style="caption_label"}
            empty_cells(content, columns - 1)
        end
        add_milestone_item(content, record.milestone, force.index, milliseconds, compact, estimations, player.admin)
        count = count + 1
    end
end

local function change_display_page(player_index, direction)
    local state = storage.players[player_index]
    state.editing_milestone_id = nil
    state.display_page = math.max(1, (state.display_page or 1) + direction)
    build_display_page(game.get_player(player_index))
end

function is_display_page_visible(player_index)
    return get_inner_frame(player_index).milestones_display_scroll ~= nil
end

return {change_display_page=change_display_page}
