---@diagnostic disable: inject-field

-- Global auto-incrementing counters stored in game state. Useful for generating unique IDs.

require("lib.core.require").require_guard("lib.core.counters")

local event = require("lib.core.event")

local BIG_INT = 9007199254740000

---@alias Core.CounterStorage { [string]: int64 }

---@type Core.CounterStorage
storage._counters = {}

---@class Core.Lib.Counters
local lib = {}

event.bind("on_startup", function()
	-- We don't reset existing counters on startup to ensure uniqueness of
	-- previously generated IDs across restarts.

	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	if type(storage._counters) ~= "table" then
		storage._counters = {} --[[@as Core.CounterStorage]]
	end
end)

---Increment the global counter with the given key and return its next value.
---@param key string The key of the counter to increment.
---@return integer #The next value of the counter
function lib.next(key)
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	local counters = storage._counters

	if not counters then
		-- We have to crash here for reasons of determinism.
		error(
			"Attempt to increment a counter before storage was initialized. Make sure you are calling counters.init() in your on_init handler and that you aren't utilizing counters in a phase where storage is inaccessible."
		)
	end
	local n = (counters[key] or 0) + 1
	if n > BIG_INT then n = -BIG_INT end
	counters[key] = n
	return n
end

---Examine the value of the given counter without modifying it.
---@param key string The key of the counter to examine.
---@return integer? #The current value of the counter or `nil` if it has not been set.
function lib.peek(key)
	-- Diag disabled: approved storage injection
	---@diagnostic disable-next-line: undefined-field
	local counters = storage._counters

	if not counters then
		-- We have to crash here for reasons of determinism.
		error(
			"Attempt to examine a counter before storage was initialized. Make sure you are calling counters.init() in your on_init handler and that you aren't utilizing counters in a phase where storage is inaccessible."
		)
	end
	return counters[key]
end

return lib
