local Registry = require("script.external-rooms.registry")
local Plots = {}
local floor = math.floor
local SURFACE_BASE = "factorissimo-external-rooms"
local SLOT = 128
local COLUMNS = 128

local function valid(object) return object and object.valid end

local function callback(kind, name, context)
    local callbacks = kind.callbacks
    local interface = remote.interfaces[callbacks.interface]
    local method = callbacks[name]
    if not (interface and method and interface[method]) then return false, {ok = false, code = "provider-unavailable"} end
    local ok, result = pcall(remote.call, callbacks.interface, method, context)
    if not ok then
        log("Factorissimo external rooms: provider callback failed: " .. callbacks.interface .. "." .. method .. ": " .. tostring(result))
        return false, {ok = false, code = "provider-error"}
    end
    if type(result) ~= "table" or result.ok ~= true then return false, type(result) == "table" and result or {ok = false, code = "provider-rejected"} end
    return true, result
end
Plots.callback = callback

function Plots.exclude_rso(name)
    local rso = remote.interfaces.RSO
    return not rso or rso.ignoreSurface and pcall(remote.call, "RSO", "ignoreSurface", name)
end

local function external_surface()
    local s = Registry.state()
    local surface = s.surface
    if valid(surface) then return not Registry.removing(surface) and surface or nil end
    local name, serial = SURFACE_BASE, 0
    while game.get_surface(name) do serial = serial + 1; name = SURFACE_BASE .. "-" .. serial end
    if not Plots.exclude_rso(name) then return nil end
    surface = game.create_surface(name, {width = 2, height = 2, autoplace_settings = {
        entity = {treat_missing_as_default = false, settings = {}},
        decorative = {treat_missing_as_default = false, settings = {}},
    }})
    surface.localised_name = {"factorissimo-external-room.surface-name"}
    surface.freeze_daytime = true
    surface.daytime = 0.08
    surface.show_clouds = false
    s.surface, s.surface_index = surface, surface.index
    return surface
end

local function absolute(area, x, y)
    return {{x + area[1][1], y + area[1][2]}, {x + area[2][1], y + area[2][2]}}
end

local function room_context(binding, room)
    local kind = Registry.state().kinds[binding.kind_key]
    return {
        binding_id = binding.id,
        host_unit = binding.host_unit,
        host = valid(binding.host) and binding.host or nil,
        provider = binding.provider,
        kind = binding.kind,
        geometry_rev = binding.geometry_rev,
        room_id = room.id,
        surface = valid(room.surface) and room.surface or nil,
        surface_index = room.surface_index,
        origin = {x = room.x, y = room.y},
        write_bounds = absolute(kind.write_bounds, room.x, room.y),
        visit_region = absolute(kind.visit_region, room.x, room.y),
    }
end
Plots.context = room_context

local function slot_bounds(x, y)
    return {{x - 64, y - 64}, {x + 64, y + 64}}
end

local function any_player(surface, area)
    for _, player in pairs(game.players) do
        if player.physical_surface == surface and Registry.contains(area, player.physical_position) then return true end
    end
    return false
end

local function vacant(surface, area)
    return not any_player(surface, area) and surface.count_entities_filtered{area = area, limit = 1} == 0
        and surface.count_tiles_filtered{area = area, name = "out-of-map", invert = true, limit = 1} == 0
        and surface.count_tiles_filtered{area = area, has_hidden_tile = true, limit = 1} == 0
        and surface.count_tiles_filtered{area = area, has_double_hidden_tile = true, limit = 1} == 0
        and not surface.find_decoratives_filtered{area = area, limit = 1}[1]
end

local function reserve_chunks(surface, x, y)
    local xmin, xmax = floor((x - 64) / 32), floor((x + 64 - 1) / 32)
    local ymin, ymax = floor((y - 64) / 32), floor((y + 64 - 1) / 32)
    for cx = xmin, xmax do
        for cy = ymin, ymax do surface.set_chunk_generated_status({cx, cy}, defines.chunk_generated_status.entities) end
    end
end

local function assigned(s, binding, room)
    return room and s.bindings[binding.id] == binding and binding.room_id == room.id and room.binding_id == binding.id
        and s.rooms[room.id] == room and s.rooms_by_plot[room.plot] == room.id and valid(room.surface) and room.surface == s.surface
end

local function quarantine(binding, room, code, permanent)
    Registry.close_doors(binding)
    binding.state, binding.last_error = "quarantined", code
    binding.revision = binding.revision + 1
    if room and room.binding_id == binding.id and room.id == binding.room_id then
        room.state, room.retry_tick = "quarantined", permanent and math.huge or game.tick + 1800
    end
    if permanent then binding.cleanup_permanent = true; Registry.work(Registry.state()).cleanup[binding.id] = nil end
    return false, code
end

function Plots.ensure(binding)
    local s = Registry.state()
    local kind = s.kinds[binding.kind_key]
    if not (kind and Registry.binding_live(binding, kind)) then return nil, "invalid-host" end
    local room = binding.room_id and s.rooms[binding.room_id]
    if binding.room_id then
        if not assigned(s, binding, room) then quarantine(binding, room, "room-unavailable", true); return nil, "room-unavailable" end
        if room.state == "ready" then return room end
        return nil, room.state == "quarantined" and "build-failed" or "room-unavailable"
    end
    local surface = external_surface()
    if not valid(surface) or not Registry.binding_live(binding, kind) then return nil, "room-unavailable" end
    -- A slot number is not proof of emptiness. Skip dirty plots without writing
    -- to them; bound probes per request even if a third party filled many slots.
    local plot, x, y
    for _ = 1, 8 do
        local candidate = s.next_plot
        s.next_plot = candidate + 1
        x, y = (candidate % COLUMNS) * SLOT, floor(candidate / COLUMNS) * SLOT
        if not s.rooms_by_plot[candidate] and vacant(surface, slot_bounds(x, y)) then plot = candidate; break end
    end
    if not plot then return nil, "plot-unavailable" end
    s.last_room_id = s.last_room_id + 1
    room = {id = s.last_room_id, binding_id = binding.id, surface = surface, surface_index = surface.index,
        x = x, y = y, plot = plot, state = "building", revision = 1, retry_tick = 0}
    s.rooms[room.id] = room
    s.rooms_by_plot[plot] = room.id
    binding.room_id, binding.state = room.id, "building"
    binding.revision = binding.revision + 1
    reserve_chunks(surface, x, y)
    if not assigned(s, binding, room) or not Registry.binding_live(binding, kind) or not vacant(surface, slot_bounds(x, y)) then
        quarantine(binding, room, "plot-unavailable", true); return nil, "plot-unavailable"
    end
    local ok, result = callback(kind, "build_room", room_context(binding, room))
    if not ok or not assigned(s, binding, room) or room.state ~= "building" or not Registry.binding_live(binding, kind) then
        quarantine(binding, room, not ok and result.code or "build-failed", not valid(room.surface))
        return nil, "build-failed"
    end
    room.state, binding.state = "ready", "ready"
    room.revision, binding.revision = room.revision + 1, binding.revision + 1
    return room
end

function Plots.room(binding)
    local room = binding and binding.room_id and storage.external_rooms.rooms[binding.room_id]
    return room and room.binding_id == binding.id and room.id == binding.room_id and room or nil
end

function Plots.retain_incident(binding, visit)
    binding.unresolved_bodies = binding.unresolved_bodies or {}
    binding.unresolved_bodies[visit.id] = {player_index = visit.player_index, body = visit.body, unit = visit.body_unit}
    return quarantine(binding, Plots.room(binding), "body-unconfirmed", true)
end

function Plots.room_at(surface_index, position)
    local s = storage.external_rooms
    if not (s and valid(s.surface) and s.surface.index == surface_index and type(position) == "table") then return nil end
    position = {x = position.x or position[1], y = position.y or position[2]}
    if type(position.x) ~= "number" or type(position.y) ~= "number" or not (math.abs(position.x) < math.huge and math.abs(position.y) < math.huge) then return nil end
    local column = floor((position.x + 64) / SLOT)
    local row = floor((position.y + 64) / SLOT)
    if column < 0 or column >= COLUMNS or row < 0 then return nil end
    local id = s.rooms_by_plot and s.rooms_by_plot[row * COLUMNS + column]
    local room = id and s.rooms[id]
    if room and room.surface == s.surface and room.state ~= "cleared" then
        local binding = s.bindings[room.binding_id]
        local kind = binding and s.kinds[binding.kind_key]
        if kind and Registry.contains(absolute(kind.visit_region, room.x, room.y), position)
            and (room.state ~= "ready" or room.surface.get_tile(position).name ~= "out-of-map") then return room, binding, kind end
    end
end

local belts = {['transport-belt'] = true, ['underground-belt'] = true, ['linked-belt'] = true, splitter = true,
    ['lane-splitter'] = true, loader = true, ['loader-1x1'] = true}
local function inventory_empty(entity)
    if entity.has_items_inside() or entity.grid and entity.grid.count() > 0 then return false end
    if belts[entity.type] then
        for i = 1, entity.get_max_transport_line_index() do if entity.get_transport_line(i).get_item_count() > 0 then return false end end
    end
    local maximum = entity.get_max_inventory_index()
    for i = 1, maximum do
        local inventory = entity.get_inventory(i)
        if inventory and not inventory.is_empty() then return false end
    end
    for i = 1, entity.fluids_count do
        local fluid = entity.get_fluid(i)
        if fluid and fluid.amount > 0 then return false end
    end
    if entity.type == "inserter" and entity.held_stack.valid_for_read then return false end
    return true
end

local function dense(list)
    if type(list) ~= "table" then return false end
    local n, count = #list, 0
    for k in pairs(list) do
        if type(k) ~= "number" or floor(k) ~= k or k < 1 or k > n then return false end
        count = count + 1
    end
    return count == n
end

local function normalize_manifest(room, context, manifest)
    local area = context.write_bounds
    local owned = {}
    if manifest.pending_work or not dense(manifest.entities) then return nil end
    for _, entity in ipairs(manifest.entities) do
        if not (valid(entity) and entity.object_name == "LuaEntity" and entity.surface == room.surface and entity.unit_number
            and not owned[entity.unit_number] and Registry.fixed(entity.prototype) and inventory_empty(entity)) then return nil end
        local box = entity.bounding_box
        if not Registry.contains(area, entity.position) or box.left_top.x < area[1][1] or box.left_top.y < area[1][2]
            or box.right_bottom.x > area[2][1] or box.right_bottom.y > area[2][2] then return nil end
        owned[entity.unit_number] = entity
    end
    local width = area[2][1] - area[1][1]
    if not dense(manifest.tiles) or #manifest.tiles ~= width * (area[2][2] - area[1][2]) then return nil end
    local seen, nonvoid = {}, 0
    for _, tile in ipairs(manifest.tiles) do
        local position = tile.position
        local x, y = position and (position.x or position[1]), position and (position.y or position[2])
        if not (type(x) == "number" and type(y) == "number" and floor(x) == x and floor(y) == y
            and x >= area[1][1] and x < area[2][1] and y >= area[1][2] and y < area[2][2]
            and type(tile.name) == "string" and room.surface.get_tile(x, y).name == tile.name) then return nil, "cleanup-blocked" end
        local key = (y - area[1][2]) * width + x - area[1][1]
        if seen[key] then return nil end
        seen[key] = true
        if tile.name ~= "out-of-map" then nonvoid = nonvoid + 1 end
    end
    local slot = slot_bounds(room.x, room.y)
    if any_player(room.surface, slot) or room.surface.count_tiles_filtered{area = slot, name = "out-of-map", invert = true, limit = nonvoid + 1} ~= nonvoid
        or room.surface.find_decoratives_filtered{area = slot, limit = 1}[1] then return nil end
    -- Restoring void also erases hidden and double-hidden tiles. A fresh plot was
    -- void: a hidden layer other than that baseline is not ours to throw away.
    if room.surface.count_tiles_filtered{area = slot, has_double_hidden_tile = true, limit = 1} > 0 then return nil end
    for _, tile in pairs(room.surface.find_tiles_filtered{area = slot, has_hidden_tile = true}) do
        if not Registry.contains(area, tile.position) or tile.hidden_tile ~= "out-of-map" then return nil end
    end
    local found = room.surface.find_entities_filtered{area = slot}
    if #found ~= #manifest.entities then return nil end
    for _, entity in pairs(found) do
        if not entity.unit_number or owned[entity.unit_number] ~= entity then return nil end
    end
    return manifest.entities
end

function Plots.try_clear(binding)
    local s = Registry.state()
    local room, kind = Plots.room(binding), s.kinds[binding.kind_key]
    if not binding.entry_locked or Registry.work(s).visitors[binding.id] then return false, "cleanup-blocked" end
    if not kind then return quarantine(binding, room, "provider-unavailable", true) end
    if binding.room_id and not assigned(s, binding, room) then return quarantine(binding, room, "room-unavailable", true) end
    if not room then
        binding.state, binding.entry_locked = "cleared", true
        binding.revision = binding.revision + 1
        Registry.remove_binding(binding)
        return true, "cleared"
    end
    local context = room_context(binding, room)
    local inspected, manifest = callback(kind, "inspect_cleanup", context)
    if not inspected then return quarantine(binding, room, manifest.code or "cleanup-blocked") end
    if not assigned(s, binding, room) then return quarantine(binding, room, "room-unavailable", true) end
    -- A provider bug (bad LuaObject, sparse manifest, etc.) must quarantine only its slot.
    local checked, entities = pcall(normalize_manifest, room, context, manifest)
    if not checked or not entities then return quarantine(binding, room, "cleanup-blocked") end
    context.entities = entities -- exactly the handles approved above, not a new provider scan
    local cleared, result = callback(kind, "clear_room", context)
    if not cleared then return quarantine(binding, room, result.code or "cleanup-blocked") end
    if not assigned(s, binding, room) then return quarantine(binding, room, "room-unavailable", true) end
    if not vacant(room.surface, slot_bounds(room.x, room.y)) then return quarantine(binding, room, "cleanup-blocked") end
    room.state, binding.state = "cleared", "cleared"
    room.revision, binding.revision = room.revision + 1, binding.revision + 1
    Registry.state().rooms_by_plot[room.plot] = nil
    Registry.remove_binding(binding)
    return true, "cleared"
end

return Plots
