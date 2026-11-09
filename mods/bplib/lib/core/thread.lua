--------------------------------------------------------------------------------
-- Green threading/coroutine library for Factorio
--------------------------------------------------------------------------------

local class = require("lib.core.class").class
local counters = require("lib.core.counters")
local event = require("lib.core.event")
local log = require("lib.core.strace")

local table_size = _G.table_size
local pairs = _G.pairs
local next = _G.next

local BIG_INT = 9007199254740000

local DEFAULT_MAX_WORKLOAD = 100
local DEFAULT_MAX_BUCKET_SIZE = 5
local DEFAULT_RESCHEDULE_INTERVAL = 60 * 10
local DEFAULT_WORK_PERIOD = 1

---@class Core.Lib.Thread
local lib = {}

local strace = nil
local ERROR = 60
local WARN = 50
local TRACE = 10

---Set strace handler. `nil` disables tracing entirely.
---@param handler? fun(level: int, ...)
function lib.set_strace_handler(handler) strace = handler end

--------------------------------------------------------------------------------
-- Types/Data
--------------------------------------------------------------------------------

---@alias Core.Thread.IdSet {[integer]: true}

---@alias Core.Thread.Workload {workload: number}

---Storage table for threads.
---@class Core.Thread.Storage
---@field public threads {[integer]: Core.Thread} All threads by id.
---@field public max_workload number Empirical target workload per execution cycle. Used to determine how many threads should fit into a frame window.
---@field public max_bucket_size uint Maximum number of threads that can be scheduled in a single frame, regardless of work_per_frame calculations. Used to prevent degeneracy when work_per_frame is inaccurate.
---@field public buckets Core.Thread.IdSet[] Active threads, bucketed by frame.
---@field public bucket_workloads number[] Workload of each bucket.
---@field public current_bucket uint The current bucket being processed.
---@field public wake_at {[uint]: Core.Thread.IdSet} Threads that are scheduled to wake up at a given tick.
---@field public last_reschedule_tick uint The tick at which the last reschedule occurred.
---@field public work_period uint Number of idle ticks to insert between threads, plus 1. 1 is the lowest value, the recommended value, and results in threads running every tick.

event.bind(
	"on_startup",
	---@param reset_data Core.ResetData
	function(reset_data)
		---TODO: warn about unkilled threads from previous state?
		if
			-- Authorized storage injections.
			---@diagnostic disable-next-line: undefined-field
			storage._thread
			and storage._thread.threads
			and next(storage._thread.threads)
		then
			log.warn(
				"Thread scheduler:",
				---@diagnostic disable-next-line: undefined-field
				table_size(storage._thread.threads),
				"outstanding threads from previous state will be killed."
			)
		end
		---@type Core.Thread.Storage
		local initial_storage = {
			threads = {},
			max_workload = DEFAULT_MAX_WORKLOAD,
			max_bucket_size = DEFAULT_MAX_BUCKET_SIZE,
			work_period = DEFAULT_WORK_PERIOD,
			buckets = { {} },
			bucket_workloads = { 0 },
			current_bucket = 1,
			wake_at = {},
			last_reschedule_tick = 0,
		}
		storage._thread = initial_storage
	end
)

---@return Core.Thread.Storage
local function get_data()
	---@diagnostic disable-next-line: undefined-field
	return storage._thread
end

---@class Core.Thread
---@field public id integer Unique ID of the thread
---@field public friendly_name? string Friendly name of the thread, used for debugging and logging
---@field public wake_at? integer The tick at which the thread should wake up. If `nil`, the thread is not sleeping.
---@field public workload? number Empirical measure of work done by this thread per execution cycle. Used to determine how many threads should fit into a frame window.
local Thread = class("Thread")
lib.Thread = Thread

--------------------------------------------------------------------------------
-- Scheduler
--------------------------------------------------------------------------------

---@param data Core.Thread.Storage
local function recompute_workload(data, bucket, bucket_index)
	---@type number
	local workload = 0
	for id in pairs(bucket) do
		local thread = data.threads[id]
		if thread and not thread.wake_at then
			workload = workload + (thread.workload or 0)
		end
	end
	data.bucket_workloads[bucket_index] = workload
end

---@param data Core.Thread.Storage
local function reschedule_all(data)
	local buckets = { {} }
	---@type number[]
	local bucket_workloads = { 0 }
	local current_bucket = 1
	local max_workload = data.max_workload
	local max_bucket_size = data.max_bucket_size
	for id, thread in pairs(data.threads) do
		-- Skip sleeping threads
		if thread.wake_at then goto continue end
		-- Add a new bucket if needed
		local bucket = buckets[current_bucket] --[[@as Core.Thread.IdSet]]
		local workload = bucket_workloads[current_bucket] --[[@as number]]
		local thread_workload = thread.workload or 0
		local next_workload = workload + thread_workload
		if
			next_workload > max_workload or table_size(bucket) >= max_bucket_size
		then
			current_bucket = current_bucket + 1
			bucket = {}
			workload = 0
			next_workload = thread_workload
			buckets[current_bucket] = bucket
		end
		-- Add the thread to the bucket
		bucket[id] = true
		bucket_workloads[current_bucket] = next_workload
		::continue::
	end
	data.buckets = buckets
	data.bucket_workloads = bucket_workloads
	data.current_bucket = 1
end

---@param data Core.Thread.Storage
---@param thread Core.Thread
---@param use_current_bucket boolean? If `true`, the thread will be scheduled in the current bucket if possible.
local function schedule(data, thread, use_current_bucket)
	if thread.wake_at then return end
	local buckets = data.buckets
	local n_buckets = #buckets
	local bucket_workloads = data.bucket_workloads
	local thread_workload = thread.workload or 0
	local max_workload = data.max_workload
	local max_bucket_size = data.max_bucket_size
	local current_bucket = data.current_bucket
	local offset = use_current_bucket and -2 or -1
	-- Try to fit thread into existing buckets
	for i = 1, n_buckets do
		local bucket_index = ((current_bucket + offset + i) % n_buckets) + 1
		local bucket = buckets[bucket_index] --[[@as Core.Thread.IdSet]]
		local workload = bucket_workloads[bucket_index] --[[@as number]]
		local next_workload = workload + thread_workload
		local bucket_size = table_size(bucket)
		if
			(bucket_size == 0)
			or (next_workload <= max_workload and bucket_size < max_bucket_size)
		then
			bucket[thread.id] = true
			bucket_workloads[bucket_index] = next_workload
			return
		end
	end
	-- Add a new bucket if we couldn't find a suitable one
	buckets[n_buckets + 1] = { [thread.id] = true }
	bucket_workloads[n_buckets + 1] = thread_workload
end

---@param data Core.Thread.Storage
---@param id integer
---@param bucket Core.Thread.IdSet
---@param bucket_index integer
local function unschedule(data, id, bucket, bucket_index)
	bucket[id] = nil
	return recompute_workload(data, bucket, bucket_index)
end

--------------------------------------------------------------------------------
-- Executive
--------------------------------------------------------------------------------

---Perform tasks for the given tick. MUST be called precisely once every tick.
if not _G.__RECOVERY_MODE__ then
	event.bind(
		event.nth_tick(1),
		---@param tick_data NthTickEventData
		function(tick_data)
			local data = get_data()
			if not data then
				if strace then strace(ERROR, "thread", "missing_data") end
				return
			end
			local tick_n = tick_data.tick

			-- Wake all threads that are scheduled to wake up at this tick
			local wake_now = data.wake_at[tick_n]
			if wake_now then
				for id in pairs(wake_now) do
					local thread = data.threads[id]
					if thread then
						thread.wake_at = nil
						schedule(data, thread, true)
					end
				end
				data.wake_at[tick_n] = nil
			end

			-- Honor work period
			if tick_n % data.work_period ~= 0 then return end

			-- Execute all mainloops in current bucket.
			local buckets = data.buckets
			local current_bucket = data.current_bucket
			local bucket = buckets[current_bucket]
			if not bucket then
				-- Something has mutilated the thread scheduler's state.
				error("Thread scheduler: missing bucket, invalid state")
				return
			end
			for id in pairs(bucket) do
				local thread = data.threads[id]
				if thread then
					if thread.wake_at then
						unschedule(data, id, bucket, current_bucket)
					else
						thread:main()
					end
				else
					-- Thread has been killed, remove from bucket
					unschedule(data, id, bucket, current_bucket)
				end
			end

			-- Move to next bucket.
			current_bucket = current_bucket + 1
			if current_bucket > #buckets then
				-- If we haven't rescheduled all in a while, do so at the end of a bucket
				-- sweep so no one is denied a timeslice.
				if data.last_reschedule_tick + DEFAULT_RESCHEDULE_INTERVAL < tick_n then
					data.last_reschedule_tick = tick_n
					reschedule_all(data)
				end
				current_bucket = 1
			end
			data.current_bucket = current_bucket
		end
	)
end

event.bind("on_shutdown", function()
	-- Kill all threads on shutdown.
	local data = get_data()
	for id, thread in pairs(data.threads) do
		log.info(
			"Threads: shutdown: killing thread ",
			id,
			"(",
			thread.friendly_name or "unnamed",
			")"
		)
		data.threads[id] = nil
	end
end)

--------------------------------------------------------------------------------
-- API
--------------------------------------------------------------------------------

---Create a new thread. The thread begins in a sleeping state.
function Thread:new()
	local id = counters.next("_thread")
	local thread = setmetatable({
		id = id,
		wake_at = BIG_INT,
	}, self) --[[@as Core.Thread]]
	local data = get_data()
	data.threads[id] = thread
	return thread
end

---@param data Core.Thread.Storage
local function do_sleep_until(data, thread, tick)
	thread.wake_at = tick
	if tick < BIG_INT then
		local id = thread.id
		local wake_at = data.wake_at[tick]
		if not wake_at then
			data.wake_at[tick] = { [id] = true }
		else
			wake_at[id] = true
		end
	end
end

---Sleep the thread for the given number of ticks. Note that sleeping is inexact
---and the thread may not run on the exact wakeup tick.
---@param ticks uint The number of ticks to sleep for. If `0`, the thread will not sleep.
function Thread:sleep_for(ticks)
	if ticks <= 0 then return end
	local sleep_until = game.tick + ticks
	return do_sleep_until(get_data(), self, sleep_until)
end

---Sleep the thread until the given tick. Note that sleeping is inexact and the
---thread may not run on the exact wakeup tick.
---@param tick uint The tick at which to wake up. If not in the future, the thread will not sleep.
function Thread:sleep_until(tick)
	if tick <= game.tick then return end
	return do_sleep_until(get_data(), self, tick)
end

---Sleep the thread forever or until manually woken up.
function Thread:sleep() return do_sleep_until(get_data(), self, BIG_INT) end

---Wake a sleeping thread. This will not wake the thread if it is already awake.
function Thread:wake()
	local wake_at = self.wake_at
	if not wake_at then return end
	local data = get_data()
	-- Clear wakeup schedule if needed
	if wake_at < BIG_INT then
		local wake_now = data.wake_at[wake_at]
		if wake_now then wake_now[self.id] = nil end
	end
	-- Schedule the thread.
	self.wake_at = nil
	return schedule(data, self, false)
end

---Kill the thread, preventing it from ever running its handler again.
function Thread:kill() get_data().threads[self.id] = nil end

---Thread main loop. Override in a subclass to perform work.
function Thread:main() end

---Get a thread by ID. Returns `nil` if the thread does not exist or has been killed.
---@param id integer? The ID of the thread to get.
---@return Core.Thread? #The thread with the given ID, or `nil` if it does not exist.
function lib.get_thread(id)
	if not id then return nil end
	local data = get_data()
	return data and data.threads[id]
end

---Get all thread IDs. Returns an empty table if no threads exist.
---@return integer[] #A list of all thread IDs.
function lib.get_thread_ids()
	local data = get_data()
	if not data then return {} end
	local ids = {}
	for id in pairs(data.threads) do
		ids[#ids + 1] = id
	end
	return ids
end

---Get internal state of thread system. DO NOT mutate this or you will break
---threading. This is for debugging purposes only.
---@return {[integer]: Core.Thread} #The thread map.
---@return Core.Thread.IdSet[] #The thread buckets, indexed by frame.
---@return number[] #The workload of each bucket, indexed by frame.
function lib.debug_get_threads()
	local data = get_data()
	return data.threads, data.buckets, data.bucket_workloads
end

---Utility function for adding to a workload object.
---@param workload Core.Thread.Workload|nil
---@param qty number
---@return number total_workload New workload total, or `qty` if `workload` is `nil`.
function lib.add_workload(workload, qty)
	-- Check for NAN
	if (not qty) or (qty ~= qty) then
		if workload then
			return workload.workload
		else
			return 0
		end
	end

	if workload then
		local x = workload.workload
		local x1 = x + qty
		workload.workload = x1
		return x1
	else
		return qty
	end
end

---Utility function for getting workload value from a workload object.
---@param workload Core.Thread.Workload | nil
---@return number workload
function lib.get_workload(workload) return workload and workload.workload or 0 end

return lib
