local config = require 'config'


local _M = {}


local function get_entity(entity, position)
	return entity.surface.find_entity(config.SETTINGS_ENTITY_NAME, position or entity.position)
end
local function get_or_create_entity(entity)
	return get_entity(entity) or entity.surface.create_entity {
		name = config.SETTINGS_ENTITY_NAME,
		position = entity.position,
		force = entity.force,
		create_build_effect_smoke = false,
		alert_parameters = {alert_message = 'nil'},
	}
end


function _M.def(defs)
	local res = {by_key = {}, by_name = {}}
	for name, def in pairs(defs) do
		if type(name) == 'string' then
			if type(def) ~= 'table' then def = {def, 'raw'}; end
			local key, typ = def[1], def[2]
			local tdef = {name = name, key = key, type = typ}
			res.by_key[key] = tdef; res.by_name[name] = tdef
			if not typ then
				tdef.type = 'table'
				tdef.defs = _M.def(def)
			end
		end
	end
	return res
end


local function _dump(defs, tab)
	if type(tab) ~= 'table' then return tab; end
	local res = {}
	for name, value in pairs(tab) do
		local def = defs.by_name[name]
		if def then
			if def.type == 'table' then res[def.key] = _dump(def.defs, value)
			elseif def.type == 'bool' then res[def.key] = (value and 1) or 0
			else res[def.key] = value; end
		end
	end
	return res
end
function _M.dump(defs, tab) return serpent.line(_dump(defs, tab), {compact = true}); end


local function _parse(defs, raw)
	if type(raw) ~= 'table' then return raw; end
	local res = {}
	for key, value in pairs(raw) do
		local def = defs.by_key[key]
		if def then
			if def.type == 'table' then res[def.name] = _parse(def.defs, value)
			elseif def.type == 'bool' then res[def.name] = value == 1
			else res[def.name] = value; end
		end
	end
	return res
end
function _M.parse(defs, str) return _parse(defs, load('return '..str)()); end


function _M.read(defs, entity, default)
	local e = get_or_create_entity(entity)
	local res = _M.parse(defs, e.alert_parameters.alert_message)
	if not res and default ~= nil then _M.update(defs, entity, default); end
	return res or default
end

function _M.update(defs, entity, settings)
	local e = get_or_create_entity(entity)
	e.alert_parameters = {alert_message = _M.dump(defs, settings)}
end

function _M.move_entity(entity, original_position)
	local e = get_entity(entity, original_position)
	if e then e.teleport(entity.position); end
end

function _M.destroy(entity)
	local e = get_entity(entity)
	if e then e.destroy(); end
end


function _M.fill_defaults(target, defaults)
	for key, value in pairs(defaults) do
		if target[key] == nil then target[key] = value
		elseif type(value) == 'table' then _M.fill_defaults(target[key], value); end
	end
end


return setmetatable(_M, {__call=function(cls, defs)
	return {
		defs = _M.def(defs),
		parse = function(self, str) return _M.parse(self.defs, str); end,
		dump = function(self, tab) return _M.dump(self.defs, tab); end,
		read = function(self, entity, default) return _M.read(self.defs, entity, default); end,
		update = function(self, entity, settings) return _M.update(self.defs, entity, settings); end,
		
		read_or_default = function(self, entity, default)
			local res = self:read(entity, default)
			_M.fill_defaults(res, default)
			return res
		end,
	}
end})
