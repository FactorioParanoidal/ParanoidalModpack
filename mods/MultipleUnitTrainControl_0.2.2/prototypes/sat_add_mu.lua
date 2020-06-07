--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: sat_add_mu.lua
 * Description: Integration with Schall's Armoured Train
--]]


if mods["SchallArmouredTrain"] then

	-- Generate an MU version of the Armoured Locomotives
	createMuLoco{std="Schall-armoured-locomotive",mu="Schall-armoured-locomotive-mu",item="item-with-entity-data"}
	createMuLoco{std="Schall-armoured-locomotive-mk1",mu="Schall-armoured-locomotive-mk1-mu",item="item-with-entity-data"}
	createMuLoco{std="Schall-armoured-locomotive-mk2",mu="Schall-armoured-locomotive-mk2-mu",item="item-with-entity-data"}
	if data.raw["locomotive"]["Schall-armoured-locomotive-mk3"] then
		createMuLoco{std="Schall-armoured-locomotive-mk3",mu="Schall-armoured-locomotive-mk3-mu",item="item-with-entity-data"}
	end
	
end
