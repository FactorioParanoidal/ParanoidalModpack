local const = require("const") --[[@as Squeakthrough.const]]
local cmu = require("collision-mask-util")
local util = require("util")

local character = data.raw.character.character

-- BoundingBox may be written as {{x, y}, {x, y}}, with x/y keys, or with left_top/right_bottom.
local function box_corners(box)
    local lt = box.left_top or box[1]
    local rb = box.right_bottom or box[2]
    return lt, rb
end

local function get_coord(point, axis)
    if axis == 1 then return point.x or point[1] end
    return point.y or point[2]
end

local function set_coord(point, axis, value)
    if axis == 1 then
        if point.x ~= nil then point.x = value else point[1] = value end
    else
        if point.y ~= nil then point.y = value else point[2] = value end
    end
end

-- Shrink every character a tiny bit so it fits exactly into the gaps formed below.
for _, prototype in pairs(data.raw.character or {}) do
    local box = prototype.collision_box
    if box then
        local lt, rb = box_corners(box)
        if lt and rb then
            for axis = 1, 2 do
                set_coord(lt, axis, math.min(0, get_coord(lt, axis) + 1/256))
                set_coord(rb, axis, math.max(0, get_coord(rb, axis) - 1/256))
            end
        end
    end
end

---@type table<string, boolean>
local disabled_types = {}
for group, ptypes in pairs(const.groups) do
    for _, ptype in pairs(ptypes) do
        disabled_types[ptype] = settings.startup["sqt-disable-modify-" .. group].value --[[@as boolean]]
    end
end

---@return table<string, true>
local function parse_csv(setting)
    ---@cast setting string
    local values = {}
    for value in setting:gmatch("([^,]+)") do
        value = value:match("^%s*(.-)%s*$")
        if value ~= "" then values[value] = true end
    end
    return values
end

local blacklist_types = parse_csv(settings.startup["sqt-blacklist-types"].value)
local blacklist_names = parse_csv(settings.startup["sqt-blacklist-names"].value)

local remove_collision = settings.startup["sqt-remove-collision"].value
local remove_types = parse_csv(settings.startup["sqt-remove-collision-types"].value)
local remove_names = parse_csv(settings.startup["sqt-remove-collision-names"].value)

-- Entity names are unique across all entity types; next_upgrade may point to another type.
---@type table<string, data.EntityPrototype>
local entities_by_name = {}
---@type table<string, table<string, data.EntityPrototype>>
local downgrades = {}

for ptype in pairs(defines.prototypes.entity) do
    for name, prototype in pairs(data.raw[ptype] or {}) do
        entities_by_name[name] = prototype
        if prototype.next_upgrade then
            local downgrade = downgrades[prototype.next_upgrade] or {}
            downgrades[prototype.next_upgrade] = downgrade
            downgrade[name] = prototype
        end
    end
end

--- All entities connected to `prototype` through next_upgrade in either direction.
---@param prototype data.EntityPrototype
---@return data.EntityPrototype[]
local function upgrade_group(prototype)
    local seen, result, queue = {[prototype.name] = true}, {}, {prototype}
    while #queue > 0 do
        local current = table.remove(queue)
        result[#result + 1] = current
        local neighbours = {}
        if current.next_upgrade then
            neighbours[#neighbours + 1] = entities_by_name[current.next_upgrade]
        end
        for _, downgrade in pairs(downgrades[current.name] or {}) do
            neighbours[#neighbours + 1] = downgrade
        end
        for _, neighbour in pairs(neighbours) do
            if not seen[neighbour.name] then
                seen[neighbour.name] = true
                queue[#queue + 1] = neighbour
            end
        end
    end
    return result
end

local character_mask = cmu.get_mask(character)

-- Removing "train" would let rolling stock pass through entities such as gates.
local kept_layers = {train = true}

---@param mask data.CollisionMaskConnector
local function collides_with_character(mask)
    for layer in pairs(character_mask.layers) do
        if mask.layers[layer] then return true end
    end
    return false
end

---@type table<string, true>
local removed_layers = {}

---@param prototype data.EntityPrototype
local function remove_player_collision(prototype)
    if removed_layers[prototype.name] then return end
    for _, member in pairs(upgrade_group(prototype)) do
        removed_layers[member.name] = true
        local mask = util.copy(cmu.get_mask(member))
        for layer in pairs(character_mask.layers) do
            if not kept_layers[layer] then mask.layers[layer] = nil end
        end
        if collides_with_character(mask) then
            log("Squeak Through 2: not removing collision from " .. member.type .. "/" .. member.name ..
                ", it collides with the character through a layer that must be kept")
        else
            member.collision_mask = mask
        end
    end
end

---@param n number
---@param override number?
local function trim(n, override)
    local max_trim = override or 0.3
    local sign = n >= 0 and 1 or -1
    n = n * sign
    local base = math.floor(n * 2) / 2
    local decimal = math.fmod(n, 0.5)
    local new_decimal = math.min(max_trim, decimal)
    return (base + new_decimal) * sign
end

-- Off-grid entities (trees) have no tile grid to keep a gap to: clamp the box size directly.
---@param n number
---@param max_size number
local function clamp(n, max_size)
    if n >= 0 then return math.min(n, max_size) end
    return math.max(n, -max_size)
end

---@type table<string, data.BoundingBox>
local original_boxes = {}

---@param prototype data.EntityPrototype
local function process_prototype(prototype)
    if removed_layers[prototype.name] then return end

    local mask = cmu.get_mask(prototype)
    if mask.colliding_with_tiles_only then return end

    if remove_collision and remove_names[prototype.name] then
        remove_player_collision(prototype)
        return
    end
    if blacklist_names[prototype.name] then return end

    if remove_collision and remove_types[prototype.type] then
        remove_player_collision(prototype)
        return
    end
    if blacklist_types[prototype.type] then return end

    ---@diagnostic disable-next-line: undefined-field
    if prototype.squeak_behaviour == false then return end

    local is_disabled = disabled_types[prototype.type]
    if is_disabled ~= false then return end

    local collision_box = prototype.collision_box
    if not collision_box then return end

    local is_tree = prototype.type == "tree"
    local flags = prototype.flags
    if flags and not is_tree then
        for _, flag in pairs(flags) do
            if flag == "placeable-off-grid" then return end
        end
    end

    local lt, rb = box_corners(collision_box)
    local values = {
        ltx = get_coord(lt, 1),
        lty = get_coord(lt, 2),
        rbx = get_coord(rb, 1),
        rby = get_coord(rb, 2)
    }

    local override = const.overrides[prototype.type]
    local modified = false
    for name, value in pairs(values) do
        local new_value = is_tree and clamp(value, override or 0.3) or trim(value, override)
        if new_value ~= value then
            values[name] = new_value
            modified = true
        end
    end

    if modified then
        original_boxes[prototype.name] = util.copy(collision_box)
        prototype.collision_box = {{values.ltx, values.lty}, {values.rbx, values.rby}}
    end
end

local prototypes = cmu.collect_prototypes_colliding_with_mask(cmu.get_mask(character))
---@cast prototypes data.EntityPrototype[]
for _, prototype in pairs(prototypes) do
    process_prototype(prototype)
end

-- next_upgrade requires identical collision boxes. If an exclusion (blacklist, squeak_behaviour,
-- disabled group, off-grid flag, removed collision) split an upgrade chain, restore the whole chain.
local function same_box(a, b)
    if not a or not b then return a == b end
    local alt, arb = box_corners(a)
    local blt, brb = box_corners(b)
    for axis = 1, 2 do
        if get_coord(alt, axis) ~= get_coord(blt, axis) or get_coord(arb, axis) ~= get_coord(brb, axis) then
            return false
        end
    end
    return true
end

local function original_box(prototype)
    return original_boxes[prototype.name] or prototype.collision_box
end

local modified_names = {}
for name in pairs(original_boxes) do
    modified_names[#modified_names + 1] = name
end
table.sort(modified_names)

---@type table<string, true>
local checked = {}
for _, name in ipairs(modified_names) do
    if not checked[name] then
        local group = upgrade_group(entities_by_name[name])
        local broken = false
        for _, member in pairs(group) do
            checked[member.name] = true
            local target = member.next_upgrade and entities_by_name[member.next_upgrade]
            if target and same_box(original_box(member), original_box(target))
                and not same_box(member.collision_box, target.collision_box) then
                broken = true
            end
        end
        if broken then
            for _, member in pairs(group) do
                if original_boxes[member.name] then
                    member.collision_box = original_boxes[member.name]
                    original_boxes[member.name] = nil
                end
            end
            log("Squeak Through 2: upgrade chain of " .. name .. " is only partly modifiable, collision boxes left unchanged")
        end
    end
end

require("compatibility")
