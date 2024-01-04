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
