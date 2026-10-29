-- Pollution sensor: the signal tpr-pollution put into a constant combinator gets the pollution of its
-- chunk once per second. Only slots that still hold the signal, in manual sections, are written;
-- a combinator without the signal is forgotten. 12 buckets, one every 5 ticks.
local C = require("shared.config")

local S = {}

S.INTERVAL = 5
S.BUCKETS = 12

function S.init()
	storage.sensors = storage.sensors or {}
	storage.sensor_buckets = storage.sensor_buckets or {}
	for bucket = 0, S.BUCKETS - 1 do
		storage.sensor_buckets[bucket] = storage.sensor_buckets[bucket] or {}
	end
	storage.sensor_next = storage.sensor_next or 0
end

local function is_ours(filter)
	local value = filter and filter.value
	return value ~= nil and value.type == "virtual" and value.name == C.SIGNAL
end

-- Positions {section, slot} of our signal in manual sections.
local function find_slots(entity)
	local behavior = entity.get_control_behavior()
	if not behavior then return {} end
	local slots = {}
	for section_index = 1, behavior.sections_count do
		local section = behavior.get_section(section_index)
		if section and section.is_manual then
			for slot = 1, section.filters_count do
				if is_ours(section.get_slot(slot)) then
					slots[#slots + 1] = { section_index, slot }
				end
			end
		end
	end
	return slots
end

local function forget(unit)
	local sensor = storage.sensors[unit]
	if sensor then
		storage.sensor_buckets[sensor.bucket][unit] = nil
		storage.sensors[unit] = nil
	end
end

local function write(entity, slots)
	local value = math.floor(entity.surface.get_pollution(entity.position))
	local behavior = entity.get_control_behavior()
	if not behavior then return false end
	for _, place in ipairs(slots) do
		local section = behavior.get_section(place[1])
		if not (section and section.is_manual) then return false end
		local filter = section.get_slot(place[2])
		if not is_ours(filter) then return false end
		if filter.min ~= value then
			section.set_slot(place[2], { value = filter.value, min = value })
		end
	end
	return true
end

-- (Re)registers a constant combinator after it was built, pasted, cloned or its GUI closed.
function S.check(entity)
	if not (entity and entity.valid and entity.type == "constant-combinator") then return end
	local unit = entity.unit_number
	if not unit then return end
	local slots = find_slots(entity)
	if #slots == 0 then
		forget(unit)
		return
	end
	local sensor = storage.sensors[unit]
	if sensor then
		sensor.slots = slots
	else
		local bucket = storage.sensor_next % S.BUCKETS
		storage.sensor_next = storage.sensor_next + 1
		storage.sensors[unit] = { entity = entity, slots = slots, bucket = bucket }
		storage.sensor_buckets[bucket][unit] = true
		script.register_on_object_destroyed(entity)
	end
	write(entity, slots)
end

function S.on_destroyed(unit)
	if unit then forget(unit) end
end

function S.tick(tick)
	local bucket = storage.sensor_buckets[math.floor(tick / S.INTERVAL) % S.BUCKETS]
	if not bucket or next(bucket) == nil then return end
	local sensors = storage.sensors
	for unit in pairs(bucket) do
		local sensor = sensors[unit]
		local entity = sensor and sensor.entity
		if not (entity and entity.valid) then
			forget(unit)
		else
			local behavior = entity.get_control_behavior()
			if behavior and behavior.enabled then
				if not write(entity, sensor.slots) then
					-- The signal was moved or removed outside of our events: look again.
					S.check(entity)
				end
			end
		end
	end
end

return S
