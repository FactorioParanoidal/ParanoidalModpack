require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.That Provides messages for assert
---Usage: assert(That...) <br>
---This is because to show the correct position in code. <br>
---Each That functions returns (true, nil) or (false, message).
local That = {
    __class  = "That",
	__guid   = "{4AEB03A1-6391-4209-9856-D421B8914857}",
	__origin = "Kux-CoreLib/lib/That.lua",

	__isInitialized = false,
	__on_initialized = {},

    ---@class That.Not
    Not = {},
    ---@class That.Argument
    Argument = {},
    ---@class That.Table
    Table = {
        ---@class That.Table.Not
        Not = {}
    },
	String = {
		Not = {}
	},
    ---@class That.Array
    Array = {},
    ---@class That.Disctionary
    Disctionary = {},
    ---@class That.String
}
if not KuxCoreLib.__classUtils.ctor(That) then return self end

-- to avoid circular references, the class MUST be defined before require other modules
local Table = KuxCoreLib.Table
local String = KuxCoreLib.String
local Debug = KuxCoreLib.Debug

---raises an error if value is nil
---@param name string
---@param message? string
function That.Argument.IsNotNil(value, name, message)
    if value then return true end
    message = message or ("Argument must not be nil! Name='{name}'")
    message = message:gsub("{name}",name)
    return false, message
end

--assert(That.Argument("a", nil, Is.Not.Nil)

---raises an error if value is nil or empty
---@param name string
---@param message? string
function That.Argument.IsNotNilOrEmpty(value, name, message)
    if value~=nil and value ~="" then return true end
    message = message or ("Argument must not be nil or empty! Name='{name}'")
    message = message:gsub("{name}",name)
    return false, message
end

function That.IsEqual(value, expected)
    if value==expected then return true end
    if type(value) == type(expected) then
        if type(value)=="table" then
            if Table.isEqual(value,expected) then return true end
        end
    else
        return false, ("Types are not eqal. Expected: "..type(expected).." but was "..type(value))
    end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, ("Values are not eqal. Expected: "..tostring(expected).." but was "..tostring(value))
end

function That.IsNotEqual(value, expected, name)
    name = name or "Value"
    if value~=expected then return true end
    if type(value) ~= type(expected) then return true end
    if type(value)=="table" then
        if not Table.isEqual(value,expected) then return true end
    end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, (name.." is equal to "..tostring(value)..", but not equal was expected.")
end

function That.IsReferenceEqual(value, expected)
    if value==expected then return true end
    if value==nil then value="nil" end
    if expected==nil then expected="nil" end
    return false, ("Value reference are not eqal.")
end

---IsTrue
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsTrue(value,name)
    name = name or "Value"
    if value==true then return true end
    if value==nil then value="nil" end
    return false, (name.." is not true. Expected: true but was "..tostring(value))
end

---IsFalse
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsFalse(value,name)
    name = name or "Value"
    if value==false then return true end
    if value==nil then value="nil" end
    return false, (name.." is not false. Expected: false but was "..tostring(value))
end

---IsNil
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsNil(value, name)
    name = name or "Value"
    if value==nil then return true end
    return false, (name.." is not nil. but was "..tostring(value))
end

---IsNilOrFalse
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsNilOrFalse(value, name)
    name = name or "Value"
    if value==nil or value==false then return true end
    return false, (name.." is "..tostring(value)..". But nil or false was expected.")
end

---IsNotNil
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsNotNil(value, name)
    name = name or "Value"
    if value~=nil then return true end
    return false, (name.." is nil. but not nil was expected")
end

---Is Not Nil And Not False. same condition as in "if not variable then"
---@param value any
---@param name? string
---@return boolean
---@return string?
function That.IsNotNilOrFalse(value,name)
    name = name or "Value"
    if value~=nil and value ~= false then return true end
    return false, (name.." is "..tostring(value)..". but not nil and not false was expected")
end

---IsTypeOf
---@param value any
---@param expected string Expected type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---@return boolean
---@return string?
function That.IsTypeOf(value, expected)
    if type(value)==expected then return true end
    return false, ("Value are not type of "..expected.." but was type of "..type(value))
end

---IsNotTypeOf
---@param value any
---@param notExpected string unexpected type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---@return boolean
---@return string?
function That.IsNotTypeOf(value, notExpected)
    if type(value)~=notExpected then return true end
    return false, ("Value is type of "..notExpected..".")
end

-------------------------------------------------------------------------------
--#region That.Table

function That.Table.Contains(t, value)
    if t==nil then return false, ("Value is nil") end
    if type(t)~="table" then return false, ("Value ist not a table") end
    for _, v in pairs(t) do
        if v==value then return true end
    end
    return false, ("Table not contains the value.")
end

function That.Table.Not.Contains(t, value)
    if t==nil then return false, ("Value is nil") end
    if type(t)~="table" then return false, ("Value ist not a table") end
    for _, v in pairs(t) do
        if v==value then return false, ("Table contains the value.") end
    end
    return true
end
--#endregion That.Table
-------------------------------------------------------------------------------
--#region That.String

---String IsEqual
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.IsEqual(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if s==compareString then return true end
    return false, ("String not equal to '"..compareString.."'.")
end

---String Contains
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.Contains(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,String.escape(compareString)) then return true end
    return false, ("String not contains '"..compareString.."'.")
end

---String StartsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.StartsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,"^"..String.escape(compareString)) then return true end
    return false, ("String not starts with the '"..compareString.."'.")
end

---String EndsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.EndsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,String.escape(compareString).."$") then return true end
    return false, ("String not ends with '"..compareString.."'.")
end

---String not StartsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.Not.StartsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,"^"..String.escape(compareString)) then return true end
    return false, ("String starts with '"..compareString.."'.")
end

---String not EndsWith
---@param s string
---@param compareString string
---@return boolean
---@return string?
function That.String.Not.EndsWith(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,String.escape(compareString).."$") then return true end
    return false, ("String ends with '"..compareString.."'.")
end

---String matches
---@param s string
---@param comparePattern string
---@return boolean
---@return string?
function That.String.Matches(s, comparePattern)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if string.match(s,comparePattern) then return true end
    return false, ("String not matches with '"..comparePattern.."'.")
end

---String not matches
---@param s string
---@param comparePattern string
---@return boolean
---@return string?
function That.String.Not.Matches(s, comparePattern)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,comparePattern) then return true end
    return false, ("String matches with '"..comparePattern.."'.")
end

---String not Contains
---@param s any
---@param compareString any
---@return boolean
---@return string?
function That.String.Not.Contains(s, compareString)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    if not string.match(s,String.escape(compareString)) then return true end
    return false, ("String contains '"..compareString.."'.")
end

---String Contains All
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function That.String.ContainsAll(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    for _, cs in ipairs(compareStrings) do
        if not string.match(s,String.escape(cs)) then return false,("String not contains '"..cs.."'.") end
    end
    return true
end

---String Contains Any
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function That.String.ContainsAny(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value ist not a string") end
    for _, cs in ipairs(compareStrings) do
        if string.match(s,String.escape(cs)) then return true end
    end
    return false, ("String not contains any")
end

---String not Contains All
---@param s string
---@param compareStrings string[]
---@return boolean
---@return string?
function That.String.Not.ContainsAll(s, compareStrings)
    if s==nil then return false, ("Value is nil") end
    if type(s)~="string" then return false, ("Value is not a string") end
    for _, cs in ipairs(compareStrings) do
        if string.match(s,String.escape(cs)) then return false,("String contains '"..cs.."'.") end
    end
    return true
end

--#endregion That.String
-------------------------------------------------------------------------------

---Contains
---@param o any
---@param compare any
---@return boolean
---@return string?
function That.Contains(o, compare)
    local tt=type(o)
    if tt == "table" then return That.Table.Contains(o,compare) end
    if tt == "string" then return That.String.Contains(o, compare) end
    error("Contains is not applicable to type of "..tt..".")
end

---Not Contains
---@param o any
---@param compare any
---@return boolean
---@return string?
function That.NotContains(o, compare)
    local tt=type(o)
    if tt == "table" then return That.Table.Not.Contains(o,compare) end
    if tt == "string" then return That.String.Not.Contains(o, compare) end
    error("Contains is not applicable to type of "..tt..".")
end

function That.HasError(fnc)
	local success = pcall(fnc)

    if success==false then return true end
    return false, ("Error expected")
end

function That.HasNoError(fnc)
	local success, ex = pcall(fnc)
    if success==true then return true end
    return false, ("No error expected, but got '"..ex.."'")
end

local prefixe =nil-- lazy loaded
local has_no_parameter = nil-- lazy loaded

local function main()
	-- because circular references betwween That and Table/String we have to use lazy load
	if(not Table.__isInitialized or not String.__isInitialized) then return end

	prefixe = Table.toFlagsDictionary(String.split("String,Table",","))
	has_no_parameter = Table.toFlagsDictionary(String.split("Is,Or,And,Not,True,False,Nil,Empty",","))
end
table.insert(Table.__on_initialized, main)
table.insert(String.__on_initialized, main)

---The metatable for the Contraint class
Contraint_metatable = {}

function Contraint_metatable.__index(self, key)
	if(key=="__class" or key=="__guid" or key=="__origin" or
		key=="name" or key=="prev" or key=="next" or key=="args") then return nil end
	if(key=="set") then
		return function (...)
			self.args=table.pack(...)
			return self
		end
	elseif(prefixe[key] or has_no_parameter[key]) then -- Or,And,Not etc.
		self.next = Constraint:new(key)
		self.next.prev=self
		return self.next
	else -- we accept each key as constraint with one argument, but we have to exclude real members: prev, args, etc...
		-- drawback, if we forget  that, we get an error >> attempt to index field 'args' (a function value)
		self.next = Constraint:new(key)
		self.next.prev=self
		return self.next.set
	end
end

---@class Constraint
---@field Not Constraint
---@field And Constraint
---@field Or Constraint
---@field True Constraint
---@field False Constraint
---@field Nil Constraint
---@field Equal Constraint
---@field StartsWith Constraint
---@field EndsWith Constraint
---@field Empty Constraint tests that an object is an empty string, directory or collection.
---@field Contains Constraint tests for a substring.
Constraint = {}
function Constraint:new(name, ...)
	return setmetatable({
		name = name,
		args = table.pack(...)
	},Contraint_metatable)
end
function Constraint:set(self, ...)
	self.args = table.pack(...)
	return self
end

local Is = Constraint:new("Is")
Is.__class  = "Is"
Is.__guid   = "e20c53b4-8a03-4bef-9679-133b89a984ec"
Is.__origin = "Kux-CoreLib/lib/That.lua"

local function That_fnc(_, what, constraint)
	local fnc_path="That"
	local fnc=That --[[@as any]]
	local fNot = nil
	local c = constraint
	local first = nil
	while c do first = c; c = c.prev end
	c = first;
	local result = true
	local message = nil
	local function prefix()
		if(type(fnc)=="table")then
			if(fnc[c.name]) then
				fnc=fnc[c.name]
				fnc_path = fnc_path .."."..c.name
			else
				error("Invalid constraint. "..c.name)
			end
		else
			error("Invalid constraint. "..c.name)
		end
	end

	local function callThat()
		local name = c.name; if(fNot) then name = "Not"..name end --Equal|NotEqual
		if(fnc["Is"..name]) then
			fnc = fnc["Is"..name]
			fnc_path = fnc_path ..".Is"..name
		elseif(fnc[name]) then
			fnc = fnc[name]
			fnc_path = fnc_path .."."..name
		else
			fnc = nil
			fnc_path = fnc_path .."."..name
			error("Function not found! Name:'"..fnc_path.."'")
		end --IsEqual|IsNotEqual


		result, message = fnc(what,table.unpack(c.args or {}))
		fNot=false
		fnc=That
		fnc_path="That"
	end

	while c do
		if(c.name=="Is") then
		elseif(c.name=="And") then if(not result) then break end; goto next
		elseif(c.name=="Or" ) then if(result) then break end; goto next
		elseif(c.name=="Not") then fNot=true; goto next
		elseif(prefixe[c.name]) then prefix(); goto next
		else callThat()
		end
		if(c.next == nil) then break end
		::next::
		c = c.next
	end
	return result, message
end
--[[
AllItems
AnyOf
AssignableFrom
AssignableTo
Attribute
AttributeExists
BinarySerializable
CollectionContains
CollectionEquivalent
CollectionOrdered
CollectionSubset
CollectionSuperset
Delayed
DictionaryContainsKey
DictionaryContainsKeyValuePair
DictionaryContainsValue
EmptyCollection
Empty
EmptyDirectory
EmptyString
EndsWith
ExactCount
ExactType
False
FileOrDirectoryExists
GreaterThan
GreaterThanOrEqual
InstanceOfType
LessThan
LessThanOrEqual
NaN
NoItem
Property
PropertyExists
Range
Regex
Reusable
SameAs
SamePath
SamePathOrUnder
SomeItems
StartsWith
SubPath
Substring
Throws
ThrowsNothing
True
UniqueItems
XmlSerializable
]]

setmetatable(That, {
	__call=That_fnc
})

That.Is=Is

-- assert(That("foo", Is.EqualTo("foo").Or.StartsWith("f")))
-- assert(That("foo", Is.Not.EqualTo("foo").Or.String.Not.StartsWith("f")))
---------------------------------------------------------------------------------------------------

---Provides That in the global namespace
---@return KuxCoreLib.That
function That.asGlobal()
	KuxCoreLib.__classUtils.asGlobal(Is)
	return KuxCoreLib.__classUtils.asGlobal(That)
end
main()
That.__isInitialized=true
for _, fnc in ipairs(That.__on_initialized) do fnc() end

return That, Is