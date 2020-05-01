-------------------------------------------------------------------------------
--[Picker Extended]--
-------------------------------------------------------------------------------
require('__stdlib__/stdlib/event/event').set_protected_mode(true)
require('__stdlib__/stdlib/event/changes').register_events('mod_versions', 'changes/versions')
require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)

--(( Picker Scripts ))--
require('scripts/playeroptions')
require('scripts/reviver')
require('scripts/renamer')
require('scripts/pastesettings')
require('scripts/flashlight')
require('scripts/playerdeath')
require('scripts/tools')
require('scripts/wiretools')
require('scripts/oreeraser')
require('scripts/planners')
require('scripts/crafter')
--)) Picker Scripts ((--

--(( Remote Interfaces ))--
local interface = require('__stdlib__/stdlib/scripts/interface')
remote.add_interface(script.mod_name, interface) --))
