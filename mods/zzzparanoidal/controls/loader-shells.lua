-- Selection/tooltip shell around a native loader. No scripted power or item accounting.
-- Opening the shell shows the native loader window; power stays with the native loader.
local defs = require("loader-definitions")
local snap = require("controls.electric-loaders")
local M = {}
-- Same gate as the data stage, plus the prototypes it should have produced:
-- never register handlers for a feature whose prototypes are absent.
local function feature_present()
    if not defs.enabled(script.active_mods, settings.startup) then return false end
    for _, name in ipairs(defs.names) do
        if not (prototypes.entity[name] and prototypes.entity[defs.shell(name, "input")]
                and prototypes.entity[defs.shell(name, "output")]) then
            log("Paranoidal loaders: prototypes missing, runtime disabled: " .. name)
            return false
        end
    end
    return true
end
if not feature_present() then
    function M.init() end
    return M
end
local TAG = "paranoidal_loader"
local wire_ids = { defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green }
local status_keys = {}
for name, value in pairs(defines.entity_status) do status_keys[value] = (name:gsub("_", "-")) end
local attach, replace_shell

local function state()
    storage.paranoidal_loader_shells = storage.paranoidal_loader_shells or {
        shells = {}, machines = {}, registrations = {}, pending = {}, viewers = {},
    }
    return storage.paranoidal_loader_shells
end
local function valid(e) return e and e.valid end
local function position_key(e)
    return e.surface.index .. ":" .. e.force.index .. ":" .. e.position.x .. ":" .. e.position.y
end
local function record(e)
    if not valid(e) then return nil end
    local s = state()
    return s.shells[e.unit_number] or s.machines[e.unit_number]
end
local function configuration(machine)
    local c = { mode = machine.loader_type, filters = {}, filter_mode = machine.loader_filter_mode }
    for i = 1, machine.filter_slot_count do c.filters[tostring(i)] = machine.get_filter(i) end
    local b = machine.get_or_create_control_behavior()
    c.circuit = {
        circuit_read_transfers = b.circuit_read_transfers, circuit_set_filters = b.circuit_set_filters,
        circuit_enable_disable = b.circuit_enable_disable, circuit_condition = b.circuit_condition,
        connect_to_logistic_network = b.connect_to_logistic_network, logistic_condition = b.logistic_condition,
    }
    return c
end
local function configure(machine, c, direction)
    if c then
        machine.loader_type = c.mode or "output"
        if c.filter_mode then machine.loader_filter_mode = c.filter_mode end
        for i = 1, machine.filter_slot_count do machine.set_filter(i, (c.filters or {})[tostring(i)]) end
        local b = machine.get_or_create_control_behavior()
        for k, v in pairs(c.circuit or {}) do b[k] = v end
    end
    -- Setting loader_type may flip the direction: restore the stored belt-flow direction.
    machine.direction = direction
    machine.update_connections()
end
-- The shell must never emit signals, whatever was pasted or built onto it:
-- drop all sections and switch its output off. Wires still join the network.
local function clear_shell_signals(shell)
    local b = shell.get_or_create_control_behavior()
    for i = b.sections_count, 1, -1 do b.remove_section(i) end
    b.enabled = false
end
-- The worker stops exactly while its visible shell is marked for deconstruction.
local function sync_disabled(r)
    if valid(r.shell) and valid(r.machine) then
        r.machine.disabled_by_script = r.shell.to_be_deconstructed()
    end
end
local function external_wires(entity, excluded)
    local result = {}
    for _, id in ipairs(wire_ids) do
        local c = entity.get_wire_connector(id, false)
        if c then
            for _, wire in pairs(c.connections) do
                if wire.target.valid and wire.target.owner ~= excluded then
                    result[#result + 1] = { id = id, target = wire.target, origin = wire.origin }
                end
            end
        end
    end
    return result
end
-- Internal shell<->loader link per colour, ONLY while that colour has external wires.
-- A permanent link would give every loader its own visible circuit network IDs.
-- Idempotent: safe to call repeatedly.
local function sync_link(r)
    if not (valid(r.shell) and valid(r.machine)) then return end
    local used = {}
    for _, wire in ipairs(external_wires(r.shell, r.machine)) do used[wire.id] = true end
    for _, id in ipairs(wire_ids) do
        local a = r.shell.get_wire_connector(id, true)
        local b = r.machine.get_wire_connector(id, true)
        local linked = a.is_connected_to(b, defines.wire_origin.script)
        if used[id] and not linked then
            assert(a.connect_to(b, false, defines.wire_origin.script), "Loader shell circuit connection failed")
        elseif linked and not used[id] then
            a.disconnect_from(b, defines.wire_origin.script)
        end
    end
end
local function connect_pair(r)
    clear_shell_signals(r.shell)
    sync_link(r)
end
local function restore_wires(entity, wires)
    for _, wire in ipairs(wires or {}) do
        if wire.target.valid then
            local c = entity.get_wire_connector(wire.id, true)
            if c then c.connect_to(wire.target, false, wire.origin) end
        end
    end
end
local function register(r)
    local s = state()
    r.shell_id, r.machine_id = r.shell.unit_number, r.machine.unit_number
    s.shells[r.shell_id] = r
    s.machines[r.machine_id] = r
    r.shell_registration = script.register_on_object_destroyed(r.shell)
    r.machine_registration = script.register_on_object_destroyed(r.machine)
    s.registrations[r.shell_registration] = { kind = "shell", record = r }
    s.registrations[r.machine_registration] = { kind = "machine", record = r }
end
local function unregister(r)
    local s = state()
    if r.shell_registration then s.registrations[r.shell_registration] = nil end
    if r.machine_registration then s.registrations[r.machine_registration] = nil end
    if r.shell_id then s.shells[r.shell_id] = nil end
    if r.machine_id then s.machines[r.machine_id] = nil end
end
local function close_viewers(r)
    for index, viewed in pairs(state().viewers) do
        if viewed == r then
            local player = game.get_player(index)
            if player and valid(r.machine) and player.opened == r.machine then player.opened = nil end
            state().viewers[index] = nil
        end
    end
end

-- Mining returns complete stacks (including metadata), never reconstructed name/count pairs.
local function release_contents(machine, inventory)
    for i = 1, machine.get_max_transport_line_index() do
        local line = machine.get_transport_line(i)
        local details = line.get_detailed_contents()
        if #details > 0 then
            local buffer = game.create_inventory(#details)
            for j, entry in ipairs(details) do buffer[j].set_stack(entry.stack) end
            line.clear()
            for j = 1, #buffer do
                local stack = buffer[j]
                if stack.valid_for_read then
                    local inserted = inventory and inventory.valid and inventory.insert(stack) or 0
                    if inserted < stack.count then
                        stack.count = stack.count - inserted
                        machine.surface.spill_item_stack { position = machine.position, stack = stack, enable_looted = true, force = machine.force }
                    end
                end
            end
            buffer.destroy()
        end
    end
end
local function remove(r, inventory, keep_settings)
    if valid(r.machine) then
        if keep_settings and valid(r.shell) then
            state().pending[position_key(r.shell)] = {
                tick = game.tick, config = configuration(r.machine), energy = r.machine.energy,
                direction = r.machine.direction,
                wires = external_wires(r.shell, r.machine),
            }
        end
        release_contents(r.machine, inventory)
    end
    close_viewers(r)
    unregister(r)
    if valid(r.machine) then r.machine.destroy() end
end

replace_shell = function(r)
    local expected = defs.shell(r.machine.name, r.machine.loader_type)
    if r.shell.name == expected then
        r.shell.direction = r.machine.direction
        sync_disabled(r)
        return
    end
    local old = r.shell
    local wires = external_wires(old, r.machine)
    -- Robot orders live on the shell: carry them to the replacement.
    local deconstruct = old.to_be_deconstructed()
    local upgrade, upgrade_quality = old.get_upgrade_target()
    local replacement = assert(old.surface.create_entity {
        name = expected, position = old.position, direction = r.machine.direction,
        force = old.force, quality = old.quality, create_build_effect_smoke = false,
    }, "Cannot create loader presentation shell")
    replacement.health = old.health
    replacement.last_user = old.last_user
    unregister(r)
    r.shell = replacement
    old.destroy()
    register(r)
    restore_wires(replacement, wires)
    connect_pair(r)
    if deconstruct then replacement.order_deconstruction(replacement.force) end
    if upgrade then
        replacement.order_upgrade {
            target = { name = upgrade.name, quality = upgrade_quality and upgrade_quality.name },
            force = replacement.force,
        }
    end
    sync_disabled(r)
end

attach = function(shell, config, existing, no_snap)
    local found = record(shell)
    if found then return found end
    local def = defs.shells[shell.name]
    if not def then return nil end
    local pending = state().pending[position_key(shell)]
    state().pending[position_key(shell)] = nil
    if pending and pending.tick == game.tick then config = config or pending.config else pending = nil end
    local machine = existing or shell.surface.create_entity {
        name = def.machine, position = shell.position, direction = shell.direction,
        type = (config and config.mode) or def.mode, force = shell.force, quality = shell.quality,
        create_build_effect_smoke = false,
    }
    assert(valid(machine), "Cannot create native loader " .. def.machine)
    machine.destructible = false
    machine.minable_flag = false
    machine.operable = true
    if not existing then
        configure(machine, config or { mode = def.mode }, pending and pending.direction or shell.direction)
        if pending then machine.energy = math.min(pending.energy, machine.electric_buffer_size) end
        if not config and not no_snap then snap(machine) end
    end
    local r = { shell = shell, machine = machine }
    register(r)
    if pending then restore_wires(shell, pending.wires) end
    connect_pair(r)
    replace_shell(r) -- also syncs disabled_by_script
    return r
end

local function wrap(machine)
    if record(machine) then return record(machine) end
    local shell = assert(machine.surface.create_entity {
        name = defs.shell(machine.name, machine.loader_type), position = machine.position,
        direction = machine.direction, force = machine.force, quality = machine.quality,
        create_build_effect_smoke = false,
    }, "Cannot wrap existing native loader")
    shell.health = machine.health
    shell.last_user = machine.last_user
    local wires = external_wires(machine)
    local r = attach(shell, nil, machine, true)
    restore_wires(shell, wires)
    for _, wire in ipairs(wires) do
        if wire.target.valid then
            local c = machine.get_wire_connector(wire.id, false)
            if c then c.disconnect_from(wire.target, wire.origin) end
        end
    end
    connect_pair(r)
    return r
end

function M.init()
    state()
    -- Recipes moved to the item names: carry an already-unlocked AAI recipe over.
    for _, force in pairs(game.forces) do
        for i, old_name in ipairs(defs.old_recipes) do
            local old, new = force.recipes[old_name], force.recipes[defs.names[i]]
            if old and new and old.enabled then new.enabled = true; old.enabled = false end
        end
    end
    -- Reconcile only this feature's native 1x2 loaders, never legacy AAI 1x1 entities.
    -- Existing native machines are wrapped in place: contents, energy and filters survive.
    for _, surface in pairs(game.surfaces) do
        for _, shell in pairs(surface.find_entities_filtered { type = "constant-combinator" }) do
            if defs.shells[shell.name] then
                local r = record(shell)
                if not r or not valid(r.machine) then
                    if r then unregister(r) end
                    local existing
                    for _, machine in pairs(surface.find_entities_filtered {
                        name = defs.shells[shell.name].machine, position = shell.position, force = shell.force,
                    }) do
                        if not record(machine) then existing = machine; break end
                    end
                    attach(shell, nil, existing, true)
                else
                    r.machine.destructible = false
                    r.machine.operable = true
                    connect_pair(r)
                    sync_disabled(r)
                end
            end
        end
        for _, machine in pairs(surface.find_entities_filtered { type = "loader" }) do
            if defs.machines[machine.name] and not record(machine) then wrap(machine) end
        end
    end
end

local function built(event)
    local shell = event.entity
    if valid(shell) and defs.shells[shell.name] then
        attach(shell, event.tags and event.tags[TAG])
    elseif valid(shell) and defs.machines[shell.name] then
        -- A script may explicitly create the native prototype rather than the placing shell.
        wrap(shell)
    elseif valid(shell) then
        -- A revived blueprint neighbour may bring a wire to an existing shell.
        local ok, connectors = pcall(shell.get_wire_connectors, false)
        if not ok then return end
        for _, connector in pairs(connectors) do
            for _, wire in pairs(connector.connections) do
                local r = wire.target.valid and record(wire.target.owner)
                if r then sync_link(r) end
            end
        end
    end
end
local function cloned(event)
    local source, destination = event.source, event.destination
    if not valid(destination) then return end
    if defs.shells[destination.name] then
        local source_record = record(source)
        local config = source_record and valid(source_record.machine) and configuration(source_record.machine)
        local nearby = destination.surface.find_entities_filtered { name = defs.shells[destination.name].machine, position = destination.position, force = destination.force }
        local existing
        for _, machine in pairs(nearby) do if not record(machine) then existing = machine; break end end
        attach(destination, config, existing, true)
    elseif defs.machines[destination.name] then
        -- clone_area may clone both members in either order. Prefer the engine's native
        -- clone, which already contains the exact transport-line contents and energy.
        local shells = destination.surface.find_entities_filtered { type = "constant-combinator", position = destination.position, force = destination.force }
        for _, shell in pairs(shells) do
            local r = record(shell)
            if r and r.machine.name == destination.name then
                local old = r.machine
                unregister(r)
                if valid(old) and old ~= destination then old.destroy() end
                r.machine = destination
                destination.destructible = false; destination.minable_flag = false; destination.operable = true
                register(r); connect_pair(r); replace_shell(r)
                return
            end
        end
        -- Leave until the end of this tick: its shell clone may follow it.
        state().pending["clone:" .. destination.unit_number] = { tick = game.tick, clone = destination }
    end
end

local function update_status(r)
    if not (valid(r.shell) and valid(r.machine)) then return end
    r.shell.custom_status = {
        diode = r.machine.energy > 0 and defines.entity_status_diode.green or defines.entity_status_diode.red,
        label = { "entity-status." .. (status_keys[r.machine.status] or "working") },
    }
end
-- Preserve earlier zzz handlers; this module never takes over lifecycle registration.
local function on(event, callback)
    local previous = script.get_event_handler(event)
    script.on_event(event, function(e)
        if previous then previous(e) end
        callback(e)
    end)
end
for _, event in ipairs({ defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built, defines.events.script_raised_revive }) do on(event, built) end
on(defines.events.on_entity_cloned, cloned)
for _, event in ipairs({ defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity }) do
    on(event, function(e) local r = record(e.entity); if r then remove(r, e.buffer, true) end end)
end
-- The engine leaves a ghost of the dying shell. Drop the internal script link first,
-- otherwise the ghost keeps dangling red/green connections to the destroyed loader.
-- The loader settings are handed to that ghost so robots rebuild it configured.
on(defines.events.on_entity_died, function(e)
    local r = record(e.entity)
    if not r then return end
    if valid(r.shell) and valid(r.machine) then
        local s = state()
        s.dying = s.dying or {}
        s.dying[r.shell_id] = configuration(r.machine)
        for _, id in ipairs(wire_ids) do
            local a = r.shell.get_wire_connector(id, false)
            local b = r.machine.get_wire_connector(id, false)
            if a and b then a.disconnect_from(b, defines.wire_origin.script) end
        end
    end
    remove(r, nil, false)
end)
on(defines.events.on_post_entity_died, function(e)
    local s = state()
    local config = s.dying and e.unit_number and s.dying[e.unit_number]
    if not config then return end
    s.dying[e.unit_number] = nil
    local ghost = e.ghost
    if not valid(ghost) then return end
    for _, connector in pairs(ghost.get_wire_connectors(false)) do
        connector.disconnect_all(defines.wire_origin.script)
    end
    local tags = ghost.tags or {}
    tags[TAG] = config
    ghost.tags = tags
end)
on(defines.events.script_raised_destroy, function(e)
    local r = record(e.entity)
    if r then
        local shell = r.shell
        remove(r, nil, false)
        if valid(shell) and shell ~= e.entity then shell.destroy() end
    end
end)
on(defines.events.on_object_destroyed, function(e)
    local entry = state().registrations[e.registration_number]
    if not entry then return end
    local r = entry.record
    local shell = r.shell
    remove(r, nil, false)
    if valid(shell) then shell.destroy() end
end)
on(defines.events.on_player_rotated_entity, function(e)
    local r = record(e.entity)
    if r and valid(r.machine) and valid(r.shell) then
        if e.entity == r.shell then
            -- The player rotated a combinator, not a loader. Let the native loader
            -- perform its own rotation (including input/output switching at a chest).
            -- No by_player: avoid recursively raising this event for the worker.
            local reverse = (r.shell.direction - e.previous_direction) % 16 == 12
            r.machine.rotate { reverse = reverse }
        end
        -- Also restores the shell if native rotation was refused. An event raised
        -- directly for the worker has already rotated it: do not rotate it twice.
        replace_shell(r)
    end
end)
on(defines.events.script_raised_teleported, function(e)
    local r = record(e.entity)
    if r and valid(r.machine) and valid(r.shell) then
        local moved, other = e.entity, e.entity == r.shell and r.machine or r.shell
        if other.surface.index ~= moved.surface.index then
            log("Paranoidal loader: unsupported cross-surface teleport event")
            return
        end
        -- Passing a surface argument is forbidden for these entity types, even
        -- for the current surface. Do not raise another teleport event recursively.
        if not other.teleport(moved.position) then
            if not moved.teleport(e.old_position) then
                log("Paranoidal loader: paired teleport and rollback both refused")
                return
            end
            log("Paranoidal loader: rejected an unsupported paired teleport")
            return
        end
        r.machine.direction = r.shell.direction
        r.machine.update_connections()
        connect_pair(r)
    end
end)
on(defines.events.on_marked_for_deconstruction, function(e)
    local r = record(e.entity); if r then sync_disabled(r) end
end)
on(defines.events.on_cancelled_deconstruction, function(e)
    local r = record(e.entity); if r then sync_disabled(r) end
end)
on(defines.events.on_entity_settings_pasted, function(e)
    local source, destination = record(e.source), record(e.destination)
    -- Any source (e.g. an ordinary constant combinator) may paste signal sections.
    if destination and valid(destination.shell) and e.destination == destination.shell then
        clear_shell_signals(destination.shell)
    end
    if source and destination and valid(source.machine) and valid(destination.machine) then
        local config = configuration(source.machine)
        local direction = destination.machine.direction
        if config.mode ~= destination.machine.loader_type then direction = (direction + 8) % 16 end
        configure(destination.machine, config, direction)
        replace_shell(destination); connect_pair(destination)
    end
end)
on(defines.events.on_player_setup_blueprint, function(e)
    local blueprint = e.record or e.stack
    if not (blueprint and blueprint.valid) then return end
    for index, entity in pairs(e.mapping.get()) do
        local r = record(entity)
        if r and valid(r.machine) then blueprint.set_blueprint_entity_tag(index, TAG, configuration(r.machine)) end
    end
end)
-- The shell has no window of its own: redirect to the native loader window.
-- The machine also raises on_gui_opened; only the shell is redirected.
local function sync_viewed(index)
    local r = state().viewers[index]
    if r and valid(r.shell) and valid(r.machine) then replace_shell(r); update_status(r) end
end
on(defines.events.on_gui_opened, function(e)
    local entity = e.entity
    local r = record(entity)
    if not (r and valid(r.shell) and valid(r.machine)) then return end
    local player = game.get_player(e.player_index)
    if entity == r.shell then
        sync_link(r) -- drop a stale link whose external wire's other end is gone
        player.opened = r.machine
    elseif entity == r.machine then
        state().viewers[e.player_index] = r
    end
end)
on(defines.events.on_gui_closed, function(e)
    local r = state().viewers[e.player_index]
    if r and e.entity and r.machine == e.entity then
        -- The native window may toggle input/output: follow it with the shell.
        sync_viewed(e.player_index)
        state().viewers[e.player_index] = nil
    end
end)
on(defines.events.on_selected_entity_changed, function(e)
    local r = record(game.get_player(e.player_index).selected)
    if r then update_status(r) end
end)
-- Constant-time idle cost: update only players' inspected loaders, not every loader.
-- No wire-connected event exists: while a player holds a circuit wire, watch the
-- shells they point at (both ends of a drag) and sync once more when they stop.
local circuit_wires = { ["red-wire"] = true, ["green-wire"] = true }
local function wiring()
    local s = state()
    s.wiring = s.wiring or {}
    return s.wiring
end
on(defines.events.on_player_cursor_stack_changed, function(e)
    local player = game.get_player(e.player_index)
    local stack = player and player.cursor_stack
    local w = wiring()
    if stack and stack.valid_for_read and circuit_wires[stack.name] then
        w[e.player_index] = w[e.player_index] or {}
    elseif w[e.player_index] then
        for _, r in pairs(w[e.player_index]) do sync_link(r) end
        w[e.player_index] = nil
    end
end)
on(defines.events.on_tick, function(e)
    local s = state()
    for index, watched in pairs(wiring()) do
        local player = game.get_player(index)
        local r = player and player.connected and record(player.selected)
        if r then watched[r.shell_id] = r end
        for id, w in pairs(watched) do
            if valid(w.shell) and valid(w.machine) then sync_link(w) else watched[id] = nil end
        end
    end
    for key, pending in pairs(s.pending) do
        if pending.tick < e.tick then
            s.pending[key] = nil
            if valid(pending.clone) and not record(pending.clone) then wrap(pending.clone) end
        end
    end
    if e.tick % 30 == 0 then
        for index in pairs(s.viewers) do sync_viewed(index) end
        for _, player in pairs(game.connected_players) do
            local r = record(player.selected)
            if r then update_status(r) end
        end
    end
end)
return M
