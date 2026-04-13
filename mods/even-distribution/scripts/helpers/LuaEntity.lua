local util = scripts.util
local config = require("config")
local entity = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaEntity --

function entity:isIgnored(player)
	return not storage.allowedEntities[self.name] or
		   storage.settings[player.index].ignoredEntities[self.name] or
		   storage.remoteIgnoredEntities[self.name]
end

function entity:recipe()
	return _(self.get_recipe() or (self.type == "furnace" and self.previous_recipe and self.previous_recipe.name))
end

-- for turrets
function entity:supportsAmmo(item)
	local ammoCategory = item.ammo_category
	local attackParameters = self.prototype.attack_parameters

	if attackParameters and _(ammoCategory):is("valid") then
		return _(attackParameters.ammo_categories):contains(ammoCategory.name)
	end

	return false
end

-- for furnace
function entity:canSmelt(item)
	return #prototypes.get_recipe_filtered({
		unpack(_(self.prototype.crafting_categories):map(function(category)
			return nil, {filter = "category", category = category, mode = "or"}
		end):toPlain()),
		{filter = "has-ingredient-item", elem_filters = {{filter = "name", name = item}}, mode = "and"},
	}) > 0
end