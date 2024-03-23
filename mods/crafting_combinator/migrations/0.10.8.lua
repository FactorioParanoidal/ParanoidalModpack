if not late_migrations then return end

late_migrations["Use module chests as overflow"] = function()
	local cc_control = require 'script.cc'
	cc_control.on_load()
	for _, combinator in pairs(global.cc.data) do combinator:find_chest(); end
end
