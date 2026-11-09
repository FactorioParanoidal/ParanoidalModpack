--- Cooperative multitasking library for Factorio mods.

local log = require("lib.core.strace")
local class = require("lib.core.class").class

---@class Core.CMT.Lib
local lib = {}

-- EMA parameters
local ALPHA = 0.25
local ONE_MINUS_ALPHA = 1 - ALPHA

--------------------------------------------------------------------------------
-- Data
--------------------------------------------------------------------------------

---@alias Core.CMT.TaskID integer

---@alias Core.CMT.TaskSet { [Core.CMT.TaskID]: true }

---@class Core.CMT.Task
---@field public id Core.CMT.TaskID The ID of the task
---@field public friendly_name? string An optional friendly name for debugging purposes
---@field public frame_work_cap? number Maximum workload this task can consume per frame. The task's main loop will be re-entered until this cap is reached or the total frame cap is reached. If not given, 0, or negative, the task will yield after each iteration of its main loop.
---@field public ema_work_per_frame number An exponentially moving average of the work done by this task per frame
---@field public ema_work_per_timeslice number An exponentially moving average of the work done by this task per timeslice
---@field public debug_paused? boolean Whether the task is paused for debugging purposes
---@field public debug_stepped? boolean Whether the task should execute one step while paused for debugging purposes
local Task = class("Core.CMT.Task")
lib.Task = Task

---@class Core.CMT.Storage
---@field public tasks { [Core.CMT.TaskID]: Core.CMT.Task } The set of all tasks
---@field public active_task_set Core.CMT.TaskSet The set of active tasks
---@field public run_queue Core.CMT.TaskID[] The run queue of active tasks
---@field public wake_at { [uint]: Core.CMT.TaskSet } The set of tasks scheduled to wake at a given tick
---@field public target_work_per_frame number Target amount of work to be done per frame across all tasks
---@field public max_work_per_frame number Maximum amount of work to be done per frame across all tasks

---@return Core.CMT.Storage
local function get_cmt_data()
	---@diagnostic disable-next-line: undefined-field
	return storage._cmt
end

---@param tick_data NthTickEventData
local function scheduler_tick(tick_data)
	local data = get_cmt_data()
	-- Add any woken tasks to this frame's runqueue
	-- Run tasks until we hit the frame workload cap
end

return lib
