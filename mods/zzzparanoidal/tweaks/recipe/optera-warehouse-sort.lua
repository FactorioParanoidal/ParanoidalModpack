-- Warehousing (Optera): basic-склады сидят в vanilla-подгруппе "storage", а
-- логистические — в "logistic-network", поэтому разбросаны по разным рядам.
-- Собираем каждое семейство в свою подгруппу-ряд по сетке постройки:
-- 6×6 (warehouse) и 3×3 (storehouse), порядок Beta 8 micro-final-fix:
-- basic, active, buffer, passive, requester, storage. Цены и свойства не меняются.
if not mods["Warehousing"] then
	return
end

data:extend({
	{ type = "item-subgroup", name = "optera-storehouse", group = "logistics", order = "f-4" },
	{ type = "item-subgroup", name = "optera-warehouse", group = "logistics", order = "f-5" },
})

local cols = {
	["basic"] = "1",
	["active-provider"] = "2",
	["passive-provider"] = "4",
	["storage"] = "6",
	["buffer"] = "3",
	["requester"] = "5",
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
