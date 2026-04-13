-- bob enemies
-- unitName = prefix + tier + element + type
local prefix = "bob-"
local enemyTiers = { "small-", "medium-", "big-", "huge-", "titan-", "behemoth-", "leviathan-" }
local elements = { "poison-", "piercing-", "fire-", "explosive-", "electric-" }
local enemyTypes = { "biter", "spitter" }
local elementToColor = {
	["poison-"] = { "-green" },
	["piercing"] = { "", "-yellow" },
	["fire-"] = { "-red" },
	["explosive-"] = { "-orange" },
	["electric-"] = { "-blue", "-purple" },
}

if data.raw.item["bob-small-alien-artifact"] then
	-- bob enemies loot
	for tier, tierName in ipairs(enemyTiers) do
		for _, element in ipairs(elements) do
			for _, enemyType in ipairs(enemyTypes) do
				local enemyFullName = prefix .. tierName .. element .. enemyType
				local probability = (tier * tier) / 100 -- smooth growth from 0.01 for 1 tier(small) to 0.5 to 7 tier(leviathan)
				for _, color in ipairs(elementToColor) do
					table.insert(data.raw.unit[enemyFullName].loot, {
						item = "bob-small-alien-artifact" .. color,
						count_min = 0,
						count_max = 3,
						probability = probability,
					})
				end
			end
		end
	end
	-- common enemy loot
	table.insert(
		data.raw.unit["small-biter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 1, probability = 0.01 }
	) --DrD all enemy count_min
	table.insert(
		data.raw.unit["small-spitter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 1, probability = 0.01 }
	)
	table.insert(
		data.raw.unit["medium-biter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 3, probability = 0.01 }
	)
	table.insert(
		data.raw.unit["medium-spitter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 3, probability = 0.01 }
	)
	table.insert(
		data.raw.unit["big-biter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 4, probability = 0.01 }
	)
	table.insert(
		data.raw.unit["big-spitter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 4, probability = 0.01 }
	)

	table.insert(
		data.raw.unit["behemoth-biter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 12, probability = 0.01 }
	)
	table.insert(
		data.raw.unit["behemoth-spitter"].loot,
		{ item = "bob-small-alien-artifact", count_min = 0, count_max = 12, probability = 0.01 }
	)
end

