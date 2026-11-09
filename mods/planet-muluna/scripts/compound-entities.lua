-- Blueprint support for compound entities.
--
-- A compound entity only stores its parent entity in a blueprint. Subentities are
-- spawned by the parent and therefore lose both their circuit wires and their
-- control behavior settings when a blueprint is stamped down. bplib raises
-- `bplib-extract` for the parent so those details can be written to the parent's
-- blueprint tags, and `bplib-positions` so the links can be rebuilt after the
-- blueprint is rotated or flipped.
--
-- The registry is built from the constants for the three compound entity types:
-- telescopes, heat assembling machines (including the vacuum heating tower), and
-- burner roboports.
local blueprint_tags = require("lib.blueprint-tags")
local TAG_KEY = "muluna_compound"
local PENDING_WIRE_LIFETIME = 60 * 60 * 10
local ORIENTATION_LIFETIME = 60 * 60 * 60

---@type table
local Public = {}
Muluna.compound_entities = Public

-- Scalar/tabular control behavior settings that make sense to copy between two
-- instances of the same entity. Derived or read-only fields such as `disabled`
-- are deliberately omitted.
local CONTROL_BEHAVIOR_FIELDS = {
    "enabled",
    "input_networks",
    "output_networks",
    "read_items_mode",
    "read_robot_stats",
    "available_logistic_output_signal",
    "total_logistic_output_signal",
    "available_construction_output_signal",
    "total_construction_output_signal",
    "roboport_count_output_signal",
    "circuit_enable_disable",
    "circuit_condition",
    "logistic_condition",
    "connect_to_logistic_network",
    "read_fuel",
    "read_temperature",
    "temperature_signal",
}

local compound_types = {}

local function register_compound_type(storage_key, parent_key, child_keys, constants)
    for _, machine in pairs(constants or {}) do
        local parent_name = machine[parent_key]
        if parent_name then
            compound_types[parent_name] = {
                storage_key = storage_key,
                parent_key = parent_key,
                child_keys = child_keys,
            }
        end
    end
end

register_compound_type("telescopes", "assembling-machine", { "constant-combinator" }, Muluna.constants.telescopes)
register_compound_type(
    "heat_assembling_machines",
    "assembling-machine",
    { "reactor" },
    Muluna.constants.heat_assembling_machines
)
register_compound_type("burner_roboports", "refueler", { "roboport" }, Muluna.constants.vacuum_roboports)

local function deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do
        result[key] = deepcopy(child)
    end
    return result
end

local function get_compound_data(config, parent)
    local entries = storage[config.storage_key]
    return entries and entries[parent.unit_number]
end

local function get_compound_data_by_unit_number(config, unit_number)
    local entries = storage[config.storage_key]
    return entries and entries[unit_number]
end

local function find_parent_by_unit_number(unit_number)
    for _, config in pairs(compound_types) do
        local data = get_compound_data_by_unit_number(config, unit_number)
        local parent = data and data[config.parent_key]
        if parent and parent.valid then
            return parent, config, data
        end
    end
end

local function get_children(config, data)
    local children = {}
    for index, key in ipairs(config.child_keys) do
        local entity = data[key]
        if entity and entity.valid then
            children[index] = { key = key, entity = entity }
        else
            children[index] = { key = key }
        end
    end
    return children
end

local function capture_control_behavior(entity)
    local behavior = entity.get_or_create_control_behavior()
    if not behavior or not behavior.valid then return nil end

    local settings = {}
    for _, field in ipairs(CONTROL_BEHAVIOR_FIELDS) do
        -- Accessing a setting that does not exist on this concrete behavior
        -- type raises instead of returning nil.
        local ok, value = pcall(function()
            return behavior[field]
        end)
        if ok and value ~= nil and type(value) ~= "function" and type(value) ~= "userdata" then
            settings[field] = deepcopy(value)
        end
    end
    if next(settings) then return settings end
end

local function apply_control_behavior(entity, settings)
    local behavior = entity.get_or_create_control_behavior()
    if not behavior or not behavior.valid then return end

    for field, value in pairs(settings) do
        -- Some settings are version- or entity-specific. A rejected write should
        -- never break the rest of the blueprint restoration.
        pcall(function()
            behavior[field] = deepcopy(value)
        end)
    end
end

---Find the index of `owner` among the compound's children.
local function find_child_index(children, owner)
    for index, child in ipairs(children) do
        if child.entity == owner then return index end
    end
end

---Serialize the circuit wires and control behavior of every subentity.
local function capture_compound_tags(parent, data, config)
    local children = get_children(config, data)
    local subentities = {}

    for index, child in ipairs(children) do
        local entity = child.entity
        if entity then
            local entry = { name = entity.name }

            local control = capture_control_behavior(entity)
            if control then entry.control = control end

            local connectors = {}
            for connector_id, connector in pairs(entity.get_wire_connectors(false)) do
                local links = {}
                for _, connection in pairs(connector.connections) do
                    local target = connection.target
                    if target and target.valid and target.owner and target.owner.valid then
                        local owner = target.owner
                        local link
                        if owner == parent then
                            link = { parent = true, id = target.wire_connector_id }
                        else
                            local sibling_index = find_child_index(children, owner)
                            if sibling_index then
                                link = { subentity = sibling_index, id = target.wire_connector_id }
                            else
                                -- Store the offset from the parent rather than an
                                -- absolute position so the blueprint can be moved.
                                -- A ghost target should resolve to the real entity
                                -- once it is built.
                                link = {
                                    name = owner.type == "entity-ghost" and owner.ghost_name or owner.name,
                                    x = owner.position.x - parent.position.x,
                                    y = owner.position.y - parent.position.y,
                                    id = target.wire_connector_id,
                                }
                            end
                        end
                        if link then table.insert(links, link) end
                    end
                end
                if #links > 0 then
                    table.insert(connectors, { id = connector_id, links = links })
                end
            end
            if #connectors > 0 then entry.connectors = connectors end

            subentities[index] = entry
        end
    end

    return {
        version = 1,
        direction = parent.valid and parent.direction or nil,
        mirroring = parent.valid and parent.mirroring or nil,
        subentities = subentities,
    }
end

Muluna.events.on_event("bplib-extract", function(event)
    for blueprint_index, entity in pairs(event.entities or {}) do
        if entity.valid then
            local config = compound_types[entity.name]
            if config then
                local data = get_compound_data(config, entity)
                if data then
                    blueprint_tags.add_tags(event.blueprint, blueprint_index, {
                        [TAG_KEY] = capture_compound_tags(entity, data, config),
                    })
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Blueprint placement orientation
--------------------------------------------------------------------------------
-- bplib computes the world position of every registered parent at `on_pre_build`
-- time. Storing the placement orientation by position lets the build handler
-- transform saved wire offsets for rotated and flipped blueprints, including
-- blueprints that are built as ghosts some time later.

local function position_key(surface_index, position)
    if type(position) ~= "table" then return nil end
    -- bplib returns positions as vector tables (`{x, y}`) in some code paths and
    -- as map positions (`{x = x, y = y}`) in others.
    local x = position.x ~= nil and position.x or position[1]
    local y = position.y ~= nil and position.y or position[2]
    if type(x) ~= "number" or type(y) ~= "number" then return nil end
    return string.format("%d:%.2f,%.2f", surface_index, x, y)
end

local function orientation_from_event(event)
    return {
        direction = event.orientation_info and event.orientation_info.direction or 0,
        flip_horizontal = event.orientation_info and event.orientation_info.flip_horizontal or false,
        flip_vertical = event.orientation_info and event.orientation_info.flip_vertical or false,
    }
end

---Transform a blueprint entity direction into the placed blueprint's space.
---Flips happen before rotation, matching bplib's position transform.
local function transform_blueprint_direction(direction, orientation)
    if orientation.flip_horizontal then
        if direction == defines.direction.east then
            direction = defines.direction.west
        elseif direction == defines.direction.west then
            direction = defines.direction.east
        end
    end
    if orientation.flip_vertical then
        if direction == defines.direction.north then
            direction = defines.direction.south
        elseif direction == defines.direction.south then
            direction = defines.direction.north
        end
    end
    return (direction + (orientation.direction or 0)) % 16
end

Muluna.events.on_event("bplib-positions", function(event)
    storage.compound_placement_orientations = storage.compound_placement_orientations or {}
    storage.compound_blueprint_directions = storage.compound_blueprint_directions or {}
    local orientations = storage.compound_placement_orientations
    local directions = storage.compound_blueprint_directions

    -- Blueprint placements can be cancelled or stamped as ghosts that are never
    -- built. Prune entries that can no longer correspond to this placement.
    for key, entry in pairs(orientations) do
        if game.tick - entry.tick > ORIENTATION_LIFETIME then
            orientations[key] = nil
        end
    end
    for key, entry in pairs(directions) do
        if game.tick - entry.tick > ORIENTATION_LIFETIME then
            directions[key] = nil
        end
    end

    local orientation = orientation_from_event(event)
    local blueprint_entities = event.blueprint and event.blueprint.get_blueprint_entities()
    for index, position in pairs(event.positions or {}) do
        local key = position_key(event.surface_index, position)
        if key then
            orientations[key] = {
                tick = event.tick,
                orientation = orientation,
            }
            local blueprint_entity = blueprint_entities and blueprint_entities[index]
            if blueprint_entity then
                directions[key] = {
                    tick = event.tick,
                    direction = blueprint_entity.direction or defines.direction.north,
                    mirroring = blueprint_entity.mirror or false,
                    orientation = orientation,
                }
            end
        end
    end
end)

---Take the source direction of a compound parent from a pending blueprint.
---bplib raises `bplib-positions` before entity ghosts are revived, so this lets
---the build handler restore the direction before a recipe change can clear it.
---@param entity LuaEntity
---@return table|nil
function Public.take_blueprint_direction(entity)
    local directions = storage.compound_blueprint_directions
    if not directions then return nil end

    local key = position_key(entity.surface_index, entity.position)
    local entry = key and directions[key]
    if entry then
        directions[key] = nil
        return entry
    end
end

---Restore a compound parent's direction and mirroring from a pending blueprint
---or from the compound's own blueprint tags. Returns nil for a value that has
---no saved source (a normal player placement); the caller must keep the
---entity's own orientation in that case.
---@param entity LuaEntity
---@param tags Tags|nil
---@return defines.direction|nil direction
---@return boolean|nil mirroring
function Public.restore_blueprint_direction(entity, tags)
    local saved
    if type(tags) == "table" then
        saved = Public.take_blueprint_direction(entity)
    end
    local compound = type(tags) == "table" and tags[TAG_KEY] or nil
    local direction = saved and saved.direction
    local mirroring = saved and saved.mirroring
    if type(compound) == "table" then
        if direction == nil then direction = compound.direction end
        if mirroring == nil then mirroring = compound.mirroring end
    end

    if type(direction) == "number" and saved and saved.orientation then
        direction = transform_blueprint_direction(direction, saved.orientation)
    end
    if type(direction) ~= "number" then direction = nil end
    if type(mirroring) ~= "boolean" then mirroring = nil end

    if direction and entity.direction ~= direction then
        entity.direction = direction
    end
    if mirroring ~= nil and entity.mirroring ~= mirroring then
        entity.mirroring = mirroring
    end
    return direction, mirroring
end

local function take_placement_orientation(parent)
    local orientations = storage.compound_placement_orientations
    if not orientations then return nil end

    local key = position_key(parent.surface_index, parent.position)
    local entry = orientations[key]
    if entry then
        orientations[key] = nil
        return entry.orientation
    end
end

---Transform an offset in blueprint space into the placed blueprint's space,
---mirroring `bplib.pos_blueprint_transform`: flips happen first, then the
---blueprint is rotated.
local function transform_offset(offset, orientation)
    local x, y = offset.x, offset.y
    if orientation.flip_horizontal then x = -x end
    if orientation.flip_vertical then y = -y end

    local rotation = math.floor((orientation.direction or 0) / 4) % 4
    if rotation == 1 then
        x, y = -y, x
    elseif rotation == 2 then
        x, y = -x, -y
    elseif rotation == 3 then
        x, y = y, -x
    end
    return x, y
end

---Fallback for when no `bplib-positions` data exists (for example a blueprint
---added to a save before this module was installed). The parent's direction
---delta still captures a plain rotation.
local function fallback_orientation(saved_direction, built_direction)
    local rotation = math.floor(((built_direction or saved_direction or 0) - (saved_direction or 0)) / 4) % 4
    return {
        direction = rotation * 4,
        flip_horizontal = false,
        flip_vertical = false,
    }
end

--------------------------------------------------------------------------------
-- Pending wire restoration
--------------------------------------------------------------------------------
-- The other endpoint of a wire may not exist yet while a blueprint is being
-- built (for example a construction robot may build it several ticks later).
-- Unresolved wires are retried on a timer and dropped when the parent is gone.

local RETRY_INTERVAL = 30

local function get_pending_wires()
    storage.compound_pending_wires = storage.compound_pending_wires or {}
    return storage.compound_pending_wires
end

-- The retry timer is only registered with the engine while a wire is waiting
-- for its other endpoint. An empty pending table is the normal state, so an
-- always-on timer spends an engine call every 30 ticks for nothing.
-- nil means "not synced with the engine yet"; on_init applies the real state.
local retry_enabled

local function set_wire_retries_enabled(enabled)
    if retry_enabled == enabled then return end
    retry_enabled = enabled
    Muluna.events.set_nth_tick_enabled(RETRY_INTERVAL, enabled)
end

local function sync_wire_retries()
    set_wire_retries_enabled(next(get_pending_wires()) ~= nil)
end

-- Loading re-runs the top-level registration, which turns the timer back on even
-- when the save was stored with it off. Re-apply the saved state so a joining
-- client and the server register the same nth-tick handlers. on_load must not
-- modify storage, so read the pending table without initializing it.
local function sync_wire_retries_after_load()
    local pending = storage.compound_pending_wires
    set_wire_retries_enabled(pending ~= nil and next(pending) ~= nil)
end

local function queue_wire(parent, child, source_connector_id, target)
    local pending = get_pending_wires()
    local id = (storage.compound_pending_wire_sequence or 0) + 1
    storage.compound_pending_wire_sequence = id
    pending[id] = {
        parent_name = parent.name,
        parent_unit_number = parent.unit_number,
        child_key = child.key,
        source_connector_id = source_connector_id,
        target = target,
        expires = game.tick + PENDING_WIRE_LIFETIME,
    }
    set_wire_retries_enabled(true)
end

local function find_target_entity(parent, target)
    if target.name then
        local entities = parent.surface.find_entities_filtered({
            name = target.name,
            position = target.position,
            radius = 1,
        })
        local closest
        local closest_distance
        for _, entity in pairs(entities) do
            local dx = entity.position.x - target.position.x
            local dy = entity.position.y - target.position.y
            local distance = dx * dx + dy * dy
            if not closest_distance or distance < closest_distance then
                closest = entity
                closest_distance = distance
            end
        end
        return closest
    end
end

local function resolve_target_entity(parent, data, config, target)
    if target.parent then
        return data[config.parent_key], target.id
    end
    if target.subentity then
        local child_key = config.child_keys[target.subentity]
        local child = child_key and data[child_key]
        if child and child.valid then return child, target.id end
        return nil
    end
    return find_target_entity(parent, target), target.id
end

---Get a wire connector without trusting a numeric id read from blueprint tags.
local function get_wire_connector(entity, connector_id)
    if type(connector_id) ~= "number" or connector_id < 0 or connector_id > 8 then
        return nil
    end
    return entity.get_wire_connector(connector_id, true)
end

local function retry_pending_wires()
    for id, wire in pairs(storage.compound_pending_wires) do
        local config = compound_types[wire.parent_name]
        local data = config and get_compound_data_by_unit_number(config, wire.parent_unit_number)
        local parent = config and data and data[config.parent_key]
        local child = data and data[wire.child_key]
        if not parent or not parent.valid or not child or not child.valid or game.tick > wire.expires then
            storage.compound_pending_wires[id] = nil
        else
            local source = get_wire_connector(child, wire.source_connector_id)
            local target_entity, target_connector_id = resolve_target_entity(parent, data, config, wire.target)
            local target = target_entity and target_entity.valid and get_wire_connector(target_entity, target_connector_id)
            if source and target then
                if source.is_connected_to(target) then
                    storage.compound_pending_wires[id] = nil
                elseif source.connect_to(target) then
                    storage.compound_pending_wires[id] = nil
                end
            end
        end
        -- Stop the timer when the last wire resolved or expired.
        if next(storage.compound_pending_wires) == nil then
            set_wire_retries_enabled(false)
        end
    end
end

local function restore_wires(parent, data, config, tags, orientation_override)
    if type(tags.subentities) ~= "table" then return end

    local children = get_children(config, data)
    local saved_direction = type(tags.direction) == "number" and tags.direction or parent.direction
    local orientation = orientation_override
        or take_placement_orientation(parent)
        or fallback_orientation(saved_direction, parent.direction)

    for index, entry in ipairs(tags.subentities) do
        local child = children[index]
        if child and child.entity and type(entry) == "table" then
            if type(entry.control) == "table" then
                apply_control_behavior(child.entity, entry.control)
            end

            if type(entry.connectors) == "table" then
                for _, connector in ipairs(entry.connectors) do
                    if type(connector) == "table" and type(connector.id) == "number" and type(connector.links) == "table" then
                        for _, link in ipairs(connector.links) do
                            if type(link) == "table" and type(link.id) == "number" then
                                local target = { id = link.id }
                                if link.parent then
                                    target.parent = true
                                elseif link.subentity then
                                    target.subentity = link.subentity
                                elseif type(link.name) == "string" and type(link.x) == "number" and type(link.y) == "number" then
                                    local x, y = transform_offset(link, orientation)
                                    target.name = link.name
                                    target.position = { x = parent.position.x + x, y = parent.position.y + y }
                                else
                                    target = nil
                                end
                                if target then
                                    queue_wire(parent, child, connector.id, target)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    retry_pending_wires()
end

local function apply_compound_tags(parent, data, config, tags, orientation)
    if type(tags) ~= "table" then return end
    local compound = tags[TAG_KEY]
    if type(compound) ~= "table" then return end
    restore_wires(parent, data, config, compound, orientation)
end

-- Stamping a blueprint over an existing compound entity does not raise a build
-- event. bplib reports the overlap and the blueprint's tags, so apply them to
-- the existing parent instead.
Muluna.events.on_event("bplib-overlaps", function(event)
    local orientation = orientation_from_event(event)
    for blueprint_index, entity in pairs(event.overlaps or {}) do
        if entity.valid then
            local config = compound_types[entity.name]
            if config then
                local data = get_compound_data(config, entity)
                if data then
                    local tags = blueprint_tags.get_tags(event.blueprint, blueprint_index)
                    apply_compound_tags(entity, data, config, tags, orientation)
                end
            end
        end
    end
end)

local build_filters = {}
for parent_name in pairs(compound_types) do
    table.insert(build_filters, { filter = "name", name = parent_name })
    table.insert(build_filters, { filter = "ghost_name", name = parent_name })
end

Muluna.events.on_event(Muluna.events.events.on_built(), function(event)
    local parent = event.entity
    if not parent or not parent.valid then return end

    local config = compound_types[parent.name]
    if not config then return end

    local data = get_compound_data(config, parent)
    if not data then return end

    apply_compound_tags(parent, data, config, event.tags)
end, build_filters)

Muluna.events.on_nth_tick(RETRY_INTERVAL, retry_pending_wires)

Muluna.events.on_event(Muluna.events.events.on_init(), function()
    storage.compound_pending_wires = storage.compound_pending_wires or {}
    storage.compound_placement_orientations = storage.compound_placement_orientations or {}
    storage.compound_blueprint_directions = storage.compound_blueprint_directions or {}
    sync_wire_retries()
end)

Muluna.events.on_event(Muluna.events.events.on_load(), sync_wire_retries_after_load)

if script.active_mods["funit"] then
    ---Queue a wire that can never resolve, so the retry timer has work for one
    ---interval. Used to test that the timer starts and stops with the queue.
    ---@param parent_unit_number uint32
    ---@return boolean
    Muluna.funit.queue_test_pending_wire = function(parent_unit_number)
        local parent = find_parent_by_unit_number(parent_unit_number)
        if not parent then return false end
        queue_wire(parent, { key = "funit-missing-child" }, 1, {
            name = "funit-missing-entity",
            position = parent.position,
        })
        return true
    end

    ---State of the idle-able wire retry timer, for the FUnit suite.
    ---@return {enabled: boolean, pending: integer}
    Muluna.funit.get_compound_retry_state = function()
        local pending = 0
        for _ in pairs(get_pending_wires()) do pending = pending + 1 end
        return { enabled = retry_enabled, pending = pending }
    end

    ---Re-apply the state that on_load applies from a fresh control stage.
    ---The headless FUnit scenario cannot save and reload a map.
    Muluna.funit.apply_compound_load_state = function()
        retry_enabled = nil
        sync_wire_retries_after_load()
    end

    ---@param unit_number uint32
    ---@return table|nil
    Muluna.funit.capture_compound_blueprint_tags = function(unit_number)
        local parent, config, data = find_parent_by_unit_number(unit_number)
        if not (parent and config and data) then return nil end
        return capture_compound_tags(parent, data, config)
    end

    ---@param offset table
    ---@param direction defines.direction
    ---@param flip_horizontal boolean
    ---@param flip_vertical boolean
    ---@return number, number
    Muluna.funit.transform_compound_offset = function(offset, direction, flip_horizontal, flip_vertical)
        return transform_offset(offset, {
            direction = direction,
            flip_horizontal = flip_horizontal,
            flip_vertical = flip_vertical,
        })
    end
end
