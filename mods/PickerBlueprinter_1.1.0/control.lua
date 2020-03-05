require('__stdlib__/stdlib/event/event').set_protected_mode(true)
require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)

require('scripts/blueprinter')
require('scripts/deconstruction')
require('scripts/bpmirror')
require('scripts/bpupdater')
require('scripts/bpsnap')

require('__stdlib__/stdlib/event/changes').register('mod_versions', 'changes/remove_old_gui')
remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
