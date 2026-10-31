-- One-time takeover of the units built with deep-storage-unit 9.8.0 and fluid-memory-storage 9.8.0 and earlier.
--
-- The entities and their hidden parts keep their prototype names, so they stay on the map; only the records
-- were kept by the old mods (Factorio keeps the storage of a mod under the mod's own name):
-- - item units: deep-storage-unit 9.9.0 is a bridge that still holds them and hands over the contents
--   (plain data: item, quality, count by unit number) through its remote interface;
-- - fluid units: fluid-memory-storage is removed, the fluid in their counters is lost. The fluid in the tank
--   itself stays and the unit locks to it again.
-- Runs in on_configuration_changed: by then the storage of the bridge is restored (it is not during on_init of
-- a mod added to a save).

local item_unit = require "scripts.item-unit"
local fluid_unit = require "scripts.fluid-unit"

local M = {}

local BRIDGE = "deep-storage-unit-migration"

local function take_from_bridge()
	local interface = remote.interfaces[BRIDGE]
	if not (interface and interface.take_units) then return {} end
	local data = remote.call(BRIDGE, "take_units")
	if type(data) ~= "table" then return {} end
	-- Renames recorded by the old mod: packed units in chests may still carry old item names.
	for kind, renames in pairs(type(data.renames) == "table" and data.renames or {}) do
		storage.renames[kind] = storage.renames[kind] or {}
		for old, new in pairs(renames) do
			if storage.renames[kind][old] == nil then storage.renames[kind][old] = new end
		end
	end
	return type(data.units) == "table" and data.units or {}
end

function M.run()
	if storage.takeover_done then return end
	storage.takeover_done = true

	local old_units = take_from_bridge()
	-- Leftovers of the removed fluid mod, if the game kept any (the bridge clears its own).
	pcall(function() rendering.clear("fluid-memory-storage") end)

	local items, restored, fluids = 0, 0, 0
	for _, surface in pairs(game.surfaces) do
		for _, entity in pairs(surface.find_entities_filtered {name = item_unit.names}) do
			local unit_number = entity.unit_number
			if not storage.units[unit_number] then
				local old = old_units[unit_number]
				local tags = old and old.item and {name = old.item, count = old.count, quality = old.quality} or nil
				item_unit.register(entity, tags)
				items = items + 1
				if tags then restored = restored + 1 end
			end
		end
		for _, entity in pairs(surface.find_entities_filtered {name = fluid_unit.names}) do
			if not storage.fluid_units[entity.unit_number] then
				fluid_unit.register(entity)
				fluids = fluids + 1
			end
		end
	end
	if items + fluids > 0 then
		log(string.format("paranoidal-deep-storage: took over %d item units (%d with contents from deep-storage-unit) and %d fluid units (counters lost)",
			items, restored, fluids))
	end
end

return M
