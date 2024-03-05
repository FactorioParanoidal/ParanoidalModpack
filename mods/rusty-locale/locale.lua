local util = require '__rusty-locale__.util'
local prototypes = require '__rusty-locale__.prototypes'
local recipes = require '__rusty-locale__.recipes'


local _M = {}


local function remove_trailing_level(prototype_name)
	-- locale key for levelled technologies is the technology name with the level removed
	return prototype_name:gsub("-%d+$", "")
end

local function key_of(prototype, type, locale_type)
--- Get the default locale key for the given prototype and key type (name or description).
	if not locale_type then locale_type = prototypes.inherits(prototype.type, _M.localised_types); end
	local prototype_name = prototype.name
	if locale_type == 'technology' then
		prototype_name = remove_trailing_level(prototype_name)
	end
	return {('%s-%s.%s'):format(locale_type, type, prototype_name)}
end


--- These are the types that support locale (including all of their descendants).
_M.localised_types = {}
for type, _ in pairs(prototypes.descendants('prototype-base')) do _M.localised_types[type] = true; end


function _M.of_generic(prototype, locale_type)
--- Get the locale of the given prototype, assuming it's one of the types that use the generic format.
	return util.resolver {
		name = function() return prototype.localised_name or key_of(prototype, 'name', locale_type); end,
		description = function() return prototype.localised_description or key_of(prototype, 'description', locale_type); end,
	}
end

function _M.of_item(prototype)
--- Get the locale of the given item.
	return util.resolver {
		place_result = function()
			return prototype.place_result and prototype.place_result ~= '' and _M.of_generic(prototypes.find(prototype.place_result, 'entity'), 'entity') or false
		end,
		placed_as_equipment_result = function()
			return prototype.placed_as_equipment_result and _M.of_generic(prototypes.find(prototype.placed_as_equipment_result, 'equipment'), 'equipment') or false
		end,
		
		name = function(self)
			return prototype.localised_name
				or self.place_result and self.place_result.name
				or self.placed_as_equipment_result and self.placed_as_equipment_result.name
				or key_of(prototype, 'name', 'item')
		end,
		description = function(self) return prototype.localised_description or key_of(prototype, 'description', 'item'); end,
	}
end

function _M.of_recipe(prototype)
--- Get the locale of the given recipe.
	return util.resolver {
		main_product = function()
			local product = recipes.get_main_product(prototype)
			return product and _M.of(prototypes.find(product.name, product.type)) or {}
		end,
		
		name = function(self) return prototype.localised_name or self.main_product.name or key_of(prototype, 'name', 'recipe'); end,
		description = function(self) return prototype.localised_description or key_of(prototype, 'description', 'recipe'); end,
	}
end


local custom_resolvers = {
	['recipe'] = _M.of_recipe,
	['item'] = _M.of_item,
}
function _M.of(prototype, type)
--- Get the locale of the given prototype.
	if type ~= nil then prototype = prototypes.find(prototype, type); end
	local locale_type = prototypes.inherits(prototype.type, _M.localised_types)
	assert(locale_type, ("%s doesn't support localization"):format(prototype.type))
	
	local resolver = custom_resolvers[locale_type] or _M.of_generic
	return resolver(prototype, locale_type)
end


return _M
