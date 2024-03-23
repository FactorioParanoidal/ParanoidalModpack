local config = require 'config'


local _M = {}


_M.EVERYTHING = {type = 'virtual', name = 'signal-everything'}


local cache_mt = {
	__index = function(self, key)
		local entity = self.__entity.surface.create_entity {
			name = config.SIGNAL_CACHE_NAME,
			position = self.__entity.position,
			force = self.__entity.force,
			create_build_effect_smoke = false,
		}
		self.__cache_entities[key] = entity
		entity.destructible = false
		
		self.__entity.connect_neighbour {
			wire = defines.wire_type.red,
			target_entity = entity,
			source_circuit_id = self.__circuit_id or nil,
		}
		self.__entity.connect_neighbour {
			wire = defines.wire_type.green,
			target_entity = entity,
			source_circuit_id = self.__circuit_id or nil,
		}
		
		self[key] = {
			__cb = entity.get_or_create_control_behavior(),
		}
		
		return self[key]
	end,
}


function _M.init_global()
	global.signals = global.signals or {}
	global.signals.cache = global.signals.cache or {}
end

function _M.on_load()
	for _, cache in pairs(global.signals.cache) do setmetatable(cache, cache_mt); end
end


_M.cache = {}

function _M.cache.get(entity, circuit_id)
	local cache = global.signals.cache[entity.unit_number]
	if not cache then
		cache = setmetatable({
			__entity = entity,
			__circuit_id = circuit_id or false, -- Avoid calling __index when the id is nil
			__cache_entities = {},
		}, cache_mt)
		global.signals.cache[entity.unit_number] = cache
	end
	return cache
end

function _M.cache.reset(entity, name)
	local cache = global.signals.cache[entity.unit_number]
	if cache and rawget(cache, name) then
		global.signals.cache[entity.unit_number][name] = {
			control_behavior = entity.get_or_create_control_behavior(),
		}
	end
end

function _M.cache.drop(entity)
	local cache = global.signals.cache[entity.unit_number]
	if cache then
		for key, e in pairs(cache.__cache_entities) do e.destroy(); end
		global.signals.cache[entity.unit_number] = nil
	end
end

function _M.cache.move(entity)
	local cache = global.signals.cache[entity.unit_number]
	if cache then
		for _, e in pairs(cache.__cache_entities) do e.teleport(entity); end
	end
end


function _M.get_merged_signals(entity, circuit_id)
	return circuit_id and (entity.get_merged_signals(circuit_id) or {}) or entity.get_merged_signals() or {}
end
function _M.get_merged_signal(entity, signal, circuit_id)
	if circuit_id then return entity.get_merged_signal(signal, circuit_id)
	else return entity.get_merged_signal(signal); end
end


function _M.get_highest(entity, circuit_id, update_count)
	local cache = _M.cache.get(entity, circuit_id)
	
	if cache.highest.valid
		and not cache.highest.__cb.disabled
		and (not cache.highest.value or not cache.highest_present.__cb.disabled)
	then
		if update_count and cache.highest.value and cache.highest_count.__cb.disabled then
			local count = _M.get_merged_signal(entity, cache.highest.value.signal, circuit_id)
			
			cache.highest.value.count = count
			cache.highest_count.__cb.circuit_condition = {condition = {
				comparator = '=',
				first_signal = cache.highest.value.signal,
				constant = count,
			}}
		end
		return cache.highest.value
	end
	
	local highest = nil
	for _, signal in pairs(_M.get_merged_signals(entity, circuit_id)) do
		if highest == nil or signal.count > highest.count then highest = signal; end
	end
	
	cache.highest.valid = true
	
	if highest then
		cache.highest.value = highest
		cache.highest.__cb.circuit_condition = {condition = {
			comparator = '≤',
			first_signal = _M.EVERYTHING,
			second_signal = highest.signal,
		}}
		
		cache.highest_present.__cb.circuit_condition = {condition = {
			comparator = '≠',
			first_signal = highest.signal,
			constant = 0,
		}}
		
		cache.highest_count.__cb.circuit_condition = {condition = {
			comparator = '=',
			first_signal = highest.signal,
			constant = highest.count,
		}}
	else
		cache.highest.value = nil
		cache.highest.__cb.circuit_condition = {condition = {
			comparator = '=',
			first_signal = _M.EVERYTHING,
			constant = 0,
		}}
	end
	
	return highest
end


function _M.watch_highest_presence(entity, circuit_id)
	local highest = _M.get_highest(entity, circuit_id)
	local cache = _M.cache.get(entity, circuit_id)
	
	if not highest then
		cache.signal_present.valid = false
	else
		cache.signal_present.valid = true
		cache.signal_present.__cb.circuit_condition = {condition = {
			comparator = '>',
			first_signal = highest.signal,
			constant = 0,
		}}
	end
	
	return highest
end
function _M.signal_present(entity, circuit_id)
	local cache = _M.cache.get(entity, circuit_id)
	return cache.signal_present.valid and not cache.signal_present.__cb.disabled
end


return _M
