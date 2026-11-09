-- "Even Pickier Dollies" (EPD) compatibility.
--
-- Muluna's compound machines are two overlapping entities: the machine the player
-- places and a script-created helper (a reactor, a constant-combinator or a
-- roboport). EPD moves only the entity it has selected, leaving the helper behind.
-- It also refuses to move at all when the helper (which shares the machine's
-- collision box) is inside the destination box.
--
-- The matching prototype changes live in the files that build the compounds
-- (heat-assembling-machine-final-fix.lua, telescope-prototype.lua and
-- burner-roboports.lua): the helper is made non-colliding, and the player-placed
-- machine is guaranteed to be the entity EPD selects.
--
-- This module subscribes to EPD's `even-pickier-dollies-on-entity-moved` custom
-- event and teleports the helper to keep it on top of the entity that was moved.

local muluna_constants = Muluna.constants

-- Every member entity name of a compound -> its partner entity name, and -> the
-- name of the entity that must stay on top (the player-placed machine).
local partner_by_name = {}
local top_by_name = {}

local function register_pair(top_name, helper_name)
    if not (top_name and helper_name) then return end
    partner_by_name[top_name] = helper_name
    partner_by_name[helper_name] = top_name
    top_by_name[top_name] = top_name
    top_by_name[helper_name] = top_name
end

for _,machine in pairs(muluna_constants.heat_assembling_machines or {}) do
    register_pair(machine["assembling-machine"], machine["reactor"])
end
for _,telescope in pairs(muluna_constants.telescopes or {}) do
    register_pair(telescope["assembling-machine"], telescope["constant-combinator"])
end
for _,roboport in pairs(muluna_constants.vacuum_roboports or {}) do
    register_pair(roboport["refueler"], roboport["roboport"])
end

local function move_entity_to_bottom_layer(entity)

    entity.rotate{reverse=false}
    entity.rotate{reverse=true}
end

---@param event epd.Event
local function on_dolly_moved_entity(event)
    local moved = event.moved_entity
    if not (moved and moved.valid) then return end

    local partner_name = partner_by_name[moved.name]
    if not partner_name then return end
    local start_pos = event.start_pos
    if not start_pos then return end

    -- EPD raises this event for rotations too; a rotation does not translate the
    -- entity, so there is nothing to do.
    local dx = moved.position.x - start_pos.x
    local dy = moved.position.y - start_pos.y
    if dx == 0 and dy == 0 then return end

    -- The partner is still sitting where the moved entity started.
    local partner = moved.surface.find_entity(partner_name, start_pos)
    if not (partner and partner.valid) then return end

    local position = partner.position
    partner.teleport(
        {x = position.x + dx, y = position.y + dy},
        nil, -- Same surface.
        false, -- Do not raise script_raised_teleported.
        false, -- Use the exact position instead of re-snapping to the grid.
        defines.build_check_type.script -- Ignore collisions so it can overlap the moved entity.
    )

    -- Reconnect anything that was linked to either entity before the move.
    partner.update_connections()
    moved.update_connections()

    -- Teleporting can change draw order; keep the player-placed machine on top.
    local top_name = top_by_name[moved.name]
    if top_name then
        local top = (moved.name == top_name) and moved or partner
        if top.valid then
            move_entity_to_bottom_layer(top)
        end
    end
end

-- EPD 3.2.0+ exposes the move event as the custom event
-- `even-pickier-dollies-on-entity-moved`, so it can be registered by name during
-- control-stage loading without calling the remote interface. `mods` only exists
-- in the data stage, so use `script.active_mods` here.
local function register_epd_event()
    if not script.active_mods["even-pickier-dollies"] then return end
    if not remote.interfaces["PickerDollies"] then return end
    Muluna.events.on_event("even-pickier-dollies-on-entity-moved", on_dolly_moved_entity)
end

register_epd_event()
