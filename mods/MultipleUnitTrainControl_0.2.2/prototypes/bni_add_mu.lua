--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: bni_add_mu.lua
 * Description: Integration with Batteries Not Included electric trains
--]]


if mods["BatteriesNotIncluded"] then

	-- Generate an MU version of the BNI Electric Locomotive
	createMuLoco{std="bni_electric-locomotive",mu="bni_electric-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	
end
