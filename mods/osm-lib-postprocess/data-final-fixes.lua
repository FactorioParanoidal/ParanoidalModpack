------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Setup local host
local data_core = require("data-core")

-- Index properties
data_core.index_properties()

-- Get additional mod prototypes
data_core.get_additional_prototypes()

-- Check for disabled prototypes
data_core.disable_prototypes()

-- Finalise properties
data_core.finalise_prototypes()

-- Regenerate properties
data_core.regenerate_properties()

-- Debug mode
if OSM.debug_mode then data_core.debug_mode() end

-----------------------------------------------------------------------

-- Print log
data_core.print_log()