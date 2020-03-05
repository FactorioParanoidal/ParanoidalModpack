--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: ret_add_mu.lua
 * Description: Integration with J_Aetherwing's Realistic Electric Trains
--]]

if mods["Realistic_Electric_Trains"] then

	-- Generate an MU version of the Electric and Electric Mk2 Locomotives
	createMuLoco{std="ret-electric-locomotive",mu="ret-electric-locomotive-mu",item="item-with-entity-data",fuel_item="ret-dummy-fuel-1",hasDescription=true}
	createMuLoco{std="ret-electric-locomotive-mk2",mu="ret-electric-locomotive-mk2-mu",item="item-with-entity-data",fuel_item="ret-dummy-fuel-2",hasDescription=true}
	createMuLoco{std="ret-modular-locomotive",mu="ret-modular-locomotive-mu",item="item-with-entity-data",hasDescription=true}
	
end
