---@meta
------------------------------------------------------------------------
-- controller
------------------------------------------------------------------------
assert(script)

local util = require('util')

local Is = require('stdlib.utils.is')
local Math = require('stdlib.utils.math')
local Direction = require('stdlib.area.direction')
local Position = require('stdlib.area.position')

require('stdlib.utils.string')

local const = require('lib.constants')

---@class miniloader.Controller
---@field positions table<defines.direction, MapPosition[]>
local Controller = {}

-- position calculation
--
--   8  6  4  2   +-- entity --+
--                |            |
--   7  5  3  1   +------------+
--
--   x  0.375  0.125  -0.125 -0.375  y -0.25
--                                   y  0.25
--
-- dropoff is 0/0.25 and 0/-0.25


Controller.positions = {
    [defines.direction.north] = {},
    [defines.direction.east] = {},
    [defines.direction.south] = {},
    [defines.direction.west] = {},
}

local positions = 8 -- number of "outside" positions
local step = 0.25   -- increment per step
local shift = 0.25  -- shift for the position (either left/right or up/down, depending on orientation)

local count = 0     -- goes 0 .. 3 to choose the four sets of data
for direction in pairs(Controller.positions) do
    local v = bit32.band(count, 1) == 1
    local h = (bit32.band(count, 2) == 2) and 1 or -1
    local pos = -0.375 -- first start position

    for index = 1, positions, 2 do
        local offset = pos * h
        local x = v and shift or offset
        local y = v and offset or shift

        Controller.positions[direction][index] = Position { x = x, y = y }
        Controller.positions[direction][index + 1] = Position { x = v and -x or x, y = v and y or -y }
        pos = pos + step
    end

    count = count + 1
end

------------------------------------------------------------------------

---@type miniloader.Config
local default_config = {
    enabled = true,
    loader_type = const.loader_direction.input, -- freshly minted loader image is 'input'
    inserter_config = {
        filters = {},
    },
    highspeed = false,
}

local config_field_names = { 'enabled', 'loader_type', 'inserter_config', 'direction', 'highspeed' }

--- Creates a default configuration with some fields overridden by
--- an optional parent.
---
---@param parent_config miniloader.Config?
---@return miniloader.Config
local function create_config(parent_config)
    parent_config = parent_config or default_config

    local config = {}
    -- iterate over all field names given in the default_config
    for _, field_name in pairs(config_field_names) do
        if parent_config[field_name] ~= nil then
            config[field_name] = util.copy(parent_config[field_name])
        else
            config[field_name] = util.copy(default_config[field_name])
        end
    end

    return config
end


------------------------------------------------------------------------

--- Called when the mod is initialized
function Controller:init()
    ---@type miniloader.Storage
    storage.ml_data = storage.ml_data or {
        VERSION = const.CURRENT_VERSION,
        count = 0,
        by_main = {},
        open_guis = {},
    }
end

------------------------------------------------------------------------
-- attribute getters/setters
------------------------------------------------------------------------

--- Returns the registered total count
---@return integer count The total count of miniloaders
function Controller:entityCount()
    return storage.ml_data.count
end

--- Returns data for all miniloaders.
---@return table<integer, miniloader.Data> entities
function Controller:entities()
    return storage.ml_data.by_main
end

--- Returns data for a given miniloader
---@param entity_id integer main unit number (== entity id)
---@return miniloader.Data? entity
function Controller:getEntity(entity_id)
    return storage.ml_data.by_main[entity_id]
end

--- Sets or clears a miniloader entity.
---@param entity_id integer The unit_number of the primary
---@param ml_entity miniloader.Data?
function Controller:setEntity(entity_id, ml_entity)
    assert((ml_entity ~= nil and storage.ml_data.by_main[entity_id] == nil)
        or (ml_entity == nil and storage.ml_data.by_main[entity_id] ~= nil))

    if (ml_entity) then
        assert(Is.Valid(ml_entity.main) and ml_entity.main.unit_number == entity_id)
    end

    storage.ml_data.by_main[entity_id] = ml_entity
    storage.ml_data.count = storage.ml_data.count + ((ml_entity and 1) or -1)

    if storage.ml_data.count < 0 then
        storage.ml_data.count = table_size(storage.ml_data.by_main)
        Framework.logger:logf('Miniloader count got negative (bug), size is now: %d', storage.ml_data.count)
    end
end

------------------------------------------------------------------------
-- sub entity management
------------------------------------------------------------------------

---@param main LuaEntity
---@param config miniloader.Config
---@return LuaEntity? loader
local function create_loader(main, config)
    -- create the loader with the same orientation as the inserter. Then look in front of the
    -- loader and snap the direction for it.
    local loader = main.surface.create_entity {
        name = const.loader_name(main.name),
        position = main.position,
        direction = This.Snapping:compute_loader_direction(config),
        force = main.force,
        type = tostring(config.loader_type),
    }
    if not loader then return nil end

    loader.destructible = false
    loader.operable = true

    local main_wire_connectors = main.get_wire_connectors(true)
    local loader_wire_connectors = loader.get_wire_connectors(true)

    for wire_connector_id, wire_connector in pairs(loader_wire_connectors) do
        wire_connector.connect_to(main_wire_connectors[wire_connector_id], false, defines.wire_origin.script)
    end

    return loader
end

---@param main LuaEntity
---@param speed_config miniloader.SpeedConfig
---@param config miniloader.Config
---@return (LuaEntity[])? inserters
function Controller:createInserters(main, speed_config, config)
    local inserter_count = speed_config.inserter_pairs * 2
    assert(inserter_count <= 8)

    local inserters = { main }

    local main_wire_connectors = main.get_wire_connectors(true)

    assert(#inserters <= inserter_count)

    while #inserters < inserter_count do
        local inserter = main.surface.create_entity {
            name = const.inserter_name(main.name),
            position = main.position,
            direction = config.direction,
            force = main.force,
        }
        if not inserter then return nil end

        inserter.destructible = false
        inserter.operable = false

        local inserter_wire_connectors = inserter.get_wire_connectors(true)

        for wire_connector_id, wire_connector in pairs(inserter_wire_connectors) do
            wire_connector.connect_to(main_wire_connectors[wire_connector_id], false, defines.wire_origin.script)
        end

        table.insert(inserters, inserter)
    end

    return inserters
end

------------------------------------------------------------------------
-- rotate/move
------------------------------------------------------------------------

---@param ml_entity miniloader.Data
---@param reverse boolean
function Controller:rotate(ml_entity, reverse)
    if ml_entity.config.loader_type == (reverse and const.loader_direction.input or const.loader_direction.output) then
        ml_entity.config.direction = Direction.opposite(ml_entity.config.direction)
    end
    ml_entity.config.loader_type = This.Snapping:reverse_loader_type(ml_entity.config.loader_type)
    self:reconfigure(ml_entity)
end

---@param main LuaEntity
function Controller:move(main)
    if not const.supported_types[main.name] then return end

    local ml_entity = self:getEntity(main.unit_number)
    if not ml_entity then return end

    self:reconfigure(ml_entity)
end

------------------------------------------------------------------------
-- blueprinting
------------------------------------------------------------------------

--- in very rare cases, some entries in the filter array end up having string
--- keys. try to convert them to number keys, if there would be a conflict, drop
--- the key that comes second
---@param ml_entity miniloader.Data
function Controller:sanitizeConfiguration(ml_entity)
    local filters = {}
    for key, value in pairs(ml_entity.config.inserter_config.filters) do
        local new_key = tonumber(key)
        if new_key then
            filters[new_key] = value
        end
    end
    if table_size(ml_entity.config.inserter_config.filters) ~= table_size(filters) then
        ml_entity.config.inserter_config.filters = filters
    end
end

--- Serializes the configuration suitable for blueprinting and tombstone management.
---
---@param entity LuaEntity
---@return table<string, any>?
function Controller:serializeConfiguration(entity)
    local ml_entity = self:getEntity(entity.unit_number)
    if not ml_entity then return end

    self:sanitizeConfiguration(ml_entity)

    return {
        [const.config_tag_name] = ml_entity.config,
        [const.no_snapping_tag_name] = 'true',
    }
end

--- Add tag to entities to not snap miniloaders when built from blueprint.
---
---@param entity LuaEntity
---@return table<string, any>?
function Controller:addSnappingTag(entity)
    return {
        [const.no_snapping_tag_name] = 'true',
    }
end

------------------------------------------------------------------------
-- create/destroy
------------------------------------------------------------------------

---@param main LuaEntity
---@param config miniloader.Config?
---@return miniloader.Data?
function Controller:setup(main, config)
    local entity_id = main.unit_number --[[@as integer]]

    assert(self:getEntity(entity_id) == nil)

    -- if tags were passed in and they contain a config, use that.
    config = create_config(config)
    config.status = main.status
    config.direction = config.direction or This.Snapping:direction_from_inserter(main.direction, config.loader_type)

    local inserter_data = assert(prototypes.mod_data[const.name].data[main.name])
    config.highspeed = inserter_data.speed_config.items_per_second > 240 -- 240 is max speed for one lane
    config.nerf_mode = inserter_data.nerf_mode

    local loader = create_loader(main, config)
    local inserters = self:createInserters(main, inserter_data.speed_config, config)

    if not (loader and inserters) then
        main.destroy()
        return nil
    end

    ---@type miniloader.Data
    local ml_entity = {
        main = main,
        loader = loader,
        inserters = inserters,
        config = util.copy(config),
    }

    self:setEntity(entity_id, ml_entity)

    return ml_entity
end

--- Creates a new entity from the main entity, registers with the mod
--- and configures it.
---@param main LuaEntity
---@param config miniloader.Config?
---@param no_snapping boolean? If true, don't snap to neighbors
---@return miniloader.Data?
function Controller:create(main, config, no_snapping)
    if not Is.Valid(main) then return nil end

    local ml_entity = self:setup(main, config)
    if not ml_entity then return nil end

    if not no_snapping then
        This.Snapping:snapToNeighbor(ml_entity)
        self:readConfigFromEntity(main, ml_entity)
    end

    self:reconfigure(ml_entity)

    return ml_entity
end

--- Destroys a Miniloader and all its sub-entities
---@param entity_id integer? main unit number (== entity id)
---@return boolean True if entity was destroyed
function Controller:destroy(entity_id)
    if not (entity_id and Is.Number(entity_id)) then return false end
    assert(entity_id)

    local ml_entity = self:getEntity(entity_id)
    if not ml_entity then return false end

    self:setEntity(entity_id, nil)

    ml_entity.main = nil
    ml_entity.inserters[1] = nil -- do not add to the loop below, game needs to manage the main inserter

    if Is.Valid(ml_entity.loader) then ml_entity.loader.destroy() end
    ml_entity.loader = nil

    if ml_entity.inserters then
        for i = 2, #ml_entity.inserters do
            if Is.Valid(ml_entity.inserters[i]) then ml_entity.inserters[i].destroy() end
            ml_entity.inserters[i] = nil
        end
    end

    return true
end

------------------------------------------------------------------------
-- sync control behavior
------------------------------------------------------------------------

-- GUI updates the loader, loader config is synced to the inserters
-- entity creation / resurrection uses the primary inserter. config is synced from the inserter to the loader
-- all meet at ml_entity.config

local control_attributes = {
    'circuit_set_filters',
    'circuit_enable_disable',
    'circuit_condition',
    'connect_to_logistic_network',
    'logistic_condition',
}

local EMPTY_LOADER_CONFIG = {
    circuit_set_filters = false,
    circuit_enable_disable = false,
    circuit_condition = { constant = 0, comparator = '<', fulfilled = false },
    connect_to_logistic_network = false,
    logistic_condition = { constant = 0, comparator = '<', fulfilled = false },
    loader_filter_mode = 'none',
    filters = {},
    read_transfers = false,
}

---@param entity LuaEntity Loader or Inserter
---@param ml_entity miniloader.Data
function Controller:readConfigFromEntity(entity, ml_entity)
    local control = entity.get_or_create_control_behavior() --[[@as LuaGenericOnOffControlBehavior ]]
    assert(control)

    if not control.valid then return end

    local inserter_config = ml_entity.config.inserter_config

    -- copy control attributes
    for _, attribute in pairs(control_attributes) do
        if ml_entity.config.nerf_mode then
            inserter_config[attribute] = EMPTY_LOADER_CONFIG[attribute]
        else
            inserter_config[attribute] = control[attribute]
        end
    end

    if entity.type == 'inserter' then
        if entity.filter_slot_count > 0 and not ml_entity.config.nerf_mode then
            inserter_config.loader_filter_mode = entity.use_filters and entity.inserter_filter_mode or 'none'

            local inserter_control = control --[[@as LuaInserterControlBehavior]]
            inserter_config.read_transfers = inserter_control.circuit_read_hand_contents

            for i = 1, entity.filter_slot_count, 1 do
                inserter_config.filters[i] = entity.get_filter(i)
            end
        else
            inserter_config.loader_filter_mode = 'none'
        end
    else
        inserter_config.loader_filter_mode = entity.loader_filter_mode
        local loader_control = control --[[@as LuaLoaderControlBehavior ]]
        inserter_config.read_transfers = loader_control.circuit_read_transfers

        for i = 1, entity.filter_slot_count, 1 do
            inserter_config.filters[i] = entity.get_filter(i)
        end
    end
end

---@param inserter_config table<string, any?>
---@param entity LuaEntity Loader or Inserter
function Controller:writeConfigToEntity(inserter_config, entity)
    if not (entity and entity.valid) then return end

    local control = entity.get_or_create_control_behavior() --[[@as LuaGenericOnOffControlBehavior ]]
    assert(control)

    if not control.valid then return end

    -- copy control attributes
    for _, attribute in pairs(control_attributes) do
        control[attribute] = inserter_config[attribute]
    end

    if entity.type == 'inserter' then
        if entity.filter_slot_count > 0 then
            for i = 1, entity.filter_slot_count, 1 do
                entity.set_filter(i, inserter_config.filters[i])
            end

            if inserter_config.loader_filter_mode and inserter_config.loader_filter_mode ~= 'none' then
                entity.use_filters = true
                entity.inserter_filter_mode = inserter_config.loader_filter_mode
            else
                entity.use_filters = false
            end
        end

        entity.inserter_stack_size_override = entity.prototype.bulk and 4 or 0 -- 0 resets to inserter default

        local inserter_control = control --[[@as LuaInserterControlBehavior]]
        inserter_control.circuit_set_stack_size = false

        if inserter_config.read_transfers then
            inserter_control.circuit_read_hand_contents = true
            inserter_control.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse
        end
    else
        if entity.filter_slot_count > 0 then
            for i = 1, entity.filter_slot_count, 1 do
                entity.set_filter(i, inserter_config.filters[i])
            end

            entity.loader_filter_mode = inserter_config.loader_filter_mode or 'none'
        end

        local loader_control = control --[[@as LuaLoaderControlBehavior ]]
        loader_control.circuit_read_transfers = inserter_config.read_transfers or false
    end
end

---@param ml_entity miniloader.Data
---@param skip_main boolean?
function Controller:resyncInserters(ml_entity, skip_main)
    for _, inserter in pairs(ml_entity.inserters) do
        if not (skip_main and inserter.unit_number == ml_entity.main.unit_number) then
            self:writeConfigToEntity(ml_entity.config.inserter_config, inserter)
        end
    end
end

------------------------------------------------------------------------
-- manage internal state
------------------------------------------------------------------------

---@param ml_entity miniloader.Data
---@param position MapPosition
---@param color Color
---@param index number
local function draw_position(ml_entity, position, color, index)
    if ml_entity.inserters[index] and not ml_entity.inserters[index].active then
        color = { r = 0.3, g = 0.3, b = 0.3 }
    end

    local area = Position(position):expand_to_area(0.1)
    rendering.draw_rectangle {
        color = color,
        surface = ml_entity.main.surface,
        left_top = area.left_top,
        right_bottom = area.right_bottom,
        time_to_live = const.debug_lifetime,
    }
    rendering.draw_text {
        text = tostring(index),
        surface = ml_entity.main.surface,
        target = position,
        color = color,
        scale = 0.5,
        alignment = 'center',
        vertical_alignment = 'middle',
        time_to_live = const.debug_lifetime,
    }
end

---@param ml_entity miniloader.Data
function Controller:reconfigure(ml_entity, cfg)
    if cfg then
        local new_config = util.copy(cfg)
        -- do not overwrite direction and loader type. But they need to be
        -- in the config to allow blueprinting / copy&paste of entities
        new_config.direction = ml_entity.config.direction
        new_config.loader_type = ml_entity.config.loader_type
        ml_entity.config = new_config
    end

    local config = ml_entity.config
    local direction = config.direction
    assert(direction)

    assert(ml_entity.loader.valid)

    -- reorient loader
    ml_entity.loader.loader_type = tostring(config.loader_type)
    ml_entity.loader.direction = This.Snapping:compute_loader_direction(config)
    if Position(ml_entity.main.position) ~= Position(ml_entity.loader.position) then
        -- miniloader was moved
        ml_entity.loader.destroy()
        ml_entity.loader = create_loader(ml_entity.main, ml_entity.config)
    end

    -- connect loader to belt if needed
    ml_entity.loader.update_connections()

    -- connect inserters and loader
    local back_position = Position(ml_entity.main.position):translate(direction, -1)
    local front_position = Position(ml_entity.main.position) -- position is limited to 240 items/sec
    local hs_front_position = Position(ml_entity.main.position):translate(direction, 0.375)

    for inserter_index, inserter in pairs(ml_entity.inserters) do
        local index = config.highspeed and (9 - inserter_index) or inserter_index

        -- reorient inserter
        inserter.direction = This.Snapping:compute_inserter_direction(ml_entity.config)
        inserter.teleport(ml_entity.main.position)

        -- normal speed: even inserters right
        -- high speed: even inserters left
        local right_lane = (inserter_index % 2) == (config.highspeed and 0 or 1)

        inserter.pickup_from_left_lane = not right_lane
        inserter.pickup_from_right_lane = right_lane

        -- either pickup or drop position

        local eight_mod = Math.one_mod(index, 8)
        local outside_position = back_position + self.positions[direction][eight_mod]
        local inside_position = front_position + self.positions[direction][eight_mod]
        local hs_inside_position = hs_front_position + self.positions[direction][eight_mod]

        local pickup_position = config.highspeed and hs_inside_position or inside_position
        local drop_position = outside_position

        -- loader gets items, inserter drop them off
        if config.loader_type == const.loader_direction.input then
            inserter.pickup_target = ml_entity.loader
            inserter.drop_target = nil
        else
            -- inserter gets items, loader sends them down the belt
            pickup_position = outside_position
            drop_position = inside_position

            inserter.pickup_target = nil
            inserter.drop_target = ml_entity.loader
        end

        inserter.pickup_position = pickup_position
        inserter.drop_position = drop_position

        if Framework.settings:startup_setting('debug_mode') then
            draw_position(ml_entity, inserter.drop_position, { r = 1, g = 0, b = 0 }, inserter_index)
            draw_position(ml_entity, inserter.pickup_position, { r = 0, g = 1, b = 0 }, inserter_index)
            draw_position(ml_entity, inserter.position, { r = 0, g = 0, b = 1 }, inserter_index)
        end
    end

    self:resyncInserters(ml_entity)

    -- clear out loader configuration
    self:writeConfigToEntity(EMPTY_LOADER_CONFIG, ml_entity.loader)
end

------------------------------------------------------------------------

return Controller
