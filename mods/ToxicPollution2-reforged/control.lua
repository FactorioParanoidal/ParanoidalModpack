local Player = require("scripts.player")
local Research = require("scripts.research")
local Sensor = require("scripts.sensor")
local Hud = require("scripts.hud")
local Alerts = require("scripts.alerts")
local Interface = require("scripts.interface")
local Protection = require("scripts.protection")

local function init_storage()
	storage.players = storage.players or {}
	storage.levels = storage.levels or {}
	storage.kills = storage.kills or {}
	Sensor.init()
end

-- One log line with the final armor filtration (after every data stage), for diagnostics.
local function log_filtration()
	local parts = {}
	for name, prototype in pairs(prototypes.get_item_filtered({ { filter = "type", type = "armor" } })) do
		local share = Protection.armor_share(name)
		if share > 0 then
			parts[#parts + 1] = name .. " " .. math.floor(share * 100 + 0.5) .. "%/" .. (prototype.get_durability() or 0)
		end
	end
	table.sort(parts)
	log("ToxicPollution2-reforged: final armor filtration/resource: " .. table.concat(parts, ", "))
end

script.on_init(function()
	init_storage()
	Research.compute_all()
	log_filtration()
end)

script.on_configuration_changed(function()
	init_storage()
	Research.compute_all()
	log_filtration()
	-- The panel layout may differ between versions: rebuild it on the next update.
	Hud.reset_all()
end)

Interface.register()

script.on_nth_tick(Player.INTERVAL, function(event)
	Player.tick(event.tick)
end)

script.on_nth_tick(Sensor.INTERVAL, function(event)
	Sensor.tick(event.tick)
end)

-- Research level of the smog protection chain.
local function research_changed(event)
	if Research.is_ours(event.research.name) then
		Research.compute(event.research.force)
	end
end
script.on_event(defines.events.on_research_finished, research_changed)
script.on_event(defines.events.on_research_reversed, research_changed)
script.on_event({ defines.events.on_force_reset, defines.events.on_technology_effects_reset }, function(event)
	Research.compute(event.force)
end)
script.on_event({ defines.events.on_forces_merged, defines.events.on_force_created }, function()
	Research.compute_all()
end)

-- Players.
script.on_event(defines.events.on_player_died, function(event)
	local player = game.get_player(event.player_index)
	if player then Player.on_died(player) end
end)
script.on_event(defines.events.on_player_respawned, function(event)
	local player = game.get_player(event.player_index)
	if player then Player.on_respawned(player) end
end)
script.on_event(defines.events.on_player_removed, function(event)
	storage.players[event.player_index] = nil
	storage.kills[event.player_index] = nil
end)
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting ~= "tpr-hud" or not event.player_index then return end
	local player = game.get_player(event.player_index)
	if player then
		local data = Player.data(player.index)
		Hud.destroy(player, data)
		if player.character and player.character.valid then
			Player.update(player)
		end
	end
end)
script.on_event(defines.events.on_player_changed_surface, function(event)
	local player = game.get_player(event.player_index)
	if player then Alerts.clear(player, Player.data(player.index)) end
end)

-- Poison clouds on a character wearing a mask.
script.on_event(defines.events.on_entity_damaged, Player.on_poison,
	{ { filter = "type", type = "character" }, { mode = "and", filter = "damage-type", type = "poison" } })

-- Pollution sensor in constant combinators. Filtered events are registered one at a time.
local combinator = { { filter = "type", type = "constant-combinator" } }
for _, id in ipairs({
	defines.events.on_built_entity,
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
}) do
	script.on_event(id, function(event)
		Sensor.check(event.entity)
	end, combinator)
end
script.on_event(defines.events.on_entity_cloned, function(event)
	Sensor.check(event.destination)
end, combinator)
script.on_event(defines.events.on_entity_settings_pasted, function(event)
	Sensor.check(event.destination)
end)
script.on_event(defines.events.on_gui_closed, function(event)
	if event.gui_type == defines.gui_type.entity and event.entity then
		Sensor.check(event.entity)
	end
end)
script.on_event(defines.events.on_object_destroyed, function(event)
	if event.type == defines.target_type.entity then
		Sensor.on_destroyed(event.useful_id)
	end
end)
