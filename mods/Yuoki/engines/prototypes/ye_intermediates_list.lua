--[[Yuoki intermediates script
Copyright joshrick (Codec) © August 2020
adds Yuoki intermediate products to the vanilla intermediates list--]]
local productivity_item_list = {
	"y-iron-case",
	"y-quantrinum-charge",
	"ye_center",
	"ye_sealing",
	"y-winding",
	"yie_pureiron",
	"yie_hard_metals",
	"ye_buechsenblech",
}

for _, module in pairs(data.raw.module) do
	if module.effect and module.limitation then
		for effect_name in pairs(module.effect) do
			if effect_name == "productivity" then
				for _, item in pairs(productivity_item_list) do
					table.insert(module.limitation, item)
				end
				break
			end
		end
	end
end
