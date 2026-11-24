local Registry = {}
local floor = math.floor
local retire_callback
local door_index = {} -- Each exterior surface is indexed on first use, never in on_load.

local function state()
    local s = storage.external_rooms
    if not s then
        s = {kinds = {}, bindings = {}, by_entity = {}, registrations = {}, rooms = {}, rooms_by_plot = {}, visits = {}, requests = {}, groups = {},
            last_binding_id = 0, last_room_id = 0, last_visit_id = 0, next_plot = 0, revision = 0}
        storage.external_rooms = s
    end
    return s
end
Registry.state = state

local function include(sets, key, id)
    local set = sets[key] or {}; sets[key] = set; set[id] = true
end

local function exclude(sets, key, id)
    local set = sets[key]
    if set then set[id] = nil; if not next(set) then sets[key] = nil end end
end

-- Persistent work sets keep quiet and retired hosts out of the travel loop. A save
-- made before these indices existed builds them once in a writable event, not on_load.
local function work(s)
    if s.work then return s.work end
    local w = {visitors = {}, by_surface = {}, cleanup = {}, notifications = {}}
    for id, b in pairs(s.bindings) do
        if not b.entry_locked and b.state ~= "cleared" then include(w.by_surface, b.surface_index, id) end
        local room = b.room_id and s.rooms[b.room_id]
        if b.state == "closing" or b.state == "quarantined" and not b.cleanup_permanent and not (room and room.retry_tick == math.huge) then w.cleanup[id] = true end
        if b.pending_by_player and next(b.pending_by_player) then w.notifications[id] = true end
    end
    for index, v in pairs(s.visits) do include(w.visitors, v.binding_id, index) end
    s.work = w
    return w
end
Registry.work = work

function Registry.set_visit(index, visit)
    local s = state()
    local sets = work(s).visitors
    local old = s.visits[index]
    if old then exclude(sets, old.binding_id, index) end
    s.visits[index] = visit
    if visit then include(sets, visit.binding_id, index) end
end

function Registry.surface_kind(surface)
    local s = storage.external_rooms
    if s and s.surface and s.surface.valid and surface == s.surface then return "external-rooms" end
    if s and s.refuge_surface and s.refuge_surface.valid and surface == s.refuge_surface then return "external-refuge" end
    local planet = surface.planet
    if planet and planet.name == "factory-travel-surface" then return "factory-transit" end
    if storage.surface_factories and storage.surface_factories[surface.index] then return "factory-floor" end
    return "other"
end

function Registry.removing(surface)
    local s = storage.external_rooms
    return s and s.removing and s.removing[surface.index] == surface
end

function Registry.supported_origin(surface)
    return not surface.platform and not Registry.removing(surface) and Registry.surface_kind(surface) == "other"
end

local function finite(n)
    return type(n) == "number" and n == n and n > -math.huge and n < math.huge
end

local function plain_string(v)
    return type(v) == "string" and #v > 0 and #v <= 120 and not v:find("%c")
end

local function array(t)
    if type(t) ~= "table" then return false end
    for i = 1, #t do if t[i] == nil then return false end end
    for k in pairs(t) do if type(k) ~= "number" or k < 1 or k > #t or floor(k) ~= k then return false end end
    return true
end

local function stable(value, seen)
    local kind = type(value)
    if kind == "nil" then return "n" end
    if kind == "boolean" then return value and "b1" or "b0" end
    if kind == "number" then
        assert(finite(value), "external-room number is not finite")
        return "d" .. string.format("%.17g", value)
    end
    if kind == "string" then return "s" .. #value .. ":" .. value end
    assert(kind == "table", "external-room descriptions contain data only")
    seen = seen or {}
    assert(not seen[value], "external-room description is recursive")
    seen[value] = true
    local keys = {}
    for k in pairs(value) do
        local kt = type(k)
        assert(kt == "string" or kt == "number", "external-room table key must be a string or number")
        keys[#keys + 1] = k
    end
    table.sort(keys, function(a, b)
        if type(a) ~= type(b) then return type(a) < type(b) end
        return a < b
    end)
    local out = {"t", tostring(#keys), ":"}
    for _, k in ipairs(keys) do
        out[#out + 1] = stable(k, seen)
        out[#out + 1] = stable(value[k], seen)
    end
    seen[value] = nil
    return table.concat(out)
end

local function area(value, name, limit)
    assert(type(value) == "table" and type(value[1]) == "table" and type(value[2]) == "table", name .. " must be an area")
    local x1, y1 = value[1].x or value[1][1], value[1].y or value[1][2]
    local x2, y2 = value[2].x or value[2][1], value[2].y or value[2][2]
    assert(finite(x1) and finite(y1) and finite(x2) and finite(y2) and x1 < x2 and y1 < y2, name .. " is invalid")
    assert(x1 >= -limit and y1 >= -limit and x2 <= limit and y2 <= limit, name .. " exceeds the supported plot")
    return {{x1, y1}, {x2, y2}}
end

local function point(value, name, limit)
    assert(type(value) == "table", name .. " must be a point")
    local x, y = value.x or value[1], value.y or value[2]
    assert(finite(x) and finite(y) and math.abs(x) <= limit and math.abs(y) <= limit, name .. " is invalid")
    return {x = x, y = y}
end

local function directions(value, name)
    assert(array(value) and value[1], name .. " must list directions")
    local out, seen = {}, {}
    for _, direction in ipairs(value) do
        assert(type(direction) == "number" and direction >= 0 and direction <= 15 and floor(direction) == direction, name .. " has an invalid direction")
        if not seen[direction] then seen[direction] = true; out[#out + 1] = direction end
    end
    return out
end

local function landings(value, name)
    assert(array(value) and value[1], name .. " must list landing points")
    local out = {}
    for i, p in ipairs(value) do out[i] = point(p, name .. "[" .. i .. "]", 64) end
    return out
end

local function door(id, value)
    assert(plain_string(id) and type(value) == "table", "external-room door is invalid")
    local out = {id = id}
    for _, side in ipairs {"outside", "inside"} do
        local source = assert(value[side], "external-room door needs " .. side)
        out[side] = {
            trigger = area(source.trigger, id .. "." .. side .. ".trigger", 64),
            directions = directions(source.directions, id .. "." .. side .. ".directions"),
            landings = landings(source.landings, id .. "." .. side .. ".landings"),
        }
    end
    return out
end

local OBSERVER_ACTIONS = {start_walking = true, gui_click = true, open_character_gui = true, clear_cursor = true,
    open_gui = true, custom_input = true, gui_value_changed = true, gui_selection_state_changed = true, gui_checked_state_changed = true}

local function within(inner, outer)
    return inner[1][1] >= outer[1][1] and inner[1][2] >= outer[1][2]
        and inner[2][1] <= outer[2][1] and inner[2][2] <= outer[2][2]
end

local REQUIRED_CALLBACKS = {"prepare_entry", "build_room", "visit_changed", "inspect_cleanup", "clear_room"}
local function callback_spec(value)
    assert(type(value) == "table" and plain_string(value.interface), "external-room callback interface is invalid")
    local interface = remote.interfaces[value.interface]
    assert(interface, "external-room callback interface is missing: " .. value.interface)
    local out = {interface = value.interface}
    for _, name in ipairs(REQUIRED_CALLBACKS) do
        local method = value[name]
        assert(plain_string(method) and interface[method], "external-room callback is missing: " .. tostring(method or name))
        out[name] = method
    end
    return out
end

-- Some stationary script/exhibition entities are not classified as industrial buildings.
local fixed_types = {container = true, ["heat-interface"] = true, ["simple-entity-with-owner"] = true, ["simple-entity-with-force"] = true}
function Registry.fixed(prototype)
    return prototype and prototype.type ~= "entity-ghost" and (fixed_types[prototype.type] or prototype.is_building)
end

local function normalize_kind(spec)
    assert(type(spec) == "table" and plain_string(spec.provider) and plain_string(spec.kind), "external-room provider/kind is invalid")
    assert(finite(spec.geometry_rev) and spec.geometry_rev >= 1 and spec.geometry_rev <= 4294967295 and floor(spec.geometry_rev) == spec.geometry_rev, "external-room geometry revision is invalid")
    assert(array(spec.host_names) and spec.host_names[1], "external-room host_names must be a nonempty array")
    local names, known = {}, {}
    for _, name in ipairs(spec.host_names) do
        local prototype = plain_string(name) and prototypes.entity[name]
        assert(Registry.fixed(prototype), "external-room host must be a fixed building: " .. tostring(name))
        if not known[name] then known[name] = true; names[#names + 1] = name end
    end
    table.sort(names)
    local allowed = spec.host_directions or {defines.direction.north}
    local visit_region, write_bounds = area(spec.visit_region, "visit_region", 64), area(spec.write_bounds, "write_bounds", 64)
    for _, corner in ipairs(write_bounds) do assert(corner[1] == floor(corner[1]) and corner[2] == floor(corner[2]), "write bounds must align to tiles") end
    assert(within(visit_region, write_bounds), "visit region exceeds write bounds")
    local doors = {}
    assert(type(spec.doors) == "table" and next(spec.doors), "external-room kind has no doors")
    for id, value in pairs(spec.doors) do
        local d = door(id, value)
        assert(within(d.inside.trigger, visit_region), "internal trigger outside visit region: " .. id)
        for _, p in ipairs(d.inside.landings) do
            assert(Registry.contains(visit_region, p), "internal landing outside visit region: " .. id)
        end
        doors[id] = d
    end
    local actions = {}
    local policy = spec.policy or {}
    assert(array(policy.allowed_actions or {}), "external-room allowed_actions must be an array")
    for _, name in ipairs(policy.allowed_actions or {}) do
        assert(OBSERVER_ACTIONS[name] and defines.input_action[name], "input action is not permitted by observer-v1: " .. tostring(name))
        actions[#actions + 1] = name
    end
    table.sort(actions)
    return {
        provider = spec.provider,
        kind = spec.kind,
        geometry_rev = spec.geometry_rev,
        host_names = names,
        host_name_set = known,
        host_directions = directions(allowed, "host_directions"),
        environment = spec.environment == "observer-v1" and spec.environment or error("unsupported external-room environment"),
        visit_region = visit_region,
        write_bounds = write_bounds,
        doors = doors,
        policy = {allowed_actions = actions},
        callbacks = callback_spec(spec.callbacks),
    }
end

local function kind_key(provider, kind, geometry_rev)
    return provider .. "\0" .. kind .. "\0" .. geometry_rev
end
Registry.kind_key = kind_key

function Registry.register_kind(spec)
    local normalized = normalize_kind(spec)
    local key = kind_key(normalized.provider, normalized.kind, normalized.geometry_rev)
    normalized.fingerprint = stable(normalized)
    local s = state()
    local old = s.kinds[key]
    if old then
        if old.fingerprint ~= normalized.fingerprint then return {ok = false, code = "kind-conflict", state = "registered"} end
        return {ok = true, code = "already-registered", state = "registered"}
    end
    s.kinds[key] = normalized
    s.revision = s.revision + 1
    return {ok = true, code = "registered", state = "registered"}
end

function Registry.get_kind(provider, kind, geometry_rev)
    if not (plain_string(provider) and plain_string(kind) and finite(geometry_rev)) then return nil end
    local s = storage.external_rooms
    return s and s.kinds[kind_key(provider, kind, geometry_rev)] or nil
end

local function index_binding(binding, adding)
    local index = binding.surface_index
    local surface = door_index[index]
    if not surface then return end
    local kind = storage.external_rooms.kinds[binding.kind_key]
    if not kind then return end
    for id, door in pairs(kind.doors) do
        local trigger = door.outside.trigger
        local ref = adding and {binding_id = binding.id, door_id = id}
        for x = floor(binding.x + trigger[1][1]), math.ceil(binding.x + trigger[2][1]) - 1 do
            local column = surface[x]
            if adding and not column then column = {}; surface[x] = column end
            if column then
                for y = floor(binding.y + trigger[1][2]), math.ceil(binding.y + trigger[2][2]) - 1 do
                    local list = column[y]
                    if adding then
                        if not list then list = {}; column[y] = list end
                        list[#list + 1] = ref
                    elseif list then
                        for i = #list, 1, -1 do
                            if list[i].binding_id == binding.id and list[i].door_id == id then table.remove(list, i); break end
                        end
                        if not list[1] then column[y] = nil end
                    end
                end
                if not next(column) then surface[x] = nil end
            end
        end
    end
    if not adding and not next(surface) then door_index[index] = nil end
end

function Registry.close_doors(binding)
    local w = work(state())
    if not binding.entry_locked then index_binding(binding, false); exclude(w.by_surface, binding.surface_index, binding.id) end
    binding.entry_locked = true
    w.cleanup[binding.id] = true
end

local function binding_live(binding, kind)
    local host = binding and binding.host
    if not (kind and host and host.valid and host.unit_number == binding.host_unit and host.name == binding.host_name
        and host.surface.index == binding.surface_index and host.force.index == binding.force_index
        and host.position.x == binding.x and host.position.y == binding.y and host.direction == binding.direction and not host.mirroring) then return false end
    return kind.host_name_set[host.name] and not binding.entry_locked and binding.state ~= "cleared"
end
Registry.binding_live = binding_live

-- Rotation/teleport signals invalidate a fixed host. Silent script changes are
-- also caught on admission, for existing visits, and on explicit re-binding.
function Registry.host_changed(host)
    local s = storage.external_rooms
    if not (s and host and host.valid and host.unit_number) then return end
    local binding = s.bindings[s.by_entity[host.unit_number]]
    if binding and not binding.entry_locked and not binding_live(binding, s.kinds[binding.kind_key]) then
        retire_callback(binding, "invalid-host")
    end
end

function Registry.set_retire_callback(callback) retire_callback = callback end

local function max_id(list, field)
    local n = 0
    for id, value in pairs(list or {}) do
        local candidate = field and value[field] or id
        if type(candidate) == "number" and candidate > n then n = candidate end
    end
    return n
end

function Registry.init()
    local s = state()
    s.kinds, s.bindings, s.by_entity, s.registrations = s.kinds or {}, s.bindings or {}, s.by_entity or {}, s.registrations or {}
    s.rooms, s.rooms_by_plot, s.visits, s.requests, s.groups = s.rooms or {}, {}, s.visits or {}, s.requests or {}, s.groups or {}
    s.next_plot = s.next_plot or 0
    for id, room in pairs(s.rooms) do
        if room.plot ~= nil then
            s.next_plot = math.max(s.next_plot, room.plot + 1)
            if room.state ~= "cleared" then s.rooms_by_plot[room.plot] = id end
        end
    end
    s.last_binding_id = math.max(s.last_binding_id or 0, max_id(s.bindings))
    s.last_room_id = math.max(s.last_room_id or 0, max_id(s.rooms))
    s.last_visit_id = math.max(s.last_visit_id or 0, max_id(s.visits, "id"))
    for unit, id in pairs(s.by_entity) do
        local binding, kind = s.bindings[id], s.bindings[id] and s.kinds[s.bindings[id].kind_key]
        if not (binding and binding.host_unit == unit and binding_live(binding, kind)) then s.by_entity[unit] = nil end
    end
    door_index, s.work, s.registrations = {}, nil, {}
    work(s)
    local available, interfaces = {}, remote.interfaces
    for key, kind in pairs(s.kinds) do
        local methods = interfaces[kind.callbacks.interface]
        available[key] = methods ~= nil
        for _, name in ipairs(REQUIRED_CALLBACKS) do
            if not (methods and methods[kind.callbacks[name]]) then available[key] = false; break end
        end
    end
    for id, binding in pairs(s.bindings) do
        if binding.state ~= "cleared" then
            local host = binding.host
            if host and host.valid then
                s.by_entity[binding.host_unit] = id
                binding.registration = script.register_on_object_destroyed(host)
                s.registrations[binding.registration] = id
            end
            if not binding.entry_locked then
                if not available[binding.kind_key] then retire_callback(binding, "provider-unavailable")
                elseif not (binding_live(binding, s.kinds[binding.kind_key]) and Registry.fixed(host.prototype)) then retire_callback(binding, "invalid-host") end
            end
        end
    end
end

local function direction_allowed(kind, direction)
    for _, value in ipairs(kind.host_directions) do if value == direction then return true end end
    return false
end

function Registry.bind_host(request)
    if type(request) ~= "table" then return {ok = false, code = "invalid-host", state = "rejected"} end
    local kind = Registry.get_kind(request.provider, request.kind, request.geometry_rev)
    local host = request.host
    if host and host.valid and host.object_name == "LuaEntity" then Registry.host_changed(host) end
    if not (kind and host and host.valid and host.object_name == "LuaEntity" and host.unit_number and not host.mirroring and Registry.fixed(host.prototype) and kind.host_name_set[host.name]
        and direction_allowed(kind, host.direction)) then return {ok = false, code = "invalid-host", state = "rejected"} end
    if has_layout and has_layout(host.name) then return {ok = false, code = "invalid-host", state = "rejected"} end
    if not Registry.supported_origin(host.surface) then
        return {ok = false, code = "unsupported-origin", state = "rejected"}
    end
    local s = state()
    local existing = s.by_entity[host.unit_number]
    if existing then
        local binding = s.bindings[existing]
        if binding and binding.kind_key == kind_key(request.provider, request.kind, request.geometry_rev) and binding_live(binding, kind) then
            return {ok = true, code = "already-bound", state = binding.state, binding_id = binding.id, revision = binding.revision}
        end
        return {ok = false, code = "host-conflict", state = binding and binding.state or "closing", binding_id = existing}
    end
    s.last_binding_id = s.last_binding_id + 1
    local id = s.last_binding_id
    local registration = script.register_on_object_destroyed(host)
    local binding = {id = id, kind_key = kind_key(request.provider, request.kind, request.geometry_rev), provider = request.provider,
        kind = request.kind, geometry_rev = request.geometry_rev, host = host, host_unit = host.unit_number, host_name = host.name,
        surface_index = host.surface.index, x = host.position.x, y = host.position.y, direction = host.direction,
        force_index = host.force.index, registration = registration, state = "bound", revision = 1, entry_locked = false}
    include(work(s).by_surface, binding.surface_index, id)
    s.bindings[id], s.by_entity[host.unit_number], s.registrations[registration] = binding, id, id
    s.revision = s.revision + 1
    index_binding(binding, true)
    return {ok = true, code = "bound", state = binding.state, binding_id = id, revision = binding.revision}
end

function Registry.binding(id)
    local s = storage.external_rooms
    return s and finite(id) and s.bindings[id] or nil
end

local function contains(area_value, position)
    return position.x >= area_value[1][1] and position.x < area_value[2][1]
        and position.y >= area_value[1][2] and position.y < area_value[2][2]
end
Registry.contains = contains

local function moving(directions_value, direction)
    for _, value in ipairs(directions_value) do if value == direction then return true end end
    return false
end

function Registry.outside_candidates(surface, position, direction)
    local s = storage.external_rooms
    if not s then return end
    local index = door_index[surface.index]
    if not index then
        local ids = work(s).by_surface[surface.index]
        if not ids then return end
        index = {}; door_index[surface.index] = index
        for id in pairs(ids) do
            local b = s.bindings[id]
            if b and not b.entry_locked then index_binding(b, true) end
        end
    end
    local column = index and index[floor(position.x)]
    local list = column and column[floor(position.y)]
    if not list then return end
    local found, stale
    for _, ref in ipairs(list) do
        local binding = s.bindings[ref.binding_id]
        local kind = binding and s.kinds[binding.kind_key]
        local door_spec = kind and kind.doors[ref.door_id]
        if binding_live(binding, kind) and door_spec then
            if contains(door_spec.outside.trigger, {x = position.x - binding.x, y = position.y - binding.y}) and moving(door_spec.outside.directions, direction) then
                found = found or {}
                found[#found + 1] = {binding = binding, kind = kind, door = door_spec}
            end
        elseif binding and not binding.entry_locked then
            stale = stale or {}; stale[binding.id] = binding
        end
    end
    -- Removal changes the cell list; defer until all matching doors were considered.
    if stale then
        -- A fresh local index can enumerate the same cell in a different order.
        -- Retire in saved-ID order so even subsequent cleanup callbacks agree.
        local ids = {}; for id in pairs(stale) do ids[#ids+1] = id end
        table.sort(ids); for _, id in ipairs(ids) do retire_callback(stale[id], "invalid-host") end
    end
    return found
end

function Registry.destroyed(event)
    if event.type ~= defines.target_type.entity then return end
    local s = storage.external_rooms
    local id = s and s.registrations[event.registration_number]
    if not id then return end
    s.registrations[event.registration_number] = nil
    local binding = s.bindings[id]
    if binding and retire_callback then retire_callback(binding, "host-destroyed") end
end

function Registry.force_merged(event)
    local s = storage.external_rooms
    if not s then return end
    for _, binding in pairs(s.bindings) do
        if binding.state ~= "cleared" and binding.force_index == event.source_index then
            binding.force_index = event.destination.index
            binding.revision = binding.revision + 1
            if not binding.entry_locked and not binding_live(binding, s.kinds[binding.kind_key]) then retire_callback(binding, "invalid-host") end
        end
    end
end

function Registry.remove_binding(binding)
    local s = state()
    if s.by_entity[binding.host_unit] == binding.id then s.by_entity[binding.host_unit] = nil end
    if binding.registration and s.registrations[binding.registration] == binding.id then s.registrations[binding.registration] = nil end
    local w = work(s)
    w.cleanup[binding.id] = nil
    exclude(w.by_surface, binding.surface_index, binding.id)
    binding.host = nil
end

return Registry
