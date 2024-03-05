krastorio2GridName = "kr-cargo-plane-grid"

if data.raw["equipment-grid"][krastorio2GridName] then
	newGrid = table.deepcopy(data.raw["equipment-grid"]["cargo-plane-equipment-grid"])
	newGrid.name = krastorio2GridName
	data.raw["equipment-grid"][krastorio2GridName] = newGrid
end