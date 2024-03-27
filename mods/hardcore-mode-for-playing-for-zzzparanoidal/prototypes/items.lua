require("__hardcore-mode-for-playing__.prototypes.fuel-category.fuel-categories")
local function copy_item(name, new_name)
	return flib.copy_prototype(data.raw["item"][name], new_name)
end
data:extend({
	copy_item("bi-bio-farm", "coal-bi-bio-farm"),
	copy_item("bi-bio-greenhouse", "coal-bi-bio-greenhouse"),
	copy_item("bi-seed", "coal-tree-seed"),
	copy_item("seedling", "coal-seedling"),
	copy_item("mining-drill-bit-mk0", "salvaged-mining-drill-bit-mk0"),
	copy_item("offshore-pump-0", "salvaged-offshore-pump-0"),
	copy_item("burner-mining-drill", "salvaged-mining-drill"),
	copy_item("burner-ore-crusher", "salvaged-ore-crusher"),
})

-- поделки из дерева, кроме стружки и чего-то там ещё - не горят, резина не горит
-- электричка - не горит, тем более с лампами!
cleanup_fuel_category_for_Item("small-electric-pole")
cleanup_fuel_category_for_Item("bi-wooden-pole-big")
cleanup_fuel_category_for_Item("lighted-bi-wooden-pole-big")
cleanup_fuel_category_for_Item("bi-wooden-pole-huge")
cleanup_fuel_category_for_Item("lighted-bi-wooden-pole-huge")
-- в сундуках всяких хлам лежит - не горит
cleanup_fuel_category_for_Item("wooden-chest")
-- в трубах остаётся что угодно, они сырые, не горят
cleanup_fuel_category_for_Item("bi-wood-pipe")
cleanup_fuel_category_for_Item("bi-wood-pipe-to-ground")
-- винтовки и туррели - не жечь
cleanup_fuel_category_for_Item("bi-wooden-fence")
cleanup_fuel_category_for_Item("bi-dart-turret")
cleanup_fuel_category_for_Item("bi-woodpulp")
--резину не жечь
cleanup_fuel_category_for_Item("solid-rubber")
