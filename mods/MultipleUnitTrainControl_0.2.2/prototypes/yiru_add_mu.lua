--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: yiru_add_mu.lua
 * Description: Integration with Yuoki Industries Railroads - Uranium mod
--]]


if mods["z_yira_UP"] then

	-- Generate an MU version of the uranium locomotives
	createMuLoco{std="yir_atom_header",mu="yir_atom_header-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_atom_mitte",mu="yir_atom_mitte-mu",item="item",hasDescription=true}
	
end
