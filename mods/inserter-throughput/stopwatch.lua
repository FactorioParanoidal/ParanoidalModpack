local lib = require('lib')
local floor = math.floor

local cycles = 6

local states = {
    collecting = 1,
    carrying = 2,
    waiting_for_space = 3,
    depositing = 4,
    returning = 5,
    waiting_for_items = 6,
}

local beltlike = {
    ['linked-belt'] = true,
    ['loader-1x1'] = true,
    ['loader'] = true,
    ['splitter'] = true,
    ['transport-belt'] = true,
    ['underground-belt'] = true,
}

local state_machine = {
    [states.collecting] = function(watch)
        local inserter = watch.inserter
        local cur_pos = inserter.held_stack_position
        local pick_pos = inserter.pickup_position
        local pick_entity = inserter.pickup_target
        if pick_entity and beltlike[pick_entity.type] then
            if floor(cur_pos.x) ~= floor(pick_pos.x) or floor(cur_pos.y) ~= floor(pick_pos.y) then
                return states.carrying
            end
        else -- must be container-like and therefore inserter won't move around while collecting
            if cur_pos.x ~= pick_pos.x or cur_pos.y ~= pick_pos.y then
                return states.carrying
            end
        end
        return nil
    end,
    [states.carrying] = function(watch)
        local inserter = watch.inserter
        local cur_pos = inserter.held_stack_position
        local drop_pos = inserter.drop_position
        if cur_pos.x == drop_pos.x and cur_pos.y == drop_pos.y then
            return states.waiting_for_space
        end
        local held_stack = inserter.held_stack
        local item_count = held_stack.valid_for_read and held_stack.count or 0
        if item_count < watch.item_count then
            return states.waiting_for_space
        end
        return nil
    end,
    [states.waiting_for_space] = function(watch)
        local held_stack = watch.inserter.held_stack
        local item_count = held_stack.valid_for_read and held_stack.count or 0
        if item_count < watch.item_count then
            return states.depositing
        end
        return nil
    end,
    [states.depositing] = function(watch)
        if not watch.inserter.held_stack.valid_for_read then
            return states.returning
        end
        return nil
    end,
    [states.returning] = function(watch)
        local inserter = watch.inserter
        local cur_pos = inserter.held_stack_position
        local pick_pos = inserter.pickup_position
        if cur_pos.x == pick_pos.x and cur_pos.y == pick_pos.y then
            return states.waiting_for_items
        end
        if inserter.held_stack.valid_for_read and watch.item_count == 0 then
            return states.waiting_for_items
        end
        return nil
    end,
    [states.waiting_for_items] = function(watch)
        if watch.inserter.held_stack.valid_for_read and watch.item_count == 0 then
            return states.collecting
        end
        return nil
    end,
}

local function tick(watch, tick)
    local new_state = watch.state
    local ended = false
    local changed = false
    repeat
        new_state = state_machine[new_state](watch)
        if not new_state then
            break
        end
        changed = true
        watch.state = new_state
        if new_state == states.collecting then
            local cycle = watch.cycle + 1
            watch.cycle = cycle
            if cycle > cycles then
                ended = true
            end
        elseif new_state == states.waiting_for_space then
            watch.counts[watch.cycle] = watch.item_count
        end
        watch.timestamps[new_state][watch.cycle] = tick
    until ended
    local held_stack = watch.inserter.held_stack
    watch.item_count = held_stack.valid_for_read and held_stack.count or 0
    watch.hand_position = watch.inserter.held_stack_position
    return ended
end

local function new(inserter)
    local timestamps = {}
    for _, state in pairs(states) do
        timestamps[state] = {}
    end
    local held_stack = inserter.held_stack
    return {
        inserter = inserter,
        cycle = 0,
        -- a hack to make the cycle start unambiguously when inserter picks up items
        state = states.waiting_for_items,
        item_count = held_stack.valid_for_read and held_stack.count or 0,
        hand_position = inserter.held_stack_position,
        timestamps = timestamps,
        counts = {},
    }
end

local function get_statistics(series)
    local min, max, sum = series[1], series[1], series[1]
    for i = 2, cycles do
        if series[i] < min then
            min = series[i]
        elseif series[i] > max then
            max = series[i]
        end
        sum = sum + series[i]
    end
    return min, max, sum
end

local waiting_state = {
    [states.waiting_for_space] = true,
    [states.waiting_for_items] = true,
}

local function result(watch)
    if watch.cycle <= cycles then
        error('Unable to get the result of an ongoing stopwatch.')
    end
    local stable = true
    local timestamps = watch.timestamps
    local total_time = 0
    for state, state_timestamps in pairs(timestamps) do
        local diffs = {}
        if timestamps[state + 1] then
            for i = 1, cycles do
                diffs[i] = timestamps[state + 1][i] - state_timestamps[i]
            end
        else
            for i = 1, cycles do
                diffs[i] = timestamps[states.collecting][i + 1] - state_timestamps[i]
            end
        end
        local min, max, sum = get_statistics(diffs)
        if min ~= max or waiting_state[state] and sum > 0 then
            stable = false
        end
        total_time = total_time + sum
    end
    local hand_size = lib.get_stack_size(watch.inserter, watch.inserter.prototype)
    local item_min, item_max, item_sum = get_statistics(watch.counts)
    if item_min ~= item_max or item_sum ~= hand_size * cycles then
        stable = false
    end
    -- 60 ticks per second
    return {
        throughput = (item_sum * 60 / total_time),
        stable = stable,
        items = item_sum,
        ticks = total_time,
    }
end

return {
    new = new,
    tick = tick,
    get_throughput = result,
}
