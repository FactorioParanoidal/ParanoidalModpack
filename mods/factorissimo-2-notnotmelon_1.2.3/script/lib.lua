remote_api = {}

BUILDING_TYPE = 'storage-tank'

--[[
factory = {
	+id = *,
	(+)inactive = *,

	+outside_surface = *,
	+outside_x = *,
	+outside_y = *,
	+outside_door_x = *,
	+outside_door_y = *,

	+inside_surface = *,
	+inside_x = *,
	+inside_y = *,
	+inside_door_x = *,
	+inside_door_y = *,

	+force = *,
	+layout = *,
	+building = *,
	+outside_energy_receiver = *,
	+outside_overlay_displays = {*},
	+outside_port_markers = {*},

	+inside_overlay_controller = *,
	+inside_power_poles = {*},
	(+)outside_power_pole = *,

	(+)middleman_id = *,
	(+)direct_connection = *,

	+stored_pollution = *,

	+connections = {*},
	+connection_settings = {{*}*},
	+connection_indicators = {*},

	+upgrades = {},
}
]]--

remote_api.get_global = function(path)
	if not path then return global end
	local g = global
	for _, point in ipairs(path) do
		g = g[point]
	end
	return g
end

remote_api.set_global = function(path, v)
	local g = global
	for i = 1, #path - 1 do
		g = g[path[i]]
	end
	g[path[#path]] = v
end
	
remote_api.get_factory_by_entity = function(entity)
	if entity == nil then return nil end
	return global.factories_by_entity[entity.unit_number]
end

remote_api.get_factory_by_building = function(entity)
	local factory = global.factories_by_entity[entity.unit_number]
	if factory == nil then
		game.print('ERROR: Unbound factory building: ' .. entity.name .. '@' .. entity.surface.name .. '(' .. entity.position.x .. ', ' .. entity.position.y .. ')')
	end
	return factory
end

local bt = BUILDING_TYPE
remote_api.find_factory_by_building = function(surface, area)
	for _,entity in pairs(surface.find_entities_filtered{area = area, type = bt}) do
		if Layout.has_layout(entity.name) then return remote_api.get_factory_by_building(entity) end
	end
	return nil
end

remote_api.find_surrounding_factory = function(surface, position)
	local factories = global.surface_factories[surface.name]
	if factories == nil then return nil end
	local x = math.floor(0.5+position.x/(16*32))
	local y = math.floor(0.5+position.y/(16*32))
	if (x > 7 or x < 0) then return nil end
	return factories[8*y+x+1]
end

remote_api.power_middleman_surface = function()
	if game.surfaces['factory-power-connection'] then
		return game.surfaces['factory-power-connection']
	end
	
	local map_gen_settings = {height=1, width=1, property_expression_names={}}
	map_gen_settings.autoplace_settings = {
		['decorative'] = {treat_missing_as_default=false, settings={}},
		['entity'] = {treat_missing_as_default=false, settings={}},
		['tile'] = {treat_missing_as_default=false, settings={['out-of-map']={}}},
	}
	
	local surface = game.create_surface('factory-power-connection', map_gen_settings)
	surface.set_chunk_generated_status({0, 0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({-1, 0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({0, -1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({-1, -1}, defines.chunk_generated_status.entities)
	
	return surface
end

return remote_api
