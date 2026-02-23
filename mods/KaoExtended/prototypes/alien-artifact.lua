local function AddArtifacts()
	data:extend({
		{
			type = "item",
			name = "bob-alien-artifact",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-128.png",
			icon_size = 128,
			flags = {},
			subgroup = "raw-material",
			order = "g[alien-artifact]-a[pink]",
			stack_size = 500,
			default_request_amount = 10,
		},
	})

	data:extend({
		{
			type = "item",
			name = "bob-alien-artifact-red",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-red-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-b[red]",
			stack_size = 500,
			default_request_amount = 10,
		},

		{
			type = "item",
			name = "bob-alien-artifact-orange",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-orange-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-c[orange]",
			stack_size = 500,
			default_request_amount = 10,
		},

		{
			type = "item",
			name = "bob-alien-artifact-yellow",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-yellow-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-d[yellow]",
			stack_size = 500,
			default_request_amount = 10,
		},

		{
			type = "item",
			name = "bob-alien-artifact-green",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-green-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-e[green]",
			stack_size = 500,
			default_request_amount = 10,
		},

		{
			type = "item",
			name = "bob-alien-artifact-blue",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-blue-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-f[blue]",
			stack_size = 500,
			default_request_amount = 10,
		},

		{
			type = "item",
			name = "bob-alien-artifact-purple",
			icon = "__bobicons__/graphics/icons/alien/alien-artifact-purple-128.png",
			icon_size = 128,
			subgroup = "raw-material",
			order = "g[alien-artifact]-g[purple]",
			stack_size = 500,
			default_request_amount = 10,
		},
	})
end

-- Artifacts enabled by bobenenies mod by default
-- So i leave custom loot but not call
--
-- PS: bobicons deprecated so if you want enable this
-- you need change icons module name
-- AddArtifacts()

-- bob enemies
-- unitName = prefix + tier + element + type
local prefix = "bob-"
local enemyTiers = { "small-", "medium-", "big-", "huge-", "titan-", "behemoth-", "leviathan-" }
local elements = { "poison-", "piercing-", "fire-", "explosive-", "electric-" }
local enemyType = { "biter", "spitter" }
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
			for _, enemyType in ipairs(enemyType) do
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
