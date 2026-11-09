local rro = require("lib.remove-replace-object")
PlanetsLib = {}
PlanetsLib.events = require("scripts.custom-events")
PlanetsLib.constants = prototypes.mod_data.Planetslib.data
PlanetsLib.objects = require("lib.remove-replace-object")
PlanetsLib.stage = "runtime"
PlanetsLib.event_handler = require("__PlanetsLib__.lib.event-handler.event-handler")
PlanetsLib.composite_events = require("__PlanetsLib__.lib.event-handler.composite-events")
local library = require("__PlanetsLib__.lib.lib")
local rocket_parts = require("scripts.rocket-parts")
local unreachable_techs = require("scripts.unreachable-techs")
local entity_replacement = require("scripts.entity-replacement")
require("lib.authors")
require("scripts.player-effects")
local entity_removal_floors = require("scripts.entity-removal-floors")
-- By convention, please register event handlers in this file rather than the scripts directory, to help avoid collisions

local cargo_pods
if script.active_mods["space-age"] then
	cargo_pods = require("scripts.cargo-pods")
end
local is_cargo_pods = cargo_pods ~= nil
if cargo_pods then
	-- script.on_event(
	-- 	defines.events.on_built_entity,
	-- 	rocket_parts.on_built_rocket_silo,
	-- 	{ { filter = "type", type = "rocket-silo" }, { filter = "ghost_type", type = "rocket-silo" } }
	-- )

	script.on_event(defines.events.on_cargo_pod_started_ascending, cargo_pods.on_cargo_pod_started_ascending)

	
end

local function warn_on_join_if_due()
	local setting = settings.startup["PlanetsLib-warn-on-hidden-prerequisites"]
	if not unreachable_techs.should_warn_on_join(game.tick, setting and setting.value) then
		return false
	end
	unreachable_techs.warn_unreachable_techs()
	return true
end

if settings.startup["PlanetsLib-warn-on-hidden-prerequisites"].value then
	script.on_event(defines.events.on_player_joined_game, warn_on_join_if_due)
end

local function init_storage()
	if not storage.entity_info then storage.entity_info = {} end --Stores info about each entity to speed up recipe effects
end

PlanetsLib.event_handler.add_lib{on_init = function()
	if cargo_pods then
		cargo_pods.init_storage()
	end
	init_storage()
	entity_removal_floors.on_init()
		storage.old_replacement_rules = PlanetsLib.constants.on_entity_placed_on_planet_replacements
end}

local function entity_prototype_exists(name)
	return type(name) == "string" and prototypes.entity[name] ~= nil
end

local function replace_entity(surface,old_entity,new_entity)
	if not surface then return end

	-- Migration snapshots in storage.old_replacement_rules outlive prototype
	-- changes, so a rule can name an entity that a mod update removed (for
	-- example a generated "<entity>-PlanetsLib-<planet>" variant).
	-- find_entities_filtered raises "Unknown entity name" for such names, which
	-- would crash on_configuration_changed and leave the save unloadable.
	if not entity_prototype_exists(old_entity) or not entity_prototype_exists(new_entity) then
		log("[PlanetsLib] Skipping entity migration from '"..tostring(old_entity).."' to '"
			..tostring(new_entity).."': the prototype no longer exists.")
		return
	end

	local entities = surface.find_entities_filtered{name = old_entity}
	local entity_ghosts = surface.find_entities_filtered{name = "entity-ghost",ghost_name = old_entity}

	for _,entities in pairs({entities,entity_ghosts}) do
		if not rro.deep_equals(entities,{}) then
			game.print({"planetslib.planetslib-entity-migration",old_entity,new_entity})
		end
		for _,entity in pairs(entities) do
			entity_replacement.replace_entity(entity,new_entity,false)
		end
	end
end

local function entity_replacements_disabled_by_setting()
	local setting = settings.startup["PlanetsLib-disable-all-entity-replacements"]
	return setting and setting.value == true
end

local function migrate_surface(planet_name,surface,planet_rules,replacement_rules)
	storage.old_replacement_rules[planet_name] = storage.old_replacement_rules[planet_name] or {}
	local old_planet_rules = storage.old_replacement_rules[planet_name]
	local replacements_disabled = entity_replacements_disabled_by_setting()

	-- Iterate the union of old and new rules. A rule that was removed entirely
	-- between saves is absent from the new table, so iterating only
	-- `planet_rules` would leave its entities replaced forever.
	local entity_names = {}
	for entity_name in pairs(planet_rules or {}) do
		entity_names[entity_name] = true
	end
	for entity_name in pairs(old_planet_rules) do
		entity_names[entity_name] = true
	end

	for entity_name in pairs(entity_names) do
		local new_rule = planet_rules and planet_rules[entity_name]
		local old_rule = old_planet_rules[entity_name]

		if old_rule and new_rule then
			if new_rule.enabled ~= old_rule.enabled or new_rule.entity ~= old_rule.entity then
				game.print({"planetslib.planetslib-entity-replacement-rule-changed"})
				if not replacements_disabled then
					if new_rule.enabled == false then
						--Revert changes previously made. Search for old_rule.entity and new_rule.entity and replace both with new_rule.old_entity
						replace_entity(surface,old_rule.entity,new_rule.old_entity)
						replace_entity(surface,new_rule.entity,new_rule.old_entity)
					elseif new_rule.enabled == true then
						--Make overdue changes. Search for new_rule.old_entity, old_rule.old_entity, and old_rule.entity and replace them with new_rule.entity
						replace_entity(surface,old_rule.old_entity,new_rule.entity)
						replace_entity(surface,new_rule.old_entity,new_rule.entity)
						replace_entity(surface,old_rule.entity,new_rule.entity)
					end
				end
				old_planet_rules[entity_name] = new_rule
			end
		elseif old_rule and not new_rule then
			--The rule was removed. Put any previously replaced entities back.
			if old_rule.enabled and not replacements_disabled
				and old_rule.entity and old_rule.old_entity then
				replace_entity(surface,old_rule.entity,old_rule.old_entity)
			end
			old_planet_rules[entity_name] = nil
		elseif new_rule and not old_rule then
			old_planet_rules[entity_name] = new_rule
			if new_rule.enabled == true and not replacements_disabled
				and new_rule.old_entity and new_rule.entity then
				--Make overdue changes. Search for new_rule.old_entity and replace it with new_rule.entity
				replace_entity(surface,new_rule.old_entity,new_rule.entity)
			end
		end
	end
end

local function migrate_all_entity_replacement_rules()
	local replacement_rules = PlanetsLib.constants.on_entity_placed_on_planet_replacements
	if not storage.old_replacement_rules then storage.old_replacement_rules = {} end
	if not replacement_rules then
		return
	end

	-- Search for changes to entity replacement rules and replace existing
	-- entities when the rules changed since the last load. Walk the union of
	-- planet keys: a mod may remove every rule for a planet, not just one rule.
	local planet_names = {}
	for planet_name in pairs(replacement_rules) do
		planet_names[planet_name] = true
	end
	for planet_name in pairs(storage.old_replacement_rules or {}) do
		planet_names[planet_name] = true
	end

	for planet_name in pairs(planet_names) do
		local planet_rules = replacement_rules[planet_name] or {}
		local is_space_platform = planet_name == "space-platform"

		if is_space_platform then --Migrate each space platform using space platform rules
			for _,surface in pairs(game.surfaces) do
				if surface.platform then
					migrate_surface(planet_name,surface,planet_rules,replacement_rules)
				end
			end
		else
			local surface --Migrate the one planet these rules apply to.
			if game.planets[planet_name] then surface = game.planets[planet_name].surface end
			migrate_surface(planet_name,surface,planet_rules,replacement_rules)
		end
	end
end

local function on_configuration_changed(configuration_changed_data)
	if cargo_pods then
		cargo_pods.init_storage()
	end
	init_storage()
	local mod_changed = false

	for _, _ in pairs(configuration_changed_data.mod_changes or {}) do
		mod_changed = true
		break
	end

	migrate_all_entity_replacement_rules()
	entity_removal_floors.on_configuration_changed(configuration_changed_data)

	-- local rocket_part_recipe_rules = data.raw["mod-data"]["Planetslib-planet-rocket-part-recipe"].data
	-- local lock_rocket_part_rules = 

	if not mod_changed then
		return
	end

	if settings.startup["PlanetsLib-warn-on-hidden-prerequisites"].value then
		unreachable_techs.warn_unreachable_techs()
	end
	
end

PlanetsLib.event_handler.add_lib{on_configuration_changed=on_configuration_changed}

local entity_replacements = PlanetsLib.constants.on_entity_placed_on_planet_replacements
local is_entity_replacements = not PlanetsLib.objects.deep_equals(entity_replacements,{}) --If no mods add entity replacements, disable related event triggers.
--is_entity_replacements = true
local on_built_filters = {} --List of entity filters derived from entity_replacements to improve performance on entities not governed by replacement rules.
local on_built_filters_and_silos = {}
for planet_name,replacements in pairs(entity_replacements) do
	for entity,replacement_table in pairs(replacements) do
		local replacement = replacement_table.entity
		table.insert(on_built_filters,{filter = "name", name = entity})
		table.insert(on_built_filters,{filter = "ghost_name", name = entity})
		table.insert(on_built_filters_and_silos,{filter = "name", name = entity}) --This lines are copy-pasted because to my shock, table.deepcopy is unavailable in control.
		table.insert(on_built_filters_and_silos,{filter = "ghost_name", name = entity})
		table.insert(on_built_filters,{filter = "name", name = replacement})
		table.insert(on_built_filters,{filter = "ghost_name", name = replacement})
		table.insert(on_built_filters_and_silos,{filter = "name", name = replacement}) --This lines are copy-pasted because to my shock, table.deepcopy is unavailable in control.
		table.insert(on_built_filters_and_silos,{filter = "ghost_name", name = replacement})
		
	end
end


table.insert(on_built_filters_and_silos,{filter = "type", type = "rocket-silo"})
table.insert(on_built_filters_and_silos,{filter = "ghost_type", type = "rocket-silo"})

-- Ground diggers share one prototype per drill across all planets, so the recipe is
-- assigned when a digger is built. Build events are filtered down to digger names.
local ground_diggers = require("scripts.ground-diggers")
local ground_digger_names = {}
for _,config in pairs(PlanetsLib.constants.ground_diggers) do
	for _,info in pairs(config.diggers or {}) do
		if not ground_digger_names[info.digger] then
			ground_digger_names[info.digger] = true
			table.insert(on_built_filters_and_silos,{filter = "name", name = info.digger})
		end
	end
end

local on_built_entity_combined

if is_cargo_pods and is_entity_replacements then
	on_built_entity_combined = function(event)
		rocket_parts.on_built_rocket_silo(event)
		entity_replacement.on_built_entity(event)
	end
elseif is_cargo_pods then
	on_built_entity_combined = function(event)
		rocket_parts.on_built_rocket_silo(event)
	end
elseif is_entity_replacements then
	on_built_entity_combined = function(event)
		entity_replacement.on_built_entity(event)
	end
end

-- Assign ground diggers their planet's recipe whenever one is built.
if next(ground_digger_names) then
	local previous_on_built_entity_combined = on_built_entity_combined
	on_built_entity_combined = function(event)
		if previous_on_built_entity_combined then
			previous_on_built_entity_combined(event)
		end
		ground_diggers.on_entity_built(event)
	end
end


if on_built_entity_combined then
	script.on_event(defines.events.on_built_entity,on_built_entity_combined,on_built_filters_and_silos)
	script.on_event(defines.events.on_robot_built_entity,on_built_entity_combined,on_built_filters_and_silos)
	script.on_event(defines.events.script_raised_built,on_built_entity_combined,on_built_filters_and_silos) 
	script.on_event(defines.events.script_raised_revive,on_built_entity_combined,on_built_filters_and_silos)
	script.on_event(defines.events.on_space_platform_built_entity,on_built_entity_combined,on_built_filters_and_silos)
	--script.on_event(defines.events.on_biter_base_built,entity_replacement.on_built_entity)

	--script.on_event(defines.events.on_player_setup_blueprint,entity_replacement.blueprint_standardize)
end

require("scripts.recipe-effects")

local entities_without_unit_number = {
	"simple-entity",
	"tree",
	"plant",
	"asteroid",
	"resource",
	"corpse",
	"item-entity",
}
local destroy_filters = {

}
for _,entity_type in pairs(entities_without_unit_number) do
	table.insert(destroy_filters,
	{mode="and",filter = "type",type=entity_type,invert=true}
)
end

for _,event_name in pairs(library.destroy_events) do
	script.on_event(event_name, function(event)
		if event.entity.unit_number then
			storage.entity_info[event.entity.unit_number] = nil --Entity info table is used during recipe events to cache crafter inventories and production stat objects
		end
		
		
	end,
	destroy_filters
	)
end

--Allows the pipette tool to summon explicitly defined entities when used on an entity without making it possible to build that entity using said item with robots.
if not rro.deep_equals(PlanetsLib.constants.pipette_result,{}) then
	script.on_event(
	"pipette", function(event)
		local player = game.players[event.player_index]
		--player.update_selected_entity(event.cursor_position)
		
		--local selected_prototype_name = event.selected_prototype.name
		if not player.selected then return end
		local result_name = PlanetsLib.constants.pipette_result[player.selected.name]
		local result = prototypes.entity[result_name]
		if result then
			player.pipette(result,player.selected.quality.name or nil, true)
		end
		
		
	end


	)
end


-- Ground diggers: intercept the build controls so that a mining drill placed without
-- nearby resources is converted into a digging machine instead of failing to build.
if not rro.deep_equals(PlanetsLib.constants.ground_diggers, {}) then
	script.on_event("PlanetsLib-build", ground_diggers.construct_ground_digger)
	script.on_event("PlanetsLib-build-ghost", ground_diggers.construct_ground_digger)
	script.on_event("PlanetsLib-super-forced-build", ground_diggers.construct_ground_digger)
end


-- Entity removal floors: place temporary tile ghosts under configured simple
-- entities before construction robots can deconstruct them over unsafe tiles.
if entity_removal_floors.is_enabled() then
	script.on_event(
		defines.events.on_marked_for_deconstruction,
		entity_removal_floors.on_marked_for_deconstruction,
		entity_removal_floors.get_entity_filters()
	)
	script.on_event(defines.events.on_player_built_tile, function(event)
		entity_removal_floors.on_tile_built(event, "player")
	end)
	script.on_event(defines.events.on_robot_built_tile, function(event)
		entity_removal_floors.on_tile_built(event, "robot")
	end)
	script.on_event(defines.events.on_space_platform_built_tile, function(event)
		entity_removal_floors.on_tile_built(event, "robot")
	end)
	script.on_event(defines.events.script_raised_set_tiles, entity_removal_floors.on_script_raised_set_tiles)
	script.on_event(defines.events.on_player_mined_tile, entity_removal_floors.on_tile_mined)
	script.on_event(defines.events.on_robot_mined_tile, entity_removal_floors.on_tile_mined)
	script.on_event(defines.events.on_space_platform_mined_tile, entity_removal_floors.on_tile_mined)
	script.on_event(defines.events.on_undo_applied, entity_removal_floors.on_undo_applied)
	script.on_nth_tick(30, entity_removal_floors.process_pending_tile_cleanup)
	script.on_nth_tick(60, entity_removal_floors.prune_invalid_entries)
end


--Remote interface to help transfer storage of a mod to a fork of a mod.
remote.add_interface("PlanetsLib_transfer_storage",
	{
		save = function(mod_name,storage_data) 
			if not storage.dumped_storage then
				storage.dumped_storage = {}
			end
			storage.dumped_storage[mod_name] = storage_data
		end,
		get = function(mod_name)
			if not storage.dumped_storage then
				storage.dumped_storage = {}
			end
			return storage.dumped_storage[mod_name]
		end,
		purge = function(mod_name) 
			if not storage.dumped_storage then
				storage.dumped_storage = {}
			end
			storage.dumped_storage[mod_name] = nil
		end,
	}
)


if script.active_mods["gvv"] then 
	require("__gvv__.gvv")() 
	

	end --gvv enables debugging of storage values with a GUI

-- == Test-only seams for the FUnit test suite == --
-- This block is purely additive and does nothing unless the FUnit test
-- framework is active. It (1) registers PlanetsLib with FUnit's event mocker so
-- mocked events reach the handlers above, and (2) exposes a remote interface so
-- the headless test scenario can drive the stateful internals below, which
-- cannot be reached across mod Lua environments. It wraps the existing
-- functions unchanged; see test-mods/planetslib-funit-data/tests/README.md.
if script.active_mods["funit"] then
	require("__funit__.mock").register()

	remote.add_interface("planetslib_funit", {
		replace_entity = function(entity, new_entity, raise_built)
			return entity_replacement.replace_entity(entity, new_entity, raise_built)
		end,
		on_built_entity = function(event, swap_target, dont_raise_built)
			return entity_replacement.on_built_entity(event, swap_target, dont_raise_built)
		end,
		construct_ground_digger = function(event)
			return ground_diggers.construct_ground_digger(event)
		end,
		on_entity_built = function(event)
			return ground_diggers.on_entity_built(event)
		end,
		ground_digger_collisions = function(surface, position, digger_prototype_name)
			return ground_diggers.find_build_collisions(surface, position, digger_prototype_name)
		end,
		revive_ground_digger_ghost = function(ghost)
			return ground_diggers.revive_ground_digger_ghost(ghost)
		end,
		select_digger_ghost = function(colliding_entities, digger_name, position)
			return ground_diggers.select_digger_ghost(colliding_entities, digger_name, position)
		end,
		on_configuration_changed = function(configuration_changed_data)
			return on_configuration_changed(configuration_changed_data)
		end,
		migrate_entity_replacement_rules = function(old_rules)
			storage.old_replacement_rules = old_rules or storage.old_replacement_rules
			return migrate_all_entity_replacement_rules()
		end,
		orientations_differ = function(first, second)
			return entity_replacement.orientations_differ(first, second)
		end,
		warn_on_join = function()
			return warn_on_join_if_due()
		end,
		should_warn_on_join = function(tick, setting_value)
			return unreachable_techs.should_warn_on_join(tick, setting_value)
		end,
		warn_cargo_pod_canceled = function(player, platform, planet_name)
			if not cargo_pods then
				return nil
			end
			return cargo_pods.warn_player_of_canceled_pod(player, platform, planet_name)
		end,
		pod_contents_is_allowed = function(pod_contents, planet_name)
			if not cargo_pods then
				return nil
			end
			return cargo_pods.pod_contents_is_allowed(pod_contents, planet_name)
		end,
		examine_cargo_pods = function(platform, planet_name)
			if not cargo_pods then
				return nil
			end
			return cargo_pods.examine_cargo_pods(platform, planet_name)
		end,
		entity_removal_floors_is_enabled = function()
			return entity_removal_floors.is_enabled()
		end,
		entity_removal_floors_on_marked_for_deconstruction = function(event)
			return entity_removal_floors.on_marked_for_deconstruction(event)
		end,
		entity_removal_floors_on_tile_built = function(event, builder)
			return entity_removal_floors.on_tile_built(event, builder)
		end,
		entity_removal_floors_on_script_raised_set_tiles = function(event)
			return entity_removal_floors.on_script_raised_set_tiles(event)
		end,
		entity_removal_floors_on_tile_mined = function(event)
			return entity_removal_floors.on_tile_mined(event)
		end,
		entity_removal_floors_on_undo_applied = function(event)
			return entity_removal_floors.on_undo_applied(event)
		end,
		entity_removal_floors_process_pending_tile_cleanup = function()
			return entity_removal_floors.process_pending_tile_cleanup()
		end,
		entity_removal_floors_prune_invalid_entries = function()
			return entity_removal_floors.prune_invalid_entries()
		end,
		entity_removal_floors_floor_bounds = function(entity)
			return { entity_removal_floors._test_get_floor_bounds(entity) }
		end,
		entity_removal_floors_analyse_floor = function(entity)
			return entity_removal_floors._test_analyse_floor(entity)
		end,
		entity_removal_floors_select_replacement_tile = function(...)
			return entity_removal_floors._test_select_replacement_tile(...)
		end,
		entity_removal_floors_select_replacement_tile_for_tile = function(...)
			return entity_removal_floors._test_select_replacement_tile_for_tile(...)
		end,
		entity_removal_floors_has_stationary_roboport_coverage = function(surface, force, position)
			return entity_removal_floors._test_has_stationary_roboport_coverage(surface, force, position)
		end,
		entity_removal_floors_queue_entity = function(entity, force_name, player_index, replacement_tile)
			return entity_removal_floors._test_queue_entity(entity, force_name, player_index, replacement_tile)
		end,
		entity_removal_floors_apply_undo_actions = function(actions)
			return entity_removal_floors._test_apply_undo_actions(actions)
		end,
		entity_removal_floors_clear_surface_state = function(surface_index)
			return entity_removal_floors._test_clear_surface_state(surface_index)
		end,
		entity_removal_floors_get_queued = function(surface_index)
			return entity_removal_floors._test_get_queued(surface_index)
		end,
		entity_removal_floors_get_cleanup = function(surface_index)
			return entity_removal_floors._test_get_cleanup(surface_index)
		end,
	})
end

