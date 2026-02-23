---@class Factorissimo.FactoryObject
---@field id integer
---@field inactive boolean
---@field outside_surface LuaSurface
---@field outside_x integer
---@field outside_y integer
---@field outside_door_x integer
---@field outside_door_y integer
---@field inside_surface LuaSurface
---@field inside_x integer
---@field inside_y integer,
---@field inside_door_x integer
---@field inside_door_y integer
---@field force LuaForce
---@field layout any
---@field building LuaEntity
---@field outside_energy_receiver any
---@field outside_overlay_displays any[]
---@field outside_port_markers any[]
---@field inside_overlay_controller any
---@field inside_power_poles any[]
---@field outside_power_pole any
---@field middleman_id any
---@field direct_connection any
---@field stored_pollution number
---@field connections any[]
---@field connection_settings any --{{*}*}
---@field connection_indicators any[]
---@field upgrades any
---@field built boolean

---@class Factorissimo.global
---@field factories Factorissimo.FactoryObject[] List of all factories
---@field saved_factories {any:Factorissimo.FactoryObject} Map: Id from item-with-tags -> Factory
---@field pending_saves any Map: Player or robot -> Save name to give him on the next relevant event
---@field factories_by_entity any {uint:boolean} Map: Entity unit number -> Factory it is a part of
---@field surface_factories any {string:Factorissimo.FactoryObject[]} Map: Surface name -> list of factories on it
---@field surface_factory_counters {string:integer} Map: Surface name -> number of used factory spots on it
---@field next_factory_surface integer
---@field last_player_teleport {uint:any} Map: Player index -> Last teleport time
---@field player_preview_active {uint:boolean} Map: Player index -> Whether preview is activated
---@field middleman_power_poles any[] List of all factory power pole middlemen

---@class Factorissimo.API
local api = {
	class="Factorissimo.API"
}

local function isAvailable()
	return remote.interfaces['factorissimo'] ~= nil
end

function api.make_connection()
	remote.call('factorissimo', 'make_connection')
end

function api.add_layout()
	remote.call('factorissimo', 'add_layout')
end

---Returns true if an entity name has a factory layout
---@param name string Name of an entity prototype
---@return boolean
function api.has_layout(name)
	return remote.call('factorissimo', 'has_layout', name) --[[@as boolean]]
end

---Returns the layout object for the given entity name
---@param name string Name of an entity prototype
function api.create_layout(name)
	remote.call('factorissimo', 'create_layout', name)
end

---Sets a value in Factorissimo's global table.
---@param path string[]]? (optional) - table of indexes leading to the desired table
---@return any
function api.get_global(path)
	--local force = remote.call('factorissimo', 'get_global', {'factories', 1}).force
	return remote.call('factorissimo', 'get_global', path)
end

---Sets a value in Factorissimo's global table.
---@param path string[] table of indexes leading to the value to be updated
---@param value any The value to be set
function api.set_global(path, value)
	return remote.call('factorissimo', 'set_global', path, value)
end

---Returns a factory object from a factory building entity. nil if the factory is not found
---@param entity LuaEntity
---@return Factorissimo.FactoryObject?
function api.get_factory_by_entity(entity)
	return remote.call('factorissimo', 'get_factory_by_entity', entity)
end

---Returns a factory object from a factory building entity. Throws an error if the factory object isn't found.
---In fact the same as get_factory_by_entity, but throws an error instead of returning nil.
---@param entity LuaEntity
---@return Factorissimo.FactoryObject
function api.get_factory_by_building(entity)
	return remote.call('factorissimo', 'get_factory_by_building', entity) --[[@as Factorissimo.FactoryObject]]
end

---Returns a factory object based on a surface and a position. nil if the factory is not found
---@param surface LuaSurface
---@param position MapPosition
---@return Factorissimo.FactoryObject?
function api.find_surrounding_factory(surface, position)
	if(not isAvailable()) then return nil end
	return remote.call('factorissimo', 'find_surrounding_factory', surface, position) --[[@as Factorissimo.FactoryObject?]]
end

---Searches for any factory buildings in an area
---@param surface LuaSurface
---@param position MapPosition
---@return any
function api.find_factory_by_building(surface, position)
	return remote.call('factorissimo', 'find_factory_by_building', surface, position)
end

---Returns the surface used for power middleman poles and circuit middleman poles
---@return LuaSurface
function api.power_middleman_surface()
	return remote.call('factorissimo', 'power_middleman_surface') --[[@as LuaSurface]]
end

return api