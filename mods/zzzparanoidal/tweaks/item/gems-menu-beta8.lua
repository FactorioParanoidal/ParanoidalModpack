-- Beta 8: отдельная вкладка самоцветов, включая три ряда биокристаллов.
-- Только меню; рецепты, открытия, свойства и существующее оформление остаются 2.0.
if not mods["bobplates"] or not mods["angelsrefining"] then return end
local technology = data.raw.technology["bob-gem-processing-1"]
if not technology then return end

local group = data.raw["item-group"]["bob-gems"]
if not group then
	group = {
		type = "item-group", name = "bob-gems", order = "d-g",
		localised_name = { "entity-name.bob-gem-ore" },
		icons = technology.icons and table.deepcopy(technology.icons),
		icon = technology.icon, icon_size = technology.icon_size,
	}
	data:extend({ group })
else
	group.order = "d-g"
end

local rows = {
	["bob-gems-ore"] = "2-2",
	["bob-gems-raw"] = "4",
	["bob-gems-cut"] = "5",
	["bob-gems-polished"] = "6",
	["angels-bio-biter-processing-crystal-splinter"] = "7e[alien-products]-b[crystal]-a[splinter]",
	["angels-bio-biter-processing-crystal-shard"] = "7e[alien-products]-b[crystal]-b[shard]",
	["angels-bio-biter-processing-crystal-full"] = "7e[alien-products]-b[crystal]-c[full]",
}
for name, order in pairs(rows) do
	local row = data.raw["item-subgroup"][name]
	if row then row.group = "bob-gems"; row.order = order end
end
if not data.raw["item-subgroup"]["bob-gems-crystallization"] then
	data:extend({ {
		type = "item-subgroup", name = "bob-gems-crystallization", group = "bob-gems", order = "2-1",
	} })
end
for _, gem in ipairs({ "ruby", "sapphire", "emerald", "amethyst", "topaz", "diamond" }) do
	local item = data.raw.item["bob-" .. gem .. "-ore"]
	if item then item.subgroup = "bob-gems-crystallization" end
end
for index = 1, 6 do
	local recipe = data.raw.recipe["angels-ore7-crystallization-" .. index]
	if recipe then recipe.subgroup = "bob-gems-crystallization" end
end
-- В Beta 8 предмет и рецепт шлифовального камня находились в разных рядах.
local item = data.raw.item["angels-crystal-grindstone"]
if item and data.raw["item-subgroup"]["angels-bio-biter-processing-crystal-splinter"] then
	item.subgroup = "angels-bio-biter-processing-crystal-splinter"
	item.order = "d"
end
local recipe = data.raw.recipe["angels-crystal-grindstone"]
if recipe then recipe.subgroup = "bob-gems-cut"; recipe.order = "h-4" end
