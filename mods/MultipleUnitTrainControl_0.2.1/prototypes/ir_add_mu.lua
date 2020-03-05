--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: ir_add_mu.lua
 * Description: Integration with Deadlock898's IndustrialRevolution mod
--]]


if mods["IndustrialRevolution"] then

	-- Generate an MU version of the Electric Locomotive
	createMuLoco{std="electric-locomotive",mu="electric-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	
end
