--[[ Copyright (c) 2020 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: k2_add_mu.lua
 * Description: Integration with Krastorio 2
--]]


if mods["Krastorio2"] then
	-- Generate an MU version of the Krastorio 2's Nuclear Locomotive
	createMuLoco{std="kr-nuclear-locomotive",mu="kr-nuclear-locomotive-mu",item="item-with-entity-data"}
end
