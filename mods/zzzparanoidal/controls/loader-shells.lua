-- Selection/tooltip shell around a native loader. No scripted power or item accounting.
-- Opening the shell shows the native loader window; power stays with the native loader.
local defs = require("loader-definitions")
local snap = require("controls.electric-loaders")
local planners = require("controls.loader-planners")
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
-- Diode colour by the worker's real status, not merely by a non-empty buffer.
local status_diodes = {}
for _, name in ipairs({ "working", "normal" }) do
    if defines.entity_status[name] then status_diodes[defines.entity_status[name]] = defines.entity_status_diode.green end
end
for _, name in ipairs({ "no_power", "disabled", "disabled_by_script", "disabled_by_control_behavior",
        "marked_for_deconstruction", "frozen", "not_plugged_in_electric_network" }) do
    if defines.entity_status[name] then status_diodes[defines.entity_status[name]] = defines.entity_status_diode.red end
end
-- Control-behavior fields stored in settings tags; anything else in a tag is ignored.
local circuit_fields = {
    "circuit_read_transfers", "circuit_set_filters", "circuit_enable_disable", "circuit_condition",
    "connect_to_logistic_network", "logistic_condition",
}
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
local function near(a, b)
    return math.abs(a.x - b.x) < 0.25 and math.abs(a.y - b.y) < 0.25
end
local function record(e)
    if not valid(e) then return nil end
    local s = state()
    return s.shells[e.unit_number] or s.machines[e.unit_number]
end
-- The side of the container end: an input belt flows towards it, an output belt away from it.
local function container_side(mode, direction)
    return mode == "input" and direction or (direction + 8) % 16
end
local function configuration(machine)
    local c = { mode = machine.loader_type, filters = {}, filter_mode = machine.loader_filter_mode }
    for i = 1, machine.filter_slot_count do c.filters[tostring(i)] = machine.get_filter(i) end
    local b = machine.get_or_create_control_behavior()
    c.circuit = {}
    for _, k in ipairs(circuit_fields) do c.circuit[k] = b[k] end
    return c
end
-- Settings come from blueprint/ghost/undo tags and may name items or signals that no longer
-- exist (another modpack version). Apply each field on its own and never fail the build.
local function configure(machine, c, direction)
    if type(c) == "table" then
        machine.loader_type = (c.mode == "input" or c.mode == "output") and c.mode or "output"
        if c.filter_mode ~= nil and not pcall(function() machine.loader_filter_mode = c.filter_mode end) then
            log("Paranoidal loader: ignored a stored filter mode")
        end
        local filters = type(c.filters) == "table" and c.filters or {}
        for i = 1, machine.filter_slot_count do
            if not pcall(machine.set_filter, i, filters[tostring(i)]) then
                log("Paranoidal loader: ignored an unknown stored filter in slot " .. i)
                pcall(machine.set_filter, i, nil)
            end
        end
        local b = machine.get_or_create_control_behavior()
        local circuit = type(c.circuit) == "table" and c.circuit or {}
        for _, k in ipairs(circuit_fields) do
            local v = circuit[k]
            if v ~= nil and not pcall(function() b[k] = v end) then
                log("Paranoidal loader: ignored an invalid stored circuit setting " .. k)
            end
        end
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
-- A loader has no mirrored form: a flip only matters through the direction it leaves.
local function clear_mirroring(shell)
    if shell.mirroring then pcall(function() shell.mirroring = false end) end
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
            if not a.connect_to(b, false, defines.wire_origin.script) then
                log("Paranoidal loader: shell circuit connection failed")
            end
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
    if s.replace_queue and r.shell_id then s.replace_queue[r.shell_id] = nil end
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
-- A script destroy discards them, as the engine does for an ordinary belt.
local function release_contents(machine, inventory, discard)
    for i = 1, machine.get_max_transport_line_index() do
        local line = machine.get_transport_line(i)
        local details = line.get_detailed_contents()
        if discard then
            line.clear()
        elseif #details > 0 then
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
-- Detach the contents of a worker that is replaced in place, per transport line and position.
local function take_contents(machine)
    local lines = {}
    for i = 1, machine.get_max_transport_line_index() do
        local line = machine.get_transport_line(i)
        local details = line.get_detailed_contents()
        if #details > 0 then
            local buffer = game.create_inventory(#details)
            local positions = {}
            for j, entry in ipairs(details) do
                buffer[j].set_stack(entry.stack)
                positions[j] = entry.position
            end
            line.clear()
            lines[i] = { buffer = buffer, positions = positions }
        end
    end
    return lines
end
-- Put detached contents back at their former line positions; whatever does not fit
-- is spilled at `at` (any table with surface, position and force).
local function put_contents(machine, lines, at)
    for i, saved in pairs(lines or {}) do
        local line = valid(machine) and i <= machine.get_max_transport_line_index() and machine.get_transport_line(i)
        local buffer = saved.buffer
        if buffer and buffer.valid then
            for j = 1, #buffer do
                local stack = buffer[j]
                if stack.valid_for_read then
                    local done = false
                    if line then
                        local ok, inserted = pcall(line.insert_at, saved.positions[j] or 0, stack, stack.count)
                        done = ok and inserted
                        if not done then
                            ok, inserted = pcall(line.insert_at_back, stack, stack.count)
                            done = ok and inserted
                        end
                    end
                    if not done and valid(at.surface) then
                        at.surface.spill_item_stack { position = at.position, stack = stack, enable_looted = true, force = at.force }
                    end
                end
            end
            buffer.destroy()
        end
    end
end
-- keep_contents: the worker is being replaced in place (upgrade); its belt items wait
-- for the replacement instead of going to the player's or robot's inventory.
local function remove(r, inventory, keep_settings, discard, keep_contents)
    if valid(r.machine) then
        if keep_settings and valid(r.shell) then
            local pending = {
                tick = game.tick, config = configuration(r.machine), energy = r.machine.energy,
                direction = r.machine.direction,
                wires = external_wires(r.shell, r.machine),
            }
            if keep_contents then
                pending.contents = take_contents(r.machine)
                pending.surface, pending.position, pending.force = r.shell.surface, r.shell.position, r.shell.force
            end
            state().pending[position_key(r.shell)] = pending
        end
        release_contents(r.machine, inventory, discard)
    end
    close_viewers(r)
    unregister(r)
    if valid(r.machine) then r.machine.destroy { raise_destroy = true } end
end

-- defer: never destroy the shell inside an event raised for it. Script builders
-- (Nanobots, Kruise Kontrol, Blueprint Sandboxes) keep using the entity they created.
replace_shell = function(r, defer)
    if not (valid(r.shell) and valid(r.machine)) then return end
    clear_mirroring(r.shell)
    local expected = defs.shell(r.machine.name, r.machine.loader_type)
    if r.shell.name == expected then
        r.shell.direction = r.machine.direction
        sync_disabled(r)
        return
    end
    if defer then
        local s = state()
        s.replace_queue = s.replace_queue or {}
        s.replace_queue[r.shell_id] = r
        sync_disabled(r)
        return
    end
    local old = r.shell
    local wires = external_wires(old, r.machine)
    -- Robot orders live on the shell: carry them to the replacement.
    local deconstruct = old.to_be_deconstructed()
    local upgrade, upgrade_quality = old.get_upgrade_target()
    local replacement = old.surface.create_entity {
        name = expected, position = old.position, direction = r.machine.direction,
        force = old.force, quality = old.quality, create_build_effect_smoke = false,
    }
    if not valid(replacement) then
        log("Paranoidal loader: cannot create presentation shell " .. expected)
        sync_disabled(r)
        return
    end
    replacement.health = old.health
    replacement.last_user = old.last_user
    replacement.combinator_description = old.combinator_description
    unregister(r)
    r.shell = replacement
    register(r)
    -- Let other mods track the swap; neither event reaches this module's own records.
    old.destroy { raise_destroy = true }
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
    script.raise_script_built { entity = replacement }
end

-- A script fast-replace (instant upgrades of Blueprint Sandboxes, Nanobots, Kruise Kontrol)
-- swaps the shell without a mined event, so the previous worker still occupies the tile.
-- Take over its settings, energy and contents, then free the tile for the new worker.
local function take_over_stale(shell)
    for _, machine in pairs(shell.surface.find_entities_filtered {
        type = "loader", position = shell.position, force = shell.force,
    }) do
        local r = defs.machines[machine.name] and record(machine)
        if r and r.machine == machine and not valid(r.shell) then
            local stale = {
                config = configuration(machine), energy = machine.energy,
                direction = machine.direction, contents = take_contents(machine),
            }
            close_viewers(r)
            unregister(r)
            machine.destroy { raise_destroy = true }
            return stale
        end
    end
end

local function report_failure(shell)
    local player = shell.last_user
    if player and player.valid and player.object_name == "LuaPlayer" and player.connected then
        player.create_local_flying_text {
            text = { "paranoidal-loader-message.cannot-create" }, position = shell.position,
        }
    end
end

attach = function(shell, config, existing, no_snap)
    local found = record(shell)
    if found then return found end
    local def = defs.shells[shell.name]
    if not def then return nil end
    clear_mirroring(shell)
    if type(config) ~= "table" then config = nil end
    local pending = state().pending[position_key(shell)]
    state().pending[position_key(shell)] = nil
    if pending and pending.tick == game.tick then config = config or pending.config else pending = nil end
    local stale = not existing and not pending and take_over_stale(shell) or nil
    if stale then config = config or stale.config end
    -- Scripts and robots keep the old direction; a player may place the item rotated.
    -- The same container end (also the opposite-mode sprite of the same loader) keeps
    -- everything; another end keeps the mode and settings but takes the new orientation.
    local direction = shell.direction
    if pending then
        local mode = (config and config.mode) or def.mode
        if shell.direction == pending.direction
            or container_side(def.mode, shell.direction) == container_side(mode, pending.direction) then
            direction = pending.direction
        else
            direction = container_side(def.mode, shell.direction)
            if mode ~= "input" then direction = (direction + 8) % 16 end
        end
    elseif stale then
        direction = stale.direction
    end
    local machine = existing or shell.surface.create_entity {
        name = def.machine, position = shell.position, direction = shell.direction,
        type = (config and config.mode) or def.mode, force = shell.force, quality = shell.quality,
        create_build_effect_smoke = false,
    }
    if not valid(machine) then
        -- Never crash the game: leave a plain shell that still mines back into its item.
        log("Paranoidal loader: cannot create native loader " .. def.machine .. " at " .. position_key(shell))
        if stale then put_contents(nil, stale.contents, shell) end
        if pending and pending.contents then put_contents(nil, pending.contents, shell) end
        report_failure(shell)
        return nil
    end
    machine.destructible = false
    machine.minable_flag = false
    machine.operable = true
    if not existing then
        configure(machine, config or { mode = def.mode }, direction)
        local energy = (pending and pending.energy) or (stale and stale.energy)
        if energy then machine.energy = math.min(energy, machine.electric_buffer_size) end
        if stale then put_contents(machine, stale.contents, shell) end
        if pending and pending.contents then put_contents(machine, pending.contents, shell) end
        if not config and not no_snap then snap(machine) end
    end
    local r = { shell = shell, machine = machine }
    register(r)
    if pending then restore_wires(shell, pending.wires) end
    connect_pair(r)
    replace_shell(r, true) -- also syncs disabled_by_script
    -- Belt-aware mods (Factorissimo connections, statistics) see the worker being built.
    if not existing then script.raise_script_built { entity = machine } end
    return r
end

local function wrap(machine)
    if record(machine) then return record(machine) end
    local shell = machine.surface.create_entity {
        name = defs.shell(machine.name, machine.loader_type), position = machine.position,
        direction = machine.direction, force = machine.force, quality = machine.quality,
        create_build_effect_smoke = false,
    }
    if not valid(shell) then
        log("Paranoidal loader: cannot wrap existing native loader " .. machine.name)
        return nil
    end
    shell.health = machine.health
    shell.last_user = machine.last_user
    local wires = external_wires(machine)
    local r = attach(shell, nil, machine, true)
    if not r then return nil end
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

-- Pure prototype cache (identical on every peer): names whose entities have no wire connectors.
local wireless = {}
local function built(event)
    local shell = event.entity
    if not valid(shell) then return end
    if defs.shells[shell.name] then
        attach(shell, event.tags and event.tags[TAG])
    elseif defs.machines[shell.name] then
        -- A script may explicitly create the native prototype rather than the placing shell.
        wrap(shell)
    elseif not wireless[shell.name] and next(state().shells) then
        -- A revived blueprint neighbour may bring a wire to an existing shell.
        local ok, connectors = pcall(shell.get_wire_connectors, false)
        if not ok then wireless[shell.name] = true; return end
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
                if valid(old) and old ~= destination then old.destroy { raise_destroy = true } end
                r.machine = destination
                destination.destructible = false; destination.minable_flag = false; destination.operable = true
                register(r); connect_pair(r); replace_shell(r, true)
                return
            end
        end
        -- Leave until the end of this tick: its shell clone may follow it.
        state().pending["clone:" .. destination.unit_number] = { tick = game.tick, clone = destination }
    end
end

local function update_status(r)
    if not (valid(r.shell) and valid(r.machine)) then return end
    local status = r.machine.status
    r.shell.custom_status = {
        diode = status == nil and defines.entity_status_diode.green
            or status_diodes[status] or defines.entity_status_diode.yellow,
        label = { "entity-status." .. (status_keys[status] or "working") },
    }
end

-- Planners list the input and output shells as two identical entries: see loader-planners.
local function extend_cursor_planner(player)
    if not (player and player.valid) then return end
    local stack = player.cursor_stack
    if stack and stack.valid_for_read then
        planners.extend(stack)
    elseif player.cursor_record then
        planners.extend(player.cursor_record)
    end
end

-- Mining by hand loses settings that the undo ghost would need: tag the undo action.
local function tag_undo(entry)
    local player = game.get_player(entry.player_index)
    if not (player and player.valid) then return end
    local stack = player.undo_redo_stack
    for i = 1, math.min(stack.get_undo_item_count(), 3) do
        for j, action in ipairs(stack.get_undo_item(i)) do
            local target = action.target
            if action.type == "removed-entity" and target and target.name == entry.name
                and (not action.surface_index or action.surface_index == entry.surface_index)
                and near(target.position, entry.position) and not (action.tags and action.tags[TAG]) then
                stack.set_undo_tag(i, j, TAG, entry.config)
                return
            end
        end
    end
end
local function undo_applied(e)
    local player = game.get_player(e.player_index)
    for _, action in ipairs(e.actions or {}) do
        local config = action.type == "removed-entity" and action.tags and action.tags[TAG]
        local target = action.target
        if type(config) == "table" and target and defs.shells[target.name] then
            local surface = game.get_surface(action.surface_index or (player and player.surface_index) or 1)
            if surface then
                for _, ghost in pairs(surface.find_entities_filtered { ghost_name = target.name, position = target.position }) do
                    local tags = ghost.tags or {}
                    tags[TAG] = config
                    ghost.tags = tags
                end
                -- Restored instantly (editor, cheat mode): configure the live worker.
                for _, shell in pairs(surface.find_entities_filtered { name = target.name, position = target.position }) do
                    local r = record(shell)
                    if r and valid(r.machine) then
                        configure(r.machine, config, r.machine.direction)
                        replace_shell(r, true)
                    end
                end
            end
        end
    end
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
-- A hand fast-replace announces itself with on_pre_build at the replaced position.
on(defines.events.on_pre_build, function(e)
    local s = state()
    s.pre_build = s.pre_build or {}
    s.pre_build[e.player_index] = { tick = e.tick, position = e.position }
end)
on(defines.events.on_player_mined_entity, function(e)
    local r = record(e.entity)
    if not r then return end
    local s = state()
    local p = s.pre_build and s.pre_build[e.player_index]
    local replacing = p and p.tick == e.tick and valid(r.shell) and near(p.position, r.shell.position)
    if not replacing and valid(r.shell) and valid(r.machine) then
        s.undo_queue = s.undo_queue or {}
        s.undo_queue[#s.undo_queue + 1] = {
            tick = e.tick, player_index = e.player_index, surface_index = r.shell.surface.index,
            name = r.shell.name, position = r.shell.position, config = configuration(r.machine),
        }
    end
    remove(r, e.buffer, true, false, replacing)
end)
on(defines.events.on_robot_mined_entity, function(e)
    local r = record(e.entity)
    if not r then return end
    -- A robot upgrade mines the old shell while its upgrade order is still set.
    remove(r, e.buffer, true, false, valid(r.shell) and r.shell.to_be_upgraded())
end)
on(defines.events.on_undo_applied, undo_applied)
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
        remove(r, nil, false, true)
        if valid(shell) and shell ~= e.entity then shell.destroy() end
    end
end)
-- A shell on the worker's tile that has no worker of its own.
local function unattached_shell(machine)
    for _, shell in pairs(machine.surface.find_entities_filtered {
        type = "constant-combinator", position = machine.position, force = machine.force,
    }) do
        if defs.shells[shell.name] and not record(shell) then return shell end
    end
end
on(defines.events.on_object_destroyed, function(e)
    local entry = state().registrations[e.registration_number]
    if not entry then return end
    local r = entry.record
    -- The shell was fast-replaced by a script without any built event:
    -- hand this worker's state over to the new shell instead of dropping it.
    if entry.kind == "shell" and valid(r.machine) then
        local orphan = unattached_shell(r.machine)
        if orphan and attach(orphan) then return end
    end
    local shell = r.shell
    remove(r, nil, false, true)
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
-- Flipping a combinator only toggles its mirrored sprite, or also reverses it when the
-- flip runs along its axis. A loader is symmetric across its axis: keep only the reversal,
-- with the same mode, so the container end moves exactly as in a flipped blueprint.
on(defines.events.on_player_flipped_entity, function(e)
    local r = record(e.entity)
    if not (r and valid(r.machine) and valid(r.shell)) then return end
    clear_mirroring(r.shell)
    if e.entity == r.shell and r.shell.direction ~= r.machine.direction then
        r.machine.direction = r.shell.direction
        r.machine.update_connections()
    end
    replace_shell(r)
end)
-- Rebuild the worker under its moved shell with the same settings, energy and belt items.
-- If it cannot stand there, it is rebuilt where it was; returns whether it followed.
local function relocate_worker(r)
    local old, shell = r.machine, r.shell
    local surface, from = old.surface, old.position
    local saved = {
        config = configuration(old), energy = old.energy, contents = take_contents(old),
        name = old.name, quality = old.quality, force = old.force, direction = old.direction,
    }
    close_viewers(r)
    unregister(r)
    old.destroy { raise_destroy = true }
    local function create(position, direction)
        return surface.create_entity {
            name = saved.name, position = position, direction = direction, type = saved.config.mode,
            force = saved.force, quality = saved.quality, create_build_effect_smoke = false,
        }
    end
    local direction = shell.direction
    local machine = create(shell.position, direction)
    local followed = valid(machine)
    if not followed then
        direction = saved.direction
        machine = create(from, direction)
    end
    if not valid(machine) then
        log("Paranoidal loader: worker lost while moving its shell")
        put_contents(nil, saved.contents, { surface = surface, position = from, force = saved.force })
        return false
    end
    machine.destructible = false
    machine.minable_flag = false
    machine.operable = true
    configure(machine, saved.config, direction)
    machine.energy = math.min(saved.energy, machine.electric_buffer_size)
    put_contents(machine, saved.contents, machine)
    r.machine = machine
    register(r)
    connect_pair(r)
    sync_disabled(r)
    script.raise_script_built { entity = machine }
    return followed
end
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
        -- The engine never teleports belt-connectable entities: a moved shell gets its
        -- worker rebuilt at the new place instead.
        if not other.teleport(moved.position) and not (moved == r.shell and relocate_worker(r)) then
            if not moved.teleport(e.old_position) then
                log("Paranoidal loader: paired teleport and rollback both refused")
                return
            end
            log("Paranoidal loader: rejected an unsupported paired teleport")
            -- A rotate-and-move (dollies) may have turned the shell: follow the worker again.
            if valid(r.machine) and record(r.machine) == r then replace_shell(r) end
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
        replace_shell(destination, true); connect_pair(destination)
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
    if e.item then planners.extend(e.item) end
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
local function stop_wiring(index)
    local w = wiring()
    for _, r in pairs(w[index] or {}) do sync_link(r) end
    w[index] = nil
end
on(defines.events.on_player_cursor_stack_changed, function(e)
    local player = game.get_player(e.player_index)
    local stack = player and player.cursor_stack
    local w = wiring()
    if stack and stack.valid_for_read and circuit_wires[stack.name] then
        w[e.player_index] = w[e.player_index] or {}
    elseif w[e.player_index] then
        stop_wiring(e.player_index)
    end
    extend_cursor_planner(player)
end)
-- A player who leaves keeps nothing watched or viewed.
for _, event in ipairs({ defines.events.on_player_left_game, defines.events.on_player_removed }) do
    on(event, function(e)
        stop_wiring(e.player_index)
        state().viewers[e.player_index] = nil
        local s = state()
        if s.pre_build then s.pre_build[e.player_index] = nil end
    end)
end
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
    if s.replace_queue and next(s.replace_queue) then
        local queue = s.replace_queue
        s.replace_queue = {}
        for id, r in pairs(queue) do
            if s.shells[id] == r then replace_shell(r) end
        end
    end
    if s.undo_queue and #s.undo_queue > 0 then
        local queue = s.undo_queue
        s.undo_queue = {}
        for _, entry in ipairs(queue) do
            local ok, err = pcall(tag_undo, entry)
            if not ok then log("Paranoidal loader: undo tag failed: " .. tostring(err)) end
        end
    end
    for key, pending in pairs(s.pending) do
        if pending.tick < e.tick then
            s.pending[key] = nil
            if valid(pending.clone) and not record(pending.clone) then wrap(pending.clone) end
            -- An upgrade that never arrived: its belt items are not lost.
            if pending.contents then put_contents(nil, pending.contents, pending) end
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
