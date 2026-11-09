--Forked from Maraxsis

local events = {}
local Public = {}

---Drop-in replacement for script.on_event however it supports multiple handlers per event. You can also use 'on_built' 'on_destroyed' and 'on_init' as shortcuts for multiple events.
---@param event defines.events|defines.events[]|string
---@param f function
Public.on_event = function(event, f,filters)
	for _, event in pairs(type(event) == "table" and event or {event}) do
		event = tostring(event)
		events[event] = events[event] or {}
		table.insert(events[event], {cached_function = f,filters = filters})
	end
end

Public.on_nth_tick = function(event, f)
	events[event] = events[event] or {}
	table.insert(events[event], {cached_function = f,filters = nil})
end

local function one_function_from_many(functions,event_handler)
	local l = #functions
	if l == 1 then return {functions[1].cached_function,functions[1].filters} end
	local filters = {}
	local every_function_has_filter = true
	local some_functions_have_filters = false
	for _,func in pairs(functions) do
		local force_or = true --First rule of every filter must be "or" to properly work with filters from other events.
		if func.filters then
			some_functions_have_filters = true
			for _,filter in pairs(func.filters) do
				if force_or then
					filter.mode = "or"
					force_or = false
				end
				table.insert(filters,filter)
			end
		else
			every_function_has_filter = false --If not all functions of a type has a filter, none can work properly.
		end
		
	end
	if some_functions_have_filters and not every_function_has_filter then
		error("Some, but not all events with event type ".. event_handler.." have a filter!\n" .. serpent.block(functions))
	end
	return {function(arg)
		for i = 1, l do
			local func_to_run = functions[i].cached_function
			func_to_run(arg)
		end
	end,
	every_function_has_filter and filters or nil

	}
end

local powers_of_two = {}
for i = 0, 20 do
	powers_of_two[i] = 2 ^ i
end

local finalized = false
-- Composed handler for every finalized nth-tick, so an idle timer can be
-- switched off and on without unregistering other handlers by accident.
local nth_tick_handlers = {}

---Enable or disable an nth-tick handler that was registered with
---`on_nth_tick` before `finalize_events`.
---
---Use this for work that only needs a timer while something is pending. The
---engine call itself is cheap, but a handler that runs forever to inspect an
---empty table is still work in every save.
---@param tick integer
---@param enabled boolean
function Public.set_nth_tick_enabled(tick, enabled)
    local handler = nth_tick_handlers[tick]
    if not handler then
        error("No nth-tick handler registered for tick " .. tostring(tick))
    end
    script.on_nth_tick(tick, enabled and handler or nil)
end

Public.finalize_events = function()
	if finalized then error("Events already finalized") end
	local i = 0
	for event, functions in pairs(events) do
		local func_and_filter = one_function_from_many(functions,event)
		local f = func_and_filter[1]
		local filter = func_and_filter[2]
		if type(event) == "number" then
			nth_tick_handlers[event] = f
			script.on_nth_tick(event, f)
		elseif event == Public.events.on_init() then
			script.on_init(f)
			script.on_configuration_changed(f)
		elseif event == Public.events.on_load() then
			script.on_load(f)
		elseif event == tonumber(defines.events.on_biter_base_built) then
			script.on_event(tonumber(event) or event, f)
		else
			script.on_event(tonumber(event) or event, f,filter)
		end
		i = i + 1
	end
	finalized = true
	log("Finalized " .. i .. " events for " .. script.mod_name)
end

_G.gui_events = {
	[defines.events.on_gui_click] = {},
	[defines.events.on_gui_confirmed] = {},
	[defines.events.on_gui_text_changed] = {},
	[defines.events.on_gui_checked_state_changed] = {},
	[defines.events.on_gui_selection_state_changed] = {},
	[defines.events.on_gui_checked_state_changed] = {},
	[defines.events.on_gui_elem_changed] = {},
	[defines.events.on_gui_value_changed] = {},
	[defines.events.on_gui_location_changed] = {},
	[defines.events.on_gui_selected_tab_changed] = {},
	[defines.events.on_gui_switch_state_changed] = {}
}
local function process_gui_event(event)
	if event.element and event.element.valid then
		for pattern, f in pairs(gui_events[event.name]) do
			if event.element.name:match(pattern) then
				f(event); return
			end
		end
	end
end

for event, handlers in pairs(gui_events) do
	-- Registering an event makes the engine call into Lua for every occurrence
	-- (including on_gui_value_changed and on_gui_text_changed, which fire many
	-- times per second while dragging or typing). Skip the events that have no
	-- handler pattern at load time.
	if next(handlers) ~= nil then
		Public.on_event(event, process_gui_event)
	end
end

local delayed_functions = {}
---use this to execute a script after a delay
---example:
---Public.register_delayed_function('my_delayed_func', function(param1, param2, param3) ... end)
---Public.execute_later('my_delayed_func', 60, param1, param2, param3)
---The above code will execute my_delayed_func after waiting for 60 ticks
---@param function_key string
---@param ticks integer
---@param ... any
function Public.execute_later(function_key, ticks, ...)
	local marked_for_death_render_object = rendering.draw_line {
		color = {0, 0, 0, 0},
		width = 0,
		filled = false,
		from = {0, 0},
		to = {0, 0},
		create_build_effect_smoke = false,
		surface = "nauvis",
		time_to_live = ticks
	}
	storage._delayed_functions = storage._delayed_functions or {}
	storage._delayed_functions[script.register_on_object_destroyed(marked_for_death_render_object)] = {function_key, {...}}
end

Public.on_event(defines.events.on_object_destroyed, function(event)
	if not storage._delayed_functions then return end
	local registration_number = event.registration_number
	local data = storage._delayed_functions[registration_number]
	if not data then return end
	storage._delayed_functions[registration_number] = nil

	local f = delayed_functions[data[1]]
	if not f then error("No function found for key: " .. tostring(data[1])) end
	f(table.unpack(data[2]))
end)

function Public.register_delayed_function(key, func)
	delayed_functions[key] = func
end

-- Sentinel values for defining groups of events
Public.events = {
	--- Called after an entity is constructed.
	--- Note: Using this event may be bad practice. Consider instead defining `created_effect` in the entity prototype.
	---
	--- entity.created_effect = {
	--- 	type = 'direct',
	--- 	action_delivery = {
	--- 		type = 'instant',
	--- 		source_effects = {
	--- 			type = 'script',
	--- 			effect_id = 'on_built_[ENTITY NAME]'
	--- 		}
	--- 	}
	--- }
	on_player_moved = function()
		return {
			"move-up",
			"move-down",
			"move-left",
			"move-right",
		}
	end,
	on_built = function()
		return {
			defines.events.on_built_entity,
			defines.events.on_robot_built_entity,
			defines.events.script_raised_built,
			defines.events.script_raised_revive,
			defines.events.on_space_platform_built_entity,
			--defines.events.on_biter_base_built
		}
	end,
	
	--- Called after the results of an entity being mined are collected just before the entity is destroyed. [...]
	on_destroyed = function()
		return {
			defines.events.on_player_mined_entity,
			defines.events.on_robot_mined_entity,
			defines.events.on_entity_died,
			defines.events.script_raised_destroy,
			defines.events.on_space_platform_mined_entity
		}
	end,
	--- Called after a tile is built.
	on_built_tile = function()
		return {
			defines.events.on_robot_built_tile,
			defines.events.on_player_built_tile,
			defines.events.on_space_platform_built_tile,
		}
	end,
	on_mined_tile = function()
		return {
			defines.events.on_player_mined_tile,
			defines.events.on_robot_mined_tile,
			defines.events.on_space_platform_mined_tile,
		}
	end,
	--- Called for on_init and on_configuration_changed
	on_init = function()
		return "ON INIT EVENT"
	end,
	--- Called when a save is loaded, including when a client joins a server.
	--- Handlers must not modify `storage`.
	on_load = function()
		return "ON LOAD EVENT"
	end,
	--- Custom event for when a player clicks on an entity
	on_entity_clicked = function()
		return "build"
	end
}

return Public