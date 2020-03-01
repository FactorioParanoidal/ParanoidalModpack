if not data.raw["item-subgroup"]["bob-assembly-machine"] then return end --Bob's assembling machines not installed

if data.raw["assembling-machine"]["assembling-machine-6"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "flash-crafter",
		order = "a",
		to_build = "assembling-machine-6",
		icon = "__MoreAchievements__/graphics/bobs/flash-crafter.png",
		icon_size = 128
	}}
end
if data.raw["assembling-machine"]["oil-refinery-4"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "a-refined-taste",
		order = "b",
		to_build = "oil-refinery-4",
		icon = "__MoreAchievements__/graphics/bobs/a-refined-taste.png",
		icon_size = 128
	}}
end
if data.raw["assembling-machine"]["chemical-plant-4"] then
	data:extend{{
		type = "build-entity-achievement",
		name = "we-have-chemistry",
		order = "c",
		to_build = "chemical-plant-4",
		icon = "__MoreAchievements__/graphics/bobs/we-have-chemistry.png",
		icon_size = 128
	}}
end
if data.raw.technology["automation-4"] then
	data:extend{{
		type = "research-achievement",
		name = "what-if-we-could-craft-even-faster",
		order = "d",
		technology = "automation-4",
		icon = "__MoreAchievements__/graphics/bobs/what-if-we-could-craft-even-faster.png",
		icon_size = 128
	}}
end
