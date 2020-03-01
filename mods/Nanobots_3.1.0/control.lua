local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Interface = require('__stdlib__/stdlib/scripts/interface').merge_interfaces(require('interface'))
local Commands = require('commands')

Event.build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
Event.mined_events = {defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined}

local Player = require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)
require('__stdlib__/stdlib/event/changes').register_events('mod_versions', 'changes/versions')

Player.additional_data({ranges = {}})

require('scripts/nanobots')
require('scripts/robointerface')
require('scripts/armormods')

require('scripts/reprogram-gui')

remote.add_interface(script.mod_name, Interface)

commands.add_command(script.mod_name, 'Nanobot commands', Commands)
