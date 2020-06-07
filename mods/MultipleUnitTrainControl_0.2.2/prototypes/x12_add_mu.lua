--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: x12_add_mu.lua
 * Description: Integration with X-12 Nuclear Locomotive mod
--]]


if mods["X12NuclearLocomotive"] then

	-- Generate an MU version of the X-12 Nuclear Locomotive, powered version only
	createMuLoco{std="x12-nuclear-locomotive-powered",mu="x12-nuclear-locomotive-powered-mu",item="item-with-entity-data",hasDescription=true}
	
end
