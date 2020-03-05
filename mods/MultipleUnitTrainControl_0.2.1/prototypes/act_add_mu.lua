--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: act_add_mu.lua
 * Description: Integration with Angel's Industries
--]]


if mods["angelsindustries"] then
	-- Generate an MU version of the Angel's Crawler Locomotive
	createMuLoco{std="crawler-locomotive",mu="crawler-locomotive-mu",item="item-with-entity-data"}
	createMuLoco{std="crawler-locomotive-wagon",mu="crawler-locomotive-wagon-mu",item="item-with-entity-data"}
end
