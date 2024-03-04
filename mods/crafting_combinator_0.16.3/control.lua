require 'script.bootstrap'

local config = require 'config'
local cc_control = require 'script.cc'
local rc_control = require 'script.rc'
local signals = require 'script.signals'
local util = require 'script.util'
local gui = require 'script.gui'
local settings_parser = require 'script.settings-parser'


local cc_rate, rc_rate = 1, 1

local function enable_recipes()
	for _, force in pairs(game.forces) do
		if force.technologies['circuit-network'].researched then
			force.recipes[config.CC_NAME].enabled = true
			force.recipes[config.RC_NAME].enabled = true
		end
	end
end

local function on_load(forced)
	if not forced and next(late_migrations.__migrations) ~= nil then return; end
	
	cc_control.on_load()
	rc_control.on_load()
	signals.on_load()
	cc_rate = settings.global[config.REFRESH_RATE_CC_NAME].value
	rc_rate = settings.global[config.REFRESH_RATE_RC_NAME].value
	
	if remote.interfaces['PickerDollies'] then
		script.on_event(remote.call('PickerDollies', 'dolly_moved_entity_id'), function(event)
			local entity = event.moved_entity
			local combinator
			if entity.name == config.CC_NAME then combinator = global.cc.data[entity.unit_number]
			elseif entity.name == config.RC_NAME then combinator = global.rc.data[entity.unit_number]; end
			if combinator then combinator:update_inner_positions(); end
		end)
	end
end

script.on_init(function()
	cc_control.init_global()
	rc_control.init_global()
	signals.init_global()
	on_load(true)
end)
script.on_load(on_load)

script.on_configuration_changed(function(changes)
	late_migrations(changes)
	on_load(true)
	enable_recipes()
end)


local function count_entities_at(entity, name)
	return #(entity.surface.find_entities_filtered {
		name = name or entity.name,
		position = entity.position,
	})
end

local function on_built(event)
	local entity = event.created_entity or event.entity
	if entity.name == config.CC_NAME then cc_control.create(entity); end
	if entity.name == config.RC_NAME then rc_control.create(entity); end
	if entity.type == 'assembling-machine' then cc_control.update_assemblers(entity.surface, entity); end
	if util.CONTAINER_TYPES[entity.type] then cc_control.update_chests(entity.surface, entity); end
	
	if entity.type == 'entity-ghost' and entity.ghost_name == config.SETTINGS_ENTITY_NAME then
		if count_entities_at(entity, config.SETTINGS_ENTITY_NAME) > 0 then entity.destroy()
		else entity.silent_revive(); end
		return
	end
	if entity.name == config.SETTINGS_ENTITY_NAME then
		if count_entities_at(entity) > 1 then
			entity.destroy()
			return
		end
	end
end

local function on_destroyed(event)
	local entity = event.entity
	if entity.name == config.CC_NAME then
		if cc_control.destroy(entity, event.player_index) then return; end -- Return if the entity was coppied
	end
	if entity.name == config.MODULE_CHEST_NAME then return cc_control.destroy_by_robot(entity); end
	if entity.name == config.RC_NAME then rc_control.destroy(entity); end
	if entity.type == 'assembling-machine' then cc_control.update_assemblers(entity.surface, entity, true); end
	if util.CONTAINER_TYPES[entity.type] then cc_control.update_chests(entity.surface, entity, true); end
	
	if entity.type == 'entity-ghost' and (entity.ghost_name == config.CC_NAME or entity.ghost_name == config.RC_NAME) then
		settings_parser.destroy(entity)
	end
end


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	cc_rate = settings.global[config.REFRESH_RATE_CC_NAME].value
	rc_rate = settings.global[config.REFRESH_RATE_RC_NAME].value
end)

local function run_update(tab, tick, rate)
	for i = tick % (rate + 1) + 1, #tab, (rate + 1) do tab[i]:update(); end
end
script.on_event(defines.events.on_tick, function(event)
	if global.cc.inserter_empty_queue[event.tick] then
		for _, e in pairs(global.cc.inserter_empty_queue[event.tick]) do
			if e.entity.valid and e.assembler and e.assembler.valid then e:empty_inserters(); end
		end
		global.cc.inserter_empty_queue[event.tick] = nil
	end
	
	run_update(global.cc.ordered, event.tick, cc_rate)
	run_update(global.rc.ordered, event.tick, rc_rate)
end)


script.on_event(defines.events.on_player_rotated_entity, function(event)
	if event.entity.name == config.CC_NAME then
		local combinator = global.cc.data[event.entity.unit_number]
		combinator:find_assembler()
		combinator:find_chest()
	end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
	local source, destination
	if event.source.name == config.CC_NAME and event.destination.name == config.CC_NAME then
		source, destination = global.cc.data[event.source.unit_number], global.cc.data[event.destination.unit_number]
	elseif event.source.name == config.RC_NAME and event.destination.name == config.RC_NAME then
		source, destination = global.rc.data[event.source.unit_number], global.rc.data[event.destination.unit_number]
	else return; end
	
	destination.settings = util.deepcopy(source.settings)
	destination.settings_parser:update(destination.entity, destination.settings)
	if destination.entity.name == config.RC_NAME then destination:update(true)
	elseif destination.entity.name == config.CC_NAME then destination:copy(source); end
end)


script.on_event(defines.events.on_gui_opened, function(event)
	local entity = event.entity
	if entity then
		if entity.name == config.CC_NAME then global.cc.data[entity.unit_number]:open(event.player_index); end
		if entity.name == config.RC_NAME then global.rc.data[entity.unit_number]:open(event.player_index); end
	end
end)
script.on_event(defines.events.on_gui_closed, function(event)
	local element = event.element
	if element and element.valid and element.name and element.name:match('^crafting_combinator:') then
		element.destroy()
	end
end)
script.on_event(defines.events.on_gui_checked_state_changed, function(event)
	local element = event.element
	if element and element.valid and element.name and element.name:match('^crafting_combinator:') then
		local gui_name, unit_number, element_name = gui.parse_entity_gui_name(element.name)
		
		if gui_name == 'crafting-combinator' then
			global.cc.data[unit_number]:on_checked_changed(element_name, element.state, element)
		end
		if gui_name == 'recipe-combinator' then
			global.rc.data[unit_number]:on_checked_changed(element_name, element.state, element)
		end
	end
end)
script.on_event(defines.events.on_gui_selection_state_changed, function(event)
	local element = event.element
	if element and element.valid and element.name and element.name:match('^crafting_combinator:') then
		local gui_name, unit_number, element_name = gui.parse_entity_gui_name(element.name)
		if gui_name == 'crafting-combinator' then
			global.cc.data[unit_number]:on_selection_changed(element_name, element.selected_index)
		end
	end
end)
script.on_event(defines.events.on_gui_text_changed, function(event)
	local element = event.element
	if element and element.valid and element.name and element.name:match('^crafting_combinator:') then
		local gui_name, unit_number, element_name = gui.parse_entity_gui_name(element.name)
		if gui_name == 'recipe-combinator' then
			global.rc.data[unit_number]:on_text_changed(element_name, element.text)
		end
	end
end)
script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if element and element.valid and element.name and element.name:match('^crafting_combinator:') then
		local gui_name, unit_number, element_name = gui.parse_entity_gui_name(element.name)
		if gui_name == 'crafting-combinator' then
			global.cc.data[unit_number]:on_click(element_name, element)
		end
	end
end)


script.on_event(defines.events.on_built_entity, on_built)
script.on_event(defines.events.on_robot_built_entity, on_built)
script.on_event(defines.events.script_raised_built, on_built)
script.on_event(defines.events.script_raised_revive, on_built)

script.on_event(defines.events.on_pre_player_mined_item, on_destroyed)
script.on_event(defines.events.on_robot_pre_mined, on_destroyed)
script.on_event(defines.events.on_entity_died, on_destroyed)
script.on_event(defines.events.script_raised_destroy, on_destroyed)

script.on_event(defines.events.on_pre_ghost_deconstructed, function(event)
	event.entity = event.ghost
	on_destroyed(event)
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
	if event.entity.name == config.CC_NAME then cc_control.fix_undo_deconstruction(event.entity, event.player_index); end
	if event.entity.name == config.MODULE_CHEST_NAME then cc_control.mark_for_deconstruction(event.entity); end
end)
script.on_event(defines.events.on_cancelled_deconstruction, function(event)
	if event.entity.name == config.MODULE_CHEST_NAME then cc_control.cancel_deconstruction(event.entity); end
end)
