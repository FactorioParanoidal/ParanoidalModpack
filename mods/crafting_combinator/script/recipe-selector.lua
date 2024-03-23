local signals = require 'script.signals'


local _M = {}


function _M.get_recipe(entity, circuit_id, last_name, last_count)
	local highest = signals.get_highest(entity, circuit_id, last_count ~= nil)
	
	if not highest then
		if last_name == nil then return false; end
		return true, nil, 0
	end
	
	if last_name == highest.signal.name and (last_count == nil or last_count == highest.count) then return false; end
	return true, entity.force.recipes[highest.signal.name], highest.count
end


local get_recipes_cache = {
	ingredients = {
		item = {},
		fluid = {},
	},
	products = {
		item = {},
		fluid = {},
	},
}
function _M.get_recipes(entity, circuit_id, mode, last_signal, last_count)
	local highest = signals.get_highest(entity, circuit_id, last_count ~= nil)
	
	if not highest or highest.signal.type == 'virtual' then
		if last_signal == nil then return false; end
		return true, {}, 0, nil
	end
	
	if last_signal
		and last_signal.name == highest.signal.name
		and last_signal.type == highest.signal.type
		and (last_count == nil or last_count == highest.count)
	then return false; end
	
	local cache = get_recipes_cache[mode][highest.signal.type]
	local force_index = entity.force.index
	cache[force_index] = cache[force_index] or {}
	if cache[force_index][highest.signal.name] then
		return true, cache[force_index][highest.signal.name], highest.count, highest.signal
	end
	
	local results = {}
	for name, recipe in pairs(entity.force.recipes) do
		for _, product in pairs(recipe[mode]) do
			if product.name == highest.signal.name and product.type == highest.signal.type then
				local amount = tonumber(product.amount or product.amount_min or product.amount_max) or 1
				amount = amount * (tonumber(product.probability) or 1)
				table.insert(results, {recipe = recipe, amount = amount})
				break
			end
		end
	end
	
	cache[force_index][highest.signal.name] = results
	return true, results, highest.count, highest.signal
end


local signal_cache = {}
function _M.get_signal(recipe)
	local signal = signal_cache[recipe]
	if not signal then
		signal = {
			name = recipe,
			type = (game.item_prototypes[recipe] and 'item') or (game.fluid_prototypes[recipe] and 'fluid') or 'virtual'
		}
		signal_cache[recipe] = signal
	end
	return signal
end


return _M
