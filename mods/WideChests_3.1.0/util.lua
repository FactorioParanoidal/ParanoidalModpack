function string.starts_with(String, Start)
   return string.sub(String, 1, string.len(Start)) == Start
end

function math.round(num)
	if num >= 0 then
		return math.floor(num + 0.5)
	else
		return math.ceil(num - 0.5)
	end
end

function string.split(str, sep)
   local sep, fields = sep or ":", { }
   local pattern = string.format("([^%s]+)", sep)
   string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function table.unpack(t, i)
	i = i or 1
	if t[i] ~= nil then
		return t[i], unpack(t, i + 1)
	end
end

function groupByName(t)
	local result = { }
	for _, item in ipairs(t) do
		local key = item.name
		if not result[key] then
			result[key] = { }
		end
		table.insert(result[key], item)
	end
	return result
end
