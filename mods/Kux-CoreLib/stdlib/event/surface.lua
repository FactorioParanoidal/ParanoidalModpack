local Event = require('__Kux-CoreLib__/stdlib/event/event')

--- Surface storage creation.
-- <p>All surfaces will be added to the `storage.surfaces` table.
-- <p>This modules events should be registered after any other Init functions but before any scripts needing `storage.surfaces`.
-- <p>This modules can register the following events:
--- @class StdLib.Event.Surface
--- @usage
--- local surface = require('__Kux-CoreLib__/stdlib/event/surface').register_events()
local Surface = {
    __class = 'Surface',
    _new_surface_data = {}
}
setmetatable(Surface, require('__Kux-CoreLib__/stdlib/core'))
local inspect = _ENV.inspect

local merge_additional_data = require('__Kux-CoreLib__/stdlib/event/modules/merge_data')

local function new(index)
    local surface = game.surfaces[index]
    local sdata = {
        index = surface.index,
        name = surface.name,
    }

    merge_additional_data(Surface._new_surface_data, sdata)
    return sdata
end

function Surface.additional_data(...)
    for _, func_or_table in pairs { ... } do
        local typeof = type(func_or_table)
        assert(typeof == 'table' or typeof == 'string', 'Must be table or function')
        Surface._new_surface_data[#Surface._new_surface_data + 1] = func_or_table
    end
    return Surface
end

--- Remove data for a surface when it is deleted.
--- @param event table event table containing the surface index
function Surface.remove(event)
    storage.surfaces[event.surface_index] = nil
end

function Surface.rename(event)
    storage.surfaces[event.surface_index].name = event.new_name
end

function Surface.import(event)
    new(event.surface_index)
end

-- function Surface.cleared(event)
-- end

--- Init or re-init the surfaces.
-- Passing a `nil` event will iterate all existing surfaces.
--- @param event nil|number|table|string|LuaSurface [opt]
--- @param overwrite boolean? [opt=false] the surface data
function Surface.init(event, overwrite)
    -- Create the storage.surfaces table if it doesn't exisit
    storage.surfaces = storage.surfaces or {}

    --get a valid surface object or nil
    local surface = event and game.surfaces[event.surface_index] or nil

    if surface then
        if not storage.surfaces[surface.index] or (storage.surfaces[surface.index] and overwrite) then
            storage.surfaces[surface.index] = new(surface.index)
            return storage.surfaces[surface.index]
        end
    else --Check all surfaces
        for index in pairs(game.surfaces) do
            if not storage.surfaces[index] or (storage.surfaces[index] and overwrite) then
                storage.surfaces[index] = new(index)
            end
        end
    end
    return Surface
end

function Surface.dump_data()
    helpers.write_file(script.mod_name .. '/Surface/surface_data.lua', inspect(Surface._new_surface_data, { longkeys = true, arraykeys = true }))
    helpers.write_file(script.mod_name .. '/Surface/storage.lua', inspect(storage.surfaces or nil, { longkeys = true, arraykeys = true }))
end

function Surface.register_init()
    Event.register(Event.core_events.init, Surface.init)
    return Surface
end

function Surface.register_events(do_on_init)
    Event.register(defines.events.on_surface_created, Surface.init)
    Event.register(defines.events.on_surface_deleted, Surface.remove)
    Event.register(defines.events.on_surface_imported, Surface.import)
    Event.register(defines.events.on_surface_renamed, Surface.rename)
    --Event.register(defines.events.on_surface_cleared, Surface.func)
    if do_on_init then
        Surface.register_init()
    end
    return Surface
end

return Surface
