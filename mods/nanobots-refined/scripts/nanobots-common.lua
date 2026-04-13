

NanobotsCommon = {}

local Event = require('__stdlib2__/stdlib/event/event').set_protected_mode(true)
local Area = require('__stdlib2__/stdlib/area/area')
local Position = require('__stdlib2__/stdlib/area/position')

local moveable_types = { train = true, car = true, spidertron = true } ---@type { [string]: true }
local blockable_types = {['straight-rail'] = true, ['curved-rail'] = true} ---@type { [string]: true }

local config = require('config')
--[[
NanobotsCommon.settings = {}

local function update_settings()
    local setting = settings['global']
    NanobotsCommon.settings = {
        build_tiles = setting['nanobots-nano-build-tiles'].value,
        cliff_limits = setting['nanobots-levelers-only-targeted-cliffs'].value,
        nature_all = setting['nanobots-levelers-destroy-targeted-nature'].value,
        fill_water = setting['nanobots-levelers-place-landfill'].value
    }
end
Event.register(defines.events.on_runtime_mod_setting_changed, update_settings)
update_settings()
--]]

--functions that will be registered elsewhere
--constructor_ammo_fired
--leveler_ammo_fired

--forward declaration of functions, purely for ease of code reading
--*mostly* in the same order they're defined
local nano_repairable_entity
local does_entity_have_contents
local can_player_insert_contents
local are_items_under_ghost
local get_all_items_under_ghost
local are_non_pending_items_under_ghost
local get_quality_placing_items
local get_total_requests

local NanobotActions = {}

local create_nano_returners
local complete_build_action
local complete_deconstruct_action
local complete_upgrade_action
local complete_upgrade_tile_action
local complete_automatic_action

local does_player_have_items
local does_inventory_have_items
local does_player_have_any
local does_inventory_have_any
local can_player_insert
local can_player_insert_any

local remove_any_from_player
local remove_items_from_player
local remove_any_from_inventory
local remove_items_from_inventory
local transfer_requested_from_player

local cheat_empty_inventory
local cheat_remove_all_requests
local cheat_insert_all_requests

local insert_items_to_player
local insert_contents_to_player
local insert_requested_to_player
local insert_or_spill_items

local insert_pending_action
local remove_pending_action
local is_pending

local clone_item_stack
local clone_item_stacks
local make_items_quality

local create_projectile

-- ----Event Listeners---- --

local function script_event_triggered(event)
    if not event.effect_id:match("^nano.*") then
        --not our event
        return
    end
    
    local source = event.source_entity
    local target = event.target_position
    
    if not source then 
        game.print("Nanobots debug: No source entity for event")
        return
    end
    
    local player = source.player
    if not player then
        game.print("Nanobots debug: Source entity for event has no attached player")
        return
    end
    
    if event.effect_id == "nano-constructor" then
        constructor_ammo_fired(player, target)
    elseif event.effect_id == "nano-leveler" then 
        leveler_ammo_fired(player, target)
    elseif event.effect_id == "nano-returners" then
        create_nano_returners(source, target)
    elseif event.effect_id == "nano-build" then
        complete_build_action(player, target)
    elseif event.effect_id == "nano-deconstruct" then
        complete_deconstruct_action(player, target)
    elseif event.effect_id == "nano-upgrade" then
        complete_upgrade_action(player, target)
        elseif event.effect_id == "nano-pave" then
        complete_pave_action(player, target)
    elseif event.effect_id == "nano-auto" then
        complete_automatic_action(player, target)
    end
end
Event.register(defines.events.on_script_trigger_effect, script_event_triggered)

-- ----Public functions---- --

--also functions as an initial check on if it IS a potential constructor target
--- @param entity LuaEntity
--- @param player LuaPlayer
--- @return string|nil
function NanobotsCommon.get_constructor_target_type(entity, player)
    if not entity.valid then
        return nil
    end
  
  
    if entity.to_be_deconstructed() then 
        if entity.type ~= "cliff" then
            if does_entity_have_contents(entity) then
                return "empty"
            else
                return "deconstruct"
            end
        else
            return "explode_cliff"
        end
    end
    
    if entity.force ~= player.force then
        return nil 
    end
    
    if entity.to_be_upgraded() then 
        return "upgrade"
    end
    
    if entity.name == 'entity-ghost' then
        if not are_items_under_ghost(entity) then
            return "build"
        else
            return "clear_ground"
        end
    end
    
    if entity.name == 'tile-ghost' and settings.get_player_settings(player)["nanobots-nano-build-tiles"].value then  
        local surface = entity.surface
        local existing_tile = surface.get_tile(entity.position).prototype
        local proto = entity.ghost_prototype
        
        if existing_tile.mineable_properties.minable and existing_tile.is_foundation == proto.is_foundation then
            return "upgrade_tile"
        else
            return "build_tile"
        end
    end
    
    if nano_repairable_entity(entity) then 
        return "repair"
    end
    
    if entity.name == 'item-request-proxy' then  
        if entity.removal_plan[1] then
            return "removal_request"
        else
            return "insert_request"
        end
    end
    
    return nil
end

--also functions as an initial check on if it IS a potential leveler target
--- @param entity LuaEntity
--- @param player LuaPlayer
--- @return string|nil
function NanobotsCommon.get_leveler_target_type(entity, player)
    if not entity.valid then
        return nil
    end
    
    if entity.object_name == "LuaEntity" then
    
        if entity.type == "tree" then
            return "destroy_tree"
        end
        
        if entity.type == "simple-entity" and entity.prototype.count_as_rock_for_filtered_deconstruction then
            return "destroy_rock"
        end
        
        if entity.type == "cliff" then
            if entity.to_be_deconstructed() or 
                        not settings.get_player_settings(player)["nanobots-levelers-only-targeted-cliffs"].value then
                return "explode_cliff"
            end
        end
    elseif entity.object_name == "LuaTile" then
        --not an entity, actually
        
        if entity.collides_with("water_tile") 
                    and settings.get_player_settings(player)["nanobots-levelers-place-landfill"].value then
            return "fill_water"
        end
        
    end
    
end

--checks for conditions that might make an entity an invalid target for an action
--For example, a deconstruct action on a non-minable entity 
--- @param entity LuaEntity
--- @param action string
--- @param player LuaPlayer
--- @return boolean
function is_valid_nanobot_target(entity, action, player)
    if not (entity and entity.valid) then
        return false
    end
    
    if is_pending(entity.position) then
        return false
    end
    
    if action == "deconstruct" then
        if not entity.minable then
            return false
        end
        return true --other deconstructions should be valid
    end
    
    if action == "explode_cliff" then
        if not (player.force.technologies['nanobots-cliff'].researched or
                player.force.technologies['cliff-explosives'].researched) then
            return false --can't explode a cliff without explosives
        end
        
        local pdata = storage.players[player.index]
        if pdata.cliff_bomb ~= nil and pdata.cliff_bomb.valid then
            --prevent wasting explosives by allowing only one cliff bomb at once
            return false
        end
        return true
    end
    
    if action == "upgrade" then
        local upgrade, upgrade_quality = entity.get_upgrade_target()
        if upgrade then
            if upgrade.name ~= entity.name or entity.quality ~= upgrade_quality then
                return true
            end
            return false --upgrade target is same as current entity?
        end
        return false --upgrade without a target??
    end
    
    if action == "repair" then
        if entity.surface.count_entities_filtered { name = 'nano-cloud-small-repair', position = entity.position } ~= 0 then
            --entity is already being repaired
            return false
        else
            return true
        end
    end
    
    if action == "build" then
        if not entity.surface.can_place_entity { name = entity.ghost_name, 
                                                position = entity.position, 
                                                direction = entity.direction, 
                                                force = entity.force } then
            return false
            --this usually means that the player (or another entity) is standing where the ghost must go
        end
    end
    
    if action == "clear-ground" then
        return are_non_pending_items_under_ghost(entity)
    end
    
    if action == "removal_request" then
        return entity.removal_plan[1] 
               and entity.proxy_target 
               and entity.proxy_target.valid 
               and not entity.proxy_target.to_be_deconstructed()
    end
    
    if action == "insert_request" then
        return entity.insert_plan[1] 
               and entity.proxy_target 
               and entity.proxy_target.valid 
               and not entity.proxy_target.to_be_deconstructed()
    end
    
    if action == "destroy_tree" or action == "destroy_rock" then
        if entity.to_be_deconstructed() and 
                    not settings.get_player_settings(player)["nanobots-levelers-destroy-targeted-nature"].value then
            return false
        end
        --because "deconstruct" implies getting materials back, and levelers *destroy* entities
        
        local cloud_name
        if action == "destroy_tree" then
            cloud_name = 'nano-cloud-small-termites'
        else --action == "destroy_rock"
            cloud_name = 'nano-cloud-small-lithotrophs'
        end
        
        if entity.surface.count_entities_filtered { name = cloud_name, position = entity.position } ~= 0 then
            return false
        else
            return true
        end
    end
    
    --all other types cannot be invalid
    return true
end

--Checks if the player's inventory has the needed supplies for the given action.
--This also checks if the inventory has space for actions which add items.
--- @param entity LuaEntity
--- @param action string
--- @param player LuaPlayer
--- @return boolean
function has_supplies_for_nanobot_action(entity, action, player)
    if player.cheat_mode then
        --in cheat mode nanobots don't require supplies
        return true
    end
    
    if action == "repair" or action == "destroy_tree" or action == "destroy_rock" then
        return true --these actions require no additional material
    end
    
    if action == "explode_cliff" then
        if player.force.technologies['nanobots-cliff'].researched then
            return does_player_have_any(config.USABLE_EXPLOSIVES, player)
        else
            return does_player_have_items({ name = 'cliff-explosives', count = 1 }, player)
        end
    end
    
    if action == "empty" then
        return can_player_insert_contents(entity, player)
    end
    
    if action == "deconstruct" then
        return true
        --TODO: check if player can hold mining results
    end
    
    if action == "upgrade" then
        local prototype, quality = entity.get_upgrade_target()
        return does_player_have_any(get_quality_placing_items(prototype, quality), player)
        --TODO: check if player can hold mining results
    end
    
    if action == "build" or action == "build_tile" or action == "upgrade_tile" then
        local prototype = entity.ghost_prototype
        local quality = entity.quality
        return does_player_have_any(get_quality_placing_items(prototype, quality), player)
    end
    --TODO: combine upgrade with build and/or deconstruct in some way?
    
    if action == "insert_request" then
        local requests = entity.item_requests
        return does_player_have_any(requests, player, true)
    end
    
    if action == "removal_request" then
        local requests = get_total_requests(entity.removal_plan, false, entity.proxy_target)
        return can_player_insert_any(requests, player, true)
    end
    
    if action == "clear_ground" then
        local item_stacks = get_all_items_under_ghost(entity)
        return can_player_insert_any(item_stacks, player)
    end
    
    if action == "fill_water" then
        return does_player_have_items({name = "landfill", count = 1}, player, true)
    end
    
    --there should be no other cases
    game.print("Bad nanobot action type? " .. action)
    return false
end

--Performs the given action to the given entity from the given player
--Assumes the appropriate checks have been already run
--- @param entity LuaEntity
--- @param action string
--- @param player LuaPlayer
--- @return boolean whether an action was successfully performed. True even if the action was only partially completed.
function perform_nanobot_action(entity, action, player)
    if NanobotActions[action] then
        return NanobotActions[action](entity, player)
    end
    
    return false
end

--- Get the radius to use based on tehnology and player defined radius
--- @param player LuaPlayer
--- @param nano_ammo LuaItemStack
function get_ammo_radius(player, nano_ammo)
    local data = storage.players[player.index]
    local modifier = player.force.get_ammo_damage_modifier(nano_ammo.prototype.ammo_category.name)
    local max_radius = config.BOT_RADIUS[modifier] or 7
    local custom_radius = data.ranges[nano_ammo.name] or max_radius
    return custom_radius <= max_radius and custom_radius or max_radius
end

--- Manually drain ammo, if it is the last bit of ammo in the stack pull in more ammo from inventory if available
--- @param player LuaPlayer the player object --- Todo Character?
--- @param ammo LuaItemStack the ammo itemstack
--- @return boolean #Ammo was drained
function ammo_drain(player, ammo, amount)
    if player.cheat_mode then
        return true
    end

    amount = amount or 1
    local name = ammo.name
    ammo.drain_ammo(amount)
    if not ammo.valid_for_read then
        local new = player.get_main_inventory().find_item_stack(name)
        if new then
            ammo.set_stack(new)
            new.clear()
        end
        return true
    end
end

-- ----Local functions---- --

--- Can nanobots repair this entity?
--- @param entity LuaEntity
--- @return boolean
nano_repairable_entity = function(entity)
    if entity.has_flag('not-repairable') or entity.type:find('robot') then
        return false
    end
    if blockable_types[entity.type] and entity.minable == false then
        --TODO: spade, does this REALLY block repairs??
        return false
    end
    if (entity.get_health_ratio() or 1) >= 1 then
        return false
    end
    if moveable_types[entity.type] and entity.speed > 0 then
        return false
    end
    return table_size(entity.prototype.collision_mask) > 0
end

--- Checks to see if the given entity has any item contents
--- @param entity LuaEntity the entity to check for contents
--- @return boolean
does_entity_have_contents = function(entity)
    
    for i = 1, entity.get_max_inventory_index() do
        local inv = entity.get_inventory(i)
        if inv ~= nil then
            if not inv.is_empty() then
                return true
            end
        end
    end
    
    return false
end

--- Scan the ground under a ghost entities collision box for items
--- @param entity LuaEntity the entity object to scan under
--- @return boolean true if there are items, false otherwise
are_items_under_ghost = function(entity)
    local item_stacks = {}
    local surface, position, bounding_box = entity.surface, entity.position, entity.ghost_prototype.selection_box
    local area = Area.offset(bounding_box, position)
    local ground_items = surface.count_entities_filtered({ name = 'item-on-ground', area = area })
    if ground_items ~= 0 then
        return true
    end
    return false
end

--- Scan the ground under a ghost entities collision box for items without pending actions and remove them,
--- returning them as an array of SimpleItemStack.
--- @param entity LuaEntity the entity object to scan under
--- @return ItemStackDefinition[] #array of ItemStackDefinition
get_all_items_under_ghost = function(entity)
    local item_stacks = {}
    local surface, position, bounding_box = entity.surface, entity.position, entity.ghost_prototype.selection_box
    local area = Area.offset(bounding_box, position)
    for _, item_on_ground in pairs(surface.find_entities_filtered { name = 'item-on-ground', area = area }) do
        if not is_pending(item_on_ground.position) then
            table.insert(item_stacks, clone_item_stack(item_on_ground.stack))
        end
    end
    return item_stacks
end

are_non_pending_items_under_ghost = function(entity)
    --we have two options:
    --1. Get the roster of item stacks in the area, then check each for a pending_action (until finding one that isn't)
    --2. Get the *count* of item stacks, then deserialize all pending actions to see if they're in the area, and compare the two counts
    --Now that they're written out, 1 seems *likely* to be much faster, but it really depends on the speed difference between count_entities_filtered and find_entities_filtered. (After all, there shouldn't be THAT many pending actions to deserialize.)
    --...Like, two or three per player, probably. So. Yeah, actually, count is... probably faster?
    --Hard to be sure.
    --Well, option 2 is apparently not accurate. So.
    
    local item_stacks = {}
    local surface, position, bounding_box = entity.surface, entity.position, entity.ghost_prototype.selection_box
    local area = Area.offset(bounding_box, position)
    local ground_items = surface.find_entities_filtered({ name = 'item-on-ground', area = area })
    
    for _, item in pairs(ground_items) do
        if not is_pending(item.position) then
            return true
        end
    end
    
    return false
end

--- Checks to see if the given player can insert ANY of the given entity's contents
--- @param entity LuaEntity
--- @param player LuaPlayer
--- @param boolean at_least_one 
--- @return boolean
can_player_insert_contents = function(entity, player, at_least_one)
    at_least_one = at_least_one or false

    for i = 1, entity.get_max_inventory_index() do
        local inv = entity.get_inventory(i)
        if inv == nil or not inv.valid then
            goto continue
        end
        
        if inv.is_empty() then
            goto continue
        end
        
        --inv is valid
        for i = 1, #inv do
            local stack = inv[i]
            if stack ~= nil and stack.count ~= 0 then
                local test_stack = clone_item_stack(stack)
                test_stack.count = math.min(test_stack.count, 10)
                if can_player_insert(test_stack, player, at_least_one) then
                    return true
                end
            end
        end
        
        ::continue::
    end
    
    return false
end

--- Gets a list of items that can be used to create the given prototype at the given quality
--- @param prototype LuaEntityPrototype
--- @param quality QualityID
--- @return ItemStackDefinition[] the list of items that can create this entity
get_quality_placing_items = function(prototype, quality)
    local base_items = prototype.items_to_place_this
    local cloned = clone_item_stacks(base_items)
    return make_items_quality(cloned, quality)
end

--- Converts an list of insert (or removal) plans into a list of item stacks to be inserted (or removed)
--- @param plans BlueprintInsertPlan[]
--- @param inserting boolean if true, stack sizes are determined by MAX_FILLING_STACK; if false, MAX_EMPTYING_STACK
--- @param entity LuaEntity|nil If given, copies stacks from the entity's inventory instead of building virtual stacks.
--- @return ItemStackDefinition[] the list of items requested
get_total_requests = function(plans, inserting, entity)
    local max_stack
    if inserting then
        max_stack = config.MAX_FILLING_STACK
    else
        max_stack = config.MAX_EMPTYING_STACK
    end
    
    local requests = {}
    for _, plan in pairs(plans) do
        
        if entity then
            for _, stack_pointer in pairs(plan.items.in_inventory) do
                local stack = clone_item_stack(entity.get_inventory(stack_pointer.inventory)[stack_pointer.stack + 1])
                if stack_pointer.count then
                    stack.count = math.min(stack.count, stack_pointer.count, max_stack)
                else
                    stack.count = 1
                end
                table.insert(requests, stack)
            end
            
        else
            local count = 0
            for _, stack in pairs(plan.items.in_inventory) do
                count = count + stack.count
            end
            stack.count = math.min(stack.count, max_stack)
            table.insert(requests, { name = plan.id.name,
                                     quality = plan.id.quality,
                                     count = count })
        end
        
    end
    
    return requests
end

--- Performs the cliff deconstruct action
--- @param entity LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.explode_cliff(entity, player)
    if config.DEBUG then
        game.print("In NA:explode_cliff")
    end
    
    local pdata = storage.players[player.index]
    if pdata.cliff_bomb ~= nil and pdata.cliff_bomb.valid then
        --prevent wasting explosives by allowing only one cliff bomb at once
        return false
    end
    
    if not player.cheat_mode then 
        if player.force.technologies['nanobots-cliff'].researched then
            remove_any_from_player(config.USABLE_EXPLOSIVES, player, false, true)
        else
            remove_items_from_player({ name = 'cliff-explosives', count = 1 }, player, false, true)
        end
    end

    pdata.cliff_bomb = create_projectile('nano-projectile-cliff-bomb', entity.surface, player.character.position, entity.position)
    --the projectile does the actual cliff destroying part
    
    return true
end

--- Performs the build (entity) action
--- @param ghost LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed. True even if the action was only partially completed.
function NanobotActions.build(ghost, player)
    if config.DEBUG then
        game.print("In NA:build")
    end
    
    if are_items_under_ghost(ghost) then
        return false
    end
    
    if not player.surface.can_place_entity { name = ghost.ghost_name, position = ghost.position, direction = ghost.direction, force = ghost.force } then
        return false
    end
    
    local proto = ghost.ghost_prototype
    local quality = ghost.quality --I guess? they didn't make this clear
    
    local placing_item
    if not player.cheat_mode then
        placing_item = remove_any_from_player(get_quality_placing_items(proto, quality), player)
        
        if config.DEBUG then
            game.print("Removed items")
        end
    else
        placing_item = { health = 1 }
    end
    
    local data = { type = "build",
                   player = player,
                   ghost = ghost,
                   item = placing_item }
    
    local success = insert_pending_action(ghost.position, data)
    if success then
        create_projectile('nano-projectile-constructors', ghost.surface, player.character, ghost.position)
        if config.DEBUG then
            game.print("Fired projectile")
        end
        return true
    else
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
        end
        return false
    end
end

--- Performs the upgrade (entity) action
--- @param entity LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed. True even if the action was only partially completed.
function NanobotActions.upgrade(entity, player)
    if config.DEBUG then
        game.print("In NA:upgrade")
    end
    
    local proto, quality = entity.get_upgrade_target()
    
    local placing_item
    if not player.cheat_mode then
        placing_item = remove_any_from_player(get_quality_placing_items(proto, quality), player)
        
        if config.DEBUG then
            game.print("Removed items")
        end
    else
        placing_item = { health = 1 }
    end
    
    local data = { type = "upgrade",
                   player = player,
                   entity = entity,
                   item = placing_item }
    
    local success = insert_pending_action(entity.position, data)
    if success then
        create_projectile('nano-projectile-upgraders', entity.surface, player.character, entity.position)
        if config.DEBUG then
            game.print("Fired projectile")
        end
        return true
    else
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
        end
        if config.DEBUG then
            game.print("Items refunded")
        end
        return false
    end
end

--- Performs the build tile action
--- @param ghost LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed. True even if the action was only partially completed.
function NanobotActions.build_tile(ghost, player)
    if config.DEBUG then
        game.print("In NA:build_tile")
    end
    
    local proto = ghost.ghost_prototype
    local placing_item
    if not player.cheat_mode then
        placing_item = remove_any_from_player(proto.items_to_place_this, player)
        
        if config.DEBUG then
            game.print("Removed items")
        end
    end
    
    local data = { type = "build_tile",
                   player = player,
                   ghost = ghost,
                   item = placing_item }
    
    local success = insert_pending_action(ghost.position, data)
    if success then
        create_projectile('nano-projectile-constructors', ghost.surface, player.character, ghost.position)
        if config.DEBUG then
            game.print("Fired projectile")
        end
        return true
    else
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
        end
        return false
    end
end

--- Performs the upgrade tile action
--- @param ghost LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed. True even if the action was only partially completed.
function NanobotActions.upgrade_tile(ghost, player)
    if config.DEBUG then
        game.print("In NA:upgrade_tile")
    end
    
    local proto = ghost.ghost_prototype
    local placing_item
    if not player.cheat_mode then
        placing_item = remove_any_from_player(proto.items_to_place_this, player)
        
        if config.DEBUG then
            game.print("Removed items")
        end
    end
    
    local data = { type = "upgrade_tile",
                   player = player,
                   ghost = ghost,
                   item = placing_item }
    
    local success = insert_pending_action(ghost.position, data)
    if success then
        create_projectile('nano-projectile-upgraders', ghost.surface, player.character, ghost.position)
        if config.DEBUG then
            game.print("Fired projectile")
        end
        return true
    else
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
        end
        return false
    end
end

--- Performs the empty (inventory before deconstruction) action
--- @param entity LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.empty(entity, player)
    if config.DEBUG then
        game.print("In NA:empty")
    end
    
    if not player.cheat_mode then
        local success = insert_contents_to_player(entity, player, true)
        if not success then
            return false
        end
    else
        cheat_empty_inventory(entity)
    end
    
    create_projectile('nano-projectile-emptyers', entity.surface, player.character, entity.position)
    return true
end

--- Performs the deconstruct (non-cliff entity or tile) action
--- @param entity LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.deconstruct(entity, player)
    if config.DEBUG then
        game.print("In NA:deconstruct")
    end
    
    if not entity.minable then
        return false
    end
    
    if config.DEBUG then
        game.print("Entity is minable")
    end
    
    local data = { type = "deconstruct",
                   entity = entity,
                   player = player }
                   
    insert_pending_action(entity.position, data)
    
    create_projectile('nano-projectile-deconstructors', entity.surface, player.character, entity.position)
    return true
end

--- Performs the clear ground (below ghost before building) action
--- @param entity LuaEntity the ghost to clear under
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.clear_ground(ghost, player)
    if config.DEBUG then
        game.print("In NA:clear_ground")
    end
    
    local surface, position, bounding_box = ghost.surface, ghost.position, ghost.ghost_prototype.selection_box
    local area = Area.offset(bounding_box, position)
    local target_item = nil
    for _, item_on_ground in pairs(surface.find_entities_filtered { name = 'item-on-ground', area = area }) do
        local stack = clone_item_stack(item_on_ground.stack)
        if can_player_insert(stack, player) then
            if is_valid_nanobot_target(item_on_ground, "clear", player) then
                --this is mostly to check for if there's already a projectile targeting this item
                target_item = item_on_ground
                break
            end
        end
    end
    
    if not target_item then
        game.print("Nanobots error: No clearable stacks found by clear_ground action!")
        return false
    end
    
    if not target_item.valid then
        game.print("Nanobots error: Target item to clear from ground invalid!")
        return false
    end
    
    if not target_item.minable then
        game.print("Nanobots error: Target item to clear from ground not minable!")
        return false
    end
    
    if config.DEBUG then
        game.print("Found minable stack")
    end
    
    local data = { type = "deconstruct",
                   entity = target_item,
                   player = player }
    
    --the deconstruct algorithm should be able to handle it from here
    insert_pending_action(target_item.position, data)
    
    create_projectile('nano-projectile-deconstructors', surface, player.character, target_item.position)
    return true
end

--- Performs the repair action
--- @param entity LuaEntity the target
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.repair(entity, player)
    if config.DEBUG then
        game.print("In NA:repair")
    end
    
    local data = { type = "repair" }
    
    insert_pending_action(entity.position, data)

    create_projectile('nano-projectile-repair', entity.surface, player.character, entity.position)
    --the projectile does the repairs
    --...Wow, this one is dead simple.
    
    return true
end

--- Performs the removal request action
--- @param request_proxy LuaEntity the targeted proxy
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.removal_request(request_proxy, player)
    if config.DEBUG then
        game.print("In NA:removal_request")
    end
    
    local entity = request_proxy.proxy_target
    local plans = request_proxy.removal_plan
    
    if not player.cheat_mode then
        local success, plans = insert_requested_to_player(entity, plans, player, true)
        if not success then
            return false
        end
        request_proxy.removal_plan = plans
    else
        cheat_remove_all_requests(entity, plans)
        request_proxy.removal_plan = nil
    end
    
    create_projectile('nano-projectile-emptyers', entity.surface, player.character, entity.position)
    return true
end

--- Performs the insertion request action
--- @param request_proxy LuaEntity the targeted proxy
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.insert_request(request_proxy, player)
    if config.DEBUG then
        game.print("In NA:insert_request")
    end
    
    local entity = request_proxy.proxy_target
    
    
    --[[
    local requests = request_proxy.item_requests
    for _, request in pairs(requests) do
        request.count = math.min(request.count, config.MAX_FILLING_STACK)
    end
    
    local removed = remove_any_from_player(requests, player, true)
    request_proxy.insert(removed) --this may not work, in which case we'll have to more closely mirror removal_request
    --nope, doesn't work at all
    --]]
    
    local plans = request_proxy.insert_plan
    
    
    if not player.cheat_mode then
        local success, plans = transfer_requested_from_player(entity, plans, player, true)
        if not success then
            return false
        end
        request_proxy.insert_plan = plans
    else
        cheat_insert_all_requests(entity, plans)
        request_proxy.insert_plan = nil
    end
    
    create_projectile('nano-projectile-fillers', entity.surface, player.character, entity.position)
    return true
end

--- Performs the destroy tree action
--- @param tree LuaEntity the targeted tree
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.destroy_tree(tree, player)
    if config.DEBUG then
        game.print("In NA:destroy_tree")
    end
    
    local data = { type = "destroy_tree" }
    
    insert_pending_action(tree.position, data)

    create_projectile('nano-projectile-termites', tree.surface, player.character, tree.position)
    
    return true
end

--- Performs the destroy rock action
--- @param rock LuaEntity the targeted rock
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.destroy_rock(rock, player)
    if config.DEBUG then
        game.print("In NA:destroy_rock")
    end
    
    local data = { type = "destroy_rock" }
    
    insert_pending_action(rock.position, data)

    create_projectile('nano-projectile-lithotrophs', rock.surface, player.character, rock.position)
    
    return true
end

--- Performs the destroy rock action
--- @param tile LuaTile the targeted water tile
--- @param player LuaPlayer the player to perform the action
--- @return boolean whether an action was successfully performed.
function NanobotActions.fill_water(tile, player)
    if config.DEBUG then
        game.print("In NA:fill_water")
    end
    
    local placing_item
    if not player.cheat_mode then 
        placing_item = remove_any_from_player({{ name = 'landfill', count = 1 }}, player, false)
        if config.DEBUG then
            game.print("Removed items")
        end
    end
    
    local data = { type = "pave",
                   player = player,
                   tile = tile,
                   item = placing_item }
    
    local success = insert_pending_action(tile.position, data)
    if success then
        create_projectile('nano-projectile-pavers', tile.surface, player.character, tile.position)
        if config.DEBUG then
            game.print("Fired projectile")
        end
        return true
    else
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
        end
        return false
    end
end

--- @param entity LuaEntity the entity to return to (presumably a character)
--- @param position MapPosition the position to return from
create_nano_returners = function(entity, position)
    if config.DEBUG then
        game.print("In create_nano_returners")
    end
    create_projectile('nano-projectile-return', entity.surface, position, entity, nil, 0.3)
    if config.DEBUG then
        game.print("Created returner")
    end
end

--- @param player LuaPlayer the player that is building
--- @param target MapPosition the position of the entity to build
complete_build_action = function(player, target)
    if config.DEBUG then
        game.print("In complete_build_action")
    end
    
    local data = remove_pending_action(target)
    if not data then
        game.print("Nanobots error: Pending action was not found for build!")
        return false
    end
    
    if not (data.type == "build" or data.type == "build_tile") then
        game.print("Nanobots error: Pending action for build projectile was not build!")
        return false
    end
    
    if data.player ~= player then
        game.print("Nanobots error: Pending build action registered to different player!")
        return false
    end
    
    local ghost = data.ghost
    if not is_valid_nanobot_target(ghost) then
        if config.DEBUG then
            game.print("Build target no longer valid")
        end
        --refund reserved item
        if not player.cheat_mode then
            player.insert(data.item)
        end
    
        return false
    end
    
    local tile_mode = ghost.name == "tile-ghost"
    
    local revived, entity = ghost.revive { raise_revive = true }

    if not revived then
        if config.DEBUG then
            game.print("Revive failed")
        end
        --refund reserved item
        if not player.cheat_mode then
            player.insert(data.item)
        end
        
        return
    end
    
    if config.DEBUG then
        game.print("Revived ghost")
    end

    if not tile_mode then
        if not entity then
            game.print("Nanobots error: Successful revive resulted in no entity?")
            return
        end
        
        if entity.health > 0 then 
            entity.health = (data.item.health or 1) * entity.max_health
        end
    end
end

--- @param player LuaPlayer the player that is deconstructing
--- @param target MapPosition the position of the entity to deconstruct
complete_deconstruct_action = function(player, target)
    if config.DEBUG then
        game.print("In complete_deconstruct_action")
    end
    
    local data = remove_pending_action(target)
    if not data then
        game.print("Nanobots error: Pending action was not found for deconstruct!")
        return false
    end
    
    if data.type ~= "deconstruct" then
        game.print("Nanobots error: Pending action for deconstruct projectile was not deconstruct!")
        return false
    end
    
    if data.player ~= player then
        game.print("Nanobots error: Pending deconstruct action registered to different player!")
        return false
    end
    
    local entity = data.entity
    
    if not is_valid_nanobot_target(entity) then
        if config.DEBUG then
            game.print("Deconstruct target no longer valid")
        end
        
        return false
    end
    
    if entity.name == 'deconstructible-tile-proxy' then
        local tile = player.surface.get_tile(target)
        if tile then
            player.mine_tile(tile)
            entity.destroy()
        end
    else
        player.mine_entity(entity)
    end
    
    if config.DEBUG then
        game.print("Deconstructed successfully")
    end
end

--- @param player LuaPlayer the player that is building
--- @param target MapPosition the position of the entity to build
complete_upgrade_action = function(player, target)
    if config.DEBUG then
        game.print("In complete_upgrade_action")
    end
    
    local data = remove_pending_action(target)
    if not data then
        game.print("Nanobots error: Pending action was not found for upgrade!")
        return false
    end
    
    if data.player ~= player then
        game.print("Nanobots error: Pending upgrade action registered to different player!")
        return false
    end
    
    if data.type == "upgrade_tile" then
        complete_upgrade_tile_action(player, target, data)
        return
    end
    
    if data.type ~= "upgrade" then
        game.print("Nanobots error: Pending action for upgrade projectile was not upgrade!")
        return false
    end
    
    local entity = data.entity
    if not is_valid_nanobot_target(entity) then
        if config.DEBUG then
            game.print("Upgrade target no longer valid")
        end
        --refund reserved item
        if not player.cheat_mode then
            player.insert(data.item)
        end
    
        return false
    end
    
    
    local surface = entity.surface
    local prototype, quality = entity.get_upgrade_target()
    local belt_type = entity.type == 'underground-belt' and entity.belt_to_ground_type or nil
    
    if config.DEBUG then
        game.print("Attempting create entity")
    end
    
    local upgrade = surface.create_entity({
        name = prototype.name,
        position = target,
        direction = entity.direction,
        quality = quality,
        force = player.force,
        fast_replace = true,
        player = player,
        raise_built = true,
        spill = true,
        move_stuck_players = true,
        type = belt_type
    })
    
    if config.DEBUG then
        game.print("Create entity passed")
    end

    if not upgrade then
        if config.DEBUG then
            game.print("Upgrade (create_entity) failed")
        end
        --refund reserved item
        if not player.cheat_mode then
            insert_or_spill_items(player.character, placing_item)
            player.insert(data.item)
        end
        
        return
    end
    
    --because we're building by script, it doesn't automatically show build effects
    surface.play_sound { path = "entity-build/" .. upgrade.prototype.name, position = upgrade.position }
    upgrade.create_build_effect_smoke()
    
    if upgrade.health > 0 then 
        upgrade.health = (data.item.health or 1) * upgrade.max_health
    end
    
    if config.DEBUG then
        game.print("Upgrade successful")
    end

end

--- @param player LuaPlayer the player that is building
--- @param target MapPosition the position of the entity to build
complete_upgrade_tile_action = function(player, target, data)
    if config.DEBUG then
        game.print("In complete_upgrade_tile_action")
    end
    
    if not (data.type == "upgrade_tile") then
        game.print("Nanobots error: In upgrade tile method but action is not upgrade tile!")
        return false
    end
    
    local ghost = data.ghost
    if not is_valid_nanobot_target(ghost) then
        if config.DEBUG then
            game.print("Build target no longer valid")
        end
        --refund reserved item
        if not player.cheat_mode then
            player.insert(data.item)
        end
    
        return false
    end
    
    local surface = ghost.surface
    local existing_tile = surface.get_tile(target)
    local target_tile = {name = ghost.ghost_name, position = target}
    local tile_was_mined = player.mine_tile(existing_tile)

    if not tile_was_mined then
        if config.DEBUG then
            game.print("Mining old tile failed")
        end
        --refund reserved item
        if not player.cheat_mode then
            player.insert(data.item)
        end
        
        return
    end
    
    if config.DEBUG then
        game.print("Mined old tile")
    end

    surface.set_tiles({target_tile}, true, true, true, true)
    
    --because we're building by script, it doesn't automatically show build effects
    surface.play_sound { path = "tile-build-small/" .. target_tile.name, position = target }
    
end

--- @param player LuaPlayer the player that is building
--- @param target MapPosition the position of the tile to pave
complete_pave_action = function(player, target)
    if config.DEBUG then
        game.print("In complete_pave_action")
    end
    
    local data = remove_pending_action(target)
    if not data then
        game.print("Nanobots error: Pending action was not found for pave!")
        return false
    end
    
    if not (data.type == "pave") then
        game.print("Nanobots error: Pending action for pave projectile was not pave!")
        return false
    end
    
    if data.player ~= player then
        game.print("Nanobots error: Pending pave action registered to different player!")
        return false
    end
    
    local surface = data.tile.surface
    local existing_tile = surface.get_tile(target)
    local tile_name = data.item.name --this is a BAD PLAN but it might work anyway
    if config.DEBUG then
        game.print("Tile name: " .. tile_name)
    end
    local target_tile = {name = tile_name, position = target}

    surface.set_tiles({target_tile}, true, true, true, true)
end

--- Removes an action from pending_actions without any other effect.
--- Useful for actions which are completed by the projectile itself, such as repair and destroy_tree.
--- @param player LuaPlayer the player that is repairing
--- @param target MapPosition the position of the entity to repair
complete_automatic_action = function(player, target)
    if config.DEBUG then
        game.print("In complete_automatic_action")
    end
    
    local data = remove_pending_action(target)
    if not data then
        game.print("Nanobots error: Pending automatic action was not found!")
        return false
    end
    
    if data.type ~= "repair" and data.type ~= "destroy_tree" and data.type ~= "destroy_rock" then
        game.print("Nanobots error: Pending automatic action not of an automatic type!")
        return false
    end
end

--- Checks the given inventory for the given stack
--- @param item_stack ItemStackDefinition ; the items to look for
--- @param inventory LuaInventory
--- @param at_least_one boolean ; if true, treats searching stack size as 1. Default false.
--- @return boolean
does_inventory_have_items = function(item_stack, inventory, at_least_one)
    at_least_one = at_least_one or false

    local count = inventory.get_item_count({name = item_stack.name, quality = item_stack.quality})
    if count >= item_stack.count or (count >= 1 and at_least_one) then
        return true
    end
    return false
end

--TODO: determine if "player has" functions should check the currently held stack
--(leaning no, but may change my mind in play)
--- Checks the given player's inventory for the given stack
--- @param item_stack ItemStackDefinition the items to look for
--- @param player LuaPlayer
--- @param at_least_one boolean; if true, treats searching stack size as 1. Default false.
--- @return boolean
does_player_have_items = function(item_stack, player, at_least_one)
    at_least_one = at_least_one or false
    
    local inv = player.get_main_inventory()
    if inv == nil then
        return false
    else
        return does_inventory_have_items(item_stack, inv, at_least_one)
    end
end

--- Checks the given inventory for any of the given stacks
--- @param item_stacks ItemStackDefinition[] the items to look for
--- @param inventory LuaInventory
--- @param at_least_one boolean; if true, treats searching stack sizes as 1. Default false.
--- @return boolean
does_inventory_have_any = function(item_stacks, inventory, at_least_one)
    at_least_one = at_least_one or false
    
    for _, stack in pairs(item_stacks) do
        if does_inventory_have_items(stack, inventory, at_least_one) then
            return true
        end
    end

    return false
end

--- Checks the given player's inventory for any of the given stacks
--- @param item_stacks ItemStackDefinition[] the items to look for
--- @param player LuaPlayer
--- @param at_least_one boolean; if true, treats searching stack sizes as 1. Default false.
--- @return boolean
does_player_have_any = function(item_stacks, player, at_least_one)
    at_least_one = at_least_one or false
    
    local inv = player.get_main_inventory()
    if inv == nil then
        return false
    else
        return does_inventory_have_any(item_stacks, inv, at_least_one)
    end
end

--- Checks if the given player's inventory can insert the given stack
--- @param item_stack ItemStackDefinition the items to check for insertion
--- @param player LuaPlayer
--- @param at_least_one boolean if true, will return true if at least one item can be inserted.
--- @return boolean
can_player_insert = function(item_stack, player, at_least_one)
    at_least_one = at_least_one or false

    local inv = player.get_main_inventory()
    if inv == nil then
        return false
    else
        if at_least_one then
            return inv.can_insert(item_stack)
        else
            return inv.get_insertable_count(item_stack) >= item_stack.count
        end
    end
end

--- Checks if the given player's inventory can insert at least one given stack
--- @param item_stacks ItemStackDefinition[] the items to check for insertion
--- @param player LuaPlayer
--- @param at_least_one boolean if true, will return true if at least one item can be inserted.
--- @return boolean
can_player_insert_any = function(item_stacks, player, at_least_one)
    at_least_one = at_least_one or false

    for _, stack in pairs(item_stacks) do
        if can_player_insert(stack, player, at_least_one) then
            return true
        end
    end
    
    return false
end

--- Removes the first of the given stacks that are in the player's inventory, from that inventory.
--- @param item_stacks ItemStackDefinition[] the items to look for
--- @param player LuaPlayer
--- @param at_least_one boolean; if true, will remove a partial stack. Default false.
--- @return SimpleItemStack the items actually removed
remove_any_from_player = function(item_stacks, player, at_least_one)
    at_least_one = at_least_one or false
    
    local inv = player.get_main_inventory()
    if inv == nil then
        return nil
    else
        return remove_any_from_inventory(item_stacks, inv, at_least_one)
    end
end

--- Removes the first of the given stacks that are in the player's inventory, from that inventory.
--- @param item_stacks ItemStackDefinition[] the items to look for
--- @param inventory LuaInventory
--- @param at_least_one boolean; if true, will match to a partial stack. Default false.
--- @return SimpleItemStack the items actually removed
remove_any_from_inventory = function(item_stacks, inventory, at_least_one)
    at_least_one = at_least_one or false

    for _, stack in pairs(item_stacks) do
        if does_inventory_have_items(stack, inventory, at_least_one) then
            local removed = clone_item_stack(stack)
            removed.count = remove_items_from_inventory(stack, inventory, at_least_one)
            return removed
        end
    end

    return nil
end

--- Removes the given stack from the given inventory
--- @param requested_stack ItemStackDefinition ; the items to look for
--- @param inventory LuaInventory
--- @return uint the number of items actually removed
remove_items_from_inventory = function(requested_stack, inventory, at_least_one)
    at_least_one = at_least_one or false

    local specification = {name = requested_stack.name, quality = requested_stack.quality}
    local count = inventory.get_item_count(specification)
    if count >= requested_stack.count or (count >= 1 and at_least_one) then
        return inventory.remove(requested_stack)
    end
    return nil
end

--- Transfers the FIRST stack possible (up to config.MAX_FILLING_STACK) in the removal plan from the player to the given entity
--- @param entity LuaEntity
--- @param BlueprintInsertPlan[] plans
--- @param player LuaPlayer
--- @param boolean at_least_one 
--- @return boolean if any items were transferred
--- @return BlueprintInsertPlan[]|nil the plans that remain after the action
transfer_requested_from_player = function(entity, plans, player, at_least_one)
    at_least_one = at_least_one or false
    
    for i = 1, #plans do
        local plan = plans[i]
        
        for j = 1, #plan.items.in_inventory do
            local stack_pointer = plan.items.in_inventory[j]
            
            local original_stack = entity.get_inventory(stack_pointer.inventory)[stack_pointer.stack + 1]
            local working_stack
            if original_stack ~= nil and original_stack.valid and original_stack.valid_for_read then
                working_stack = clone_item_stack(original_stack)
            else
                working_stack = { name = plan.id.name,
                                  quality = plan.id.quality,
                                  count = 0 }
            end
            --can't figure how to reliably get stack size, so we just have to hope there's no issues with that
            local count
            if stack_pointer.count then
                count = math.min(stack_pointer.count, 
                                 config.MAX_FILLING_STACK)
            else
                count = 1
            end
            
            working_stack.count = count
            if does_player_have_items(working_stack, player, at_least_one) then
                local player_stack = player.get_main_inventory().find_item_stack({name = working_stack.name, quality = working_stack.quality})
                local orig_player_stack_count = player_stack.count
                
                local transferred = original_stack.transfer_stack(player_stack, count)
                if not transferred then
                    if orig_player_stack_count == player_stack.count then
                        --none were transferred
                        game.print("Nanobots error: Could not transfer any items of matching stacks!")
                        return false, plans
                    end
                    --some were transferred, so we can still work with this
                end
                
                --find the amount actually transferred
                count = orig_player_stack_count - player_stack.count
                if count < 0 then
                    game.print("Nanobots error: Transferred a negative amount of items?")
                    return false, plans
                end
                
                --we've successfully transferred, now for bookkeeping
                if stack_pointer.count then
                    stack_pointer.count = stack_pointer.count - count
                else
                    stack_pointer.count = 0
                end
                
                if stack_pointer.count == 0 then
                    table.remove(plan.items.in_inventory, j)
                    if #plan.items.in_inventory == 0 then
                        table.remove(plans, i)
                    end
                end
                    
                return true, plans
            end
        end
    end

    return false, plans
end

--- Removes the given stack from the given player's inventory
--- @param item_stack ItemStackDefinition the items to look for
--- @param player LuaPlayer
--- @return uint the number of items actually removed
remove_items_from_player = function(item_stack, player, at_least_one)
    at_least_one = at_least_one or false
    
    local inv = player.get_main_inventory()
    if inv == nil then
        return false
    else
        return remove_items_from_inventory(item_stack, inv, at_least_one)
    end
end

--- Empties all inventories of the given entity without sending the items anywhere.
--- @param entity LuaEntity the entity to empty
cheat_empty_inventory = function(entity)

    for i = 1, entity.get_max_inventory_index() do
        local inv = entity.get_inventory(i)
        if inv == nil or not inv.valid then
            goto continue
        end
        
        if inv.is_empty() then
            goto continue
        end
        
        --inv is valid and has contents
        inv.clear()
        
        ::continue::
    end
    
end

--- Removes all requested items from the given entity without sending them anywhere.
--- @param entity LuaEntity the entity to empty
cheat_remove_all_requests = function(entity, plans)

    for _, plan in pairs(plans) do
        for _, stack_pointer in pairs(plan.items.in_inventory) do
            local stack = entity.get_inventory(stack_pointer.inventory)[stack_pointer.stack + 1]
            
            local remove_count
            if stack_pointer.count then
                remove_count = math.min(stack.count, 
                                        stack_pointer.count)
            else
                remove_count = 1
            end
            
            stack.count = stack.count - remove_count
        end
    end
end

--- Creates all requested items in the given entity with no cost.
--- @param entity LuaEntity the entity to empty
cheat_insert_all_requests = function(entity, plans)

    for _, plan in pairs(plans) do
        for _, stack_pointer in pairs(plan.items.in_inventory) do
            local stack = entity.get_inventory(stack_pointer.inventory)[stack_pointer.stack + 1]
            if (not stack.valid_for_read) or stack.count == 0 then
                
                local count
                if stack_pointer.count then
                    count = stack_pointer.count
                else
                    count = 1
                end
                
                local new_stack = {name = plan.id.name,
                                   quality = plan.id.quality,
                                   count = count}
                
                if stack.can_set_stack(new_stack) then
                    set_stack(new_stack)
                else
                    --...we have no recourse currently
                    game.print("Nanobots error! Set stack in cheat_insert_all_requests failed!")
                end
            else
                --we assume they're the correct item, or there'd be a removal request as well (which takes priority)
                --we also assume we HAVE a count
                stack.count = stack.count + stack_pointer.count
            end
        end
    end
end

--- Inserts the given stack to the player's main inventory
--- @param stack ItemStackIdentification
--- @param player LuaPlayer
--- @return uint the number of items actually inserted
insert_items_to_player = function(stack, player)
    at_least_one = at_least_one or false
    
    local inv = player.get_main_inventory()
    if inv == nil then
        return 0
    else
        return inv.insert(stack)
    end
end

--- Transfers the FIRST stack possible (up to config.MAX_EMPTYING_STACK) from the given entity's inventories to the player
--- @param entity LuaEntity
--- @param player LuaPlayer
--- @param boolean at_least_one 
--- @return boolean if any items were transferred
insert_contents_to_player = function(entity, player, at_least_one)
    at_least_one = at_least_one or false

    for i = 1, entity.get_max_inventory_index() do
        local inv = entity.get_inventory(i)
        if inv == nil or not inv.valid then
            goto continue
        end
        
        if inv.is_empty() then
            goto continue
        end
        
        --inv is valid
        for j = 1, #inv do
            local stack = inv[j]
            if stack ~= nil and stack.count ~= 0 then
                local test_stack = clone_item_stack(stack)
                test_stack.count = math.min(test_stack.count, config.MAX_EMPTYING_STACK)
                if can_player_insert(test_stack, player, at_least_one) then
                    test_stack.count = insert_items_to_player(test_stack, player)
                    if test_stack.count ~= 0 then
                        local count = inv.remove(test_stack)
                        if count ~= test_stack.count then
                            game.print("Nanobots error: Could not remove all items inserted!")
                            test_stack.count = count
                            remove_items_from_player(test_stack, player)
                        end
                        return true
                    else
                        return false
                    end
                end
            end
        end
        
        ::continue::
    end
    
    return false
end

--- Transfers the FIRST stack possible (up to config.MAX_EMPTYING_STACK) in the removal plan from the given entity to the player
--- @param entity LuaEntity
--- @param BlueprintInsertPlan[] plans
--- @param player LuaPlayer
--- @param boolean at_least_one 
--- @return boolean if any items were transferred
--- @return BlueprintInsertPlan[]|nil the plans that remain after the action
insert_requested_to_player = function(entity, plans, player, at_least_one)
    at_least_one = at_least_one or false
    
    for i = 1, #plans do
        local plan = plans[i]
        
        for j = 1, #plan.items.in_inventory do
            local stack_pointer = plan.items.in_inventory[j]
            
            local original_stack = entity.get_inventory(stack_pointer.inventory)[stack_pointer.stack + 1]
            
            local working_stack = clone_item_stack(original_stack)
            if stack_pointer.count then
                working_stack.count = math.min(working_stack.count, 
                                               stack_pointer.count, 
                                               config.MAX_EMPTYING_STACK)
            else
                working_stack.count = 1
            end
            
            if can_player_insert(working_stack, player, at_least_one) then
                working_stack.count = insert_items_to_player(working_stack, player)
                if working_stack.count ~= 0 then
                    
                    original_stack.count = original_stack.count - working_stack.count
                    if stack_pointer.count then
                        stack_pointer.count = stack_pointer.count - working_stack.count
                    else
                        stack_pointer.count = 0
                    end
                    
                    if original_stack.count < 0 then
                        --this is logically impossible, but who the fuck knows
                        game.print("Nanobots error: Removed more items than present!")
                        return false, plans
                    end 
                    
                    if stack_pointer.count == 0 then
                        table.remove(plan.items.in_inventory, j)
                        if #plan.items.in_inventory == 0 then
                            table.remove(plans, i)
                        end
                    end
                    
                    return true, plans
                end
            end
        end
    end

    return false, plans
end

--- Attempt to insert an ItemStackDefinition or array of ItemStackDefinition into the entity
--- Spill to the ground at the entity anything that doesn't get inserted
--- @param entity LuaEntity
--- @param item_stacks ItemStackDefinition|ItemStackDefinition[]
--- @return boolean #there was some items inserted or spilled
insert_or_spill_items = function(entity, item_stacks)
    local new_stacks = {}
    if item_stacks then
        if item_stacks[1] and item_stacks[1].name then
            new_stacks = item_stacks
        elseif item_stacks and item_stacks.name then
            new_stacks = { item_stacks }
        end
        for _, stack in pairs(new_stacks) do
            local name, count, health = stack.name, stack.count, stack.health or 1
            if prototypes.item[name] and not prototypes.item[name].hidden then
                local inserted = entity.insert({ name = name, count = count, health = health })
                if inserted ~= count then
                    entity.surface.spill_item_stack(entity.position, { name = name, count = count - inserted, health = health }, true)
                end
            end
        end
        return new_stacks[1] and new_stacks[1].name and true
    end
end

--- @param position MapPosition the location of the action. Only one action at each position can be pending (across all players).
--- @param data table The data needed to perform the action.
--- @return boolean whether the action was successfully inserted.
insert_pending_action = function(position, data)
    if not storage.pending_actions then
        storage.pending_actions = {}
    end
    
    local serialized = Position.to_key(position)
    if storage.pending_actions[serialized] then
        return false
    end
    
    storage.pending_actions[serialized] = data
    return true
end

--- @param position MapPosition the location of the action. Only one action at each position can be pending.
--- @return table|nil The data needed to perform the action, or nil if it was not found.
remove_pending_action = function(position)
    if not storage.pending_actions then
        return nil
    end
    
    local serialized = Position.to_key(position)
    
    local data = storage.pending_actions[serialized]
    if not data then
        return nil
    end
    
    storage.pending_actions[serialized] = nil
    return data
end

--- @param position MapPosition the location of the action. Only one action at each position can be pending.
--- @return boolean Whether an action is pending at this location.
is_pending = function(position)
    if not storage.pending_actions then
        return false
    end
    
    local serialized = Position.to_key(position)
    return storage.pending_actions[serialized] and true or false
    --a totally sane statement that isn't confusing at all
end

-- Copies a given item stack to an ItemStackDefinition for non-referential use.
--- @param item_stack ItemStackIdentification the stack to copy from
--- @return ItemStackDefinition
clone_item_stack = function(item_stack)
    local cloned_stack =  { name = item_stack.name,
                            count = item_stack.count,
                            quality = item_stack.quality,
                            health = item_stack.health,
                            spoil_percent = item_stack.spoil_percent or nil }
                    
    if item_stack.is_tool then
        cloned_stack.durability = item_stack.durability
        cloned_stack.is_tool = true
    end
    
    if item_stack.is_ammo then
        cloned_stack.ammo = item_stack.ammo
        cloned_stack.is_ammo = true
    end
    
    if item_stack.is_item_with_tags then
        cloned_stack.tags = item_stack.tags
        cloned_stack.custom_description = item_stack.custom_description
        cloned_stack.is_item_with_tags = true
    end
    
    --...and hopefully this doesn't make it not accept it as an ItemStackDefinition...
    
    return cloned_stack
    
end

-- Copies all given item stacks to ItemStackDefinitions for non-referential use.
-- Preserves order.
--- @param item_stacks ItemStackIdentification[] the stacks to copy from
--- @return ItemStackDefinition[] the copied stacks
clone_item_stacks = function(item_stacks)
    local cloned = {}
    for index, stack in pairs(item_stacks) do
        cloned[index] = clone_item_stack(stack)
    end
    return cloned
end

-- Changes all of the item stacks given to have the given quality. (Does not copy, so passed table may be changed.)
--- @param item_stacks ItemStackIdentification[] the stacks to make quality
--- @param quality QualityID the quality 
--- @return ItemStackIdentification[] the same stacks, with the given quality.
make_items_quality = function(item_stacks, quality)
    for _, stack in pairs(item_stacks) do
        stack.quality = quality
    end
    return item_stacks
end

--- Create a projectile from source to target
--- @param name string the name of the projectile
--- @param surface LuaSurface the surface to create the projectile on
--- @param source MapPosition|LuaEntity position table to start at
--- @param target MapPosition|LuaEntity the entity or position to target
--- @param data_entity LuaEntity the entity to be passed in to the projectile-hit event (through minor abuse of the engine)
--- @return LuaEntity the projectile created
create_projectile = function(name, surface, source, target, speed)
    speed = speed or .4
    local force = source.force or target.force or 'player'
    local position = source.position or source
    if config.DEBUG then
        game.print("Creating projectile")
    end
    return surface.create_entity { name = name, force = force, position = position, source = source, target = target, speed = speed }
end