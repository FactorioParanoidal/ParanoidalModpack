local Registry = require("script.external-rooms.registry")
local Plots = require("script.external-rooms.plots")
local Visits = {}
local valid = function(object) return object and object.valid end
local RETURN_BUTTON = "factorissimo_external_room_return"
Visits.return_button = RETURN_BUTTON
local COOLDOWN = 35
local EMPTY = {}
local visit_room_valid, mark_recovery

local allowed_by_kind = {}
local busy = {}
local editing_permissions = false
local carry_body

local function state() return Registry.state() end
local function visit_of(index)
    local s = storage.external_rooms
    return s and type(index) == "number" and index == index and s.visits[index] or nil
end

local function kind_of(binding)
    return binding and storage.external_rooms.kinds[binding.kind_key]
end

local function room_of(binding) return Plots.room(binding) end

local function body_inside(visit, room)
    return room and valid(room.surface) and valid(visit.body) and visit.body.surface == room.surface
        and Registry.contains({{room.x - 64, room.y - 64}, {room.x + 64, room.y + 64}}, visit.body.position)
end

local function host_state(binding)
    if not binding then return nil end
    local reservations, occupants, viewers = 0, 0, 0
    local room = room_of(binding)
    local s = storage.external_rooms
    -- Read-only callers can precede the first writable event on an older save.
    local indices = s.work and (s.work.visitors[binding.id] or EMPTY) or s.visits
    for index in pairs(indices) do
        local visit = s.visits[index]
        if visit and visit.binding_id == binding.id and visit.state ~= "requested" then
            if body_inside(visit, room) then
                occupants = occupants + 1
                local player = game.get_player(index)
                if visit.state == "inside" and player and visit_room_valid(player, visit, room) then viewers = viewers + 1 end
            else reservations = reservations + 1 end
        end
    end
    for _, incident in pairs(binding.unresolved_bodies or EMPTY) do
        if body_inside(incident, room) then occupants = occupants + 1 else reservations = reservations + 1 end
    end
    return {binding_id = binding.id, revision = binding.revision, state = binding.state, room_id = binding.room_id,
        reservations = reservations, occupants = occupants, viewers = viewers, entry_locked = binding.entry_locked or false,
        last_error = binding.last_error}
end
Visits.host_state = host_state

local function visit_snapshot(visit, event_name)
    local binding = Registry.binding(visit.binding_id)
    local room = room_of(binding)
    local snapshot = host_state(binding) or {binding_id = visit.binding_id, revision = visit.revision or 0, state = "cleared",
        reservations = 0, occupants = 0, viewers = 0, entry_locked = true}
    snapshot.event = event_name
    snapshot.player_index = visit.player_index
    snapshot.visit_id = visit.id
    snapshot.visit_state = visit.state
    local player = visit.state == "inside" and game.get_player(visit.player_index)
    snapshot.active = player and visit_room_valid(player, visit, room) or false
    snapshot.restricted = valid(visit.restricted) and visit.restricted or nil
    snapshot.door_id = visit.door_id
    snapshot.code = visit.code
    snapshot.provider = visit.provider
    snapshot.kind = visit.kind
    snapshot.host_unit = visit.host_unit
    snapshot.body = valid(visit.body) and visit.body or nil
    if room then
        snapshot.surface = valid(room.surface) and room.surface or nil
        snapshot.surface_index = room.surface_index
        snapshot.origin = {x = room.x, y = room.y}
    end
    return snapshot
end

local function deliver(kind, snapshot)
    if not kind then return false end
    local index = snapshot.player_index
    local previous = busy[index]
    busy[index] = true
    local ok = Plots.callback(kind, "visit_changed", snapshot)
    busy[index] = previous
    return ok
end

local function notify(visit, event_name)
    local binding = Registry.binding(visit.binding_id)
    local kind = kind_of(binding)
    if not kind then return false end
    local snapshot = visit_snapshot(visit, event_name)
    local queue = binding.pending_by_player
    if not queue then queue = {}; binding.pending_by_player = queue end
    queue[visit.player_index] = snapshot -- Latest fact for this player and binding; never drops another player's update.
    local pending = Registry.work(state()).notifications
    pending[binding.id] = true
    if not deliver(kind, snapshot) then return false end
    if queue[visit.player_index] == snapshot then queue[visit.player_index] = nil end
    if not next(queue) then pending[binding.id], binding.notice_due, binding.notice_delay = nil, nil, nil end
    return true
end

local function button(player, show)
    if not valid(player) then return end
    local element = player.gui.top[RETURN_BUTTON]
    if element and element.get_mod() ~= script.mod_name then return false end
    if show then
        if not element then element = player.gui.top.add {type = "button", name = RETURN_BUTTON, caption = {"factorissimo-external-room.return"}} end
        element.visible, element.enabled = true, true
    elseif element then element.destroy() end
    return true
end

local function original_group(player)
    return player.permission_group
end

local function group_key(kind, original)
    return kind.provider .. "\0" .. kind.kind .. "\0" .. kind.geometry_rev .. "\0" .. (original and original.group_id or 0)
end

local function restricted_group(kind, original, temporary)
    local base = original or game.permissions.get_group(0)
    if not valid(base) then return nil end
    local key = group_key(kind, original)
    local s = state()
    local group = not temporary and s.groups[key] or nil
    if not valid(group) or group == base then
        local serial = (s.last_group_id or 0) + 1
        local name
        repeat
            name = "factorissimo-external-observer-" .. serial
            serial = serial + 1
        until not game.permissions.get_group(name)
        s.last_group_id = serial - 1
        group = game.permissions.create_group(name)
        if not valid(group) then return nil end
        if not temporary then s.groups[key] = group end
    end
    local allowed = allowed_by_kind[kind.fingerprint]
    if not allowed then
        allowed = {}
        for _, name in ipairs(kind.policy.allowed_actions) do allowed[name] = true end
        allowed_by_kind[kind.fingerprint] = allowed
    end
    editing_permissions = true
    local complete = true
    for name, action in pairs(defines.input_action) do
        local permit = allowed[name] == true and base.allows_action(action)
        if group.allows_action(action) ~= permit and not group.set_allows_action(action, permit) then complete = false end
    end
    editing_permissions = false
    return complete and group or nil
end

local function set_group(player, group)
    if player.permission_group == group then return end
    editing_permissions = true
    player.permission_group = group
    editing_permissions = false
end

local function restore_group(player, visit)
    if not valid(visit.restricted) or player.permission_group ~= visit.restricted then return end
    if not visit.original_lost and (visit.original == nil or valid(visit.original)) then set_group(player, visit.original)
    else player.print({"factorissimo-external-room.permissions-lost"}) end
end

local function clear_position(surface, body, candidates, bounds)
    if not (valid(surface) and valid(body)) then return nil end
    for _, candidate in ipairs(candidates) do
        local clear = surface.find_non_colliding_position(body.name, candidate, 1.05, 0.25, true)
        if clear and (clear.x-candidate.x)^2+(clear.y-candidate.y)^2<=1.11
            and (not bounds or Registry.contains(bounds, clear)) and surface.get_tile(clear).name ~= "out-of-map" then return clear end
    end
end

local function absolute_landings(base_x, base_y, landings)
    local out = {}
    for i, point in ipairs(landings) do out[i] = {x = base_x + point.x, y = base_y + point.y} end
    return out
end

local function inside_area(room, source)
    return {{room.x + source.trigger[1][1], room.y + source.trigger[1][2]},
        {room.x + source.trigger[2][1], room.y + source.trigger[2][2]}}
end

local function direction_matches(list, direction)
    for _, value in ipairs(list) do if value == direction then return true end end
    return false
end

local function current_body(player)
    local body = player.character
    return valid(body) and body or nil
end

visit_room_valid = function(player, visit, room)
    local body = current_body(player)
    local binding = Registry.binding(visit.binding_id)
    local kind = kind_of(binding)
    return player.connected and not visit.retire_pending and body and body == visit.body and Registry.binding_live(binding, kind)
        and room and room.state == "ready" and valid(room.surface)
        and player.controller_type == defines.controllers.character and not player.driving and player.force.index == visit.origin_force
        and binding.force_index == visit.origin_force and player.physical_surface == room.surface and not Registry.removing(room.surface)
        and room.surface.get_tile(player.physical_position).name ~= "out-of-map"
        and valid(visit.restricted) and player.permission_group == visit.restricted
        and Registry.contains({{room.x + kind.visit_region[1][1], room.y + kind.visit_region[1][2]},
            {room.x + kind.visit_region[2][1], room.y + kind.visit_region[2][2]}}, player.physical_position)
end

local function release_visit(player, visit, event_name, code)
    local index = visit.player_index
    if visit_of(index) ~= visit then return end
    local previous = busy[index]; busy[index] = true
    visit.state, visit.code = event_name == "aborted" and "aborted" or "outside", code
    Registry.set_visit(index, nil) -- commit before permission events or provider callbacks
    local binding = Registry.binding(visit.binding_id)
    if binding then
        if code then binding.last_error = code end
        binding.revision = binding.revision + 1
    end
    if valid(player) then button(player, false); restore_group(player, visit) end
    notify(visit, event_name)
    busy[index] = previous
end

local function abort_entry(player, visit, code, confirmed_return)
    if visit_of(visit.player_index) ~= visit then return false, code end
    -- A provider/instant event can have moved the original body even before our own hop.
    if not confirmed_return and valid(visit.body) and visit.body.surface ~= visit.origin_surface then
        visit.retire_pending = true; mark_recovery(visit); return false, "recovery-pending"
    end
    release_visit(player, visit, "aborted", code)
    return false, code
end

local function entry_problem(player, binding, kind)
    local host = binding and binding.host
    if not (valid(player) and player.connected and Registry.binding_live(binding, kind) and valid(host)) then return "invalid-host" end
    if player.controller_type == defines.controllers.remote or player.physical_controller_type ~= defines.controllers.character
        or not current_body(player) or player.driving then return "invalid-player" end
    if player.physical_surface ~= host.surface or player.force.index ~= binding.force_index then return "wrong-force" end
    if not Registry.supported_origin(host.surface) then return "unsupported-origin" end
    local control = player.gui.top[RETURN_BUTTON]
    if control and control.get_mod() ~= script.mod_name then return "permission-failed" end
    if player.cursor_stack and player.cursor_stack.valid_for_read then return "cursor-busy" end
    if host.to_be_deconstructed() then return "marked-for-deconstruction" end
    if not player.can_reach_entity(host) then return "out-of-reach" end
end

local function nearest_door(player, binding, kind)
    local position = player.physical_position
    local point = {x = position.x - binding.x, y = position.y - binding.y}
    local found
    for id, door in pairs(kind.doors) do
        if Registry.contains(door.outside.trigger, point) then
            if found then return nil, true end
            found = id
        end
    end
    return found, false
end

local function prepare_context(binding, visit)
    return {binding_id = binding.id, host_unit = binding.host_unit, host = valid(binding.host) and binding.host or nil,
        provider = binding.provider, kind = binding.kind, geometry_rev = binding.geometry_rev,
        player_index = visit.player_index, visit_id = visit.id, door_id = visit.door_id, revision = binding.revision,
        approved_cleanup_entities = true}
end

local function enter(player, visit, transport)
    local binding = Registry.binding(visit.binding_id)
    local kind = kind_of(binding)
    local problem = entry_problem(player, binding, kind)
    if problem then return abort_entry(player, visit, problem) end
    local door_id, tied = visit.door_id, false
    if not door_id then door_id, tied = nearest_door(player, binding, kind) end
    local door = door_id and kind.doors[door_id]
    if tied then return abort_entry(player, visit, "ambiguous-door") end
    if not door then return abort_entry(player, visit, door_id and "invalid-door" or "out-of-reach") end
    local function at_door()
        local p = player.physical_position
        return Registry.contains(door.outside.trigger, {x = p.x - binding.x, y = p.y - binding.y})
    end
    if not at_door() then return abort_entry(player, visit, "out-of-reach") end
    visit.door_id, visit.state = door_id, "entering"
    visit.host_unit, visit.provider, visit.kind = binding.host_unit, binding.provider, binding.kind
    visit.origin_surface, visit.origin_position = player.physical_surface, {x = player.physical_position.x, y = player.physical_position.y}
    visit.origin_force, visit.body = player.force.index, current_body(player)
    visit.body_unit = visit.body.unit_number
    visit.original = original_group(player)
    visit.restricted = restricted_group(kind, visit.original)
    if not valid(visit.restricted) or not visit.restricted.allows_action(defines.input_action.gui_click) then
        return abort_entry(player, visit, "permission-failed")
    end
    binding.revision = binding.revision + 1
    local accepted, answer = Plots.callback(kind, "prepare_entry", prepare_context(binding, visit))
    if not accepted then return abort_entry(player, visit, answer.code or "entry-denied") end
    if visit_of(visit.player_index) ~= visit or visit.retire_pending or not Registry.binding_live(binding, kind) then return abort_entry(player, visit, "invalid-host") end
    local room, code = Plots.ensure(binding)
    if not room then return abort_entry(player, visit, code or "build-failed") end
    problem = entry_problem(player, binding, kind)
    if problem or visit_of(visit.player_index) ~= visit or visit.retire_pending or current_body(player) ~= visit.body or player.permission_group ~= visit.original or not at_door() then
        return abort_entry(player, visit, problem or "entry-changed")
    end
    visit.restricted = restricted_group(kind, visit.original)
    if not valid(visit.restricted) or not visit.restricted.allows_action(defines.input_action.gui_click) then
        return abort_entry(player, visit, "permission-failed")
    end
    local ctx = Plots.context(binding, room)
    local landing = clear_position(room.surface, visit.body, absolute_landings(room.x, room.y, door.inside.landings), ctx.visit_region)
    if not landing then return abort_entry(player, visit, "landing-blocked") end
    set_group(player, visit.restricted)
    if not valid(player) or player.permission_group ~= visit.restricted then return abort_entry(player, visit, "permission-failed") end
    if visit_of(visit.player_index) ~= visit or visit.retire_pending or entry_problem(player, binding, kind) or current_body(player) ~= visit.body or not at_door() then
        return abort_entry(player, visit, "entry-changed")
    end
    local moved, pending = transport(player, room.surface, landing, true, {owner = "external-room", operation = "enter", visit_id = visit.id})
    if visit_of(visit.player_index) ~= visit then return false, "entry-changed" end
    if not (moved and valid(player) and visit_room_valid(player, visit, room)) then
        if pending or moved or not valid(visit.body) or visit.body.surface ~= visit.origin_surface then
            visit.state, visit.code, visit.retire_pending = "recovery-pending", "recovery-pending", true
            binding.revision = binding.revision + 1
            notify(visit, "recovery-pending")
            return false, "recovery-pending"
        end
        return abort_entry(player, visit, "teleport-failed")
    end
    visit.state, visit.code = "inside", nil
    binding.revision = binding.revision + 1
    if not button(player, true) then visit.retire_pending = true; mark_recovery(visit); return false, "recovery-pending" end
    notify(visit, "entered")
    return true, "entered"
end

local function outside_landing(player, binding, door)
    if not (binding and valid(binding.host)) then return nil end
    return clear_position(binding.host.surface, current_body(player) or player.character,
        absolute_landings(binding.x, binding.y, door.outside.landings))
end

local function fallback_destination(player, visit, banned_surface)
    local body = visit.body
    if not valid(body) then return nil end
    local force = body.force
    local origin = visit.origin_surface
    if valid(origin) and origin.index ~= banned_surface and Registry.supported_origin(origin) then
        local p = origin.find_non_colliding_position(body.name, visit.origin_position, 8, 0.25, true)
        if p and origin.get_tile(p).name ~= "out-of-map" then return origin, p end
    end
    local home = game.get_surface(1)
    if valid(home) and home.index ~= banned_surface and Registry.supported_origin(home) then
        local spawn = force.get_spawn_position(home)
        local p = home.find_non_colliding_position(body.name, spawn, 32, 0.5, true)
        if p and home.get_tile(p).name ~= "out-of-map" then return home, p end
    end
    local s = state()
    local refuge = s.refuge_surface
    if not valid(refuge) or refuge.index == banned_surface or Registry.removing(refuge) then
        local name, serial = "factorissimo-external-refuge", 0
        while game.get_surface(name) do serial = serial + 1; name = "factorissimo-external-refuge-" .. serial end
        if not Plots.exclude_rso(name) then return nil end
        refuge = game.create_surface(name, {width = 32, height = 32, autoplace_settings = {
            entity = {treat_missing_as_default = false, settings = {}}, decorative = {treat_missing_as_default = false, settings = {}}}})
        refuge.set_chunk_generated_status({0, 0}, defines.chunk_generated_status.entities)
        local tiles = {}
        for x = -8, 7 do for y = -8, 7 do tiles[#tiles + 1] = {name = "refined-concrete", position = {x, y}} end end
        refuge.set_tiles(tiles, false, false, true)
        refuge.localised_name = {"factorissimo-external-room.refuge-name"}
        s.refuge_surface = refuge
    end
    return refuge, clear_position(refuge, body, {{x = 0, y = 0}, {x = 3, y = 0}, {x = -3, y = 0}})
end

local function arrived(body, surface, landing)
    if not valid(body) or body.surface ~= surface then return false end
    local p = body.position
    return (p.x - landing.x)^2 + (p.y - landing.y)^2 <= 0.25
end

mark_recovery = function(visit)
    if visit.state == "recovery-pending" then return end
    visit.state, visit.code = "recovery-pending", "recovery-pending"
    local binding = Registry.binding(visit.binding_id)
    if binding then binding.revision = binding.revision + 1 end
    notify(visit, "recovery-pending")
end

local function leave(player, visit, door_id, transport, emergency, banned_surface)
    if not (valid(player) and current_body(player) == visit.body) then return false, "invalid-player" end
    local binding = Registry.binding(visit.binding_id)
    local kind = kind_of(binding)
    local room = room_of(binding)
    if not emergency and not visit_room_valid(player, visit, room) then return false, "invalid-visit" end
    local surface, landing, door
    if not emergency and door_id then
        door = kind and kind.doors[door_id]
        if not door then return false, "invalid-door" end
        if not Registry.contains(inside_area(room, door.inside), player.physical_position) then return false, "out-of-reach" end
        landing = outside_landing(player, binding, door)
        surface = valid(binding.host) and binding.host.surface or nil
        if not landing then visit.code = "exit-blocked"; return false, visit.code end
    else
        surface, landing = fallback_destination(player, visit, banned_surface)
    end
    if not (valid(surface) and landing) then
        visit.retry_tick = game.tick + COOLDOWN
        mark_recovery(visit)
        return false, "recovery-pending"
    end
    local prior = visit.state
    visit.state, visit.door_id = "leaving", door_id or visit.door_id
    if binding then binding.revision = binding.revision + 1 end
    local moved, pending = transport(player, surface, landing, true, {owner = "external-room", operation = "leave", visit_id = visit.id, door_id = door_id})
    if visit_of(visit.player_index) ~= visit then return false, "invalid-visit" end
    if not (moved and arrived(visit.body, surface, landing) and valid(player) and player.character == visit.body) then
        if pending or emergency or prior == "recovery-pending" or not body_inside(visit, room) then
            visit.retry_tick = game.tick + COOLDOWN
            mark_recovery(visit)
            return false, "recovery-pending"
        end
        visit.state, visit.code = "inside", "exit-blocked"
        if binding then binding.revision = binding.revision + 1 end
        return false, "exit-blocked"
    end
    release_visit(player, visit, "left")
    return true, "left"
end

function Visits.request_enter(request)
    if type(request) ~= "table" then return {ok = false, code = "invalid-host", state = "rejected"} end
    local player = type(request.player_index) == "number" and request.player_index >= 1 and request.player_index <= 4294967295
        and request.player_index == math.floor(request.player_index) and game.get_player(request.player_index)
    local binding = Registry.binding(request.binding_id)
    local kind = kind_of(binding)
    if not (valid(player) and binding and kind) then return {ok = false, code = "invalid-host", state = "rejected"} end
    if busy[player.index] then return {ok = false, code = "busy", state = "rejected"} end
    if not Registry.binding_live(binding, kind) then
        if not binding.entry_locked then Visits.retire(binding, "invalid-host") end
        return {ok = false, code = "invalid-host", state = binding.state}
    end
    if request.door_id ~= nil and (type(request.door_id) ~= "string" or not kind.doors[request.door_id]) then
        return {ok = false, code = "invalid-door", state = "rejected"}
    end
    local existing = visit_of(player.index)
    if existing then
        if existing.state == "requested" and existing.binding_id == binding.id and existing.door_id == request.door_id then
            return {ok = true, code = "already-requested", state = "requested", visit_id = existing.id}
        end
        return {ok = false, code = "already-visiting", state = existing.state, visit_id = existing.id}
    end
    local s = state()
    s.last_visit_id = s.last_visit_id + 1
    local visit = {id = s.last_visit_id, player_index = player.index, binding_id = binding.id, door_id = request.door_id,
        provider = binding.provider, kind = binding.kind, host_unit = binding.host_unit,
        state = "requested", requested_tick = game.tick, expires_tick = game.tick + 60}
    Registry.set_visit(player.index, visit)
    return {ok = true, code = "requested", state = "requested", visit_id = visit.id}
end

function Visits.request_leave(request)
    if type(request) ~= "table" then return {ok = false, code = "invalid-visit", state = "rejected"} end
    local visit = visit_of(request.player_index)
    if not visit or request.visit_id ~= visit.id then return {ok = false, code = "invalid-visit", state = "rejected"} end
    if busy[visit.player_index] or visit.state ~= "inside" and visit.state ~= "recovery-pending" then return {ok = false, code = "busy", state = visit.state} end
    local kind = kind_of(Registry.binding(visit.binding_id))
    if request.door_id ~= nil and not (type(request.door_id) == "string" and kind and kind.doors[request.door_id]) then
        return {ok = false, code = "invalid-door", state = visit.state}
    end
    visit.leave_requested, visit.leave_door = true, request.door_id
    return {ok = true, code = "requested", state = visit.state, visit_id = visit.id}
end

local function inside_door(visit, player, direction)
    local binding = Registry.binding(visit.binding_id)
    local kind = kind_of(binding)
    local room = room_of(binding)
    if not (kind and room) then return nil end
    local found
    for id, door in pairs(kind.doors) do
        if Registry.contains(inside_area(room, door.inside), player.physical_position) and direction_matches(door.inside.directions, direction) then
            if found then return false end
            found = id
        end
    end
    return found
end

function Visits.process(player, tick, direction, transport)
    local visit = visit_of(player.index)
    if visit then
        if busy[player.index] then return true end
        busy[player.index] = true
        local owned = true
        if visit.state == "requested" then
            if tick > visit.expires_tick then abort_entry(player, visit, "request-expired") else enter(player, visit, transport) end
        elseif visit.state == "inside" then
            local binding = Registry.binding(visit.binding_id)
            local room = room_of(binding)
            if not visit_room_valid(player, visit, room) then
                leave(player, visit, nil, transport, true)
            elseif visit.leave_requested then
                local door = visit.leave_door
                visit.leave_requested, visit.leave_door = nil, nil
                leave(player, visit, door, transport, false)
            elseif direction then
                local id = inside_door(visit, player, direction)
                if id ~= nil then storage.last_player_teleport[player.index] = tick end
                if id == false then player.print({"factorissimo-external-room.ambiguous-door"})
                elseif id then leave(player, visit, id, transport, false)
                end
            end
        elseif visit.state == "recovery-pending" then
            if not visit.retry_tick or tick >= visit.retry_tick then leave(player, visit, nil, transport, true, visit.banned_surface) end
        elseif visit.state == "leaving" or visit.state == "entering" then
            owned = true
        else
            visit.retire_pending = true; mark_recovery(visit)
        end
        busy[visit.player_index] = nil
        return owned
    end
    if not direction then return false end
    local candidates = Registry.outside_candidates(player.physical_surface, player.physical_position, direction)
    if not candidates then return false end
    storage.last_player_teleport[player.index] = tick -- Throttle recognized refusals as well as actual travel.
    if candidates[2] then
        player.print({"factorissimo-external-room.ambiguous-door"})
        return true
    end
    local candidate = candidates[1]
    local s = state()
    s.last_visit_id = s.last_visit_id + 1
    visit = {id = s.last_visit_id, player_index = player.index, binding_id = candidate.binding.id,
        provider = candidate.binding.provider, kind = candidate.binding.kind, host_unit = candidate.binding.host_unit,
        door_id = candidate.door.id, state = "requested", requested_tick = tick, expires_tick = tick}
    Registry.set_visit(player.index, visit)
    busy[player.index] = true
    enter(player, visit, transport)
    busy[visit.player_index] = nil
    return true
end

function Visits.has_visit(player_index)
    return visit_of(player_index) ~= nil
end

-- Revalidate the exact destination *after* instant handlers on the first hop.
-- Ordinary factory travel does not use this policy. An evacuation needs no entry rights.
function Visits.transit_ready(player, metadata, transit, surface, position)
    local v = visit_of(player.index)
    if not (v and v.id == metadata.visit_id and valid(v.body) and player.connected and current_body(player) == v.body
        and player.controller_type == defines.controllers.character and not player.driving and player.physical_surface == transit
        and not Registry.removing(surface)) then return false end
    local binding = Registry.binding(v.binding_id)
    local kind = kind_of(binding)
    if metadata.operation == "enter" then
        local room = room_of(binding)
        if not (v.state == "entering" and not v.retire_pending and Registry.binding_live(binding, kind) and room and room.state == "ready"
            and room.surface == surface and Registry.supported_origin(binding.host.surface) and not binding.host.to_be_deconstructed()
            and player.force.index == v.origin_force and binding.force_index == v.origin_force and valid(v.restricted) and player.permission_group == v.restricted
            and v.restricted.allows_action(defines.input_action.gui_click) and not (player.cursor_stack and player.cursor_stack.valid_for_read)
            and Registry.contains(Plots.context(binding, room).visit_region, position)) then return false end
    elseif metadata.operation ~= "leave" or v.state ~= "leaving" then return false
    elseif metadata.door_id then
        if v.retire_pending or not Registry.binding_live(binding, kind) or surface ~= binding.host.surface or not Registry.supported_origin(surface) then return false end
    elseif surface ~= state().refuge_surface and not Registry.supported_origin(surface) then return false end
    if surface.get_tile(position).name == "out-of-map" then return false end
    local clear = surface.find_non_colliding_position(v.body.name, position, 0.01, 0.01, true)
    return clear and clear.x == position.x and clear.y == position.y
end

function Visits.recover_travel(player, pending)
    local visit = visit_of(player.index)
    if not visit or visit.id ~= pending.visit_id then return true end
    if player.controller_type ~= defines.controllers.character or current_body(player) ~= visit.body or player.driving then return false end
    local b = Registry.binding(visit.binding_id)
    local room, kind = room_of(b), kind_of(b)
    -- A named exit obstructed during the transit hop is not permission to use
    -- the opposite exterior. Go back inside, unless explicit return/evacuation won.
    if pending.door_id and not visit.retire_pending and not (visit.leave_requested and not visit.leave_door)
        and Registry.binding_live(b, kind) and room and room.state == "ready" and valid(room.surface) and room.surface == pending.surface
        and not Registry.removing(room.surface) and valid(visit.restricted) and player.permission_group == visit.restricted
        and player.force.index == visit.origin_force and b.force_index == visit.origin_force then
        local door = kind.doors[pending.door_id]
        local candidates = door and absolute_landings(room.x, room.y, door.inside.landings) or {}
        table.insert(candidates, 1, pending.position)
        local landing = clear_position(room.surface, visit.body, candidates, Plots.context(b, room).visit_region)
        if not landing then return false end
        visit.state = "leaving" -- intermediate surface events must not start a second evacuation
        local moved = player.teleport(landing, room.surface)
        if visit_of(visit.player_index) ~= visit then return true end
        if moved and arrived(visit.body, room.surface, landing) and valid(player) and visit_room_valid(player, visit, room) then
            visit.state, visit.code, visit.leave_requested, visit.leave_door = "inside", "exit-blocked", nil, nil
            b.revision = b.revision + 1; button(player, true); notify(visit, "resumed"); return true
        end
        visit.state = "recovery-pending"; return false
    end
    local surface, landing = fallback_destination(player, visit, visit.banned_surface)
    if not (valid(surface) and landing and player.teleport(landing, surface) and arrived(visit.body, surface, landing)) then return false end
    if visit_of(visit.player_index) ~= visit then return true end
    if pending.operation == "enter" then abort_entry(player, visit, "teleport-failed", true) else release_visit(player, visit, "left") end
    return true
end

function Visits.retire(binding, reason)
    if not binding or binding.state == "cleared" then return {ok = true, code = "cleared", state = "cleared"} end
    if binding.entry_locked then return {ok = true, code = binding.state, state = binding.state, binding_id = binding.id} end
    Registry.close_doors(binding)
    binding.state, binding.retire_reason = "closing", reason or "retired"
    binding.revision = binding.revision + 1
    local s = state()
    for index in pairs(Registry.work(s).visitors[binding.id] or EMPTY) do s.visits[index].retire_pending = true end
    return {ok = true, code = "closing", state = binding.state, binding_id = binding.id}
end

function Visits.retire_request(request)
    if type(request) ~= "table" then return {ok = false, code = "invalid-host", state = "rejected"} end
    local binding = Registry.binding(request.binding_id)
    if not binding or binding.provider ~= request.provider then return {ok = false, code = "invalid-host", state = "rejected"} end
    return Visits.retire(binding, "provider-retired")
end

local function controlled_body(player, body)
    if not (valid(player) and player.connected) then return false end
    if player.controller_type == defines.controllers.remote and (player.character == body or body.player == player) then player.exit_remote_view() end
    return valid(player) and player.character == body and player.controller_type == defines.controllers.character
end

local function reacquire_body(visit, player)
    if valid(visit.body) then return true end
    if not (visit.body_unit and player and player.connected) then return false end
    local body = current_body(player)
    if body and body.unit_number == visit.body_unit then visit.body = body; return true end
    for _, candidate in pairs(player.get_associated_characters() or EMPTY) do
        if valid(candidate) and candidate.unit_number == visit.body_unit then visit.body = candidate; return true end
    end
    return false
end

local function unresolved_body(player, visit)
    local b = Registry.binding(visit.binding_id)
    if b then Visits.retire(b, "body-unconfirmed"); Plots.retain_incident(b, visit) end
    log("Factorissimo external rooms: original body not accounted for; retained binding " .. visit.binding_id .. ", visit " .. visit.id)
    release_visit(player, visit, "left", "body-unconfirmed") -- not a successful rescue
end

function Visits.maintenance(tick, transport)
    local s = storage.external_rooms
    if not s then return end
    local w = Registry.work(s)
    for index, visit in pairs(s.visits) do
        local binding = s.bindings[visit.binding_id]
        if binding and not binding.entry_locked and not Registry.binding_live(binding, kind_of(binding)) then Visits.retire(binding, "invalid-host") end
        -- Both hops are synchronous. A transitional state still present at this
        -- tick boundary is unfinished work, including after loading a save.
        if visit.state == "entering" or visit.state == "leaving" then visit.retire_pending = true; mark_recovery(visit) end
        if visit.state == "recovery-pending" and not visit.retire_pending then
            local player = game.get_player(index)
            if not (valid(visit.body) and player and player.connected and current_body(player) == visit.body
                and player.controller_type == defines.controllers.character and not player.driving) then visit.retire_pending = true end
        end
        if visit.state == "requested" and tick > visit.expires_tick then
            abort_entry(game.get_player(index), visit, "request-expired")
        elseif visit.retire_pending and tick >= (visit.retry_tick or 0) then
            local player = game.get_player(index)
            local returns = storage.factory_travel_returns
            if visit.state == "requested" then
                abort_entry(player, visit, "retired")
            elseif not reacquire_body(visit, player) then
                if visit.logged_out and player then
                    -- Logged-off characters are not enumerated by the engine. Absence is
                    -- not a death or an evacuation. Never give the visit to another body.
                    if player.connected and current_body(player) and Registry.supported_origin(player.physical_surface) then
                        unresolved_body(player, visit)
                    else visit.retry_tick = tick + 60; mark_recovery(visit) end
                else
                    if returns and returns[index] and returns[index].visit_id == visit.id then returns[index] = nil end
                    release_visit(player, visit, "left", "body-gone")
                end
            elseif controlled_body(player, visit.body) then
                if player.driving then player.driving = false end
                if visit_of(index) == visit and current_body(player) == visit.body and not player.driving and not (returns and returns[index]) then
                    leave(player, visit, nil, transport, true, visit.banned_surface)
                end
            else
                local surface, landing = fallback_destination(player, visit, visit.banned_surface)
                local ok, moved
                if valid(surface) and landing then ok, moved = pcall(carry_body, visit.body, surface, landing) end
                if ok and moved then
                    if returns and returns[index] and returns[index].visit_id == visit.id then returns[index] = nil end
                    release_visit(player, visit, "left")
                else
                    visit.retry_tick = tick + COOLDOWN
                    mark_recovery(visit)
                end
            end
        end
    end
    if tick % 60 == 0 then
        for id in pairs(w.notifications) do
            local binding = s.bindings[id]
            local queue = binding.pending_by_player
            if tick >= (binding.notice_due or 0) then
                for index, snapshot in pairs(queue) do
                    if deliver(kind_of(binding), snapshot) and queue[index] == snapshot then queue[index] = nil end
                end
                if not next(queue) then w.notifications[id], binding.notice_delay, binding.notice_due = nil, nil, nil
                else binding.notice_delay = math.min(1800, (binding.notice_delay or 30)*2); binding.notice_due = tick + binding.notice_delay end
            end
        end
    end
    for id in pairs(w.cleanup) do
        local binding = s.bindings[id]
        local room = room_of(binding)
        if not w.visitors[id] and (not room or (room.retry_tick or 0) <= tick) then Plots.try_clear(binding) end
    end
end

function Visits.force_merged(event)
    for _, visit in pairs(state().visits) do
        if visit.origin_force == event.source_index then
            visit.origin_force = event.destination.index
            if visit.state == "inside" then
                local player = game.get_player(visit.player_index)
                local active = player and visit_room_valid(player, visit, room_of(Registry.binding(visit.binding_id)))
                notify(visit, active and "resumed" or "suspended")
            end
        end
    end
end

function Visits.player_changed(player_index)
    local visit = visit_of(player_index)
    if not visit then return end
    local player = game.get_player(player_index)
    local room = room_of(Registry.binding(visit.binding_id))
    if visit.state == "recovery-pending" then visit.retire_pending = true end
    if visit.state == "inside" and player and player.connected then
        local binding = Registry.binding(visit.binding_id)
        if visit_room_valid(player, visit, room) then
            button(player, true)
            if visit.view_suspended then
                visit.view_suspended = nil; binding.revision = binding.revision + 1; notify(visit, "resumed")
            end
        elseif player.controller_type == defines.controllers.remote and body_inside(visit, room) and binding and not visit.retire_pending then
            if not visit.view_suspended then
                visit.view_suspended = true; binding.revision = binding.revision + 1; button(player, false); notify(visit, "suspended")
            end
        else visit.retire_pending = true end
    end
end

function Visits.before_logout(index)
    local v = visit_of(index)
    if v and v.state ~= "requested" then
        v.logged_out = true
        if valid(v.body) then v.body_unit = v.body.unit_number end
    end
end

function Visits.player_left(player_index)
    local visit = visit_of(player_index)
    local player = game.get_player(player_index)
    if visit and visit.state == "requested" then abort_entry(player, visit, "request-cancelled")
    elseif visit and visit.state == "recovery-pending" then visit.retire_pending = true
    elseif visit and visit.state == "inside" then
        local binding = Registry.binding(visit.binding_id)
        if binding then binding.revision = binding.revision + 1 end
        button(player, false); notify(visit, "suspended")
    end
end

function Visits.player_joined(player_index)
    local visit = visit_of(player_index)
    local player = game.get_player(player_index)
    if not (visit and player) then return end
    local room = room_of(Registry.binding(visit.binding_id))
    if visit.logged_out and not reacquire_body(visit, player) then
        visit.retire_pending, visit.retry_tick = true, nil; mark_recovery(visit); return
    end
    visit.logged_out = nil
    if visit.state == "inside" and visit_room_valid(player, visit, room) then
        local binding = Registry.binding(visit.binding_id)
        if binding then binding.revision = binding.revision + 1 end
        visit.view_suspended = nil; button(player, true); notify(visit, "resumed")
    elseif not valid(visit.body) then release_visit(player, visit, "left")
    else visit.retire_pending = true end
end

function Visits.player_lost(player_index)
    local visit = visit_of(player_index)
    if not visit then return end
    local player = game.get_player(player_index)
    if visit.state == "requested" then abort_entry(player, visit, "request-cancelled")
    elseif valid(visit.body) then
        -- A different controller/character can die. Do not discard a still-live body.
        visit.retire_pending = true
        mark_recovery(visit)
    else release_visit(player, visit, "left") end
end

-- A detached character is not a supported cross-surface teleport target. Carry
-- the original LuaEntity as a passenger; never clone it or copy its inventory.
carry_body = function(body, surface, landing)
    if body.player and body.player.connected then return false end -- not a detached character
    local source = body.surface
    if source == surface then return body.teleport(landing) and arrived(body, surface, landing) end
    local boarding = source.find_non_colliding_position("car", body.position, 8, 0.5, true)
    local target = surface.find_non_colliding_position("car", landing, 8, 0.5, true)
    if not (boarding and target) then return false end
    local vehicle = source.create_entity {name = "car", position = boarding, force = body.force}
    if not valid(vehicle) then return false end
    vehicle.destructible, vehicle.minable_flag = false, false
    vehicle.set_passenger(body)
    if vehicle.get_passenger() == body then vehicle.teleport(target, surface) end
    vehicle.set_passenger(nil)
    if vehicle.get_passenger() or vehicle.get_driver() then return false end -- Never destroy an occupied vehicle.
    vehicle.destroy()
    if not valid(body) or body.surface ~= surface then return false end
    if not arrived(body, surface, landing) then body.teleport(landing) end
    return arrived(body, surface, landing)
end

local function evacuate_now(index, visit, banned)
    local body, player = visit.body, game.get_player(index)
    if not valid(body) then return false end
    local surface, position = fallback_destination(player, visit, banned)
    if not (valid(surface) and position) then return false end
    local moved
    if controlled_body(player, body) then
        if player.driving then player.driving = false end
        moved = valid(player) and player.character == body and player.controller_type == defines.controllers.character and not player.driving
            and player.teleport(position, surface) and arrived(body, surface, position)
    else
        local ok, carried = pcall(carry_body, body, surface, position); moved = ok and carried
    end
    if not moved then return false end
    local returns = storage.factory_travel_returns
    if returns and returns[index] and returns[index].visit_id == visit.id then returns[index] = nil end
    release_visit(player, visit, "left")
    return true
end

function Visits.player_removed(index)
    local v = visit_of(index)
    if not v then return end
    if v.state == "requested" then abort_entry(game.get_player(index), v, "request-cancelled")
    elseif not evacuate_now(index, v, v.banned_surface) then unresolved_body(game.get_player(index), v) end
end

function Visits.pre_surface(surface_index)
    local s = storage.external_rooms
    if not s then return end
    s.removing = s.removing or {}; s.removing[surface_index] = game.get_surface(surface_index)
    for id in pairs(Registry.work(s).by_surface[surface_index] or EMPTY) do Visits.retire(s.bindings[id], "surface-removed") end
    if valid(s.surface) and s.surface.index == surface_index then
        for _, room_id in pairs(s.rooms_by_plot) do
            local room = s.rooms[room_id]
            if room.surface == s.surface then Visits.retire(s.bindings[room.binding_id], "surface-removed") end
        end
    end
    for index, visit in pairs(s.visits) do
        if valid(visit.origin_surface) and visit.origin_surface.index == surface_index then visit.origin_surface = nil end
        local body = visit.body
        local room = room_of(s.bindings[visit.binding_id])
        if visit.logged_out and not valid(body) and room and room.surface == s.removing[surface_index] then
            visit.retire_pending = true; mark_recovery(visit)
            log("Factorissimo external rooms: logged-off body unavailable before removing surface for visit " .. visit.id)
        elseif valid(body) and body.surface.index == surface_index then
            visit.banned_surface = surface_index
            if not evacuate_now(index, visit, surface_index) then
                visit.retire_pending = true
                mark_recovery(visit)
                log("Factorissimo external rooms: unable to evacuate live body for player " .. index .. " before removing surface " .. surface_index)
            end
        end
    end
end

function Visits.surface_finished(surface_index)
    local s = storage.external_rooms
    if not (s and s.removing) then return end
    s.removing[surface_index] = nil
    for _, v in pairs(s.visits) do if v.banned_surface == surface_index then v.banned_surface = nil end end
end

function Visits.room_at(request)
    if type(request) ~= "table" then return nil end
    local room, binding = Plots.room_at(request.surface_index, request.position)
    if not room then return nil end
    return {room_id = room.id, binding_id = binding.id, provider = binding.provider, kind = binding.kind,
        state = room.state, surface_index = room.surface_index, origin = {x = room.x, y = room.y}}
end

function Visits.get_visit(request)
    local index = type(request) == "table" and request.player_index or request
    local visit = type(index) == "number" and visit_of(index) or nil
    if not visit then return nil end
    local player = game.get_player(index)
    local room = room_of(Registry.binding(visit.binding_id))
    local active = visit.state == "inside" and player and visit_room_valid(player, visit, room) or false
    return {visit_id = visit.id, binding_id = visit.binding_id, room_id = room and room.id or nil, provider = visit.provider, code = visit.code,
        kind = visit.kind, door_id = visit.door_id, state = visit.state, active = active, host_unit = visit.host_unit,
        surface_index = room and room.surface_index or nil, origin = room and {x = room.x, y = room.y} or nil}
end

function Visits.before_group_deleted(event)
    local s = storage.external_rooms
    if not s then return end
    local doomed, replacements = event.group, {}
    -- A later group can receive the same numeric id. It must not rewrite the
    -- restrictions left on a player whose original group has disappeared.
    for _, kind in pairs(s.kinds) do s.groups[group_key(kind, doomed)] = nil end
    for index, v in pairs(s.visits) do
        if v.original == doomed or v.restricted == doomed then
            local player = game.get_player(index)
            v.retire_pending = true
            if v.original == doomed then v.original_lost = true end
            if v.restricted == doomed and player and player.permission_group == doomed then
                local binding = Registry.binding(v.binding_id)
                local kind = kind_of(binding)
                local group = kind and replacements[binding.kind_key]
                if kind and not group then group = restricted_group(kind, doomed, true); replacements[binding.kind_key] = group end
                if valid(group) then
                    set_group(player, group); if player.permission_group == group then v.restricted = group end
                end
                if player.permission_group == doomed and not evacuate_now(index, v, v.banned_surface) then
                    mark_recovery(v); log("Factorissimo external rooms: cannot replace observer rights or immediately evacuate player " .. index)
                end
            end
        end
    end
end

function Visits.permissions_changed()
    if editing_permissions or not storage.external_rooms then return end
    allowed_by_kind = {}
    local indices = {};for index in pairs(state().visits) do indices[index] = true end
    for index in pairs(indices) do
        local visit = visit_of(index)
        local player = visit and game.get_player(index)
        local binding = visit and Registry.binding(visit.binding_id)
        local kind = kind_of(binding)
        if visit and player and valid(visit.restricted) and player.permission_group == visit.restricted and kind and not visit.original_lost
            and (visit.original == nil or valid(visit.original)) and not visit.retire_pending then
            local refreshed = restricted_group(kind, visit.original)
            if refreshed and refreshed.allows_action(defines.input_action.gui_click) then
                if visit.restricted ~= refreshed then
                    visit.restricted = refreshed; set_group(player, refreshed)
                    if visit.state == "inside" then binding.revision = binding.revision + 1; notify(visit, visit_room_valid(player, visit, room_of(binding)) and "resumed" or "suspended") end
                end
            else visit.retire_pending = true end
        elseif visit and visit.state == "inside" then visit.retire_pending = true end
    end
end

function Visits.init()
    allowed_by_kind, busy, editing_permissions = {}, {}, false
    local s = Registry.state()
    for index, visit in pairs(s.visits) do
        visit.player_index = index
        local binding = Registry.binding(visit.binding_id)
        if not binding or visit.state == "aborted" then
            if valid(visit.body) then visit.retire_pending = true; mark_recovery(visit)
            else release_visit(game.get_player(index), visit, "left") end
        end
    end
end

Registry.set_retire_callback(Visits.retire)
return Visits
