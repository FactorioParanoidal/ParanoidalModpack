--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: evr_add_mu.lua
 * Description: Integration with Electric Vehicles Reborn
--]]


if mods["electric-vehicles-reborn"] then
-- Check version number
	local r = {0,1,2} -- required version
	local ver = mods["electric-vehicles-reborn"]
	local f = {tonumber(string.match(ver,"^(%d+)%.")),  -- found version
	           tonumber(string.match(ver,"%.(%d+)%.")),
			   tonumber(string.match(ver,"%.(%d+)$"))}
	if (f[1] > r[1]) or (f[1] == r[1] and f[2] > r[2]) or (f[1] == r[1] and f[2] == r[2] and f[3] >= r[3]) then
		-- Generate an MU version of the EVR Electric Locomotive
		createMuLoco{std="electric-vehicles-electric-locomotive",mu="electric-vehicles-electric-locomotive-mu",
							item="item-with-entity-data",hasDescription=true}
	end
end
