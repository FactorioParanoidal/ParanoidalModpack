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
---@field spoiling boolean
local Controller = {
    spoiling = script.feature_flags.spoiling,
}

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

--- Keys are the keys in the inserter_config and control behavior
--- Values in this table are keys in the blueprint entity
---@type table<string, string>
local CONTROL_ATTRIBUTES = {
    circuit_set_filters = 'circuit_set_filters',
    circuit_enable_disable = 'circuit_enabled',
    circuit_condition = 'circuit_condition',
    connect_to_logistic_network = 'connect_to_logistic_network',
    logistic_condition = 'logistic_condition',
}

---@type table<string, any>
local DEFAULT_LOADER_CONFIG = {
    circuit_set_filters = false,
    circuit_enable_disable = false,
    circuit_condition = { constant = 0, comparator = '<', fulfilled = false },
    connect_to_logistic_network = false,
    logistic_condition = { constant = 0, comparator = '<', fulfilled = false },
    loader_filter_mode = 'none',
    filters = {},
    read_transfers = false,
}

---@type miniloader.Config
local DEFAULT_CONFIG = {
    enabled = true,
    loader_type = const.loader_direction.input, -- freshly minted loader image is 'input'
    inserter_config = {},
    highspeed = false,
}

local CONFIG_ATTRIBUTES = { 'enabled', 'loader_type', 'direction', 'highspeed' }

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

--- Creates a default configuration with some fields overridden by
--- an optional parent.
---
---@param parent_config miniloader.Config?
---@param inserter_data miniloader.ModData
---@return miniloader.Config
local function create_config(parent_config, inserter_data)
    local config = util.copy(DEFAULT_CONFIG)
    config.inserter_config = util.copy(DEFAULT_LOADER_CONFIG)

    if not parent_config then return config end

    -- iterate over all field names given in the default_config
    for _, field_name in pairs(CONFIG_ATTRIBUTES) do
        if parent_config[field_name] ~= nil then
            config[field_name] = util.copy(parent_config[field_name])
        else
            config[field_name] = util.copy(DEFAULT_CONFIG[field_name])
        end
    end

    local control = parent_config.inserter_config or {}
    for control_key in pairs(CONTROL_ATTRIBUTES) do
        if inserter_data.nerf_mode then
            config.inserter_config[control_key] = DEFAULT_LOADER_CONFIG[control_key]
        else
            config.inserter_config[control_key] = control[control_key] or DEFAULT_LOADER_CONFIG[control_key]
        end
    end

    if not inserter_data.nerf_mode then
        config.inserter_config.loader_filter_mode = control.loader_filter_mode or 'none'
        config.inserter_config.read_transfers = control.read_transfers or false

        if control.filters then
            for idx, filter in pairs(control.filters) do
                config.inserter_config.filters[idx] = filter
            end
        end

        config.inserter_config.inserter_spoil_priority = Controller.spoiling and (control.inserter_spoil_priority or 'none') or nil
    else
        config.inserter_config.loader_filter_mode = 'none'
        config.inserter_config.inserter_spoil_priority = Controller.spoiling and 'none' or nil
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
---@return LuaEntity[] inserters
---@return boolean success
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

        if not inserter then return inserters, false end

        inserter.destructible = false
        inserter.operable = false

        local inserter_wire_connectors = inserter.get_wire_connectors(true)

        for wire_connector_id, wire_connector in pairs(inserter_wire_connectors) do
            wire_connector.connect_to(main_wire_connectors[wire_connector_id], false, defines.wire_origin.script)
        end

        table.insert(inserters, inserter)
    end

    return inserters, true
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

--- Blueprints are deserialized from json and the set of keys may be deserialized
--- as strings. Turn them back into numbers.
---
---@param ml_config miniloader.Config
function Controller:sanitizeConfiguration(ml_config)
    if not ml_config then return end

    local filters = {}
    for key, value in pairs(ml_config.inserter_config.filters) do
        local new_key = tonumber(key)
        if new_key then
            filters[new_key] = value
        end
    end
    ml_config.inserter_config.filters = filters
end

--- Serializes the configuration suitable for blueprinting and tombstone management.
---
---@param entity LuaEntity
---@return Tags?
function Controller:serializeConfiguration(entity)
    local ml_entity = self:getEntity(entity.unit_number)
    if not ml_entity then return end

    return {
        [const.config_tag_name] = ml_entity.config,
        [const.no_snapping_tag_name] = 'true',
    }
end

---@param tags Tags?
---@return miniloader.Config? ml_config
---@return boolean no_snapping
function Controller:deserializeConfiguration(tags)
    if not (tags and tags[const.config_tag_name]) then return nil, false end

    ---@type miniloader.Config
    local ml_config = tags[const.config_tag_name]
    self:sanitizeConfiguration(ml_config)

    return ml_config, tostring(tags[const.no_snapping_tag_name]) == 'true'
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

---@param ml_entity miniloader.Data
---@return boolean True if entity was destroyed
local function entity_destroy(ml_entity)
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

---@param main LuaEntity
---@param config miniloader.Config?
---@return miniloader.Data?
function Controller:setup(main, config)
    local entity_id = main.unit_number

    ---@type miniloader.ModData
    local inserter_data = assert(prototypes.mod_data[const.name].data[main.name])

    -- if tags were passed in and they contain a config, use that.
    config = create_config(config, inserter_data)
    config.status = main.status
    config.direction = config.direction or This.Snapping:direction_from_inserter(main.direction, config.loader_type)

    config.highspeed = inserter_data.speed_config.items_per_second > 240 -- 240 is max speed for one lane
    config.nerf_mode = inserter_data.nerf_mode

    local loader = create_loader(main, config)
    local inserters, success = self:createInserters(main, inserter_data.speed_config, config)

    ---@type miniloader.Data
    local ml_entity = {
        main = main,
        loader = loader,
        inserters = inserters,
        config = util.copy(config),
    }

    if not (loader and success) then
        entity_destroy(ml_entity)
        main.destroy()
        return nil
    end

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

    if config then
        -- support blueprint parameters. In this case, there is a config but the
        -- inserter also has filters set. Reset the filters from the config and read
        -- the actual filter values out of the inserter
        if not ml_entity.config.nerf_mode then
            local bp_filters = {}
            for i = 1, ml_entity.main.filter_slot_count do
                local value = ml_entity.main.get_filter(i)
                if value then bp_filters[i] = value end
            end
            if table_size(bp_filters) > 0 then
                ml_entity.config.inserter_config.filters = bp_filters
            end
        end
    else
        ml_entity.config.inserter_config = self:readConfigFromEntity(main, ml_entity)
    end

    if not no_snapping then
        This.Snapping:snapToNeighbor(ml_entity)
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

    return entity_destroy(ml_entity)
end

------------------------------------------------------------------------
-- sync control behavior
------------------------------------------------------------------------

-- GUI updates the loader, loader config is synced to the inserters
-- entity creation / resurrection uses the primary inserter. config is synced from the inserter to the loader
-- all meet at ml_entity.config

---@param entity LuaEntity Loader or Inserter
---@param ml_entity miniloader.Data
---@return table<string, any> inserter_config
function Controller:readConfigFromEntity(entity, ml_entity)
    assert(entity)

    local control = assert(entity.get_or_create_control_behavior()) --[[@as LuaGenericOnOffControlBehavior ]]
    assert(control.valid)

    local inserter_config = {
        filters = {}
    }

    -- copy control attributes
    for control_key in pairs(CONTROL_ATTRIBUTES) do
        if ml_entity.config.nerf_mode then
            inserter_config[control_key] = DEFAULT_LOADER_CONFIG[control_key]
        else
            inserter_config[control_key] = control[control_key]
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

            inserter_config.inserter_spoil_priority = self.spoiling and (entity.inserter_spoil_priority or 'none') or nil
        else
            inserter_config.loader_filter_mode = 'none'
            inserter_config.inserter_spoil_priority = self.spoiling and 'none' or nil
        end
    else
        inserter_config.loader_filter_mode = entity.loader_filter_mode
        local loader_control = control --[[@as LuaLoaderControlBehavior ]]
        inserter_config.read_transfers = loader_control.circuit_read_transfers

        for i = 1, entity.filter_slot_count, 1 do
            inserter_config.filters[i] = entity.get_filter(i)
        end

        -- Loader has no concept of spoil_priority, retain existing values
        inserter_config.inserter_spoil_priority = self.spoiling and (ml_entity.config.inserter_config.inserter_spoil_priority or 'none') or nil
    end

    return inserter_config
end

--- see https://forums.factorio.com/viewtopic.php?t=133512
local fix_spoil_prio = {
    ['fresh-first'] = 'fresh_first',
    ['spoiled-first'] = 'spoiled_first',
    fresh_first = 'fresh_first',
    spoiled_first = 'spoiled_first',
    none = 'none',
}

---@param bp_entity BlueprintEntity.inserter
---@param ml_entity miniloader.Data
---@return table<string, any> inserter_config
function Controller:readConfigFromBlueprintEntity(bp_entity, ml_entity)
    ---@type InserterBlueprintControlBehavior
    local control_behavior = bp_entity.control_behavior or {}

    local inserter_config = {
        filters = {}
    }

    -- copy blueprint attributes
    for control_key, bp_key in pairs(CONTROL_ATTRIBUTES) do
        if ml_entity.config.nerf_mode then
            inserter_config[control_key] = DEFAULT_LOADER_CONFIG[control_key]
        else
            inserter_config[control_key] = (control_behavior[bp_key] ~= nil) and control_behavior[bp_key] or DEFAULT_LOADER_CONFIG[control_key]
        end
    end

    if not ml_entity.config.nerf_mode then
        inserter_config.inserter_filter_mode = bp_entity.use_filters and (bp_entity.filter_mode or 'whitelist') or nil
        inserter_config.loader_filter_mode = inserter_config.inserter_filter_mode or 'none'

        inserter_config.read_transfers = control_behavior.circuit_read_hand_contents or false

        if bp_entity.filters then
            for _, filter in pairs(bp_entity.filters) do
                inserter_config.filters[filter.index] = {
                    name = filter.name,
                    quality = filter.quality,
                    comparator = filter.comparator,
                }
            end
        end

        inserter_config.inserter_spoil_priority = self.spoiling and fix_spoil_prio[bp_entity.spoil_priority or 'none'] or nil
    else
        inserter_config.loader_filter_mode = 'none'
        inserter_config.inserter_spoil_priority = self.spoiling and 'none' or nil
    end

    return inserter_config
end

---@param inserter_config table<string, any?>
---@param entity LuaEntity Loader or Inserter
function Controller:writeConfigToEntity(inserter_config, entity)
    if not (entity and entity.valid) then return end

    local control = entity.get_or_create_control_behavior() --[[@as LuaGenericOnOffControlBehavior ]]
    assert(control)

    if not control.valid then return end

    -- copy control attributes
    for control_key in pairs(CONTROL_ATTRIBUTES) do
        control[control_key] = inserter_config[control_key]
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

        if self.spoiling then
            -- only set spoil priority if there are some filter_slots (not nerfed)
            entity.inserter_spoil_priority = (entity.filter_slot_count > 0) and inserter_config.inserter_spoil_priority or 'none'
        end

        local inserter_control = control --[[@as LuaInserterControlBehavior]]
        inserter_control.circuit_set_stack_size = false

        if inserter_config.read_transfers then
            inserter_control.circuit_read_hand_contents = true
            inserter_control.circuit_hand_read_mode = defines.control_behavior.inserter.hand_read_mode.pulse
        end
    else
        if entity.filter_slot_count > 0 then
            entity.loader_filter_mode = inserter_config.loader_filter_mode or 'none'

            for i = 1, entity.filter_slot_count, 1 do
                entity.set_filter(i, inserter_config.filters[i])
            end
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
---@return boolean has_open_gui
local function has_open_gui(ml_entity)
    local guis = Framework.gui_manager:findGuisByEntityId(ml_entity.main.unit_number)

    for _, gui in pairs(guis) do
        if gui.entity_id == ml_entity.main.unit_number then return true end
    end

    return false
end

---@param ml_entity miniloader.Data
---@param cfg miniloader.Config?
function Controller:reconfigure(ml_entity, cfg)
    if cfg and not ml_entity.config.nerf_mode then
        -- do not overwrite any of the settings in the config object itself
        -- only copy the inserter config.
        ml_entity.config.inserter_config = util.copy(cfg.inserter_config)
        ml_entity.config.enabled = cfg.enabled
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

    -- if a gui is open, copy the config also to the loader which is shown on the GUI right now
    if has_open_gui(ml_entity) then
        self:writeConfigToEntity(ml_entity.config.inserter_config, ml_entity.loader)
    else
        self:writeConfigToEntity(DEFAULT_LOADER_CONFIG, ml_entity.loader)
    end
end

------------------------------------------------------------------------

return Controller
