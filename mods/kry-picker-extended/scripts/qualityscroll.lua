-------------------------------------------------------------------------------
--[Quality Scrolling]--
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local Player = require('__kry_stdlib__/stdlib/event/player')
local Table = require('__kry_stdlib__/stdlib/utils/table')
local lib = require('utils/lib')

local function previous_quality(quality)
    local previous
    for key, qualityName in pairs(storage.quality) do
        if qualityName == quality.name then
            previous = prototypes.quality[storage.quality[key+1]]
            --game.print("Name: "..previous.name.."\nLevel: "..previous.level)
        end
    end
    if previous.level == 0 and quality.level == 0 then
        previous = prototypes.quality[storage.quality[1]]
    end
    return previous
end

-- this loops until it finds the previous valid quality, looping back to maximum if necessary
local function get_previous_quality_item(player, stack)
    local quality = stack.quality
    local new_item
    local looped = false
    ::backToStart::
    repeat
        quality=previous_quality(quality)
        new_item = lib.find_item_in_inventory(stack.name,player.get_main_inventory(), quality)
    until new_item or quality.level == storage.minQuality.level
    -- if we hit the minimum quality, try grabbing maxQuality before looping back down from the top
    if not new_item and not looped then
        quality = storage.maxQuality
        new_item = lib.find_item_in_inventory(stack.name,player.get_main_inventory(), quality)
        if not new_item then
            looped = true  -- this variable prevents infinite loops
            goto backToStart
        end
    end
    return new_item
end

-- this loops until it finds the next valid quality, looping back to minimum if neceessary
local function get_next_quality_item(player, stack)
    local quality = stack.quality
    local new_item
    local looped = false
    ::backToStart::
    repeat
        quality=quality.next or storage.minQuality -- quality.next becomes nil with modded qualities
        new_item = lib.find_item_in_inventory(stack.name,player.get_main_inventory(), quality)
    until new_item or quality.level == storage.maxQuality.level
    -- if we hit the maximum quality, try grabbing minQuality before looping back up from the bottom
    if not new_item and not looped then
        quality = storage.minQuality
        new_item = lib.find_item_in_inventory(stack.name,player.get_main_inventory(), quality)
        if not new_item then
            looped = true  -- this variable prevents infinite loops
            goto backToStart
        end
    end
    return new_item
end

-- Register the next quality hotkey,  which simply invokes get_next_quality_item() function
local function quality_scroll_up(event)
    local player, pdata = Player.get(event.player_index)
    local stack = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack
    if stack and stack.quality and stack.quality.level and script.active_mods["quality"] then
        new_item = get_next_quality_item(player, stack)
        if new_item then
            player.cursor_stack.swap_stack(new_item)
        end
    end
end
Event.register('picker-quality-cycle-next', quality_scroll_up)

-- Register the previous quality hotkey, which simply invokes get_prevous_quality_item() function
local function quality_scroll_down(event)
    local player, pdata = Player.get(event.player_index)
    local stack = player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack
    if stack and stack.quality and stack.quality.level and script.active_mods["quality"] then
        new_item = get_previous_quality_item(player, stack)
        if new_item then
            player.cursor_stack.swap_stack(new_item)
        end
    end
end
Event.register('picker-quality-cycle-previous', quality_scroll_down)

-- This runs on first init and when mod configuration is changed, I think
local function setup_quality()
    if script.active_mods["quality"] then
        storage.quality = {}
        local temporary_table = {}
        local minQuality
        local maxQuality
        for _, quality in pairs(prototypes.quality) do
            temporary_table[quality.name] = quality.level
            if not maxQuality or quality.level > maxQuality.level then
                maxQuality = quality
            end
            if not minQuality or quality.level < minQuality.level then
                minQuality = quality
            end
        end
        storage.maxQuality = maxQuality
        storage.minQuality = minQuality
        -- Takes the quality names and sort them by their values, in reverse order
        local sorted_table = {}
        for name, _ in pairs(temporary_table) do
            table.insert(sorted_table, name)
        end
        table.sort(sorted_table, function(a, b)
            return temporary_table[a] > temporary_table[b]
        end)
        -- then store the table for later use
        storage.quality = Table.deepcopy(sorted_table)
    end
end
Event.register(Event.core_events.init_and_config, setup_quality)