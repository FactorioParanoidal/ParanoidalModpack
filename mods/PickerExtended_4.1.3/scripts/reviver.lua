-------------------------------------------------------------------------------
--[Reviver] -- Revives the selected entity
-------------------------------------------------------------------------------

local Event = require('__stdlib__/stdlib/event/event')
local Area = require('__stdlib__/stdlib/area/area')
local Player = require('__stdlib__/stdlib/event/player')
local lib = require('__PickerAtheneum__/utils/lib')

--as of 08/30 this is mostly incorporated into base.
--Modules are still not revived,
--items on ground are not picked up
--tile proxys are not selected  Should be added to pippette to put in hand

local function revive_it(event)
    local placed = event.created_entity
    if not lib.ghosts[placed.name] and Area(placed.selection_box):size() > 0 then
        local player = game.get_player(event.player_index)
        lib.satisfy_requests(player, placed)
    else
        -- Auto reviver hack, stops autobuilding when placing a ghost item from an item (alt mode)
        local _, pdata = Player.get(event.player_index)
        pdata.next_revive_tick = event.tick + 1
    end
end
Event.register(defines.events.on_built_entity, revive_it)

local function picker_revive_selected(event)
    local player = game.players[event.player_index]
    if player.selected and player.controller_type ~= defines.controllers.ghost then
        if player.selected.name == 'item-on-ground' then
            return player.mine_entity(player.selected)
        elseif player.selected.name == 'item-request-proxy' and not player.cursor_stack.valid_for_read then
            lib.satisfy_requests(player, player.selected)
        end
    end
end
Event.register('picker-select', picker_revive_selected)

--- Automatically revive ghosts when hovering over them with the item in hand.
local function picker_revive_selected_ghosts(event)
    local player, pdata = Player.get(event.player_index)
    local selected = player.selected
    if player.controller_type ~= defines.controllers.ghost and selected then
        local stack = player.cursor_stack
        if stack.valid_for_read then
            if selected.type == 'entity-ghost' and player.mod_settings['picker-revive-selected-ghosts-entity'].value then
                if stack.type ~= 'rail-planner' and stack.prototype.place_result == game.entity_prototypes[selected.ghost_name] and pdata.next_revive_tick ~= event.tick then
                    local direction = selected.direction or defines.direction.north
                    local position = selected.position
                    -- API build_from_cursor to no do flip logic
                    if selected.ghost_type == 'underground-belt' then
                        local name = selected.ghost_name
                        local belt_type = selected.belt_to_ground_type
                        player.build_from_cursor {position = position, direction = direction}

                        local ent = player.surface.find_entity(name, position)
                        if ent then
                            if ent.belt_to_ground_type ~= belt_type then
                                ent.rotate()
                            end
                            ent.direction = direction
                        end
                    elseif selected.ghost_type == 'pipe-to-ground' then
                        local name = selected.ghost_name
                        player.build_from_cursor {position = position, direction = direction}
                        local ent = player.surface.find_entity(name, position)
                        if ent and ent.direction ~= direction then
                            ent.direction = direction
                        end
                    else
                        player.build_from_cursor {position = position, direction = direction}
                    end
                end
            elseif selected.type == 'tile-ghost' and player.mod_settings['picker-revive-selected-ghosts-tile'].vaue then
                local tile = stack.prototype.place_as_tile_result
                if tile and tile.result == game.tile_prototypes[selected.ghost_name] and pdata.next_revive_tick ~= event.tick then
                    player.build_from_cursor {position = selected.position, direction = selected.direction, terrain_building_size = 1}
                end
            end
        end
    end
end
Event.register(defines.events.on_selected_entity_changed, picker_revive_selected_ghosts)

return picker_revive_selected
