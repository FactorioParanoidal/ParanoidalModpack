--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: yirr_add_mu.lua
 * Description: Integration with Yuoki Industries Railroads mod
--]]


if mods["z_yira_yuokirails"] then

	-- Generate an MU version of the non-steam locomotives
	createMuLoco{std="yir_ns2200wr",mu="yir_ns2200wr-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_ns2200gg",mu="yir_ns2200gg-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_diesel_620",mu="y_loco_diesel_620-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_usl",mu="yir_usl-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_lsw_r790orange",mu="yir_lsw_r790orange-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_lsw_r790red",mu="yir_lsw_r790red-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_lsw_840green",mu="yir_lsw_840green-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_desw_blue",mu="y_loco_desw_blue-mu",item="item",hasDescription=true}	
	
end
