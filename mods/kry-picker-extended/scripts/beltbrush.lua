-------------------------------------------------------------------------------
--[Belt Brush]--
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local Player = require('__kry_stdlib__/stdlib/event/player')
local Position = require('__kry_stdlib__/stdlib/area/position')
local Area = require('__kry_stdlib__/stdlib/area/area')
local Direction = require('__kry_stdlib__/stdlib/area/direction')
local Inventory = require('__kry_stdlib__/stdlib/entity/inventory')
local table = require('__kry_stdlib__/stdlib/utils/table')

local Pad = require('utils/adjustmentpad')
local lib = require('utils/lib')

local balancers = require('blueprints/balancers')

--These item types can be used to make brush widths
local match_to_brush = {
    ['transport-belt'] = true,
    ['underground-belt'] = true,
    ['loader'] = true,
    ['pipe-to-ground'] = true,
    ['wall'] = true,
    ['heat-pipe'] = true,
    ['inserter'] = true,
    ['pipe'] = true,
    -- ['container'] = true,
    -- ['logistic-container'] = true,
    -- ['rail'] = true,
    -- ['straight-rail'] = true
}

--These items types will be automatically revived in belt brush BPs
local match_to_revive = {
    ['splitter'] = true,
}
table.merge(match_to_revive, match_to_brush)

local function get_match(stack, cursor_ghost)
    if cursor_ghost then
        local result = cursor_ghost.place_as_tile_result or cursor_ghost.place_result
        return match_to_brush[result and result.type or 'nil'] and cursor_ghost.name
    elseif stack.valid_for_read then
        if stack.prototype.place_result and match_to_brush[stack.prototype.place_result.type or 'nil'] then
            return stack.prototype.place_result.name
        elseif stack.is_blueprint and stack.is_blueprint_setup() then
            local ents = stack.get_blueprint_entities()
            if ents then
                local ent =
                    table.find(
                    ents,
                    function(v)
                        return match_to_brush[prototypes.entity[v.name].type]
                    end
                )
                return ent and ent.name
            end
        end
    end
end

--Revive belts in build range when using belt brush blueprints
local function revive_belts(event)
    local player = Player.get(event.player_index)
    local ent = event.entity
    if ent.name == 'entity-ghost' and match_to_revive[ent.ghost_type] and Inventory.is_named_bp(player.cursor_stack, 'Belt Brush') then
        local ghost = event.entity
        local name = ghost.ghost_name
        if Position.distance(player.position, ghost.position) <= player.build_distance + 1 then
            if player.get_item_count(name) > 0 then
                local _, revived = ghost.revive{raise_revive = true}
                if revived then
                    player.remove_item({name = name, count = 1})
                end
            end
        end
    end
end
Event.register(defines.events.on_built_entity, revive_belts)

local function build_beltbrush(stack, name, lanes)
    if name then
        local entities = {}
        local _, width = Area(prototypes.entity[name].collision_box):size()
        width = math.ceil(width)
        for i = 1, lanes do
            entities[#entities + 1] = {
                entity_number = i,
                name = name,
                position = {-0.5 + (i * width), -0.5},
                direction = Direction.north
            }
        end
        -- Shift all entities in the blueprint to try and keep it centered on the cursor
        table.each(
            entities,
            function(ent)
                ent.position = Position(ent.position):translate(Direction.west, math.ceil((lanes * width) / 2))
            end
        )
        stack.set_blueprint_entities(entities)
        stack.label = 'Belt Brush ' .. lanes
        stack.allow_manual_label_change = false
    end
end

local function create_or_destroy_bp(player, lanes)
    local stack = player.cursor_stack
    local name = get_match(stack, player.cursor_ghost)

    if name then
        if lanes > 1 then
            if not (Inventory.is_named_bp(stack, 'Belt Brush') or Inventory.is_named_bp(stack, 'Pipette Blueprint')) and player.clear_cursor() then
                stack = lib.get_planner(player, 'picker-blueprint-tool', 'Belt Brush')
                stack.clear_blueprint()
            end
            if Inventory.get_blueprint(player.cursor_stack, false) then
                build_beltbrush(stack, name, lanes)
            end
        elseif Inventory.is_named_bp(stack, 'Belt Brush') and lanes == 1 then
            local inv = player.get_main_inventory()
            local item = inv.find_item_stack(name)
            if item then
                stack.set_stack(item) -- set the cursor stack to the item
                item.clear() -- clear the item from the inventory
            else
                stack.clear() -- no item found, just nuke the cursor stack
                player.cursor_ghost = name
            end
        end
    end
end

-------------------------------------------------------------------------------
--[Beltbrush Corners]--
-------------------------------------------------------------------------------
local function mirror_corners(stack)
    local entities = stack.get_blueprint_entities()
    for i, entity in pairs(entities) do
        entity.direction = (0 - (entity.direction or 0)) % 16
        entity.position.x = -1 * entity.position.x
    end
    stack.set_blueprint_entities(entities)
end

local function build_corner_brush(stack, belt, lanes)
    if lanes >= 1 and lanes <= 32 then
        local new_ents = {}
        local next_id = 1

        local dir = belt.direction or 0

        local function next_dir()
            -- if dir = west then loops back to north (0)
            --return dir == 0 and 6 or dir - 2
            return dir == 0 and Direction.west or dir - 4
        end

        local function get_dir(x, y)
            if y + .5 - lanes + x + .5 <= 1 then
                return next_dir()
            else
                return dir
            end
        end

        for x = .5, lanes, 1 do
            for y = .5, lanes, 1 do
                next_id = next_id + 1
                new_ents[#new_ents + 1] = {
                    entity_number = next_id,
                    name = belt.name,
                    position = {x = x, y = y},
                    direction = get_dir(x, y)
                }
            end
        end
        table.each(
            new_ents,
            function(ent)
                ent.position = Position(ent.position):translate(Direction.northwest, math.ceil(lanes / 2))
            end
        )
        stack.set_blueprint_entities(new_ents)
        stack.label = 'Belt Brush Corner Left ' .. lanes
    end
end

local function build_ug_brush(stack, ug, lanes)
    if lanes >= 1 and lanes <= 32 then
        local name = ug.name
        local direction = ug.direction
        local type = ug.type

        local opposite_type = {
            ['input'] = 'output',
            ['output'] = 'input'
        }

        local distance = tonumber(stack.label:match('Belt Brush Underground %d+x(%d+)'))
        local max = prototypes.entity[ug.name].max_underground_distance
        max = distance or max
        if max > 0 then
            local new_ents = {}
            local next_id = 0
            local get_next_id = function()
                next_id = next_id + 1
                return next_id
            end

            for x = 0.5, lanes, 1 do
                new_ents[#new_ents + 1] = {
                    entity_number = get_next_id(),
                    name = name,
                    direction = direction,
                    type = type,
                    position = {x, -0.5}
                }
                new_ents[#new_ents + 1] = {
                    entity_number = get_next_id(),
                    name = name,
                    direction = direction,
                    type = opposite_type[type],
                    position = {x, -(0.5 + max)}
                }
            end
            table.each(
                new_ents,
                function(ent)
                    ent.position = Position(ent.position):translate(Direction.west, math.ceil(lanes / 2))
                    ent.position = Position(ent.position):translate(Direction.south, math.ceil(max / 2))
                end
            )
            stack.set_blueprint_entities(new_ents)
            stack.label = 'Belt Brush Underground ' .. lanes .. 'x' .. (max - 1)
        else
            build_beltbrush(stack, ug.name, lanes)
        end
    end
end

local function build_ptg_brush(stack, ptg, lanes)
    if lanes >= 1 and lanes <= 32 then
        local name = ptg.name
        local direction = ptg.direction or 0
        local new_ents = {}
        local distance = tonumber(stack.label:match('Belt Brush Pipe to Ground %d+x(%d+)'))
        local max = distance or prototypes.entity[name].max_underground_distance
        local next_id = 0
        local get_next_id = function()
            next_id = next_id + 1
            return next_id
        end

        if max > 0 then
            for x = 0.5, lanes, 1 do
                new_ents[#new_ents + 1] = {
                    entity_number = get_next_id(),
                    name = name,
                    direction = direction,
                    position = {x, 0.5}
                }
                new_ents[#new_ents + 1] = {
                    entity_number = get_next_id(),
                    name = name,
                    direction = Direction.opposite(direction),
                    position = {x, (0.5 + max)}
                }
            end

            table.each(
                new_ents,
                function(ent)
                    ent.position = Position(ent.position):translate(Direction.west, math.ceil(lanes / 2))
                    ent.position = Position(ent.position):translate(Direction.north, math.ceil(max / 2))
                end
            )
            stack.set_blueprint_entities(new_ents)
            stack.label = 'Belt Brush Pipe to Ground ' .. lanes .. 'x' .. (max - 1)
        else
            build_beltbrush(stack, ptg.name, lanes)
        end
    end
end

-- Build corners based on brushed width on key press
-- pressing a second time will mirror the corner
-- pressing a third time will revert to brush width
local function beltbrush_corners(event)
    local player = game.get_player(event.player_index)
    local stack = player.cursor_stack
    if Inventory.is_named_bp(stack, 'Belt Brush') then
        local stored = tonumber(Pad.get_or_create_adjustment_pad(player, 'beltbrush')['beltbrush_text_box'].text)
        local bp_ents = stack.get_blueprint_entities()
        local belt, ug, ptg
        table.find(
            bp_ents,
            function(v)
                local proto = prototypes.entity[v.name].type
                if proto == 'transport-belt' then
                    belt = v
                    return true
                elseif proto == 'underground-belt' then
                    ug = v
                    return true
                elseif proto == 'pipe-to-ground' then
                    ptg = v
                    return true
                end
            end
        )

        if not (stack.label:find('Corner') or stack.label:find('Underground') or stack.label:find('Pipe to Ground')) then
            if belt and belt.name then
                build_corner_brush(stack, belt, stored)
            elseif ug and ug.name then
                build_ug_brush(stack, ug, stored)
            elseif ptg and ptg.name then
                build_ptg_brush(stack, ptg, stored)
            end
        elseif stack.label:find('Belt Brush Corner Left') then
            mirror_corners(stack)
            stack.label = 'Belt Brush Corner Right ' .. stack.label:match('%d+')
        elseif stack.label:find('Belt Brush Corner Right') then
            build_beltbrush(stack, belt.name, tonumber(stack.label:match('%d+')))
        elseif stack.label:find('Belt Brush Underground') then
            build_ug_brush(stack, ug, tonumber(stack.label:match('%d+')))
        elseif stack.label:find('Belt Brush Pipe to Ground') then
            build_ptg_brush(stack, ptg, tonumber(stack.label:match('%d+')))
        end
    end
end
Event.register('picker-beltbrush-corners', beltbrush_corners)

local function mirror_blueprint(event)
    local blueprint = event.blueprint
    if blueprint and blueprint.valid then
        if blueprint.label and not event.corner then
            if blueprint.label:find('Belt Brush Corner Left') then
                blueprint.label = 'Belt Brush Corner Right ' .. blueprint.label:match('%d+')
            elseif blueprint.label:find('Belt Brush Corner Right') then
                blueprint.label = 'Belt Brush Corner Left ' .. blueprint.label:match('%d+')
            end
        end
    end
end

-------------------------------------------------------------------------------
--[Automatic Balancers]--
-------------------------------------------------------------------------------
local function build_cascading_underground(stack, ug, lanes)
    if lanes >= 1 and lanes <= 32 then
        local next_id = 0
        local get_next_id = function()
            next_id = next_id + 1
            return next_id
        end
        local casc = {}

        local distance = tonumber(stack.label:match('Belt Brush Cascade %d+x(%d+)'))
        local max = prototypes.entity[ug.name].max_underground_distance
        max = distance or max

        if max > 0 then
            local skip = lanes + .5
            for y = .5, (lanes * max) + max, max + 1 do
                for x = .5, lanes + 0.5, 1 do
                    if x < skip then
                        casc[#casc + 1] = {
                            entity_number = get_next_id(),
                            name = ug.name,
                            direction = Direction.south,
                            type = 'input',
                            position = {x, y}
                        }

                        casc[#casc + 1] = {
                            entity_number = get_next_id(),
                            name = ug.name,
                            direction = Direction.south,
                            type = 'output',
                            position = {x, y + max}
                        }
                    end
                end
                skip = skip - 1
            end
            table.each(
                casc,
                function(ent)
                    ent.position = Position(ent.position):translate(Direction.west, math.ceil(lanes / 2))
                    ent.position = Position(ent.position):translate(Direction.north, math.ceil(max / 2))
                end
            )
            stack.set_blueprint_entities(casc)
            stack.label = 'Belt Brush Cascade ' .. lanes .. 'x' .. (max - 1)
        else
            build_beltbrush(stack, ug.name, lanes)
        end
    end
end

-- Build balancers based on brush width on key press.
-- Subsequent key presses will cycle through the availble balancers
local function beltbrush_balancers(event)
    local player = Player.get(event.player_index)
    local stack = player.cursor_stack
    if Inventory.is_named_bp(stack, 'Belt Brush') --[[or get_match(stack)]] then
        local lanes = tonumber(Pad.get_or_create_adjustment_pad(player, 'beltbrush')['beltbrush_text_box'].text)
        local bp = stack.is_blueprint and stack.is_blueprint_setup() and stack.get_blueprint_entities()
        local belt =
            table.find(
            bp,
            function(v)
                return prototypes.entity[v.name].type == 'transport-belt'
            end
        )
        local ug =
            table.find(
            bp,
            function(v)
                return prototypes.entity[v.name].type == 'underground-belt'
            end
        )
        belt = belt and belt.name
        if belt then
            local kind = belt:gsub('transport%-belt', '')
            local current = stack.label:gsub('Belt Brush Balancers %d+x', '')

            --set the width to 1 less then existing or existing if not a balancer already
            local width = (tonumber(current) and tonumber(current) - 1) or lanes

            if lanes then
                local ents

                local i = 0
                repeat
                    --ents = table.deepcopy(balancers[lanes .. 'x' .. width])
                    ents = balancers[lanes .. 'x' .. width]
                    width = (not ents and ((width <= 1 and 32) or (width - 1))) or width
                    i = i + 1
                until ents or width == lanes or i == 100

                if ents and not (width == lanes and stack.label:find('Belt Brush Balancers')) then
                    stack.import_stack(ents)
                    ents = stack.get_blueprint_entities()
                    table.each(
                        ents,
                        function(v)
                            v.name = kind .. v.name
                        end
                    )
                    stack.set_blueprint_entities(ents)
                    stack.label = 'Belt Brush Balancers ' .. lanes .. 'x' .. width
                elseif stack.label:find('Belt Brush Balancers') then
                    build_beltbrush(stack, belt, lanes)
                end
            end
        elseif ug and ug.name then
            build_cascading_underground(stack, ug, lanes)
        end
    end
end
Event.register('picker-beltbrush-balancers', beltbrush_balancers)

-------------------------------------------------------------------------------
--[Allow Upgrades]--
-------------------------------------------------------------------------------
-- When a blueprint is placed check to see if it is a beltbrush bp and if it is destroy matched ghosts underneath.
local function placed_blueprint(event)
    local player, pdata = Player.get(event.player_index)
    local stack = Inventory.get_blueprint(player.cursor_stack, true)
    if stack and Inventory.is_named_bp(stack, 'Belt Brush') and (pdata.last_ghost_check or 0) <= event.tick - 2 and not stack.label:find("Belt Brush %d+") then
        local corners = {lx = 0, ly = 0, rx = 0, ry = 0}
        --Create a bounding box from the blueprint entities.
        table.each(
            stack.get_blueprint_entities(),
            function(v)
                if v.position.x > 0 and v.position.x > corners.rx then
                    corners.rx = v.position.x + .5
                elseif v.position.x <= 0 and v.position.x < corners.lx then
                    corners.lx = v.position.x - .5
                end
                if v.position.y > 0 and v.position.y > corners.ry then
                    corners.ry = v.position.y + .5
                elseif v.position.y <= 0 and v.position.y < corners.ly then
                    corners.ly = v.position.y - .5
                end
            end
        )

        --For all ghosts in the bounding box destroy them if they match revivables.
        local position = Position({math.floor(event.position.x) + .5, math.floor(event.position.y) + .5})
        table.each(
            player.surface.find_entities_filtered {
                name = 'entity-ghost',
                area = Area({{corners.lx, corners.ly}, {corners.rx, corners.ry}}):offset(position)
            },
            function(v)
                if match_to_revive[v.ghost_type] then
                    v.destroy()
                end
            end
        )
        pdata.last_ghost_check = event.tick
    end
end
Event.register(defines.events.on_pre_build, placed_blueprint)

-------------------------------------------------------------------------------
--[Adjustment Pad]--
-------------------------------------------------------------------------------
local function increase_decrease_reprogrammer(event)
    local player = game.get_player(event.player_index)
    local stack = player.cursor_stack
    local belt_brush = Inventory.is_named_bp(stack, 'Belt Brush')
    local change = event.change or 0
    if get_match(stack, player.cursor_ghost) or belt_brush then
        local pad = Pad.get_or_create_adjustment_pad(player, 'beltbrush')
        local text_field = pad['beltbrush_text_box']
        local count = tonumber(text_field.text) or 1
        local lanes = belt_brush and stack.label:match('%d+') or count
        if event.element and event.element.name == 'beltbrush_text_box' then
            if not tonumber(event.element.text) then
                lanes = 1
            else
                lanes = count <= 32 and count or 32
            end
        elseif event.element and event.element.name == 'beltbrush_btn_reset' then
            lanes = 1
            belt_brush = false
        else
            lanes = lanes and math.min(math.max(1, lanes + change), 32) or 1
        end
        text_field.text = tostring(lanes)
        pad['beltbrush_btn_reset'].enabled = lanes > 1
        if not (belt_brush and change == 0) then
            create_or_destroy_bp(player, lanes)
        end
    else
        Pad.remove_gui(player, 'beltbrush_frame_main')
    end
end
local events = {defines.events.on_player_cursor_stack_changed, 'picker-beltbrush-hack'}
Pad.register_events('beltbrush', increase_decrease_reprogrammer, events)

local function register_mirror_events()
    local inter = remote.interfaces['PickerBlueprinter']
    if inter and inter['get_event_name'] then
        Event.set_event_name('on_blueprint_mirrored', remote.call('PickerBlueprinter', 'get_event_name'))
        Event.register(Event.get_event_name('on_blueprint_mirrored'), mirror_blueprint)
    end
end
Event.register(Event.core_events.init_and_load, register_mirror_events)
