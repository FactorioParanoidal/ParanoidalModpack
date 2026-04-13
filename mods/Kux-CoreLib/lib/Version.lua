require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides version functions
---@class KuxCoreLib.Version : KuxCoreLib.Class
---@field asGlobal KuxCoreLib.Version Provides Version in the global namespace
Version = {
    __class  = "Version",
	__guid   = "{3F3C2EDA-5537-4643-8A33-6B00A0F42C25}",
	__origin = "Kux-CoreLib/lib/Version.lua",
}
if not KuxCoreLib.__classUtils.ctor(Version) then return self end
---------------------------------------------------------------------------------------------------
-- to avoid circular references, the class MUST be defined before require other modules
local String = KuxCoreLib.String

Version.baseVersionGreaterOrEqual1d1 = function ()
	local v = ""
	---@diagnostic disable-next-line: undefined-global
	if mods then v = mods["base"] else v = mods["base"] end
	if String.startsWith(v,"0.") then return false end
	if String.startsWith(v,"1.0") then return false end
	return true
end

local splitString = function (text)
	local list = {}; local pos = 1
	while 1 do
		local first, last = string.find(text, "%.", pos)
		if first then
		    local d = string.sub(text, pos, first-1)
			table.insert(list, tonumber(d))
			pos = last+1
		else
		    local d = string.sub(text, pos)
			table.insert(list, tonumber(d))
		    break
		end
	end
	return list
end

Version.compare = function (versionA, versionB)
	--local v0 = helpers.compare_versions(versionA, versionB) -->=2.0.55
	local a = splitString(versionA)
	local b = splitString(versionB)
	for i = 1, 3, 1 do
		local ax=0
		local bx=0
		if i <= #a then ax = a[i] end
		if i <= #b then bx = b[i] end
		if ax<bx then return -1 end
		if ax>bx then return 1 end
	end
	return 0
end

do
	assert(helpers.compare_versions("1.1.1", "1.1.2")==Version.compare("1.1.1", "1.1.2"))
	assert(helpers.compare_versions("1.1.0", "1.1"  )==Version.compare("1.1.0", "1.1"  ))
	--not supported: assert(helpers.compare_versions("1.0.0", "1"    )==Version.compare("1.0.0", "1"    ))
end

---Creates a new version
---@param major uint16
---@param minor uint16
---@param build uint16
---@return KuxCoreLib.Version
function Version:new(major,minor,build)
	self = {
		majpr=major,
		minor=minor,
		build=build
	}
	return self
end

---Creates a new version from string
---@param s string
---@return KuxCoreLib.Version
function Version:parse(s)
	local tokens = splitString(s)
	self = {
		major=tokens[1],
		minor=tokens[2],
		build=tokens[3]
	}
	return self
end

---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(Version)
return Version
