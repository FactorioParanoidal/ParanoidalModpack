local util = require("util")

local Public = {}

--== Factorio-specific functions ==--

--Encodes string to double
function Public.encode_string_to_double(str)
	assert(#str <= 8, "String length exceeds 8 characters; cannot encode.")

	local result = 0
	local length = #str
	local max_bytes = 8 -- We can encode up to 8 bytes in a double precision floating point

	for i = 1, length do
		local byte = string.byte(str, i)
		result = result + byte * (256 ^ (i - 1))
	end

	return result
end

-- Decodes a double back into a string
function Public.decode_double_to_string(num)
	local result = {}
	local max_bytes = 8 -- Decode up to 8 bytes

	for i = 0, max_bytes - 1 do
		local byte = math.floor(num / (256 ^ i)) % 256
		if byte == 0 then
			break
		end -- Null terminator or end of meaningful bytes
		table.insert(result, string.char(byte))
	end

	return table.concat(result)
end

--== General helper functions ==--

function Public.merge(old, new)
	old = util.table.deepcopy(old)

	for k, v in pairs(new) do
		if v == "nil" then
			old[k] = nil
		else
			old[k] = v
		end
	end

	return old
end

Public.find = function(tbl, f, ...)
	if type(f) == "function" then
		for k, v in pairs(tbl) do
			if f(v, k, ...) then
				return v, k
			end
		end
	else
		for k, v in pairs(tbl) do
			if v == f then
				return v, k
			end
		end
	end
	return nil
end

function Public.contains(table, value)
	for _, v in pairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function Public.sort(arr, compare_fn)
	local n = #arr
	for i = 1, n do
		for j = 1, n - i do
			if compare_fn(arr[j + 1], arr[j]) then
				arr[j], arr[j + 1] = arr[j + 1], arr[j]
			end
		end
	end
	return arr
end

function Public.wrap_single_config(config_or_configs)
	if not config_or_configs[1] then
		return { config_or_configs }
	end
	return config_or_configs
end

function Public.detailed_log(message)
	if settings.startup["PlanetsLib-enable-detailed-logs"].value then
		log(message)
	end
end

function Public.event_name(eventid)
    for name, id in pairs(defines.events) do
        if id == eventid then
            return name
        end
    end
    return tostring(eventid)
end

Public.destroy_events = {
	defines.events.on_player_mined_entity,
	defines.events.on_robot_mined_entity,
	defines.events.on_entity_died,
	defines.events.script_raised_destroy,
	defines.events.on_space_platform_mined_entity
}

Public.build_events = {
	defines.events.on_robot_built_entity,
	defines.events.script_raised_built,
	defines.events.script_raised_revive,
	defines.events.on_space_platform_built_entity,
	defines.events.on_built_entity
}

return Public
