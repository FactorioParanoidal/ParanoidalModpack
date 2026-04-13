--[[
    A basic interface script, with generic functions
    usage:
    local interface = require(__Kux-CoreLib__/stdlib/scripts/interface)
    interface.myfunc = function() end
    remote.add_interface(script.mod_name, interface)
    interface.myfunc2 = function() end -- Can even add new functions afterwards!
]] --
local interface = {}
local Table = require('__Kux-CoreLib__/stdlib/utils/table') --[[@as StdLib.Utils.Table]]

local Event = require('__Kux-CoreLib__/stdlib/event/event')
local Game = require('__Kux-CoreLib__/stdlib/game')
local Changes = require('__Kux-CoreLib__/stdlib/event/changes')
local Player = require('__Kux-CoreLib__/stdlib/event/player')
local Force = require('__Kux-CoreLib__/stdlib/event/force')

local ignore_defines = Table.invert { 'anticolor', 'lightcolor', 'color', 'time' }

local function write(data, name, keyignore, maxlevel)
    return serpent.block(data, { comment = false, nocode = true, name = name, keyignore = keyignore, maxlevel = maxlevel })
end

interface['write_global'] = function()
    helpers.remove_path(script.mod_name)

    helpers.write_file(script.mod_name .. '/global.lua', write(global, 'global'))
    helpers.write_file(script.mod_name .. '/package.lua', write(package.loaded, 'package', nil, 1))
    helpers.write_file(script.mod_name .. '/interface.lua', write(remote.interfaces[script.mod_name] or {}, 'interface'))
    helpers.write_file(script.mod_name .. '/_G.lua', write(_G, 'globals', nil, 1))

    Event.dump_data()
    Player.dump_data()
    Force.dump_data()
    Changes.dump_data()
end

interface['dump_all'] = function()
    helpers.remove_path('Interfaces')

    helpers.write_file('defines.lua', write(defines, 'defines', ignore_defines))

    helpers.write_file('interfaces.lua', write(remote.interfaces, 'interfaces'))
    for name, interfaces in pairs(remote.interfaces) do
        -- Write each interface
        helpers.write_file('Interfaces/' .. name .. '.lua', write(interfaces, 'interface'))
        if interfaces['write_global'] then remote.call(name, 'write_global') end
    end

    Game.write_mods()
    Game.write_surfaces()
    Game.write_statistics()
    game.print('Finished writing all data to script-output')
end

interface['merge_interfaces'] = function(tab)
    Table.merge(interface, tab, false)
    return interface
end

return interface
