-----------------------------------------------------------------------------------------------------------------------
-- Functions for handling long-running things over a period of time.
-- fork of async.lua from the 'What is Missing' mod from Zomis (MIT, 2024)
-----------------------------------------------------------------------------------------------------------------------
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides async functions
---@class KuxCoreLib.AsyncTask : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.AsyncTask
local AsyncTask = {
	__class  = "KuxCoreLib.AsyncTask",
	__guid   = "{5a5500ae-79d0-424e-a849-a69cfc4fd7e7}",
	__origin = "Kux-CoreLib/lib/AsyncTask.lua",
}
if not KuxCoreLib.__classUtils.ctor(AsyncTask) then return self end
-----------------------------------------------------------------------------------------------------------------------
local Storage = KuxCoreLib.Storage
local Events  = KuxCoreLib.Events

---@class KuxCoreLib.AsyncTask.private : KuxCoreLib.AsyncTask
local this = setmetatable({}, {__index = AsyncTask})

---@type KuxCoreLib.AsyncTask.LoopFactory
AsyncTask.Loop = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/AsyncTask~Loop")(this)

---@type KuxCoreLib.AsyncTask.Instance
local AsyncTask_prototype = require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/AsyncTask~prototype")(this)
-----------------------------------------------------------------------------------------------------------------------

Storage.register("storage.__KuxCoreLib__.async_tasks", "Kux-CoreLib.Async")
---@type table<integer, KuxCoreLib.AsyncTask.SaveState>
--- -> storage.__KuxCoreLib__.async_tasks
this.task_states = nil

--- Sparse array of runtime tasks
---@type table<integer, KuxCoreLib.AsyncTask.Instance>
this.tasks = {}

this.initialized = false

---@type {[string]:function} dictionary of {identifier -> function}
this.registered_functions = {}

---@type {[function]:string} dictionary of {function -> identifier}
this.registered_functions_byFnc = {}

local mt_loop_functions = {
	__index = function(t,k) error("No loop lookup function found for '" .. k .. "'. Need to check AsyncTask.registerLoopFunctions configuration") end
}

---@type {[string]:function} identifier -> function
this.loop_functions = setmetatable({}, mt_loop_functions)

local mt_dynamic_functions = {
	__index = function(t,k) error("No dynamic function found for " .. k .. ". Need to check AsyncTask.dynamic(..) calls") end
}

---@type {[string]:function} identifier -> function
this.dynamic_functions = setmetatable({}, mt_dynamic_functions)

-----------------------------------------------------------------------------------------------------------------------
-- public functions
-----------------------------------------------------------------------------------------------------------------------

---Registers a callback function for mapping identifier <-> function
---@param identifier string
---@param func function
---<p>Because Factorio no longer allows to store functions in `storage` we have to make a mapping identifier <-> function to store only the identifier.
function AsyncTask.registerFunction(identifier, func)
	if this.registered_functions[identifier] then error("Identifier " .. identifier .. " already registered") end
	if this.registered_functions_byFnc[func] then error("Function already registered. '"..this.registered_functions_byFnc[func].."'") end
	this.registered_functions[identifier] = func
	this.registered_functions_byFnc[func] = identifier
end

---Registers a table of callback functions for mapping identifier <-> function
---@param dic table<string, function>
---@param additionalPrefix string?
---<p>Because Factorio no longer allows to store functions in `storage` we have to make a mapping identifier <-> function to store only the identifier.
function AsyncTask.registerFunctions(dic, additionalPrefix)
	for identifier, func in pairs(dic) do
		this.registerFunction((additionalPrefix or "")..identifier, func)
	end
end

---Registers functions for loops
---@param dic {[string]:function} identifier -> function
function AsyncTask.registerLoopFunctions(dic)
	for key, value in pairs(dic) do
		if rawget(this.loop_functions,key) then error("Loop function " .. key .. " already registered") end
		this.loop_functions[key] = value
	end
end

---@param custom_data KuxCoreLib.AsyncTask.CustomData
---@param delay_ticks integer
---@param on_finished KuxCoreLib.AsyncTask.FinishedDelegate
---@return KuxCoreLib.AsyncTask.SaveState
function AsyncTask.delayed(custom_data, delay_ticks, on_finished)
	local sleep_loop = this.Loop.numeric("sleep", 1, delay_ticks)
	local task = this.run(custom_data, { sleep_loop }, nil, on_finished)
	return task
end

---@param custom_data KuxCoreLib.AsyncTask.CustomData
---@param loops KuxCoreLib.AsyncTask.Loop[]
---@param on_execute KuxCoreLib.AsyncTask.ExecuteDelegate?
---@param on_finished KuxCoreLib.AsyncTask.FinishedDelegate?
function AsyncTask.run(custom_data, loops, on_execute, on_finished)
	assert(on_execute~=nil or on_finished~=nil, "Invalid argument. Either 'on_execute' or 'on_finished' must be set")
	assert(loops~=nil, "Invalid argument. 'loops' must not be nil")
	assert(#loops>0, "Invalid argument. 'loops' must not be empty")
	for key, loop in pairs(loops) do
		assert(type(key) == "number", "Invalid argument. 'loops' must be an array not a dictionary")
		--assert(this.loop_functions[loop.identifier] ~= nil, "Invalid argument. Loop function not found for identifier " .. loop.identifier)
	end

	---@type KuxCoreLib.AsyncTask.SaveState
	local save_state = {
		custom_data = custom_data,
		completions = 0,
		interval = 1,
		steps_per_interval = 1,
		remaining = 1,
		loops = loops,
		loop_counts = table_size(loops)
	}
	save_state.on_execute = on_execute and this.registered_functions_byFnc[on_execute] or nil
	save_state.on_finished = on_finished and this.registered_functions_byFnc[on_finished] or nil

	local task = this.load_task(save_state) or error("Invalid state")
	task:initializeLoops()
	return task.save_state
end

function AsyncTask.registerVersion(version)
	this.data_version = version.."/"..KuxCoreLib.__version
end

-----------------------------------------------------------------------------------------------------------------------
-- private functions
-----------------------------------------------------------------------------------------------------------------------

function this.add_async_task(task)
	if not this.task_states then
		this.task_states = {}
		if not storage.__KuxCoreLib__ then storage.__KuxCoreLib__ = {} end
		storage.__KuxCoreLib__.async_tasks = this.task_states
	end
	for k, existing_task in pairs(this.task_states) do
		if this.task_states[k] == task.save_state then
			-- Just load task, no need for inserting anything
			this.tasks[k] = task
			return
		end
	end
	for k, existing_task in pairs(this.tasks) do
		if existing_task:isCompleted() then
			this.task_states[k] = task.save_state
			this.tasks[k] = task
			return
		end
	end

	table.insert(this.task_states, task.save_state)
	table.insert(this.tasks, task)
end

---@param save_state KuxCoreLib.AsyncTask.SaveState
---@return KuxCoreLib.AsyncTask.Instance?
function this.load_task(save_state)
	local task = setmetatable({}, {__index=AsyncTask_prototype}) --[[@as KuxCoreLib.AsyncTask.Instance]]
	task.save_state = save_state

	task:load_loop_functions(this.loop_functions)
	task.on_execute = save_state.on_execute and this.registered_functions[save_state.on_execute] or nil
	task.on_finished = save_state.on_finished and this.registered_functions[save_state.on_finished] or nil
	if not task.on_execute and not task.on_finished then
		trace.warning("No on_execute or on_finished function found. Task ignored.")
		return nil
	end
	this.add_async_task(task)
	return task
end

function this.initialize()
	-- game.print("AsyncTask.initialize")
	-- perform configuration step
	if not storage.__KuxCoreLib__ then storage.__KuxCoreLib__ = {} end
	if not storage.__KuxCoreLib__.async_tasks then storage.__KuxCoreLib__.async_tasks = {} end
	local stored_version = tostring(storage.__KuxCoreLib__.async_tasks.__version)
	if (this.data_version ~= stored_version) then
		--clear all data
		trace("AsyncTask version change datated."..stored_version.."->"..this.data_version.." Clearing all tasks.")
		storage.__KuxCoreLib__.async_tasks = {__version = tostring(this.data_version)}
	end
	this.task_states = storage.__KuxCoreLib__.async_tasks
	for _, task_state in ipairs(this.task_states) do
		this.load_task(task_state)
	end
end

function this.on_tick()
	if not this.initialized then
		this.initialize()
		this.initialized = true
	end
	local tick = game.tick
	for _, task in pairs(this.tasks) do task:on_tick(tick) end
	if tick % 3600 == 2700 then
		-- Cleanup tasks
		-- log("Cleanup async tasks")
		local delete={}
		for k, task in pairs(this.tasks) do
			if task:isCompleted() then
				table.insert(delete, k)
			end
		end
		for i = #delete, 1, -1 do
			table.remove(this.task_states, delete[i])
			table.remove(this.tasks, delete[i])
		end
		return
	end
end

Events.on_tick(this.on_tick)
-----------------------------------------------------------------------------------------------------------------------
return AsyncTask

---Custom data for the task. Part of SaveState.
---@alias KuxCoreLib.AsyncTask.CustomData {[string]:(string|number|boolean|table)}

---State data for the task. Part of SaveState.
---@alias KuxCoreLib.AsyncTask.StateData {[string]:(string|number|boolean|table)}

---SaveState: the data that will be saved in storage [TODO: WIP]
---@class KuxCoreLib.AsyncTask.SaveState
---@field id integer? The id of the task
---@field custom_data KuxCoreLib.AsyncTask.CustomData The custom data for the task
---@field state KuxCoreLib.AsyncTask.StateData?
---@field completions integer
---@field interval integer
---@field steps_per_interval integer
---@field remaining integer
---@field loops KuxCoreLib.AsyncTask.Loop[] The loops for the task
---@field loop_counts integer
---@field loops_iterator table?
---@field iterators table?
---@field loop_values table?
---@field type string?
---@field identifier string?
---@field start integer?
---@field stop integer?
---@field on_execute string? -- function identifier for the 'execute' function
---@field on_finished string? -- function identifier for the 'finished' function


---@alias KuxCoreLib.AsyncTask.ExecuteDelegate fun(KuxCoreLib.AsyncTask.StateData, KuxCoreLib.AsyncTask.CustomData)

---@alias KuxCoreLib.AsyncTask.FinishedDelegate fun(KuxCoreLib.AsyncTask.CustomData)