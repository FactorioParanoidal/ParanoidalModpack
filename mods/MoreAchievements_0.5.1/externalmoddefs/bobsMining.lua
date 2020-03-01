if data.raw["mining-drill"]["bob-area-mining-drill-1"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "mining-the-area",
		order = "a",
		to_build = "bob-area-mining-drill-1",
		icon = "__MoreAchievements__/graphics/bobs/mining-the-area.png",
		icon_size = 128
	}}
end 
if data.raw["mining-drill"]["bob-area-mining-drill-4"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "no-ores-land",
		order = "b",
		to_build = "bob-area-mining-drill-4",
		icon = "__MoreAchievements__/graphics/bobs/no-ores-land.png",
		icon_size = 128
	}}
end
if data.raw["mining-tool"]["diamond-axe"] then
	data:extend{{
		type = "produce-achievement",
		name = "can-i-axe-you-a-question",
		order = "c",
		item_product = "diamond-axe",
		amount = 1,
		icon = "__MoreAchievements__/graphics/bobs/can-i-axe-you-a-question.png",
		icon_size = 128,
		limited_to_one_game = true,
	}}
end
if data.raw["mining-drill"]["bob-mining-drill-4"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "ultiminer",
		order = "d",
		to_build = "bob-mining-drill-4",
		icon = "__MoreAchievements__/graphics/bobs/ultiminer.png",
		icon_size = 128
	}}
end
if data.raw["mining-drill"]["bob-pumpjack-4"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "pumped-up",
		order = "d",
		to_build = "bob-pumpjack-4",
		icon = "__MoreAchievements__/graphics/bobs/pumped-up.png",
		icon_size = 128
	}}
end
