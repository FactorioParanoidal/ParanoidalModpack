-- Pollution sensor consumes a snapshot once for both labels; mocks, not rendered Factorio GUI.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../value_sensors/?.lua;" .. package.path
EvoUi = nil
storage = {}
local surface = { index = 1, get_pollution = function() return 300 end }
local player = { index = 1, surface = surface, position = { x = 0, y = 0 } }
local other = { index = 2, surface = surface, position = { x = 0, y = 0 } }
game = { tick = 60, players = { player, other } }
local calls, logs = 0, 0
local sample = { schema_version = 1, availability = "ok", sample_tick = 50, surface_index = 1,
	chunk_x = 0, chunk_y = 0, pollution = 300, tolerance = 150, inhaled = 0, protected = true,
	armor = { resource = 500, max = 1000 }, intoxication = 12, rate = -5, description = { "", "details" } }
remote = { interfaces = { toxic_pollution = { get_player_status = true } }, call = function(_, _, index)
	calls = calls + 1
	if index == 2 then return { schema_version = 1, availability = "no_character" } end
	return sample
end }
log = function() logs = logs + 1 end
require("pollution_around_player")
local sensor = EvoUi.value_sensors[1]
local function owner(index)
	return { player_index = index, pollution_around_player = { style = {} } }
end
local a, b, c = owner(1), owner(1), owner(2)
sensor:update_ui(a)
sensor:update_ui(b)
assert(calls == 1 and a.pollution_around_player.tooltip and b.pollution_around_player.tooltip)
sensor:update_ui(c)
assert(calls == 2 and c.pollution_around_player.tooltip[1] == "sensor.pollution_around_player.no_character")
assert(a.pollution_around_player.tooltip[1] == "", "other player's tooltip not leaked")

game.tick = 120
player.position.x = 64
sensor:update_ui(a)
assert(a.pollution_around_player.tooltip[2][1] == "sensor.pollution_around_player.different")
game.tick = 180
sample.availability = "stale"
sensor:update_ui(a)
assert(a.pollution_around_player.tooltip[1] == "sensor.pollution_around_player.pending")
game.tick = 240
remote.interfaces = {}
sensor:update_ui(a)
assert(a.pollution_around_player.caption[1] == sensor.format_key and logs == 0)
game.tick = 300
remote.interfaces = { toxic_pollution = { get_player_status = true } }
remote.call = function() calls = calls + 1; error("provider failure") end
local before = calls
sensor:update_ui(a); sensor:update_ui(b)
assert(calls == before + 1 and logs == 1)
game.tick = 360
sensor:update_ui(a)
assert(logs == 1, "bounded error reporting")
print("EvoUi: OK (one remote call, context, unavailable fallback, no tooltip leakage)")
