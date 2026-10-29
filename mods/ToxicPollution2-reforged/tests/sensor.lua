-- Pollution sensor on mock constant combinators: writes only its own slots, forgets combinators
-- without the signal, survives removed sections and destroyed entities. Not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path

storage = {}
local registered = {}
script = { register_on_object_destroyed = function(entity) registered[#registered + 1] = entity end }

local S = require("scripts.sensor")
S.init()

local OURS = { type = "virtual", name = "tpr-pollution", quality = "normal" }
local OTHER = { type = "virtual", name = "signal-A", quality = "normal" }

local function section(filters, manual)
	local s = { is_manual = manual ~= false, filters = filters, writes = 0 }
	s.filters_count = #filters
	function s.get_slot(index) return s.filters[index] end
	function s.set_slot(index, filter)
		s.writes = s.writes + 1
		s.filters[index] = { value = filter.value, min = filter.min }
	end
	return s
end

local function combinator(unit, sections, pollution)
	local behavior = { enabled = true, sections = sections }
	behavior.sections_count = #sections
	function behavior.get_section(index) return behavior.sections[index] end
	return {
		valid = true, type = "constant-combinator", unit_number = unit, position = { x = 0, y = 0 },
		surface = { get_pollution = function() return pollution end },
		get_control_behavior = function() return behavior end,
		behavior = behavior,
	}
end

-- Ordinary combinator: not registered -------------------------------------------------------------
local plain = combinator(1, { section({ { value = OTHER, min = 5 } }) }, 300)
S.check(plain)
assert(storage.sensors[1] == nil and #registered == 0)

-- Two signals in two sections; other slots untouched -----------------------------------------------
local first = section({ { value = OTHER, min = 7 }, { value = OURS, min = 0 } })
local second = section({ { value = OURS, min = 0 } })
local logistic = section({ { value = OURS, min = 0 } }, false) -- not manual: never written
local sensor = combinator(2, { first, second, logistic }, 412.7)
S.check(sensor)
assert(storage.sensors[2] and #storage.sensors[2].slots == 2 and #registered == 1)
assert(first.filters[2].min == 412 and second.filters[1].min == 412, "written on registration")
assert(first.filters[1].min == 7 and first.filters[1].value == OTHER, "foreign slot untouched")
assert(logistic.filters[1].min == 0, "non-manual section untouched")

-- Unchanged value is not rewritten ------------------------------------------------------------------
local bucket = storage.sensors[2].bucket
local tick = bucket * S.INTERVAL
local writes = first.writes
S.tick(tick)
assert(first.writes == writes, "no write without a change")

-- The player replaced our signal by another one: the slot is NOT overwritten (old bug: hijack) -------
first.filters[2] = { value = OTHER, min = 99 }
S.tick(tick)
assert(first.filters[2].value == OTHER and first.filters[2].min == 99, "foreign signal kept")
assert(#storage.sensors[2].slots == 1, "rescanned: one slot left")

-- All signals removed: forgotten --------------------------------------------------------------------
second.filters[1] = { value = OTHER, min = 1 }
S.tick(tick)
assert(storage.sensors[2] == nil and storage.sensor_buckets[bucket][2] == nil, "forgotten")

-- Section deleted: rescan instead of writing into a shifted section ---------------------------------
local a = section({ { value = OURS, min = 0 } })
local b = section({ { value = OTHER, min = 3 } })
local c3 = combinator(3, { a, b }, 50)
S.check(c3)
c3.behavior.sections = { b }
c3.behavior.sections_count = 1
S.tick(storage.sensors[3].bucket * S.INTERVAL)
assert(b.filters[1].value == OTHER and b.filters[1].min == 3, "the shifted section is not written")
assert(storage.sensors[3] == nil)

-- Destroyed entity ----------------------------------------------------------------------------------
local d = combinator(4, { section({ { value = OURS, min = 0 } }) }, 10)
S.check(d)
S.on_destroyed(4)
assert(storage.sensors[4] == nil)
local e = combinator(5, { section({ { value = OURS, min = 0 } }) }, 10)
S.check(e)
e.valid = false
S.tick(storage.sensors[5].bucket * S.INTERVAL)
assert(storage.sensors[5] == nil, "invalid entity dropped")

-- Buckets spread the sensors: each tick touches one bucket only ------------------------------------
for unit = 10, 33 do
	S.check(combinator(unit, { section({ { value = OURS, min = 0 } }) }, unit))
end
local counts = {}
for b2 = 0, S.BUCKETS - 1 do
	local n = 0
	for _ in pairs(storage.sensor_buckets[b2]) do n = n + 1 end
	counts[#counts + 1] = n
end
for _, n in ipairs(counts) do assert(n == 2, "24 sensors over 12 buckets: " .. table.concat(counts, ",")) end

print("sensor: OK")
