log("Loading KuxCoreLib.String.lua")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides string functions
---@class KuxCoreLib.String : KuxCoreLib.Class
local String = {
	__class  = "String",
	__guid   = "{0E8BBFAF-73EF-4209-9774-B2CD6A13A296}",
	__origin = "Kux-CoreLib/lib/String.lua",
}
if not KuxCoreLib.__classUtils.ctor(String) then return self end
---------------------------------------------------------------------------------------------------
local Table = {} -- we do not load lib/Table here, to avoid circular reference
function Table.append(t, value)
	table.insert(t, value)
end
function Table.appendRange(t, list)
	for _, value in ipairs(list) do
		table.insert(t, value)
	end
end
---------------------------------------------------------------------------------------------------
---Create a string.
---@param s string The base string.
---@param count integer The number of repetitions
---@return string
String.new = function(s, count)
	local r = ""
	for i = 1, count, 1 do r = r .. s end
	return r
end

---Gets or sets the separator for the next concat call.
String.concatSeparator = "" --alias oneTineConcatSeparator

---Concatenances a string
---@param ... any Values to concatenation
---@return string The concatenanced string
function String.concat(...)
	local result = ""
	local args = {...}
	local c = 0
	for _,v in ipairs(args) do
		if c>1 and String.concatSeparator then result = result .. String.concatSeparator end
		result = result .. v
		c=c+1
	end
	String.concat_separator = ""
	return result
end
-- TODO concat options. single/block, tables

---Joins an array of strings
---@param separator string
---@param strings string[] The strings to join.
---@return string
function String.join(separator, strings)
	return table.concat(strings,separator)
end

---Formats a string
---@param format string The format. Placeholders are %1, %2, etc.
---@param ... any The replacement values.
---@return string
function String.format(format, ...)
	 -- remarks: we have to do this with a for loop elsewhere nil values are not counted or skipped
	 local result = format
	local args = {...}
	local len = #args
	for i = 1, len, 1 do
		local v=args[i]
		if v == nil then v = "" else v = tostring(v) end
		result = string.gsub(result,"%%"..i, v)
	end
	return result
end

---Replaces parts of a string
---@param format string The format. Placeholder is {name}, where name ist the key in the replacements dictionary.
---@param replacements {[string]:any} The dictionary with the replacement values.
---@return string
function String.replace(format, replacements)
	local result = format
	for k,v in pairs(replacements) do
		if v == nil then v = "" else v = tostring(v) end
		local p = "{"..k.."}"
		result = string.gsub(result, p, v)
	end
	result = string.gsub(result,"{[%w%d_]+}", "") -- fill remaining placeholder with empty string
	return result
end


function String.print(dest, ...)
	dest.print(String.concat(...))
end

---Gets a value indication the string starts with the specifed value.
---@param s? string The string.
---@param compare string
---@param nonCaseSensitive? boolean
---@return boolean # true: the string starts with specifed value; elsewhere false.
function String.startsWith(s, compare, nonCaseSensitive)
	--TODO: write test
	if s == nil then return false end
	if type(s) ~= "string" or type(compare) ~= "string" then return false end
	if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
	if #compare > #s then return false end
	if #compare == #s then return s == compare end
	return string.sub(s,1,#compare)==compare
end

---Gets a value indication the string ends with the specifed value.
---@param s? string The string.
---@param compare string
---@param nonCaseSensitive? boolean
---@return boolean # true: the string ends with specifed value; elsewhere false.
function String.endsWith(s, compare, nonCaseSensitive)
	--TODO: write test
	if s == nil then return false end
	if type(s) ~= "string" or type(compare) ~= "string" then return false end
	if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
	if #compare > #s then return false end
	if #compare == #s then return s == compare end
	return string.sub(s, -#compare) == compare
end

function String.contains(s, compare, nonCaseSensitive)
	if s == nil then return false end
	if type(s) ~= "string" or type(compare) ~= "string" then return false end
	if nonCaseSensitive then s = s:lower(); compare = compare:lower() end
	if #compare > #s then return false end
	if #compare == #s then return s == compare end
	return string.find(s,compare)
end

local function escapePattern(pattern)
	return pattern:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end

---Splits a string
---@param s string The string to split
---@param separatorsPatterns string[]
---@return string[]
local function split(s, separatorsPatterns)
	local results = {}
	local pattern = table.concat(separatorsPatterns, "|")
	local currentPos = 1
	while true do
		local startPos, endPos, capture = s:find(pattern, currentPos)
		if not startPos then
			table.insert(results, s:sub(currentPos))
			break
		end
		if startPos > currentPos then
			table.insert(results, s:sub(currentPos, startPos - 1))
		end
		currentPos = endPos + 1
	end

	return results
end

local function split(inputString, delimiter)
	if inputString == "" then return {""} end
	if (type(delimiter)~="string") then error("Invalid argument. Name 'delemiter', Type string expected, got "..type(delimiter)) end
	local result = {}
	local startIndex = 1
	while startIndex <= #inputString do
		local iStart, iEnd = string.find(inputString, delimiter, startIndex)
		if(not iStart) then
			iStart = #inputString+1
			iEnd = iStart
		end
		local tLen=startIndex-iStart
		if(tLen==0) then
			table.insert(result, "")
		else
			local token = string.sub(inputString, startIndex,iStart-1)
			table.insert(result, token)
		end
		startIndex = iEnd+1
	end
	return result
end

---Splits a string.
---@param inputString string The string to split
---@param patterns string|string[]|nil The separator(s) pattern
---@param separators string|string[]|nil The separator(s) as plain text (will be escaped)
---@return table # A table with the parts
---example: stringSplit("Foo, Bar, Boo", ",%s+") returns the table {"Foo", "Bar", "Boo"}
---example: stringSplit("Foo/Bar/Boo", nil, "/") returns the table {"Foo", "Bar", "Boo"}
function String.split(inputString, patterns, separators)
	--TODO: test String.split
	if(not patterns) then patterns = {}
	elseif(type(patterns)=="string") then patterns = {patterns}
	elseif(type(patterns)=="table") then --do nothing
	else error("Invalid argument. Name: 'pattern'") end

	if separators == nil then --do nothing
	elseif(type(separators)=="table") then Table.appendRange(patterns, String.escapeTable(separators))
	elseif(type(separators)=="string" and #separators>0) then Table.append(patterns, String.escape(separators))
	else error("Invalid argume. Name: 'separator'") end

	if(#patterns==0) then patterns={"%s"} end
	--TODO: compress single chars to a single pattern  "%." "c"  => [%.x]

	local result = {inputString}
	for _, p in ipairs(patterns) do
		local r={}
		for _, v in ipairs(result) do
			local tokens = split(v,p)
			for _, value in ipairs(tokens) do table.insert(r,value) end
		end
		result = r
	end
	return result
end

---Escapes a string
---@param s string
---@return string
function String.escape(s)
	--                                            - . + [ ] ( ) $ ^ % ?
	local r = string.gsub(s,'[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1')
	return r
end

--source: [1]
local _escapeMatches = {
    ["^"] = "%^";
    ["$"] = "%$";
    ["("] = "%(";
    [")"] = "%)";
    ["%"] = "%%";
    ["."] = "%.";
    ["["] = "%[";
    ["]"] = "%]";
    ["*"] = "%*";
    ["+"] = "%+";
    ["-"] = "%-";
    ["?"] = "%?";
    ["\0"] = "%z";
}

--source: [1]
---Escapes a string for gsub/gmatch.
---@param s string The string to escape.
String.escape_dld=function(s)
	return (s:gsub(".", _escapeMatches))
end

---Escapes a string[]
---@param t string[]
---@return string[]
function String.escapeTable(t)
	local result={}
	for _, value in ipairs(t) do
		table.insert(result,String.escape(value))
	end
	return result
end

-----------------------------
---@class StringPrettyOptions Options for String.pretty
---@field printTableRefs boolean
---@field recursive boolean
---@field maxLevel integer
---@field showNil boolean?
---@field useQuotes boolean?
-----------------------------

---prettystr_core
---@param v any
---@param indentLevel integer
---@param options StringPrettyOptions
---@return string
local function prettystr_core(v,indentLevel,options)
	local type_v = type(v)
	if "nil" == type_v then
		if options.showNil then return "!NIL" else return "" end
	elseif "string" == type_v  then
		if not options.useQuotes then return v end
		-- use clever delimiters according to content:
		-- enclose with single quotes if string contains ", but no '
		if v:find('"', 1, true) and not v:find("'", 1, true) then
			return "'" .. v .. "'"
		end
		-- use double quotes otherwise, escape embedded "
		return '"' .. v:gsub('"', '\\"') .. '"'

	elseif "table" == type_v then
		--if v.__class__ then
		--    return string.gsub( tostring(v), 'table', v.__class__ )
		--end
		-- return M.private._table_tostring(v, indentLevel, printTableRefs, cycleDetectTable)
		return "@Table"
		-- TODO
	elseif "number" == type_v then
		-- eliminate differences in formatting between various Lua versions
		if v ~= v then return "#NaN" end -- "not a number"
		if v == math.huge then return "#Inf" end -- "infinite"
		if v == -math.huge then return "-#Inf" end
		-- if _VERSION == "Lua 5.3" then
		--     local i = math.tointeger(v)
		--     if i then
		--         return tostring(i)
		--     end
		-- end
	end

	return tostring(v)
end

---Returns a string that presents the prettified value
---@param v any
---@param options? StringPrettyOptions
---@return string
function String.pretty(v, options)
	options = options or {}
	options = {
		printTableRefs = options.printTableRefs or false,
		recursive = options.recursive or false,
		maxLevel = options.maxLevel or 1024,
		showNil = options.showNil or false,
---@diagnostic disable-next-line: undefined-field
		cycleDetectTable = options.cycleDetectTable or {},
	}
	return prettystr_core(v,0,options)
end

---Return an array with each char from string
---@param s string
---@return string[]
---If you only want to iterate, use:<br>
---for v in string.gmatch(s,".") do .. end
function String.toChars(s)
	local result={}
	for v in string.gmatch(s,".") do
		table.insert(result,v)
	end
	return result
end

---Checks if a string is nil or  empty.
---@param s string The string to be checked.
---@return boolean -Returns true if the string is nil empty, false otherwise.
function String.isNilOrEmpty(s)
	return s == nil or string.len(s) == 0
end

---@deprecated Use isNilOrEmpty
String.isNullOrEmpty = String.isNilOrEmpty

---Checks if a string is nil, empty or consists only of whitespace characters.
---@param s string The string to be checked.
---@return boolean Returns true if the string is nil or contains only whitespace characters, false otherwise.
function String.isNilOrWhitespace(s)
	return s == nil or string.len(s) == 0 or string.match(s, "^%s*$")
end

function String.repeatN (s, count, separator) return string.rep(s,count,separator) end

function String.overlaps(a,b)
	-- abcde
	--    def
	--> 4, 2
	local aStart, aEnd , bStart, bEnd

	for i = 1, math.min(#a, #b) do
		if a:sub(-i) == b:sub(1, i) then
			aStart = #a - i + 1
			aEnd = #a
			bStart = 1
			bEnd = i
			break
		end
	end

	if aStart and aEnd and bStart and bEnd then
		return aStart, aEnd, bStart, bEnd
	else
		return nil
	end

	-- abc   abc   abc   abc   ab     bc   abc     bce   abc
	-- abc   ab     bc    b    abc   abc    bce   abc       def
end

function String.padLeft(s, length, padChar)
	local padLength = length - #s
	if padLength <= 0 then return s end
	return string.rep(padChar or " ", padLength) .. s
end

function String.padRight(s, length, padChar)
	local padLength = length - #s
	if padLength <= 0 then return s end
	return s .. string.rep(padChar or " ", padLength)
end

function String.richText(p,v,s)
    -- [color=#57AEFF][/color]
    if type(s)=="table" then s = serpent.line(s) end -- LocalisedString
    return "["..p.."="..v.."]"..s.."[/"..p.."]"
end

-- String.padCenter / padBoth

-- [1]: https://github.com/lua-nucleo/lua-nucleo/blob/v0.1.0/lua-nucleo/string.lua#L245-L267

---------------------------------------------------------------------------------------------------

function String.__setGlobals()
	---Returns a string representing the value for display purposes (nil=>"")
	---@diagnostic disable-next-line: lowercase-global
	_G.prettystr = String.pretty -- make globally available

	---Returns a string representing the value for debug purposes (nil=>!NIL, "string in quotes")
	---@diagnostic disable-next-line: lowercase-global
	function _G.str(v) return prettystr_core(v,0,{showNil=true, useQuotes=true, cycleDetectTable={}, printTableRefs=false, recursive=false, maxLevel=0}) end
end

-----------------------------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(String)
return String