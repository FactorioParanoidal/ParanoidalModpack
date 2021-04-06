local START_SIZE = 10
local mod_gui = require("__core__.lualib.mod-gui")
local table = require("__flib__.table")
local gui = require("__flib__.gui-beta")

local function export_config(config_data, name)
    local to_bp_entities = function(data)
        local entities = {}
        local bp_index = 1
        local items
        for i, config in pairs(data) do
            if config.from then
                items = {}
                for _, module in pairs(config.to) do
                    items[module] = items[module] and items[module] + 1 or 1
                end
                entities[bp_index] = {
                    entity_number = i,
                    items = items,
                    name = config.from,
                    position = {x = 0, y = i*5.5},
                    tags = {order = i}
                }
                bp_index = bp_index + 1
            end
        end
        return entities
    end
    local inventory, stack, result
    --export a single preset
    if name then
        inventory = game.create_inventory(1)
        inventory.insert{name = "blueprint"}
        stack = inventory[1]
        stack.set_blueprint_entities(to_bp_entities(config_data))
        stack.label = name

        result = stack.export_stack()
        inventory.destroy()
    --export all presets
    else
        inventory = game.create_inventory(1)
        inventory.insert{name = "blueprint-book"}
        local book = inventory[1]
        local book_inventory = book.get_inventory(defines.inventory.item_main)
        local index = 1
        for preset_name, preset_config in pairs(config_data) do
            book_inventory.insert{name = "blueprint"}
            local res = to_bp_entities(preset_config)
            book_inventory[index].set_blueprint_entities(res)
            book_inventory[index].label = preset_name
            index = index + 1
        end
        book.label = "ModuleInserter Configuration"
        result = book.export_stack()
        inventory.destroy()
    end
    return result
end

local function import_config(bp_string)

    local to_config = function(entities)
        if not entities then return end
        local config = {}
        local config_index
        local modules
        local c = 0
        for _, ent in pairs(entities) do
            modules = {}
            config_index = ent.tags and ent.tags["order"] or ent.entity_number
            if global.nameToSlots[ent.name] then
                if ent.items then
                    for module, amount in pairs(ent.items) do
                        for i = 1, amount do
                            modules[table_size(modules)+1] = module
                        end
                    end
                end
                config[config_index] = {cTable = ent.items or {}, from = ent.name, to = modules}
                c = config_index > c and config_index or c
            end
        end
        if c < START_SIZE then
            for i = c+1, START_SIZE do
                config[i] = {cTable = {}, to = {}}
            end
        end
        return config
    end

    local inventory = game.create_inventory(1)
    inventory.insert{name = "blueprint"}
    local stack = inventory[1]
    local result = stack.import_stack(bp_string)
    if result ~= 0 then return result end

    if stack.type == "blueprint" then
        local name = stack.label or "ModuleInserter Configuration"
        local config = to_config(stack.get_blueprint_entities())
        inventory.destroy()
        return result, config, name
    elseif stack.type == "blueprint-book" then
        local storage = {}
        local name, item
        local book_inventory = stack.get_inventory(defines.inventory.item_main)
        for i = 1, #book_inventory do
            item = book_inventory[i]
            name = item.label or "ModuleInserter Configuration"
            storage[name] = to_config(item.get_blueprint_entities())
        end
        return result, storage
    end
end

local mi_gui = {}

mi_gui.templates = {
    assembler_button = function(assembler)
        return {type = "choose-elem-button", name = "assembler", style = "slot_button", style_mods = { right_margin = 6},
                actions = {on_elem_changed = {gui = "main", action = "choose_assembler"}},
                elem_type = "entity", elem_filters = {{filter = "name", name = global.module_entities}},
                entity = assembler,
                tooltip = assembler and game.entity_prototypes[assembler].localised_name or {"module-inserter-choose-assembler"}
        }
    end,
    module_button = function(index, module, assembler)
        return {type = "choose-elem-button", style = "slot_button", name = index,
                actions = {on_elem_changed = {gui = "main", action = "choose_module"}},
                elem_type = "item", elem_filters = {{filter = "type", type = "module"}},
                item = module,
                locked = not assembler and  true or false,
                tooltip = module and game.item_prototypes[module].localised_name or {"module-inserter-choose-module"}
        }
    end,
    config_row = function(index, config)
        config = config or {}
        local assembler = config.from
        local slots = assembler and global.nameToSlots[assembler] or 2
        local modules = config.to or {}
        local row = {type = "flow", direction = "horizontal", name = index, style_mods = {horizontal_spacing = 0}, children = {
                        mi_gui.templates.assembler_button(assembler),
                        {type = "table", column_count = 10, name = "modules",  children = {},
                            style_mods = {
                                margin=0, padding = 0,
                                horizontal_spacing = 0,
                                vertical_spacing = 0
                            }
                        }
                    }}
        for m = 1, slots do
            row.children[2].children[m] = mi_gui.templates.module_button(m, modules[m], assembler)
        end
        return row
    end,
    config_rows = function(n, config_tmp)
        local config_rows = {}
        for index = 1, n do
            config_rows[index] = mi_gui.templates.config_row(index, config_tmp[index])
        end
        return config_rows
    end,
    preset_row = function(name, selected)
        return {type = "flow", direction = "horizontal", children = {
                    {type = "button", caption = name,
                        style = name == selected and "mi_preset_button_selected" or "mi_preset_button",
                        actions = {on_click = {gui = "preset", action = "load"}},
                    },
                    {type = "sprite-button", style = "tool_button", sprite = "utility/export_slot", tooltip = {"module-inserter-export_tt"},
                        actions = {on_click = {gui = "preset", action = "export"}},
                    },
                    {type = "sprite-button", style = "tool_button_red", sprite = "utility/trash",
                        actions = {on_click = {gui = "preset", action = "delete"}},
                    },
                }}
    end,
    preset_rows = function(presets, selected)
        local preset_rows = {}
        local i = 1
        for name, _ in pairs(presets) do
            preset_rows[i] = mi_gui.templates.preset_row(name, selected)
            i = i +1
        end
        return preset_rows
    end,
    pushers = {
        horizontal = {type = "empty-widget", style_mods = {horizontally_stretchable = true}},
        vertical = {type = "empty-widget", style_mods = {vertically_stretchable = true}}
    },
    import_export_window = function(bp_string)
        local caption = bp_string and {"gui.export-to-string"} or {"gui-blueprint-library.import-string"}
        local button_caption = bp_string and {"gui.close"} or {"gui-blueprint-library.import"}
        local button_handler = bp_string and "close_button" or "import_button"
        return {type = "frame", style = "inner_frame_in_outer_frame", direction = "vertical",
                ref = {"import", "window"},
                children = {
                {type = "flow", ref = {"import", "titlebar_flow"},
                    children = {
                    {type = "label", style = "frame_title", caption = caption, elem_mods = {ignored_by_interaction = true}},
                    {type = "empty-widget", style = "flib_titlebar_drag_handle", elem_mods = {ignored_by_interaction = true}},
                    {type = "sprite-button", style = "frame_action_button",
                        sprite = "utility/close_white", hovered_sprite = "utility/close_black", clicked_sprite = "utility/close_black",
                        actions = {on_click = {gui = "import", action = "close_button"}},
                    }
                }},
                {type = "text-box", text = bp_string, elem_mods = {word_wrap = true}, style_mods = {width=400, height = 250},
                    ref = {"import", "textbox"},
                },
                {type = "flow", direction = "horizontal", children={
                    mi_gui.templates.pushers.horizontal,
                        {type = "button", style = "dialog_button", caption = button_caption,
                            actions = {on_click = {gui = "import", action = button_handler}},
                        }
                }}
            }}
    end,
}

function mi_gui.update_main_button(player)
    local button_flow = mod_gui.get_button_flow(player)
    local button = button_flow.module_inserter_config_button
    button = button and button.valid and button
    local visible = not player.mod_settings["module_inserter_hide_button"].value
    local style = player.mod_settings["module_inserter_button_style"].value
    if not button then
        gui.build(button_flow, {{
            type = "sprite-button",
            name = "module_inserter_config_button",
            actions = {on_click = {gui = "mod_gui_button", action = "toggle"}},
            style = style,
            sprite = "technology/modules"
        }})
        button = button_flow.module_inserter_config_button
    end
    button.style = style
    button.visible = visible
end

function mi_gui.create(player_index)
    local pdata = global._pdata[player_index]
    local player = game.get_player(player_index)
    if not player or not pdata then return end

    pdata.config_tmp = table.deep_copy(pdata.config)
    local config_tmp = pdata.config_tmp

    local max_config_size = table_size(config_tmp)
    max_config_size = (max_config_size > START_SIZE) and max_config_size or START_SIZE
    for index = 1, max_config_size do
        if not config_tmp[index] then
            config_tmp[index] = {to = {}, cTable = {}}
        end
    end
    local refs = gui.build(player.gui.screen,{
        {type = "frame", style_mods = {maximal_height = 650}, direction = "vertical",
            actions = {on_closed = {gui = "main", action = "close_window"}},
            ref = {"main", "window"},
            children = {
                {type = "flow", ref = {"main", "titlebar_flow"},
                    children = {
                        {type = "label", style = "frame_title", caption = "Module Inserter", elem_mods = {ignored_by_interaction = true}},
                        {type = "empty-widget", style = "flib_titlebar_drag_handle", elem_mods = {ignored_by_interaction = true}},
                        {type = "sprite-button", style = "frame_action_button_red", sprite = "utility/trash", tooltip = {"module-inserter-destroy"},
                            actions = {on_click = {gui = "main", action = "destroy_tool"},}
                        },
                        {type = "sprite-button", style = "frame_action_button", tooltip={"module-inserter-keep-open"},
                            sprite = pdata.pinned and "mi_pin_black" or "mi_pin_white", hovered_sprite = "mi_pin_black", clicked_sprite = "mi_pin_black",
                            ref = {"main", "pin_button"},
                            actions = {on_click = {gui = "main", action = "pin"}},
                        },
                        {type = "sprite-button", style = "frame_action_button",
                            sprite = "utility/close_white", hovered_sprite = "utility/close_black", clicked_sprite = "utility/close_black",
                            actions = {on_click = {gui = "main", action = "close"}}
                        }
                    }
                },
                {type = "flow", direction = "horizontal", style = "inset_frame_container_horizontal_flow", children = {
                    {type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
                        {type = "frame", style = "subheader_frame", children={
                            {type = "label", style = "subheader_caption_label", caption = {"module-inserter-config-frame-title"}},
                            mi_gui.templates.pushers.horizontal,
                            {type = "sprite-button", style = "tool_button_green", style_mods = {padding = 0},
                                actions = {on_click = {gui = "main", action = "apply_changes"}},
                                sprite = "utility/check_mark_white", tooltip = {"module-inserter-config-button-apply"}
                            },
                            {type = "sprite-button", style = "tool_button_red", sprite = "utility/trash", tooltip = {"module-inserter-config-button-clear-all"},
                                actions = {on_click = {gui = "main", action = "clear_all"}},
                            },
                        }},
                        {type = "flow", direction="vertical", style_mods = {padding= 12, top_padding = 8, vertical_spacing = 10}, children = {
                            {type = "frame", style = "deep_frame_in_shallow_frame",
                                style_mods = {horizontally_stretchable = true, minimal_height = 444}, children = {
                                {type = "scroll-pane", style="mi_naked_scroll_pane", name = "config_rows",
                                    style_mods = {minimal_width = 214},
                                    ref = {"main", "config_rows"},
                                    children = mi_gui.templates.config_rows(max_config_size, config_tmp)
                                }
                            }}
                        }}
                    }},
                    {type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
                        {type = "frame", style = "subheader_frame", children={
                            {type = "label", style = "subheader_caption_label", caption = {"module-inserter-storage-frame-title"}},
                            mi_gui.templates.pushers.horizontal,
                            {type = "sprite-button", style = "tool_button", sprite = "mi_import_string", tooltip = {"module-inserter-import_tt"},
                                actions = {on_click = {gui = "presets", action = "import"}},
                            },
                            {type = "sprite-button", style = "tool_button", sprite = "utility/export_slot", tooltip = {"module-inserter-export_tt"},
                                actions = {on_click = {gui = "presets", action = "export"}},
                            },
                        }},
                        {type = "flow", direction="vertical", style_mods = {width = 246, padding= 12, top_padding = 8, vertical_spacing = 10}, children = {
                            {type = "flow", direction = "horizontal", children ={
                                {type = "textfield", text = pdata.last_preset, style_mods = {width = 150},
                                    ref = {"presets", "textfield"},
                                    actions = {on_click = {gui = "presets", action = "textfield"}},
                                },
                                mi_gui.templates.pushers.horizontal,
                                {type = "button", caption = {"gui-save-game.save"}, style = "module-inserter-small-button",
                                    actions = {on_click = {gui = "presets", action = "save"}}
                                },
                            }},
                            {type = "frame", style = "deep_frame_in_shallow_frame", children = {
                                {type = "scroll-pane",style="mi_naked_scroll_pane",
                                    style_mods = {vertically_stretchable = true, minimal_width = 222},
                                    ref = {"presets", "scroll_pane"},
                                    children = mi_gui.templates.preset_rows(pdata.storage, pdata.last_preset)
                                }
                            }}
                        }}
                    }}
                }}
            }},
    })
    refs.main.titlebar_flow.drag_target = refs.main.window
    refs.main.window.force_auto_center()
    pdata.gui.main = refs.main
    pdata.gui.presets = refs.presets
    mi_gui.update_contents(pdata)
    refs.main.window.visible = false
end

function mi_gui.create_import_window(pdata, player, bp_string)
    local import_gui = pdata.gui.import
    if import_gui and import_gui.window and import_gui.window.valid then
        import_gui.window.destroy()
        pdata.gui.import = nil
    end
    local refs = gui.build(player.gui.screen, {mi_gui.templates.import_export_window(bp_string)})
    pdata.gui.import = refs.import
    import_gui = pdata.gui.import
    import_gui.titlebar_flow.drag_target = import_gui.window
    import_gui.window.force_auto_center()
    local textbox = import_gui.textbox
    if bp_string then
        textbox.read_only = true
    end
    textbox.select_all()
    textbox.focus()
end

function mi_gui.shrink_rows(config_rows, c, config_tmp)
    for i = c, START_SIZE + 1, -1 do
        if config_tmp[i] then
            if config_tmp[i-1].from then
                break
            elseif not config_tmp[i].from and not config_tmp[i-1].from then
                config_rows.children[i].destroy()
                config_tmp[i] = nil
            end
        else
            if config_rows.children[i] then
                config_rows.children[i].destroy()
            end
        end
    end
end

function mi_gui.extend_rows(config_rows, c, config_tmp)
    if not config_rows.children[c+1] then
        gui.build(config_rows, {mi_gui.templates.config_row(c+1)})
        config_tmp[c+1] = {cTable = {}, to = {}}
        config_rows.scroll_to_bottom()
    end
end

function mi_gui.update_modules(config, slots, modules)
    modules = modules or {}
    slots = slots or 2

    local module_btns = table_size(config.modules.children)
    local assembler = config.children[1].elem_value
    if not assembler then
        for i, btn in pairs(config.modules.children) do
            btn.elem_value = nil
            btn.locked = true
            btn.tooltip = {"module-inserter-choose-module"}
            if i > 2 then
                btn.visible = false
            end
        end
        return
    end
    if module_btns < slots then
        for i = module_btns + 1, slots do
            gui.build(config.modules, {mi_gui.templates.module_button(i, nil, assembler)})
        end
        for i = 1, slots do
            local child = config.modules.children[i]
            child.visible = true
            child.locked = false
            child.elem_value = modules[i]
            child.tooltip = modules[i] and game.item_prototypes[modules[i]].localised_name or {"module-inserter-choose-module"}
        end
    else
        for i = 1, module_btns do
            local child = config.modules.children[i]
            child.elem_value = modules[i]
            child.tooltip = modules[i] and game.item_prototypes[modules[i]].localised_name or {"module-inserter-choose-module"}
            child.locked = not assembler and true or false
            child.visible = i <= slots
        end
    end
end

function mi_gui.update_row(pdata, index, assembler, tooltip, slots, modules)--luacheck: ignore
    local config_rows = pdata.gui.main.config_rows
    if not (config_rows and config_rows.valid) then return end
    local row = config_rows.children[index]
    if not row then
        gui.build(config_rows, {mi_gui.templates.config_row(index)})
        row = config_rows.children[index]
    end
    row.assembler.elem_value = assembler
    row.assembler.tooltip = tooltip or {"module-inserter-choose-assembler"}
    mi_gui.update_modules(row, slots, modules)
end

function mi_gui.update_contents(pdata, clear)
    local config_tmp = pdata.config_tmp
    local assembler, assembler_proto, tooltip
    local slots, modules

    if clear then
        pdata.gui.main.config_rows.clear()
    end

    for index, config in pairs(config_tmp) do
        if config.from then
            assembler = config.from
            assembler_proto = assembler and game.entity_prototypes[assembler]
            tooltip = assembler_proto and assembler_proto.localised_name
            slots = config.from and global.nameToSlots[config.from]
            modules = config.to
        else
            assembler, tooltip, slots, modules = nil, nil, nil, nil
        end
        mi_gui.update_row(pdata, index, assembler, tooltip, slots, modules)
    end
    mi_gui.shrink_rows(pdata.gui.main.config_rows, table_size(pdata.gui.main.config_rows.children), config_tmp)
end

function mi_gui.add_preset(player, pdata, name, config, textfield)
    local gui_elements = pdata.gui

    if name == "" then
        player.print({"module-inserter-storage-name-not-set"})
        return
    end
    if pdata.storage[name] then
        if not player.mod_settings["module_inserter_overwrite"].value then
            player.print{"module-inserter-storage-name-in-use", name}
            if textfield then
                textfield.select_all()
                textfield.focus()
            end
            return
        else
            pdata.storage[name] = table.deep_copy(config)
            player.print{"module-inserter-storage-updated", name}
            return true
        end
    end

    pdata.storage[name] = table.deep_copy(config)
    gui.build(gui_elements.presets.scroll_pane, {mi_gui.templates.preset_row(name)})
    return true
end

function mi_gui.update_presets(pdata, selected_preset)
    for _, preset_flow in pairs(pdata.gui.presets.scroll_pane.children) do
        local preset = preset_flow.children[1]
        if preset.caption == selected_preset then
            preset.style = "mi_preset_button_selected"
        else
            preset.style = "mi_preset_button"
        end
    end
end

function mi_gui.destroy(pdata, player)
    local main_gui = pdata.gui.main
    if main_gui and main_gui.window and main_gui.window.valid then
        main_gui.window.destroy()
    end
    local import_gui = pdata.gui.import
    if import_gui and import_gui.window and import_gui.window.valid then
        import_gui.window.destroy()
    end
    if not pdata.pinned then
        player.opened = nil
    end
    pdata.gui.main = nil
    pdata.gui.presets = nil
    pdata.gui.import = nil
    pdata.gui_open = false
end

function mi_gui.open(e)
    local window = e.pdata.gui.main.window
    if not(window and window.valid) then
        mi_gui.destroy(e.pdata, e.player)
        mi_gui.create(e.player_index)
        window = e.pdata.gui.main.window
    end
    window.visible = true
    e.pdata.gui_open = true
    if not e.pdata.pinned then
        e.player.opened = window
    end
end

function mi_gui.close(e)
    local pdata = e.pdata
    if pdata.closing then
        return
    end
    local window = pdata.gui.main.window
    if window and window.valid then
        window.visible = false
    end
    pdata.gui_open = false
    if e.player.opened == window then
        pdata.closing = true
        e.player.opened = nil
        pdata.closing = nil
    end
end

function mi_gui.toggle(e)
    if e.pdata.gui_open then
        mi_gui.close(e)
    else
        mi_gui.open(e)
    end
end

mi_gui.handlers = {
    mod_gui_button = {
        toggle = mi_gui.toggle
    },
    main = {
        apply_changes = function(e, keep_open)
            e.pdata.config = table.deep_copy(e.pdata.config_tmp)
            local config_by_entity = {}
            for _, config in pairs(e.pdata.config) do
                if config.from then
                    config_by_entity[config.from] = config_by_entity[config.from] or {}
                    config_by_entity[config.from][table_size(config_by_entity[config.from])+1] = {to = config.to, cTable = config.cTable, limitations = config.limitations}
                end
            end
            e.pdata.config_by_entity = config_by_entity
            --log(serpent.block(config_by_entity))
            if not keep_open then
                mi_gui.close(e)
            end
        end,
        clear_all = function(e)
            local tmp = {}
            for i = 1, START_SIZE do
                tmp[i] = {cTable = {}, to = {}}
            end
            e.pdata.config_tmp = tmp
            mi_gui.update_contents(e.pdata)
        end,
        close_window = function(e)
            if not e.pdata.pinned then
                mi_gui.close(e)
            end
        end,
        close = function(e)
            mi_gui.close(e)
        end,
        pin = function(e)
            local pdata = e.pdata
            local pin = pdata.gui.main.pin_button
            if pdata.pinned then
                pin.sprite = "mi_pin_white"
                pin.style = "frame_action_button"
                pdata.pinned = false
                pdata.gui.main.window.force_auto_center()
                e.player.opened = pdata.gui.main.window
            else
                pin.sprite = "mi_pin_black"
                pin.style = "flib_selected_frame_action_button"
                pdata.pinned = true
                pdata.gui.main.window.auto_center = false
                e.player.opened = nil
            end
        end,
        choose_assembler = function(e)
            local pdata = e.pdata
            local config_tmp = pdata.config_tmp
            local config_rows = pdata.gui.main.config_rows
            if not (config_rows and config_rows.valid) then return end
            local index = tonumber(e.element.parent.name)
            local element = e.element
            local elem_value = element.elem_value

            if elem_value == config_tmp[index].from then
                return
            end

            local c = table_size(config_tmp)

            if not elem_value then
                config_tmp[index] = {cTable = {}, to = {}}
                element.tooltip = {"module-inserter-choose-assembler"}
                mi_gui.update_modules(config_rows.children[index])
                mi_gui.shrink_rows(config_rows, c, config_tmp)
                return
            end

            element.tooltip = game.entity_prototypes[elem_value].localised_name
            config_tmp[index].from = elem_value

            mi_gui.update_modules(config_rows.children[index], global.nameToSlots[elem_value])
            if index == c then
                mi_gui.extend_rows(config_rows, c, config_tmp)
            end
        end,

        choose_module = function(e)
            local config_tmp = e.pdata.config_tmp
            local config_rows = e.pdata.gui.main.config_rows
            if not (config_rows and config_rows.valid) then return end
            local index = tonumber(e.element.parent.parent.name)
            local slot = tonumber(e.element.name)


            local config = config_tmp[index]
            config.to[slot] = e.element.elem_value
            local entity_proto = config.from and game.entity_prototypes[config.from]
            if e.element.elem_value then
                local proto = game.item_prototypes[e.element.elem_value]
                local success = true
                if proto and config.from then
                    local itemEffects = proto.module_effects
                    if entity_proto and itemEffects then
                        for name, effect in pairs(itemEffects) do
                            if effect and effect.bonus ~= 0 and not entity_proto.allowed_effects[name] then
                                success = false
                                e.player.print({"inventory-restriction.cant-insert-module", proto.localised_name, entity_proto.localised_name})
                                config.to[slot] = nil
                                e.element.elem_value = nil
                                break
                            end
                        end
                    end
                    if success then
                        config.to[slot] = proto.name
                    end
                end

            end
            if slot == 1 and e.element.elem_value and e.player.mod_settings["module_inserter_fill_all"].value then
                for i = 2, entity_proto.module_inventory_size do
                    config.to[i] = config.to[i] or e.element.elem_value
                end
            end
            mi_gui.update_modules(config_rows.children[index], entity_proto.module_inventory_size, config.to)
            local cTable = {}
            local prototype, limitations
            config.limitations = false
            for _, module in pairs(config.to) do
                if module then
                    prototype = game.item_prototypes[module]
                    limitations = prototype and prototype.limitations
                    if limitations and next(limitations) then
                        config.limitations = true
                    end
                    cTable[module] = (cTable[module] or 0) + 1
                end
            end
            config.cTable = cTable
        end,
        destroy_tool = function(e)
            e.player.get_main_inventory().remove{name = "module-inserter", count = 1}
            mi_gui.close(e)
        end
    },
    presets = {
        save = function(e)
            local textfield = e.pdata.gui.presets.textfield
            local name = textfield.text
            if mi_gui.add_preset(e.player, e.pdata, name, e.pdata.config_tmp, textfield) then
                mi_gui.update_presets(e.pdata, name)
            end
        end,
        textfield = function(e)
            e.element.select_all()
            e.element.focus()
        end,
        import = function(e)
            local stack = e.player.cursor_stack
            if stack and stack.valid and stack.valid_for_read and (stack.type == "blueprint" or stack.type == "blueprint-book") then
                local player = e.player
                local pdata = e.pdata
                local result, config, name = import_config(stack.export_stack())
                if result ~= 0 then
                    player.print({"failed-to-import-string", name})
                    return
                end
                if name then
                    mi_gui.add_preset(player, pdata, name, config)
                else
                    for sname, data in pairs(config) do
                        mi_gui.add_preset(player, pdata, sname, data)
                    end
                end
            else
                mi_gui.create_import_window(e.pdata, e.player)
            end
        end,
        export = function(e)
            local text = export_config(e.pdata.storage)
            if e.shift then
                local stack = e.player.cursor_stack
                if stack.valid_for_read then
                    e.player.print("Click with an empty cursor")
                    return
                else
                    if not stack.set_stack{name = "blueprint", count = 1} then
                        e.player.print({"", {"error-while-importing-string"}, " Could not set stack"})
                        return
                    end
                    stack.import_stack(text)
                end
            else
                mi_gui.create_import_window(e.pdata, e.player, text)
            end
        end
    },
    preset = {
        load = function(e)
            local name = e.element.caption
            local pdata = e.pdata
            local gui_elements = pdata.gui

            local preset = pdata.storage[name]
            if not preset then return end

            pdata.config_tmp = table.deep_copy(preset)
            pdata.config = table.deep_copy(preset)

            --TODO save the last loaded/saved preset somewhere to fill the textfield
            gui_elements.presets.textfield.text = name or ""

            local keep_open = not e.player.mod_settings["module_inserter_close_after_load"].value
            mi_gui.update_contents(pdata, true)
            mi_gui.update_presets(pdata, name)

            mi_gui.handlers.main.apply_changes(e, keep_open)
            pdata.last_preset = name
            --mi_gui.close(player, pdata)
            e.player.print{"module-inserter-storage-loaded", name}
        end,
        export = function(e)
            local pdata = e.pdata
            local name = e.element.parent.children[1].caption
            local config = pdata.storage[name]
            if not config or not name or name == "" then
                e.player.print("Preset " .. name .. "not found")
                return
            end

            local text = export_config(config, name)
            if e.shift then
                local stack = e.player.cursor_stack
                if stack.valid_for_read then
                    e.player.print("Click with an empty cursor")
                    return
                else
                    if not stack.set_stack{name = "blueprint", count = 1} then
                        e.player.print({"", {"error-while-importing-string"}, " Could not set stack"})
                        return
                    end
                    stack.import_stack(text)
                end
            else
                mi_gui.create_import_window(pdata, e.player, text)
            end
        end,
        delete = function(e)
            local name = e.element.parent.children[1].caption
            local pdata = e.pdata
            local parent = e.element.parent
            pdata.storage[name] = nil
            parent.destroy()
        end
    },
    import = {
        import_button = function(e)
            local player = e.player
            local pdata = e.pdata
            local text_box = pdata.gui.import.textbox
            local result, config, name = import_config(text_box.text)
            if result ~= 0 then
                player.print({"failed-to-import-string", name})
                return
            end
            if name then
                mi_gui.add_preset(player, pdata, name, config)
            else
                for sname, data in pairs(config) do
                    mi_gui.add_preset(player, pdata, sname, data)
                end
            end
            mi_gui.handlers.import.close_button(e)
        end,
        close_button = function(e)
            local window = e.pdata.gui.import.window
            window.destroy()
            e.pdata.gui.import = nil
        end
    },
}

return mi_gui