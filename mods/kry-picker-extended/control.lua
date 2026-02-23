-------------------------------------------------------------------------------
--[New Picker Extended]--
-------------------------------------------------------------------------------
-- not sure which, if any of these lines are required
require('__kry_stdlib__/stdlib/event/event').set_option('protected_mode', true)
require('__kry_stdlib__/stdlib/event/event').set_protected_mode(true)
--require('__kry_stdlib__/stdlib/event/changes').register_events('mod_versions', 'changes/versions')
require('__kry_stdlib__/stdlib/event/player').register_events(true)
require('__kry_stdlib__/stdlib/event/force').register_events(true)

--(( Picker Extended Scripts ))--
-- taken from Picker Extended
require('scripts/playeroptions')
require('scripts/searchlight')
require('scripts/reviver')
require('scripts/itemcount')
--require('scripts/renamer')    -- no longer needed, use Renamer mod instead
--require('scripts/tools')      -- merged Tape Measure into planners, Screenshot mod replacements available
--require('scripts/oreeraser')  -- no longer needed, multiple mod replacements available
--require('scripts/picker')     -- This didn't work, but I might reuse parts of the code later
require('scripts/qualityscroll')-- NEW: Scrolls through quality of held item, if possible
require('scripts/planners')
--require('scripts/crafter')    -- no longer needed, use CursorEnhancements mod instead

-- taken from Picker Inventory Tools
require('scripts/zapper')
require('scripts/copychest')
require('scripts/chestlimit')
require('scripts/inventorysort')

-- taken from Picker Belt Tools
--require('scripts/beltbrush')  -- no longer needed, use standalone Belt Brush mod
require('scripts/beltreverser')
require('scripts/autocircuit')  -- why was this part of Picker Belt Tools?
--)) Picker Scripts ((--

--(( Remote Interfaces ))--
local interface = require('__kry_stdlib__/stdlib/scripts/interface')
remote.add_interface(script.mod_name, interface) --))
