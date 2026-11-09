-- Chunk lifecycle and status API on mocks, not Factorio event delivery/native circuit evaluation.
local directory = assert(arg[0]:match("^(.*[/\\])"))
local handlers, nth, api, next_id = {}, {}, {}, 100
local events = setmetatable({}, { __index = function(t, key) next_id = next_id + 1; t[key] = next_id; return next_id end })
defines = { events = events, entity_status_diode = { yellow = 1 }, target_type = { entity = 1 } }
storage = {}
local query_count, registrations = 0, 0
local pollution = { [0] = 20, [1] = 5, [2] = 20 }
local surface = { index = 1, valid = true, pollutant_type = { name = "pollution" },
	get_pollution = function(pos) query_count = query_count + 1; return pollution[math.floor(pos.x / 32)] or 0 end,
	find_entities_filtered = function() return {} end }
game = { tick = 0, forces = { neutral = { index = 3 } }, surfaces = { surface } }
script = { on_init = function(f) handlers.init = f end, on_load = function(f) handlers.load = f end,
	on_configuration_changed = function(f) handlers.config = f end, on_nth_tick = function(n, f) nth[n] = f end,
	on_event = function(id, f) handlers[id] = f end,
	register_on_object_destroyed = function() registrations = registrations + 1 end }
local ruins_id = 901
remote = { interfaces = { AbandonedRuins = { get_on_entity_force_changed_event = true } },
	call = function() return ruins_id end,
	add_interface = function(name, methods) api[name] = methods end }
dofile(directory .. "../control.lua")
handlers.init()
local get = api["carbon-capture2"].get_machine_status
local function machine(unit, x)
	return { unit_number = unit, name = "CW-air-filter-machine-1", force_index = 1, surface_index = 1,
		surface = surface, position = { x = x, y = 0 }, valid = true, status = 7 }
end
local a, b = machine(1, 1), machine(2, 65)
handlers[events.on_built_entity]({ entity = a })
assert(get(1).script_gate_enabled and not a.disabled_by_script and registrations == 1)
local before = query_count
for _ = 1, 4 do assert(get(1).pollution == 20 and get(1).entity_status == 7) end
assert(query_count == before)
local detached = get(1); detached.script_gate_enabled = false
assert(get(1).script_gate_enabled)

-- New destination uses placement threshold, not source's running gate.
a.position.x = 33
handlers[events.script_raised_teleported]({ entity = a })
assert(not get(1).script_gate_enabled and a.disabled_by_script and get(1).chunk_x == 1)
assert(#storage.cc.list == 1 and registrations == 1 and query_count == before + 1)
handlers[events.on_built_entity]({ entity = a })
assert(registrations == 1, "duplicate build is idempotent")

-- Existing destination retains its own running gate in the hysteresis band.
handlers[events.on_entity_cloned]({ destination = b })
pollution[2] = 5
a.position.x = 65
before = query_count
handlers[events.script_raised_teleported]({ entity = a })
assert(get(1).script_gate_enabled and get(2).script_gate_enabled and #storage.cc.list == 1)
assert(registrations == 2 and query_count == before + 1)

pollution[2] = 1; game.tick = 10; nth[10]()
assert(not get(1).script_gate_enabled and not get(2).script_gate_enabled)
pollution[2] = 10; game.tick = 20; nth[10]()
assert(not get(1).script_gate_enabled)
pollution[2] = 11; game.tick = 30; nth[10]()
assert(get(1).script_gate_enabled and get(1).sample_tick == 30)
game.tick = 151
assert(get(1).availability == "stale")
game.tick = 30
-- Unraised moves cannot be repaired by a getter; they are reported stale.
a.position.x = 1
before = query_count
assert(get(1).availability == "stale" and query_count == before)
a.position.x = 65
handlers[events.on_object_destroyed]({ type = 1, useful_id = 1 })
assert(get(1).availability == "untracked" and get(2).availability == "ok")
handlers[events.on_object_destroyed]({ type = 1, useful_id = 2 })
assert(#storage.cc.list == 0 and nth[10] == nil)

-- Subscription reconciliation, and load registration without persistent writes.
assert(handlers[901])
ruins_id = 902
handlers.config()
assert(handlers[901] == nil and handlers[902] and storage.cc.ruins_event == 902)
local state = storage.cc
handlers.load()
assert(storage.cc == state and storage.cc.ruins_event == 902)
remote.interfaces.AbandonedRuins = nil
handlers.config()
assert(handlers[902] == nil and storage.cc.ruins_event == nil)
print("carbon-capture2: OK (mock registry, hysteresis, pure getter, subscription)")
