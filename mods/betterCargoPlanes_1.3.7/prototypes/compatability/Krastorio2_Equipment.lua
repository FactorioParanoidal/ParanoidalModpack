local function AddEquipmentCategories(equipment_category)
	if data.raw["equipment-category"][equipment_category] then
		table.insert(data.raw["equipment-grid"]["cargo-plane-equipment-grid"].equipment_categories, equipment_category)
		table.insert(data.raw["equipment-grid"]["better-cargo-plane-equipment-grid"].equipment_categories, equipment_category)
		table.insert(data.raw["equipment-grid"]["even-better-cargo-plane-equipment-grid"].equipment_categories, equipment_category)
	end
end

AddEquipmentCategories("vehicle-motor");
AddEquipmentCategories("vehicle-robot-interaction-equipment");
AddEquipmentCategories("robot-interaction-equipment");
AddEquipmentCategories("universal-equipment");