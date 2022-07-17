-------------------------------------------------------------------------------
--[Ore Eraser]--
-------------------------------------------------------------------------------
--Ore Eraser modified from "Ore Eraser", by "Tergiver", "tergiver@msn.com"
--[[
world. Specifically it removes entities defined as type 'resource'.
In vanilla Factorio, resources are: iron, copper, coal, stone, oil, and uranium.

To use it, craft an Ore Eraser, found on the Production tab. It functions like a Blueprint or Deconstruction Planner.
With the Ore Eraser in hand, click and drag a rectangle encompassing the resource you want to remove.
--]]
local Event = require('__stdlib__/stdlib/event/event')

local function erase_ores(event)
    if event.item == 'picker-ore-eraser' then
        local player = game.players[event.player_index]
        local do_destroy = event.name == defines.events.on_player_alt_selected_area and (player.admin or not settings.global['picker-tool-admin-only'].value)
        local list = {}
        for _, entity in ipairs(event.entities) do
            if entity.type == 'resource' then
                local name = entity.name
                list[name] = list[name] or {count = 0, amount = 0, localised_name = entity.localised_name}
                list[name].count = list[name].count + 1
                list[name].amount = list[name].amount + entity.amount
                if do_destroy then
                    entity.deplete()
                end
            end
        end
        for _, ore in pairs(list) do
            local args = {'ore-eraser.message'}
            args[#args + 1] = do_destroy and {'ore-eraser.destroyed'} or {'ore-eraser.count'}
            args[#args + 1] = ore.amount
            args[#args + 1] = ore.localised_name
            args[#args + 1] = ore.count
            player.print(args)
        end
    end
end
Event.register({defines.events.on_player_selected_area, defines.events.on_player_alt_selected_area}, erase_ores)
