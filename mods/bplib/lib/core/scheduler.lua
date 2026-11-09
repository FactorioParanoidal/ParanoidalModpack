---@diagnostic disable: inject-field

require("lib.core.require").require_guard("lib.core.scheduler")

local counters = require("lib.core.counters")
local event = require("lib.core.event")
local log = require("lib.core.strace")

local unpack = table.unpack
local pairs = _G.pairs
local next = _G.next
local type = _G.type
local setmetatable = _G.setmetatable

---@class Core.Lib.Scheduler
local lib = {}

local strace = nil
local ERROR = 60
local WARN = 50
local TRACE = 10

---@alias Scheduler.Handler fun(task: Scheduler.Task): any

---@alias Scheduler.TaskId integer

---@alias Scheduler.TaskSet {[Scheduler.TaskId]: true}

---@class Scheduler.Task
---@field id Scheduler.TaskId The unique identifier of the task
---@field type "once"|"many" The type of the task
---@field handler_name string The name of the callback handler
---@field data any Optional stateful data for the task. Note that this is stored in game state and must be serializable.

---@class Scheduler.OneOffTask: Scheduler.Task
---@field type "once" A one-off task
---@field at uint The tick at which the task should be executed

---@class Scheduler.RecurringTask: Scheduler.Task
---@field type "many" A recurring task
---@field period uint The number of ticks between executions
---@field next uint The next tick at which the task should be executed

---@class (exact) Scheduler.Storage
---@field tasks {[Scheduler.TaskId]: Scheduler.Task} The set of all tasks
---@field at {[uint]: Scheduler.TaskSet} The set of tasks scheduled for a given tick

---@type {[string]: Scheduler.Handler}
local handlers = {}

---Abort key that can be returned from schedule handlers to abort recurring
---tasks.
local ABORT = setmetatable({}, { __newindex = function() end })
lib.ABORT = ABORT

---Register a global handler callback for the scheduler. This should be done
---at the global level of the control phase unconditionally for each handler.
---@param name string
---@param handler Scheduler.Handler
function lib.register_handler(name, handler) handlers[name] = handler end

event.bind(
	"on_startup",
	---@param reset_data Core.ResetData
	function(reset_data)
		log.info("Scheduler: resetting state")
		-- Authorized storage injection
		---@diagnostic disable-next-line: undefined-field
		if storage._sched and storage._sched.at and next(storage._sched.at) then
			log.warn(
				"Scheduler:",
				-- Authorized storage injection
				---@diagnostic disable-next-line: undefined-field
				table_size(storage._sched.at),
				"outstanding tasks from previous state will NOT be processed."
			)
		end
		---TODO: warn about unkilled threads from previous state?
		storage._sched = {
			tasks = {},
			at = {},
		} --[[@as Scheduler.Storage]]
	end
)

local function do_at(tick, task_id)
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local state = storage._sched --[[@as Scheduler.Storage]]
	local task_set = state.at[tick]
	if not task_set then
		state.at[tick] = { [task_id] = true }
	else
		task_set[task_id] = true
	end
end

-- Tick handler. Runs every tick and executes any tasks scheduled for that tick.
---@diagnostic disable-next-line: undefined-field
if not _G.__RECOVERY_MODE__ then
	event.bind(
		event.nth_tick(1),
		---@param tick_data NthTickEventData
		function(tick_data)
			-- Authorized storage injection
			---@diagnostic disable-next-line: undefined-field
			local state = storage._sched --[[@as Scheduler.Storage]]
			if not state then return end
			local tick_n = tick_data.tick
			local task_set = state.at[tick_n]
			if task_set then
				for task_id in pairs(task_set) do
					local task = state.tasks[task_id]
					if task then
						local handler = handlers[task.handler_name]
						local handler_result = nil
						if handler then
							handler_result = handler(task)
						else
							if strace then
								strace(
									ERROR,
									"scheduler",
									"missing_handler",
									"handler_name",
									task.handler_name
								)
							end
							handler_result = ABORT
						end
						-- Returning abort code can stop recurring tasks.
						if handler_result == ABORT then state.tasks[task_id] = nil end
						if task.type == "once" then
							state.tasks[task_id] = nil
						elseif task.type == "many" then
							local rtask = task --[[@as Scheduler.RecurringTask]]
							rtask.next = tick_n + rtask.period
							do_at(rtask.next, task_id)
						end
					end
				end
				state.at[tick_n] = nil
			end
		end
	)
end

local function dont_at(state, tick, task_id)
	local task_set = state.at[tick]
	if task_set then task_set[task_id] = nil end
end

local function at(tick, handler_name, data)
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local state = storage._sched --[[@as Scheduler.Storage]]
	local task_id = counters.next("_task")
	local task = {
		id = task_id,
		type = "once",
		handler_name = handler_name,
		data = data,
		at = tick,
	}
	state.tasks[task_id] = task
	do_at(tick, task_id)
	if strace then strace(TRACE, "scheduler", "create_once", "task", task) end
	return task_id
end

local function every(first_tick, period, handler_name, data)
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local state = storage._sched --[[@as Scheduler.Storage]]
	local task_id = counters.next("_task")
	local task = {
		id = task_id,
		type = "many",
		handler_name = handler_name,
		data = data,
		period = period,
		next = first_tick,
	}
	state.tasks[task_id] = task
	do_at(first_tick, task_id)
	if strace then
		strace(TRACE, "scheduler", "create_recurring", "task", task)
	end
	return task_id
end

---Schedule a handler, previously registered with `register_handler`, to be
---executed at the given tick.
---@param tick uint The tick at which the handler should be executed
---@param handler_name string The name of the handler to execute
---@param data any Optional stateful data to be passed to the handler
---@return Scheduler.TaskId? #The unique identifier of the task, or `nil` if it couldnt be created.
function lib.at(tick, handler_name, data)
	if game and tick <= game.tick then
		if strace then
			strace(
				WARN,
				"scheduler",
				"past",
				"message",
				"attempted to schedule task in the past"
			)
		end
		return nil
	end
	if not handlers[handler_name] then
		if strace then
			strace(
				ERROR,
				"scheduler",
				"missing_handler",
				"handler_name",
				handler_name
			)
		end
		return nil
	end
	return at(tick, handler_name, data)
end

---Schedule a handler, previously registered with `register_handler`, to be
---executed in `ticks` ticks from now.
---@param ticks uint The number of ticks from now at which the handler should be executed
---@param handler_name string The name of the handler to execute
---@param data any Optional stateful data to be passed to the handler
---@return Scheduler.TaskId? #The unique identifier of the task, or `nil` if it couldnt be created.
function lib.after(ticks, handler_name, data)
	if ticks < 1 then
		if strace then
			strace(
				WARN,
				"scheduler",
				"past",
				"message",
				"attempted to schedule task in the past"
			)
		end

		return nil
	end
	return lib.at(game.tick + ticks, handler_name, data)
end

---Schedule a handler, previously registered with `register_handler`, to be
---executed every `period` ticks.
---@param period uint The number of ticks between executions
---@param handler_name string The name of the handler to execute
---@param data any Optional stateful data to be passed to the handler
---@param skew uint? Optional skew to apply to the first execution. This can be used to disperse tasks with the same period from running all on the same tick.
---@return Scheduler.TaskId? #The unique identifier of the task, or `nil` if it couldnt be created.
function lib.every(period, handler_name, data, skew)
	if not handlers[handler_name] then
		if strace then
			strace(
				ERROR,
				"scheduler",
				"missing_handler",
				"handler_name",
				handler_name
			)
		end
		return nil
	end
	local first_tick = game.tick + 1 + ((skew or 0) % period)
	return every(first_tick, period, handler_name, data)
end

---Get a task by ID if it exists.
---@param task_id Scheduler.TaskId
---@return Scheduler.Task? #The task, or `nil` if it doesn't exist.
local function get(task_id)
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local state = storage._sched --[[@as Scheduler.Storage]]
	if not state then return nil end
	return state.tasks[task_id]
end
lib.get = get

---Change the period of an existing recurring task.
---@param task_id Scheduler.TaskId
function lib.set_period(task_id, period)
	local task = lib.get(task_id) --[[@as Scheduler.RecurringTask]]
	if not task then return end
	task.period = period
end

---Stop a task
---@param task_id Scheduler.TaskId?
---@return boolean `true` if a task record was deleted
function lib.stop(task_id)
	if not task_id then return false end
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local state = storage._sched --[[@as Scheduler.Storage]]
	local task = state.tasks[task_id] --[[@as Scheduler.RecurringTask]]
	if not task then return false end
	state.tasks[task_id] = nil
	return true
end

---Set strace handler. `nil` disables tracing entirely.
---@param handler? fun(level: int, ...)
function lib.set_strace_handler(handler) strace = handler end

lib.register_handler("@call_method", function(task)
	local data = task.data
	local obj = data[1]
	local method_name = data[2]
	if obj then
		local callable = obj[method_name]
		if type(callable) == "function" then
			callable(obj, unpack(data, 3))
			return
		end
	end

	return ABORT
end)

---Call a method on a serializable object at a given tick.
---@param tick uint64
---@param serializable_object table
---@param method_name string
function lib.at_method(tick, serializable_object, method_name, ...)
	return lib.at(tick, "@call_method", { serializable_object, method_name, ... })
end
lib.call_method_at = lib.at_method

return lib
