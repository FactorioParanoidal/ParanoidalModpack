-------------------------------------------------------------------------------
--[New Picker Extended]--
-------------------------------------------------------------------------------
local events = require('utils/events')

--(( Player data ))--
-- storage.players[index] = {index, name, force, ...}, as the kry_stdlib Player module kept it.
local function new_player_data(player)
    return {index = player.index, name = player.name, force = player.force.name}
end

local function init_players()
    storage.players = storage.players or {}
    for index, player in pairs(game.players) do
        if not storage.players[index] then
            storage.players[index] = new_player_data(player)
        end
    end
end
events.on('on_init', init_players)
events.on(defines.events.on_player_created, init_players)
events.on(defines.events.on_player_changed_force, function(event)
    local player = game.get_player(event.player_index)
    storage.players = storage.players or {}
    local pdata = storage.players[event.player_index]
    if not pdata then
        pdata = new_player_data(player)
        storage.players[event.player_index] = pdata
    end
    pdata.force = player.force.name
end)
events.on(defines.events.on_player_removed, function(event)
    storage.players[event.player_index] = nil
end)
--))

--(( Picker Extended Scripts ))--
-- taken from Picker Extended
require('scripts/playeroptions')
require('scripts/searchlight')
require('scripts/reviver')
require('scripts/qualityscroll')-- NEW: Scrolls through quality of held item, if possible
require('scripts/planners')

-- taken from Picker Inventory Tools
require('scripts/zapper')
require('scripts/copychest')
require('scripts/chestlimit')
require('scripts/inventorysort')

-- taken from Picker Belt Tools
require('scripts/autocircuit')  -- why was this part of Picker Belt Tools?
--)) Picker Scripts ((--

--(( Remote Interfaces ))--
remote.add_interface(script.mod_name, require('utils/interface')) --))
