-- control.lua wiring on mocks: event registration, the per-player loop, panel, alerts, death, commands.
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
		mod_settings = { ["tpr-hud"] = { value = "auto" }, ["tpr-sounds"] = { value = true },
			["tpr-auto-equip"] = { value = true }, ["tpr-respawn-respirator"] = { value = true } },
		force = { index = 1, technologies = {}, print = function(m) force_prints[#force_prints + 1] = m end },
	}
	p.print = function(m) prints[#prints + 1] = m end
	p.play_sound = function(spec) sounds[#sounds + 1] = spec.path end
	p.create_local_flying_text = function() end
	p.add_custom_alert = function(entity, icon, message) alerts[#alerts + 1] = { icon = icon.name, op = "add" } end
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
	"on_runtime_mod_setting_changed", "on_force_reset", "on_technology_effects_reset" }) do
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

-- Clean air: nothing shown --------------------------------------------------------------------------
pollution = 50
second()
assert(storage.players[6].x == 0)
assert(not player.gui.left.tpr_hud, "no panel in clean air (auto)")

-- Smog without protection: panel, alert, intoxication grows, damage after ~44 s at P=250 -----------
pollution = 250
second()
local hud = player.gui.left.tpr_hud
assert(hud and hud.visible, "panel shown in smog")
assert(alerts[#alerts].icon == "tpr-alert-smog" and alerts[#alerts].op == "add")
for _ = 1, 50 do second() end
assert(storage.players[6].x > 50 and player.character.health < 250, "damage after 50 s")
assert(sounds[1] == "utility/alert_destroyed", "alarm when the damage starts")
assert(alerts[#alerts].icon == "tpr-alert-danger" and alerts[#alerts - 1].op == "remove", "old alert removed")

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

-- Respirator in P=250 keeps the air tolerable (inhaled 125 < 150) ------------------------------------
pollution = 250
for _ = 1, 30 do second() end
assert(storage.players[6].x == 0, "protected: no intoxication")

-- Command and remote ----------------------------------------------------------------------------------
prints = {}
commands_registered.toxic({ player_index = 6, parameter = nil })
assert(#prints == 1 and prints[1][1] == "tpr-command.status")
commands_registered.toxic({ player_index = 6, parameter = "kills" })
assert(prints[2][1] == "tpr-command.kills-title")
interfaces.toxic_pollution.set_intoxication(6, 42)
assert(interfaces.toxic_pollution.get_intoxication(6) == 42)
local state = interfaces.toxic_pollution.get_state(6)
assert(state and math.abs(state.filtration - 0.5) < 1e-9)

-- Configuration change resets the panel ------------------------------------------------------------
handlers.config()
assert(storage.players[6].hud == nil)

print("control: OK")
