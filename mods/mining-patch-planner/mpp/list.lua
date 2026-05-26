local table_insert = table.insert

---@class List<T> : {[integer]:T, (push:fun(self:List<T>,v:T):List<T>),(unshift:fun(self:List<T>,value:T):List<T>),(append:fun(self:List<T>,...:T):List<T>),(conditional_append:fun(self:List<T>,check:boolean,...:T):List<T>) }

local list_mt = {}
list_mt.__index = list_mt

script.register_metatable("List", list_mt)

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

function list_mt:conditional_append(check, ...)
	if not check then return self end
	for _, value in pairs({...}) do
		table_insert(self, value)
	end
	return self
end

---@generic T
---@param t? T[]
---@return List<T>
return function(t)
	return setmetatable(t or {}, list_mt)
end
