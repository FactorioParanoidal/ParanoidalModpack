-- Shared helpers of the memory unit (Paranoidal fork).
-- fluid-memory-storage keeps its own copy of the generic parts; keep both in sync.

local floor = math.floor
local min = math.min

local M = {}

M.update_rate = 15
M.update_slots = 4
-- Physical chest size of every unit, whatever its quality (quality lowers power usage instead).
M.buffer_slots = 300
-- Stacks kept in the chest for inserters; the rest lives in the counter.
M.comfortable_slots = 150

function M.compactify(n)
	n = floor(n)

	local suffix = 1
	local new
	while n >= 1000 do
		new = floor(n / 100) / 10
		if n == new then
			return {"big-numbers.infinity"}
		else
			n = new
		end
		suffix = suffix + 1
	end

	if suffix ~= 1 and floor(n) == n then n = tostring(n) .. ".0" end

	return {"big-numbers." .. suffix, n}
end

-- Exact amount with digit groups: 1 234 567.
function M.format_exact(n)
	n = floor(n)
	if n >= 1e21 then return string.format("%.4g", n) end
	local digits = string.format("%.0f", n)
	local grouped = digits:reverse():gsub("(%d%d%d)", "%1 "):reverse()
	return (grouped:gsub("^ ", ""))
end

-- One blank item-with-inventory per player: its GUI shows the player's inventory next to ours.
function M.open_inventory(player)
	storage.blank_gui_inventories = storage.blank_gui_inventories or {}
	local inventory = storage.blank_gui_inventories[player.index]
	if not (inventory and inventory.valid) then
		inventory = game.create_inventory(1)
		inventory[1].set_stack("blank-gui-item")
		inventory[1].allow_manual_label_change = false
		storage.blank_gui_inventories[player.index] = inventory
	end
	player.opened = nil
	player.opened = inventory[1]
	return player.opened
end

-- Destroys script inventories left by older versions (one leaked per opened GUI).
function M.cleanup_script_inventories()
	local keep = {}
	for _, inventory in pairs(storage.blank_gui_inventories or {}) do
		if inventory.valid then keep[inventory] = true end
	end
	local destroyed = 0
	local owned = game.get_script_inventories(script.mod_name)[script.mod_name] or {}
	for _, inventory in pairs(owned) do
		if inventory.valid and not keep[inventory] then
			inventory.destroy()
			destroyed = destroyed + 1
		end
	end
	if destroyed > 0 then log("memory units: destroyed " .. destroyed .. " leaked GUI inventories") end
end

local function get_render(id)
	if not id then return nil end
	local object = rendering.get_object_by_id(id)
	if object and object.valid then return object end
	return nil
end
M.get_render = get_render

function M.destroy_render(id)
	local object = get_render(id)
	if object then object.destroy() end
end

function M.update_display_text(unit_data, entity, localised_string)
	local object = get_render(unit_data.text)
	if object then
		object.text = localised_string
		return
	end

	unit_data.text = rendering.draw_text {
		surface = entity.surface,
		target = entity,
		text = localised_string,
		alignment = "center",
		scale = 1.5,
		only_in_alt_mode = true,
		color = {r = 1, g = 1, b = 1}
	}.id
end

local function control_section(combinator)
	local control = combinator.get_or_create_control_behavior()
	return control.get_section(1) or control.add_section()
end

function M.update_combinator(combinator, signal, count)
	count = min(2147483647, floor(count))
	control_section(combinator).set_slot(1, {
		value = signal,
		min = count,
		max = count
	})
end

function M.clear_combinator(combinator)
	local section = control_section(combinator)
	if section.get_slot(1).value then section.clear_slot(1) end
end

local power_usages = {
	["0W"] = 0,
	["60kW"] = 1000,
	["180kW"] = 3000,
	["300kW"] = 5000,
	["480kW"] = 8000,
	["600kW"] = 10000,
	["1.2MW"] = 20000,
	["2.4MW"] = 40000,
	["3.6MW"] = 40000 / 2.4 * 3.6,
	["5MW"] = 40000 / 2.4 * 5,
	["10MW"] = 40000 / 2.4 * 10,
	["20MW"] = 40000 / 2.4 * 20,
	["50MW"] = 40000 / 2.4 * 50,
}

-- Quality lowers the whole power usage along a parabola:
-- factor = MIN + (1 - MIN) * (1 - i / N)^2, where i is the step above normal
-- and N the number of steps in the quality chain (normal -> next -> ... -> last).
-- Qualities outside the chain (defects, hidden) get no discount.
M.min_quality_factor = 0.2
local quality_factors
function M.quality_factor(quality_name)
	if not quality_factors then
		quality_factors = {}
		local chain, seen = {}, {}
		local quality = prototypes.quality["normal"]
		while quality and not seen[quality.name] do
			seen[quality.name] = true
			chain[#chain + 1] = quality.name
			quality = quality.next
		end
		local steps = #chain - 1
		local min_factor = M.min_quality_factor
		for i, name in ipairs(chain) do
			local step = i - 1
			quality_factors[name] = steps > 0 and (min_factor + (1 - min_factor) * (1 - step / steps) ^ 2) or 1
		end
	end
	return quality_factors[quality_name] or 1
end

local base_usage = 1000000 / 60
function M.update_power_usage(unit_data, count)
	local powersource = unit_data.powersource
	local multiplier = power_usages[settings.global["memory-unit-power-usage"].value] or power_usages["300kW"]
	local power_usage = (math.ceil(count / (unit_data.stack_size or 1000)) ^ 0.35) * multiplier + base_usage
	power_usage = power_usage * M.quality_factor(unit_data.entity.quality.name)
	powersource.power_usage = power_usage
	powersource.electric_buffer_size = power_usage
end

function M.has_power(powersource, entity)
	if powersource.energy < powersource.electric_buffer_size * 0.9 then
		if powersource.energy ~= 0 then
			rendering.draw_sprite {
				sprite = "utility.electricity_icon",
				x_scale = 0.5,
				y_scale = 0.5,
				target = entity,
				surface = entity.surface,
				time_to_live = 30
			}
		end
		return false
	end

	return not entity.to_be_deconstructed()
end

-- Items whose stacks carry data (equipment grids, inventories, tags, blueprints, vehicles)
-- would lose it in the counter. Spoilable items would stop spoiling.
local data_item_types = {
	["armor"] = true,
	["item-with-entity-data"] = true,
	["item-with-tags"] = true,
	["item-with-label"] = true,
	["item-with-inventory"] = true,
	["blueprint"] = true,
	["blueprint-book"] = true,
	["deconstruction-item"] = true,
	["upgrade-item"] = true,
	["copy-paste-tool"] = true,
	["selection-tool"] = true,
	["spidertron-remote"] = true,
	["space-platform-starter-pack"] = true,
}
local vehicle_types = {
	["car"] = true,
	["spider-vehicle"] = true,
	["locomotive"] = true,
	["cargo-wagon"] = true,
	["fluid-wagon"] = true,
	["artillery-wagon"] = true,
	["infinity-cargo-wagon"] = true,
}

local function classify(name)
	local prototype = prototypes.item[name]
	if not prototype then return "missing" end
	if prototype.get_spoil_ticks() ~= 0 then return "spoil" end
	if data_item_types[prototype.type] or prototype.equipment_grid then return "data" end
	local place_result = prototype.place_result
	if place_result and vehicle_types[place_result.type] then return "data" end
	return "ok"
end

local storable_cache = {}
-- "ok", "spoil", "data" or "missing".
function M.storable_reason(name)
	local reason = storable_cache[name]
	if not reason then
		reason = classify(name)
		storable_cache[name] = reason
	end
	return reason
end

function M.is_storable(name)
	return M.storable_reason(name) == "ok"
end

-- Status text for an item the unit refuses.
function M.refusal_text(name)
	local reason = M.storable_reason(name)
	local localised_name = prototypes.item[name] and prototypes.item[name].localised_name or name
	if reason == "spoil" then return {"entity-status.cannot-store", localised_name} end
	return {"entity-status.cannot-store-data", localised_name}
end

-- Rename tables collected from configuration changes: old name -> new name, false if removed.
function M.record_migrations(changes)
	storage.renames = storage.renames or {}
	local migrations = changes and changes.migrations
	if not migrations then return end
	for _, kind in pairs({"item", "fluid", "quality"}) do
		local renames = migrations[kind]
		if renames then
			storage.renames[kind] = storage.renames[kind] or {}
			for old, new in pairs(renames) do
				storage.renames[kind][old] = (new ~= "" and new) or false
			end
		end
	end
end

-- Current name of a stored prototype, following recorded renames; nil if it is gone.
function M.resolve(kind, name, exists)
	local renames = storage.renames and storage.renames[kind] or {}
	local steps = 0
	while name and not exists(name) and steps < 32 do
		local new = renames[name]
		if not new then return nil end
		name = new
		steps = steps + 1
	end
	if name and exists(name) then return name end
	return nil
end

return M
