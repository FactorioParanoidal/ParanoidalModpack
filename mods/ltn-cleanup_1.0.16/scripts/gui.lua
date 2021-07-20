local ltn = require("ltn")

local gui = {}

function gui.on_player_created(event)
    local player = game.get_player(event.player_index)
    gui.initialize_global(player)
end

function gui.on_player_removed(event)
    global.players[event.player_index] = nil
end

function gui.on_gui_closed(event)
    if event.element and event.element.name == "ltn-cleanup-main-frame" then
        local player = game.get_player(event.player_index)
        gui.toggle_interface(player)
    end
end

function gui.toggle_summary(event)
    local player = game.get_player(event.player_index)
    gui.toggle_interface(player)
end

function gui.initialize_global(player)
    global.gui_players[player.index] = {
        elements = {}
    }
end

function gui.toggle_interface(player)
    local player_global = global.gui_players[player.index]
    local main_frame = player_global.elements.main_frame

    if main_frame == nil then
        gui.build_interface(player)
    else
        main_frame.destroy()
        player_global.elements = {}
    end
end

function gui.get_display_size(player)
    if player == nil then
        return 800, 600
    end

    local display_resolution = player.display_resolution
    local display_scale = player.display_scale
    return display_resolution.width / display_scale, display_resolution.height / display_scale
end

function gui.build_interface(player)
    local player_global = global.gui_players[player.index]

    local screen_element = player.gui.left

    local main_frame = screen_element.add {
        type = "frame",
        name = "ltn-cleanup-main-frame"
    }
    --player.opened = main_frame
    player_global.elements.main_frame = main_frame

    local scroll = main_frame.add {
        type = "scroll-pane"
    }
    local window_width, window_height = gui.get_display_size(player)
    scroll.style.maximal_height = window_height * 0.5

    local content_frame = scroll.add {
        type = "table",
        column_count = 5,
        vertical_centering = false,
        name="ltn-cleanup-train-summary"
    }

    player_global.elements.content_frame = content_frame

    content_frame.add{type="label", caption="Loading..."}
end

function gui.format_number(n)
    if n == nil then
        return n
    elseif n >= 10^12 then
        return string.format("%.1fT", n / 10^12)
    elseif n >= 10^9 then
        return string.format("%.1fG", n / 10^9)
    elseif n >= 10^6 then
        return string.format("%.1fM", n / 10^6)
    elseif n >= 10^3 then
        return string.format("%.1fk", n / 10^3)
    else
        return tostring(n)
    end
end

function gui.add_row(frame, color, type, name, delta, count, stop_id)
    local icon = frame.add {
        type = "sprite",
        sprite = "ltn-cleanup-signal-" .. color
    }
    icon.style.top_padding = 4

    frame.add {
        type = "label",
        caption = "[" .. type .. "=" .. name .. "]"
    }
    frame.add {
        type = "label",
        caption = delta
    }
    local count_e = frame.add {
        type = "label",
        caption = "(" .. count .. ")"
    }
    count_e.style.left_padding = 10
    count_e.style.right_padding = 15

    frame.add{
        type="label",
        caption=ltn.get_stop_name(stop_id),
        tags={stop_name = true}
    }
end

function gui.any_open()
    if global.gui_players == nil then
        return false
    end
    for _, player in pairs(global.gui_players) do
        if player.elements.content_frame ~= nil then
            return true
        end
    end
    return false
end

function gui.on_gui_click(event)
    if event.element.parent.name == "ltn-cleanup-train-summary" and event.element.tags.stop_name == true then
        local entity = game.get_train_stops({name=event.element.caption})
        if entity ~= nil and entity[1] ~= nil then
            entity = entity[1]
            game.get_player(event.player_index).zoom_to_world(entity.position, 0.5)
            rendering.draw_circle{
                color = {r = 0.2, g = 0.5, b = 1, a = 0.75},
                radius = 1.5,
                width = 6,
                filled = false,
                target = entity,
                surface = entity.surface,
                time_to_live = 120,
                players = {event.player_index}
            }
        end
    end
end

function gui.update_data()
    if not gui.any_open() then
        return
    end

    local positive_deltas = {}
    local negative_deltas = {}

    for id, val in pairs(global.delta_below_limit) do
        for name, val in pairs(val) do
            if val.delta >= 0 then
                table.insert(positive_deltas, {name=name, type=val.type, delta=val.delta, stop_id=id, count=val.count})
            else
                table.insert(negative_deltas, {name=name, type=val.type, delta=val.delta, stop_id=id, count=val.count})
            end
        end
    end

    table.sort(positive_deltas, function (a, b)
        if a["delta"] == b["delta"] then
            return a["stop_id"] < b["stop_id"]
        end
        return a["delta"] < b["delta"]
    end)

    for _, player in pairs(global.gui_players) do
        local content_frame = player.elements.content_frame
        if content_frame ~= nil then
            local empty = true
            content_frame.clear()

            for _, val in ipairs(positive_deltas) do
                if val.delta == 0 then
                    gui.add_row(content_frame, "red", val.type, val.name, gui.format_number(val.delta), gui.format_number(val.count), val.stop_id)
                else
                    gui.add_row(content_frame, "green", val.type, val.name, "+" .. gui.format_number(val.delta), gui.format_number(val.count), val.stop_id)
                end
                empty = false
            end

            -- for id, val in pairs(global.delta_at_limit) do
            --     for name, val in pairs(val) do
            --         gui.add_row(content_frame, "blue", val.type, name, "At limit", gui.format_number(val.count), id)
            --     end
            -- end

            for _, val in pairs(negative_deltas) do
                gui.add_row(content_frame, "yellow", val.type, val.name, gui.format_number(val.delta), gui.format_number(val.count), val.stop_id)
                empty = false
            end
            if empty == true then
                content_frame.add{type="label", caption="Waiting for data from LTN..."}
            end
        end
    end

end

return gui
