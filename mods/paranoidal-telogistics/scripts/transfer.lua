-- The sender pass: a charged sender with cargo moves it to the receivers of its channel on the target planet.
-- Stacks move with LuaItemStack.transfer_stack, so quality, spoilage, health, ammo, equipment grids, blueprints and
-- inventories inside items stay as they are. Receiver slot filters and the red bar are respected.
local tiers = require("shared.tiers")
local registry = require("scripts.registry")

local M = {}

local CHEST = defines.inventory.chest
local DIODE = defines.entity_status_diode

local function planet_text(name)
	local proto = prototypes.space_location[name]
	return {"", "[planet=" .. name .. "] ", proto and proto.localised_name or name}
end

-- Status of a teleporter (panel and the entity's own status line); written only when it changes.
local function set_status(rec, key, diode, label)
	local stamp = key .. "|" .. serpent.line(label, {comment = false})
	if rec.status == stamp then return end
	rec.status = stamp
	rec.status_key = key
	rec.status_label = label
	rec.status_diode = diode
	local entity = rec.entity
	if entity and entity.valid then entity.custom_status = {diode = diode, label = label} end
end
M.set_status = set_status

local function target_surface(rec)
	local planet = rec.target and game.planets[rec.target]
	return planet and planet.surface or nil
end
M.target_surface = target_surface

-- Receivers of the sender's channel on the target surface, starting after the one served last (round robin).
local function receivers_for(rec, surface)
	local key = registry.receiver_key(rec.entity.force.index, surface.index, rec.channel)
	local set = storage.receivers[key]
	if not set then return {}, key end
	local units = {}
	for unit in pairs(set) do units[#units + 1] = unit end
	table.sort(units)
	local last = storage.cursors[key]
	local start = 1
	if last then
		for i, unit in ipairs(units) do
			if unit > last then
				start = i
				break
			end
		end
	end
	local list = {}
	for i = 0, #units - 1 do
		local r = registry.get(units[(start - 1 + i) % #units + 1])
		if r and r.mode == "receive" then list[#list + 1] = r end
	end
	return list, key
end
M.receivers_for = receivers_for

local function compare(value, comparator, constant)
	if comparator == ">" then return value > constant
	elseif comparator == "<" then return value < constant
	elseif comparator == "=" then return value == constant
	elseif comparator == "≥" then return value >= constant
	elseif comparator == "≤" then return value <= constant
	else return value ~= constant end
end

-- The circuit condition on the red and green wires together; no signal chosen = never.
function M.condition_met(rec)
	local cond = rec.cond
	if not (cond and cond.signal) then return false end
	local entity = rec.entity
	local value = 0
	for _, id in ipairs({defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green}) do
		local network = entity.get_circuit_network(id)
		if network then value = value + network.get_signal(cond.signal) end
	end
	return compare(value, cond.comparator or ">", cond.constant or 0)
end

-- Usable slots of a receiver: up to the red bar.
local function slot_limit(inv)
	local limit = #inv
	if inv.supports_bar() then limit = math.min(limit, inv.get_bar() - 1) end
	return limit
end

-- Moves as much of the source inventory as fits into one receiver; returns the item count moved.
local function fill(src, dst)
	local limit = slot_limit(dst)
	if limit < 1 then return 0 end
	-- Not yet full stacks of the receiver by item and quality (items with data never stack).
	local partial = {}
	for j = 1, limit do
		local d = dst[j]
		if d.valid_for_read and not d.item and d.count < d.prototype.stack_size then
			local key = d.name .. "|" .. d.quality.name
			partial[key] = partial[key] or {}
			table.insert(partial[key], j)
		end
	end
	local moved = 0
	for i = 1, #src do
		local s = src[i]
		if s.valid_for_read then
			local name, quality, has_data = s.name, s.quality.name, s.item ~= nil
			local key = name .. "|" .. quality
			local before = s.count
			local list = not has_data and partial[key]
			if list then
				for k = #list, 1, -1 do
					local d = dst[list[k]]
					d.transfer_stack(s)
					if not (d.valid_for_read and d.count < d.prototype.stack_size) then table.remove(list, k) end
					if not s.valid_for_read then break end
				end
			end
			while s.valid_for_read do
				local d, j = dst.find_empty_stack({name = name, quality = quality})
				if not d or not j or j > limit then break end
				local left = s.count
				d.transfer_stack(s)
				if s.valid_for_read and s.count >= left then break end -- nothing moved: never loop
				if not has_data and d.valid_for_read and d.count < d.prototype.stack_size then
					partial[key] = partial[key] or {}
					table.insert(partial[key], j)
				end
			end
			moved = moved + before - (s.valid_for_read and s.count or 0)
		end
	end
	return moved
end
M.fill = fill

local function flash(entity, tier, sound)
	if not (entity and entity.valid) then return end
	rendering.draw_animation{animation = tier.flash, target = entity, surface = entity.surface, time_to_live = 60,
		animation_speed = 1, render_layer = "higher-object-under"}
	rendering.draw_light{sprite = "utility/light_medium", target = entity, surface = entity.surface, scale = 3,
		intensity = 0.8, color = tier.glow, time_to_live = 45}
	entity.surface.play_sound{path = sound, position = entity.position}
end

-- One sender: decide the status; when everything is ready, teleport.
function M.process(rec)
	local entity = rec.entity
	local charger = registry.ensure_charger(rec)
	if not charger then
		set_status(rec, "no-power", DIODE.red, {"ptl-status.no-charger"})
		return
	end
	local tier = tiers.by_name[entity.name]
	if not rec.target then
		set_status(rec, "no-target", DIODE.red, {"ptl-status.no-target"})
		return
	end
	local surface = target_surface(rec)
	if surface and surface.index == entity.surface.index then
		set_status(rec, "same-planet", DIODE.red, {"ptl-status.same-planet"})
		return
	end
	local receivers, key = {}, nil
	if surface then receivers, key = receivers_for(rec, surface) end
	if #receivers == 0 then
		set_status(rec, "no-receiver", DIODE.red, {"ptl-status.no-receiver", planet_text(rec.target)})
		return
	end
	-- Receivers without power take nothing; the cargo goes to the powered ones of the channel.
	local powered = {}
	for _, r in ipairs(receivers) do
		if registry.powered(r) then powered[#powered + 1] = r end
	end
	if #powered == 0 then
		set_status(rec, "receivers-unpowered", DIODE.red, {"ptl-status.receivers-unpowered", planet_text(rec.target)})
		return
	end
	local inv = entity.get_inventory(CHEST)
	local charged = charger.energy >= tier.energy_j - 1
	if inv.is_empty() then
		set_status(rec, "empty", DIODE.yellow, charged and {"ptl-status.empty-charged"} or
			{"ptl-status.empty-charging", math.floor(charger.energy / tier.energy_j * 100)})
		return
	end
	if not charged then
		set_status(rec, "charging", DIODE.yellow, {"ptl-status.charging",
			math.floor(charger.energy / tier.energy_j * 100)})
		return
	end
	if rec.rule == "full" and inv.count_empty_stacks(true, false) > 0 then
		set_status(rec, "waiting-full", DIODE.yellow, {"ptl-status.waiting-full"})
		return
	end
	if rec.rule == "circuit" and not M.condition_met(rec) then
		set_status(rec, "waiting-signal", DIODE.yellow, {"ptl-status.waiting-signal"})
		return
	end
	local moved, hits = 0, {}
	for _, r in ipairs(powered) do
		local got = fill(inv, r.entity.get_inventory(CHEST))
		if got > 0 then
			moved = moved + got
			hits[#hits + 1] = r
			r.received = (r.received or 0) + got
		end
		if inv.is_empty() then break end
	end
	if moved == 0 then
		set_status(rec, "receivers-full", DIODE.red, {"ptl-status.receivers-full", planet_text(rec.target)})
		return
	end
	charger.energy = 0
	rec.sent = (rec.sent or 0) + moved
	rec.last_sent = game.tick
	rec.last_moved = moved
	storage.cursors[key] = hits[1].unit
	flash(entity, tier, "ptl-send")
	for _, r in ipairs(hits) do flash(r.entity, tiers.by_name[r.entity.name], "ptl-arrive") end
	set_status(rec, "sent", DIODE.green, {"ptl-status.sent", moved, planet_text(rec.target)})
end

-- Receivers and switched off teleporters only show what they do (a receiver also whether it has power).
function M.passive_status(rec)
	if rec.mode == "receive" then
		if registry.powered(rec) then
			set_status(rec, "receive", DIODE.green, {"ptl-status.receive"})
		else
			set_status(rec, "receive-unpowered", DIODE.red, {"ptl-status.receive-unpowered",
				tostring(tiers.by_name[rec.entity.name].receive_mw)})
		end
	elseif rec.mode == "off" then
		set_status(rec, "off", DIODE.yellow, {"ptl-status.off"})
	end
end

-- Every 10 ticks: every sender, then the power status of every receiver (written only when it changes).
function M.tick()
	for unit in pairs(storage.senders) do
		local rec = registry.get(unit)
		if rec then
			if rec.mode == "send" then M.process(rec) else storage.senders[unit] = nil end
		end
	end
	for _, set in pairs(storage.receivers) do
		for unit in pairs(set) do
			local rec = storage.units[unit]
			if rec and rec.entity and rec.entity.valid then M.passive_status(rec) end
		end
	end
end

return M
