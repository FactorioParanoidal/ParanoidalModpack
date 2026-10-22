------------------------------------------------------------------------------------
-- Compound entities: a base entity with hidden helper entities (poles, solar panels,
-- lamps, radars) that are created, registered and removed together with the base.
-- storage[<tab>][base.unit_number] = {base = LuaEntity, <hidden key> = LuaEntity, ...}
------------------------------------------------------------------------------------
local M = {}

-- Handles under which hidden entities may be stored in a table entry next to "base".
local HIDDEN_KEYS = {}
for key in pairs(BioInd.HE_map) do
    HIDDEN_KEYS[#HIDDEN_KEYS + 1] = key
end
table.sort(HIDDEN_KEYS)

-- Runtime list: the compound entities whose base prototype exists, each with only the
-- hidden entities whose prototypes exist (e.g. no garden pole while "Easy gardens" is
-- off). It depends on prototypes only, so it is built when control.lua is loaded and is
-- identical on every client.
local compounds = {}
for name, data in pairs(BioInd.compound_entities) do
    if data.base and data.base.name and prototypes.entity[data.base.name] then
        local copy = table.deepcopy(data)
        for key, hidden in pairs(copy.hidden) do
            if not (hidden.name and prototypes.entity[hidden.name]) then
                copy.hidden[key] = nil
            end
        end
        compounds[name] = copy
    end
end
M.compounds = compounds

-- Overlays (e.g. the terraformer area preview) are replaced by their real base entity
-- when built; they never get hidden entities.
local function is_overlay(name, data)
    return data.new_base_name and data.new_base_name ~= name
end

-- Sorted names of all compound entities, overlays included (event filters).
M.names = {}
for name in pairs(compounds) do
    M.names[#M.names + 1] = name
end
table.sort(M.names)

local arboretum = compounds["bi-arboretum"]
M.arboretum_radar = arboretum and arboretum.hidden.radar and arboretum.hidden.radar.name

local garden = compounds["bi-bio-garden"]
local garden_pole = garden and garden.hidden.pole and garden.hidden.pole.name


------------------------------------------------------------------------------------
-- "Easy gardens": the hidden garden pole connects to these poles
local garden_connectors
function M.get_garden_connectors()
    if not garden_connectors then
        garden_connectors = {}
        if garden_pole then
            local poles = prototypes.get_entity_filtered({ { filter = "type", type = "electric-pole" } })
            for name in pairs(poles) do
                if name ~= garden_pole and name ~= "bi-musk-mat-hidden-pole" then
                    garden_connectors[#garden_connectors + 1] = name
                end
            end
        end
    end
    return garden_connectors
end

local function connect_garden_pole(pole)
    local own = pole.get_wire_connector(defines.wire_connector_id.pole_copper, true)
    if not own then
        return
    end
    own.disconnect_all()

    local reach = pole.prototype.get_max_wire_distance(pole.quality)
    local unit_number = pole.unit_number
    -- A pole has a limited number of connections: other hidden garden poles first.
    for _, names in ipairs({ { garden_pole }, M.get_garden_connectors() }) do
        if names[1] then
            local neighbours = pole.surface.find_entities_filtered({
                position = pole.position,
                radius = reach,
                type = "electric-pole",
                name = names,
            })
            for _, neighbour in pairs(neighbours) do
                if neighbour.unit_number ~= unit_number then
                    local target = neighbour.get_wire_connector(defines.wire_connector_id.pole_copper, true)
                    if target then
                        own.connect_to(target, false)
                    end
                end
            end
        end
    end
end


------------------------------------------------------------------------------------
-- Hidden entities
------------------------------------------------------------------------------------
local function hidden_position(base, hidden)
    local position = base.position
    local offset = hidden.base_offset
    if offset then
        return { x = position.x + (offset.x or offset[1]), y = position.y + (offset.y or offset[2]) }
    end
    return position
end

-- Things a hidden entity needs once it belongs to its base.
local function attach(base, key, entity)
    if key == "radar" and entity.name == M.arboretum_radar then
        local map = storage.bi_arboretum_radar_table
        if not map then
            map = {}
            storage.bi_arboretum_radar_table = map
        end
        map[entity.unit_number] = base.unit_number
        entity.backer_name = ""
    elseif key == "pole" and entity.name == garden_pole then
        connect_garden_pole(entity)
    end
end

local function create_hidden(base, key, hidden)
    local entity = base.surface.create_entity({
        name = hidden.name,
        position = hidden_position(base, hidden),
        force = base.force,
    })
    if not entity then
        return
    end
    entity.minable = false
    entity.destructible = false
    attach(base, key, entity)
    -- Other mods learn about the new entity as before (base_entity is extra data).
    script.raise_event(defines.events.script_raised_built, { entity = entity, base_entity = base })
    return entity
end

-- Hidden entities at their place. Searched by centre: their collision box is empty.
local function hidden_at(base, hidden)
    return base.surface.find_entities_filtered({
        name = hidden.name,
        position = hidden_position(base, hidden),
        radius = 0.01,
    })
end

-- An existing hidden entity at its place (lost table reference, unregistered base).
-- Duplicates of the same hidden entity are removed.
local function find_hidden(base, hidden)
    local found = hidden_at(base, hidden)
    for i = 2, #found do
        found[i].destroy({ raise_destroy = true })
    end
    return found[1]
end

-- Table entry that owns a hidden entity (only searched when one is found at the place
-- of a new building, i.e. when a building has been replaced).
local function owner_of(tab, entity)
    local id = entity.unit_number
    for unit_number, entry in pairs(tab) do
        for _, key in ipairs(HIDDEN_KEYS) do
            local hidden = entry[key]
            if hidden and hidden.valid and hidden.unit_number == id then
                return unit_number, entry
            end
        end
    end
end

-- A building replaced by a script (fast replace by Nanobots, Blueprint Sandboxes etc.)
-- disappears without an event and leaves its hidden entities behind. The new building
-- takes them over; hidden entities of a building that still stands are left alone.
local function left_over(base, compound, tab)
    local found
    for key, hidden in pairs(compound.hidden) do
        for _, entity in ipairs(hidden_at(base, hidden)) do
            local unit_number, entry = owner_of(tab, entity)
            if not (entry and entry.base and entry.base.valid) then
                if unit_number then
                    tab[unit_number] = nil
                end
                found = found or {}
                if found[key] then
                    entity.destroy({ raise_destroy = true })
                else
                    found[key] = entity
                end
            end
        end
    end
    return found
end

local function destroy_hidden(entry)
    for _, key in ipairs(HIDDEN_KEYS) do
        local hidden = entry[key]
        if hidden then
            if hidden.valid then
                if key == "radar" and storage.bi_arboretum_radar_table then
                    storage.bi_arboretum_radar_table[hidden.unit_number] = nil
                end
                hidden.destroy({ raise_destroy = true })
            end
            entry[key] = nil
        end
    end
end


------------------------------------------------------------------------------------
-- Register a base entity and make sure it has all hidden entities.
-- adopt: true to reuse hidden entities found at their place instead of creating new
-- ones, or a table {key = entity} of hidden entities to reuse.
-- Returns the table entry and the number of hidden entities created or adopted.
function M.register(base, adopt)
    local compound = compounds[base.name]
    if not compound then
        return
    end
    local tab = storage[compound.tab]
    if not tab then
        tab = {}
        storage[compound.tab] = tab
    end
    local unit_number = base.unit_number
    local entry = tab[unit_number]
    if not entry then
        entry = {}
        tab[unit_number] = entry
    end
    entry.base = base

    local added = 0
    for key, hidden in pairs(compound.hidden) do
        local entity = entry[key]
        if not (entity and entity.valid) then
            if type(adopt) == "table" then
                entity = adopt[key]
            elseif adopt then
                entity = find_hidden(base, hidden)
            else
                entity = nil
            end
            if entity then
                attach(base, key, entity)
            else
                entity = create_hidden(base, key, hidden)
            end
            entry[key] = entity
            added = added + 1
        end
    end

    for key, value in pairs(compound.optional or {}) do
        if entry[key] == nil then
            entry[key] = value
        end
    end
    return entry, added
end


------------------------------------------------------------------------------------
-- A compound entity has been built
function M.built(entity)
    local name = entity.name
    local compound = compounds[name]
    local new_name = compound.new_base_name

    if new_name and new_name ~= name then
        -- Overlay: replace it with the real base entity. Building that one raises its
        -- own event, which creates the hidden entities.
        local new_base = entity.surface.create_entity({
            name = new_name,
            position = entity.position,
            direction = entity.direction,
            force = entity.force,
            quality = entity.quality,
            raise_built = true,
        })
        if new_base then
            if new_base.valid then
                new_base.health = entity.health
            end
            entity.destroy({ raise_destroy = true })
        end
        return
    end

    local tab = storage[compound.tab]
    M.register(entity, tab and left_over(entity, compound, tab) or false)
end


------------------------------------------------------------------------------------
-- A compound entity is being mined, has died or was destroyed by a script
function M.removed(entity)
    local tab = storage[compounds[entity.name].tab]
    local unit_number = entity.unit_number
    local entry = tab and unit_number and tab[unit_number]
    if entry then
        tab[unit_number] = nil
        destroy_hidden(entry)
    end
end


------------------------------------------------------------------------------------
-- Terraformer and its radar share their health
function M.damaged(event)
    local entity = event.entity
    if not (entity and entity.valid) or event.final_damage_amount == 0 or event.final_health <= 0 then
        return
    end
    local tab = storage.bi_arboretum_table
    if not tab then
        return
    end

    local associated
    if entity.name == "bi-arboretum" then
        local entry = tab[entity.unit_number]
        associated = entry and entry.radar
    else
        local map = storage.bi_arboretum_radar_table
        local base_id = map and map[entity.unit_number]
        local entry = base_id and tab[base_id]
        associated = entry and entry.base
    end

    if associated and associated.valid then
        associated.health = event.final_health
    end
end


------------------------------------------------------------------------------------
-- on_init / on_configuration_changed / migration: bring the tables in line with the
-- prototypes and the map. Idempotent.
function M.setup_storage()
    local stats = { removed = 0, restored = 0, registered = {} }

    -- Tables used by the compound entities of this game
    local used = {}
    for _, compound in pairs(compounds) do
        used[compound.tab] = true
        storage[compound.tab] = storage[compound.tab] or {}
        for _, tab in ipairs(compound.add_global_tables or {}) do
            used[tab] = true
            storage[tab] = storage[tab] or {}
        end
        for var_name, value in pairs(compound.add_global_values or {}) do
            used[var_name] = true
            if storage[var_name] == nil then
                storage[var_name] = value
            end
        end
    end

    -- Remove the tables of compound entities that no longer exist. A table shared with
    -- an existing entity (overlays, farm tiers) is kept.
    for _, compound in pairs(BioInd.compound_entities) do
        if compound.tab and not used[compound.tab] then
            storage[compound.tab] = nil
        end
        for _, tab in ipairs(compound.add_global_tables or {}) do
            if not used[tab] then
                storage[tab] = nil
            end
        end
        for var_name in pairs(compound.add_global_values or {}) do
            if not used[var_name] then
                storage[var_name] = nil
            end
        end
    end

    -- Drop entries without a valid base (and their hidden entities); restore missing
    -- hidden entities of the others.
    local checked = {}
    for _, compound in pairs(compounds) do
        local tab_name = compound.tab
        if not checked[tab_name] then
            checked[tab_name] = true
            local tab = storage[tab_name]
            for unit_number, entry in pairs(tab) do
                local base = entry.base
                if base and base.valid and compounds[base.name] and not is_overlay(base.name, compounds[base.name]) then
                    local _, added = M.register(base, true)
                    stats.restored = stats.restored + added
                else
                    destroy_hidden(entry)
                    tab[unit_number] = nil
                    stats.removed = stats.removed + 1
                end
            end
        end
    end

    -- Register bases missing from the tables: one search per surface for all names.
    local names = {}
    for _, name in ipairs(M.names) do
        if not is_overlay(name, compounds[name]) then
            names[#names + 1] = name
        end
    end
    if names[1] then
        for _, surface in pairs(game.surfaces) do
            for _, base in pairs(surface.find_entities_filtered({ name = names })) do
                local name = base.name
                if not storage[compounds[name].tab][base.unit_number] then
                    M.register(base, true)
                    stats.registered[name] = (stats.registered[name] or 0) + 1
                end
            end
        end
    end

    -- The radar map follows the terraformer table.
    if storage.bi_arboretum_table and arboretum then
        local map = {}
        for unit_number, entry in pairs(storage.bi_arboretum_table) do
            local radar = entry.radar
            if radar and radar.valid then
                map[radar.unit_number] = unit_number
            end
        end
        storage.bi_arboretum_radar_table = map
    end

    return stats
end

return M
