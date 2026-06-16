----------------------------------------------------------------------------------------------------
--- Global definitions included in all phases
----------------------------------------------------------------------------------------------------

local const = require('lib.constants')

-- Framework core
require('framework.init'):init(const.framework_init)

-- mod code
require('lib.this')
