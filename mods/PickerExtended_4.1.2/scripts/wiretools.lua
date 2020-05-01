-------------------------------------------------------------------------------
--[WIRE TOOLS]--
-------------------------------------------------------------------------------
local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local table = require('__stdlib__/stdlib/utils/table')
local lib = require('__PickerAtheneum__/utils/lib')

--Cut wires code modified from "WireStripper", by "justarandomgeek"
--https://mods.factorio.com/mods/justarandomgeek/wirestripper

local function update_wires(player, entities, network)
    local found = false
    for _, entity in pairs(entities) do
        if not network then
            if entity.type == 'electric-pole' then
                found = true
                pcall(
                    function()
                        entity.disconnect_neighbour()
                    end
                )
            end
        else
            found = true
            pcall(
                function()
                    entity.disconnect_neighbour(defines.wire_type.green)
                    entity.disconnect_neighbour(defines.wire_type.red)
                end
            )
        end
        if entity.last_user then
            entity.last_user = player
        end
    end
    return found
end

local function cut_wires(event)
    if event.item == 'picker-wire-cutter' and #event.entities > 0 then
        local player = game.players[event.player_index]
        if player.admin or not settings.global['picker-tool-admin-only'].value then
            if event.name == defines.events.on_player_selected_area then
                if update_wires(player, event.entities) then
                    player.print({'wiretool.copper-removed'})
                end
            elseif event.name == defines.events.on_player_alt_selected_area then
                update_wires(player, event.entities, 'network')
                player.print({'wiretool.network-removed'})
            end
        else
            player.print({'picker.must-be-admin'})
        end
    end
end
Event.register({defines.events.on_player_alt_selected_area, defines.events.on_player_selected_area}, cut_wires)

local wire_types = {
    'red-wire',
    'green-wire',
    'copper-cable'
}

local function pick_wires(event)
    local player = game.players[event.player_index]
    local stack = player.cursor_stack
    if not stack.valid_for_read then
        for _, wire_name in ipairs(wire_types) do
            local wire = lib.get_item_stack(player, wire_name)
            if wire then
                return player.clean_cursor() and stack.swap_stack(wire)
            end
        end
        player.print({'wiretool.no-wires-found'})
    elseif stack.valid_for_read then
        local index
        local _find = function(v, k)
            if v == stack.name then
                index = k
                return true
            end
        end

        if table.any(wire_types, _find) then
            local start = index
            repeat
                index = index < #wire_types and index + 1 or 1
                local wire = lib.get_item_stack(player, wire_types[index])
                if wire then
                    return player.clean_cursor() and stack.swap_stack(wire)
                end
            until index == start
            player.print({'wiretool.no-wires-found'})
            player.clean_cursor()
        end
    end
end
Event.register('picker-wire-picker', pick_wires)

--[[
    "name": "rewire",
	"title": "Rewire",
	"author": "deltatag",
	"description": "Neatly rewire electric grid setups.",
--]]
local function rewire_wires(event)
    if event.item == 'picker-rewire' and #event.entities > 2 then
        -- Pretty crude but works for now
        -- filter all valid electric poles
        local poles = {}
        for _, entity in ipairs(event.entities) do
            if entity.type == 'electric-pole' then
                poles[#poles + 1] = entity
            end
        end

        for _, pole1 in ipairs(poles) do
            for _, pole2 in ipairs(poles) do
                -- calculate differences
                local v = Position(pole1.position) % Position(pole2.position)
                if v.x > 0.05 and v.y > 0.05 then
                    pole1.disconnect_neighbour(pole2)
                end
                if (v.x <= 0.05 and v.y > 0.05) or (v.x > 0.05 and v.y <= 0.05) then
                    pole1.connect_neighbour(pole2)
                end
            end
        end

    end
end
Event.register({defines.events.on_player_alt_selected_area, defines.events.on_player_selected_area}, rewire_wires)
