local library = require("__PlanetsLib__.lib.lib")


local libraries = {}
local filters = {}

local composite_event_handlers = {}

local setup_ran = false

local register_remote_interfaces = function()
    --Sometimes, in special cases, on_init and on_load can be run at the same time. Only register events once in this case.
    if setup_ran then return end
    setup_ran = true

    local global_interface = {}
    local added_to_global_interface = false
    for lib_name, lib in pairs(libraries) do
        if lib.add_to_remote_interface then
            lib.add_to_remote_interface(global_interface)
            added_to_global_interface= true
        end
        if lib.add_remote_interface then
            lib.add_remote_interface()
        end

        if lib.add_commands then
            lib.add_commands()
        end
    end
    if added_to_global_interface then
        remote.add_interface(script.mod_name,global_interface)
    end
end

local function add_lib(lib)
    for k, current in ipairs(libraries) do
        if current == lib then
            error("Trying to register same lib twice")
        end
    end
    table.insert(libraries, lib)
end



local check_handler = function(id, handler, oldhandler)
    if oldhandler then
        local oldinfo = debug.getinfo(oldhandler, "S")
        local newinfo = debug.getinfo(handler, "S")
        log(string.format(
            "duplicate handlers within module for event %s: first defined at %s:%d, replaced by redefinition at %s:%d",
            library.event_name(id), oldinfo.short_src, oldinfo.linedefined, newinfo.short_src, newinfo.linedefined))
    end
end

local register_events = function()
    local all_events = {}
    local on_nth_tick = {}

    -- handle composite event handlers.
    for lib_name, lib in pairs(libraries) do
        local composite_lib = {
            events = {}
        }
        local do_add = false

        if not lib.composite_events then
            goto continue
        end

        local composite_events = lib.composite_events

        for _, event_handler in ipairs(composite_event_handlers) do
            if composite_events[event_handler.name] then
                for _, value in ipairs(event_handler.events) do
                    if event_handler.handlers and event_handler.handlers[value] then
                        composite_lib.events[value] = event_handler.handlers[value](composite_events
                            [event_handler.name])
                    else
                        composite_lib.events[value] = composite_events[event_handler.name]
                    end
                end
                do_add = true
            end
        end
        if do_add then
            table.insert(libraries, composite_lib)
        end
        ::continue::
    end

    for lib_name, lib in ipairs(libraries) do
        if lib.events then
            for k, handler in pairs(lib.events) do
                -- if different modules refer to the same event different ways
                -- (string, defines, CustomEvent/CustomInput protos), unify them to ids for registration...
                local id = script.get_event_id(k)
                all_events[id] = all_events[id] or {}

                -- if a *single* module refers to the same event different ways, error...
                local oldhandler = all_events[id][lib_name]
                check_handler(id, handler, oldhandler)
                all_events[id][lib_name] = handler
            end
        end

        if lib.on_nth_tick then
            for n, handler in pairs(lib.on_nth_tick) do
                on_nth_tick[n] = on_nth_tick[n] or {}
                on_nth_tick[n][lib_name] = handler
            end
        end
    end

    for event, handlers in pairs(all_events) do
        local action = function(event)
            for k, handler in pairs(handlers) do
                handler(event)
            end
        end
        if filters[event] then
            script.on_event(event, action, filters[event])
        else
            script.on_event(event, action)
        end
    end

    for n, handlers in pairs(on_nth_tick) do
        local action = function(event)
            for k, handler in pairs(handlers) do
                handler(event)
            end
        end
        script.on_nth_tick(n, action)
    end
end

script.on_init(function()
    register_remote_interfaces()
    register_events()
    for k, lib in pairs(libraries) do
        if lib.on_init then
            lib.on_init()
        end
    end
end)

script.on_load(function()
    register_remote_interfaces()
    register_events()
    for k, lib in pairs(libraries) do
        if lib.on_load then
            lib.on_load()
        end
    end
end)

script.on_configuration_changed(function(data)
    for k, lib in pairs(libraries) do
        if lib.on_configuration_changed then
            lib.on_configuration_changed(data)
        end
    end
end)

local handler = {}

local function register_filter(event, filter)
    if event == nil then
        return
    end
    local event_filters = filters[event]
    if not event_filters then
        event_filters = {}
        filters[event] = event_filters
    end

    -- prevent duplicate filters from being added.
    -- don't need to crash the process
    for _, value in ipairs(event_filters) do
        if value == filter then
            return
        end
    end
    table.insert(event_filters, filter)
end

handler.add_composite_event = function(handler)
    table.insert(composite_event_handlers, handler)
end

handler.add_composite_events = function(handlers)
    for _, handler in ipairs(handlers) do
        table.insert(composite_event_handlers, handler)
    end
end

handler.add_filter = function(event, filter)
    for _, value in ipairs(composite_event_handlers) do
        if event == value.name then
            for _, actual_event in ipairs(value.events) do
                register_filter(actual_event, filter)
            end
            return
        end
    end
    register_filter(event.filter)
end


handler.add_filters = function(event, filters)
    for _, value in ipairs(composite_event_handlers) do
        if event == value.name then
            for _, actual_event in ipairs(value.events) do
                for _, filter in ipairs(filters) do
                    register_filter(actual_event, filter)
                end
            end
            return
        end
    end
    for _, filter in ipairs(filters) do
        register_filter(event, filter)
    end
end

handler.add_lib = function(lib)
    add_lib(lib)
end

handler.add_libraries = function(libs)
    for k, lib in pairs(libs) do
        add_lib(lib)
    end
end

return handler
