local rpath = (...):match("(.-)[^%.]+$")
local Setting = require(rpath .. "setting")
local network = require(rpath .. "heat.network")
local technology = require(rpath .. "technology")
local union_tables = require(rpath .. "util").union_tables
local splitty = require(rpath .. "gui.util").splitty
local Setting = require(rpath .. "setting")


local function on_configuration_changed()
	for _,reactor in pairs(global.reactors) do --updating signals for removed fuel cell mods
		if reactor.entity.valid == true then
			if reactor.entity.get_fuel_inventory().is_empty() then
				reactor.signals.parameters["uranium-fuel-cells"] = {signal=SIGNAL_URANIUM_FUEL_CELLS, count=0, index=8}
			end
		end
		reactor.signals.parameters["used-uranium-fuel-cells"] = nil
		reactor.signals.parameters["neighbour-bonus"] = {signal=SIGNAL_NEIGHBOUR_BONUS, count=0, index=13}
	end
	technology.init()
end


return on_configuration_changed -- exports
