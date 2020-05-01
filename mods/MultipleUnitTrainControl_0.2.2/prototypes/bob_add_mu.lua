--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: bob_add_mu.lua
 * Description: Integration with Bob's Logistics trains
--]]


if mods["boblogistics"] then

	-- Generate an MU version of the new locomotives
	createMuLoco{std="bob-locomotive-2",mu="bob-locomotive-2-mu",item="item-with-entity-data"}
	createMuLoco{std="bob-locomotive-3",mu="bob-locomotive-3-mu",item="item-with-entity-data"}
	createMuLoco{std="bob-armoured-locomotive",mu="bob-armoured-locomotive-mu",item="item-with-entity-data"}
	createMuLoco{std="bob-armoured-locomotive-2",mu="bob-armoured-locomotive-2-mu",item="item-with-entity-data"}
	
end
