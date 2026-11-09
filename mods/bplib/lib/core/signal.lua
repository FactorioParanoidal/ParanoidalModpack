--------------------------------------------------------------------------------
-- Tools for the manipulation of circuit signals and filters.
--------------------------------------------------------------------------------

local tlib = require("lib.core.table")
local strace = require("lib.core.strace")

local EMPTY = tlib.EMPTY
local strsub = string.sub
local strfind = string.find
local strformat = string.format
local type = type
local abs = math.abs
local floor = math.floor
local tostring = tostring
local band = bit32.band
local pairs = pairs
local next = next

local lib = {}

---@class NamedSignalID: SignalID
---@field public name string The name of the signal.

---@alias SignalKey string A unique string key for a signal

---@alias SignalCounts {[SignalKey]: int32} A mapping of signal keys to counts.

---Get the `string` quality name from a `QualityID` value.
---@param quality_id QualityID?
---@return string?
local function get_quality_name(quality_id)
	if quality_id == nil then
		return nil
	elseif type(quality_id) == "string" then
		return quality_id
	else
		return quality_id.name
	end
end
lib.get_quality_name = get_quality_name

---@type {[string]: boolean}
local _is_parameter_name = {}

---Determine if a signal name is the name of a parameter signal (i.e. starts with "parameter-").
---@param name string
local function is_parameter_name(name)
	if not name then return false end
	local cached = _is_parameter_name[name]
	if cached ~= nil then return cached end
	if strsub(name, 1, 10) == "parameter-" then
		_is_parameter_name[name] = true
		return true
	else
		_is_parameter_name[name] = false
		return false
	end
end
lib.is_parameter_name = is_parameter_name

---@type {[string]: SignalIDType | "nil"}
local _signal_type_from_name_cache = {}

---Get the type of a signal from the name of an item, fluid, virtual_signal,
---entity, recipe, space_location, or asteroid_chunk, prioritizing in that
---order.
---@param name string
---@return SignalIDType?
local function get_signal_type_from_name(name)
	local ty = _signal_type_from_name_cache[name]
	if ty then
		if ty == "nil" then
			return nil
		else
			return ty
		end
	end

	if prototypes.item[name] ~= nil then
		ty = "item"
	elseif prototypes.fluid[name] ~= nil then
		ty = "fluid"
	elseif prototypes.virtual_signal[name] ~= nil then
		ty = "virtual"
	elseif prototypes.quality[name] ~= nil then
		ty = "quality"
	elseif prototypes.entity[name] ~= nil then
		ty = "entity"
	elseif prototypes.recipe[name] ~= nil then
		ty = "recipe"
	elseif prototypes.space_location[name] ~= nil then
		ty = "space-location"
	elseif prototypes.asteroid_chunk[name] ~= nil then
		ty = "asteroid-chunk"
	else
		ty = "nil"
	end
	_signal_type_from_name_cache[name] = ty
	if ty == "nil" then
		return nil
	else
		return ty
	end
end
lib.get_signal_type_from_name = get_signal_type_from_name

---Directly encode signal data (name, type, quality) into a SignalKey.
---@param name string
---@param stype SignalIDType?
---@param quality QualityID?
---@return SignalKey
local function encode_signal_key(name, stype, quality)
	local quality_name
	if not quality then
		quality_name = nil
	elseif type(quality) == "string" then
		quality_name = quality
	else
		quality_name = quality.name
	end
	-- TODO: benchmark caching this in a 2d hash like hash[quality][type]
	---@type string
	local key
	if quality_name == nil or quality_name == "normal" then
		key = name
	else
		key = name .. "|" .. quality_name
	end
	return key --[[@as SignalKey]]
end
lib.encode_signal_key = encode_signal_key

---@type {[SignalKey]: SignalID}
local _key_to_sig = {}
---@type {[SignalKey]: boolean}
local _key_is_virtual = {}
---@type {[SignalKey]: boolean}
local _key_is_quality = {}

---Convert a signal to a key.
---@param signal SignalID
---@return SignalKey
local function signal_to_key(signal)
	local quality_name
	local quality = signal.quality
	local stype = signal.type
	if not quality then
		quality_name = nil
	elseif type(quality) == "string" then
		quality_name = quality
	else
		quality_name = quality.name
	end
	-- TODO: benchmark caching this in a 2d hash like hash[quality][type]
	---@type SignalKey
	local key
	if quality_name == nil or quality_name == "normal" then
		key = signal.name --[[@as SignalKey]]
	else
		key = signal.name .. "|" .. quality_name
	end
	---@cast key SignalKey
	if stype == "item" or stype == "fluid" then
		signal.quality = quality_name -- don't cache signal qualities as prototypes
		_key_to_sig[key] = signal
		if not is_parameter_name(key) then _key_is_virtual[key] = false end
	elseif stype == "virtual" then
		_key_to_sig[key] = signal
		_key_is_virtual[key] = true
	elseif stype == "quality" then
		_key_to_sig[key] = signal
		_key_is_quality[key] = true
	end
	return key --[[@as SignalKey]]
end
lib.signal_to_key = signal_to_key

---@param key string
---@return string? name
---@return SignalIDType? type
---@return string? quality
local function missed_key_to_signal_parts(key)
	local index = strfind(key, "|", 1, true)
	---@type string
	local name
	---@type string?
	local quality
	if index then
		name = strsub(key, 1, index - 1)
		quality = strsub(key, index + 1)
	else
		name = key
	end
	local ty = get_signal_type_from_name(name)
	if ty == nil then return nil end
	return name, ty, quality
end

---Convert a key to a signal.
---@param key SignalKey?
---@return SignalID?
local function key_to_signal(key)
	if not key then return nil end
	local signal = _key_to_sig[key]
	if signal then return signal end
	-- Cache miss so we have to reconstruct the signal
	local name, ty, quality = missed_key_to_signal_parts(key)
	if name then
		signal = { name = name, type = ty, quality = quality }
		if ty == "item" or ty == "fluid" then
			_key_to_sig[key] = signal
			if not is_parameter_name(key) then _key_is_virtual[key] = false end
		elseif ty == "virtual" then
			_key_to_sig[key] = signal
			_key_is_virtual[key] = true
		elseif ty == "quality" then
			_key_to_sig[key] = signal
			_key_is_quality[key] = true
		end
		return signal
	else
		return nil
	end
end
lib.key_to_signal = key_to_signal

---Spread SignalCounts into two arrays: one of SignalIDs and one of counts.
---@param signal_counts SignalCounts
---@return SignalID[] signals
---@return int32[] counts
function lib.spread_signal_counts(signal_counts)
	---@type SignalID[]
	local signals = {}
	---@type int32[]
	local counts = {}
	for key, count in pairs(signal_counts) do
		local signal = key_to_signal(key)
		if signal then
			signals[#signals + 1] = signal
			counts[#counts + 1] = count
		end
	end
	return signals, counts
end

---Build blueprint logistic filters from signals and values. Signals in the array
---are mapped one-to-one with counts at the same index.
---@param signals SignalID[]
---@param counts? int32[]
---@param default_count? int32 A default count to use for any signal that doesn't have a corresponding count. If not provided, signals are dropped.
---@return BlueprintLogisticFilter[]
function lib.compose_blueprint_logistic_filters(signals, counts, default_count)
	---@type BlueprintLogisticFilter[]
	local filters = {}
	counts = counts or EMPTY
	for index, signal in ipairs(signals) do
		local count = counts[index] or default_count
		if count then
			local filter_index = #filters + 1
			filters[filter_index] = {
				index = filter_index,
				type = signal.type or "item",
				name = signal.name,
				quality = get_quality_name(signal.quality) or "normal",
				count = count,
				comparator = "=",
			}
		end
	end
	return filters
end

---Build runtime logistic filters from signals and values. Signals in the array are mapped one-to-one with counts at the same index.
---@param signals SignalID[]
---@param counts? int32[]
---@param default_count? int32 A default count to use for any signal that doesn't have a corresponding count. If not provided, signals are dropped.
---@return LogisticFilter[]
function lib.compose_logistic_filters(signals, counts, default_count)
	---@type LogisticFilter[]
	local filters = {}
	counts = counts or EMPTY
	for index, signal in ipairs(signals) do
		local count = counts[index] or default_count
		if count then
			---@type LogisticFilter
			local filter = {
				value = {
					type = signal.type or "item",
					name = signal.name --[[@as string]],
					quality = get_quality_name(signal.quality) or "normal",
					comparator = "=",
				},
				min = count,
			}
			filters[#filters + 1] = filter
		end
	end
	return filters
end

---Compose a `ConstantCombinatorBlueprintControlBehavior` that will result in
---the blueprinted constant combinator outputting the given signals and counts
---in a single simple logistic section.
---@param signals SignalID[]
---@param counts? int32[]
---@param default_count? int32 A default count to use for any signal that doesn't have a corresponding count. If not provided, signals are dropped.
---@return ConstantCombinatorBlueprintControlBehavior? control_behavior
function lib.compose_simple_ccbpcb(signals, counts, default_count)
	---@type ConstantCombinatorBlueprintControlBehavior
	local control_behavior = {
		sections = {
			sections = {
				{
					index = 1,
					filters = lib.compose_blueprint_logistic_filters(
						signals,
						counts,
						default_count
					),
				},
			},
		},
	}
	return control_behavior
end

---Apply the given signals and counts to the given `LuaConstantCombinatorControlBehavior` as a single simple logistic section. Signals in the array are mapped one-to-one with counts at the same index.
---@param behavior LuaConstantCombinatorControlBehavior? The control behavior to apply the signals and counts to. If nil, the function does nothing.
---@param signals SignalID[]? Signals to assign; if `nil`, clears the combinator's signals.
---@param counts? int32[]
---@param default_count? int32 A default count to use for any signal that doesn't have a corresponding count. If not provided, signals are dropped.
---@return boolean success True if the operation was successful, false if anything went wrong.
function lib.apply_simple_cccb(behavior, signals, counts, default_count)
	if not behavior then return false end

	-- Normalize sections
	local n = behavior.sections_count
	local section = nil
	if n == 0 then
		section = behavior.add_section()
	elseif n == 1 then
		section = behavior.get_section(1)
	else
		section = behavior.get_section(1)
		for i = n, 2, -1 do
			behavior.remove_section(i)
		end
	end
	if not section then return false end
	if not signals then
		section.filters = EMPTY
		return true
	end

	local filters = lib.compose_logistic_filters(signals, counts, default_count)
	section.filters = filters
	return true
end

return lib
