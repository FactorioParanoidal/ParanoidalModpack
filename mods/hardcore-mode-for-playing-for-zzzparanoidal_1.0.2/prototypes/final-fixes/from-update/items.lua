require("__hardcore-mode-for-playing__.prototypes.fuel-categories")
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
cleanupFuelCategoryForItem("small-electric-pole")
cleanupFuelCategoryForItem("bi-wooden-pole-big")
cleanupFuelCategoryForItem("lighted-bi-wooden-pole-big")
cleanupFuelCategoryForItem("bi-wooden-pole-huge")
cleanupFuelCategoryForItem("lighted-bi-wooden-pole-huge")
-- в сундуках всяких хлам лежит - не горит
cleanupFuelCategoryForItem("wooden-chest")
-- в трубах остаётся что угодно, они сырые, не горят
cleanupFuelCategoryForItem("bi-wood-pipe")
cleanupFuelCategoryForItem("bi-wood-pipe-to-ground")
-- винтовки и туррели - не жечь
cleanupFuelCategoryForItem("bi-wooden-fence")
cleanupFuelCategoryForItem("bi-dart-turret")
cleanupFuelCategoryForItem("bi-woodpulp")
--резину не жечь
cleanupFuelCategoryForItem("solid-rubber")
