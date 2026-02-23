if true then return nil end -- module is deprecated

if(KuxCoreLib.__modules.RequireOverride) then
	KuxCoreLib.override_require()
	return
end

local RequireOverride = {}
KuxCoreLib.__modules.RequireOverride = RequireOverride

RequireOverride.require_table = {
	KuxCoreLib = KuxCoreLib
}

local function require_override(self,arg)
	--TODO: Require can't be used outside of control.lua parsing.
	if(type(arg)=="string") then return _require(arg) end
	return arg
end

setmetatable(RequireOverride.require_table,{
	__call = require_override
})

---The original 'require' funtion
---@diagnostic disable-next-line: lowercase-global
_require = _require;
---A special 'require' funtion
require = require

---Ovverrides the default require function
function KuxCoreLib.override_require()---@diagnostic disable-line: inject-field
	---@diagnostic disable-next-line: param-type-mismatch
	if(type(_G.require)=="function" and debug.getinfo(_G.require,"S").short_src=="[C]") then
		_G._require = _G.require
		_G.require = KuxCoreLib.__modules.RequireOverride.require_table
	end
end

KuxCoreLib.override_require()


