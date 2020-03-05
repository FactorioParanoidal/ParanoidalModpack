--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: apc_add_mu.lua
 * Description: Integration with Angel's Addons Petrochem Train mod
--]]


if mods["angelsaddons-petrotrain"] then

	-- Generate an MU version of the Petrochem Locomotives
	createMuLoco{std="petro-locomotive-1",mu="petro-locomotive-1-mu",item="item-with-entity-data"}
	
end
