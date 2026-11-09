---@diagnostic disable: inject-field
--------------------------------------------------------------------------------
-- STRUCTURED TRACING
-- A simple, low cost logging, debugging, and stats library based on
-- structured tracing, or `strace`, messages. These are messages that can be
-- forwarded as parameter packs on the Lua stack without creating temporary
-- objects, yet carry a table-like key-value structure.
--
-- The format of a structured tracing message is as follows:
--
--  `strace(level, key1, value1, ..., keyN, valueN,
-- 	"message"?, message_arg1, ..., message_argN)`
--
--  - The first argument is a single integer `level`. Level is interpreted
-- as priority from low to high, with messages below designated levels being
-- discardable without processing penalties.
--
--  - Subsequent arguments are interpreted in pairs as `key`s and `value`s. The `key`s must always be strings. The `value`s can be any lua type.
--  - This sequence of pairs ends at either the end of the argument list, or when a special `key` named `message` is encountered.
--  - If `message` is encountered, ALL further arguments beyond the `message` are `message_arg`s to be stringified and concatenated to a single string message.
--  - Any of the `value` or `message_arg` args may be functions. These are interpreted as lazy data and are to be evaluated at the site of interpretation with their return values replacing the associated argument.
--
--
-- This library contains useful tools for manipulating strace messages, as
-- well as a default global driver for handling them. It is NOT necessary to
-- use this library in order for your own mod to use or display straces.
--------------------------------------------------------------------------------

local format_tick_relative =
	require("lib.core.math.numeric").format_tick_relative

local select = _G.select
local type = _G.type
local tconcat = _G.table.concat
local tunpack = _G.table.unpack
local pairs = _G.pairs
local serpent_line = serpent.line
local serpent_block = serpent.block
local tostring = _G.tostring

local SERPENT_ARGS = { maxlevel = 3, maxnum = 20, nocode = true }

local lib = {}

local TRACE = 10
local DEBUG = 20
local INFO = 30
local STATS = 40
local WARN = 50
local ERROR = 60

lib.TRACE = TRACE
lib.DEBUG = DEBUG
lib.INFO = INFO
lib.STATS = STATS
lib.WARN = WARN
lib.ERROR = ERROR
lib.MAX_LEVEL = 1000

local level_to_string = {
	[lib.TRACE] = "TRACE",
	[lib.DEBUG] = "DEBUG",
	[lib.INFO] = "INFO",
	[lib.STATS] = "STATS",
	[lib.WARN] = "WARN",
	[lib.ERROR] = "ERROR",
}
lib.level_to_string = level_to_string

---Global strace handler per Lua state.
---@type fun(...)|nil
local handler = nil

local function unwind_fns(car, ...)
	if type(car) == "function" then car = car() end
	if select("#", ...) == 0 then
		return car
	else
		return car, unwind_fns(...)
	end
end

---Split off the first key-value pair from an strace message, returning the
---key and value, along with the remaining message.
---The level parameter must have been stripped in advance.
---@return string? key The first key or `nil` if no such key exists in the message
---@return any ... The associated value. If the `message` is encountered, instead a full parameter pack of the message data will be returned, with lazy functions evaluated.
function lib.car_cdr(k, v, ...)
	if k == nil then return nil end
	if v == nil then
		-- Malformed strace message.
		return nil
	end
	if k == "message" then return "message", unwind_fns(v, ...) end
	if type(v) == "function" then v = v() end
	return k, v, ...
end

---Iterate over the kv pairs of an strace message.
---@param fn fun(key: string, ...: any) Function to call for each key-value pair. If the `message` key is encountered, the function will be called with `message` and all remaining message args.
---@param level int The strace level.
---@param ... any The strace message parameter pack.
local function foreach(fn, level, ...)
	fn("level", level)
	for i = 1, select("#", ...), 2 do
		local key = select(i, ...)
		if key == "message" then
			return fn("message", unwind_fns(select(i + 1, ...)))
		end
		local val = select(i + 1, ...)
		if type(val) == "function" then val = val() end
		fn(key, val)
	end
end
lib.foreach = foreach

---Get a key-value pair from an strace message by linear search for the key.
---@return string? key The key or `nil` if no such key exists in the message
---@return any value The associated value
function lib.get_kv(key, ...)
	for i = 2, select("#", ...), 2 do
		local ith = select(i, ...)
		if ith == key then
			local val = select(i + 1, ...)
			if type(val) == "function" then val = val() end
			return ith, val
		elseif ith == "message" then
			return nil
		end
	end
	return nil
end

-- Get string message from portion of parameter pack beginning with `MESSAGE`
local function get_trailing_message(stringify, ...)
	local n = select("#", ...)
	-- Special cases to avoid table allocation for single-string message
	if n == 1 then
		return ""
	elseif n == 2 then
		local arg = select(2, ...)
		if type(arg) == "function" then arg = arg() end
		return stringify(arg)
	else
		-- General case
		local accum = {}
		for i = 2, n do
			local arg = select(i, ...)
			if type(arg) == "function" then arg = arg() end
			accum[#accum + 1] = stringify(arg)
		end
		return tconcat(accum, " ")
	end
end

---Convert an strace message to a structured table containing all its data.
---The level is stored in `level`, each (`key`, `value`) pair is mapped
---to an equivalent pair in the table, and the message is stored at `message`.
---All lazy functions are evaluated.
---@param stringify? fun(x: any): string Stringifier for non-string message parts. If `nil`, the `message` will be ignored completely.
local function to_struct(stringify, ...)
	local n = select("#", ...)
	local res = {}
	res.level = select(1, ...)
	local i = 2
	local arg1, arg2
	while i <= n do
		arg1 = select(i, ...)
		if arg1 == "message" then break end
		arg2 = select(i + 1, ...)
		if type(arg2) == "function" then arg2 = arg2() end
		res[arg1] = arg2
		i = i + 2
	end
	if arg1 == "message" and stringify then
		res.message = get_trailing_message(stringify, select(i, ...))
	end
	return res
end
lib.to_struct = to_struct

---Convert a structured table back into an strace message as a parameter pack.
---@param struct table A table resulting from converting a strace message with `to_struct`.
---@return any[] unpacked An unpacked parameter pack corresponding to the original strace message.
local function unpacked_from_struct(struct)
	local result = { struct.level }
	for key, value in pairs(struct) do
		if key ~= "level" and key ~= "message" then
			result[#result + 1] = key
			result[#result + 1] = value
		end
	end
	local msg = struct.message
	if type(msg) == "string" then
		result[#result + 1] = "message"
		result[#result + 1] = msg
	end
	return result
end
lib.unpacked_from_struct = unpacked_from_struct

---Send a structured tracing message specified by the parameter pack.
---@param level int Trace level.
local function strace(level, ...)
	if handler then return handler(level, ...) end
end
lib.strace = strace

function lib.trace(...) return strace(TRACE, "message", ...) end
function lib.info(...) return strace(INFO, "message", ...) end
function lib.log(...) return strace(INFO, "message", ...) end
function lib.debug(...) return strace(DEBUG, "message", ...) end
function lib.warn(...) return strace(WARN, "message", ...) end
function lib.error(...) return strace(ERROR, "message", ...) end

---Set a global tracing handler
---@param new_handler? fun(...)
function lib.set_handler(new_handler) handler = new_handler end

---Get the global tracing handler
---@return fun(...)|nil
function lib.get_handler() return handler end

local function stringify_with(val, serpent_printer)
	local val_t = type(val)
	if
		val_t == "nil"
		or val_t == "number"
		or val_t == "string"
		or val_t == "boolean"
	then
		return tostring(val)
	elseif val_t == "function" then
		return "(function)"
	else
		return serpent_printer(val, SERPENT_ARGS)
	end
end

---Convert a lua value to a compact string.
local function stringify(val) return stringify_with(val, serpent_line) end
lib.stringify = stringify

---Convert a lua value to a pretty-printed string.
function lib.prettify(val) return stringify_with(val, serpent_block) end

---Convert an entire message to a raw string
function lib.message_to_string(...)
	local n = select("#", ...)
	local accum = {}
	for i = 1, n do
		local arg = select(i, ...)
		accum[#accum + 1] = stringify_with(arg, serpent_line)
	end
	return tconcat(accum)
end

---Filter strace messages by key/value. Each key/value pair in `filters` defines
---a filter, and a message passes that filter if:
---
---  1. the filtered value is `true` and the message has a value for that key or
---  2. the filtered value is a set and the message value of that key is in the set or
---  3. the message has a value `==` the filtered value at that key.
---
---In whitelist mode, returns `true` if the message passes at least one filter and
---fails none. In blacklist mode, returns `true` if the message fails all filters.
---Does not inspect lazy values.
function lib.filter(is_whitelist, filters, ...)
	local n = select("#", ...)
	local matches = 0
	for i = 2, n, 2 do
		local key = select(i, ...)
		if key == "message" then break end
		local value = select(i + 1, ...)
		local filter_value = filters[key]
		if filter_value ~= nil then
			if
				(filter_value == true and value ~= nil)
				or (filter_value == false and value == nil)
				or (type(filter_value) == "table" and value ~= nil and filter_value[value] == true)
				or (value == filter_value)
			then
				-- Passed filter
				if not is_whitelist then return false end
				matches = matches + 1
			else
				-- Failed filter
				if is_whitelist then return false end
			end
		end
	end
	if is_whitelist then
		return matches > 0
	else
		return true
	end
end

-- Inform typechecking that _LOG_LEVEL is an integer.
storage._LOG_LEVEL = 0

function lib.standard_log_handler(level, ...)
	-- Authorized storage injection
	---@diagnostic disable-next-line: undefined-field
	local lv = (storage and storage._LOG_LEVEL) or 10
	if level < lv then return end
	local frame = 0
	if game then frame = game.ticks_played end
	local cat_tbl = {
		"[",
		script.mod_name,
		"::",
		frame,
		format_tick_relative(frame, 0),
		level_to_string[level],
		"]",
	}
	foreach(function(key, value, ...)
		if key == "level" then
		-- skip
		elseif key == "message" then
			cat_tbl[#cat_tbl + 1] = stringify(value)
			for i = 1, select("#", ...) do
				cat_tbl[#cat_tbl + 1] = stringify(select(i, ...))
			end
		else
			cat_tbl[#cat_tbl + 1] = " "
			cat_tbl[#cat_tbl + 1] = tostring(key)
			cat_tbl[#cat_tbl + 1] = "="
			cat_tbl[#cat_tbl + 1] = stringify(value)
		end
	end, level, ...)
	log(tconcat(cat_tbl, " "))
end

return lib
