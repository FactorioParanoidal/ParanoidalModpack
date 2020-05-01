--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: nl_add_mu.lua
 * Description: Integration with Angel's Addons Smelting Train mod
--]]


if mods["Nuclear Locomotives"] then

	-- Generate an MU version of the Smelting Locomotive and Smelting Mule
	createMuLoco{std="nuclear-locomotive",mu="nuclear-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	
end
