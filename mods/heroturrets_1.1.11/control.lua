log("Entering control.lua")
local mod_gui =  require("mod-gui")
--[[Setup volatile structures]]
if not heroturrets then heroturrets = {} end

if not heroturrets.force_configuration_change then heroturrets.force_configuration_change = false end
if not heroturrets.ticks then heroturrets.ticks = {} end
if not heroturrets.ticks_low then heroturrets.ticks_low = {} end
if not heroturrets.ticks_med then heroturrets.ticks_med = {} end
if not heroturrets.ticks_high then heroturrets.ticks_high = {} end

if not heroturrets.on_added then heroturrets.on_added = {} end
if not heroturrets.on_added_by_name then heroturrets.on_added_by_name = {} end
if not heroturrets.on_removed then heroturrets.on_removed = {} end
if not heroturrets.on_removed_by_name then heroturrets.on_removed_by_name = {} end
if not heroturrets.on_pick_up then heroturrets.on_pick_up = {} end
if not heroturrets.on_pick_up_by_name then heroturrets.on_pick_up_by_name = {} end
if not heroturrets.on_init then heroturrets.on_init = {} end
if not heroturrets.on_load then heroturrets.on_load = {} end 
if not heroturrets.on_start then heroturrets.on_start = {} end
if not heroturrets.on_player_cursor_stack_changed then heroturrets.on_player_cursor_stack_changed = {} end
if not heroturrets.on_damage then heroturrets.on_damage = {} end 
if not heroturrets.on_damage_by_name then heroturrets.on_damage_by_name = {} end 
if not heroturrets.on_research then heroturrets.on_research = {} end 
if not heroturrets.on_selected then heroturrets.on_selected = {} end 
if not heroturrets.on_selected_by_name then heroturrets.on_selected_by_name = {} end 
if not heroturrets.on_spawned then heroturrets.on_spawned = {} end 
if not heroturrets.on_spawned_by_name then heroturrets.on_spawned_by_name = {} end 
if not heroturrets.on_chunk_charted then heroturrets.on_chunk_charted = {} end 
if not heroturrets.on_chunk_generated then heroturrets.on_chunk_generated = {} end 
if not heroturrets.on_post_entity_died then heroturrets.on_post_entity_died = {} end 
if not heroturrets.on_gui_click then heroturrets.on_gui_click = {} end
if not heroturrets.on_player_spawned then heroturrets.on_player_spawned = {} end
--if not heroturrets.on_adjust then heroturrets.on_adjust = {} end
--if not heroturrets.on_adjust_by_name then heroturrets.on_adjust_by_name = {} end
if not heroturrets.on_player_rotated_entity then heroturrets.on_player_rotated_entity = {} end
if not heroturrets.on_player_rotated_entity_by_name then heroturrets.on_player_rotated_entity_by_name = {} end
if not heroturrets.on_configuration_changed then heroturrets.on_configuration_changed = {} end
if not heroturrets.on_train_changed_state then heroturrets.on_train_changed_state = {} end
if not heroturrets.on_ai_command_completed then heroturrets.on_ai_command_completed = {} end
if not heroturrets.on_trigger_created_entity then heroturrets.on_trigger_created_entity = {} end
if not heroturrets.on_entity_cloned then heroturrets.on_entity_cloned = {} end


local run_init = false

require("prototypes.scripts.defines") 
--[[Import utils]]
--require("prototypes.scripts.util") 
require '__liborio__/prototypes/scripts/util'
heroturrets.util = get_liborio()

--heroturrets.profiler = false
--require("prototypes.scripts.profiler") 


local table_contains = heroturrets.util.table.contains
local table_index_of = heroturrets.util.table.index_of
local starts_with  = heroturrets.util.starts_with
local ends_with  = heroturrets.util.ends_with
local distance  = heroturrets.util.distance
local is_valid  = heroturrets.util.is_valid
local is_valid_and_persistant  = heroturrets.util.entity.is_valid_and_persistant

--require("wiki")
local build_events = heroturrets.events.on_build
local remove_events = heroturrets.events.on_remove
local item_pick_up_events = heroturrets.events.on_pick_up_item
local allow_pickup_rotations = heroturrets.defines.names.allow_pickup_rotations
local allow_fishing = heroturrets.defines.names.allow_fishing

local low_priority = heroturrets.events.low_priority
local medium_priority = heroturrets.events.medium_priority
local high_priority = heroturrets.events.high_priority

local is_map_editor = false

--[[standardized script controls]]

heroturrets.register_script = function(script)
	local index_of = function(table,value)
		for k, v in pairs(table) do 
			if v == value then 
				return k 
			end
		end return nil 
		end
	local register_event_for_in = function(event_table,func,name)
		if event_table[name] == nil then
			event_table[name] = {func}
		else
			table.insert(event_table[name],func)
		end
		end
	if script.on_init ~= nil then 
		log("Registering init event")
		table.insert(heroturrets.on_init,script.on_init)
	end
	if script.on_configuration_changed ~= nil then 
		log("Registering configuration changed event")
		table.insert(heroturrets.on_configuration_changed,script.on_configuration_changed)
	end
	if script.on_gui_click ~= nil then 
		log("Registering gui click event")
		table.insert(heroturrets.on_gui_click,script.on_gui_click)
	end
	if script.on_load ~= nil then 
		log("Registering load event")
		table.insert(heroturrets.on_load,script.on_load)
	end
	if script.on_start ~= nil then 
		log("Registering start event")
		table.insert(heroturrets.on_start,script.on_start)
	end
	if script.on_added~= nil then 
		log("Registering spawned event")
		table.insert(heroturrets.on_added,script.on_added)
	end
	if script.on_train_changed_state ~= nil then 
		log("Registering train changed state event")
		table.insert(heroturrets.on_train_changed_state,script.on_train_changed_state)
	end
	if script.on_entity_cloned ~= nil then 
		log("Registering on entity cloned event")
		table.insert(heroturrets.on_entity_cloned,script.on_entity_cloned)
	end
	
	if script.on_player_cursor_stack_changed~= nil then 
		log("Registering player stack changed event")
		table.insert(heroturrets.on_player_cursor_stack_changed,script.on_player_cursor_stack_changed)
	end	
	if script.on_removed~= nil then 
		log("Registering removed event")
		table.insert(heroturrets.on_removed,script.on_removed)
	end
	if script.on_post_entity_died ~= nil then 
		log("Registering post entity died event")
		table.insert(heroturrets.on_post_entity_died,script.on_post_entity_died)
	end	
	if script.on_damage ~= nil then 
		log("Registering damage event")
		table.insert(heroturrets.on_damage,script.on_damage)
	end	
	if script.on_trigger_created_entity ~= nil then 
		log("Registering trigger entity created event")
		table.insert(heroturrets.on_trigger_created_entity,script.on_trigger_created_entity)
	end	
	
	if script.on_pick_up ~= nil then 
		log("Registering pick up event")
		table.insert(heroturrets.on_pick_up,script.on_pick_up)
	end		
	if script.on_research ~= nil then 
		log("Registering research event")
		table.insert(heroturrets.on_research,script.on_research)
	end	
	if script.on_selected ~= nil then 
		log("Registering selected event")
		table.insert(heroturrets.on_selected,script.on_selected)
	end
	if script.on_chunk_charted ~= nil then 
		log("Registering legacy chunk charted event")
		table.insert(heroturrets.on_chunk_charted,script.on_chunk_charted)
	end
	if script.on_chunk_generated ~= nil then 
		log("Registering legacy chunk generated event")
		table.insert(heroturrets.on_chunk_generated,script.on_chunk_generated)
	end
	if script.on_spawned~= nil then 
		log("Registering spawned event")
		table.insert(heroturrets.on_spawned,script.on_spawned)
	end
	if script.on_player_spawned ~= nil then 
		log("Registering player spawned event")
		table.insert(heroturrets.on_player_spawned,script.on_player_spawned)
	end
	--if script.on_adjust ~= nil then 
	--	log("Registering adjust event")
	--	table.insert(heroturrets.on_adjust,script.on_adjust)
	--end
	if script.on_player_rotated_entity ~= nil then 
		log("Registering rotated entity event")
		table.insert(heroturrets.on_player_rotated_entity,script.on_player_rotated_entity)
	end
	if script.on_ai_command_completed ~= nil then 
		log("Registering ai command completed event")
		table.insert(heroturrets.on_ai_command_completed,script.on_ai_command_completed)
	end
	
	if script.on_tick ~= nil then 
		if type(script.on_tick)=="table" and type(script.on_tick.tick) == "function" then
			log("Registering advanced tick event")
			if script.on_tick.priority ~= nil then
				if script.on_tick.priority == low_priority then
					table.insert(heroturrets.ticks_low,script.on_tick.tick)
				elseif script.on_tick.priority == med_priority then
					table.insert(heroturrets.ticks_med,script.on_tick.tick)
				elseif script.on_tick.priority == high_priority then
					table.insert(heroturrets.ticks_high,script.on_tick.tick)
				else
					log("Unknown priority")
					table.insert(heroturrets.ticks,script.on_tick.tick)
				end
			else
				table.insert(heroturrets.ticks,script.on_tick.tick)
			end
			if script.on_tick.table ~= nil and type(script.on_tick.table) == "function" and script.on_tick.auto_add_remove~= nil and type(script.on_tick.auto_add_remove) == "table" then 
				for k=1, #script.on_tick.auto_add_remove do local s = script.on_tick.auto_add_remove[k]
					log("Registering auto add remove "..s)
					register_event_for_in(heroturrets.on_added_by_name, function(entity) table.insert(script.on_tick.table(), entity) end,s)
					register_event_for_in(heroturrets.on_removed_by_name, function(entity) 
						local t = script.on_tick.table()
						table.remove(table, index_of(t, entity)) 
					end,s)	
				end
			end
		elseif type(script.on_tick) == "function" then
			log("Registering tick event")
			table.insert(heroturrets.ticks,script.on_tick)
		else
			log("Failed to register tick event")
		end
	end
	if script.names ~=nil then
		for k=1, #script.names do local s = script.names[k]		
			if script.on_added_by_name ~= nil and type(script.on_added_by_name) == "function" then 
				log("Registering added event for ".. s)
				register_event_for_in(heroturrets.on_added_by_name,script.on_added_by_name,s)
			end
			if script.on_removed_by_name ~= nil and type(script.on_removed_by_name) == "function" then 
				log("Registering removed event for ".. s)
				register_event_for_in(heroturrets.on_removed_by_name,script.on_removed_by_name,s)
			end
			if script.on_spawned_by_name ~= nil then 
				log("Registering spawned event for ".. s)
				register_event_for_in(heroturrets.on_spawned_by_name,script.on_spawned_by_name,s)
			end
			if script.on_damage_by_name ~= nil then 
				log("Registering damage event for ".. s)
				register_event_for_in(heroturrets.on_damage_by_name,script.on_damage_by_name,s)
			end
			if script.on_selected_by_name ~= nil then 
				log("Registering selected event for ".. s)
				register_event_for_in(heroturrets.on_selected_by_name,script.on_selected_by_name,s)
			end
			if script.on_pick_up_by_name ~= nil then 
				log("Registering pick up event for ".. s)
				register_event_for_in(heroturrets.on_pick_up_by_name,script.on_pick_up_by_name,s)
			end
			--if script.on_adjust_by_name ~= nil then 
			--	log("Registering adjust event for ".. s)
			--	register_event_for_in(heroturrets.on_adjust_by_name,script.on_adjust_by_name,s)
			--end
			if script.on_player_rotated_entity_by_name ~= nil then 
				log("Registering rotated entity event for ".. s)
				register_event_for_in(heroturrets.on_player_rotated_entity_by_name,script.on_player_rotated_entity_by_name,s)
			end
		end
	end
	end

local local_create_element = function(parent,type,name,caption,tooltip)
	if not (parent and parent.valid) then return nil end
	local element = {}
	element.type    = type
	element.name    = name
	element.caption = caption
	element.tooltip = tooltip
	return element
	end

local local_add_frame_or_flow = function(parent, type, name, caption, direction, style)
	local element = local_create_element(parent,type, name, caption,nil)
	if element == nil then return nil end
	element.style = style
	element.direction = direction
	return parent.add(element)	
	end

local local_add_flow = function(parent, name, direction, style)
	return local_add_frame_or_flow(parent, "flow", name, nil, direction, style)
	end

local local_add_label = function(parent, name, caption, style)
	local element = local_create_element(parent,"label", name, caption,nil)
	if element == nil then return nil end
	element.style = style or "label"
	return parent.add(element)
	end



function hero_1_detail(flow)
	local detail_flow = local_add_flow(flow,"ht-1-dtf","vertical",nil)
end
function hero_2_detail(flow)
	local detail_flow = local_add_flow(flow,"ht-2-dtf","vertical",nil)
end
function hero_3_detail(flow)
	local detail_flow = local_add_flow(flow,"ht-3-dtf","vertical",nil)
end
function hero_4_detail(flow)
	local detail_flow = local_add_flow(flow,"ht-4-dtf","vertical",nil)
end

--[[Called first time mod is added to current game instance. Called Once]]
local local_on_init = function()
	log("control.local_on_init")
	--[[	if remote.interfaces["heroturrets"] == nil then
		remote.add_interface("heroturrets",
		{hero_1_detail = hero_1_detail,
		hero_2_detail = hero_2_detail,
		hero_3_detail = hero_3_detail,
		hero_4_detail = hero_4_detail})
	end
	remote.call("wiki","register_mod_wiki",heroturrets_wiki)]]
	if global.heroturrets == nil then global.heroturrets = {allow_pickup_rotations = false} end	
	for k=1, #heroturrets.on_init do local v = heroturrets.on_init[k]		
		v()
	end
	global.heroturrets.initialized = true 
	end
script.on_init(local_on_init)


--[[Called subsequent times mod is loaded. Called each time except first instance]]
script.on_load(function()
	log("control.on_load")
	
--[[	if remote.interfaces["heroturrets"] == nil then
		remote.add_interface("heroturrets",
		{hero_1_detail = hero_1_detail,
		hero_2_detail = hero_2_detail,
		hero_3_detail = hero_3_detail,
		hero_4_detail = hero_4_detail})
	end
	remote.call("wiki","register_mod_wiki",heroturrets_wiki)]]
	for k=1, #heroturrets.on_load do local v = heroturrets.on_load[k]		
		v()
	end 
	end)	

script.on_configuration_changed(function(f) 

	
	if f.mod_changes["heroturrets"] == nil or f.mod_changes["heroturrets"].old_version == nil then
		if heroturrets.force_configuration_change == true then
			log("Forcing update to " .. game.active_mods["heroturrets"])
			f.mod_changes["heroturrets"] = 
			{
				new_version = game.active_mods["heroturrets"],
				old_version = "0.1.1"
			} 
		else
			return
		end
	end

	log("control.on_configuration_changed " .. f.mod_changes["heroturrets"].old_version .. " -> " .. f.mod_changes["heroturrets"].new_version)

	for k=1, #heroturrets.on_configuration_changed do local v = heroturrets.on_configuration_changed[k]		
		v(f)
	end

	--[[if f.mod_changes["heroturrets"].old_version < "0.1.25" then	
		for i = 1, #game.players do local p = game.players[i]
			p.force.reset_technologies() -- not working as hoped
		end
	
	end]]
	
	end)


require("prototypes.scripts.turrets")

local local_on_standard_entity_event = function(entity, table, table_by_name, event)	
	if is_map_editor == true then return end
	if is_valid(entity) then			
		for k=1, #table do local v = table[k]		
			v(entity,event)
		end
		if table_by_name ~= nil and is_valid_and_persistant(entity) then
			local tbl = table_by_name[entity.name]
			if tbl ~= nil then
				for k=1, #tbl do local v = tbl[k]		
					v(entity,event)
				end
			end
		end
	end end

local local_on_entity_cloned = function (event)
	for k=1, #heroturrets.on_entity_cloned do local v = heroturrets.on_entity_cloned[k]		
		v(event)
	end 
end

--[[done]]
local local_on_added = function(event)	
	if event.created_entity ~= nil then
		local_on_standard_entity_event(event.created_entity,heroturrets.on_added,heroturrets.on_added_by_name,event)
	elseif event.entity ~= nil then
		local_on_standard_entity_event(event.entity,heroturrets.on_added,heroturrets.on_added_by_name,event)
	end
	end
--[[done]]
local local_on_spawned = function(event)
	local_on_standard_entity_event(event.entity,heroturrets.on_spawned,heroturrets.on_spawned_by_name,event)
	end
--[[done]]
local local_on_removed = function(event)
	local_on_standard_entity_event(event.entity,heroturrets.on_removed,heroturrets.on_removed_by_name,event)
	end
--[[done]]
local local_on_damage = function(event)
	local_on_standard_entity_event(event.entity,heroturrets.on_damage,heroturrets.on_damage_by_name,event)
	end
--[[done]]
local local_item_pick_up = function(event)
	if is_map_editor == true then return end
	local stack = event.item_stack
	if stack == nil then stack = event.buffer end
	if stack ~= nil then				
		for k=1, #heroturrets.on_pick_up do local v = heroturrets.on_pick_up[k]		
			v(stack,event)
		end
		local tbl = heroturrets.on_pick_up_by_name[stack.name]
		if tbl ~= nil then
			for k=1, #tbl do local v = tbl[k]		
				v(stack,event)
			end
		end
	end 
	end
--[[done]]
local local_on_research = function(event)
	for k=1, #heroturrets.on_research do local v = heroturrets.on_research[k]
		v(event)
	end 
	end
--[[done]]
local local_on_chunk_charted = function(event)
	if is_map_editor == true then return end
	for k=1, #heroturrets.on_chunk_charted do local v = heroturrets.on_chunk_charted[k]
		v(event)
	end 
	end
local local_on_chunk_generated = function(event)
	if is_map_editor == true then return end
	for k=1, #heroturrets.on_chunk_generated do local v = heroturrets.on_chunk_generated[k]
		v(event)
	end 
	end
--[[done]]
local local_on_gui_click = function(event)
	for k=1, #heroturrets.on_gui_click do local v = heroturrets.on_gui_click[k]
		v(event)
	end 
	end
--[[done]]
local local_on_player_spawned = function(event)
	if is_map_editor == true then return end
	for k=1, #heroturrets.on_player_spawned do local v = heroturrets.on_player_spawned[k]
		v(event)
	end 
	end
--[[done]]
local local_on_start = function()
	log("control.local_on_start")	
	for k=1, #heroturrets.on_start do local v = heroturrets.on_start[k]	
		v()
	end 
	return true
	end
--[[done]]
local local_on_tick = function()
	if game.tick > 1 and run_init ~= true then run_init = local_on_start() end
	for k=1, #heroturrets.ticks do local v = heroturrets.ticks[k]	
		v()
	end 
	end
--[[done]]
local local_on_tick_low = function()
	for k=1, #heroturrets.ticks_low do local v = heroturrets.ticks_low[k]	
		v()
	end 
	end
--[[done]]
local local_on_tick_med = function()
	for k=1, #heroturrets.ticks_med do local v = heroturrets.ticks_med[k]	
		v()
	end 
	end
--[[done]]
local local_on_tick_high = function()
	for k=1, #heroturrets.ticks_high do local v = heroturrets.ticks_high[k]
		v()
	end 
	end

local local_on_post_entity_died = function(event)
	for k=1, #heroturrets.on_post_entity_died  do local v = heroturrets.on_post_entity_died [k]
		v(event)
	end 
	end

local local_on_ai_command_completed	= function(event)
	for k=1, #heroturrets.on_ai_command_completed do local v = heroturrets.on_ai_command_completed[k]
		v(event)
	end
end

--[[done]]
local local_on_selected = function(event)
	player = game.players[event.player_index]
	entity = player.selected	
	for k=1, #heroturrets.on_selected do local v = heroturrets.on_selected[k]
		v(player,entity)
	end
	if is_valid(entity) ~= true then return end
	local on_selected_by_name = heroturrets.on_selected_by_name[entity.name]
	if on_selected_by_name ~= nil then
		for k=1, #on_selected_by_name do local v = on_selected_by_name[k]		
			v(player, entity)
		end
	end
	end

	--[[done]]
local local_on_player_cursor_stack_changed = function(event)
	for k=1, #heroturrets.on_player_cursor_stack_changed do local v = heroturrets.on_player_cursor_stack_changed[k]
		v(event)
	end
	end

--[[done]]
local local_on_train_changed_state = function(event)
	for k=1, #heroturrets.on_train_changed_state do local v = heroturrets.on_train_changed_state[k]
		v(event)
	end	
	end


local local_on_trigger_created_entity = function(event)					
	local entity = event.entity	
	if entity ~= nil then	
		for k=1, #heroturrets.on_trigger_created_entity do local v = heroturrets.on_trigger_created_entity[k]		
			v(event)
		end
	end end
	
--[[done]]
local local_on_player_rotated_entity = function(event)
	local_on_standard_entity_event(event.entity,heroturrets.on_player_rotated_entity,on_player_rotated_entity_by_name)
	end
	
--[[done]]
--[[local local_on_adjust = function(event)
	player = game.players[event.player_index]
	entity = player.selected
	local_on_standard_entity_event(entity,heroturrets.on_adjust,heroturrets.on_adjust_by_name)
	end]]

script.on_event(defines.events.on_player_toggled_map_editor,function(event)
	if is_map_editor == true then is_map_editor = false
	else is_map_editor = true end
	end)


script.on_event({on_player_joined_game,defines.events.on_player_created},local_on_player_spawned)
script.on_event(build_events, local_on_added)
script.on_event(remove_events, local_on_removed)
script.on_event(item_pick_up_events, local_item_pick_up)
script.on_event(defines.events.on_entity_damaged,local_on_damage)
script.on_event(defines.events.on_research_finished, local_on_research)
script.on_event(defines.events.on_player_cursor_stack_changed,local_on_player_cursor_stack_changed)
script.on_event(defines.events.on_entity_spawned, local_on_spawned)
script.on_event(defines.events.on_chunk_charted,local_on_chunk_charted)
script.on_event(defines.events.on_chunk_generated,local_on_chunk_generated)
script.on_event(defines.events.on_train_changed_state,local_on_train_changed_state)
script.on_event(defines.events.on_tick, local_on_tick)
script.on_event(defines.events.on_ai_command_completed, local_on_ai_command_completed)
script.on_event(defines.events.on_trigger_created_entity, local_on_trigger_created_entity)

script.on_nth_tick(low_priority, local_on_tick_low)
script.on_nth_tick(medium_priority, local_on_tick_med)
script.on_nth_tick(high_priority, local_on_tick_high)

script.on_event(defines.events.on_gui_click, local_on_gui_click)
script.on_event(defines.events.on_selected_entity_changed,local_on_selected)	
script.on_event(defines.events.on_post_entity_died,local_on_post_entity_died)
script.on_event(defines.events.on_player_rotated_entity,local_on_player_rotated_entity) 
--script.on_event("automate-target",local_on_adjust)

script.on_event(defines.events.on_entity_cloned,local_on_entity_cloned) 

script.on_event(defines.events.on_gui_click, landmine_on_gui_click)