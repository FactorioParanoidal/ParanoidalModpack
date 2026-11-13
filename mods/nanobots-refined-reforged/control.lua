local events = require('scripts/events')
local interface = require('interface')
local commands_handler = require('commands')

--(( Player and force data ))--
-- Same layout as the stdlib2 Player/Force modules kept it: storage.players[index] and storage.forces[name].
local function new_player_data(player)
    return {index = player.index, name = player.name, force = player.force.name, ranges = {}}
end

local function init_players()
    storage.players = storage.players or {}
    for index, player in pairs(game.players) do
        if not storage.players[index] then
            storage.players[index] = new_player_data(player)
        end
    end
end

local function init_forces()
    storage.forces = storage.forces or {}
    for name in pairs(game.forces) do
        if not storage.forces[name] then
            storage.forces[name] = {index = name, name = name}
        end
    end
end

events.on('on_init', init_players)
events.on('on_init', init_forces)
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
events.on(defines.events.on_force_created, init_forces)
events.on(defines.events.on_forces_merged, function(event)
    storage.forces[event.source_name] = nil
end)
--))

require('scripts/nanobots-auto')
require('scripts/nanobots-manual')
require('scripts/roboport-interface')
require('scripts/armor-mods')

require('scripts/timing')

remote.add_interface(script.mod_name, {
    reset_mod = interface.reset_mod,
    reset_queue = interface.reset_queue,
    count_queue = interface.count_queue
})

commands.add_command(script.mod_name, 'Команды Nanobot', commands_handler)

-- Installed after every module has registered its handlers; the only death handler removes this interface.
script.set_event_filter(defines.events.on_entity_died, {{filter = 'name', name = 'roboport-interface-main'}})
