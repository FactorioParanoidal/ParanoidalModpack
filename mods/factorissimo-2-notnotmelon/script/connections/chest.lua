local Chest = {}

Chest.color = {r = 200 / 255, g = 110 / 255, b = 38 / 255}
Chest.entity_types = {"container", "logistic-container", "infinity-container", "linked-container"}
Chest.unlocked = function(force) return force.technologies["factory-connection-type-chest"].researched end

local blacklist = {"factory-overlay-controller", "factory-requester-chest-factory-1", "factory-requester-chest-factory-2", "factory-requester-chest-factory-3"}
local blacklisted = {}
for _, name in pairs(blacklist) do blacklisted[name] = true end

local function get_chest_type(chest)
    local type = chest.prototype.logistic_mode
    if type == "requester" then
        return "input"
    elseif type == "active-provider" then
        return "output"
    elseif type == "passive-provider" then
        return "output"
    elseif type == "buffer" then
        return "output"
    elseif type == "storage" then
        return "input"
    else
        return "neutral"
    end
end

Chest.connect = function(factory, cid, cpos, outside_entity, inside_entity, settings)
    if blacklisted[outside_entity.name] or blacklisted[inside_entity.name] then return nil end

    -- Connection mode: 0 for balance, 1 for inwards, 2 for outwards
    if not settings.mode then
        local outside_type = get_chest_type(outside_entity)
        local inside_type = get_chest_type(inside_entity)
        if outside_type == inside_type then
            settings.mode = 0
        elseif outside_type == "input" or inside_type == "output" then
            settings.mode = 1
        elseif outside_type == "output" or inside_type == "input" then
            settings.mode = 2
        end
    end

    return {outside = outside_entity, inside = inside_entity, do_tick_update = true}
end

Chest.recheck = function(conn)
    return conn.outside.valid and conn.inside.valid
end

local DELAYS = {10, 20, 60, 180, 600}
local DEFAULT_DELAY = 60
Chest.indicator_settings = {"d0", "b0"}

for _, v in pairs(DELAYS) do
    table.insert(Chest.indicator_settings, "d" .. v)
    table.insert(Chest.indicator_settings, "b" .. v)
end

local function make_valid_delay(delay)
    for _, v in pairs(DELAYS) do
        if v == delay then return v end
    end
    return 0 -- Catchall
end

Chest.direction = function(conn)
    local mode = (conn._settings.mode or 0)
    if mode == 0 then
        return "b" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), defines.direction.north
    elseif mode == 1 then
        return "d" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_in
    else
        return "d" .. make_valid_delay(conn._settings.delay or DEFAULT_DELAY), conn._factory.layout.connections[conn._id].direction_out
    end
end

Chest.rotate = function(conn)
    conn._settings.mode = ((conn._settings.mode or 0) + 1) % 3
    local mode = conn._settings.mode
    if mode == 0 then
        return {"factory-connection-text.balance-mode"}
    elseif mode == 1 then
        return {"factory-connection-text.input-mode"}
    else
        return {"factory-connection-text.output-mode"}
    end
end

Chest.adjust = function(conn, positive)
    local delay = conn._settings.delay or DEFAULT_DELAY
    if positive then
        for i = #DELAYS, 1, -1 do
            if DELAYS[i] < delay then
                delay = DELAYS[i]
                break
            end
        end
        conn._settings.delay = delay
        return {"factory-connection-text.update-faster", delay}
    else
        for i = 1, #DELAYS do
            if DELAYS[i] > delay then
                delay = DELAYS[i]
                break
            end
        end
        conn._settings.delay = delay
        return {"factory-connection-text.update-slower", delay}
    end
end

local function get_contents_by_quality(inventory)
    local contents = inventory.get_contents()
    local count_by_quality = {}
    for _, item_data in pairs(contents) do
        local item = item_data.name
        local count = item_data.count
        local quality = item_data.quality

        count_by_quality = count_by_quality or {}
        count_by_quality[item] = count_by_quality[item] or {}
        count_by_quality[item][quality] = count
    end
    return count_by_quality
end

local function balance_items(item, quality, count, input_inv, output_inv)
    while count > 0 do
        local stack = input_inv.find_item_stack {name = item, quality = quality}
        if not stack then break end

        if stack.count > count then
            if -- this method will wipe data for the following item types. We instead swap full stacks.
                stack.is_blueprint or
                stack.is_blueprint_book or
                stack.is_item_with_label or
                stack.is_item_with_inventory or
                stack.is_item_with_entity_data or
                stack.is_selection_tool or
                stack.is_armor
            then
                local empty_stack = output_inv.find_empty_stack()
                if empty_stack then stack.swap_stack(empty_stack) end -- May cause "sloshing"
                return
            end

            local amount_moved = output_inv.insert {
                name = item,
                count = count,
                quality = quality,
                health = stack.health,
                durability = stack.is_tool and stack.durability or nil,
                ammo = stack.is_ammo and stack.ammo or nil,
                tags = stack.is_item_with_tags and stack.tags or nil,
                custom_description = stack.is_item_with_tags and stack.custom_description or nil,
                spoil_percent = stack.spoil_percent,
            }
            stack.count = stack.count - amount_moved
            break
        else
            local amount_moved = output_inv.insert(stack)
            if amount_moved == stack.count then
                stack.clear()
            elseif amount_moved == 0 then
                break
            else
                stack.count = stack.count - amount_moved
            end
            count = count - amount_moved
        end
    end
    output_inv.sort_and_merge()
end

local floor = math.floor
local function balance_chests(outside_inv, inside_inv)
    local outside_contents = get_contents_by_quality(outside_inv)
    local inside_contents = get_contents_by_quality(inside_inv)

    for item, by_quality in pairs(outside_contents) do
        for quality, count in pairs(by_quality) do
            local count2 = (inside_contents[item] and inside_contents[item][quality]) or 0
            local diff = count - count2
            if diff > 1 then
                balance_items(item, quality, floor(diff / 2), outside_inv, inside_inv)
            elseif diff < -1 then
                balance_items(item, quality, floor(-diff / 2), inside_inv, outside_inv)
            end
        end
    end
    for item, by_quality in pairs(inside_contents) do
        for quality, count in pairs(by_quality) do
            local count2 = (outside_contents[item] and outside_contents[item][quality]) or 0
            if count2 == 0 then
                balance_items(item, quality, floor(count / 2), inside_inv, outside_inv)
            end
        end
    end
end

local function move_items_inwards(outside_inv, inside_inv)
    if inside_inv.is_full() then return end
    for i = 1, #outside_inv do
        local stack = outside_inv[i]
        if stack.valid_for_read then
            local amount_moved = inside_inv.insert(stack)
            if amount_moved > 0 then
                stack.count = stack.count - amount_moved
            end
        end
    end
end

local function move_items_outwards(outside_inv, inside_inv)
    if outside_inv.is_full() then return end
    for i = 1, #inside_inv do
        local stack = inside_inv[i]
        if stack.valid_for_read then
            local amount_moved = outside_inv.insert(stack)
            if amount_moved > 0 then
                stack.count = stack.count - amount_moved
            end
        end
    end
end


Chest.tick = function(conn)
    local outside = conn.outside
    local inside = conn.inside
    if outside.valid and inside.valid then
        local outside_inv = outside.get_inventory(defines.inventory.chest)
        local inside_inv = inside.get_inventory(defines.inventory.chest)
        local mode = conn._settings.mode or 0
        if mode == 0 then
            balance_chests(outside_inv, inside_inv)
        elseif mode == 1 then
            move_items_inwards(outside_inv, inside_inv)
        else
            move_items_outwards(outside_inv, inside_inv)
        end
        return conn._settings.delay or DEFAULT_DELAY
    else
        return false
    end
end

Chest.destroy = function(conn)
end

return Chest
