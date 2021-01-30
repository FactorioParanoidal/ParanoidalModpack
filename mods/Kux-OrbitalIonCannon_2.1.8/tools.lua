String = String or {}

String.startsWith = function (string,compare)
	return string.sub(string,1,string.len(compare))==compare
end

Version = Version or {}

Version.baseVersionGreaterOrEqual1d1 = function ()
	local v = ""
	if mods then v = mods["base"] else v = script.active_mods["base"] end
	if String.startsWith(v,"0.") then return false end
	if String.startsWith(v,"1.0") then return false end
	return true
end