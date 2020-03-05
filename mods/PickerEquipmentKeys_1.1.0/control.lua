require('__stdlib__/stdlib/event/event').set_protected_mode(true)

require('scripts/switch-gun')
require('scripts/eq-toggles')

remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
