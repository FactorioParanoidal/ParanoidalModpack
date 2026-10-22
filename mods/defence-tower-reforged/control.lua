-- Defence Tower Reforged: the defence tower repairs friendly buildings with repair packs
-- (scripts/repair.lua, from Repair Turret by Klonan) and, after "Shield generation", protects the
-- turrets in the same square with an energy shield (scripts/shield.lua, from King's Turret Shields
-- by Kingdud). A mod has one handler per event, so the handlers of both sides are called from here.
local repair = require("scripts.repair")
local shield = require("scripts.shield")

repair.set_shield(shield.handles, shield.range_changed)
shield.set_hooks({
	range_of = repair.range_of,
	towers_at = repair.towers_at,
	force_changed = repair.shield_force_changed,
	turret_off = repair.turret_unshielded,
	turret_on = repair.turret_shielded,
	hot = repair.mark_hot,
})

-- The only place that registers handlers (a bench build may swap this line for a profiler).
local on_event = script.on_event

local TOWER = require("kts_shared").tower
local ENERGY = require("shared").energy

-- Shield storage and levels first (the repair side asks the shield which turrets it handles), then
-- the repair rebuild (zones), then the shield coverage of those zones.
local function rebuild_all()
	shield.init_storage()
	shield.compute_levels()
	repair.rebuild()
	shield.full_rescan()
end

local function on_moved(entity)
	repair.on_moved(entity)
	shield.on_moved(entity, game.tick)
end

local function register_dolly()
	local id = repair.dolly_event_id()
	if id then
		on_event(id, function(event)
			on_moved(event.moved_entity)
		end)
	end
end

script.on_init(function()
	rebuild_all()
	register_dolly()
end)

script.on_load(function()
	repair.on_load()
	shield.on_load()
	register_dolly()
end)

script.on_configuration_changed(rebuild_all)

-- Every non-ghost build: towers are registered, buildings inside tower squares are watched for
-- repair, turrets inside are covered by the shield.
local built_filter = {{filter = "ghost", invert = true}}
local function on_built(event)
	repair.on_built(event)
	shield.on_built(event)
end
local function on_script_built(event)
	repair.on_built(event)
	shield.on_script_built(event)
end
on_event(defines.events.on_built_entity, on_built, built_filter)
on_event(defines.events.on_robot_built_entity, on_built, built_filter)
on_event(defines.events.on_space_platform_built_entity, on_built, built_filter)
on_event(defines.events.script_raised_built, on_script_built, built_filter)
on_event(defines.events.script_raised_revive, on_script_built, built_filter)

local tower_filter = {{filter = "name", name = TOWER}}
for _, t in ipairs(require("kts_shared").turret_types) do
	tower_filter[#tower_filter + 1] = {filter = "type", type = t}
end
on_event(defines.events.script_raised_destroy, shield.on_script_destroy, tower_filter)
on_event(defines.events.script_raised_teleported, function(event)
	on_moved(event.entity)
end, tower_filter)

local clone_filter = {{filter = "type", type = "electric-energy-interface"}, {filter = "name", name = ENERGY}}
for _, f in ipairs(tower_filter) do
	clone_filter[#clone_filter + 1] = f
end
on_event(defines.events.on_entity_cloned, function(event)
	repair.on_cloned(event)
	shield.on_cloned(event)
end, clone_filter)

on_event(defines.events.on_object_destroyed, function(event)
	repair.on_object_destroyed(event)
	shield.on_object_destroyed(event)
end)

on_event(defines.events.on_tick, function(event)
	repair.on_tick(event)
	shield.on_tick(event)
end)

local function on_research(event)
	repair.on_research(event)
	shield.on_research(event)
end
on_event(defines.events.on_research_finished, on_research)
on_event(defines.events.on_research_reversed, on_research)

local function on_force_event(event)
	repair.on_force_event(event)
	shield.on_force_event(event)
end
on_event(defines.events.on_technology_effects_reset, on_force_event)
on_event(defines.events.on_force_reset, on_force_event)
on_event(defines.events.on_forces_merged, rebuild_all)
on_event(defines.events.on_force_created, shield.on_force_created)

on_event(defines.events.on_selected_entity_changed, repair.on_selected_entity_changed)
on_event(defines.events.on_player_removed, repair.on_player_removed)
on_event(defines.events.on_surface_deleted, repair.on_surface_deleted)

on_event(defines.events.on_entity_damaged, shield.on_lethal, shield.lethal_filter)
on_event(defines.events.on_player_selected_area, shield.on_player_selected_area)
on_event(defines.events.on_player_alt_selected_area, shield.on_player_alt_selected_area)
on_event(defines.events.on_runtime_mod_setting_changed, shield.on_runtime_mod_setting_changed)

---------------------------------------------------------------------------------------------------
-- Commands and the remote interface.
---------------------------------------------------------------------------------------------------
local function fmt(x)
	return string.format("%.1f", x)
end

commands.add_command("dtr-stats", {"kts.command-stats"}, function(command)
	local player = command.player_index and game.get_player(command.player_index)
	local force = player and player.force or game.forces.player
	local print = player and player.print or game.print
	local fi = force.index
	local lv, st = shield.force_info(fi)
	if not lv then
		print({"kts.stats-off", repair.count(fi), repair.range_of(fi)})
		return
	end
	local n_gens, n_turrets, energy = shield.counts(fi)
	local s = shield.stats()
	print({
		"kts.stats", fmt(st.hp), fmt(st.hps), fmt(st.drain / 1000), fmt(st.recharge / 1000), repair.range_of(fi),
		n_gens, n_turrets, fmt(energy / shield.J_PER_HP), lv.size, lv.rate, s.saved, s.repairs,
	})
end)

commands.add_command("dtr-rebuild", {"kts.command-rebuild"}, function(command)
	local player = command.player_index and game.get_player(command.player_index)
	if player and not player.admin then
		player.print({"kts.admin-only"})
		return
	end
	rebuild_all()
	local _, n_turrets = shield.counts(nil)
	game.print({"kts.rebuilt", repair.count(nil), n_turrets})
end)

remote.add_interface("defence-tower", {
	-- Shield counters since the map started, plus current counts.
	stats = function()
		local out = shield.stats()
		out.towers = repair.count(nil)
		out.shielded_towers, out.turrets = shield.counts(nil)
		return out
	end,
})
