local rpath = (...):match("(.-)[^%.]+$")
local network = require(rpath .. "heat.network")

-- for legacy

-- local function add_heatpipe(entity)
-- 	if not network.get(entity) then
-- 		network.add_heat_pipe(entity)
-- 	end
-- end
--
--
-- local function remove_heatpipe(entity)
-- 	if network.get(entity) then
-- 		network.remove_heat_pipe(entity)
-- 	end
-- end


local function debug_heat_network(enabled)
	if enabled then
		network.debug.enable()
	else
		network.debug.disable()
	end
end

local function log_heat_network(enabled)
	network.debug.logging(enabled)
end


return { -- interface
--     add_heatpipe = add_heatpipe,
--     remove_heatpipe = remove_heatpipe,
	debug_heat_network = debug_heat_network,
	debug_log_heat_network = log_heat_network,
}

-- remote.call("rr-interface", "debug_heat_network", true)
