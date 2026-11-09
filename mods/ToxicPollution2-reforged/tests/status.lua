-- Status/zone regression on mocks. Exercises the real modules, not Factorio event delivery.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path
local handlers, nth, api, command = {}, {}, {}, nil
local ids, next_id = {}, 100
setmetatable(ids, { __index = function(t, key) next_id = next_id + 1; t[key] = next_id; return next_id end })
defines = { events = ids, inventory = { character_armor = 1, character_main = 2, character_trash = 3 },
	entity_status = { working = 1, no_power = 2 }, alert_type = { custom = 1 }, gui_type = { entity = 1 },
	target_type = { entity = 1 } }
settings = { startup = { ["tpr-tolerance"] = { value = 150 } } }
storage = { players = {}, levels = {}, kills = {} }
local pollution, reads, zone_queries = 50, 0, 0
local found = {}
local surface = { index = 1, name = "nauvis", valid = true, pollutant_type = { name = "pollution" },
	get_pollution = function() reads = reads + 1; return pollution end,
	find_entities_filtered = function(spec)
		assert(spec.limit == nil and spec.radius == 10)
		zone_queries = zone_queries + 1
		return found
	end }
prototypes = { item = {}, mod_data = {}, get_item_filtered = function() return {} end,
	get_entity_filtered = function()
		return { late_cleaner = { electric_energy_source_prototype = { emissions_per_joule = { pollution = -1 } } } }
	end }
local force = { index = 1, technologies = {}, print = function() end }
local armor = { [1] = { valid_for_read = false } }
local main = { get_contents = function() return {} end }
local character = { valid = true, unit_number = 10, type = "character", position = { x = 0, y = 0 },
	surface = surface, force = force, max_health = 250, health = 250,
	get_inventory = function(id) if id == 1 then return armor end end,
	get_main_inventory = function() return main end }
local player = { index = 6, name = "tester", character = character, surface = surface, position = { x = 0, y = 0 },
	force = force, gui = { left = {} }, mod_settings = { ["tpr-sounds"] = { value = false } },
	print = function() end, play_sound = function() end, add_custom_alert = function() end, remove_alert = function() end }
character.player = player
local players = { [6] = player }
game = { tick = 0, players = players, forces = { force }, connected_players = { player },
	get_player = function(index) return players[index] end }
log = function() end
serpent = { line = function() return "same alert" end }
script = { on_init = function(f) handlers.init = f end, on_configuration_changed = function(f) handlers.config = f end,
	on_nth_tick = function(n, f) nth[n] = f end,
	on_event = function(ids_or_id, f)
		if type(ids_or_id) == "table" then for _, id in pairs(ids_or_id) do handlers[id] = f end
		else handlers[ids_or_id] = f end
	end }
commands = { add_command = function(_, _, f) command = f end }
remote = { interfaces = {}, add_interface = function(name, methods) api[name] = methods end }
dofile(directory .. "../control.lua")
local remote_api = api.toxic_pollution
local Player = require("scripts.player")
local Zones = require("scripts.zones")

-- First-ever reads neither create player/force data nor simulate anything.
assert(remote_api.get_player_status(6).availability == "pending")
for _ = 1, 3 do assert(remote_api.get_state(6).intoxication == 0) end
assert(next(storage.players) == nil and next(storage.levels) == nil)
assert(character.health == 250 and zone_queries == 0)
Player.update(player)
local count = reads
local snapshot = remote_api.get_player_status(6)
assert(snapshot.availability == "ok" and snapshot.pollution == 50 and snapshot.sample_tick == 0)
assert(snapshot.intoxication == 0 and snapshot.description)
snapshot.pollution = -100
snapshot.description[1] = "modified by consumer"
assert(remote_api.get_player_status(6).pollution == 50)
assert(remote_api.get_player_status(6).description[1] == "")
assert(reads == count, "snapshot getter cannot re-evaluate pollution/protection/zone")

game.tick = 121
assert(remote_api.get_player_status(6).availability == "stale")
game.tick = 0
player.position = { x = 1000, y = 0 } -- camera must not invalidate the character's sample
assert(remote_api.get_player_status(6).availability == "ok")
character.position.x = 32
assert(remote_api.get_player_status(6).availability == "stale")
character.position.x = 0
local original = character.unit_number
character.unit_number = 11
assert(remote_api.get_player_status(6).availability == "stale")
character.unit_number = original
force.technologies["tpr-smog-protection-1"] = { researched = true }
assert(remote_api.get_player_status(6).availability == "stale")
force.technologies = {}

-- Equipment/inventory invalidation is not an extra simulation step; retry alone is reset.
storage.players[6].refill_retry = 600
local x = storage.players[6].x
handlers[ids.on_player_main_inventory_changed]({ player_index = 6 })
assert(storage.players[6].refill_retry == nil and storage.players[6].x == x)
assert(remote_api.get_player_status(6).availability == "pending" and reads == count)
Player.update(player)
handlers[ids.on_equipment_removed]({ grid = { entity_owner = character } })
assert(remote_api.get_player_status(6).availability == "pending")
Player.update(player)
remote_api.set_intoxication(6, 42)
assert(remote_api.get_player_status(6).availability == "pending")
assert(storage.players[6].x == 42)
player.character = nil
assert(remote_api.get_player_status(6).availability == "no_character")
player.character = character

-- Working ninth machine is found, while started/stalled candidates grant no zone.
for i = 1, 8 do found[i] = { status = defines.entity_status.no_power, is_crafting = function() return true end } end
found[9] = { status = defines.entity_status.working }
assert(Zones.near_clean_air(surface, character.position))
found[9] = nil
assert(not Zones.near_clean_air(surface, character.position))
local before = zone_queries
surface.pollutant_type = nil
assert(not Zones.near_clean_air(surface, character.position) and zone_queries == before)
surface.pollutant_type = { name = "pollution" }

-- Command is also read-only, including before the first update and without optional providers.
storage.players = {}
command({ player_index = 6 })
command({ player_index = 6, parameter = "air" })
assert(next(storage.players) == nil and next(storage.levels) == nil)
-- Configuration clears only derived samples, retaining intoxication; no legacy GUI is required.
remote_api.set_intoxication(6, 42)
Player.update(player)
local before_config = storage.players[6].x
handlers.config()
assert(storage.players[6].x == before_config and storage.players[6].sample == nil)
-- Two players retain independent slot phases/samples without extra updates on reads.
local second_player, second_character = {}, {}
for key, value in pairs(player) do second_player[key] = value end
for key, value in pairs(character) do second_character[key] = value end
second_player.index, second_player.name, second_player.character = 7, "tester2", second_character
second_character.unit_number, second_character.player = 11, second_player
players[7] = second_player
game.connected_players = { player, second_player }
game.tick = 60; Player.tick(60)
assert(remote_api.get_player_status(6).sample_tick == 60 and remote_api.get_player_status(7).availability == "pending")
game.tick = 70; Player.tick(70)
assert(remote_api.get_player_status(6).sample_tick == 60 and remote_api.get_player_status(7).sample_tick == 70)
print("status: OK (mock lifecycle, snapshot purity/context and ninth cleaner)")
