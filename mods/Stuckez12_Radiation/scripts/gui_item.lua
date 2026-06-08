local gui_item = {}



script.on_event(defines.events.on_gui_click, function(event)
    if not event.element.valid then return end

    local player = game.get_player(event.player_index)
    if not player then return end

    local gui = player.gui.screen.item_mod
    if gui == nil then return end

    local tables = gui.scroll_pane
    local item_table = tables.item_table
    local fluid_table = tables.fluid_table
    local item_table_add = tables.item_table_add
    local fluid_table_add = tables.fluid_table_add

    local valid_button_clicked = false

    if event.element.name == "item_mod_close" then
        if gui then
            gui.destroy()
            return
        end

    elseif event.element.name == "apply_rad_changes" then
        storage.radiation_items = update_radiated_list(item_table, storage.radiation_items, true)
        storage.radiation_fluids = update_radiated_list(fluid_table, storage.radiation_fluids, true)
        valid_button_clicked = true

    elseif event.element.name == "item_add_item" then
        storage.radiation_items = update_radiated_list(item_table_add, storage.radiation_items, false)
        valid_button_clicked = true

    elseif event.element.name == "item_add_fluid" then
        storage.radiation_fluids = update_radiated_list(fluid_table_add, storage.radiation_fluids, false)
        valid_button_clicked = true
    end

    if valid_button_clicked then
        close_gui(gui)
        gui_item.create_window(player)
    end
end)


function update_radiated_list(parent_element, list, clear_list)
    if clear_list then list = {} end

    for i, child in pairs(parent_element.children) do
        if child.type == "choose-elem-button" then
            local item = parent_element.children[i]
            local value = parent_element.children[i + 1]

            if value.text == "" then
                value.text = "0"
            end

            local value_number = tonumber(value.text)

            if value_number > 0 then
                list[item.elem_value] = value_number
            end
        end
    end

    return list
end


function close_gui(gui)
  gui.destroy()
end

function gui_item.create_window(player)
    if not player.gui.screen.item_mod then
        -- Base GUI Elements
        local root = player.gui.screen

        local window = root.add{
            type = "frame",
            name = "item_mod",
            caption = "Radiated Item Values",
            direction = "vertical"
        }
        window.auto_center = true

        window.add{
            type = "button",
            name = "item_mod_close",
            caption = "Close Window"
        }

        window.add{
            type = "button",
            name = "apply_rad_changes",
            caption = "Apply Changes"
        }

        local pane = window.add{
            type = "scroll-pane",
            name = "scroll_pane",
            horizontal_scroll_policy = "never",
            vertical_scroll_policy = "auto"
        }
        pane.style.maximal_height = 600

        -- Add Item Section
        pane.add{
            type = "label",
            name = "item_heading_add",
            caption = "Add Radiated Item",
            style = "frame_title"
        }

        local add_item = pane.add{
            type = "table",
            name = "item_table_add",
            column_count = 2
        }

        local item_config = {
            name="item",
            type="item",
        }

        add_table_row(add_item, item_config, nil, 0)

        pane.add{
            type = "button",
            name = "item_add_item",
            caption = "Add Radiated Item"
        }

        -- All Radiated Items
        pane.add{
            type = "label",
            name = "item_heading",
            caption = "Radiated Items",
            style = "frame_title"
        }

        local table_item = pane.add{
            type = "table",
            name = "item_table",
            column_count = 2
        }

        for item_name, value in pairs(storage.radiation_items) do
            add_table_row(table_item, item_config, item_name, value)
        end

        -- Add Fluid Section
        pane.add{
            type = "label",
            name = "fluid_heading_add",
            caption = "Add Radiated Fluids",
            style = "frame_title"
        }

        local add_fluid = pane.add{
            type = "table",
            name = "fluid_table_add",
            column_count = 2
        }

        local fluid_config = {
            name="fluid",
            type="fluid",
        }

        add_table_row(add_fluid, fluid_config, nil, 0)

        pane.add{
            type = "button",
            name = "item_add_fluid",
            caption = "Add Radiated Fluid"
        }

        -- All Radiated Fluids
        pane.add{
            type = "label",
            name = "fluid_heading",
            caption = "Radiated Fluids",
            style = "frame_title"
        }
        local table_fluid = pane.add{
            type = "table",
            name = "fluid_table",
            column_count = 2
        }

        for fluid_name, value in pairs(storage.radiation_fluids) do
            add_table_row(table_fluid, fluid_config, fluid_name, value)
        end
    end
end


function add_table_row(table_gui, gui_config, name, value)
    local real_name = name

    if name == nil then real_name = "" end

    local selector = table_gui.add{
        type = "choose-elem-button",
        name = gui_config.name .. "_select_" .. real_name,
        elem_type = gui_config.type,
    }
    selector.elem_value = name

    table_gui.add{
        type = "textfield",
        name = gui_config.name .. "_amount_" .. real_name,
        text = value,
        numeric = true
    }
end


return gui_item
