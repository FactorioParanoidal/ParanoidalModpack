-- Вкладка меню «Покорение космоса» для сборки без SpaceX: раньше её давал SpaceXGAR2.
-- Имена группы и подгрупп прежние; раскладку наполняет tweaks/custom/production-space-menu.lua.
if not data.raw["item-group"]["space-exploration"] then
	data:extend({
		{
			type = "item-group",
			name = "space-exploration",
			order = "x",
			inventory_order = "x",
			icon = "__zzzparanoidal__/graphics/space-exploration-tab.png",
			icon_size = 64,
		},
	})
end

for _, subgroup in ipairs({ { "space-exploration-a", "a" }, { "space-exploration-b", "b" } }) do
	if not data.raw["item-subgroup"][subgroup[1]] then
		data:extend({
			{ type = "item-subgroup", name = subgroup[1], group = "space-exploration", order = subgroup[2] },
		})
	end
end
