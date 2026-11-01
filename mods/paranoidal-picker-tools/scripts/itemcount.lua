-------------------------------------------------------------------------------
--[[Item Count]] -- from Yemto's Item Count (yemtositemcount) by Yemto
-------------------------------------------------------------------------------
-- Shows how many of the held item the player has; for a blueprint, how many times it can be built
-- from the main inventory. Setting names are the ones of the original mod.
local events = require('utils/events')

local GUI_NAME = 'total_item_count'
local SUFFIXES = {'', 'k', 'M', 'B', 'T', 'Qa', 'Qi', 'Sx', 'Sp', 'Oc', 'No'}
local PLANNERS = {['deconstruction-planner'] = true, ['upgrade-planner'] = true}
local GROUP_SEPARATOR = {['1,247'] = ',', ['1.247'] = '.', ['1 247'] = ' '}

local function set_caption(player, caption)
    local center = player.gui.center
    local label = center[GUI_NAME]
    if not label then
        label = center.add {type = 'label', name = GUI_NAME, caption = '0', ignored_by_interaction = true}
        label.style.font = 'default-bold'
    end
    label.caption = caption
end

local function remove_gui(player)
    local label = player.gui.center[GUI_NAME]
    if label then
        label.destroy()
    end
end

local function get_blueprint_record(player)
    local record = player.cursor_record
    if record and record.valid then
        record = record.type == 'blueprint-book' and record.get_selected_record(player) or record
        if record and record.valid and record.type == 'blueprint' then
            return record
        end
    end
    return nil
end

local function get_book_stack(player)
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.is_blueprint_book and stack.active_index then
        local book_inv = stack.get_inventory(defines.inventory.item_main)
        if book_inv and stack.active_index <= #book_inv then
            local book_stack = book_inv[stack.active_index]
            return book_stack.valid and book_stack or nil
        end
    end
    return nil
end

local function is_blacklisted(settings, stack)
    local name = stack.name
    if PLANNERS[name] then
        return settings['yemtositemcount-disable-blueprint-items'].value
    end
    if name == 'artillery-targeting-remote' then
        return settings['yemtositemcount-disable-artillery-remote'].value
    end
    return false
end

local function format_number(settings, num)
    local f = settings['yemtositemcount-number-format'].value
    local separator = GROUP_SEPARATOR[f]
    if separator then
        local text = tostring(num):reverse():gsub('(%d%d%d)', '%1' .. separator):reverse():gsub('^[^0-9]+', '')
        return text
    end
    if f == '1,2k' or f == '1.2k' then
        local c = 1
        while num > 1000 and c < #SUFFIXES do
            num = num / 1000
            c = c + 1
        end
        local text = tostring(math.floor(num * 10) / 10):gsub('([^0-9]+)', f == '1,2k' and ',' or '.')
        return text .. SUFFIXES[c]
    end
    return tostring(num)
end

local function count_from_cost(player, settings, cost_to_build)
    local inventory = player.get_inventory(defines.inventory.character_main)
    if not inventory then
        return ''
    end
    local count
    for _, required in pairs(cost_to_build) do
        local times = inventory.get_item_count({name = required.name, quality = required.quality}) / required.count
        if count == nil or times < count then
            count = times
        end
    end
    if type(count) ~= 'number' then
        return ''
    end
    return 'x' .. format_number(settings, math.floor(count))
end

local function count_held(player, settings, stack)
    local inventory = player.get_inventory(defines.inventory.character_main)
    if not inventory then
        return ''
    end
    if stack.is_blueprint or stack.is_blueprint_book then
        -- cost_to_build errors for some stacks (a book without an active blueprint)
        local ok, material = pcall(function()
            return stack.cost_to_build
        end)
        if not ok or type(material) ~= 'table' then
            return ''
        end
        return count_from_cost(player, settings, material)
    end
    return format_number(settings, stack.count + inventory.get_item_count({name = stack.name, quality = stack.quality}))
end

-- Players whose blueprint preview is still loading: player index -> true. Kept in storage, and on_tick is
-- registered only while it is not empty (also in on_load), so every peer, including a joining client, runs the
-- same per-tick GUI updates.
local wait_for_blueprint

local function stop_waiting_if_empty()
    if not (storage.preview_queue and next(storage.preview_queue)) then
        storage.preview_queue = nil
        script.on_event(defines.events.on_tick, nil)
    end
end

wait_for_blueprint = function()
    local preview_queue = storage.preview_queue or {}
    for pid in pairs(preview_queue) do
        local player = game.get_player(pid)
        local blueprint = player and get_blueprint_record(player)
        if not blueprint then
            -- the player is gone or no longer holds a blueprint
            preview_queue[pid] = nil
        elseif not blueprint.is_preview then
            preview_queue[pid] = nil
            set_caption(player, count_from_cost(player, player.mod_settings, blueprint.cost_to_build) .. ' ')
        end
    end
    stop_waiting_if_empty()
end

local function refresh(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local settings = player.mod_settings
    if settings['yemtositemcount-disable-mod'].value then
        remove_gui(player)
        return
    end

    local blueprint = get_blueprint_record(player)
    if blueprint then
        if blueprint.is_preview then
            storage.preview_queue = storage.preview_queue or {}
            storage.preview_queue[event.player_index] = true
            script.on_event(defines.events.on_tick, wait_for_blueprint)
        else
            set_caption(player, count_from_cost(player, settings, blueprint.cost_to_build) .. ' ')
        end
        return
    end

    local stack = get_book_stack(player) or player.cursor_stack
    if stack and stack.valid_for_read and not is_blacklisted(settings, stack) then
        set_caption(player, count_held(player, settings, stack) .. ' ')
    else
        remove_gui(player)
    end
end

events.on({
    defines.events.on_player_cursor_stack_changed,
    defines.events.on_player_main_inventory_changed,
    defines.events.on_player_ammo_inventory_changed,
    defines.events.on_player_armor_inventory_changed
}, refresh)

events.on('on_load', function()
    if storage.preview_queue and next(storage.preview_queue) then
        script.on_event(defines.events.on_tick, wait_for_blueprint)
    end
end)
