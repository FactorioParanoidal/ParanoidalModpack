local table = require("lib.table")

maraxsis.on_event(maraxsis.events.on_init(), function()
    storage.duct_exhausts = storage.duct_exhausts or {}
end)

local SUPERCRITICAL_STEAM_ALLOW_LIST = table.invert {
    "duct-small",
    "duct",
    "duct-long",
    "duct-t-junction",
    "duct-curve",
    "duct-cross",
    "duct-intake",
    "duct-exhaust",
    "duct-underground",
    "maraxsis-trench-duct",
    "maraxsis-trench-duct-lower",
    "maraxsis-oversized-steam-turbine",
    "maraxsis-geothermal-generator",
    "maraxsis-hydro-plant-extra-module-slots",
    "cryogenic-plant",
    "infinity-pipe",
}

local function explode(entity)
    if SUPERCRITICAL_STEAM_ALLOW_LIST[entity.name] then
        return false
    end

    if entity.get_fluid_count("maraxsis-supercritical-steam") == 0 then
        return false
    end

    local position = entity.position
    local force = entity.force_index
    local name = entity.name
    local type = entity.type
    local surface = entity.surface
    entity.die()

    for _, ghost in pairs(
        surface.find_entities_filtered {
            position = position,
            ghost_type = type,
            ghost_name = name,
            force = force
        }
    ) do
        ghost.destroy()
    end

    return true
end

maraxsis.on_nth_tick(597, function()
    for unit_number, duct_exhaust in pairs(storage.duct_exhausts) do
        if not duct_exhaust.valid then
            storage.duct_exhausts[unit_number] = nil
            goto continue
        end

        if duct_exhaust.get_fluid_count("maraxsis-supercritical-steam") == 0 then
            goto continue
        end

        local found = false
        for _, neighbours in pairs(duct_exhaust.fluidbox_neighbours) do
            for _, neighbour in pairs(neighbours) do
                if explode(neighbour) then
                    found = true
                end
            end
        end

        assert(duct_exhaust.valid)

        if found then
            for _, neighbour in pairs(duct_exhaust.surface.find_entities_filtered {
                type = { "pipe", "pump", "storage-tank", "pipe-to-ground", "assembling-machine", "furnace", "generator", "boiler" },
                force = duct_exhaust.force_index
            }) do
                explode(neighbour)
            end
            return
        end

        ::continue::
    end
end)

local function add_to_duct_exhaust_list(event)
    local entity = event.entity
    if not entity.valid then return end

    if entity.name == "duct-exhaust" or entity.name == "maraxsis-hydro-plant-extra-module-slots" then
        storage.duct_exhausts[entity.unit_number] = entity
    end
end
maraxsis.on_event("PlanetsLib-on-entity-replaced", add_to_duct_exhaust_list)
maraxsis.on_event(maraxsis.events.on_built(), add_to_duct_exhaust_list)
