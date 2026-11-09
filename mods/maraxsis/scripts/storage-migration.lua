local SOURCE_MOD = "maraxsis-classic"

maraxsis.on_event(maraxsis.events.on_init(), function(event)
    -- make sure this event only runs on_init (first load)
    -- on_init does not return any event data
    if event then return end

    -- check for migrated storage data from our pre-defined source mod
    local migrated = storage._migrated and storage._migrated[SOURCE_MOD]
    if not migrated then return end

    -- then assign all of their storage data into our own storage table
    for key, value in pairs(migrated) do
        -- ignore migration data inherited from the source mod (no loops)
        if key ~= "_migrated" then
            storage[key] = value
        end
    end

    log("Maraxsis migration: transferred runtime storage from Maraxsis Classic")
end)

-- Maraxsis 1.32.0 was the first version made for Factorio 2.1.
local FIRST_21_VERSION = "1.32.0"

maraxsis.on_event(maraxsis.events.on_init(), function(event)
    -- on_init means this is a brand new save, so there is nothing to warn about
    if not event then return end

    local mod_changes = event.mod_changes or {}

    -- Saves made with Maraxsis 2.0 have an old version below 1.32.0.
    local maraxsis_change = mod_changes["maraxsis"]
    local updated_from_20 = maraxsis_change
        and maraxsis_change.old_version
        and helpers.compare_versions(maraxsis_change.old_version, FIRST_21_VERSION) < 0

    -- Saves migrated from Maraxsis Classic also predate the modern build.
    local classic_change = mod_changes["maraxsis-classic"]
    local migrated_from_classic = classic_change and classic_change.old_version

    if not (updated_from_20 or migrated_from_classic) then return end

    game.print({ "console.maraxsis-2-1-message" })
end)
