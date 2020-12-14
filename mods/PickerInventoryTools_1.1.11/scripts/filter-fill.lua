--[[
    "name": "fast-filter-fill",
    "title": "Fast Filter Fill",
    "author": "Keryja, SeaRyanC",
    "contact": "http://github.com/keryja/",
    "homepage": "https://mods.factorio.com/keryja/fast-filter-fill",
    "description": "Quickly duplicate filter settings in Cargo Wagons and other filterable containers",
--]] --
local Event = require('__stdlib__/stdlib/event/event')
local Gui = require('__stdlib__/stdlib/event/gui')
local Inventory = require('__stdlib__/stdlib/entity/inventory')
local Table = require('__stdlib__/stdlib/utils/table')
local Math = require('__stdlib__/stdlib/utils/math')
local mod_gui = require('mod-gui')

local INVENTORY_COLUMNS = 10
local GUI_TYPES = {[defines.gui_type.controller] = true, [defines.gui_type.entity] = true}

local floor, ceil = math.floor, math.ceil

local function get_or_create_filterfill_gui(player)
    local flow = mod_gui.get_button_flow(player)

    if flow.filterfill_requests then return flow end

    local requests = flow.add{type = 'table', name = 'filterfill_requests', column_count = 6, style = 'picker_table'}
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_bp',
        sprite = 'picker-request-bp',
        tooltip = {'filterfill.btn-bp'},
        style = mod_gui.button_style
    }
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_2x',
        sprite = 'picker-request-2x',
        tooltip = {'filterfill.btn-2x'},
        style = mod_gui.button_style
    }
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_5x',
        sprite = 'picker-request-5x',
        tooltip = {'filterfill.btn-5x'},
        style = mod_gui.button_style
    }
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_10x',
        sprite = 'picker-request-10x',
        tooltip = {'filterfill.btn-10x'},
        style = mod_gui.button_style
    }
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_max',
        sprite = 'picker-request-max',
        tooltip = {'filterfill.btn-max'},
        style = mod_gui.button_style
    }
    requests.add{
        type = 'sprite-button',
        name = 'filterfill_requests_btn_0x',
        sprite = 'picker-request-clear',
        tooltip = {'filterfill.btn-clear'},
        style = mod_gui.button_style
    }

    local filters = flow.add{type = 'table', name = 'filterfill_filters', column_count = 5, style = 'picker_table'}
    filters.add{
        type = 'sprite-button',
        name = 'filterfill_filters_btn_all',
        sprite = 'picker-filters-all',
        tooltip = {'filterfill.btn-all'},
        style = mod_gui.button_style
    }
    filters.add{
        type = 'sprite-button',
        name = 'filterfill_filters_btn_down',
        sprite = 'picker-filters-down',
        tooltip = {'filterfill.btn-down'},
        style = mod_gui.button_style
    }
    filters.add{
        type = 'sprite-button',
        name = 'filterfill_filters_btn_right',
        sprite = 'picker-filters-right',
        tooltip = {'filterfill.btn-right'},
        style = mod_gui.button_style
    }
    filters.add{
        type = 'sprite-button',
        name = 'filterfill_filters_btn_set_all',
        sprite = 'picker-filters-set-all',
        tooltip = {'filterfill.btn-set-all'},
        style = mod_gui.button_style
    }
    filters.add{
        type = 'sprite-button',
        name = 'filterfill_filters_btn_clear_all',
        sprite = 'picker-filters-clear-all',
        tooltip = {'filterfill.btn-clear-all'},
        style = mod_gui.button_style
    }
    -- end
    return flow
end

local function safe_number(num)
    return (num < Math.MAX_UINT) and num or (Math.MAX_UINT - 1)
end

-- Filtering: Filter all cells of the opened container with the
-- contents of the player's cursor stack, or the first item in the container,
-- or the first filter in the container
local function get_opened_inventory(player)
    local inv
    if GUI_TYPES[player.opened_gui_type] then
        if player.opened_self then
            inv = player.get_main_inventory()
        elseif player.opened_gui_type == defines.gui_type.entity then
            local opened = player.opened
            if opened.type == 'spider-vehicle' then
                inv = opened.get_inventory(defines.inventory.spider_trunk)
            else
                inv = opened.get_output_inventory()
            end
        end
    end
    return inv
end

local function filterfill_all(event)
    local player = game.players[event.player_index]
    local inventory = get_opened_inventory(player)
    if inventory then
        -- Get the contents of the player's cursor stack, or the first cell
        local desired = (player.cursor_stack.valid_for_read and player.cursor_stack.name) or
                            Inventory.get_item_or_filter(inventory, 1)
        for i = 1, #inventory do
            local current = not event.shift and Inventory.get_item_or_filter(inventory, i)
            inventory.set_filter(i, current or desired or nil)
        end
    end
end
Gui.on_click('filterfill_filters_btn_all', filterfill_all)

-- Filtering: Copies the filter settings of each cell to the cell(s) below it
local function filterfill_down(event)
    local player = game.players[event.player_index]
    local inventory = get_opened_inventory(player)
    if inventory then
        local size = #inventory
        local rows = ceil(size / INVENTORY_COLUMNS)
        for c = 1, INVENTORY_COLUMNS do
            local desired = Inventory.get_item_or_filter(inventory, c)
            for r = 1, rows do
                local i = c + (r - 1) * INVENTORY_COLUMNS
                if i <= size then
                    desired = Inventory.get_item_or_filter(inventory, i) or desired
                    inventory.set_filter(i, desired or nil)
                end
            end
        end
    end
end
Gui.on_click('filterfill_filters_btn_down', filterfill_down)

-- Filtering: Copies the filter settings of each cell to the cell(s) to the right of it
local function filterfill_right(event)
    local player = game.players[event.player_index]
    local inventory = get_opened_inventory(player)
    if inventory then
        local size = #inventory
        local rows = ceil(size / INVENTORY_COLUMNS)
        -- local desired
        for r = 1, rows do
            local desired = Inventory.get_item_or_filter(inventory, 1 + (r - 1) * INVENTORY_COLUMNS)
            for c = 1, INVENTORY_COLUMNS do
                local i = c + (r - 1) * INVENTORY_COLUMNS
                if i <= size then
                    desired = Inventory.get_item_or_filter(inventory, i) or desired
                    inventory.set_filter(i, desired or nil)
                end
            end
        end
    end
end
Gui.on_click('filterfill_filters_btn_right', filterfill_right)

-- Filtering: Set the filters of the opened container to the contents of each cell
local function filterfill_set_all(event)
    local player = game.players[event.player_index]
    local inventory = get_opened_inventory(player)
    if inventory then
        for i = 1, #inventory do
            local desired = Inventory.get_item_or_filter(inventory, i, true)
            inventory.set_filter(i, desired or nil)
        end
    end
end
Gui.on_click('filterfill_filters_btn_set_all', filterfill_set_all)

-- Filtering: Clear all filters in the opened container
local function filterfill_clear_all(event)
    local player = game.players[event.player_index]
    local inventory = get_opened_inventory(player)
    if inventory then for i = 1, #inventory do inventory.set_filter(i, nil) end end
end
Gui.on_click('filterfill_filters_btn_clear_all', filterfill_clear_all)

local function requests_fill(event)
    local player = game.players[event.player_index]
    if player.opened then
        for i = 1, player.opened.request_slot_count do
            local item = player.opened.get_request_slot(i)
            if item then
                -- If requesting 2.5 stacks, then request 3
                local stacks_to_request = ceil(item.count / game.item_prototypes[item.name].stack_size)
                local number_to_request = stacks_to_request * game.item_prototypes[item.name].stack_size
                player.opened.set_request_slot({name = item.name, count = safe_number(number_to_request)}, i)
            end
        end
    end
end
Gui.on_click('filterfill_requests_btn_max', requests_fill)

local function multiply_filter(event)
    local player = game.players[event.player_index]
    local opened = player.opened
    if opened then
        local factor = tonumber(event.element.name:match('%d+'))
        for i = 1, opened.request_slot_count do
            local existing = opened.get_request_slot(i)
            if existing and factor > 0 then
                local count = safe_number(floor(existing.count) * factor)
                opened.set_request_slot({name = existing.name, count = count}, i)
            else
                opened.clear_request_slot(i)
            end
        end
    end
end
Gui.on_click('filterfill_requests_btn_%d+x', multiply_filter)

local function blueprint_requests(event)
    -- chest "should be non-nil" at this point
    local player = game.players[event.player_index]
    local chest = player.opened
    local chest_inv = chest and chest.get_output_inventory()
    local blueprint = Inventory.get_blueprint(player.cursor_stack, true) or
                          (chest_inv and Inventory.get_blueprint(chest_inv[1], true, true))
    if chest then
        if blueprint then
            local slot_count = chest.request_slot_count
            for i = 1, slot_count do chest.clear_request_slot(i) end
            local i = 1
            Table.each(blueprint.cost_to_build, function(v, k)
                if i < slot_count then
                    chest.set_request_slot({name = k, count = safe_number(v)}, i)
                    i = i + 1
                else
                    return true
                end
            end)
        else
            player.print({'filterfill.no-blueprint'})
        end
    else
        event.element.parent.parent.destroy()
    end
end
Gui.on_click('filterfill_requests_btn_bp', blueprint_requests)

local function check_for_filterable_inventory(event)
    local player = game.players[event.player_index]
    local flow = get_or_create_filterfill_gui(player)

    local inv = get_opened_inventory(player)
    if inv then
        local requester = false
        local opened = player.opened
        if opened and opened.type == 'logistic-container' then
            local ptype = opened.prototype
            if ptype.logistic_mode == 'requester' or ptype.logistic_mode == 'buffer' then requester = true end
        end
        local settings = player.mod_settings
        local use_filter_requests = settings['picker-filter-requests'].value
        local use_filter_filters = settings['picker-filter-filters'].value

        flow['filterfill_requests'].visible = use_filter_requests and requester
        flow['filterfill_filters'].visible = use_filter_filters and (inv and inv.supports_filters())
    else
        flow['filterfill_requests'].visible = false
        flow['filterfill_filters'].visible = false
    end
end
Event.register({defines.events.on_gui_opened, defines.events.on_gui_closed}, check_for_filterable_inventory)
