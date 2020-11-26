local Event = require('__stdlib__/stdlib/event/event')
local Game = require('__stdlib__/stdlib/game')
local interface = require('__stdlib__/stdlib/scripts/interface')

require('scripts/remote-queue')
require('scripts/event-dispatcher')

if settings.startup['picker-debug'].value then
    local function reload(event)
        local player = game.players[event.player_index]
        player.clear_console()
        game.print(script.mod_name .. ' is reloading mods.')
        game.reload_mods()
    end
    commands.add_command('Picker.reload', 'Reset', reload)
    require('__stdlib__/stdlib/utils/globals').create_stdlib_globals()
    Event.register('picker-reload-mods', reload)
    Event.register('picker-dump-data', interface.dump_all)
end

if script.active_mods["debugadapter"] then
    local function breakpoint()
        __DebugAdapter.breakpoint('Manual Breakpoint Triggered')
    end
    Event.register('picker-trigger-breakpoint', breakpoint)
end

commands.add_command('Picker.write-all', {'picker.write-all'}, interface.dump_all)
commands.add_command('Picker.mods-to-file', 'Write mods to file', Game.write_mods)
commands.add_command('Picker.surface-to-file', 'Write surface info to file', Game.write_surfaces)
commands.add_command('Picker.statistics', 'Write statistics info to file', Game.write_statistics)

remote.add_interface(script.mod_name, interface)
