if not late_migrations then return end

local config = require 'config'
local cc_control = require 'script.cc'


cc_control.on_load()
log("Adding missing chest settings to combinators...")
for _, combinator in pairs(global.cc.data) do
	combinator.settings.chest_position = combinator.settings.chest_position or config.CC_DEFAULT_SETTINGS.chest_position
end
