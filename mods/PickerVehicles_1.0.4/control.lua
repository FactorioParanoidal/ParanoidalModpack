require('__stdlib__/stdlib/event/event').set_protected_mode(true)
require('__stdlib__/stdlib/event/player').register_events(true)

require('scripts/vehicles')
require('scripts/nakedrails')

remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
