------------------------------------------------------------------------
-- runtime code
------------------------------------------------------------------------

require('lib.init')

-- setup events
require('scripts.event-setup')

-- other mods code
---@diagnostic disable-next-line: undefined-field
Framework.post_runtime_stage()
