local table_insert = table.insert

List = require("mpp.list")

math.phi = 1.618033988749894

---Filters out a list
---@param t any
---@param func any
function table.filter(t, func)
	local new = {}
	for k, v in ipairs(t) do
		if func(v) then new[#new+1] = v end
	end
	return new
end

function table.map(t, func)
	local new = {}
	for k, v in pairs(t) do
		new[k] = func(v)
	end
	return new
end

function table.mapkey(t, func)
	local new = {}
	for k, v in pairs(t) do
		new[func(v)] = v
	end
	return new
end

---Appends a list to the target table
---@param target table
---@param other any[]
function table.append(target, other)
	for _, value in pairs(other) do
		table_insert(target, value)
	end
end

function math.divmod(a, b)
	return math.floor(a / b), a % b
end

function math.sign(x)
	return (x < 0 and 1) or (x == 0 and 0) or -1
end

---math.min but ignores nil values
---@param x number?
---@param ... number?
---@return number
function math.mina(x, ...)
	for _, v in pairs{...} do
		if v ~= nil and (x == nil or v < x) then
			x = v
		end
	end
	return x --[[@as number]]
end


---math.max but ignores nil values
---@param x number?
---@param ... number?
---@return number
function math.maxa(x, ...)
	for _, v in pairs{...} do
		if v ~= nil and (x == nil or v > x) then
			x = v
		end
	end
	return x --[[@as number]]
end

---Collects boolean expression result
---Yes, this kills short-circuiting
---@param ... boolean
---@return boolean
function logic_any(...)
	for i = 1, select("#", ...) do
		if select(i, ...) then return true end
	end
	return false
end
