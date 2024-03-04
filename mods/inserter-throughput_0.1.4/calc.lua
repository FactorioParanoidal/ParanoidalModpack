local abs = math.abs
local sqrt = math.sqrt
local acos = math.acos
local round_up = math.ceil
local full_circle_in_radians = math.pi * 2
local item_size_on_belt = 0.25 -- in tiles
local inserter_angle_precision = 0.001 -- hardcoded game mechanic, or so it seems

-- belt speed in tiles per tick
-- inserters can put items in the vicinity of their drop spot,
-- as long as there is no item center directly beneath them
-- e.g. they can place the second item on the very next tick
-- also, the inserter can put down an item either before or after
-- the belt moves in a given tick (usually before)
-- picking items up is vastly more complex and therefore not implemented
local function get_belt_penalty(belt_speed, stack_size)
    local penalty = 0
    stack_size = stack_size - 1
    local item_center_offset = belt_speed
    local acted = true
    while stack_size > 0 do
        if item_center_offset > 0 then
            stack_size = stack_size - 1
            item_center_offset = item_center_offset - item_size_on_belt
            acted = true
        end
        item_center_offset = item_center_offset + belt_speed
        if not acted and (item_center_offset > 0) then
            stack_size = stack_size - 1
            item_center_offset = item_center_offset - item_size_on_belt
            acted = true
        end
        penalty = penalty + 1
        acted = false
    end
    return penalty
end

local function calc(rotation_speed, extension_speed, pickup_vector, drop_vector, stack_size, pickup_belt_speed, drop_belt_speed)
    local pickup_x, pickup_y = pickup_vector[1], pickup_vector[2]
    local drop_x, drop_y = drop_vector[1], drop_vector[2]
    local pickup_length = sqrt(pickup_x * pickup_x + pickup_y * pickup_y)
    local drop_length = sqrt(drop_x * drop_x + drop_y * drop_y)
    -- get angle from the dot product
    local angle = 0
    if pickup_length > 0 and drop_length > 0 then
        angle = acos((pickup_x * drop_x + pickup_y * drop_y) / (pickup_length * drop_length))
    end
    -- convert it to circles
    -- the inserter doesn't have to swing all the way, only within a certain angle of destination
    angle = angle / full_circle_in_radians - inserter_angle_precision
    -- rotation speed is in circles per tick
    local ticks_per_cycle = 2 * round_up(angle / rotation_speed)
    local extension_time = 2 * round_up(abs(pickup_length - drop_length) / extension_speed)
    if ticks_per_cycle < extension_time then
        ticks_per_cycle = extension_time
    end
    -- inserters can not pick up and put down items in the same tick, so the full cycle is at least two ticks
    if ticks_per_cycle < 2 then
        ticks_per_cycle = 2
    end
    if pickup_belt_speed and (stack_size > 1) then
        ticks_per_cycle = ticks_per_cycle + get_belt_penalty(pickup_belt_speed, stack_size)
    end
    if drop_belt_speed and (stack_size > 1) then
        ticks_per_cycle = ticks_per_cycle + get_belt_penalty(drop_belt_speed, stack_size)
    end
    return stack_size * 60 / ticks_per_cycle -- 60 = ticks per second
end

return calc