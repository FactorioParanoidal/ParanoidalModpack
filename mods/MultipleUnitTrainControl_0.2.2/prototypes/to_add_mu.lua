--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: to_add_mu.lua
 * Description: Integration with Optera's Train & Fuel Overhaul
--]]


if mods["TrainOverhaul"] then

	-- Generate an MU version of the Heavy, Express, and Nuclear Locomotives
	createMuLoco{std="heavy-locomotive",mu="heavy-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	createMuLoco{std="express-locomotive",mu="express-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	createMuLoco{std="nuclear-locomotive",mu="nuclear-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	
end
