---@diagnostic disable: different-requires

--------------------------------------------------------------------------------
-- Relm utility functions and hooks.
--------------------------------------------------------------------------------

local relm = require("lib.core.relm.relm")
local scheduler = require("lib.core.scheduler")
local tlib = require("lib.core.table")
local event = require("lib.core.event")

local lib = {}

--------------------------------------------------------------------------------
-- Util
--------------------------------------------------------------------------------

---@param handle Relm.Handle
---@param new_state table
function lib.assign_state(handle, new_state)
	relm.set_state(handle, function(current_state)
		---@cast current_state table
		local x = tlib.assign({}, current_state)
		return tlib.assign(x, new_state)
	end)
end

---@param handle Relm.Handle
---@param key string
---@param value any
function lib.set_state_key(handle, key, value)
	relm.set_state(handle, function(current_state)
		---@cast current_state table
		local x = tlib.assign({}, current_state)
		x[key] = value
		return x
	end)
end

--------------------------------------------------------------------------------
-- Events -> Relm
--------------------------------------------------------------------------------

-- Generic handler to convert dynamic events to relm messages
event.register_dynamic_handler("relm_message", function(ev, arg, ...)
	local handle = arg[1]
	if relm.is_valid(handle) then
		relm.msg(handle, {
			key = arg[2],
			event_name = ev,
			...,
		})
	else
		return event.REMOVE_BINDING
	end
end)

local function use_event_binder(handle, event_name)
	return event.dynamic_bind(event_name, "relm_message", { handle, event_name })
end

local function use_event_unbinder(id)
	if id then return event.dynamic_unbind(id) end
end

---Bind a Relm component to an event using `dynamic_bind`. Whenever the
---event is dispatched, your
---component will receive a message with the event name as key, and
---the event args in the array portion of the payload.
---@param on_event string
function lib.use_event(on_event)
	relm.use_effect(on_event, use_event_binder, use_event_unbinder)
end

event.register_dynamic_handler("relm_closure", function(ev, arg, ...)
	local handle = arg[1]
	local closure = arg[2]
	local event_name = arg[3]
	if relm.is_valid(handle) then
		relm.invoke_closure(handle, closure, handle, event_name, ...)
	else
		return event.REMOVE_BINDING
	end
end)

local function events_unbinder(ids)
	if ids then
		for _, id in pairs(ids) do
			event.dynamic_unbind(id)
		end
	end
end

---Call a function whenever an event is dispatched via Core Events.
---@param events Core.EventName|Core.EventName[]
---@param handler fun(me: Relm.Handle, event: Core.EventName, ...: any) Handler function. Receives a handle to the component, the Core Events event name, as well as any arguments dispatched with the event.
function lib.use_event_handler(events, handler)
	local _, closure = relm.use_closure(handler)
	-- These are OK: event names are encodable as serializable str/ints.
	---@diagnostic disable-next-line: param-type-mismatch
	relm.use_effect(events, function(me, _events)
		local ids = {}
		for _, ev in tlib.iter(_events) do
			ids[#ids + 1] =
				---@diagnostic disable-next-line: param-type-mismatch
				event.dynamic_bind(ev, "relm_closure", { me, closure, ev })
		end
		return ids
	end, events_unbinder)
end

--------------------------------------------------------------------------------
-- Scheduler -> Relm
--------------------------------------------------------------------------------

scheduler.register_handler("relm_timer", function(task)
	local data = task.data
	if data then
		local component = data[1]
		if relm.is_valid(component) then
			relm.msg(component, { key = data[2] })
			return
		end
	end
	return scheduler.ABORT
end)

scheduler.register_handler("relm_closure", function(task)
	local data = task.data
	if data then
		local component = data[1]
		local closure = data[2]
		if relm.is_valid(component) then
			relm.invoke_closure(component, closure, component)
			return
		end
	end
	return scheduler.ABORT
end)

local function use_timer_binder(handle, period_msg)
	return scheduler.every(period_msg[1], "relm_timer", { handle, period_msg[2] })
end

local function use_timer_unbinder(id) scheduler.stop(id) end

---Send the given message to the component every `period` ticks.
---@param period uint The period in ticks to send the message.
---@param msg string The message to send to the component. The message will be sent with the key `msg`.
function lib.use_timer(period, msg)
	relm.use_effect({ period, msg }, use_timer_binder, use_timer_unbinder)
end

---Execute the given handler every `period` ticks.
---@param period uint The period in ticks.
---@param handler fun(me: Relm.Handle): nil The closure to execute. It will be passed the component handle as an argument.
function lib.use_timer_handler(period, handler)
	local _, relm_closure = relm.use_closure(handler)
	relm.use_effect(period, function(me, _period)
		---@cast _period uint
		return scheduler.every(_period, "relm_closure", { me, relm_closure })
	end, use_timer_unbinder)
end

return lib
