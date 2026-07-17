-- Extended Angels (extendedangels/prototypes/overrides/warehouses.lua) при наличии
-- Angel's Industries уводит склады mk2/mk3/mk4 в отдельную вкладку angels-logistics.
-- Возвращаем их подгруппы в группу logistics, подряд за базовым mk1
-- (angels-warehouse). Каждый тир — своя подгруппа = свой ряд: mk1, mk2, mk3, mk4.
if not (mods["angelsaddons-storage"] and data.raw["item-subgroup"]["angels-warehouse"]) then
	return
end

local tier_subgroups = {
	["angels-warehouses-2"] = "ae[chests-warehouse]-b",
	["angels-warehouses-3"] = "ae[chests-warehouse]-c",
	["angels-warehouses-4"] = "ae[chests-warehouse]-d",
}
for name, order in pairs(tier_subgroups) do
	local sg = data.raw["item-subgroup"][name]
	if sg then
		sg.group = "logistics"
		sg.order = order
	end
end

local cols = {
	["angels-warehouse"] = "a",
	["angels-warehouse-active-provider"] = "b",
	["angels-warehouse-passive-provider"] = "c",
	["angels-warehouse-storage"] = "d",
	["angels-warehouse-buffer"] = "e",
	["angels-warehouse-requester"] = "f",
}
local function set_order(proto, order)
	if proto then
		proto.order = order
	end
end

for base, col in pairs(cols) do
	for tier = 1, 4 do
		local name = (tier == 1) and base or (base .. "-mk" .. tier)
		set_order(data.raw.recipe[name], col)
		set_order(data.raw.item[name], col)
		set_order(data.raw.container[name], col)
		set_order(data.raw["logistic-container"][name], col)
	end
end
