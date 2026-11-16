-- Paranoidal: up to 9.12.0 this mod was named factorissimo-2-notnotmelon; since 9.20.0 it is Paranoidal-factorissimo-4.
-- Factorio keeps a mod's storage under the mod name, so in a save made before the rename every factory (interiors,
-- connections, packed factories, names, dispatcher) is in the storage of the mod factorissimo-2-notnotmelon, now a
-- bridge without content (mods/factorissimo-2-notnotmelon). Without it this mod would start empty and every factory
-- building would lose its interior.
--   on_init: the bridge's storage is already restored (probe on 2.1.24); it is taken over as it is, before any other
--     initialization handler of this mod, which then run on it as on a configuration change.
--   on_configuration_changed (raised in the same load, as this mod is new): the bridge is emptied and removes its GUI
--     elements and render objects (writes to the bridge's storage during this on_init would be overwritten when it is
--     restored before the bridge's on_load); the dispatcher button and windows are then rebuilt by this mod, and at
--     the end of the chain the persistent render objects (names, overlay icons, port markers, planet icons) are redrawn.
-- Migrations of this mod run after on_init, so the migrations of factorissimo-2-notnotmelon (already applied to such
-- saves under the old name) are not part of this mod.

local LEGACY_BRIDGE = "factorissimo-2-notnotmelon-save-bridge"
local redraw_pending = false -- not saved: set and used within the on_configuration_changed of the transferring load

local function take_over_legacy_storage()
    local bridge = remote.interfaces[LEGACY_BRIDGE]
    if not (bridge and bridge.take) then return false end
    local legacy = remote.call(LEGACY_BRIDGE, "take")
    if type(legacy) ~= "table" or type(legacy.factories) ~= "table" then return false end
    for key, value in pairs(legacy) do
        storage[key] = value
    end
    storage.release_legacy_bridge = true
    log("Paranoidal-factorissimo-4: Factorissimo state of factorissimo-2-notnotmelon taken over: "
        .. table_size(storage.factories) .. " factories, " .. table_size(storage.saved_factories or {}) .. " packed")
    return true
end

--- A save with factory floors but nothing to take over: the bridge is disabled or missing.
local function warn_if_factories_lost()
    for _, surface in pairs(game.surfaces) do
        if surface.name:find("%-factory%-floor$") then
            log("Paranoidal-factorissimo-4: factory floor " .. surface.name .. " exists, but the save bridge factorissimo-2-notnotmelon has no state")
            game.print({"factory-legacy-bridge-missing"}, {color = {r = 1, g = 0.3, b = 0.3}})
            return
        end
    end
end

local function release_legacy_bridge()
    storage.release_legacy_bridge = nil
    local bridge = remote.interfaces[LEGACY_BRIDGE]
    if bridge and bridge.release then remote.call(LEGACY_BRIDGE, "release") end
    -- The bridge removed the old dispatcher window and the preview frames.
    if storage.dispatch then storage.dispatch.open = {} end
    storage.fancy_preview_active = {}
    redraw_pending = true
end

-- First initialization handler of this mod (control.lua requires this file right after the library).
-- `event` is nil in on_init and the ConfigurationChangedData in on_configuration_changed.
factorissimo.on_event(factorissimo.events.on_init(), function(event)
    if event == nil then
        if storage.factories == nil and not take_over_legacy_storage() then warn_if_factories_lost() end
    elseif storage.release_legacy_bridge then
        release_legacy_bridge()
    end
end)

--- Last initialization handler (registered at the end of control.lua): the render objects of the bridge are gone.
function factorissimo.redraw_after_legacy_transfer()
    if not redraw_pending then return end
    redraw_pending = false
    local count = 0
    for _, factory in pairs(storage.factories) do
        factory.name_labels = nil
        factory.outside_overlay_displays = {}
        factory.overlay_signature = nil
        local markers = factory.outside_port_markers
        factory.outside_port_markers = {}
        if factory.layout then
            local building = factory.building
            if factory.built and building and building.valid then
                factorissimo.update_overlay(factory)
                if markers and markers[1] then factorissimo.toggle_port_markers(factory) end
            end
            -- Checked before the labels: drawing them creates a missing pole, which draws its own icon.
            local pole = factory._inside_power_pole
            local had_pole = pole and pole.valid and factory.inside_surface and factory.inside_surface.valid
            if factory.name then factorissimo.update_name_labels(factory) end
            if had_pole then factorissimo.draw_planet_icon_on_inside_power_pole(factory) end
        end
        count = count + 1
    end
    log("Paranoidal-factorissimo-4: render objects redrawn for " .. count .. " factories after the save transfer")
end
