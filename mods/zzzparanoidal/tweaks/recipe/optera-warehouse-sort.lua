-- Warehousing (Optera): basic-склады сидят в vanilla-подгруппе "storage", а
-- логистические — в "logistic-network", поэтому разбросаны по разным рядам.
-- Собираем каждое семейство в свою подгруппу-ряд по сетке постройки:
-- 6×6 (warehouse) и 3×3 (storehouse), порядок колонок как у Angel's-складов
-- (basic, active, passive, storage, buffer, requester).
if not mods["Warehousing"] then
	return
end

data:extend({
	{ type = "item-subgroup", name = "optera-storehouse", group = "logistics", order = "ae[chests-warehouse]-e" },
	{ type = "item-subgroup", name = "optera-warehouse", group = "logistics", order = "ae[chests-warehouse]-f" },
})

local cols = {
	["basic"] = "a",
	["active-provider"] = "b",
	["passive-provider"] = "c",
	["storage"] = "d",
	["buffer"] = "e",
	["requester"] = "f",
}

local function set_sub(proto, sg, order)
	if proto then
		proto.subgroup = sg
		proto.order = order
	end
end

for _, fam in ipairs({
	{ prefix = "warehouse", sg = "optera-warehouse" },
	{ prefix = "storehouse", sg = "optera-storehouse" },
}) do
	for suffix, col in pairs(cols) do
		local name = fam.prefix .. "-" .. suffix
		set_sub(data.raw.recipe[name], fam.sg, col)
		set_sub(data.raw.item[name], fam.sg, col)
		set_sub(data.raw.container[name], fam.sg, col)
		set_sub(data.raw["logistic-container"][name], fam.sg, col)
	end
	local linked = "linked-" .. fam.prefix
	set_sub(data.raw.item[linked], fam.sg, "g")
	set_sub(data.raw["linked-container"][linked], fam.sg, "g")
end
