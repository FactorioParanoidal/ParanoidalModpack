-- control.lua wiring on mocks: event registration, the per-player loop, alerts, death, commands.
-- Not Factorio: checks that the modules fit together and react as specified.
local directory = assert(arg[0]:match("^(.*[/\\])"))
package.path = directory .. "../?.lua;" .. package.path

local handlers, nth, commands_registered, interfaces = {}, {}, {}, {}
local next_id = 1000
local events = setmetatable({}, { __index = function(t, name)
	next_id = next_id + 1
	rawset(t, name, next_id)
	return next_id
end })

defines = {
	events = events,
	inventory = { character_armor = 1, character_main = 2, character_trash = 3 },
	entity_status = { working = 1 },
	alert_type = { custom = 7 },
	gui_type = { entity = 1 },
	target_type = { entity = 3 },
}
settings = { startup = { ["tpr-tolerance"] = { value = 150 } } }
storage = {}
script = {
	on_init = function(f) handlers.init = f end,
	on_load = function(f) handlers.load = f end,
	on_configuration_changed = function(f) handlers.config = f end,
	on_nth_tick = function(n, f) nth[n] = f end,
	on_event = function(id, f, filters)
		if type(id) == "table" then
			assert(filters == nil, "filters with an array of events")
			for _, single in ipairs(id) do handlers[single] = f end
		else
			handlers[id] = f
		end
	end,
	register_on_object_destroyed = function() end,
}
commands = { add_command = function(name, help, f) commands_registered[name] = f end }
remote = { add_interface = function(name, functions) interfaces[name] = functions end }

prototypes = {
	item = {
		["respirator"] = { type = "armor", localised_name = "respirator", resistances = { toxin = { percent = 0.5 } },
			get_durability = function() return 600 end },
		["CW-air-filter"] = { type = "item" }, ["CW-used-air-filter"] = { type = "item" },
	},
	mod_data = { ["tpr-clean-air"] = { data = { names = { "angels-air-filter" } } } },
}
prototypes.get_item_filtered = function() return { respirator = prototypes.item.respirator } end
local logged = {}
log = function(message) logged[#logged + 1] = message end
-- serpent.line stub: a stable string of a localised-string tree (enough for change detection)
local function flat(value)
	if type(value) ~= "table" then return tostring(value) end
	local parts = {}
	for _, v in ipairs(value) do parts[#parts + 1] = flat(v) end
	return "{" .. table.concat(parts, ",") .. "}"
end
serpent = { line = flat }

-- GUI mock ------------------------------------------------------------------------------------------
local element_index = 0
local function element(spec)
	element_index = element_index + 1
	local e = { valid = true, index = element_index, children = {}, visible = true, style = {} }
	for k, v in pairs(spec or {}) do e[k] = v end
	function e.add(child_spec)
		local child = element(child_spec)
		e.children[#e.children + 1] = child
		if child_spec.name then e[child_spec.name] = child end
		return child
	end
	function e.destroy() e.valid = false end
	return e
end

local alerts, prints, sounds, force_prints = {}, {}, {}, {}
local function make_player(index)
	local p = {
		index = index, name = "P" .. index, connected = true,
		gui = { left = element() },
		mod_settings = { ["tpr-sounds"] = { value = true },
			["tpr-auto-equip"] = { value = true }, ["tpr-respawn-respirator"] = { value = true } },
		force = { index = 1, technologies = {}, print = function(m) force_prints[#force_prints + 1] = m end },
	}
	p.print = function(m) prints[#prints + 1] = m end
	p.play_sound = function(spec) sounds[#sounds + 1] = spec.path end
	p.create_local_flying_text = function() end
	p.add_custom_alert = function(entity, icon, message)
		alerts[#alerts + 1] = { icon = icon.name, op = "add", message = message, text = flat(message) }
	end
	p.remove_alert = function(filter) alerts[#alerts + 1] = { icon = filter.icon.name, op = "remove" } end
	p.get_alerts = function() return {} end
	return p
end

local pollution = 0
local function make_character(player)
	local armor = { [1] = { valid_for_read = false } }
	local main = { items = {} }
	setmetatable(main, { __len = function() return 0 end })
	main.get_contents = function() return {} end
	main.insert = function(spec) main.items[spec.name] = (main.items[spec.name] or 0) + spec.count return spec.count end
	armor.insert = function(spec)
		armor[1] = { valid_for_read = true, name = spec.name, type = "armor", quality = { name = "normal" }, durability = 600 }
		return 1
	end
	local c = {
		valid = true, max_health = 250, health = 250, position = { x = 0, y = 0 }, force = player.force, player = player,
		surface = { get_pollution = function() return pollution end, find_entities_filtered = function() return {} end },
		get_inventory = function(id) if id == 1 then return armor end if id == 2 then return main end end,
		get_main_inventory = function() return main end,
	}
	c.damage = function(amount, force, damage_type)
		assert(force == "neutral" and damage_type == "tpr-intoxication", "damage type")
		c.health = c.health - amount
		if c.health <= 0 then c.valid = false player.character = nil end
		return amount
	end
	return c
end

local player = make_player(6) -- index 6 → slot 0
game = {
	tick = 0, players = { [6] = player }, connected_players = { player }, forces = { player = player.force },
	get_player = function(index) return game.players[index] end,
}
player.character = make_character(player)

dofile(directory .. "../control.lua")

-- Registration --------------------------------------------------------------------------------------
assert(handlers.init and handlers.config and nth[10] and nth[5], "lifecycle and nth ticks")
assert(commands_registered.toxic and interfaces.toxic_pollution, "command and remote")
for _, name in ipairs({ "on_research_finished", "on_research_reversed", "on_player_died", "on_player_respawned",
	"on_entity_damaged", "on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive",
	"on_entity_cloned", "on_entity_settings_pasted", "on_gui_closed", "on_object_destroyed", "on_player_removed",
	"on_force_reset", "on_technology_effects_reset", "on_player_changed_surface" }) do
	assert(handlers[events[name]], "handler " .. name)
end

handlers.init()
assert(storage.players and storage.levels[1] == 0 and storage.sensor_buckets[11])
assert(logged[1] and logged[1]:find("respirator 50%%/600", 1, false), tostring(logged[1]))

local function second()
	for t = 0, 50, 10 do
		game.tick = game.tick + 10
		nth[10]({ tick = game.tick - (game.tick % 60) + t })
	end
end

local function last_add()
	for index = #alerts, 1, -1 do
		if alerts[index].op == "add" then return alerts[index] end
	end
end
local function count_adds(icon)
	local n = 0
	for _, a in ipairs(alerts) do if a.op == "add" and (not icon or a.icon == icon) then n = n + 1 end end
	return n
end

-- Clean air: nothing shown --------------------------------------------------------------------------
pollution = 50
second()
assert(storage.players[6].x == 0)
assert(#alerts == 0, "no alert in clean air")

-- Smog without protection: one smog alert with the full status, gone after ~10 s -------------------
pollution = 250
second()
local a = last_add()
assert(a and a.icon == "tpr-alert-smog", "alert on entering the smog")
assert(a.text:find("tpr-alert.smog,250", 1, true), a.text)
assert(a.text:find("tpr-status.intoxication", 1, true) and a.text:find("tpr-status.no-armor", 1, true)
	and a.text:find("tpr-status.rising", 1, true), "status lines in the alert: " .. a.text)
assert(sounds[1] == "utility/console_message", "sound on the new alert")
for _ = 1, 11 do second() end
assert(alerts[#alerts].op == "remove" and storage.players[6].alert == nil, "the alert expires")
local adds = count_adds()
for _ = 1, 10 do second() end
assert(count_adds() == adds, "steady smog: no new alert")

-- Sharp change: the smog twice as harmful (excess 100 → 450) — but within the 30 s cooldown nothing;
-- after the cooldown a "thicker" alert
pollution = 600
second()
assert(count_adds() == adds, "cooldown")
for _ = 1, 10 do second() end
assert(count_adds("tpr-alert-smog") > 1 or count_adds("tpr-alert-danger") > 0, "sharp change noticed")

-- Damage: the danger alert stays while the damage lasts -----------------------------------------------
pollution = 250
storage.players[6].x = 60
second()
assert(player.character.health < 250, "damage")
assert(last_add().icon == "tpr-alert-danger", "danger alert")
local found_sound = false
for _, path in ipairs(sounds) do if path == "utility/alert_destroyed" then found_sound = true end end
assert(found_sound, "alarm when the damage starts")
for _ = 1, 12 do second() end
assert(storage.players[6].alert == "danger", "danger alert stays while damaged")

-- Leave the smog: damage stops at once ----------------------------------------------------------------
pollution = 100
local health = player.character.health
second()
assert(player.character.health == health, "no damage after leaving")
local x_before = storage.players[6].x
second()
assert(storage.players[6].x < x_before, "intoxication falls")

-- Death by smog: kill counter, force message, reset ------------------------------------------------
pollution = 5000
storage.players[6].x = 100
player.character.health = 10
second()
assert(player.character == nil and storage.kills[6] == 1 and #force_prints == 1, "killed by smog")
handlers[events.on_player_died]({ player_index = 6 })
assert(storage.players[6].x == 0)

-- Respawn with the respirator setting ---------------------------------------------------------------
player.character = make_character(player)
handlers[events.on_player_respawned]({ player_index = 6 })
assert(player.character.get_inventory(1)[1].name == "respirator", "respirator in the armor slot")

-- A worn respirator takes the hit: no intoxication, the resource wears (250-150)*(1-0.5)/100 per second
pollution = 250
alerts = {}
storage.players[6].x = 30
second()
assert(last_add().text:find("tpr-alert.smog-protected", 1, true), "protected entering alert")
assert(last_add().text:find("tpr-status.armor", 1, true) and last_add().text:find("tpr-status.lasts", 1, true))
for _ = 1, 29 do second() end
local worn = player.character.get_inventory(1)[1]
assert(storage.players[6].x == 0, "protected: intoxication falls to zero")
assert(math.abs(worn.durability - (600 - 30 * 0.5)) < 1e-6, "resource worn: " .. worn.durability)
assert(player.character.health == 250, "no damage in protection")

-- Resource marks: below 25 % → a filters alert ---------------------------------------------------------
worn.durability = 140
second()
assert(last_add().icon == "tpr-alert-filters" and last_add().text:find("tpr-alert.low", 1, true), "low resource alert")

-- Command and remote ----------------------------------------------------------------------------------
prints = {}
commands_registered.toxic({ player_index = 6, parameter = nil })
assert(#prints == 1 and prints[1][2][1] == "tpr-command.status" and flat(prints[1]):find("tpr-status.armor", 1, true))
commands_registered.toxic({ player_index = 6, parameter = "kills" })
assert(prints[2][1] == "tpr-command.kills-title")
interfaces.toxic_pollution.set_intoxication(6, 42)
assert(interfaces.toxic_pollution.get_intoxication(6) == 42)
local state = interfaces.toxic_pollution.get_state(6)
assert(state and state.protected and state.inhaled == 0 and state.filtration == 0)

-- Configuration change removes a panel left by a 9.0.0 test build -----------------------------------
local old_panel = player.gui.left.add({ type = "frame", name = "tpr_hud" })
storage.players[6].hud = {}
handlers.config()
assert(not old_panel.valid and storage.players[6].hud == nil)

print("control: OK")
