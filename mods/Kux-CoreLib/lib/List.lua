require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides a true list which supports ipairs with nil elements
---@class KuxCoreLib.List
---@field asGlobal fun():KuxCoreLib.List
local List = {
	__class  = "List",
	__guid   = "aeb0658f-4c33-4a61-a689-49741a5e8fff",
	__origin = "Kux-CoreLib/lib/List.lua",
}
if not KuxCoreLib.__classUtils.ctor(List) then return self end
-----------------------------------------------------------------------------------------------------------------------
---@class KuxCoreLib.List.instance
---@field private __length integer
---@field [integer] any
local instance_impl = {}

---@class KuxCoreLib.List.instance.metatable
local mt = {__class = "KuxCoreLib.List.instance.metatable"}

function mt.__index(t,k)
	if type(k)=="number" then return nil
	elseif instance_impl[k] then return instance_impl[k]
	else error("Unknown member: " .. tostring(k)) end
end

function mt.__newindex(t,k,v)
	if type(k)=="number" then
		rawset(t,k,v)
		rawset(t,"__length", math.max(rawget(t,"__length") or 0, k))
	else error("Unknown member: " .. tostring(k)) end
end

function mt.__len(t)
	return rawget(t, "__length") or 0
end

function mt.__ipairs(t)
	local i = 0
	return function()
		i = i + 1
		while rawget(t, i) == nil and i <= rawget(t, "__length") do i = i + 1 end
		if i > rawget(t, "__length") then return nil end
		return i, rawget(t, i)
	end
end

-----------------------------------------------------------------------------------------------------------------------
--#region: instance implementation
-----------------------------------------------------------------------------------------------------------------------

function instance_impl:add(value)
	local len = rawget(self, "__length")
	if rawlen(self) == len then
		table.insert(self, value)
	else
		rawset(self, len+1, value)
	end
	rawset(self, "__length", len+1)
end

function instance_impl:addRange(t)
	local len = rawget(self, "__length")
	if rawlen(self) == len then
		for _, v in ipairs(t) do
			table.insert(self, v)
			len = len + 1
		end
	else
		for _, v in ipairs(t) do
			rawset(self, len+1, v);
			len = len + 1
		end
	end
	rawset(self, "__length", len)
end

function instance_impl:insert(index, v)
	local len = rawget(self, "__length")
	if index < 1 then error("index out of range") end
	if index > len then self[index] = v return end

	if rawlen(self) == len then
		table.insert(self, index, v)
	else
		for i = len, index, -1 do rawset(self, i+1, rawget(self, i)) end
		rawset(self, index, v)
	end
	rawset(self, "__length", len+1)
end

function instance_impl:removeAt(index)
	local len = rawget(self, "__length")
	if index < 1 or index > len then error("index out of range") end
	if rawlen(self) == len then table.remove(self, index)
	else
		for i = index+1, len, 1 do rawset(self, i-1, rawget(self, i)) end
		rawset(self, len, nil)
	end
	rawset(self, "__length", len - 1)
end

---Removes the specified item
---@param item any
---@return boolean #true if the item has been found and removed; elsewhere false
function instance_impl:remove(item)
	local index = instance_impl.indexOf(self, item)
	if index then return false end
	instance_impl.removeAt(self, index)
	return true
end

---Gets the index of the specified item
---@param item any
---@return integer #the index of the item; 0 if the item is not found
function instance_impl:indexOf(item)
	for i = 1, rawget(self, "__length"), 1 do
		if self[i] == item then return i end
	end
	return 0
end

---Sorts the list by the specified keys oder function
---@overload fun(self: KuxCoreLib.List.instance, comparator: fun(a: table, b: table): boolean)
---@param self KuxCoreLib.List.instance
---@param ... string Sort keys like "name" or "order:desc"
---<p>a) Sort with keys <code>sort("name", "order:desc") </code></p>
---<p>b) Sort with function <code>sort(my_sort_fnc) </code></p>
function instance_impl:sort(...)
	local args = { ... }

	if type(args[1]) == "function" then
		table.sort(self, args[1]--[[@as fun(a: table, b: table)]] )
		return
	end

	table.sort(self, function(a, b)
		for _, key in ipairs(args) do
			local field, desc = key:match("([^:]+):?(desc)?")
			local av = a[field]
			local bv = b[field]
			if av ~= bv then
				if desc then return av > bv
				else return av < bv
				end
			end
		end
		return false
	end)
end


---Removes all nil items
function instance_impl:compress()
	local len = rawget(self, "__length")
	local shift=0
	for i = 1, len do
		local v = rawget(self, i)
		if(v) == nil then
			shift = shift + 1
		elseif(shift > 0) then
			rawset(self, i-shift, v)
			rawset(self, i, nil)
		end
	end
	rawset(self, "__length", len-shift)
	return self
end

-----------------------------------------------------------------------------------------------------------------------
--#region: static implementation
-----------------------------------------------------------------------------------------------------------------------

---Creates a new List
---@return KuxCoreLib.List.instance
function List.new()
	local obj = {__length=0}
	setmetatable(obj, mt)
	return obj
end

function List.setmetatable(t)
	setmetatable(t, mt)
	if rawget(t, "__length") == nil then
		rawset(t, "__length", 0)
		local max = 0
		for k, _ in pairs(t) do if type(k) == "number" and k>max then max = k end end
		rawset(t, "__length", max)
	end
	return t
end

---Returns true if the list is nil or empty
function List.isNilOrEmpty(t) return not t or #t==0 end

if KuxCoreLib.ModInfo.current_stage=="control" then
	script.register_metatable(mt.__class, mt)
end

-----------------------------------------------------------------------------------------------------------------------
if mods["debugadapter"] then --test removeAt
	local list = List.new()
	for i = 1, 5, 1 do list:add(i) end
	list[2] = nil list[4] = nil
	list:removeAt(3)
	assert(#list == 4)
	assert(list[3] == nil)
	assert(list[4] == 5)
	assert(list[5] == nil)
end

if mods["debugadapter"] then --test compress
	local list = List.new()
	for i = 1, 5, 1 do list:add(i) end
	list[2] = nil list[4] = nil
	list:compress()
	assert(#list == 3)
	assert(list[1] == 1)
	assert(list[2] == 3)
	assert(list[3] == 5)
	assert(rawlen(list) == 3)
end
-----------------------------------------------------------------------------------------------------------------------
return List