---@class KuxCoreLib.debug_util
local debug_util = {} --> Debug.util

local function unescapeWhitespaces(str)
	str = string.gsub(str, "\\n", "\n") -- Zeilenumbruch
	str = string.gsub(str, "\\t", "\t") -- Tabulator
	-- Weitere Escape-Sequenzen hinzufügen, falls erforderlich
	return str
end

local function unescape(str)
	local unescapedStr = str:gsub("\\(.)", function(c)
		if c == "a" then			return "\a"
		elseif c == "b"  then return "\b"
		elseif c == "f"  then return "\f"
		elseif c == "n"  then return "\n"
		elseif c == "r"  then return "\r"
		elseif c == "t"  then return "\t"
		elseif c == "v"  then return "\v"
		elseif c == "\\" then return "\\"
		elseif c == "\"" then return "\""
		elseif c == "'"  then return "'"
		elseif c == "["  then return "["
		elseif c == "]"  then return "]"
		elseif c == "\n" then return ""
		elseif c == "\r" then return ""
		else                  return "\\" .. c
		end
	end)
	return unescapedStr
end

---Returns the mod of the method that invoked the currently executing method.
---@param excludeSelf boolean?
---@return string?
function debug_util.getCallingMod(excludeSelf)
	local stackTrace = debug.traceback()
	local mod = ""
	local c = 0
	local self = ""
	for line in stackTrace:gmatch("[^\r\n]+") do
		c = c + 1
		if (c == 2) then
			self = line:match("__([^/]+)__/")
		elseif (c > 3) then
			local match = line:match("__([^/]+)__/")
			if match and match ~= self then return match end
		end
	end
	return nil
end

---Gets the mod that contains the code that is currently executing.
---@return string?
function debug_util.getExecutingMod()
	local stackTrace = debug.traceback()
	local mod = ""
	local c = 0
	for line in stackTrace:gmatch("[^\n]+") do
		c = c + 1
		if (c > 2) then
			mod = line:match("__([^/]+)__/")
			if (mod) then return mod end
		end
	end
	return nil
end

---Returns the first mod of the current call sequence.
---@return any
function debug_util.getEntryMod()
	local stackTrace = debug.traceback()
	local mod = nil
	for line in stackTrace:gmatch("[^\r\n]+") do
		local match = line:match("__([^/]+)__/")
		if match then mod = match end
	end
	return mod
end

function debug_util.getClassFileName(class)
	--local classTable = getmetatable(class)

	for _, value in pairs(class) do
	  if type(value) == "function" then
		local info = debug.getinfo(value, "S")
		if info.source and info.source ~= "=[C]" then
		  return info.source:gsub("@", "")
		end
	  end
	end

	return nil
end

function debug_util.extractLineBeforeXpcall(stackTrace)
	--[[
stack traceback:
        [C]: in function 'error'
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/String.lua:159: in function 'split'
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/String.lua:189: in function 'split'
        tests/StringTests.lua:18: in function <tests/StringTests.lua:17>
        [C]: in function 'xpcall'
		D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/TestRunner.lua:31: in function 'runTestClass'
        D:\Develop\Factorio\Mods\Kux-CoreLib/src/lib/TestRunner.lua:78: in function 'run'	
        tests/StringTests.lua:65: in main chunk
		[C]: in function 'require'
        D:\Develop\Factorio\Mods\Kux-CoreLib/tests/run.lua:22: in main chunk
        [C]: in ?
--']]

	local previousLine = nil
	stackTrace = unescapeWhitespaces(stackTrace)
	for line in stackTrace:gmatch("[^\n]+") do
		if line:find("in function 'xpcall'") then
			return previousLine
		end
		previousLine = line
	end
	return nil
end

function debug_util.extractFunctionInfo(callstackLine)
	local fileName, lineNumber = callstackLine:match("<(.-):(.-)>")
	return fileName, tonumber(lineNumber)
end

---getEntryStage
---@return "settings"|"settings-updates"|"settings-final-fixes"|"data"|"data-updates"|"data-final-fixes"|"control"
function debug_util.getEntryStage()
	local stackTrace = debug.traceback()
	--print(stackTrace)
	local stage = nil
	for line in stackTrace:gmatch("[^\r\n]+") do
		local match = line:match("__[^/]+__/([^%.]+)%.lua")
		if match then stage = match end
	end
	return stage
end

return debug_util
