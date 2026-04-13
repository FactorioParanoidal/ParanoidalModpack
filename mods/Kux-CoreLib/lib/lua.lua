require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
local utf8 = require(KuxCoreLibPath.."lib/utils/utf8")

local String = KuxCoreLib.String

---@diagnostic disable: lowercase-global

---iif
---@param condition boolean
---@param trueValue any
---@param falseValue any
---@return any
function iif(condition, trueValue, falseValue)
	local retValue = condition and trueValue or falseValue
	if type(retValue) =="function" then
		retValue = retValue()
	end
	return retValue
end

---try/catch/finaly
---@param f function
---@param catch_f? function
---@param finally_f? function
function try(f, catch_f, finally_f)
	local status, exception = pcall(f)
	if not status and catch_f then
		catch_f(exception)
	end
	if finally_f then finally_f() end
end

---switch
---@param key string|integer
---@param dictionary table
---@param default any
---@return any
function switch(key, dictionary, default)
	local v = dictionary[key]
	if v == nil then return default end
	return v
end

---switch
---@param key string|integer
---@param ... unknown
---@return any
function switchp(key, ...)
	local dic = {}
	local count = select("#",...)
	local default = nil
	for i = 1, count, 2 do
		local k = select(i,...)
		if type(k) == "function" then k = k() end
		if(i+1>count) then default = k; break end
		local v = select(i+1,...)
		if type(v) == "function" then v = v() end
		dic[k]=v
		if(i+1==count) then default = v end
	end
	return switch(key,dic,default)
end


local function getValue(object, fragment, createPartIfNotExits)
	--print("getValue", object or "<nil>", fragment or "<nil>", createPartIfNotExits)
	local name, index = string.match(fragment, "^([^.]+)%[(%d+)%]$")
	if name and index then
		if(object[name]==nil) then
			if(createPartIfNotExits) then
				object[name]={}
			else
				return nil
			end
		end
		if(object[name][tonumber(index)]==nil and createPartIfNotExits) then object[name][tonumber(index)]={} end
		return object[name][tonumber(index)]
	else
		if(object[fragment]==nil and createPartIfNotExits) then object[fragment]={} end
		return object[fragment]
	end
end

local function setValue(object, fragment, value)
	local name, index = string.match(fragment, "^([^.]+)%[(%d+)%]$")
	if name and index then
		if(object[name]==nil) then object[name]={} end
		object[name][tonumber(index)]=value
	else
		object[fragment]=value
	end
end

---safe get accessor
---@param ... any path fragmnents
---Usage: value = safeget(obj,"fieldA","fieldB") equivalent to obj.fieldA.fieldB, but w/o error if a field is nil
function safeget(...)
	--TODO: handle empty path: safeget(o, "") or safeget(o, nil)
	local o, p
	local c = select("#",...)
	for i = 1, c do
		local v = select(i,...);
		if(i==1) then
			if(v == nil) then return nil end -- in case of safeget(nil,...)
			if(type(v)=="string") then o = _G else o = v; goto next	end
		end
		local fragments = String.split(v,nil, {".","/"})
		for iFragment,fragment in ipairs(fragments) do
			if(i==1 and iFragment==1 and fragment=="_G") then goto next end
			p=o;
			o=getValue(p,fragment)
			if o == nil then return nil end
		end
		::next::
	end
	return o
end

function safegetOrCreate(...)
	local o, p
	local c = select("#",...)
	for i = 1, c do
		local v = select(i,...);
		if(i==1) then if(type(v)=="string") then o = _G else o = v; goto next end end
		local fragments = String.split(v,nil, {".","/"})
		for iFragment,fragment in ipairs(fragments) do
			if(i==1 and iFragment==1 and fragment=="_G") then goto next end
			p=o;
			o=getValue(p,fragment)
			if o == nil then o={}; setValue(p,fragment,o)  end
		end
		if i == c then return o end
		::next::
	end
end

---safe set accessor
---@param ... any path framents, last parameter is the value to set
---example: safeset(t, "foo[1].bar.baz", value)
---example: safeset(t, foo", index, "bar.baz", value)
function safeset(...)
	local p = nil
	local o = nil
	local c = select("#",...)
	local lastFragment = nil
	for i = 1, c-1 do
		local v = select(i,...)
		if(i==1) then if(type(v)=="string") then o = _G else o = v; goto next end end
		local fragments = String.split(v,nil, {".","/"})
		for iFragment,fragment in ipairs(fragments) do
			if(i==1 and iFragment==1 and fragment=="_G") then goto next end
			if(i==c-1 and iFragment == #fragments) then lastFragment=fragment; break end
			p = o;
			o = getValue(p,fragment,true)
		end
		::next::
	end
	setValue(o,lastFragment,select(c,...))
end

function anypairs(t)
	return next, t, nil
end

local function set_x(i,...)
	_G["_"..i] = select(1, ...)
	return ...
end

function _G.set_1(...) return set_x(1,...) end
function _G.set_2(...) return set_x(2,...) end
function _G.set_3(...) return set_x(3,...) end
function _G.set_4(...) return set_x(4,...) end
function _G.set_5(...) return set_x(5,...) end
function _G.set_6(...) return set_x(6,...) end
function _G.set_7(...) return set_x(7,...) end
function _G.set_8(...) return set_x(8,...) end
function _G.set_9(...) return set_x(9,...) end

function _G.set_n(...)
	_G._n = {...}
	local values = {...}
	for i = 1, 9 do _G["_"..i] = values[i] end
	return values
end

function _G.get_1() return _G["_1"] end
function _G.get_2() return _G["_2"] end
function _G.get_3() return _G["_3"] end
function _G.get_4() return _G["_4"] end
function _G.get_5() return _G["_5"] end
function _G.get_6() return _G["_6"] end
function _G.get_7() return _G["_7"] end
function _G.get_8() return _G["_8"] end
function _G.get_9() return _G["_9"] end
function _G.get_n() return {_G["_1"],_G["_2"], _G["_3"], _G["_4"], _G["_5"], _G["_6"], _G["_7"], _G["_8"], _G["_9"]} end

--[[
if set_1(some_function()) == expected_value then
	print(_1)
end

if set_n(some_function())[2] == expected_value then
	print(_1)
end
]]

---Alias for print(string.format(s,...))
---@param s string
---@vararg any
function _G.printf(s,...) print(string.format(s,...)) end

function _G.dprintf(s,...)
	local args = {...}
	for i = 1, #args do args[i] = str(args[i]) end
	print(string.format(s,...))
end

--string.lower=utf8.lower
rawset(string, "lower", utf8.tolower)
assert(string.lower~=nil,"string.lower is nil")

---Receives values of any type and converts it to a table in a human-readable format.
function locstring(...)
	local t = { ... }
	if #t == 1 and type(t[1]) == "table" then t = t[1] end
	if #t>1 and type(t[1]) == "table" then table.insert(t, 1, "") end
	return t
end

---@class KuxCoreLib.lua
local lua = {
	asGlobal=function () end -- dummy, because lua like methods are always global
}

return lua