-- Libraries dealing with require/modules

local lib = {}

-- Implementation of require guards to prevent modules from being multi-loaded
-- in the same Lua namespace. You should only use this when modules may actually
-- clobber shared data.

if not _G.__require_guard then _G.__require_guard = {} end

---Raise a Lua error if this module has already been loaded.
---@param name string Unique name of the module.
function lib.require_guard(name)
	if _G.__require_guard[name] then
		error(
			"Module '"
				.. name
				.. "' has already been loaded in this Lua environment and may not be loaded twice."
		)
	end
	_G.__require_guard[name] = true
end

---Returns the key in Lua's package.loaded table for the given module
---as described by the value of the `...` arg at the root of a module.
function lib.package_key(...)
	-- Type inference doesn't know this is a string.
	---@diagnostic disable-next-line: undefined-field
	return string.format("__%s__/%s.lua", script.mod_name, (...):gsub("%.", "/"))
end

return lib
