-- Automatic-Cursed-FMD 9.0.0. One native resource filter; never replace a drill,
-- consume/flush fluids, change disabled_by_script, or script the mining itself.
local M = {version = "9.0.0"}
local PERIOD = 120 -- distribute registered drills over two seconds
local eligible, resources, choices = {}, {}, {}
local eligible_names = {}

local function prepare()
    eligible, resources, choices = {}, {}, {}
    local config = prototypes.mod_data["automatic-cursed-fmd"]
    if not config then return end
    for name in pairs(config.data.drills) do
        local proto = prototypes.entity[name]
        if proto and proto.filter_count > 0 then
            local energy = proto.fluid_energy_source_prototype
            local fuel_index = energy and energy.fluid_box.index
            local input
            for _, box in pairs(proto.fluidbox_prototypes) do
                if box.index ~= fuel_index then
                    if input then input = nil; break end
                    input = box.index
                end
            end
            -- The data stage admits only one process box (input), plus optional fuel.
            if input then eligible[name] = input end
        end
    end
    for name, proto in pairs(prototypes.get_entity_filtered({{filter = "type", type = "resource"}})) do
        local mine = proto.mineable_properties
        local solid = mine.products and #mine.products > 0
        for _, product in pairs(mine.products or {}) do
            if product.type ~= "item" then solid = false end
        end
        if solid then
            resources[name] = {category = proto.resource_category, fluid = mine.required_fluid}
        end
    end
    for name in pairs(eligible) do
        local list, wet = {}, {}
        for resource, info in pairs(resources) do
            if prototypes.entity[name].resource_categories[info.category] then
                list[#list + 1] = resource
                if info.fluid then wet[#wet + 1] = resource end
            end
        end
        table.sort(list)
        table.sort(wet)
        -- A real wet resource is also the safe waiting filter: unlike an empty
        -- filter list it cannot accidentally enable unrestricted dry mining.
        if wet[1] then choices[name] = {all = list, wet = wet} else eligible[name] = nil end
    end
    eligible_names = {}
    for name in pairs(eligible) do eligible_names[#eligible_names + 1] = name end
    table.sort(eligible_names)
end

local function state()
    return storage.automatic_cursed_fmd
end

local function contains(box, position)
    return position.x >= box.left_top.x and position.x <= box.right_bottom.x
        and position.y >= box.left_top.y and position.y <= box.right_bottom.y
end

local function fluid_in(entity, index)
    -- Dry-only targets can leave the process input completely unallocated.
    -- Prototype indices are not live storages.
    if index > entity.fluids_count then return nil end
    local fluid = entity.get_fluid(index)
    if not fluid and entity.has_fluid_segment(index) then fluid = entity.get_fluid_segment_fluid(index) end
    return fluid and fluid.amount > 0 and fluid.name or nil
end

local function same_position(a, b)
    return math.abs(a.x - b.x) < 0.01 and math.abs(a.y - b.y) < 0.01
end

local function supplied_fluid(entity, input)
    if input > entity.fluids_count then return nil end
    local inside = fluid_in(entity, input)
    if inside then return inside end
    local found = {}
    for _, connection in pairs(entity.get_fluid_box_pipe_connections(input)) do
        if connection.flow_direction ~= "output" then
            if connection.target then
                local fluid = fluid_in(connection.target, connection.target_fluidbox_index)
                if fluid then found[fluid] = true end
            else
                -- A previous ore can filter the empty input against the incoming
                -- liquid, so the engine connection may not exist yet. Inspect only
                -- geometrically matching, reciprocal pipe ports, never a nearby tank
                -- or a drill's unrelated fuel box.
                for _, neighbour in pairs(entity.surface.find_entities_filtered({position = connection.target_position})) do
                    if neighbour ~= entity and neighbour.valid then
                        for index = 1, neighbour.fluids_count do
                            for _, port in pairs(neighbour.get_fluid_box_pipe_connections(index)) do
                                if port.flow_direction ~= "input" and same_position(port.position, connection.target_position)
                                    and same_position(port.target_position, connection.position) then
                                    local fluid = fluid_in(neighbour, index)
                                    if fluid then found[fluid] = true end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    local fluid
    for name in pairs(found) do
        if fluid then return nil end -- conflicting supplies: do not guess or flush
        fluid = name
    end
    return fluid
end

local function usable(record, resource, area)
    local witness = record.witness
    return resource == record.resource and witness and witness.valid and witness.amount > 0
        and witness.name == resource and witness.surface == record.entity.surface
        and contains(area, witness.position)
end

local function choose(record)
    local entity = record.entity
    local observed = supplied_fluid(entity, record.input)
    if observed then record.fluid = observed end -- an empty pipe is not a fluid change
    local area = entity.mining_area -- includes direction, offset and quality
    local old = resources[record.resource]
    if old and ((record.fluid and old.fluid == record.fluid) or (not record.fluid and not old.fluid))
        and usable(record, record.resource, area) then return record.resource end

    local list = choices[entity.name]
    local allowed = {}
    for _, name in ipairs(list.all) do
        local fluid = resources[name].fluid
        if (record.fluid and fluid == record.fluid) or (not record.fluid and not fluid) then
            allowed[#allowed + 1] = name
        end
    end
    -- Retain one ore type until its last cell is exhausted. A cached witness avoids
    -- searching the full mining area every cycle. The sort is deterministic in MP.
    for _, name in ipairs(allowed) do
        local found = entity.surface.find_entities_filtered({area = area, type = "resource", name = name, limit = 1})[1]
        if found then record.resource, record.witness = name, found; return name end
    end
    record.witness = nil
    -- No fluid yet: wait on a wet ore rather than admitting every resource. A real
    -- supply, including one initially rejected by this filter, is detected above.
    local waiting = list.wet[1]
    for _, name in ipairs(list.wet) do
        if resources[name].fluid == record.fluid then waiting = name; break end
    end
    record.resource = waiting
    return waiting
end

local function filter_name(entity, index)
    local filter = entity.get_filter(index)
    return type(filter) == "string" and filter or filter and filter.name or nil
end

-- Manual override: any filter state other than the one this script applied (another
-- ore, blacklist mode, extra slots, a pasted or blueprinted filter) is the player's
-- and is left untouched. Clearing every filter slot returns the drill to automatic.
local function manual(record)
    local entity = record.entity
    local first = filter_name(entity, 1)
    for index = 2, entity.filter_slot_count do
        if entity.get_filter(index) then return true end
    end
    if not first then return false end
    -- record.resource is always the filter last applied here (choose returns it).
    return first ~= record.resource or entity.mining_drill_filter_mode ~= "whitelist"
end

local function update(record)
    local entity = record.entity
    if manual(record) then return end
    local wanted = choose(record)
    if entity.mining_drill_filter_mode ~= "whitelist" then entity.mining_drill_filter_mode = "whitelist" end
    if filter_name(entity, 1) ~= wanted then entity.set_filter(1, wanted) end
end

local function add(entity)
    if not (entity and entity.valid and entity.type == "mining-drill" and eligible[entity.name]) then return end
    local s = state()
    if not s then return end
    local id = entity.unit_number
    local record = s.records[id]
    if not record then
        record = {entity = entity, input = eligible[entity.name]}
        s.records[id] = record
        local slot = id % PERIOD
        s.buckets[slot] = s.buckets[slot] or {}
        s.buckets[slot][id] = true
    end
    local area, p = entity.mining_area, entity.position
    s.max_reach = math.max(s.max_reach or 0, math.abs(area.left_top.x - p.x), math.abs(area.left_top.y - p.y),
        math.abs(area.right_bottom.x - p.x), math.abs(area.right_bottom.y - p.y))
    update(record)
end

function M.sync()
    prepare()
    local previous = state()
    local s = {version = M.version, records = {}, buckets = {}, wake = {}, max_reach = 0}
    storage.automatic_cursed_fmd = s
    local names = {}
    for name in pairs(eligible) do names[#names + 1] = name end
    if not names[1] then return end
    for _, surface in pairs(game.surfaces) do
        for _, entity in pairs(surface.find_entities_filtered({type = "mining-drill", name = names})) do
            local id = entity.unit_number
            local old = previous and previous.records[id]
            if old and old.entity == entity then
                s.records[id] = {entity = entity, input = eligible[entity.name], fluid = old.fluid,
                    resource = old.resource, witness = old.witness}
                local slot = id % PERIOD
                s.buckets[slot] = s.buckets[slot] or {}
                s.buckets[slot][id] = true
            end
            add(entity)
        end
    end
end

local function depleted(event)
    local s, resource = state(), event.entity
    if not s or not s.wake or s.max_reach == 0 or resource.prototype.infinite_resource then return end
    local p, r = resource.position, s.max_reach
    for _, entity in pairs(resource.surface.find_entities_filtered({
        area = {{p.x - r, p.y - r}, {p.x + r, p.y + r}}, type = "mining-drill", name = eligible_names,
    })) do
        local record = s.records[entity.unit_number]
        if record and record.resource == resource.name and contains(entity.mining_area, p) then
            -- The depleted entity is still valid during this event. Re-evaluate on
            -- the next tick, before AutoDeconstruct's 15-tick resource check.
            s.wake[entity.unit_number] = true
        end
    end
end

local function tick(event)
    if not state() or not state().wake then M.sync() end -- existing saves after a code-only update
    local s = state()
    local wake = s.wake
    for id in pairs(wake) do
        wake[id] = nil
        local record = s.records[id]
        if record and record.entity.valid then update(record) end
    end
    local bucket = s.buckets[event.tick % PERIOD]
    if not bucket then return end
    for id in pairs(bucket) do
        local record = s.records[id]
        if not record.entity.valid or not eligible[record.entity.name] then
            s.records[id], bucket[id] = nil, nil
        else
            update(record)
        end
    end
end

-- Existing zzz consumers own these events too; never replace their handler/filter
-- with an AFMD-only filter. Earlier consumers perform their own entity checks.
local function on(event, handler)
    local previous = script.get_event_handler(event)
    script.on_event(event, function(e)
        if previous then previous(e) end
        handler(e)
    end)
end

function M.install()
    prepare() -- local prototype caches are reconstructed on load; no storage writes
    for _, event in ipairs({defines.events.on_built_entity, defines.events.on_robot_built_entity,
        defines.events.script_raised_built, defines.events.script_raised_revive, defines.events.on_entity_cloned}) do
        on(event, function(e) add(e.destination or e.entity) end)
    end
    for _, event in ipairs({defines.events.on_entity_settings_pasted, defines.events.on_blueprint_settings_pasted,
        defines.events.script_raised_teleported, defines.events.on_player_rotated_entity, defines.events.on_player_flushed_fluid}) do
        on(event, function(e) add(e.destination or e.entity) end)
    end
    on(defines.events.on_resource_depleted, depleted)
    on(defines.events.on_tick, tick)
end

return M
