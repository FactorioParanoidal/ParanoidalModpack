if not settings.startup["nanobots-auto"].value then return end

require('nanobots-common')

NanobotsAuto = {}

local Event = require('__stdlib2__/stdlib/event/event').set_protected_mode(true)
local Area = require('__stdlib2__/stdlib/area/area')
local Position = require('__stdlib2__/stdlib/area/position')
local table = require('__stdlib2__/stdlib/utils/table')
local Queue = require('scripts/hash_queue')

local max, floor, table_size, table_find = math.max, math.floor, table_size, table.find
--this aliasing seems kinda pointless but w/e

local config = require('config')
local armormods = require('scripts/armor-mods')
local bot_radius = config.BOT_RADIUS
local queue_speed = config.AUTO_SPEED_BONUS
local network_limit = true --keeping this here in case i decide to bring this option back

local function unique(tbl)
    return table.keys(table.invert(tbl))
end
local inv_list = unique {
    defines.inventory.character_trash, defines.inventory.character_main, defines.inventory.god_main, defines.inventory.chest,
    defines.inventory.character_vehicle, defines.inventory.car_trunk, defines.inventory.cargo_wagon
}

-- ----local function forward declarations---- --
local is_connected_player_ready
local player_using_ammo
local nano_network_check
local get_gun_ammo_name

local queue_constructor_targets
local queue_leveler_targets
local queue_valid_targets


-- ----Public functions---- --

NanobotsAuto.process_queue_tasks = function(tick)
    if config.DEBUG then
        game.print("In process_queue_tasks")
    end
    
    for _, player in pairs(game.connected_players) do
        local pdata = storage.players[player.index]
        
        
        
        local queue = pdata.queue
        if not queue then
            queue = Queue()
            pdata.queue = queue
            if config.DEBUG then
                game.print("Created queue")
            end
        end
        
        
        local next_tick = pdata.next_auto_tick
        if not next_tick then
            next_tick = tick
        end
        if next_tick > tick then
            goto continue
        end
        --correct tick for next action
        
        if not queue.active then
            if config.DEBUG then
                game.print("Queue not active")
            end
            
            --attempt refill if player *was* active
            if pdata.active then
                NanobotsAuto.fill_player_queue(player)
                if not queue.active then
                    if not settings.get_player_settings(player)["nanobots-mute-launcher"].value then
                        if pdata.lacking_supplies then
                            player.play_sound({path = "nano-sound-error"})
                        else
                            player.play_sound({path = "nano-sound-complete"})
                        end
                    end
                    pdata.active = false
                end
            end
            
            goto continue
        end
        --queue has tasks
        
        pdata.active = true
        
        if config.DEBUG then
            game.print("Activating! Next_tick: " .. next_tick .. ", tick: " .. tick)
        end
        
        local success = Queue.execute(queue)
        while queue.active and not success do
            success = Queue.execute(queue)
        end
        --do actions until one works or we run out
        
        --TODO: try refill queue, sound effects
        --If not for the "finished!" sound effect, we wouldn't hardly even need the refill
        
        if success then
            local tick_spacing = max(1, config.AUTO_SPEEDS[player.force.get_gun_speed_modifier('nano-ammo') * 4] or config.AUTO_SPEEDS[0])
            pdata.next_auto_tick = tick + tick_spacing
            if config.DEBUG then
                game.print("Tick-spacing: " .. tick_spacing .. ", next_auto_tick: " .. pdata.next_auto_tick)
            end
        end
        
        
        
        pdata.lacking_supplies = false
        --this should probably be passed through fill_player_queue but this is easier
        
        ::continue::
    end
end

NanobotsAuto.fill_player_queue = function(player)
    if not network_limit or nano_network_check(player.character) then
        --Network check
        local gun, nano_ammo, ammo_name = get_gun_ammo_name(player, 'gun-nano-emitter')
        --Gun/ammo check
        if gun then
            if ammo_name == 'ammo-nano-constructors' then
                queue_constructor_targets(player, player.character.position, nano_ammo)
            elseif ammo_name == 'ammo-nano-levelers' then
                queue_leveler_targets(player, player.character.position, nano_ammo)
            end
        end
    end
end

-- ----Events---- --

--Event.register(Event.core_events.init, NanobotsAuto.initialize_queues())
--Event.register(Event.core_events.load, NanobotsAuto.initialize_queues())
--Not sure this needs to happen on both init and load, but it doesn't hurt to be safe

-- ----Local functions---- --

--- Is the player connected, not afk, and have an attached character
--- @param player LuaPlayer
--- @return boolean
is_connected_player_ready = function(player)
    return player.character
end

--- Does a full check on the given player to see if they are currently in a state to use constructor nanobots.
--- If they are, returns the stack of ammo; otherwise, returns nil
--- @param player LuaPlayer
--- @param target_ammo_name string Only the identifying part of the ammo string, e.g. "constructors" for "nano-ammo-constructors"
--- @return LuaItemStack|nil
player_using_ammo = function(player, target_ammo_name)

    if player == nil then
        return nil
    end
    -- Player exists
    
    if not is_connected_player_ready(player) then
        return nil
    end
    --player has a character
    
    if network_limit and not nano_network_check(player.character) then
        return nil
    end
    --player is not in a network, OR network limits are off
    
    local gun, nano_ammo, ammo_name = get_gun_ammo_name(player, 'gun-nano-emitter')
    if gun == nil then 
        return nil
    end
    --player has 
    
    if ammo_name ~= 'ammo-nano-' .. target_ammo_name then
        return nil
    end
    --player using constructor ammo
    
    return nano_ammo
end

local function has_powered_equipment(character, eq_name)
    local grid = character.grid
    if grid then
        eq = grid.find(eq_name)
        return eq and eq.energy > 0
    end
end

--- Is the player character not in a logistic network or has a working nano-interface
--- @param character LuaEntity
--- @param target LuaEntity
--- @return boolean
nano_network_check = function(character, target)
    if has_powered_equipment(character, 'equipment-bot-chip-nanointerface') then
        return true
    else
        local c = character
        local networks = target and target.surface.find_logistic_networks_by_construction_area(c.position, c.force) or
                             c.surface.find_logistic_networks_by_construction_area(c.position, c.force)
        -- Con bots in network
        local pnetwork = c.logistic_cell and c.logistic_cell and c.logistic_cell.mobile and c.logistic_cell.logistic_network
        local has_pbots = c.logistic_cell and c.logistic_cell.construction_radius > 0 and c.logistic_cell.logistic_network and
                              c.logistic_cell.logistic_network.all_construction_robots > 0
        local has_nbots = table.any(networks, function(network)
            return network ~= pnetwork and network.all_construction_robots > 0
        end)
        return not (has_pbots or has_nbots)
    end
end



--- Get the gun, ammo and ammo name for the named gun: will return nil for all returns if there is no ammo for the gun.
--- @param player LuaPlayer
--- @param gun_name string
--- @return LuaItemStack|nil
--- @return LuaItemStack|nil
--- @return string|nil
get_gun_ammo_name = function(player, gun_name)
    local gun_inv = player.character.get_inventory(defines.inventory.character_guns)
    local ammo_inv = player.character.get_inventory(defines.inventory.character_ammo)

    local gun --- @type LuaItemStack
    local ammo --- @type LuaItemStack

    --[[if not NanobotsCommon.settings.auto.require_equipped then
        local index
        gun, index = gun_inv.find_item_stack(gun_name)
        ammo = gun and ammo_inv[index]
    else--]]
    
    local index = player.character.selected_gun_index
    gun, ammo = gun_inv[index], ammo_inv[index]
    
    --end

    if gun and gun.valid_for_read and ammo.valid_for_read then
        return gun, ammo, ammo.name
    end
    return nil, nil, nil
end

--[[Nano Emitter Queue Handler --]]
-- Queued items are handled one at a time, 
-- check validity of all stored objects at this point, They could have become
-- invalidated between the time they were entered into the queue and now.

-- - @class Nanobots.data
-- - @field player_index number
-- - @field entity LuaEntity
-- - @field surface LuaSurface
-- - @field position MapPosition
-- - @field item_stack ItemStackDefinition

--- @param data Nanobots.data
function Queue.constructor(data)
    local entity = data.entity
    local player = game.get_player(data.player_index)
    
    if config.DEBUG then
        game.print("In constructor dequeue")
    end
    
    --perform ALL the checks again
    local ammo = player_using_ammo(player, "constructors")
    if ammo == nil then
        return false
    end
    
    local target_type = NanobotsCommon.get_constructor_target_type(entity, player)
    if target_type ~= data.target_type then
        return false
    end
    
    if config.DEBUG then
        game.print("Dequeued " .. target_type .. " action")
    end
    
    if not is_valid_nanobot_target(entity, target_type, player) then
        --target is not valid for some reason, e.g., non-minable or already being repaired
        return false
    end
    
    local max_distance = get_ammo_radius(player, ammo)
    if Position.distance(entity.position, player.position) > max_distance then
        return false
    end

    if network_limit and (not nano_network_check(player.character, entity)) then
        -- the target or character is in a network
        return false
    end
    
    if not has_supplies_for_nanobot_action(entity, target_type, player) then
        --player doesn't have the supplies necessary
        return false
    end
    
    local success = perform_nanobot_action(entity, target_type, player)
    if success then
        ammo_drain(player, ammo, 1)
        if config.DEBUG then
            game.print("Action succeeded: " .. target_type)
        end
        if target_type == "empty" or target_type == "clear_ground" or target_type == "insert_request" 
                                  or target_type == "removal_request" then
            --these actions repeatedly target the same entity, so should be re-queued to save us polling
            --the region over and over
            data.target_type = NanobotsCommon.get_constructor_target_type(entity, player)
            
            if data.target_type then
                local queue = storage.players[player.index].queue
                Queue.insert(queue, data)
            end
        end
        
        return true
    else
        game.print("Nanobots error: " .. target_type .. " action failed")
        return false
    end
    
end


--- @param data Nanobots.data
function Queue.leveler(data)
    local entity = data.entity
    local player = game.get_player(data.player_index)
    
    if config.DEBUG then
        game.print("In leveler dequeue")
    end
    
    --perform ALL the checks again
    local ammo = player_using_ammo(player, "levelers")
    if ammo == nil then
        return false
    end
    
    if config.DEBUG then
        game.print("Passed player status check")
    end
    
    local target_type = NanobotsCommon.get_leveler_target_type(entity, player)
    if target_type ~= data.target_type then
        return false
    end
    
    if config.DEBUG then
        game.print("Dequeued " .. target_type .. " action")
    end
    
    
    if not is_valid_nanobot_target(entity, target_type, player) then
        --target is not valid for some reason, e.g., non-minable or already being repaired
        return false
    end
    
    if config.DEBUG then
        game.print("Passed validity check")
    end
    
    local max_distance = get_ammo_radius(player, ammo)
    if Position.distance(entity.position, player.position) > max_distance then
        return false
    end
    
    if config.DEBUG then
        game.print("Passed range check")
    end

    if network_limit and (not nano_network_check(player.character, entity)) then
        -- the target or character is in a network
        return false
    end
    
    if config.DEBUG then
        game.print("Passed network check")
    end
    
    if not has_supplies_for_nanobot_action(entity, target_type, player) then
        --player doesn't have the supplies necessary
        return false
    end
    
    local success = perform_nanobot_action(entity, target_type, player)
    if success then
        ammo_drain(player, ammo, 1)
        if config.DEBUG then
            game.print("Action succeeded: " .. target_type)
        end
        return true
    else
        game.print("Nanobots error: " .. target_type .. " action failed")
        return false
    end
    
end

-- Search the area around the player for constructor targets and queue them.
--- @param player LuaPlayer
--- @param pos MapPosition
--- @param nano_ammo LuaItemStack
queue_constructor_targets = function(player, pos, nano_ammo)
    if config.DEBUG then
        game.print("In queue_constructor_targets")
    end
    
    
    local radius = get_ammo_radius(player, nano_ammo)
    local possible_targets = player.surface.find_entities_filtered({position = pos, radius = radius})
    
    queue_valid_targets(possible_targets, NanobotsCommon.get_constructor_target_type, player, "constructor", radius)

end -- function

-- Search the area around the player for leveler targets and queue them.
--- @param player LuaPlayer
--- @param pos MapPosition
--- @param nano_ammo LuaItemStack
queue_leveler_targets = function(player, pos, nano_ammo)
    if config.DEBUG then
        game.print("In queue_leveler_targets")
    end
    
    local radius = get_ammo_radius(player, nano_ammo)
    local surface = player.surface
    
    local possible_targets = surface.find_entities_filtered({position = pos, 
                                                             radius = radius, 
                                                             force = "neutral", 
                                                             limit = config.MAX_QUEUE_SIZE * 1.2})
    
    queue_valid_targets(possible_targets, NanobotsCommon.get_leveler_target_type, player, "leveler", radius)

    possible_targets = surface.find_entities_filtered({position = pos, 
                                                       radius = radius, 
                                                       type = "simple-entity"})
    
    queue_valid_targets(possible_targets, NanobotsCommon.get_leveler_target_type, player, "leveler", radius)
    
    if settings.get_player_settings(player)["nanobots-levelers-place-landfill"].value then
        possible_targets = surface.find_tiles_filtered({position = pos, 
                                                           radius = radius, 
                                                           collision_mask = "water_tile"})
        
        queue_valid_targets(possible_targets, NanobotsCommon.get_leveler_target_type, player, "leveler", radius)
    end
    
    --The structure here does mean trees and cliffs both will ALWAYS be processed before rocks,
    --which is kind of annoying, but whatever.
    
    --Also, all three of those are processed before landfill, but that part seems fine.
    
end


--Given an array of potential targets, places all valid ones (up to MAX_QUEUE_SIZE) into the given player's queue.
--- @param possible_targets LuaEntity[]|LuaTile[]
--- @param target_finder function(LuaEntity|LuaTile, LuaPlayer) -> string
--- @param player LuaPlayer
--- @param ammo_type string The type of ammo, used to determine which function the queue passes into
queue_valid_targets = function(possible_targets, target_finder, player, ammo_type, radius)
    
    local pdata = storage.players[player.index]
    local queue = pdata.queue
    if not queue then
        queue = Queue()
        pdata.queue = queue
        if config.DEBUG then
            game.print("Created queue")
        end
    end
    
    for _, target in pairs(possible_targets) do
        
        local target_type = target_finder(target, player)
        
        if target_type == nil then
            goto continue
        end
        
        if config.DEBUG then
            game.print("Got target type: " .. target_type)
        end
        
        if Position.distance(target.position, player.position) > radius then
            goto continue
            --if we don't do this, different calculations of distance means we're constantly adding out-of-range tasks to the queue
        end
        
        if network_limit and (not nano_network_check(player.character, target)) then
            -- the target is in a network (we shouldn't be here if the character is)
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed network test")
        end
        
        if Queue.count(queue) >= config.MAX_QUEUE_SIZE then
            --not allowed to queue any more tasks
            break
        end
        
        if Queue.get_hash(queue, target) then
            --target already in queue
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed queue tests")
        end
        
        if not is_valid_nanobot_target(target, target_type, player) then
            --target is not valid for some reason, e.g., non-minable or already being repaired
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed validity test")
        end
        
        if not has_supplies_for_nanobot_action(target, target_type, player) then
            --player doesn't have the supplies necessary
            pdata.lacking_supplies = true
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed supply test")
        end
        
        --- @class Nanobots.data
        local data = {
            player_index = player.index,
            entity = target,
            target_type = target_type,
            action = ammo_type
        }
        
        Queue.insert(queue, data)
        if config.DEBUG then
            game.print("Queued action")
        end
        
        ::continue::
    end -- looping through entities
end



