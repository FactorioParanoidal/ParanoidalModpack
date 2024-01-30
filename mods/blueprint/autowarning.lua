
local modwarning = require "modwarning"

local function autowarning(name)
	if string.find(name, "tank") or string.find(name, "splitter") then
		modwarning("possible tank or splitter not flipped (name="..tostring(name).."). Please report it to the mod's Author.")
	end
end
return autowarning
