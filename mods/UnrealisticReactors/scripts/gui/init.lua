local rpath = (...):match("(.-)[^%.]+$")
local stats = require(rpath .. "stats")


local function init()
	global.gui_count = 0
	global.stats = {}
	global.guis = {}
end


local exports = { -- exports
	init = init,
}

for name, export in pairs(stats) do
	exports[name] = export
end

return exports

