--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: ft_add_mu.lua
 * Description: Integration with Fusion Train
--]]


if mods["FusionTrain"] then

	-- Generate an MU version of the Fusion Locomotives
	createMuLoco{std="fusion-locomotive-1",mu="fusion-locomotive-1-mu",item="item-with-entity-data"}
	createMuLoco{std="fusion-locomotive-2",mu="fusion-locomotive-2-mu",item="item-with-entity-data"}
	createMuLoco{std="fusion-locomotive-3",mu="fusion-locomotive-3-mu",item="item-with-entity-data"}
	
end
