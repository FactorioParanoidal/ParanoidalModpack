-- deep-storage-unit 9.9.0 is a migration bridge. The item and fluid memory units moved to the mod
-- paranoidal-deep-storage. Factorio keeps the storage of a mod under the mod's own name, so on old saves the
-- contents of the item memory units stay here; paranoidal-deep-storage takes them over once, in its
-- on_configuration_changed. This mod adds no gameplay, prototypes or settings.

local OLD_GUI = "memory_unit_gui" -- player.gui.relative, deep-storage-unit 9.8.0 and earlier

-- Render objects, script inventories and windows of the old version.
local function remove_leftovers()
	rendering.clear(script.mod_name)
	for _, inventory in pairs(game.get_script_inventories(script.mod_name)[script.mod_name] or {}) do
		if inventory.valid then inventory.destroy() end
	end
	storage.blank_gui_inventories = nil
	for _, player in pairs(game.players) do
		local gui = player.gui.relative[OLD_GUI]
		if gui and gui.valid and gui.get_mod() == script.mod_name then gui.destroy() end
	end
end

-- Contents of every unit that held something, as plain data: unit number -> {item, quality, count}, plus the
-- renames the old version recorded. The records are dropped here afterwards.
local function take_units()
	local units = {}
	for unit_number, unit_data in pairs(type(storage.units) == "table" and storage.units or {}) do
		if type(unit_data) == "table" and unit_data.item then
			units[unit_number] = {item = unit_data.item, quality = unit_data.quality, count = unit_data.count or 0}
		end
	end
	local result = {units = units, renames = type(storage.renames) == "table" and storage.renames or nil}
	remove_leftovers()
	storage.units = nil
	storage.renames = nil
	log("deep-storage-unit bridge: handed over " .. table_size(units) .. " item memory units with contents")
	return result
end

remote.add_interface("deep-storage-unit-migration", {
	take_units = take_units,
})

script.on_configuration_changed(remove_leftovers)
