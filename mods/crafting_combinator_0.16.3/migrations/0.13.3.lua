if not late_migrations then return end

local config = require 'config'
local cc_control = require 'script.cc'
local settings_parser = require 'script.settings-parser'


log("Adding missing settings to combinators...")
for _, combinator in pairs(global.cc.data) do
	settings_parser.fill_defaults(combinator.settings, config.CC_DEFAULT_SETTINGS)
end
