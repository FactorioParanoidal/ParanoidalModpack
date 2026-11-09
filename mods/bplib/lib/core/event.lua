-- Core event handling implementation. Loosely based on the stdlib event system.
-- Implementation should be more performant, and has support for correct
-- dynamic event binding as well as subtick event triggers.

local require_guard = require("lib.core.require").require_guard
require_guard("lib.core.event")
local tlib = require("lib.core.table")
local strace = require("lib.core.strace")

local type = _G.type
local next = next
local tinsert = table.insert
local pairs = _G.pairs
local table_size = _G.table_size

local EMPTY = setmetatable({}, { __newindex = function() end })
local REMOVE_BINDING = setmetatable({}, { __newindex = function() end })

---Name of a specific event. May be a positive integer representing a `defines.event`, a string representing a custom user event, or a negative integer representing a tick interval (e.g. -60 for once per second).
---@alias Core.EventName int|string|defines.events

---Opaque identifier for a dynamic binding.
---@alias Core.EventDynamicBindingId int64

---@alias Core.EventDynamicBindings { [Core.EventDynamicBindingId]: [ Core.EventName, string, any?, any? ] }

---@alias Core.EventStorage { [Core.EventName]: Core.EventDynamicBindings }

---@alias Core.EventDynamicHandlerResult any

---@alias Core.EventDynamicHandler fun(event_name: Core.EventName, handler_data: any, ...): Core.EventDynamicHandlerResult?

---@alias Core.EventHandler.on_init fun()
---@alias Core.EventHandler.on_load fun()
---@alias Core.EventHandler.on_configuration_changed fun(data: ConfigurationChangedData)
---@alias Core.EventHandler.on_nth_tick fun(data: NthTickEventData)
---@alias Core.EventHandler.on_startup fun(reset_data: Core.ResetData)
---@alias Core.EventHandler.on_shutdown fun(reset_data: Core.ResetData)
---@alias Core.EventHandler.on_try_shutdown fun(reset_data: Core.ResetData)

---@alias Core.EventRaiser.NoArg fun(name: string)
---@alias Core.EventRaiser Core.EventRaiser.NoArg

---@alias Core.EventBinder.NoArg fun(name: string, handler: fun(), first?: boolean)
---@alias Core.EventBinder Core.EventBinder.NoArg

---@class Core.ResetData
---@field public init boolean True if this is the first initialization of the mod.
---@field public handoff boolean True if this is a handoff for a startup/shutdown sequence.
---@field public veto_shutdown? LocalisedString[] If present, shutdown is being attempted. If you would like to veto the shutdown, insert a reason string into this list.
---@field public startup_warnings? LocalisedString[] Warnings to present after startup. If an unclean shutdown left lingering state, it's a good idea to push a warning here during `on_startup`.

local script_event_set = {
	["on_init"] = true,
	["on_load"] = true,
	["on_configuration_changed"] = true,
	["on_nth_tick"] = true,
	["on_startup"] = true,
	["on_shutdown"] = true,
	["on_try_shutdown"] = true,
}

---@type {[int|string]: fun(...)[]}
local static_handlers = {}

---@type {[string]: Core.EventDynamicHandler}
local registered_dynamic_handlers = {}

---@param key int|string
---@param handler fun(...)
---@param first boolean?
local function add_static_handler(key, handler, first)
	local handlers = static_handlers[key]
	if not handlers then
		handlers = {}
		static_handlers[key] = handlers
	end
	if first then
		tinsert(handlers, 1, handler)
	else
		handlers[#handlers + 1] = handler
	end
end

---Generate a function that runs the given static handlers
local function meta_run_static_handlers(key)
	local handlers = static_handlers[key]
	if not handlers then
		handlers = {}
		static_handlers[key] = handlers
	end
	return function(...)
		for i = 1, #handlers do
			---@diagnostic disable-next-line: need-check-nil
			handlers[i](...)
		end
	end
end

script.on_init(meta_run_static_handlers("on_init"))
script.on_load(meta_run_static_handlers("on_load"))
script.on_configuration_changed(
	meta_run_static_handlers("on_configuration_changed")
)

---@type {[defines.events]: true}
local bound_game_events = {}

local function make_event_callback(event_name, handlers)
	return function(...)
		for i = 1, #handlers do
			handlers[i](...)
		end
		-- Diag disabled: approved storage injection
		---@diagnostic disable-next-line: undefined-field
		local dynamic_handlers = (storage._event or EMPTY)[event_name]
		if dynamic_handlers then
			local was_removed = false
			for binding_id, binding in pairs(dynamic_handlers) do
				local handler = registered_dynamic_handlers[binding[2]]
				if handler then
					local result = handler(binding[1], binding[3], ...)
					if result == REMOVE_BINDING then
						dynamic_handlers[binding_id] = nil
						was_removed = true
					end
				end
			end
			if was_removed then
				-- Diag disabled: approved storage injection
				---@diagnostic disable-next-line: undefined-field
				if not next(dynamic_handlers) then storage._event[event_name] = nil end
			end
		end
	end
end

local function bind_game_event(event_name, filters)
	if bound_game_events[event_name] then return end
	bound_game_events[event_name] = true

	local handlers = static_handlers[event_name]
	if not handlers then
		handlers = {}
		static_handlers[event_name] = handlers
	end
	script.on_event(
		event_name,
		make_event_callback(event_name, handlers),
		filters
	)
end

local function bind_tick(minus_dt)
	if bound_game_events[minus_dt] then return end
	bound_game_events[minus_dt] = true

	local handlers = static_handlers[minus_dt]
	if not handlers then
		handlers = {}
		static_handlers[minus_dt] = handlers
	end
	-- EmmyLua wierdness
	---@diagnostic disable-next-line: param-type-mismatch
	script.on_nth_tick(-minus_dt, make_event_callback(minus_dt, handlers))
end

local function bind_any_event(event_name, filters)
	if
		type(event_name) == "string"
		and defines.events[event_name]
		and not script_event_set[event_name]
	then
		event_name = defines.events[event_name] --[[@as integer]]
	end

	if type(event_name) == "number" then
		if event_name >= 0 then
			bind_game_event(event_name, filters)
		else
			bind_tick(event_name)
		end
	end
	return event_name
end

---@class Core.Lib.Event
local event = {}

---A sentinel value that can be returned from a dynamic event handler
---instructing the event system to remove the dynamic binding.
event.REMOVE_BINDING = REMOVE_BINDING

---Unconditionally bind a handler to an event. This MUST be called at the top
---of the control phase and MUST NOT be called conditionally. Handlers may not
---be unbound.
---@overload fun(event_names: Core.EventName, handler: fun(...), first?: boolean, filters?: table)
---@overload fun(event_names: Core.EventName[], handler: fun(...), first?: boolean, filters?: table)
---@overload fun(event_names: defines.events, handler: fun(...), first?: boolean, filters?: table)
---@overload fun(event_names: defines.events[], handler: fun(...), first?: boolean, filters?: table)
---@param event_names Core.EventName|(Core.EventName[]) The event to bind to. May be a string for a custom event, a member of `defines.events`, or the return value of `event.nth_tick`. Multiple events may be given as an array.
---@param handler fun(...) The handler function.
---@param first boolean? If true, the handler will be called before other handlers for the event. Use with care.
---@param filters? table Passed to `script.on_event` as the `filters` argument when binding to game events. NOTE: The first `filters` argument is the only one the game will see. Subsequent bindings will be against the same filters.
function event.bind(event_names, handler, first, filters)
	for _, event_name in tlib.iter(event_names) do
		event_name = bind_any_event(event_name, filters)
		add_static_handler(event_name, handler, first)
	end
end

---Raise a user-defined event.
---@param user_event_name string The name of the user event to raise.
---@param ... any Arguments to pass to the event handlers.
function event.raise(user_event_name, ...)
	local handlers = static_handlers[user_event_name]
	if handlers then
		for i = 1, #handlers do
			handlers[i](...)
		end
	end
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	local dynamic_handlers = (storage._event or EMPTY)[user_event_name]
	if dynamic_handlers then
		local was_removed = false
		for binding_id, binding in pairs(dynamic_handlers) do
			local handler = registered_dynamic_handlers[binding[2]]
			if handler then
				local result = handler(binding[1], binding[3], ...)
				if result == REMOVE_BINDING then
					dynamic_handlers[binding_id] = nil
					was_removed = true
				end
			end
		end
		if was_removed then
			if not next(dynamic_handlers) then
				-- Diag disabled: approved storage injection
				---@diagnostic disable-next-line: undefined-field
				storage._event[user_event_name] = nil
			end
		end
	end
end

---Generate event name for the on_nth_tick event for given n.
---@param n integer The tick interval. Must be a positive integer.
---@return Core.EventName event_name The event name to use for binding.
function event.nth_tick(n)
	if type(n) ~= "number" or n <= 0 or n % 1 ~= 0 then
		error("tick interval must be a positive integer")
	end
	return -n
end

---Dynamically bind a handler to an event in such a way that it may be later
---unbound. This may be called at any time, but the handler must be among
---a registered set of named functions (see `event.register_dynamic_handler`).
---@param event_names Core.EventName|Core.EventName[] The event to bind to.
---@param handler_name string The name of the handler to bind. Must have been registered with `event.register_dynamic_handler`.
---@param handler_data? any Optional data to pass to the handler when it is invoked. This data will be written to `storage` and must be serializable.
---@return Core.EventDynamicBindingId binding_id An opaque ID that may be used to unbind the handler later.
function event.dynamic_bind(event_names, handler_name, handler_data)
	if not registered_dynamic_handlers[handler_name] then
		error("unknown dynamic handler: " .. handler_name)
	end

	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	local id = storage._event_id + 1
	---@diagnostic disable-next-line: inject-field
	storage._event_id = id

	for _, event_name in tlib.iter(event_names) do
		if script_event_set[event_name] then
			error("cannot dynamically bind to core script event: " .. event_name)
		end
		event_name = bind_any_event(event_name)
		-- Diag disabled: approved storage injection
		---@diagnostic disable-next-line: undefined-field
		if not storage._event[event_name] then storage._event[event_name] = {} end
		---@diagnostic disable-next-line: undefined-field
		storage._event[event_name][id] = { event_name, handler_name, handler_data }
	end

	return id
end

---Unbind a handler previously bound with `event.dynamic_bind`.
---@param binding_id Core.EventDynamicBindingId The binding ID returned from `event.dynamic_bind`.
---@return boolean unbound True if a binding was found and removed.
function event.dynamic_unbind(binding_id)
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	for event_name, ev in pairs(storage._event) do
		if ev[binding_id] then
			ev[binding_id] = nil
			-- Diag disabled: approved storage injection
			---@diagnostic disable-next-line: undefined-field
			if not next(ev) then storage._event[event_name] = nil end
			return true
		end
	end
	return false
end

---Register a named handler that may be bound to dynamic events.
---@param handler_name string The name of the handler. Must be unique throughout the Lua session.
---@param handler Core.EventDynamicHandler The handler function. The first argument is the event name that was fired, the second argument is the `handler_data` passed to `event.dynamic_bind`, and any further arguments are those passed to the event when it is raised. If the handler returns `event.REMOVE_BINDING`, the dynamic binding will be removed.
function event.register_dynamic_handler(handler_name, handler)
	if registered_dynamic_handlers[handler_name] then
		error("duplicate dynamic handler registration: " .. handler_name)
	end
	registered_dynamic_handlers[handler_name] = handler
end

local INVISIBLE_LINE = {
	color = { 0, 0, 0, 0 },
	width = 0,
	from = { 0, 0 },
	to = { 0, 0 },
	surface = 1,
}

---Cause a dynamic event handler to be triggered on the next subtick.
---@param handler_name string The name of the handler to trigger. This
---must have been registered with `event.register_dynamic_handler`.
---@param event_name string The name of the event to pass to the handler as its first argument.
---@param handler_data? any Optional data to pass to the handler when it is invoked. This data will be written to `storage` and must be serializable.
function event.dynamic_subtick_trigger(handler_name, event_name, handler_data)
	local obj = rendering.draw_line(INVISIBLE_LINE)
	local rn = script.register_on_object_destroyed(obj)
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	---@diagnostic disable-next-line: inject-field
	if not storage._event_subtick then storage._event_subtick = {} end
	---@diagnostic disable-next-line: undefined-field
	storage._event_subtick[rn] = { event_name, handler_name, handler_data }
	obj.destroy()
end

--------------------------------------------------------------------------------
-- BUILT-IN EVENT HANDLERS
--------------------------------------------------------------------------------

event.bind(defines.events.on_object_destroyed, function(ev)
	local rn = ev.registration_number
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	local binding = (storage._event_subtick or EMPTY)[rn]
	if not binding then return end

	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	storage._event_subtick[rn] = nil
	local handler = registered_dynamic_handlers[binding[2]]
	if handler then handler(binding[1], binding[3]) end
end)

event.bind(
	"on_init",
	function() event.raise("on_startup", { init = true, startup_warnings = {} }) end,
	true
)

event.bind("on_startup", function(reset_data)
	---@diagnostic disable-next-line: undefined-field
	-- TODO: warn if mods didn't clear dynamic binds before resetting
	if storage._event and next(storage._event) then
		strace.warn(
			"Warning: dynamic event bindings exist at startup. You should clear dynamic bindings during shutdown to avoid lingering state."
		)
	end
	---@diagnostic disable-next-line: undefined-field
	if storage._event_subtick and next(storage._event_subtick) then
		strace.error(
			"ERROR: subtick event bindings exist at startup, this should be impossible."
		)
	end

	---@diagnostic disable-next-line: inject-field
	storage._event = {} --[[@as Core.EventStorage ]]
	---@diagnostic disable-next-line: inject-field
	storage._event_subtick = {}
	---@diagnostic disable-next-line: inject-field
	storage._event_id = 0
end)

event.bind("on_load", function()
	---@diagnostic disable-next-line: undefined-field
	if not storage._event then return end

	---@diagnostic disable-next-line: undefined-field
	-- Rebind all game events we were using.
	for event_name in pairs(storage._event) do
		bind_any_event(event_name)
	end
end)

return event
