-----------------------------------------------------------------------------------------------------------------------
--- AsyncTask
-----------------------------------------------------------------------------------------------------------------------

---prototype for AsyncTask class
---@class KuxCoreLib.AsyncTask.Instance
---@field save_state KuxCoreLib.AsyncTask.SaveState
---@field on_execute KuxCoreLib.AsyncTask.ExecuteDelegate?
---@field on_finished KuxCoreLib.AsyncTask.FinishedDelegate?
local AsyncTask_prototype = {}

---@class KuxCoreLib.AsyncTask.Instance.private
local this = {}
-----------------------------------------------------------------------------------------------------------------------
---@type KuxCoreLib.AsyncTask.private
local async = nil

function AsyncTask_prototype:load_loop_functions(loop_functions)
	for _, loop in pairs(self.save_state.loops) do
		if loop.type == "func" then
			assert(loop_functions[loop.identifier]) --use integrated nil check
			loop.func = loop.identifier
		end
	end
end

function AsyncTask_prototype:initializeLoops()
	local save_state = self.save_state
	save_state.state = {}
	save_state.loops_iterator = nil
	save_state.iterators = {}

	for loop_index, loop in pairs(save_state.loops) do
		local loop = save_state.loops[loop_index]
		local it, value = this.loop_next(loop, nil, save_state.iterators, save_state.state)
		save_state.iterators[loop_index] = it
		save_state.state[loop.identifier] = value
		if it == nil then
			-- if any of the loops are empty, there is nothing to loop
			this.finished(self)
			return
		end
	end
end

---@param tick integer
function AsyncTask_prototype:on_tick(tick)
	if self.save_state.remaining == 0 then return end
	if tick % self.save_state.interval ~= 0 then return end
	local steps_per_interval = self.save_state.steps_per_interval or 1
	for i = 1, steps_per_interval do
		if self.save_state.remaining ~= 0 then
			this.execute(self)
			this.next_iteration(self)
		end
	end
end

---@return boolean
function AsyncTask_prototype:isCompleted()
	return self.save_state.remaining == 0
end

-----------------------------------------------------------------------------------------------------------------------
-- private
-----------------------------------------------------------------------------------------------------------------------

---@param task KuxCoreLib.AsyncTask.Instance
function this.next_iteration(task)
	local save_state = task.save_state
	local loop_index = save_state.loop_counts

	while true do
		local loop = save_state.loops[loop_index]
		local it, value = this.loop_next(loop, save_state.iterators[loop_index], save_state.iterators, save_state.state)
		save_state.iterators[loop_index] = it
		save_state.state[loop.identifier] = value
		if it == nil then
			-- if iterator on loop_index is nil, then the current loop is finished so we must go to the next loop and iterate to the next there
			loop_index = loop_index - 1
			if loop_index == 0 then
				this.finished(task)
				return
			end
		elseif save_state.iterators[loop_index] and loop_index == save_state.loop_counts then
			-- if we're on last loop and last loop is not nil, then we're good to go for next perform call.
			return
		else
			loop_index = loop_index + 1
		end
	end
end

---@param task KuxCoreLib.AsyncTask.Instance
function this.finished(task)
	task.save_state.completions = task.save_state.completions + 1
	task.save_state.remaining = task.save_state.remaining - 1
	if task.on_finished then
		-- game.print("Finished")
		task.on_finished(task.save_state.custom_data)
	end
end


---@param task KuxCoreLib.AsyncTask.Instance
function this.execute(task)
	if task.on_execute then
--		log("Call perform with " .. serpent.line(self.state))
		task.on_execute(task.save_state.state, task.save_state.custom_data)
	end
end

---@param loop KuxCoreLib.AsyncTask.Loop
---@param current any
---@param all_iterators table
---@param all_state table
---@return any, any
function this.loop_next(loop, current, all_iterators, all_state)
	if loop.type == "numeric" then
		if current == nil then return loop.start, loop.start
		elseif current == loop.stop then return nil, nil
		else return current + 1, current + 1 end
	elseif loop.type == "values" then
		return next(loop.values, current)
	elseif loop.type == "chunks" then
		local value = loop.iterator()
		return value, value
	elseif loop.type == "func" then
		if current == nil then loop.values = async.loop_functions[loop.identifier](all_state, all_iterators) end
		return next(loop.values, current)
	elseif loop.type == "dynamic" then
		local value = async.dynamic_functions[loop.identifier](all_state, all_iterators, current)
		return value, value
	else
		error("Unknown loop type: " .. loop.type)
	end
end

-----------------------------------------------------------------------------------------------------------------------

---@param _async KuxCoreLib.AsyncTask.private
---@return KuxCoreLib.AsyncTask.Instance
function inject(_async) async = _async; return AsyncTask_prototype end
return inject