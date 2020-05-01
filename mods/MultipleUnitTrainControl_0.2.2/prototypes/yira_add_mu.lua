--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: yira_add_mu.lua
 * Description: Integration with Yuoki Industries Railroads - American mod
--]]


if mods["z_yira_american"] then

	-- Generate an MU version of the non-steam locomotives
	createMuLoco{std="yir_emdf7a_mn",mu="yir_emdf7a_mn-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_emdf7b_mn",mu="yir_emdf7b_mn-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_emdf7b_cr",mu="yir_emdf7b_cr-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_emdf7a_cr",mu="yir_emdf7a_cr-mu",item="item",hasDescription=true}
	createMuLoco{std="yir_es44cr",mu="yir_es44cr-mu",item="item",hasDescription=true}
	
end
