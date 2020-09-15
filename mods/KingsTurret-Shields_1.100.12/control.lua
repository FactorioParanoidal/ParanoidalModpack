require "on_tick"
require "prototypes.constants"
require "prototypes.functions"

--/////////////////////////////////
--Global Variable Members:

--global.turrets
-- 1	tick of last update / last energy tick **
-- 2	shield at last update / last energy value **
-- 3	hpbar entity
-- 4	orientation
-- 5	shield effect entity
-- 6	tick of last shield effect
-- 7	electric interface entity
-- 8	turret entity
-- 9	damage taken since last tick **
-- 10	disabled entity or not

-- global.turrets[turretkey][7].<property> || https://lua-api.factorio.com/latest/LuaEntity.html#LuaEntity.electric_buffer_size
-- global.needsGFXUpdate[TURRET_ID] || Notes that this unit needs a graphics update next ontick() cycle.

-- global.research_size_steps || How many levels of size research per order of magnutide of shield size
-- global.research_speed_steps || How many levels of speed research per order of magnutide of recharge rate
-- global.energy_consumption_multiplier || How much energy (in KJ) does one point of damage take from the shield.
-- global.power_drain_pct || At 1%, if shield has 10k HP, 100 KW are drained from the power grid.

-- global.research_enabled || Is research enabled or not?
-- global.alternate_effect || Use the alternate visual effect for shields?
--/////////////////////////////////

ignored_entities = {
["vehicle-gun-turret"] = true,
["vehicle-gun-turretv2"] = true,
["vehicle-gun-turretv3"] = true,
["vehicle-rocket-turret"] = true,
["vehicle-rocket-turretv2"] = true,
["vehicle-rocket-turretv3"] = true,
}

script.on_init(function()
	if DEBUG then
		log("debug script.on_init")
	end
	
	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.base_shield_val = settings.startup["TS_base_shield"].value
	global.base_shield_recharge = settings.startup["TS_base_charge_rate"].value
	global.research_size_steps = settings.startup["TS_research_size"].value
	global.research_speed_steps = settings.startup["TS_research_speed"].value

	global.power_usage = settings.startup["TS_power_drain"].value/100

	global.research_enabled = settings.global["TS_research_enabled"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
	
	--Used by ontick to update shield graphics.
	global.needsGFXUpdate = {}
	
	global.disabled_turrets={}
	global.combinators={}
	refresh_everything()
	global.version = 34
	
	global.e_updater_size = 0
	global.e_updater_disconnected_size = 0
	global.combinators_size = 0
	
	global.iterate_turrets = nil
	global.iterate_e_updater = nil
	global.iterate_e_updater_disconnected = nil
	global.iterate_combinators = nil
	
	remove_hpbars()
	for key, value in pairs(global.turrets) do
		value[HP_BAR] = nil
	end
	
	for k, force in pairs (game.forces) do	
		update_electricity_force(force)
		--technically causes a double-scan sometimes, but only once, and that's ok...ish.
		rescan_for_turrets(force)
	end
	--global.worker_key = nil
end)

script.on_configuration_changed(function()
	if DEBUG then
		log("debug script.on_configuration_changed")
	end

	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.base_shield_val = settings.startup["TS_base_shield"].value
	global.base_shield_recharge = settings.startup["TS_base_charge_rate"].value
	global.research_size_steps = settings.startup["TS_research_size"].value
	global.research_speed_steps = settings.startup["TS_research_speed"].value
	global.power_drain_pct = settings.startup["TS_power_drain"].value/100
	
	global.research_enabled = settings.global["TS_research_enabled"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
		
	--global.worker_key = nil
	if global.version < 22 then
		global.disabled_turrets={}
		global.version=22
	end
	if global.version < 24 then
		global.combinators={}
		global.version=24
	end
	if global.version < 25 then
		for key, tbl in pairs(global.combinators) do
			global.combinators[key].entity = tbl[1]
			global.combinators[key][1]=nil
			global.combinators[key].turrets={tbl[2]}
			global.combinators[key][2]=nil
		end
		global.version=25
	end
	if global.version < 26 then
		refresh_everything()
		global.version=26
	end
	if global.version < 27 then
		global.refresh_orientation={}
		global.version=27
	end
	if global.version < 32 then
		for tick, tbl in pairs(global.updater) do
			for a,b in pairs(tbl) do
				tbl[a] = b[2]
			end
		end
		for a, b in pairs(global.electric_updater) do
			global.electric_updater[a] = b[2]
		end
		for a, b in pairs(global.electric_updater_disconnected) do
			global.electric_updater[a] = b[2]
		end
		global.e_updater_size = table_size(global.electric_updater)
		global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
		global.combinators_size = table_size(global.combinators)
		--for key, tabl in pairs(global.disabled_turrets) do
		--	if global.turrets[key] then
		--		global.turrets[10] = tabl[1]
		--	end
		--end
		--global.disabled_turrets = nil
		global.version = 32
		
		disabled_turrets={}
		combinators={}
		
	end
	if global.version < 33 then
		for a,b in pairs(global.turrets) do
			if b[8].valid and ignored_entities[b[8].name] then
				destroy_turret(b[8].unit_number)
			end
		end
		global.version = 33
	end
	--Destroy any entity shield bars so they can be replaced with animation ones.
	if global.version < 34 then
		remove_hpbars()
		for key, value in pairs(global.turrets) do
			value[HP_BAR] = nil
		end
		global.version = 34
	end

	for k, force in pairs (game.forces) do	
		update_electricity_force(force)
		--technically causes a double-scan sometimes, but only once, and that's ok...ish.
		rescan_for_turrets(force)
	end
end)

script.on_event(defines.events.on_force_created,function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.on_force_created fired")
	end
	
	global.forces[event.force.name] = {}

	setTechAndRecipes(event.force)

	rescan_for_turrets(event.force)
end)

script.on_event(defines.events.on_player_selected_area,function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.on_player_selected_area")
	end
	
    if event.item == "ts-shield-disabler" then
		if global.energy_consumption then
			for key, entity in pairs(event.entities) do
				if entity.valid and entity.type== "ammo-turret" or entity.type== "fluid-turret" or entity.type== "electric-turret" then
					if global.disabled_turrets[entity.unit_number] then
						global.disabled_turrets[entity.unit_number][1].destroy()
						global.disabled_turrets[entity.unit_number] = nil
						init_turret(entity,true)
					else
						global.disabled_turrets[entity.unit_number] = {}
						global.disabled_turrets[entity.unit_number][1] = entity.surface.create_entity{name = "ts-unplugged", position = {entity.position.x, entity.position.y}, force = "neutral"}
						global.disabled_turrets[entity.unit_number][2] = entity
						destroy_turret(entity.unit_number)
						--if global.turrets[entity.unit_number] and global.turrets[entity.unit_number][3] and global.turrets[entity.unit_number][3].valid then global.turrets[entity.unit_number][3].destroy() end
						--if global.turrets[entity.unit_number] and global.turrets[entity.unit_number][7] and global.turrets[entity.unit_number][7].valid then global.turrets[entity.unit_number][7].destroy() end
						--global.turrets[entity.unit_number]=nil
					end
				end
			end
		else
			for key, entity in pairs(event.entities) do
				if entity.valid and entity.type== "ammo-turret" or entity.type== "fluid-turret" or entity.type== "electric-turret" then
					if global.disabled_turrets[entity.unit_number] then
						global.disabled_turrets[entity.unit_number][1].destroy()
						global.disabled_turrets[entity.unit_number] = nil
					else
						global.disabled_turrets[entity.unit_number] = {}
						global.disabled_turrets[entity.unit_number][1] = entity.surface.create_entity{name = "ts-unplugged", position = {entity.position.x, entity.position.y}, force = "neutral"}
						global.disabled_turrets[entity.unit_number][2] = entity
					end
				end
			end
		end
    end
end)

script.on_event( defines.events.on_player_changed_force, function(event)
	if DEBUG then
		log("debug script.on_event( defines.events.on_player_changed_force")
	end
	
	local force= game.players[event.player_index].force
	update_force(force)
end)

script.on_event( defines.events.on_console_chat, function(event)
	if DEBUG then
		log("debug script.on_event( defines.events.on_console_chat")
	end
	
	if event.player_index == 1 and event.message == "kts reset" then
		rendering.clear("KingsTurret-Shields")
		remove_energy()
		rescan_for_turrets(game.players[event.player_index].force)
	end
	if event.message == "shieldstats" then
		printShieldStats(game.players[event.player_index].force)
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.on_runtime_mod_setting_changed")
	end
	
	if event.setting == "TS_research_enabled" then
		global.research_enabled = settings.global["TS_research_enabled"].value
		if not global.research_enabled then
			game.players[event.player_index].force.technologies["turret-shields-base"].researched = true
		end
		rescan_for_turrets(game.players[event.player_index].force)
		setTechAndRecipes(game.players[event.player_index].force)
		update_electricity_force(game.players[event.player_index].force)
	end
	
	if event.setting == "TS_alternate_effect" then
		global.alternate_effect = settings.global["TS_alternate_effect"].value
	end
end)

script.on_event(defines.events.on_research_finished,function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.on_research_finished")
	end

	force = event.research.force
	if not global.research_enabled then return end
	
	if event.research.name == "turret-shields-base" or event.research.name == "turret-shields-size" or event.research.name == "turret-shields-speed" then
		printShieldStats(force)
	end
	
	update_electricity_force(force)
	
	--If we just researched the tech for the first time, ensure all existing turrets get shields.
	if event.research.name == "turret-shields-base" then
		rescan_for_turrets(force)
	end
end)

script.on_event(defines.events.script_raised_revive,function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.script_raised_revive")
	end
	
	if global.forces[event.entity.force.name].enabled then
		if event.entity.type == "ammo-turret"
		or event.entity.type == "fluid-turret"
		or event.entity.type == "electric-turret" then
			init_turret(event.entity,true)
		end
	end
	if event.entity.name=="turret-shield-combinator" then
		global.combinators[event.entity.unit_number]={}
		global.combinators[event.entity.unit_number].entity=event.entity
		global.combinators[event.entity.unit_number].turrets={}
		global.combinators_size = table_size(global.combinators)
	end
end)

script.on_event({defines.events.on_robot_built_entity,defines.events.on_built_entity,defines.events.script_raised_revive,defines.events.script_raised_built,defines.events.on_entity_cloned},function(event)
	if DEBUG then
		log("debug script.on_event({defines.events.on_robot_built_entity")
	end
	
	local entity = event.created_entity or event.entity or event.destination
	if global.forces[entity.force.name].enabled then
		if entity.type == "ammo-turret"
		or entity.type == "fluid-turret"
		or entity.type == "electric-turret" then
			init_turret(entity,true)
		end
	end
	if entity.name=="turret-shield-combinator" then
		global.combinators[entity.unit_number]={}
		global.combinators[entity.unit_number].entity=entity
		global.combinators[entity.unit_number].turrets={}
		global.combinators_size = table_size(global.combinators)
	end
end)

script.on_event(defines.events.on_entity_damaged,function(event)
	if DEBUG then
		log("debug script.on_event(defines.events.on_entity_damaged")	
	end
	
	if not event.entity.valid then
		return
	end
	if global.energy_consumption and global.disabled_turrets[event.entity.unit_number] then return end
	if global.forces[event.entity.force.name] and global.forces[event.entity.force.name].enabled then
		if event.entity.type == "ammo-turret"
		or event.entity.type == "fluid-turret"
		or event.entity.type == "electric-turret" then
			if string.sub(event.entity.name,1,4)=="wisp" then return end
			handleDamageEvent(event)
		end
	end
end)

--Building
script.set_event_filter(defines.events.on_robot_built_entity, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.on_built_entity, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.script_raised_revive, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.script_raised_built, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.on_entity_cloned, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.script_raised_revive, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})

--Destroying/removing
script.set_event_filter(defines.events.on_entity_died, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.on_player_mined_entity, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})
script.set_event_filter(defines.events.on_robot_mined_entity, {{filter = "turret"}, {filter = "name", name = "turret-shield-combinator"}})

--Damaging
script.set_event_filter(defines.events.on_entity_damaged, {{filter = "turret"}})
-----------------------------------------------------------------------------------------------------------------------------------------------------------

script.on_event({defines.events.on_entity_died,defines.events.on_player_mined_entity,defines.events.on_robot_mined_entity},function(event)
	if DEBUG then
		log("debug script.on_event({defines.events.on_entity_died")
	end
	
	if event.entity.type == "ammo-turret"
	or event.entity.type == "fluid-turret"
	or event.entity.type == "electric-turret" then
		if global.disabled_turrets[event.entity.unit_number] then 
			global.disabled_turrets[event.entity.unit_number][1].destroy()
			global.disabled_turrets[event.entity.unit_number]=nil
			global.needsGFXUpdate[event.entity.unit_number] = nil
		end
		if global.turrets[event.entity.unit_number] and global.turrets[event.entity.unit_number][HP_BAR] and rendering.is_valid(global.turrets[event.entity.unit_number][HP_BAR]) then
			rendering.destroy(global.turrets[event.entity.unit_number][HP_BAR])
		end
		if global.turrets[event.entity.unit_number] and global.turrets[event.entity.unit_number][7] and global.turrets[event.entity.unit_number][7].valid then 
			global.turrets[event.entity.unit_number][7].destroy()
			global.needsGFXUpdate[event.entity.unit_number] = nil
		end
		if global.iterate_turrets == event.entity.unit_number then
			global.iterate_turrets = next(global.turrets, global.iterate_turrets)
		end
		global.turrets[event.entity.unit_number] = nil
	end
	if event.entity.name=="turret-shield-combinator" then
		local tbl=global.combinators[event.entity.unit_number]
		for k,turret in pairs (tbl.turrets) do
			if turret and turret.valid then
				toggle_shield(turret,true)
			end
		end
		if global.iterate_combinators == event.entity.unit_number then
			global.iterate_combinators = next(global.combinators, global.iterate_combinators)
		end
		global.combinators[event.entity.unit_number]=nil
		global.combinators_size = table_size(global.combinators)
	end
end)