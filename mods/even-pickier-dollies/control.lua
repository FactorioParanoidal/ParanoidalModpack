--
-- runtime code
--

local util = require('util')
local tools = require('scripts.tools')
local const = require('scripts.constants')

local event_id = script.generate_event_name()

---@class EvenPickierDolliesMod
---@field event_id defines.events The event id registered with the main game.
---@field remote_interface EvenPickierDolliesRemoteInterface
---@field settings EvenPickierDolliesSettings
local epd = {
    event_id = event_id,
    settings = require('scripts.settings'),
    remote_interface = require('scripts.remote-interface')(event_id),
}

remote.add_interface(const.api_name, epd.remote_interface)

assert(remote.interfaces[const.api_name]['dolly_moved_entity_id'])

---@param move_event EvenPickierDolliesMoveEvent
function epd:move_entity(move_event)
    local player = move_event.player
    local cheat_mode = player.cheat_mode

    local entity = move_event.entity

    local debug = self.settings.get_debug(player)
    local item_destroy = self.settings.get_item_destroy()

    if not cheat_mode then
        -- check remote view mode
        if not self.settings.get_remote_move() and (player.controller_type == defines.controllers.remote) then
            return tools.flying_text(player, { "picker-dollies.cant-remote-move", entity.localised_name }, entity.position)
        end

        -- Check player in range.
        if not player.can_reach_entity(entity) then
            return tools.flying_text(player, { "cant-reach" }, entity.position)
        end
    end

    -- ghost moving must be explicitly allowed
    if entity.type == 'entity-ghost' and not (cheat_mode or epd.settings.get_ghost_move()) then
        return tools.flying_text(player, { "picker-dollies.cant-be-teleported", entity.ghost_localised_name }, entity.position)
    end

    -- Check if entity is blacklisted, cheat_mode allows moving more entities.
    if not tools.allow_moving(entity, cheat_mode) then
        return tools.flying_text(player, { "picker-dollies.cant-be-teleported", entity.localised_name }, entity.position)
    end

    -- Only move entities of the same force unless cheat_mode is enabled.
    local entity_force = entity.force --[[@as LuaForce]]
    if not (cheat_mode or entity_force == player.force) then
        return tools.flying_text(player, { "picker-dollies.wrong-force", entity.localised_name }, entity.position)
    end

    -- save start position in case we have to unwind
    local start_pos = entity.position        -- Where we started from in case we have to return it
    local start_direction = entity.direction -- Direction in which the entity currently points
    local start_unit_number = entity.unit_number

    local surface = entity.surface

    local entity_has_moved = false

    -- Make sure there is not a rocket present.
    -- @todo Move the rocket-silo-rocket to the correct spot.
    if entity.type == 'rocket-silo' and surface.find_entity("rocket-silo-rocket", start_pos) then
        return tools.flying_text(player, { "picker-dollies.rocket-present", entity.localised_name }, start_pos)
    end

    if debug then
        -- green box shows the current bounding box before moving/rotating
        rendering.draw_rectangle {
            color = { r = 0.3, g = 1, b = 0.3 },
            surface = player.surface,
            left_top = entity.bounding_box.left_top,
            right_bottom = entity.bounding_box.right_bottom,
            time_to_live = 120,
        }
    end

    ---@type LuaEntity?
    local target_entity = entity

    -- undo everything
    local function undo_move(message)
        -- we created a new target entity but it was not viable. Remove it
        if target_entity and (target_entity.unit_number ~= entity.unit_number) then
            target_entity.destroy()
        end

        entity.direction = start_direction

        if entity_has_moved and not entity.teleport(start_pos) then
            -- error message at the original position
            return tools.flying_text(player, { 'picker-dollies.teleport-problem', entity.localised_name }, player.position)
        end

        return tools.flying_text(player, { message, entity.localised_name }, start_pos)
    end

    local target_pos = start_pos

    if move_event.rotate then entity.direction = move_event.rotate end -- operation was a rotate

    local target_box = entity.bounding_box
    local direction = move_event.direction -- Direction to move the source

    -- process move
    if direction then
        local distance = move_event.distance * entity.prototype.building_grid_bit_shift -- Distance to move the source, defaults to 1
        target_pos = tools.position_translate(start_pos, direction, distance)           -- Where we want to go too
        target_box = tools.area_translate(target_box, direction, distance)              -- Target collision box location
    end

    -- update the saved entity for multiple moves.
    tools.save_entity(move_event.pdata, entity, move_event.tick)

    -- see if we can place the entity in the new spot
    local ignore_collisions = self.settings.get_allow_ignore_collisions() and self.settings.get_ignore_collisions(player)

    if debug then
        -- red box is the target position
        rendering.draw_rectangle {
            color = { r = 1, g = 0.3, b = 0.3 },
            surface = player.surface,
            left_top = target_box.left_top,
            right_bottom = target_box.right_bottom,
            time_to_live = 120,
        }
    end

    -- unconditional teleport first.  this can move an entity e.g. on water so it needs to be undone
    if not entity.teleport(target_pos) then
        -- If that does not work, try falling back to transporter mode: "create entity clone, destroy original entity move".

        if not self.settings.get_transporter_mode() then return undo_move('picker-dollies.cant-be-teleported') end

        -- only allow whitelisted types to be moved
        local transporter_mode_enabled = const.whitelist_transporter_mode_types[entity.type]
        if not transporter_mode_enabled then return undo_move('picker-dollies.cant-be-teleported') end

        if not player.can_place_entity {
                name = entity,
                position = target_pos,
                direction = entity.direction
            } then return undo_move('picker-dollies.no-room') end

        target_entity = tools.clone_entity(entity, target_pos, transporter_mode_enabled)

        if not target_entity then return undo_move('picker-dollies.no-room') end
    else
        entity_has_moved = true
    end

    -- at this point, there is a potential second entity around (target_entity) *OR* the original entity has
    -- moved. The "entity_has_moved" flag signals where we are.
    assert(target_entity)

    if not tools.can_wires_reach(entity, target_entity) then return undo_move('picker-dollies.wires-maxed') end

    if entity_has_moved then
        -- if the original entity has moved, target_entity is the same as the entity itself
        assert(entity.unit_number == target_entity.unit_number)
        -- move back to start position
        assert(entity.teleport(start_pos), "Could not move back to start position!")
    else
        -- target box is now the collision box of the new entity itself
        target_box = target_entity.bounding_box
    end


    if tools.has_collision(target_entity, target_box, ignore_collisions) then return undo_move('picker-dollies.no-room') end

    if entity.type ~= 'entity-ghost' then
        -- Mine or destroy of the way any items on the ground.
        local items_on_ground = player.surface.find_entities_filtered { type = "item-entity", area = target_box }
        for _, item_entity in pairs(items_on_ground) do
            if not player.mine_entity(item_entity) and item_destroy then
                item_entity.destroy {}
            end
        end
    end

    if entity_has_moved then
        -- all additional placement checks (e.g. on water) are done with this last teleport
        if not entity.teleport(target_pos, nil, true, false, ignore_collisions and defines.build_check_type.script or defines.build_check_type.ghost_revive) then
            -- this can happen in ignore-collisions mode
            return undo_move('picker-dollies.no-room')
        end
    else
        -- update the saved entity for multiple moves
        tools.save_entity(move_event.pdata, target_entity, move_event.tick)
        entity.destroy()
    end

    -- everything seems to be fine
    if target_entity.last_user then target_entity.last_user = player end

    -- Move a proxy to the correct position...
    local proxy = surface.find_entity("item-request-proxy", start_pos)
    if proxy and proxy.valid then proxy.teleport(target_pos) end

    -- Update all connections.
    -- @todo Only add updateable_entities to a list.
    local updateable_entities = surface.find_entities_filtered { area = tools.area_expand(target_box, const.grid_size), force = entity_force }
    for _, updateable in pairs(updateable_entities) do updateable.update_connections() end

    ---@type EvenPickierDolliesRemoteInterfaceDollyMovedEvent
    local event_data = {
        player_index = player.index,
        moved_entity = target_entity,
        start_pos = start_pos,
        start_direction = start_direction,
        start_unit_number = start_unit_number,
        tick = game.tick,
        name = event_id,
    }

    script.raise_event(self.event_id, event_data)
    player.play_sound { path = "utility/rotated_medium" }
end

---@param event EventData.CustomInputEvent
function epd.dolly_move(event)
    local player, pdata = game.get_player(event.player_index), tools.pdata(event.player_index)
    if not player then return end

    local save_time = epd.settings.get_save_entity(player)
    local entity = tools.get_entity_to_move(player, pdata, event.tick, save_time)
    if not entity then return end

    ---@type EvenPickierDolliesMoveEvent
    local move_event = {
        player = player,
        pdata = pdata,
        tick = event.tick,
        entity = entity,
        save_time = save_time,
        direction = const.input_to_direction[event.input_name], -- direction in which the entity is moved
        distance = 1,
    }

    epd:move_entity(move_event)
end

---@param event EventData.CustomInputEvent
---@param reverse boolean
function epd.rotate_oblong_entity(event, reverse)
    ---@type LuaPlayer?
    local player = game.get_player(event.player_index)
    if not player then return end
    if player.cursor_stack.valid_for_read or player.cursor_ghost then return end

    local pdata = tools.pdata(event.player_index)

    local save_time = epd.settings.get_save_entity(player)
    local entity = tools.get_entity_to_move(player, pdata, event.tick, save_time)
    if not entity then return end

    local distance = storage.oblong_names[entity.name]

    -- ghost moving must be explicitly allowed
    if entity.type == 'entity-ghost' and not epd.settings.get_ghost_move() then return end

    if not (distance and tools.allow_moving(entity, player.cheat_mode)) then return end
    if not (player.cheat_mode or player.can_reach_entity(entity)) then return end

    local rotate = reverse and tools.direction_previous(entity.direction) or tools.direction_next(entity.direction)

    ---@type EvenPickierDolliesMoveEvent
    local move_event = {
        player = player,
        pdata = pdata,
        tick = event.tick,
        entity = entity,
        save_time = save_time,
        direction = const.oblong_diags[rotate],
        distance = distance,
        rotate = rotate,
    }

    epd:move_entity(move_event)
end

---@param event EventData.CustomInputEvent
---@param reverse boolean
function epd.rotate_saved_dolly(event, reverse)
    ---@type LuaPlayer?
    local player = game.get_player(event.player_index)
    if not (player and player.cursor_stack) then return end

    if player.cursor_stack.valid_for_read or player.cursor_ghost or player.selected then return end

    local pdata = tools.pdata(event.player_index)

    local save_time = epd.settings.get_save_entity(player)
    local entity = tools.get_entity_to_move(player, pdata, event.tick, save_time)
    if not entity or not entity.supports_direction then return end

    tools.save_entity(pdata, entity, event.tick)
    entity.rotate { reverse = reverse, by_player = player }
end

function epd.selected_entity_changed(event)
    ---@type LuaPlayer?
    local player = game.get_player(event.player_index)
    if not (player and player.selected) then return end

    if not epd.settings.get_clear_entity(player) then return end

    local pdata = tools.pdata(event.player_index)

    local save_time = epd.settings.get_save_entity(player)
    local entity = tools.get_saved_entity(pdata, event.tick, save_time)

    if not (entity and entity.valid) then return end
    if entity.unit_number == player.selected.unit_number then return end

    tools.save_entity(pdata, nil, event.tick)
end

function epd.cursor_stack_changed(event)
    ---@type LuaPlayer?
    local player = game.get_player(event.player_index)
    if not player then return end

    local pdata = tools.pdata(event.player_index)
    tools.save_entity(pdata, nil, event.tick)
end

function epd.on_configuration_changed()
    -- Make sure the blacklists exist.
    storage.blacklist_names = storage.blacklist_names or {}
    storage.oblong_names = storage.oblong_names or {}

    for name, distance in pairs(const.oblong_names) do
        storage.oblong_names[name] = distance
    end

    for name in pairs(storage.oblong_names) do
        if type(storage.oblong_names[name]) ~= 'number' then
            storage.oblong_names[name] = 0.5 -- default offset for a 2x1 oblong entity
        end
    end

    for name in pairs(const.blacklist_names) do
        storage.blacklist_names[name] = true
    end

    -- Remove any invalid prototypes from the blacklists.
    for name in pairs(storage.blacklist_names) do
        if not prototypes.entity[name] then storage.blacklist_names[name] = nil end
    end
    for name in pairs(storage.oblong_names) do
        if not prototypes.entity[name] then storage.oblong_names[name] = nil end
    end
end

function epd.register_events()
    script.on_event({ "dolly-move-north", "dolly-move-east", "dolly-move-south", "dolly-move-west" }, epd.dolly_move)

    script.on_event("dolly-rotate-rectangle", function (event) epd.rotate_oblong_entity(event, false) end)
    script.on_event("dolly-rotate-rectangle-reverse", function (event) epd.rotate_oblong_entity(event, true) end)
    script.on_event("dolly-rotate-saved", function (event) epd.rotate_saved_dolly(event, false) end)
    script.on_event("dolly-rotate-saved-reverse", function (event) epd.rotate_saved_dolly(event, true) end)

    script.on_configuration_changed(epd.on_configuration_changed)
    script.on_event(defines.events.on_selected_entity_changed, epd.selected_entity_changed)

    script.on_event(defines.events.on_player_cursor_stack_changed, epd.cursor_stack_changed)
end

-- event registration

function epd.on_init()
    storage.blacklist_names = util.copy(const.blacklist_names)
    storage.oblong_names = util.copy(const.oblong_names)

    epd.register_events()
end

function epd.on_load()
    epd.register_events()
end

script.on_init(epd.on_init)
script.on_load(epd.on_load)
