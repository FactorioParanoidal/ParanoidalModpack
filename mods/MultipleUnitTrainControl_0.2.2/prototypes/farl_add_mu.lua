--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: farl_add_mu.lua
 * Description: Integration with Fully Automated Rail Layer
--]]


if mods["FARL"] then
	-- Generate an MU version of the Fully Automated Rail Layer
	createMuLoco{std="farl",mu="farl-mu",item="item-with-entity-data",hasDescription=true}
end
