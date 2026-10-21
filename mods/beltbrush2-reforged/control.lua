-- Belt Brush: temporary blueprints of belt lines, corners and balancers made from the belt in hand.
-- The brush is identified by its label, so the label formats below must stay as they are.
local balancers = require("balancers")

local LABEL_PREFIX = "Belt Brush"

--- Brush kind -> word in the label, and back
local WORD_BY_KIND = { line = "Line", corner_rh = "Right", corner_lh = "Left", balancer = "Balancer" }
local KIND_BY_WORD = {}
for kind, word in pairs(WORD_BY_KIND) do KIND_BY_WORD[word] = kind end

---@class BrushSettings
---@field kind "line"|"corner_rh"|"corner_lh"|"balancer"
---@field belt string transport-belt entity name
---@field quality string?
---@field width integer brush width; the input width for a balancer
---@field input integer? balancer input width
---@field output integer? balancer output width

--------------------------------------------------------------------------------------------------
-- Prototype lookups. Prototypes cannot change while the game runs, so these caches live outside
-- `storage`: every peer computes the same values and they cannot desync.
--------------------------------------------------------------------------------------------------

---@type table<string, string|false>
local entity_type_cache = {}

---@param name string
---@return string? type
local function entity_type(name)
    local entity_type_name = entity_type_cache[name]
    if entity_type_name == nil then
        local prototype = prototypes.entity[name]
        entity_type_name = prototype and prototype.type or false
        entity_type_cache[name] = entity_type_name
    end
    return entity_type_name or nil
end

--- The item that places an entity, for blueprint icons
---@param entity_name string
---@return string
local function item_for(entity_name)
    local prototype = prototypes.entity[entity_name]
    local items = prototype and prototype.items_to_place_this
    return items and items[1] and items[1].name or entity_name
end

--- A visible prototype of `type_name` with this belt speed: `preferred` if it qualifies, otherwise
--- the first by name, so every peer picks the same one.
---@param type_name string
---@param speed number
---@param preferred string?
---@return LuaEntityPrototype?
local function same_speed(type_name, speed, preferred)
    local function qualifies(prototype)
        return prototype and prototype.type == type_name and not prototype.hidden and prototype.belt_speed == speed
    end
    if preferred and qualifies(prototypes.entity[preferred]) then return prototypes.entity[preferred] end
    local best
    for name, prototype in pairs(prototypes.get_entity_filtered({ { filter = "type", type = type_name } })) do
        if qualifies(prototype) and (not best or name < best.name) then best = prototype end
    end
    return best
end

---@class BeltFamily
---@field belt string
---@field underground string
---@field splitter string
---@field splitter_item string
---@field max_distance integer

---@type table<string, BeltFamily|false>
local families = {}

--- The underground belt and splitter that go with a belt, or nil when it has no complete set.
--- Splitters used to be mapped for the four vanilla belts only, so a balancer of any other belt
--- (Bob's basic and ultimate belts) kept the express splitters of the template.
---@param belt_name string
---@return BeltFamily?
local function belt_family(belt_name)
    local family = families[belt_name]
    if family == nil then
        family = false
        local belt = prototypes.entity[belt_name]
        if belt and belt.type == "transport-belt" then
            local speed = belt.belt_speed
            local underground = belt.related_underground_belt
                or same_speed("underground-belt", speed, (belt_name:gsub("transport%-belt", "underground-belt")))
            local splitter = same_speed("splitter", speed,
                balancers.splitter_mapping[belt_name] or (belt_name:gsub("transport%-belt", "splitter")))
            if underground and splitter then
                family = {
                    belt = belt_name,
                    underground = underground.name,
                    splitter = splitter.name,
                    splitter_item = item_for(splitter.name),
                    max_distance = underground.max_underground_distance,
                }
            end
        end
        families[belt_name] = family
    end
    return family or nil
end

--- Can this balancer be built from this belt: does it exist, and do the belt's undergrounds reach far enough?
---@param family BeltFamily?
---@param in_width integer
---@param out_width integer
---@return boolean
local function balancer_fits(family, in_width, out_width)
    if not family or not balancers.get_balancer_bpstr(in_width, out_width) then return false end
    local distance = balancers.underground_distance[in_width .. "x" .. out_width]
    return distance == nil or distance <= family.max_distance
end

---@param family BeltFamily?
---@return fun(in_width: integer, out_width: integer): boolean
local function fits_for(family)
    return function(in_width, out_width) return balancer_fits(family, in_width, out_width) end
end

--------------------------------------------------------------------------------------------------
-- Reading what the player holds
--------------------------------------------------------------------------------------------------

---@param label string?
---@return boolean
local function is_brush_label(label)
    return label ~= nil and label:sub(1, #LABEL_PREFIX) == LABEL_PREFIX
end

---@param player LuaPlayer
---@return LuaItemStack? stack the brush blueprint in the cursor
local function held_brush(player)
    local stack = player.cursor_stack
    if stack and stack.valid_for_read and stack.is_blueprint and is_brush_label(stack.label) then
        return stack
    end
    return nil
end

---@param stack LuaItemStack
---@return BrushSettings?
local function read_brush(stack)
    local label = stack.label --[[@as string]]
    local kind = KIND_BY_WORD[label:match("^Belt Brush %((%a+)%)") or ""]
    if not kind then return nil end

    local entities = stack.get_blueprint_entities()
    if not entities then return nil end
    local settings
    for _, entity in pairs(entities) do
        if entity_type(entity.name) == "transport-belt" then
            settings = { kind = kind, belt = entity.name, quality = entity.quality }
            break
        end
    end
    if not settings then return nil end

    if kind == "balancer" then
        local input, output = label:match("%[(%d+)%->(%d+)%]")
        settings.input, settings.output = tonumber(input), tonumber(output)
        settings.width = settings.input
        if not settings.input or not settings.output then return nil end
    else
        settings.width = tonumber(label:match("%[(%d+)%]"))
        if not settings.width then return nil end
    end
    return settings
end

--- The belt in the cursor, as an item or as a ghost
---@param player LuaPlayer
---@return string? belt entity name
---@return string? quality
local function held_belt(player)
    local stack = player.cursor_stack
    if stack and stack.valid_for_read then
        local result = stack.prototype.place_result
        if result and result.type == "transport-belt" then return result.name, stack.quality.name end
        return nil, nil
    end
    local ghost = player.cursor_ghost
    if ghost then
        local result = ghost.name.place_result
        if result and result.type == "transport-belt" then
            -- the entity name, not the item name: they differ for some modded belts
            return result.name, ghost.quality and ghost.quality.name
        end
    end
    return nil, nil
end

--------------------------------------------------------------------------------------------------
-- Putting a brush into the cursor
--------------------------------------------------------------------------------------------------

--- Empty the cursor before a new brush goes in. When the held item cannot go back (full
--- inventory) the cursor stays as it is: overwriting it used to destroy the held belts.
---@param player LuaPlayer
---@return LuaItemStack?
local function empty_cursor(player)
    if not player.clear_cursor() then return nil end
    return player.cursor_stack
end

---@param kind "line"|"corner_rh"|"corner_lh"
---@param belt string
---@param width integer
---@param quality string?
---@return BlueprintEntity[]
local function brush_entities(kind, belt, width, quality)
    local entities = {}
    local function add(x, y, direction)
        entities[#entities + 1] = {
            entity_number = #entities + 1,
            name = belt,
            position = { x = x, y = y },
            direction = direction,
            quality = quality,
        }
    end
    if kind == "line" then
        for x = 1, width do add(x, 0, nil) end
    else
        local east = kind == "corner_rh"
        for x = 1, width do
            for y = 1, width do
                local turns = east and (y <= x) or (not east and y <= width + 1 - x)
                add(x, y, turns and (east and defines.direction.east or defines.direction.west) or nil)
            end
        end
    end
    return entities
end

---@param player LuaPlayer
---@param kind "line"|"corner_rh"|"corner_lh"
---@param belt string
---@param quality string?
---@param width integer
local function give_brush(player, kind, belt, quality, width)
    local stack = empty_cursor(player)
    if not (stack and stack.set_stack({ name = "blueprint", count = 1 })) then return end
    stack.set_blueprint_entities(brush_entities(kind, belt, width, quality))
    stack.label = string.format("%s (%s) [%d]", LABEL_PREFIX, WORD_BY_KIND[kind], width)
    stack.preview_icons = { { index = 1, signal = { name = item_for(belt), quality = quality } } }
    player.cursor_stack_temporary = true
end

---@param player LuaPlayer
---@param belt string
---@param quality string?
---@param in_width integer
---@param out_width integer
local function give_balancer(player, belt, quality, in_width, out_width)
    local family = belt_family(belt)
    if not family or not balancer_fits(family, in_width, out_width) then return end
    local stack = empty_cursor(player)
    if not stack then return end
    -- the template keeps its label, "Belt Brush (Balancer) [in->out]"
    if stack.import_stack(balancers.get_balancer_bpstr(in_width, out_width)) == 1 then
        stack.clear()
        return
    end
    local entities = stack.get_blueprint_entities()
    if not entities then
        stack.clear()
        return
    end
    local replacement = {
        ["transport-belt"] = family.belt,
        ["underground-belt"] = family.underground,
        ["splitter"] = family.splitter,
    }
    for _, entity in pairs(entities) do
        entity.name = replacement[entity_type(entity.name)] or entity.name
        entity.quality = quality
    end
    stack.set_blueprint_entities(entities)
    stack.preview_icons = { { index = 1, signal = { name = family.splitter_item, quality = quality } } }
    player.cursor_stack_temporary = true
end

--- Back to the plain belt in hand
---@param player LuaPlayer
---@param settings BrushSettings
local function give_belt(player, settings)
    player.clear_cursor()
    player.cursor_stack_temporary = false
    player.pipette({ id = prototypes.entity[settings.belt], quality = settings.quality })
end

--------------------------------------------------------------------------------------------------
-- Key actions
--------------------------------------------------------------------------------------------------

local NEXT_KIND = { line = "corner_rh", corner_rh = "corner_lh", corner_lh = "line", balancer = "line" }
local PREV_KIND = { line = "corner_lh", corner_lh = "corner_rh", corner_rh = "line", balancer = "line" }

---@param order table<string, string>
local function cycle_kind(order)
    ---@param player LuaPlayer
    return function(player)
        local stack = held_brush(player)
        local settings = stack and read_brush(stack)
        if not settings then return end
        give_brush(player, order[settings.kind], settings.belt, settings.quality, settings.width)
    end
end

---@param player LuaPlayer
local function longer(player)
    local stack = held_brush(player)
    if stack then
        local settings = read_brush(stack)
        if not settings then return end
        if settings.kind == "balancer" then
            give_balancer(player, settings.belt, settings.quality, settings.input + 1, settings.output)
        else
            give_brush(player, settings.kind, settings.belt, settings.quality, settings.width + 1)
        end
        return
    end
    local belt, quality = held_belt(player)
    if belt then give_brush(player, "line", belt, quality, 2) end
end

---@param player LuaPlayer
local function shorter(player)
    local stack = held_brush(player)
    local settings = stack and read_brush(stack)
    if not settings then return end
    if settings.kind == "balancer" then
        if settings.input > 1 then
            give_balancer(player, settings.belt, settings.quality, settings.input - 1, settings.output)
        end
    elseif settings.width > 2 then
        give_brush(player, settings.kind, settings.belt, settings.quality, settings.width - 1)
    elseif settings.width == 2 then
        give_belt(player, settings)
    else
        player.clear_cursor()
    end
end

--- Cycle balancer output widths forward (step 1) or backward (step -1)
---@param step 1|-1
local function cycle_balancers(step)
    ---@param player LuaPlayer
    return function(player)
        local stack = held_brush(player)
        local belt, quality, in_width
        if stack then
            local settings = read_brush(stack)
            if not settings then return end
            if settings.kind == "balancer" then
                local fits = fits_for(belt_family(settings.belt))
                local out_width = balancers.step_ow(settings.input, settings.output, step, fits)
                if out_width ~= 0 then
                    give_balancer(player, settings.belt, settings.quality, settings.input, out_width)
                elseif settings.input == 1 then
                    give_belt(player, settings)
                else
                    give_brush(player, "line", settings.belt, settings.quality, settings.input)
                end
                return
            end
            belt, quality, in_width = settings.belt, settings.quality, settings.width
        else
            belt, quality = held_belt(player)
            in_width = 1
            if not belt then return end
        end
        local outputs = balancers.usable_outputs(in_width, fits_for(belt_family(belt)))
        local out_width = outputs[step == 1 and 1 or #outputs]
        if out_width then give_balancer(player, belt, quality, in_width, out_width) end
    end
end

for input_name, action in pairs({
    ["beltbrush-cycle-corners"] = cycle_kind(NEXT_KIND),
    ["beltbrush-cycle-corners-rev"] = cycle_kind(PREV_KIND),
    ["beltbrush-line-longer"] = longer,
    ["beltbrush-line-shorter"] = shorter,
    ["beltbrush-cycle-balancers"] = cycle_balancers(1),
    ["beltbrush-cycle-balancers-rev"] = cycle_balancers(-1),
}) do
    script.on_event(input_name, function(event)
        local player = game.get_player(event.player_index)
        if player then action(player) end
    end)
end

--------------------------------------------------------------------------------------------------
-- Building as you go: ghosts placed with a brush in hand are built at once from the inventory
--------------------------------------------------------------------------------------------------

---@param player LuaPlayer
---@param entity LuaEntity
---@return boolean
local function in_build_range(player, entity)
    local reach = player.build_distance
    local from, to = player.physical_position, entity.position
    local dx, dy = from.x - to.x, from.y - to.y
    return dx * dx + dy * dy <= reach * reach
end

script.on_event(defines.events.on_built_entity, function(event)
    local ghost = event.entity
    if not (ghost and ghost.valid and ghost.type == "entity-ghost") then return end
    local player = game.get_player(event.player_index)
    if not (player and held_brush(player)) then return end
    if ghost.surface_index ~= player.physical_surface_index or not in_build_range(player, ghost) then return end

    local items = ghost.ghost_prototype.items_to_place_this
    local place = items and items[1]
    if not place then return end
    local inventory = player.get_main_inventory()
    if not inventory then return end
    local quality = ghost.quality.name
    if inventory.get_item_count({ name = place.name, quality = quality }) < place.count then return end

    -- revive first: taking the items before a failed revive used to lose them
    local _, revived = ghost.silent_revive({ raise_revive = true })
    if revived then
        inventory.remove({ name = place.name, quality = quality, count = place.count })
    end
end, { { filter = "ghost" } })
