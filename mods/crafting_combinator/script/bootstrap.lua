-- Fix that require raises an error when called after control.lua has finished executing, even if it doesn't actually
-- need to load anything... This was changed in 0.17.57 I think.
local _require = _G.require
_G.require = function(what, ...)
	if package.loaded[what] ~= nil then return package.loaded[what]; end
	return _require(what, ...)
end


local semver = require 'script.semver'

local function parse_version(version)
	if not version:match('^%d+%.%d+%.%d+$') then return nil; end
	return semver(version)
end

local function migration_tostring(migration)
	if not migration.version then return tostring(migration.name); end
	return tostring(migration.name).." (for version "..tostring(migration.version)..")"
end

-- A nice alternative to stuffing everything into on_configuration_changed with seven hundred ifs
_G.late_migrations = setmetatable({__migrations = {}, __ordered = {}, __versioned = {}}, {
	__newindex = function(self, name, migration)
		if type(name) == 'table' then
			assert(type(migration) == 'function')
			name.apply = migration
			migration = name
		else
			if type(migration) == 'function' then migration = {apply=migration}; end
			migration.name = name
			migration.version = migration.version or parse_version(migration.name)
		end
		
		local _apply = migration.apply
		function migration:apply(changes)
			log("Applying late migration "..migration_tostring(self))
			_apply(changes)
		end
		
		assert(self.__migrations[migration.name] == nil, "Late migration with name "..tostring(migration.name).." already exists")
		
		self.__migrations[migration.name] = migration
		if migration.version then table.insert(self.__versioned, migration)
		else table.insert(self.__ordered, migration); end
		
		print("Registered late migration "..migration_tostring(migration))
	end,
	
	__call = function(self, changes)
		table.sort(self.__versioned, function(m1, m2) return m1.version <= m2.version; end)
		for _, migration in ipairs(self.__versioned) do migration:apply(changes); end
		for _, migration in ipairs(self.__ordered) do migration:apply(changes); end
	end,
	
	__index = function(self, key) return self.__migrations[key]; end,
})
