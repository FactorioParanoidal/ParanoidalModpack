-------------------------------------------------------------------------------
--[Item Zapper]--
-------------------------------------------------------------------------------
local Event = require('__kry_stdlib__/stdlib/event/event')
local Player = require('__kry_stdlib__/stdlib/event/player')
local Position = require('__kry_stdlib__/stdlib/area/position')

local trash_types = {
    ['blueprint'] = true,
    ['blueprint-book'] = true,
    ['deconstruction-item'] = true,
    ['selection-tool'] = true,
    ['upgrade-item'] = true
}

-- Not needed, but kept in case zap all items functionality is requested in future.
--[[
local function zapper(event)
    local player, pdata = Player.get(event.player_index)
    local stack = player.cursor_stack

    if stack and stack.valid_for_read then
        local all = player.mod_settings['picker-item-zapper-all'].value

        if all or trash_types[stack.type] then
            if (pdata.last_dropped or 0) + 30 < game.tick then
                pdata.last_dropped = game.tick
                player.cursor_stack.clear()
                player.surface.create_entity {
                    name = 'drop-planner',
                    position = Position(player.position):translate(math.random(0, 7), math.random())
                }
            end
        end
    end
end
Event.register('picker-zapper', zapper)
]]--

-- Zap any planner item on drop, also might include zap all functionality here, if requested in future.
local function on_player_dropped_item(event)
    --local player = Player.get(event.player_index)
    local stack = event.entity and event.entity.stack
    --local zap_all = player.mod_settings['picker-zapper-all'].value
    --if stack and (trash_types[stack.type] or zap_all) then
    if stack and trash_types[stack.type] then
        event.entity.surface.create_entity {
            name = 'drop-planner',
            position = event.entity.position
        }
        event.entity.destroy()
    end
end
Event.register(defines.events.on_player_dropped_item, on_player_dropped_item)

-- Planners aren't automatically placed in inventory anymore, no longer need to clean inventory
--[[
local function trash_planners(event)
    local player = game.get_player(event.player_index)
    local settings = player.mod_settings

    local inventory = player.get_inventory(defines.inventory.character_trash)
    if inventory then
        if player.cheat_mode and settings['picker-trash-cheat'].value then
            inventory.clear()
        elseif settings['picker-trash-planners'].value then
            for i = 1, #inventory do
                local slot = inventory[i]
                if slot.valid_for_read and trash_types[slot.type] then
                    slot.clear()
                    return
                end
            end
        end
    end
end
Event.register(defines.events.on_player_trash_inventory_changed, trash_planners)
]]--