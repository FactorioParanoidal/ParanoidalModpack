local table_insert = table.insert

---@class List
local list_mt = {}
list_mt.__index = list_mt

function list_mt:push(value)
	table_insert(self, value)
	return self
end

function list_mt:unshift(value)
	table_insert(self, 1, value)
	return self
end

function list_mt:append(...)
	for _, value in pairs({...}) do
		table_insert(self, value)
	end
	return self
end

function list_mt:contitional_append(check, ...)
	if not check then return self end
	for _, value in pairs({...}) do
		table_insert(self, value)
	end
	return self
end

return function(t)
	return setmetatable(t or {}, list_mt)
end
