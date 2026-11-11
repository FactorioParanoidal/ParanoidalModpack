-- Registry of the teleporters: one record per teleporter (settings, charger, statistics) and the indexes the
-- sender pass needs (senders; receivers by force, surface and channel; positions for upgrades).
local tiers = require("shared.tiers")

local M = {}

local CHEST = defines.inventory.chest
M.MODES = {"send", "receive", "off"}
M.RULES = {"ready", "full", "circuit"}
M.COMPARATORS = {">", "<", "=", "≥", "≤", "≠"}
local MODE_SET, RULE_SET, COMPARATOR_SET = {}, {}, {}
for _, v in ipairs(M.MODES) do MODE_SET[v] = true end
for _, v in ipairs(M.RULES) do RULE_SET[v] = true end
for _, v in ipairs(M.COMPARATORS) do COMPARATOR_SET[v] = true end

function M.init_storage()
	storage.units = storage.units or {}        -- [unit_number] = record
	storage.senders = storage.senders or {}    -- [unit_number] = true
	storage.receivers = storage.receivers or {} -- [receiver key] = {[unit_number] = true}
	storage.positions = storage.positions or {} -- [position key] = unit_number
	storage.cursors = storage.cursors or {}    -- [receiver key] = unit number served last
	storage.pending = storage.pending or {}    -- [position key] = {tick, settings, energy, sent} (fast replace)
	storage.players = storage.players or {}    -- [player index] = panel state
end

function M.is_teleporter(name) return tiers.by_name[name] ~= nil end

function M.position_key(surface_index, position)
	return surface_index .. "|" .. position.x .. "|" .. position.y
end

-- Channel: a signal (any type and quality) or nil for the common channel.
function M.channel_key(channel)
	if not channel or not channel.name then return "" end
	return (channel.type or "item") .. "/" .. channel.name .. "/" .. (channel.quality or "normal")
end

function M.receiver_key(force_index, surface_index, channel)
	return force_index .. "|" .. surface_index .. "|" .. M.channel_key(channel)
end

local function signal_exists(signal)
	local kind = signal.type or "item"
	local list = ({item = prototypes.item, fluid = prototypes.fluid, virtual = prototypes.virtual_signal,
		entity = prototypes.entity, recipe = prototypes.recipe, ["space-location"] = prototypes.space_location,
		["asteroid-chunk"] = prototypes.asteroid_chunk, quality = prototypes.quality})[kind]
	if not list or not list[signal.name] then return false end
	return signal.quality == nil or prototypes.quality[signal.quality] ~= nil
end

-- A signal from a tag, a paste or a GUI element, or nil when it is not one or no longer exists.
function M.clean_signal(signal)
	if type(signal) ~= "table" or type(signal.name) ~= "string" then return nil end
	local clean = {type = type(signal.type) == "string" and signal.type or "item", name = signal.name,
		quality = type(signal.quality) == "string" and signal.quality or nil}
	if not signal_exists(clean) then return nil end
	return clean
end

function M.default_settings()
	return {mode = "receive", rule = "ready", cond = {comparator = ">", constant = 0}}
end

-- Settings as plain data (tags, copy-paste, remote): unknown or broken values fall back to the defaults.
function M.clean_settings(raw)
	local s = M.default_settings()
	if type(raw) ~= "table" then return s end
	if MODE_SET[raw.mode] then s.mode = raw.mode end
	if RULE_SET[raw.rule] then s.rule = raw.rule end
	s.channel = M.clean_signal(raw.channel)
	-- Only a planet (game.planets has it): a space location of another kind or a removed planet is no target.
	local location = type(raw.target) == "string" and prototypes.space_location[raw.target]
	if location and location.type == "planet" then s.target = raw.target end
	local cond = type(raw.cond) == "table" and raw.cond or {}
	s.cond = {
		signal = M.clean_signal(cond.signal),
		comparator = COMPARATOR_SET[cond.comparator] and cond.comparator or ">",
		constant = type(cond.constant) == "number" and math.floor(math.max(-2147483648, math.min(2147483647,
			cond.constant))) or 0,
	}
	return s
end

function M.settings_of(rec)
	return M.clean_settings({mode = rec.mode, rule = rec.rule, channel = rec.channel, target = rec.target,
		cond = rec.cond})
end

---------------------------------------------------------------------------------------------- indexes
local function unindex(rec)
	storage.senders[rec.unit] = nil
	if rec.rkey then
		local set = storage.receivers[rec.rkey]
		if set then
			set[rec.unit] = nil
			if next(set) == nil then
				storage.receivers[rec.rkey] = nil
				storage.cursors[rec.rkey] = nil
			end
		end
		rec.rkey = nil
	end
end

local function index(rec)
	unindex(rec)
	local entity = rec.entity
	if not (entity and entity.valid) then return end
	if rec.mode == "send" then
		storage.senders[rec.unit] = true
	elseif rec.mode == "receive" then
		local key = M.receiver_key(entity.force.index, entity.surface.index, rec.channel)
		storage.receivers[key] = storage.receivers[key] or {}
		storage.receivers[key][rec.unit] = true
		rec.rkey = key
	end
end
M.reindex = index

-- A sender keeps the charge of one send (charged at the tier's power); a receiver draws the tier's receive power all
-- the time (buffer of 4 ticks); a switched off teleporter draws nothing.
function M.update_charger(rec)
	local charger = rec.charger
	if not (charger and charger.valid) then return end
	local tier = tiers.by_name[rec.entity.name]
	local buffer, usage = 0, 0
	if rec.mode == "send" then
		buffer = tier.energy_j
	elseif rec.mode == "receive" then
		buffer, usage = tier.receive_buffer_j, tier.receive_tick_j
	end
	if charger.power_usage ~= usage then charger.power_usage = usage end
	if charger.electric_buffer_size ~= buffer then
		charger.electric_buffer_size = buffer
		if charger.energy > buffer then charger.energy = buffer end
	end
end

-- A receiver takes cargo only while the network supplies it: its buffer at least half full.
function M.powered(rec)
	local charger = rec.charger
	if not (rec.mode == "receive" and charger and charger.valid) then return false end
	local buffer = charger.electric_buffer_size
	return buffer > 0 and charger.energy >= buffer * 0.5
end

function M.ensure_charger(rec)
	local entity = rec.entity
	if rec.charger and rec.charger.valid then return rec.charger end
	local tier = tiers.by_name[entity.name]
	local found = entity.surface.find_entities_filtered{name = tier.charger, position = entity.position, limit = 1}[1]
	local charger = found or entity.surface.create_entity{name = tier.charger, position = entity.position,
		force = entity.force, create_build_effect_smoke = false}
	if charger then
		charger.destructible = false
		charger.minable_flag = false
		charger.operable = false
	end
	rec.charger = charger
	M.update_charger(rec)
	return charger
end

function M.apply_settings(rec, settings)
	local s = M.clean_settings(settings)
	rec.mode, rec.rule, rec.channel, rec.target, rec.cond = s.mode, s.rule, s.channel, s.target, s.cond
	rec.status = nil
	index(rec)
	M.update_charger(rec)
end

---------------------------------------------------------------------------------------------- add / remove
function M.add(entity, settings, carry)
	local unit = entity.unit_number
	local rec = storage.units[unit]
	if rec then
		rec.entity = entity
	else
		rec = {unit = unit, entity = entity, sent = 0}
		storage.units[unit] = rec
	end
	rec.surface_index = entity.surface.index
	rec.pos_key = M.position_key(rec.surface_index, entity.position)
	storage.positions[rec.pos_key] = unit
	script.register_on_object_destroyed(entity)
	M.ensure_charger(rec)
	M.apply_settings(rec, settings or (rec.mode and M.settings_of(rec)) or nil)
	if carry then
		rec.sent = carry.sent or rec.sent
		if carry.energy and rec.charger and rec.charger.valid then
			rec.charger.energy = math.min(carry.energy, rec.charger.electric_buffer_size)
		end
	end
	return rec
end

function M.remove(unit)
	local rec = storage.units[unit]
	if not rec then return end
	unindex(rec)
	if rec.charger and rec.charger.valid then rec.charger.destroy() end
	if rec.pos_key and storage.positions[rec.pos_key] == unit then storage.positions[rec.pos_key] = nil end
	storage.units[unit] = nil
end

-- Before a teleporter disappears (mined, upgraded, destroyed): its settings wait one tick at its position, so a
-- teleporter built there in the same tick (fast replace, upgrade) takes them over with the charge.
function M.stash(rec)
	if not rec or not rec.pos_key then return end
	storage.pending[rec.pos_key] = {tick = game.tick, settings = M.settings_of(rec), sent = rec.sent,
		energy = rec.charger and rec.charger.valid and rec.charger.energy or 0}
end

function M.take_pending(pos_key)
	local p = storage.pending[pos_key]
	storage.pending[pos_key] = nil
	if p and p.tick == game.tick then return p end
end

function M.purge_pending()
	for key, p in pairs(storage.pending) do
		if p.tick < game.tick then storage.pending[key] = nil end
	end
end

function M.get(unit)
	local rec = storage.units[unit]
	if rec and rec.entity and rec.entity.valid then return rec end
	if rec then M.remove(unit) end
end

---------------------------------------------------------------------------------------------- full rescan
-- New map, mod added to a save, any mod change: rebuild every record from the world.
function M.rescan()
	M.init_storage()
	local alive = {}
	for _, surface in pairs(game.surfaces) do
		for _, entity in ipairs(surface.find_entities_filtered{name = tiers.names}) do
			if entity.unit_number then
				local rec = storage.units[entity.unit_number]
				M.add(entity, rec and M.settings_of(rec) or nil)
				alive[entity.unit_number] = true
			end
		end
	end
	for unit in pairs(storage.units) do
		if not alive[unit] then M.remove(unit) end
	end
	-- Chargers without their teleporter (removed by another mod without an event).
	local owned = {}
	for _, rec in pairs(storage.units) do
		if rec.charger and rec.charger.valid then owned[rec.charger.unit_number or -1] = true end
	end
	for _, surface in pairs(game.surfaces) do
		for _, charger in ipairs(surface.find_entities_filtered{name = tiers.charger_names}) do
			if not owned[charger.unit_number or -1] then charger.destroy() end
		end
	end
	storage.senders, storage.receivers, storage.positions = {}, {}, {}
	for unit, rec in pairs(storage.units) do
		storage.positions[rec.pos_key] = unit
		rec.rkey = nil
		index(rec)
		M.update_charger(rec)
	end
	for key in pairs(storage.cursors) do
		if not storage.receivers[key] then storage.cursors[key] = nil end
	end
	storage.pending = {}
end

-- Forces merged or a surface deleted: records of dead entities go, the receiver index follows the forces.
function M.validate()
	for unit, rec in pairs(storage.units) do
		if not (rec.entity and rec.entity.valid) then M.remove(unit) end
	end
	storage.receivers, storage.senders = {}, {}
	for _, rec in pairs(storage.units) do
		rec.rkey = nil
		index(rec)
	end
end

function M.inventory(rec) return rec.entity.get_inventory(CHEST) end

return M
