local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Area = require('__stdlib__/stdlib/area/area')
local Position = require('__stdlib__/stdlib/area/position')
local table = require('__stdlib__/stdlib/utils/table')
local Queue = require('scripts/hash_queue')
local queue
local cfg

-- Local functions for commonly used math functions
local max, floor = math.max, math.floor

local config = require('config')
local armormods = require('scripts/armormods')
local bot_radius = config.BOT_RADIUS
local queue_speed = config.QUEUE_SPEED_BONUS
local AFK_TIME = 4 * defines.time.second

local function unique(tbl)
    return table.keys(table.invert(tbl))
end
local inv_list =
    unique {
    defines.inventory.character_main,
    defines.inventory.god_main,
    defines.inventory.chest,
    defines.inventory.character_vehicle,
    defines.inventory.character_trash,
    defines.inventory.car_trunk,
    defines.inventory.cargo_wagon
}

local function update_settings()
    local setting = settings['global']
    cfg = {
        poll_rate = setting['nanobots-nano-poll-rate'].value,
        queue_rate = setting['nanobots-nano-queue-rate'].value,
        queue_cycle = setting['nanobots-nano-queue-per-cycle'].value,
        build_tiles = setting['nanobots-nano-build-tiles'].value,
        network_limits = setting['nanobots-network-limits'].value,
        nanobots_auto = setting['nanobots-nanobots-auto'].value,
        equipment_auto = setting['nanobots-equipment-auto'].value
    }
end
Event.register(defines.events.on_runtime_mod_setting_changed, update_settings)
update_settings()

--table.find functions
local table_find = table.find
-- return the name of the item found for table.find if we found at least 1 item or cheat_mode is enabled.
local _find_item = function(v, _, p)
    local item, count = v.name, v.count
    return p.cheat_mode or p.get_item_count(item) >= count or (p.vehicle and (p.vehicle.get_item_count(item) >= count or (p.vehicle and p.vehicle.train and p.vehicle.train.get_item_count(item) > count)))
end

-- Is the player connected, not afk, and have an attached character
-- @param player: the player object
-- @return bool: player is connected and ready
local function is_connected_player_ready(player)
    return (player.afk_time < AFK_TIME and player.character)
end

local function has_powered_equipment(character, eq_name)
    local grid = character.grid
    if grid and grid.get_contents()[eq_name] then
        return table_find(
            grid.equipment,
            function(v)
                return v.name == eq_name and v.energy > 0
            end
        )
    end
end

-- Is the player not in a logistic network or has a working nano-interface
-- @param player: the player character object
-- @return bool: true if has chip or not in network
local function nano_network_check(character, e)
    if has_powered_equipment(character, 'equipment-bot-chip-nanointerface') then
        return true
    else
        local c = character
        local networks = e and e.surface.find_logistic_networks_by_construction_area(e.position, e.force) or c.surface.find_logistic_networks_by_construction_area(c.position, c.force)
        -- Con bots in network
        local pnetwork = c.logistic_cell and c.logistic_cell and c.logistic_cell.mobile and c.logistic_cell.logistic_network
        local has_pbots = c.logistic_cell and c.logistic_cell.construction_radius > 0 and c.logistic_cell.logistic_network and c.logistic_cell.logistic_network.all_construction_robots > 0
        local has_nbots =
            table.any(
            networks,
            function(network)
                return network ~= pnetwork and network.all_construction_robots > 0
            end
        )
        return not (has_pbots or has_nbots)
    end
end

-- Can nanobots repair this entity.
-- @param entity: the entity object
-- @return bool: repairable by nanobots
local function nano_repairable_entity(entity)
    return ((entity.get_health_ratio() or 1) < 1) and not (entity.has_flag('breaths-air') or ((entity.type == 'car' or entity.type == 'train') and entity.speed > 0) or entity.type:find('robot'))
end

-- Get the gun, ammo and ammo name for the named gun: will return nil
-- for all returns if there is no ammo for the gun.
-- @param player: the player object
-- @param gun_name: the name of the gun to get
-- @return the gun object or nil
-- @return the ammo object or nil
-- @return string: the name of the ammo or nil
local function get_gun_ammo_name(player, gun_name)
    local index = player.character.selected_gun_index
    local gun = player.get_inventory(defines.inventory.character_guns)[index]
    local ammo = player.get_inventory(defines.inventory.character_ammo)[index]
    if gun.valid_for_read and gun.name == gun_name and ammo.valid and ammo.valid_for_read then
        return gun, ammo, ammo.name
    end
    return nil, nil, nil
end

-- Attempt to insert an item_stack or array of item_stacks into the entity
-- Spill to the ground at the entity/player anything that doesn't get inserted
-- @param entity: the entity or player object
-- @param item_stacks: a SimpleItemStack or array of SimpleItemStacks to insert
-- @return bool : there was some items inserted or spilled
local function insert_or_spill_items(entity, item_stacks)
    local new_stacks = {}
    if item_stacks then
        if item_stacks[1] and item_stacks[1].name then
            new_stacks = item_stacks
        elseif item_stacks and item_stacks.name then
            new_stacks = {item_stacks}
        end
        for _, stack in pairs(new_stacks) do
            local name, count, health = stack.name, stack.count, stack.health or 1
            if game.item_prototypes[name] and not game.item_prototypes[name].has_flag('hidden') then
                local inserted = entity.insert({name = name, count = count, health = health})
                if inserted ~= count then
                    entity.surface.spill_item_stack(entity.position, {name = name, count = count - inserted, health = health}, true)
                end
            end
        end
        return new_stacks[1] and new_stacks[1].name and true
    end
end

-- Attempt to insert an arrary of items stacks into an entity
-- @param entity: the entity object
-- @param item_stacks: a SimpleItemStack or array of SimpleitemStacks to insert
-- @return table: an array of SimpleItemStacks not inserted
local function insert_into_entity(entity, item_stacks)
    item_stacks = item_stacks or {}
    if item_stacks and item_stacks.name then
        item_stacks = {item_stacks}
    end
    local new_stacks = {}
    for _, stack in pairs(item_stacks) do
        local name, count, health = stack.name, stack.count, stack.health or 1
        local inserted = entity.insert(stack)
        if inserted ~= count then
            new_stacks[#new_stacks + 1] = {name = name, count = count - inserted, health = health}
        end
    end
    return new_stacks
end

-- Scan the ground under a ghost entities collision box for items and insert them into the player.
-- @param entity: the entity object to scan under
-- @return table: a table of SimpleItemStacks or nil if empty
local function get_all_items_on_ground(entity, existing_stacks)
    local item_stacks = existing_stacks or {}
    local surface, position, bouding_box = entity.surface, entity.position, entity.ghost_prototype.selection_box
    local area = Area.offset(bouding_box, position)
    for _, item_on_ground in pairs(surface.find_entities_filtered {name = 'item-on-ground', area = area}) do
        item_stacks[#item_stacks + 1] = {name = item_on_ground.stack.name, count = item_on_ground.stack.count, health = item_on_ground.health or 1}
        item_on_ground.destroy()
    end
    local inserter_area = Area.expand(area, 3)
    for _, inserter in pairs(surface.find_entities_filtered {area = inserter_area, type = 'inserter'}) do
        local stack = inserter.held_stack
        if stack.valid_for_read and Position.inside(inserter.held_stack_position, area) then
            item_stacks[#item_stacks + 1] = {name = stack.name, count = stack.count, health = stack.health or 1}
            stack.clear()
        end
    end
    return (item_stacks[1] and item_stacks) or {}
end

-- Get items with health data from the inventory
-- @param entity: the entity object to search
-- @param item: the item to look for
-- @return item_stack; SimpleItemStack
local function get_items_from_inv(entity, item_stack, cheat)
    if not cheat then
        local sources
        if entity.vehicle and entity.vehicle.train then
            sources = entity.vehicle.train.cargo_wagons
            sources[#sources + 1] = entity
        elseif entity.vehicle then
            sources = {entity.vehicle, entity}
        else
            sources = {entity}
        end
        for _, source in pairs(sources) do
            for _, inv in pairs(inv_list) do
                local inventory = source.get_inventory(inv)
                if inventory and inventory.valid then
                    local stack = inventory.get_item_count(item_stack.name) > 0 and inventory.find_item_stack(item_stack.name)
                    if stack and stack.count >= item_stack.count then
                        local new_item_stack = {name = stack.name, count = item_stack.count, health = stack.health or 1}
                        stack.count = stack.count - item_stack.count
                        return new_item_stack
                    end
                end
            end
        end
    else
        return {name = item_stack.name, count = item_stack.count, health = 1}
    end
end

-- Manually drain ammo, if it is the last bit of ammo in the stack pull in more ammo from inventory if available
-- @param player: the player object
-- @param ammo: the ammo itemstack
-- @return bool: this was the last one to be drained
local function ammo_drain(player, ammo, amount)
    amount = amount or 1
    local name = ammo.name
    ammo.drain_ammo(amount)
    if not ammo.valid_for_read then
        local new = player.get_inventory(defines.inventory.character_main).find_item_stack(name)
        if new then
            ammo.set_stack(new)
            new.clear()
        end
        return true
    end
end

-- Get the radius to use based on tehnology and player defined radius
-- @param player: the player entity to check
-- @param nano_ammo: the ammo to check
local function get_ammo_radius(player, nano_ammo)
    local data = global.players[player.index]
    local max_radius = bot_radius[player.force.get_ammo_damage_modifier(nano_ammo.prototype.get_ammo_type().category)] or 7
    local custom_radius = data.ranges[nano_ammo.name] or max_radius
    return custom_radius <= max_radius and custom_radius or max_radius
end

-- Attempt to satisfy module requests from player inventory
-- @param requests: the item request proxy to get requests from
-- @param entity: the entity to satisfy requests for
-- @param player: the entity to get modules from
local function satisfy_requests(requests, entity, player)
    local pinv = player.get_inventory(defines.inventory.character_main) or player.get_inventory(defines.inventory.god_main)
    local new_requests = {}
    for name, count in pairs(requests.item_requests) do
        if entity.can_insert(name) then
            local removed = player.cheat_mode and count or pinv.remove({name = name, count = count})
            local inserted = removed > 0 and entity.insert({name = name, count = removed}) or 0
            local balance = count - inserted
            new_requests[name] = balance > 0 and balance or nil
        else
            new_requests[name] = count
        end
    end
    requests.item_requests = new_requests
end

-- Create a projectile from source to target
-- @param name: the name of the projecticle
-- @param surface: the surface to create the projectile on
-- @param force: the force this projectile belongs too
-- @param source: position table to start at
-- @param target: position table to end at
local function create_projectile(name, surface, force, source, target, speed)
    speed = speed or 1
    force = force or 'player'
    surface.create_entity {name = name, force = force, position = source, target = target, speed = speed}
end

--[[Nano Emitter Queue Handler --]]
--Queued items are handled one at a time, --check validity of all stored objects at this point, They could have become
--invalidated between the time they were entered into the queue and now.

--Handles all of the deconstruction and scrapper related tasks.
function Queue.deconstruction(data)
    local entity, player = data.entity, game.players[data.player_index]
    if player and player.valid then
        if entity and entity.valid and entity.to_be_deconstructed(player.force) then
            local item_stacks = {}

            create_projectile('nano-projectile-deconstructors', entity.surface, entity.force, player.position, entity.position)
            create_projectile('nano-projectile-return', entity.surface, entity.force, entity.position, player.position)

            if entity.type == 'item-entity' then
                item_stacks[#item_stacks + 1] = {
                    name = entity.stack.name,
                    count = entity.stack.count,
                    health = entity.stack.health,
                    durability = entity.stack.durability
                }
                if #item_stacks > 0 then
                    insert_or_spill_items(player, item_stacks)
                end
                entity.destroy()
            elseif entity.name == 'deconstructible-tile-proxy' then
                local tile = entity.surface.get_tile(entity.position)
                if tile then
                    player.mine_tile(tile)
                end
            elseif entity.valid then
                player.mine_entity(entity)
            end
        end
    --Valid entity
    end
    --Valid player
end

function Queue.build_entity_ghost(data)
    local ghost, player, ghost_surf, ghost_pos = data.entity, game.players[data.player_index], data.surface, data.position
    if (player and player.valid) then
        if ghost.valid then
            local item_stacks = get_all_items_on_ground(ghost)
            if player.surface.can_place_entity {name = ghost.ghost_name, position = ghost.position, direction = ghost.direction, force = ghost.force} then
                local revived, entity, requests = ghost.revive({return_item_request_proxy = true})
                if revived then
                    create_projectile('nano-projectile-constructors', entity.surface, entity.force, player.position, entity.position)
                    entity.health = (entity.health > 0) and ((data.item_stack.health or 1) * entity.prototype.max_health)
                    if insert_or_spill_items(player, insert_into_entity(entity, item_stacks)) then
                        create_projectile('nano-projectile-return', ghost_surf, player.force, ghost_pos, player.position)
                    end
                    if requests then
                        satisfy_requests(requests, entity, player)
                    end
                    script.raise_event(
                        defines.events.on_robot_built_entity,
                        {
                            robot = player.character,
                            created_entity = entity,
                            revived = true,
                            stack = nil
                        }
                    )
                else --not revived, return item
                    insert_or_spill_items(player, {data.item_stack})
                end --revived
            else --can't build
                insert_or_spill_items(player, {data.item_stack})
            end --can build
        else --not valid ghost
            insert_or_spill_items(player, {data.item_stack})
        end --valid ghost
    end --valid player
end

function Queue.build_tile_ghost(data)
    local ghost, surface, position, player = data.entity, data.surface, data.position, game.players[data.player_index]
    if (player and player.valid) then
        if ghost.valid then
            local tile, hidden_tile = surface.get_tile(position), surface.get_hidden_tile(position)
            local force = ghost.force
            local tile_was_mined = false
            local ghost_was_revived = false

            -- Is there any existing tile that needs returned
            if hidden_tile and tile.prototype.can_be_part_of_blueprint and player.mine_tile(tile) then
                create_projectile('nano-projectile-return', surface, force, position, player.position)
                tile_was_mined = true
            end
            -- ghost may be invalid after mining.
            if ghost.valid then
                ghost_was_revived = ghost.revive()
            end

            if tile_was_mined or ghost_was_revived then
                local ptype = data.item_stack and game.item_prototypes[data.item_stack.name]
                create_projectile('nano-projectile-constructors', surface, force, player.position, position)
                -- if the tile was mined, we need to manually place the tile.
                -- checking if the ghost was revived is likely unnecessary but felt safer.
                if tile_was_mined and not ghost_was_revived then
                    local tile_name = ptype.place_as_tile_result['result'].name
                    surface.set_tiles({{name = tile_name, position = position}})
                end

                surface.create_entity {name = 'nano-sound-build-tiles', position = position}
                script.raise_event(
                    defines.events.on_robot_built_tile,
                    {
                        robot = player.character,
                        positions = {position},
                        surface_index = surface.index,
                        item = ptype,
                        tile = tile,
                        tiles = {
                            {
                                position = position,
                                old_tile = tile
                            }
                        },
                        stack = nil
                    }
                )
            else --Can't place or revive the tile, give item back.
                insert_or_spill_items(player, {data.item_stack})
            end --Tile was placed or revived
        else --Give the item back ghost isn't valid anymore.
            insert_or_spill_items(player, {data.item_stack})
        end --valid ghost
    end --valid player
end

function Queue.upgrade_ghost(data)
    local ghost, player, surface, position = data.entity, game.players[data.player_index], data.surface, data.position
    if (player and player.valid) then
        if ghost.valid then
            local entity =
                surface.create_entity {
                name = data.item_stack.name,
                direction = ghost.direction,
                force = ghost.force,
                position = position,
                fast_replace = true,
                player = player,
                type = ghost.type == 'underground-belt' and ghost.belt_to_ground_type or nil
            }
            if entity then
                create_projectile('nano-projectile-constructors', entity.surface, entity.force, player.position, entity.position)
                entity.health = (entity.health > 0) and ((data.item_stack.health or 1) * entity.prototype.max_health)
                script.raise_event(
                    defines.events.on_robot_built_entity,
                    {
                        robot = player.character,
                        created_entity = entity,
                        revived = true,
                        stack = nil
                    }
                )
            else --not revived, return item
                insert_or_spill_items(player, {data.item_stack})
            end --revived
        else --not valid ghost
            insert_or_spill_items(player, {data.item_stack})
        end --valid ghost
    end --valid player
end

--[[ Nano Emmitter --]]
-- Extension of the tick handler, This functions decide what to do with their
-- assigned robots and insert them into the queue accordingly.
-- TODO: replace table_find entity-match with hashed lookup
-- Nano Constructors
-- Queue the ghosts in range for building, heal stuff needing healed
local function queue_ghosts_in_range(player, pos, nano_ammo)
    --local queue = global.nano_queue
    local pdata = global.players[player.index]
    local force = player.force
    local _next_nano_tick = (pdata._next_nano_tick and pdata._next_nano_tick < (game.tick + 2000) and pdata._next_nano_tick) or game.tick
    local tick_spacing = max(1, cfg.queue_rate - (queue_speed[force.get_gun_speed_modifier('nano-ammo')] or queue_speed[4]))
    local next_tick, queue_count = queue:next(_next_nano_tick, tick_spacing)
    local radius = get_ammo_radius(player, nano_ammo)
    local area = Position.expand_to_area(pos, radius)

    for _, ghost in pairs(player.surface.find_entities(area)) do
        local deconstruct = ghost.to_be_deconstructed(force)
        local upgrade = ghost.to_be_upgraded() and ghost.force == force

        if ghost.type ~= 'cliff' and (deconstruct or upgrade or ghost.force == force) then
            if nano_ammo.valid and nano_ammo.valid_for_read then
                if not cfg.network_limits or nano_network_check(player.character, ghost) then
                    if queue_count() < cfg.queue_cycle then
                        if deconstruct then
                            if ghost.minable and not queue:get_hash(ghost) then
                                local data = {
                                    player_index = player.index,
                                    action = 'deconstruction',
                                    deconstructors = true,
                                    entity = ghost,
                                    position = ghost.position,
                                    surface = ghost.surface,
                                    unit_number = ghost.unit_number,
                                    ammo = nano_ammo
                                }
                                queue:insert(data, next_tick())
                                ammo_drain(player, nano_ammo, 1)
                            end
                        elseif upgrade then
                            if not queue:get_hash(ghost) then
                                --get first available item that places entity from inventory that is not in our hand.
                                local proto = ghost.prototype.next_upgrade
                                if proto then
                                    proto = {{name = proto.name, count = 1}}
                                    local item_stack = table_find(proto, _find_item, player)
                                    if item_stack then
                                        local data = {
                                            action = 'upgrade_ghost',
                                            player_index = player.index,
                                            entity = ghost,
                                            surface = ghost.surface,
                                            position = ghost.position,
                                            unit_number = ghost.unit_number,
                                            ammo = nano_ammo
                                        }

                                        local place_item = get_items_from_inv(player, item_stack, player.cheat_mode)
                                        if place_item then
                                            data.item_stack = place_item
                                            queue:insert(data, next_tick())
                                            ammo_drain(player, nano_ammo, 1)
                                        end
                                    end
                                end
                            end
                        elseif ghost.name == 'entity-ghost' or (ghost.name == 'tile-ghost' and cfg.build_tiles) then
                            if not queue:get_hash(ghost) then
                                --get first available item that places entity from inventory that is not in our hand.
                                local item_stack = table_find(ghost.ghost_prototype.items_to_place_this, _find_item, player)
                                if item_stack then
                                    local data = {
                                        player_index = player.index,
                                        entity = ghost,
                                        surface = ghost.surface,
                                        position = ghost.position,
                                        unit_number = ghost.unit_number,
                                        ammo = nano_ammo
                                    }
                                    if ghost.name == 'entity-ghost' then
                                        local place_item = get_items_from_inv(player, item_stack, player.cheat_mode)
                                        if place_item then
                                            data.action = 'build_entity_ghost'
                                            data.item_stack = place_item
                                            queue:insert(data, next_tick())
                                            ammo_drain(player, nano_ammo, 1)
                                        end
                                    elseif ghost.name == 'tile-ghost' then
                                        --Don't queue tile ghosts if entity ghost is on top of it.
                                        if ghost.surface.count_entities_filtered {name = 'entity-ghost', area = Area(ghost.bounding_box):non_zero(), limit = 1} == 0 then
                                            local tile = ghost.surface.get_tile(ghost.position)
                                            if tile then
                                                local place_item = get_items_from_inv(player, item_stack, player.cheat_mode)
                                                if place_item then
                                                    data.item_stack = place_item
                                                    data.action = 'build_tile_ghost'
                                                    queue:insert(data, next_tick())
                                                    ammo_drain(player, nano_ammo, 1)
                                                end
                                            end
                                        end
                                    end
                                end
                            end --hash check
                        elseif nano_repairable_entity(ghost) then
                            --Check if entity needs repair, TODO: Better logic for this?
                            if ghost.surface.count_entities_filtered {name = 'nano-cloud-small-repair', position = ghost.position} == 0 then
                                ghost.surface.create_entity {
                                    name = 'nano-projectile-repair',
                                    position = player.position,
                                    force = force,
                                    target = ghost.position,
                                    speed = 0.5
                                }
                                ghost.surface.create_entity {
                                    name = 'nano-sound-repair',
                                    position = ghost.position
                                }
                                queue_count(1)
                                ammo_drain(player, nano_ammo, 1)
                            end --repair
                        end --deconstruct, build or repair
                    else
                        break
                    end --queue count
                end --network check
            else
                --ran out of ammo, break out here
                break
            end --valid ammo
        end -- not flag not_on_map
    end --looping through entities
    pdata._next_nano_tick = next_tick() or game.tick
end --function

--Nano Termites
--Kill the trees! Kill them dead
local function everyone_hates_trees(player, pos, nano_ammo)
    local radius = get_ammo_radius(player, nano_ammo)
    local area = Position.expand_to_area(pos, radius)
    for _, stupid_tree in pairs(player.surface.find_entities_filtered {area = area, type = 'tree', limit = 200}) do
        if nano_ammo.valid and nano_ammo.valid_for_read then
            if not stupid_tree.to_be_deconstructed(player.force) then
                local tree_area = Area.expand(stupid_tree.bounding_box, .5)
                if player.surface.count_entities_filtered {area = tree_area, name = 'nano-cloud-small-termites'} == 0 then
                    player.surface.create_entity {
                        name = 'nano-projectile-termites',
                        position = player.position,
                        force = player.force,
                        target = stupid_tree,
                        speed = .5
                    }
                    player.surface.create_entity {
                        name = 'nano-sound-termite',
                        position = stupid_tree.position
                    }
                    ammo_drain(player, nano_ammo, 1)
                end
            end
        else
            break
        end
    end
end

--[[ EVENTS --]]
--The Tick Handler
local function poll_players(event)
    --Run logic for nanobots and power armor modules
    --if event.tick % math.ceil(#game.connected_players/cfg.poll_rate) == 0 then
    if event.tick % max(1, floor(cfg.poll_rate / #game.connected_players)) == 0 then
        local last_player, player = next(game.connected_players, global._last_player)
        --Establish connected, non afk, player character
        if player and is_connected_player_ready(player) then
            if cfg.nanobots_auto and (not cfg.network_limits or nano_network_check(player.character)) then
                local gun, nano_ammo, ammo_name = get_gun_ammo_name(player, 'gun-nano-emitter')
                if gun then
                    if ammo_name == 'ammo-nano-constructors' then
                        queue_ghosts_in_range(player, player.position, nano_ammo)
                    elseif ammo_name == 'ammo-nano-termites' then
                        everyone_hates_trees(player, player.position, nano_ammo)
                    end
                end --Gun and Ammo check
            end
            if cfg.equipment_auto then
                armormods.prepare_chips(player)
            end --Auto Equipment
        end --Player Ready
        global._last_player = last_player
    end --NANO Automatic scripts
end
Event.register(defines.events.on_tick, poll_players)

-- Reset last player when players join or leave
local function players_changed()
    global._last_player = nil
end
Event.register({defines.events.on_player_joined_game, defines.events.on_player_left_game}, players_changed)

local function execute_nano_queue(event)
    queue:execute(event)
end
Event.register(defines.events.on_tick, execute_nano_queue)

local function on_nano_init()
    global.nano_queue = Queue()
    queue = global.nano_queue
    game.print('Nanobots are now ready to serve')
end
Event.register(Event.core_events.init, on_nano_init)

local function on_nano_load()
    queue = Queue(global.nano_queue)
end
Event.register(Event.core_events.load, on_nano_load)

local function reset_nano_queue()
    global.nano_queue = nil
    queue = nil
    global.nano_queue = Queue()
    queue = global.nano_queue
    for _, player in pairs(global.players) do
        player._next_nano_tick = 0
    end
end
Event.register(Event.generate_event_name('reset_nano_queue'), reset_nano_queue)
