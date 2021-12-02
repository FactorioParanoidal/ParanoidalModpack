require "util"

function math.round(num)
	if num >= 0 then
		return math.floor(num + 0.5)
	else
		return math.ceil(num - 0.5)
	end
end

function math.gcd(num1, num2)
	if num1 == num2 then
		return num1
	elseif num1 > num2 then
		return math.gcd(num1 - num2, num2)
	else
		return math.gcd(num1, num2 - num1)
	end
end

function math.lcm(num1, num2)
	return num1 * num2 / math.gcd(num1, num2)
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
