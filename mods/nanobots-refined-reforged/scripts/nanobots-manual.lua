if settings.startup["nanobots-auto"].value then return end

require('nanobots-common')

local config = require('config')

local Position = require('__stdlib2__/stdlib/area/position')

local consecutive_lack_of_targets = 0

-- ----local function declarations---- --
local initial_target_search
local sort_actions_and_activate
local sort_by_proximity


--- @param player LuaPlayer
--- @param target MapPosition
constructor_ammo_fired = function(player, target)
    if config.DEBUG then
        game.print("In constructor_ammo_fired")
    end
    
    local character = player.character
    
    local ammo_inv = character.get_inventory(defines.inventory.character_ammo)
    local ammo = ammo_inv[character.selected_gun_index]
    local radius = get_ammo_radius(player, ammo)
    local player_pos = character.position
    local surface = character.surface
    
    local targets = surface.find_entities_filtered({position = player_pos, radius = radius})
    local possible_actions = initial_target_search(targets, player, NanobotsCommon.get_constructor_target_type)
    
    sort_actions_and_activate(possible_actions, player, ammo, target)
end

--- @param player LuaPlayer
--- @param target MapPosition
leveler_ammo_fired = function(player, target)
    if config.DEBUG then
        game.print("In leveler_ammo_fired")
    end
    
    local character = player.character
    
    local ammo_inv = character.get_inventory(defines.inventory.character_ammo)
    local ammo = ammo_inv[character.selected_gun_index]
    local radius = get_ammo_radius(player, ammo)
    local player_pos = character.position
    local surface = character.surface
    
    
    
    
    local possible_targets = surface.find_entities_filtered({position = player_pos, 
                                                           radius = radius, 
                                                           force = "neutral"})
                                                           
    local possible_actions = initial_target_search(possible_targets, player, NanobotsCommon.get_leveler_target_type)
    
    local possible_rocks = surface.find_entities_filtered({position = player_pos, 
                                                           radius = radius, 
                                                           type = "simple-entity"})
    
    possible_actions = initial_target_search(possible_rocks, player, NanobotsCommon.get_leveler_target_type, possible_actions)
    
    if settings.get_player_settings(player)["nanobots-levelers-place-landfill"].value then
        local possible_water = surface.find_tiles_filtered({position = player_pos, 
                                                            radius = radius, 
                                                            collision_mask = "water_tile"})
                                                            
        possible_actions = initial_target_search(possible_water, player, NanobotsCommon.get_leveler_target_type, possible_actions)
    end
    
    sort_actions_and_activate(possible_actions, player, ammo, target)
end

--- @param possible_targets LuaEntity[]|LuaTile[]
--- @param player LuaPlayer
--- @param target_finder function(LuaEntity|LuaTile, LuaPlayer) -> string
--- @param possible_actions NanobotsAction[]|nil
initial_target_search = function(possible_targets, player, target_finder, possible_actions)
    if config.DEBUG then
        game.print("In initial_target_search")
    end
    
    possible_actions = possible_actions or {}

    for _, entity in pairs(possible_targets) do
        
        local target_type = target_finder(entity, player)
        
        if target_type == nil then
            goto continue
        end
        
        if config.DEBUG then
            game.print("Got target type: " .. target_type)
        end
        
        if not is_valid_nanobot_target(entity, target_type, player) then
            --target is not valid for some reason, e.g., non-minable or already being repaired
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed validity test")
        end
        
        table.insert(possible_actions, { entity = entity,
                                         position = entity.position,
                                         target_type = target_type })
        
        ::continue::
    end
    
    return possible_actions
end

sort_actions_and_activate = function(possible_actions, player, ammo, target)
    if config.DEBUG then
        game.print("In sort_actions_and_activate")
    end

    possible_actions = sort_by_proximity(target, possible_actions, true)
    
    local pdata = storage.players[player.index]
    
    local missing_supplies = false
    local out_of_area_actions = false
    for _, action in pairs(possible_actions) do
        if action.dist > config.MANUAL_RADIUS then
            if config.DEBUG then
                game.print("Exceeded max radius: " .. config.MANUAL_RADIUS)
            end
            out_of_area_actions = true
            break
        end
        
        local entity = action.table.entity
        local target_type = action.table.target_type
        
        if not has_supplies_for_nanobot_action(entity, target_type, player) then
            --player doesn't have the supplies necessary
            missing_supplies = true
            goto continue
        end
        
        if config.DEBUG then
            game.print("Passed supply test")
        end
        
        --all tests passed, let's goooooo
        
        local success = perform_nanobot_action(entity, target_type, player)
        if success then
            ammo_drain(player, ammo, 1)
            pdata.consecutive_lack_of_targets = 0
            if config.DEBUG then
                game.print("Action succeeded: " .. target_type)
            end
            return true
        else
            game.print("Nanobots error: " .. target_type .. " action failed")
            return false
        end
        
        ::continue::
    end
    
    --If we're ending the loop, it's because we didn't find an action to perform
    --We should play the appropriate sound, if not muted
    if not settings.get_player_settings(player)["nanobots-mute-launcher"].value then
        local consecutive_lack_of_targets = pdata.consecutive_lack_of_targets
        if not consecutive_lack_of_targets then
            consecutive_lack_of_targets = 0
        end
        
        if missing_supplies then
            player.play_sound({path = "nano-sound-error"})
            pdata.consecutive_lack_of_targets = 0
        else
            if not out_of_area_actions then
                consecutive_lack_of_targets = consecutive_lack_of_targets + 1
                if consecutive_lack_of_targets == 2 then
                    player.play_sound({path = "nano-sound-complete"})
                end
                pdata.consecutive_lack_of_targets = consecutive_lack_of_targets
            end
            --this is not the BEST solution for it playing too often, but..
            --it's simple and better than it was
            
        end
    end
end

---Sorts an array of tables by proximity to a location
--- @param position MapPosition the location to sort by proximity to
--- @param tables table[] An array of tables, each of which has a position value
--- @param leave_wrapper boolean If true, returns the wrapper array containing the distances as well as the original tables
sort_by_proximity = function(position, tables, leave_wrapper)
    leave_wrapper = leave_wrapper or false
    
    local wrapper_array  = {}
    for _, k in pairs(tables) do
        table.insert(wrapper_array, { dist = Position.manhattan_distance(position, k.position), 
                                      table = k})
    end
    
    local function compare(left, right)
        return left.dist < right.dist
    end
    
    table.sort(wrapper_array, compare)
    
    if leave_wrapper then
        return wrapper_array
    else
        local final_array = {}
        for _, k in pairs(wrapper_array) do
            table.insert(final_array, k.table)
        end
        
        return final_array
    end
end