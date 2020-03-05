--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: et_add_mu.lua
 * Description: Integration with magu5026's Electric Train
--]]


if mods["ElectricTrain"] then

	-- Generate an MU version of the Electric Train 1, 2, and 3
	createMuLoco{std="et-electric-locomotive-1",mu="et-electric-locomotive-1-mu",item="item-with-entity-data"}
	createMuLoco{std="et-electric-locomotive-2",mu="et-electric-locomotive-2-mu",item="item-with-entity-data"}
	createMuLoco{std="et-electric-locomotive-3",mu="et-electric-locomotive-3-mu",item="item-with-entity-data"}
	
end
