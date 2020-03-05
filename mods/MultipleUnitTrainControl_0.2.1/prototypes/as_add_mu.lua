--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: as_add_mu.lua
 * Description: Integration with Angel's Addons Smelting Train mod
--]]


if mods["angelsaddons-smeltingtrain"] then

	-- Generate an MU version of the Smelting Locomotive and Smelting Mule
	createMuLoco{std="smelting-locomotive-1",mu="smelting-locomotive-1-mu",item="item-with-entity-data"}
	createMuLoco{std="smelting-locomotive-tender",mu="smelting-locomotive-tender-mu",item="item-with-entity-data"}
	
end
