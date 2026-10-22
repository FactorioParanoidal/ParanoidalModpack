local util = scripts.util
local config = require("config")
local protocache = require("scripts.protocache")
local entity = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaEntity --

function entity:isIgnored(player)
	local name = self.name
	return not protocache.isAllowedEntity(name) or
		   storage.settings[player.index].ignoredEntities[name] or
		   (storage.remoteIgnoredEntities and storage.remoteIgnoredEntities[name])
end

function entity:recipe()
	local recipe = self.get_recipe()
	if not recipe and self.type == "furnace" then
		local previous = self.previous_recipe -- 2.0: { name = LuaRecipePrototype, quality = ... }
		recipe = previous and previous.name
	end
	return _(recipe)
end

-- for turrets
function entity:supportsAmmo(item)
	return protocache.supportsAmmo(self.prototype, item)
end

-- for furnace
function entity:canSmelt(item)
	return protocache.canSmelt(self.prototype, item)
end
