-------------------------------------------------------------------------------
--[Quality Scrolling]--
-------------------------------------------------------------------------------
local events = require('utils/events')

-- Derived from prototypes, not saved state: an old descending storage.quality list is ignored.
-- Build lazily after reload; configuration changes invalidate the local cache.
local quality_names, quality_indices
local function build_quality_order()
    local names, incoming, following = {}, {}, {}
    for name in pairs(prototypes.quality) do
        names[#names + 1] = name
        incoming[name] = 0
    end
    table.sort(names)
    for _, name in ipairs(names) do
        local next_quality = prototypes.quality[name].next
        if next_quality and incoming[next_quality.name] ~= nil then
            following[name] = next_quality.name
            incoming[next_quality.name] = incoming[next_quality.name] + 1
        end
    end

    -- Topological order keeps every next link, including all level-0 defect tiers.
    -- Name order breaks ties between disconnected chains deterministically.
    quality_names, quality_indices = {}, {}
    while #quality_names < #names do
        local candidate
        for _, name in ipairs(names) do
            if not quality_indices[name] and incoming[name] == 0 then
                candidate = name
                break
            end
        end
        -- Defensive fallback for a cyclic graph: still visit each quality only once.
        if not candidate then
            for _, name in ipairs(names) do
                if not quality_indices[name] then candidate = name; break end
            end
        end
        quality_names[#quality_names + 1] = candidate
        quality_indices[candidate] = #quality_names
        local next_name = following[candidate]
        if next_name then incoming[next_name] = incoming[next_name] - 1 end
    end
end

local function cycle_quality(event, direction)
    if not script.active_mods['quality'] then return end
    local player = game.get_player(event.player_index)
    if not (player and player.valid) then return end
    local stack = player.cursor_stack
    local inventory = player.get_main_inventory()
    if not (stack and stack.valid_for_read and inventory and inventory.valid) then return end
    if not quality_names then build_quality_order() end
    local current = quality_indices[stack.quality.name]
    if not current then return end

    -- Scan the inventory once; swap the real stack so quality and item state stay intact.
    local available = {}
    for i = 1, #inventory do
        local slot = inventory[i]
        if slot.valid_for_read and slot.name == stack.name and not available[slot.quality.name] then
            available[slot.quality.name] = slot
        end
    end
    for step = 1, #quality_names do
        local index = (current - 1 + direction * step) % #quality_names + 1
        local target = available[quality_names[index]]
        if target then
            stack.swap_stack(target)
            return
        end
    end
end

events.on('picker-quality-cycle-next', function(event) cycle_quality(event, 1) end)
events.on('picker-quality-cycle-previous', function(event) cycle_quality(event, -1) end)
events.on({'on_init', 'on_configuration_changed'}, function()
    quality_names, quality_indices = nil, nil
end)
