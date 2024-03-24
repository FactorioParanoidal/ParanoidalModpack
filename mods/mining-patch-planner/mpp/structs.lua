
local set_mt = {}
set_mt.__index = set_mt

function set_mt.new(t)
	local new = {}
	for k, v in pairs(t or {}) do
		new[v] = true
	end
	return setmetatable(new, set_mt)
end

local list_mt = {}
list_mt.__index = list_mt

function list_mt.new(t)
	local new = {}
	for k, v in pairs(t or {}) do
		
	end
	return setmetatable(new, list_mt)
end


return set_mt, list_mt
