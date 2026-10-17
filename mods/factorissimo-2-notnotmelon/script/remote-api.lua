remote_api = {}

BUILDING_TYPE = "storage-tank"

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
	+global_electric_network_pole = {*},
	+outside_overlay_displays = {*},
	+outside_port_markers = {*},

	+inside_overlay_controller = *,
	+_inside_power_pole = *,

	+stored_pollution = *,

	+connections = {*},
	+connection_settings = {{*}*},
	+connection_indicators = {*},

	+upgrades = {},
}
]] --

-- Debug access to this mod's storage (the 1.1 `global` table is `storage` in 2.0).
remote_api.get_global = function(path)
    local g = storage
    if not path then return g end
    for _, point in ipairs(path) do
        if g == nil then return nil end
        g = g[point]
    end
    return g
end

remote_api.set_global = function(path, v)
    local g = storage
    for i = 1, #path - 1 do
        g = g[path[i]]
    end
    g[path[#path]] = v
    factorissimo.clear_layout_cache()
end

remote_api.get_factory_by_entity = function(entity)
    if entity == nil then return nil end
    return storage.factories_by_entity[entity.unit_number]
end

remote_api.get_factory_by_building = function(entity)
    local factory = storage.factories_by_entity[entity.unit_number]
    if factory == nil then
        game.print("ERROR: Unbound factory building: " .. entity.name .. "@" .. entity.surface.name .. "(" .. entity.position.x .. ", " .. entity.position.y .. ")")
    end
    return factory
end

remote_api.find_factory_by_area = function(params)
    local surface = params.surface
    local position = params.position
    local area = params.area

    for _, entity in pairs(surface.find_entities_filtered {position = position, area = area, type = BUILDING_TYPE}) do
        if has_layout(entity.name) then return remote_api.get_factory_by_building(entity) end
    end
    return nil
end

remote_api.find_factories_by_area = function(params)
    local surface = params.surface
    local area = params.area

    local factories = {}
    for _, entity in pairs(surface.find_entities_filtered {area = area, type = BUILDING_TYPE}) do
        if has_layout(entity.name) then
            local factory = remote_api.get_factory_by_building(entity)
            if factory then factories[#factories + 1] = factory end
        end
    end
    return factories
end

local floor = math.floor

local function surrounding_factory(surface_index, position)
    local factories = storage.surface_factories[surface_index]
    if factories == nil then return nil end
    local x = floor(0.5 + (position.x or position[1]) / (16 * 32))
    local y = floor(0.5 + (position.y or position[2]) / (16 * 32))
    if x > 7 or x < 0 or y < 0 then return nil end
    return factories[8 * y + x + 1]
end

remote_api.find_surrounding_factory = function(surface, position)
    return surrounding_factory(surface.index, position)
end

remote_api.find_surrounding_factory_by_surface_index = function(surface_index, position)
    return surrounding_factory(surface_index, position)
end

---Lightweight alternative to find_surrounding_factory for other mods: a remote call copies the whole
---returned table, and a factory table is large. Returns where the factory around `position` stands outside.
---@return {id: integer, built: boolean, outside_surface: LuaSurface, outside_x: number, outside_y: number, outside_door_x: number, outside_door_y: number}?
remote_api.get_surrounding_factory_exit = function(surface, position)
    local surface_index
    if type(surface) == "number" then
        surface_index = surface
    elseif type(surface) == "string" then
        local s = game.get_surface(surface)
        if not s then return nil end
        surface_index = s.index
    else
        surface_index = surface.index
    end
    local factory = surrounding_factory(surface_index, position)
    if not factory or not factory.outside_surface then return nil end
    return {
        id = factory.id,
        built = factory.built or false,
        outside_surface = factory.outside_surface,
        outside_x = factory.outside_x,
        outside_y = factory.outside_y,
        outside_door_x = factory.outside_door_x,
        outside_door_y = factory.outside_door_y,
    }
end

remote_api.create_layout = function(name, quality)
    local layout = storage.layout_generators[name]
    if not layout then return nil end
    layout = table.deepcopy(layout)

    local connections = {}
    for id, connection in pairs(layout.connections) do
        if (connection.quality or 0) <= quality.level then
            connections[id] = connection
        end
    end
    layout.connections = connections

    return layout
end

-- Cache of entity/item name -> layout name (false when the name has no layout). Derived only from
-- storage.layout_generators and cleared whenever that table changes, so every client computes the same.
local layout_name_cache = {}

function factorissimo.clear_layout_cache()
    layout_name_cache = {}
end

local function layout_name_of(name)
    local cached = layout_name_cache[name]
    if cached ~= nil then return cached end
    local generators = storage.layout_generators
    if not generators then return false end
    local result = false
    if generators[name] then
        result = name
    else
        local stripped = name:gsub("%-instantiated", "")
        if generators[stripped] then result = stripped end
    end
    layout_name_cache[name] = result
    return result
end
factorissimo.layout_name_of = layout_name_of

remote_api.add_layout = function(layout)
    storage.layout_generators = storage.layout_generators or {}
    storage.layout_generators[layout.name] = layout
    factorissimo.clear_layout_cache()
end

remote_api.has_layout = function(name)
    return layout_name_of(name) ~= false
end
_G.has_layout = remote_api.has_layout

remote_api.is_factorissimo_surface = function(surface)
    if not surface then return false end
    local surface_index
    local surface_type = type(surface)

    if surface_type == "number" then
        surface_index = surface
    elseif surface_type == "string" then
        local s = game.get_surface(surface)
        if not s then return false end
        surface_index = s.index
    else
        if not surface.valid then return false end
        surface_index = surface.index
    end

    return storage.surface_factories[surface_index] ~= nil
end

remote.add_interface("factorissimo", remote_api)
