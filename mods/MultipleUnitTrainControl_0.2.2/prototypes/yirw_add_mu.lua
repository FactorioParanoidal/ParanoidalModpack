--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: yirw_add_mu.lua
 * Description: Integration with Yuokitani's Railways mod
--]]


if mods["yi_railway"] then

	-- Generate an MU version of the non-steam locomotives
	createMuLoco{std="yir_loco_del_bluegray",mu="yir_loco_del_bluegray-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_emd3000_white",mu="y_loco_emd3000_white-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_loco_del_KR",mu="yir_loco_del_KR-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_loco_fut_red",mu="yir_loco_fut_red-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_loco_del_mk1400",mu="yir_loco_del_mk1400-mu",item="item",hasDescription=true}
	
	-- Generate MU versions for the "addons" tab locomotives
	createMuLoco{std="yir_loco_fesw_op",mu="yir_loco_fesw_op-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_desw",mu="y_loco_desw-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_desw_orange",mu="y_loco_desw_orange-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_desw_blue",mu="y_loco_desw_blue-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_emd1500black",mu="y_loco_emd1500black-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_emd1500blue",mu="y_loco_emd1500blue-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_emd1500blue_v2",mu="y_loco_emd1500blue_v2-mu",item="item",hasDescription=true}
	createMuLoco{std="y_loco_emd1500black_v2",mu="y_loco_emd1500black_v2-mu",item="item",hasDescription=true}	
	
end
