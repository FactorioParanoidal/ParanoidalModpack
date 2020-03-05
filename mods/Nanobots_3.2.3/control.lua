local Event = require('__stdlib__/stdlib/event/event').set_protected_mode(true)
local Interface = require('__stdlib__/stdlib/scripts/interface').merge_interfaces(require('interface'))
local Commands = require('commands')

local ev = defines.events
Event.build_events = {ev.on_built_entity, ev.on_robot_built_entity, ev.script_raised_built, ev.script_raised_revive, ev.on_entity_cloned}
Event.mined_events = {ev.on_pre_player_mined_item, ev.on_robot_pre_mined, ev.script_raised_destroy}

local Player = require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)
require('__stdlib__/stdlib/event/changes').register_events('mod_versions', 'changes/versions')

Player.additional_data({ranges = {}})

require('scripts/nanobots')
require('scripts/roboport-interface')
require('scripts/armor-mods')

require('scripts/reprogram-gui')

remote.add_interface(script.mod_name, Interface)

commands.add_command(script.mod_name, 'Nanobot commands', Commands)
