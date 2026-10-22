-- Paranoidal: factory dispatcher. A button in the mod button bar (styled by GUI Unifier) and the hotkey
-- factory-toggle-dispatch open a window with every factory building of the force that stands in the world:
-- picture of the building, name, place, state and overlay icons; search, filters, sorting and pages; a details
-- panel with a live view of the interior, renaming and remote view of the building or its interior.
-- Nothing is computed while the window is closed. The list is built when the window opens or the factories
-- change (built, removed, renamed, new overlay icons); the states of the shown page and the details panel
-- are refreshed every 2 seconds while the window is open (the selected factory is rescanned then, see stats.lua).

local mod_gui = require("mod-gui")

local FRAME = "factorissimo_dispatch_frame"
local BUTTON = "factorissimo_dispatch_button"
local P = "fdisp_" -- names of interactive elements
local MOD_NAME = script.mod_name
local PAGE_SIZE = 20
local MAX_ICONS = 8
local CAMERA_SIZE = 280
local LIGHT_REFRESH = 120
local UNLOCK_TECHNOLOGY = "factory-architecture-t1"
local SORTS = {"id", "name", "tier", "place", "power"}

local floor = math.floor

-- STATE --

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.dispatch = storage.dispatch or {}
    local dispatch = storage.dispatch
    dispatch.players = dispatch.players or {}
    dispatch.open = dispatch.open or {}
end)

local function player_state(player)
    local players = storage.dispatch.players
    local state = players[player.index]
    if not state then
        state = {search = "", sort = "id", page = 1, problems = false}
        players[player.index] = state
    end
    return state
end

--- Marks the lists of open windows for a rebuild (done at most twice a second).
function factorissimo.dispatch_changed()
    local dispatch = storage.dispatch
    if dispatch and next(dispatch.open) then dispatch.dirty = true end
end

-- HELPERS --

local sprite_cache = {}
local function valid_sprite(path)
    local cached = sprite_cache[path]
    if cached == nil then
        cached = helpers.is_valid_sprite_path(path)
        sprite_cache[path] = cached
    end
    return cached
end

local function picture_of(layout_name)
    local path = "factorissimo-picture-" .. layout_name
    if valid_sprite(path) then return path end
    path = "item/" .. layout_name
    if valid_sprite(path) then return path end
    return "factorissimo-dispatch-button"
end

local function entity_name_of(layout_name)
    local prototype = prototypes.entity[layout_name]
    return prototype and prototype.localised_name or layout_name
end

-- Lower case for the search: ASCII and Cyrillic (Lua string.lower only knows ASCII).
local function utf8_lower(text)
    text = text:lower()
    text = text:gsub("\208([\144-\159])", function(c) return "\208" .. string.char(c:byte() + 32) end) -- А..П
    text = text:gsub("\208([\160-\175])", function(c) return "\209" .. string.char(c:byte() - 32) end) -- Р..Я
    text = text:gsub("\208\129", "\209\145") -- Ё
    return text
end

local function is_standing(factory, force_index)
    if not (factory.built and factory.layout and factory.id) then return false end
    local force, building = factory.force, factory.building
    return force and force.valid and force.index == force_index and building and building.valid
end

local function parent_of(factory)
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return nil end
    local parent = remote_api.find_surrounding_factory(surface, {x = factory.outside_x, y = factory.outside_y})
    if parent and parent ~= factory then return parent end
    return nil
end

local function depth_of(factory)
    local depth, current = 0, factory
    while depth < 16 do
        current = parent_of(current)
        if not current then break end
        depth = depth + 1
    end
    return depth
end

local function location_caption(factory)
    local parent = parent_of(factory)
    if parent then return {"factorissimo-dispatch.inside-of", factorissimo.factory_caption(parent)} end
    local surface = factory.outside_surface
    if not (surface and surface.valid) then return "?" end
    local planet = surface.planet
    local name = surface.localised_name or (planet and planet.prototype.localised_name) or surface.name
    if planet then name = {"", "[planet=" .. planet.name .. "] ", name} end
    return {"factorissimo-dispatch.location", name, tostring(floor(factory.outside_x)), tostring(floor(factory.outside_y))}
end

--- sprite, caption, problem flag
local function status_of(factory)
    if factory.inactive then
        return "utility/status_not_working", {"factorissimo-dispatch.status-inactive"}, true
    end
    if not factorissimo.is_factory_wired(factory) then
        return "utility/status_not_working", {"factorissimo-dispatch.status-no-network"}, true
    end
    if (factory.power_gen or 0) > (factory.power_use or 0) then
        return "utility/status_working", {"factorissimo-dispatch.status-producing"}, false
    end
    local ratio = factory.power_ratio
    if ratio == 0 then
        return "utility/status_not_working", {"factorissimo-dispatch.status-no-power"}, true
    end
    if ratio and ratio < 0.99 then
        return "utility/status_yellow", {"factorissimo-dispatch.status-low-power", tostring(floor(ratio * 100))}, true
    end
    if factory.active == false then
        return "utility/status_inactive", {"factorissimo-dispatch.status-idle"}, false
    end
    return "utility/status_working", {"factorissimo-dispatch.status-working"}, false
end

local function overlay_icons(factory)
    local icons = {}
    local controller = factory.inside_overlay_controller
    if not (controller and controller.valid) then return icons end
    local behavior = controller.get_control_behavior()
    if not (behavior and behavior.enabled) then return icons end
    for _, section in pairs(behavior.sections) do
        if section.active then
            for _, filter in pairs(section.filters) do
                local value = filter.value
                if value and value.name then
                    local kind = value.type or "item"
                    if kind == "virtual" then kind = "virtual-signal" end
                    local path = kind .. "/" .. value.name
                    if valid_sprite(path) then icons[#icons + 1] = path end
                    if #icons >= MAX_ICONS then return icons end
                end
            end
        end
    end
    return icons
end

local POWER_PREFIXES = {{1e9, "si-prefix-symbol-giga"}, {1e6, "si-prefix-symbol-mega"}, {1e3, "si-prefix-symbol-kilo"}}

--- "1.2 MW" from J per tick (sign dropped).
local function format_power(per_tick)
    local watts = math.abs(per_tick) * 60
    for _, prefix in ipairs(POWER_PREFIXES) do
        if watts >= prefix[1] then
            local value = watts / prefix[1]
            return {"", string.format(value < 99.95 and "%.1f" or "%.0f", value), " ", {prefix[2]}, {"si-unit-symbol-watt"}}
        end
    end
    return {"", string.format("%.0f", watts), " ", {"si-unit-symbol-watt"}}
end

local EXPORT_COLOR = {r = 0.5, g = 0.9, b = 0.5}
local IMPORT_COLOR = {r = 0.85, g = 0.85, b = 0.85}

--- Short power figure of a list row: "+5.1 MW" (green) when the factory gives power, else what it takes.
local function power_of_row(factory)
    local use, gen = factory.power_use, factory.power_gen or 0
    if not use or (use == 0 and gen == 0) then return "", "", IMPORT_COLOR end
    local tooltip = gen > 0 and {"factorissimo-dispatch.power-tooltip", format_power(use), format_power(gen)}
        or {"factorissimo-dispatch.power-tooltip-use", format_power(use)}
    if gen > use then return {"", "+", format_power(gen - use)}, tooltip, EXPORT_COLOR end
    return format_power(use - gen), tooltip, IMPORT_COLOR
end

local function update_power_label(label, factory)
    if not (label and label.valid) then return end
    local caption, tooltip, color = power_of_row(factory)
    label.caption = caption
    label.tooltip = tooltip
    label.style.font_color = color
end

local function format_duration(ticks)
    if not ticks then return {"factorissimo-dispatch.none"} end
    local minutes = floor(ticks / 3600)
    return {"factorissimo-dispatch.duration", tostring(floor(minutes / 60)), string.format("%02d", minutes % 60)}
end

-- LIST --

local function sort_key_name(factory)
    return factory.name and utf8_lower(factory.name) or nil
end

local comparators = {
    id = function(a, b) return a.id < b.id end,
    tier = function(a, b)
        local ta, tb = a.layout.tier or 0, b.layout.tier or 0
        if ta ~= tb then return ta > tb end
        return a.id < b.id
    end,
}

--- Factories of the player's force shown with the current filters, and the count of each building type.
local function collect(player, state)
    local force_index = player.force.index
    local search = state.search ~= "" and utf8_lower(state.search) or nil
    local search_id = search and search:gsub("^#", ""):gsub("^\226\132\150", ""):gsub("^%s+", "") -- "#12", "№12"
    local list, counts, total = {}, {}, 0
    for _, factory in pairs(storage.factories) do
        if is_standing(factory, force_index) then
            local layout_name = factory.layout.name
            counts[layout_name] = (counts[layout_name] or 0) + 1
            total = total + 1
            local show = not state.tier or state.tier == layout_name
            if show and search then
                local name = factory.name and utf8_lower(factory.name) or ""
                show = name:find(search, 1, true) ~= nil or tostring(factory.id) == search_id
            end
            if show and state.problems then
                local _, _, problem = status_of(factory)
                show = problem
            end
            if show then list[#list + 1] = factory end
        end
    end

    local sort = state.sort
    if sort == "name" then
        local keys = {}
        for _, factory in pairs(list) do keys[factory] = sort_key_name(factory) end
        table.sort(list, function(a, b)
            local ka, kb = keys[a], keys[b]
            if ka and kb then
                if ka ~= kb then return ka < kb end
                return a.id < b.id
            end
            if ka or kb then return ka ~= nil end
            return a.id < b.id
        end)
    elseif sort == "place" then
        local keys = {}
        for _, factory in pairs(list) do
            local surface = factory.outside_surface
            keys[factory] = {surface and surface.valid and surface.index or 0, depth_of(factory)}
        end
        table.sort(list, function(a, b)
            local ka, kb = keys[a], keys[b]
            if ka[1] ~= kb[1] then return ka[1] < kb[1] end
            if ka[2] ~= kb[2] then return ka[2] < kb[2] end
            return a.id < b.id
        end)
    elseif sort == "power" then
        -- From the largest surplus ("+", gives power) down to the largest consumer; not measured yet at the end.
        local keys = {}
        for _, factory in pairs(list) do
            local use = factory.power_use
            keys[factory] = use and (factory.power_gen or 0) - use or nil
        end
        table.sort(list, function(a, b)
            local ka, kb = keys[a], keys[b]
            if ka and kb then
                if ka ~= kb then return ka > kb end
                return a.id < b.id
            end
            if ka or kb then return ka ~= nil end
            return a.id < b.id
        end)
    else
        table.sort(list, comparators[sort] or comparators.id)
    end
    return list, counts, total
end

-- GUI BUILDING --

local function get_frame(player)
    local frame = player.gui.screen[FRAME]
    if frame and frame.valid then return frame end
    return nil
end

-- Child element names must not repeat a LuaGuiElement attribute or method (name, text, caption, ...):
-- the engine refuses such names.
local function add_status(parent, factory)
    local sprite, caption = status_of(factory)
    local flow = parent.add {type = "flow", name = "status", direction = "horizontal"}
    flow.style.vertical_align = "center"
    flow.style.horizontal_spacing = 4
    local icon = flow.add {type = "sprite", name = "status_icon", sprite = sprite}
    icon.style.size = 14
    icon.style.stretch_image_to_widget_size = true
    flow.add {type = "label", name = "status_text", caption = caption}
    return flow
end

local function update_status(flow, factory)
    if not (flow and flow.valid) then return end
    local sprite, caption = status_of(factory)
    flow.status_icon.sprite = sprite
    flow.status_text.caption = caption
end

local function tool_button(parent, action, sprite, tooltip, id)
    local button = parent.add {type = "sprite-button", name = P .. action, sprite = sprite, style = "tool_button", tooltip = tooltip, tags = {id = id}}
    button.style.size = 28
    button.style.padding = 2
    return button
end

local function add_row(list_flow, factory, selected)
    local id = factory.id
    local row = list_flow.add {type = "flow", name = tostring(id), direction = "horizontal", tags = {id = id}}
    row.style.vertical_align = "center"
    row.style.horizontal_spacing = 8
    row.style.padding = {4, 6, 4, 4}

    local layout_name = factory.layout.name
    local picture = row.add {
        type = "sprite-button",
        name = P .. "select",
        sprite = picture_of(layout_name),
        style = "slot_button",
        tags = {id = id},
        tooltip = {"factorissimo-dispatch.select-tooltip", entity_name_of(layout_name)},
    }
    picture.style.size = 56
    picture.toggled = selected

    local info = row.add {type = "flow", direction = "vertical"}
    info.style.width = 250
    info.style.vertical_spacing = 0
    local name = info.add {type = "label", name = "factory_name", caption = factorissimo.factory_caption(factory), style = "caption_label"}
    name.style.maximal_width = 250
    if not factory.name then name.style.font_color = {r = 0.7, g = 0.7, b = 0.7} end
    local place = info.add {type = "label", caption = location_caption(factory)}
    place.style.font = "default-small"
    place.style.font_color = {r = 0.75, g = 0.75, b = 0.75}
    place.style.maximal_width = 250
    add_status(info, factory)

    local icons = row.add {type = "table", column_count = 4}
    icons.style.width = 4 * 26
    icons.style.horizontal_spacing = 2
    icons.style.vertical_spacing = 2
    for _, path in pairs(overlay_icons(factory)) do
        local sprite = icons.add {type = "sprite", sprite = path}
        sprite.style.size = 24
        sprite.style.stretch_image_to_widget_size = true
    end

    local filler = row.add {type = "empty-widget"}
    filler.style.horizontally_stretchable = true

    local power = row.add {type = "label", name = "power_label", style = "bold_label"}
    power.style.width = 80
    power.style.horizontal_align = "right"
    update_power_label(power, factory)

    local buttons = row.add {type = "flow", direction = "horizontal"}
    buttons.style.horizontal_spacing = 2
    tool_button(buttons, "rename", "utility/rename_icon", {"factorissimo-dispatch.rename-tooltip"}, id)
    tool_button(buttons, "map", "utility/map", {"factorissimo-dispatch.map-tooltip"}, id)
    tool_button(buttons, "inside", "utility/search", {"factorissimo-dispatch.inside-tooltip"}, id)
end

local function build_toolbar(toolbar, state, counts, total)
    toolbar.clear()
    local search = toolbar.add {type = "textfield", name = P .. "search", text = state.search, tooltip = {"factorissimo-dispatch.search-tooltip"}}
    search.style.width = 160
    search.lose_focus_on_confirm = true

    local tiers = toolbar.add {type = "flow", direction = "horizontal"}
    tiers.style.horizontal_spacing = 2
    local all = tiers.add {type = "sprite-button", name = P .. "tier/", sprite = "utility/list_view", style = "slot_button",
        number = total, tags = {tier = ""}, tooltip = {"factorissimo-dispatch.all-tiers"}}
    all.style.size = 36
    all.toggled = state.tier == nil
    local names = {}
    for layout_name in pairs(counts) do names[#names + 1] = layout_name end
    table.sort(names)
    for _, layout_name in ipairs(names) do
        local button = tiers.add {type = "sprite-button", name = P .. "tier/" .. layout_name, sprite = picture_of(layout_name), style = "slot_button",
            number = counts[layout_name], tags = {tier = layout_name}, tooltip = entity_name_of(layout_name)}
        button.style.size = 36
        button.toggled = state.tier == layout_name
    end

    local filler = toolbar.add {type = "empty-widget"}
    filler.style.horizontally_stretchable = true

    toolbar.add {type = "checkbox", name = P .. "problems", state = state.problems, caption = {"factorissimo-dispatch.problems"},
        tooltip = {"factorissimo-dispatch.problems-tooltip"}}
    local items, selected = {}, 1
    for i, sort in ipairs(SORTS) do
        items[i] = {"factorissimo-dispatch.sort-" .. sort}
        if sort == state.sort then selected = i end
    end
    local dropdown = toolbar.add {type = "drop-down", name = P .. "sort", items = items, selected_index = selected, tooltip = {"factorissimo-dispatch.sort-tooltip"}}
    dropdown.style.width = 150
end

local function build_list(frame, player, state)
    local left = frame.body.left
    local list, counts, total = collect(player, state)
    local pages = math.max(1, math.ceil(#list / PAGE_SIZE))
    if state.page > pages then state.page = pages end
    if state.page < 1 then state.page = 1 end

    -- The search field keeps its focus and text: the toolbar is rebuilt only when the counts change.
    local signature = tostring(total)
    for layout_name, count in pairs(counts) do signature = signature .. ";" .. layout_name .. "=" .. count end
    local bar = left.toolbar.bar
    if bar.tags.signature ~= signature or not bar[P .. "search"] then
        build_toolbar(bar, state, counts, total)
        bar.tags = {signature = signature}
    end

    local scroll = left.scroll
    scroll.clear()
    local list_flow = scroll.add {type = "flow", name = "rows", direction = "vertical"}
    list_flow.style.vertical_spacing = 0
    if #list == 0 then
        local label = list_flow.add {type = "label", caption = total == 0 and {"factorissimo-dispatch.empty"} or {"factorissimo-dispatch.nothing-found"}}
        label.style.padding = 12
        label.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
    end
    local first = (state.page - 1) * PAGE_SIZE + 1
    for i = first, math.min(#list, first + PAGE_SIZE - 1) do
        if i > first then list_flow.add {type = "line", direction = "horizontal"} end
        add_row(list_flow, list[i], list[i].id == state.selected)
    end
    -- A rebuilt list starts at the top; keep the selected factory in view.
    local selected_row = state.selected and list_flow[tostring(state.selected)]
    if selected_row then scroll.scroll_to_element(selected_row, "in-view") end

    local footer = left.footer.bar
    footer.page.caption = {"factorissimo-dispatch.page", tostring(state.page), tostring(pages)}
    footer[P .. "prev"].enabled = state.page > 1
    footer[P .. "next"].enabled = state.page < pages
    footer.summary.caption = {"factorissimo-dispatch.summary", tostring(#list), tostring(total)}
end

local function add_info(info, key, value, tooltip)
    local label = info.add {type = "label", caption = {"factorissimo-dispatch." .. key}, style = "bold_label"}
    label.style.minimal_width = 100
    local value_label = info.add {type = "label", caption = value, tooltip = tooltip}
    value_label.style.single_line = false
    value_label.style.maximal_width = 170
end

local CONNECTION_TYPES = {"belt", "chest", "fluid", "heat", "circuit"}

local function fill_info(info, factory)
    info.clear()
    local layout = factory.layout
    local status_sprite, status_caption = status_of(factory)
    add_info(info, "info-state", {"", "[img=" .. status_sprite .. "] ", status_caption})
    add_info(info, "info-place", location_caption(factory))

    local ratio = factory.power_ratio
    local power
    if not factorissimo.is_factory_wired(factory) then
        power = {"factorissimo-dispatch.power-none"}
    elseif ratio then
        power = {"factorissimo-dispatch.percent", tostring(floor(ratio * 100 + 0.5))}
    else
        power = {"factorissimo-dispatch.measuring"}
    end
    add_info(info, "info-power", power)

    local use, gen = factory.power_use, factory.power_gen or 0
    add_info(info, "info-consumption", use and {"factorissimo-dispatch.approx", format_power(use)} or {"factorissimo-dispatch.measuring"})
    local generators = factory.generators or 0
    if use and generators > 0 then
        add_info(info, "info-production", format_power(gen),
            {"factorissimo-dispatch.generators", tostring(factory.generators_working or 0), tostring(generators)})
        local net = gen - use
        add_info(info, "info-balance", net >= 0 and {"", "[color=#80e080]+", format_power(net), "[/color]"}
            or {"", "[color=#ff8080]−", format_power(net), "[/color]"}, {"factorissimo-dispatch.balance-tooltip"})
    end

    local used, by_type = 0, {}
    for _, conn in pairs(factory.connections or {}) do
        used = used + 1
        by_type[conn._type] = (by_type[conn._type] or 0) + 1
    end
    local tooltip = {"", {"factorissimo-dispatch.connections-header"}}
    for _, ctype in ipairs(CONNECTION_TYPES) do
        if by_type[ctype] then
            tooltip[#tooltip + 1] = {"factorissimo-dispatch.connection-line", {"factorissimo-dispatch.connection-" .. ctype}, tostring(by_type[ctype])}
        end
    end
    add_info(info, "info-connections", {"factorissimo-dispatch.of", tostring(used), tostring(table_size(layout.connections))},
        #tooltip > 2 and tooltip or nil)

    add_info(info, "info-machines", {"factorissimo-dispatch.machines", tostring(factory.machines_working or 0), tostring(factory.machines or 0)})

    local children = factory.children or 0
    if children > 0 then add_info(info, "info-children", tostring(children)) end
    add_info(info, "info-depth", tostring(depth_of(factory)))

    add_info(info, "info-pollution", {"factorissimo-dispatch.per-minute", string.format("%.1f", (factory.pollution_rate or 0) * 60)})
    local tick = game.tick
    add_info(info, "info-uptime", format_duration(factory.uptime_since and tick - factory.uptime_since))
    add_info(info, "info-clean", format_duration(factory.clean_since and tick - factory.clean_since))

    local force = factory.force
    local hull = force and force.valid and factorissimo.factory_hull_of(force)
    add_info(info, "info-hull", hull and hull.reduction > 0
        and {"factorissimo-dispatch.hull", tostring(floor(hull.reduction * 100 + 0.5))}
        or {"factorissimo-dispatch.hull-none"})
end

local function camera_zoom(player, layout)
    return (CAMERA_SIZE / 32) / (layout.inside_size + 2) * player.display_scale / player.display_density_scale
end

local function build_details(frame, player, state)
    local details = frame.body.details.scroll.content
    local factory = state.selected and storage.factories[state.selected]
    if not (factory and is_standing(factory, player.force.index)) then
        state.selected = nil
        details.clear()
        details.tags = {}
        local label = details.add {type = "label", caption = {"factorissimo-dispatch.select-hint"}}
        label.style.single_line = false
        label.style.padding = 12
        label.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
        return
    end

    -- The interior of the selected factory is scanned at most every LIGHT_REFRESH ticks (machines, power).
    local tick = game.tick
    if not factory.active_tick or tick - factory.active_tick >= LIGHT_REFRESH then factorissimo.scan_factory(factory, tick) end

    if details.tags.id == factory.id and details.info then
        fill_info(details.info, factory)
        details.header.titles.title.caption = factorissimo.factory_caption(factory)
        return
    end

    details.clear()
    details.tags = {id = factory.id}
    local layout = factory.layout

    local header = details.add {type = "flow", name = "header", direction = "horizontal"}
    header.style.vertical_align = "center"
    header.style.horizontal_spacing = 8
    local picture = header.add {type = "sprite", sprite = picture_of(layout.name)}
    picture.style.size = 72
    picture.style.stretch_image_to_widget_size = true
    local titles = header.add {type = "flow", name = "titles", direction = "vertical"}
    local title = titles.add {type = "label", name = "title", caption = factorissimo.factory_caption(factory), style = "caption_label"}
    title.style.maximal_width = 220
    titles.add {type = "label", caption = {"factorissimo-dispatch.tier-line", entity_name_of(layout.name), tostring(factory.id),
        tostring(layout.inside_size)}}

    local rename = details.add {type = "flow", name = "rename", direction = "horizontal"}
    rename.style.vertical_align = "center"
    local field = rename.add {type = "textfield", name = P .. "name", text = factory.name or "", tags = {id = factory.id},
        icon_selector = true, tooltip = {"factorissimo-dispatch.name-tooltip"}}
    field.style.width = 260
    field.lose_focus_on_confirm = true
    local confirm = rename.add {type = "sprite-button", name = P .. "name_confirm", sprite = "utility/check_mark", style = "tool_button_green",
        tags = {id = factory.id}, tooltip = {"factorissimo-dispatch.name-confirm"}}
    confirm.style.size = 28

    local camera_frame = details.add {type = "frame", style = "deep_frame_in_shallow_frame"}
    local surface = factory.inside_surface
    if surface and surface.valid then
        local camera = camera_frame.add {
            type = "camera",
            name = "camera",
            position = {factory.inside_x, factory.inside_y},
            surface_index = surface.index,
            zoom = camera_zoom(player, layout),
        }
        camera.style.width = CAMERA_SIZE
        camera.style.height = CAMERA_SIZE
    end

    local info = details.add {type = "table", name = "info", column_count = 2}
    info.style.horizontal_spacing = 8
    info.style.vertical_spacing = 2
    fill_info(info, factory)

    local buttons = details.add {type = "flow", direction = "horizontal"}
    buttons.style.horizontal_spacing = 4
    local map = buttons.add {type = "button", name = P .. "map", caption = {"factorissimo-dispatch.map"}, tags = {id = factory.id},
        tooltip = {"factorissimo-dispatch.map-tooltip"}}
    map.style.horizontally_stretchable = true
    local inside = buttons.add {type = "button", name = P .. "inside", caption = {"factorissimo-dispatch.inside"}, tags = {id = factory.id},
        tooltip = {"factorissimo-dispatch.inside-tooltip"}}
    inside.style.horizontally_stretchable = true
end

local function refresh(player, light)
    local frame = get_frame(player)
    if not frame then return end
    local state = player_state(player)
    if light then
        -- Only the states of the shown rows and the details panel change by themselves.
        local rows = frame.body.left.scroll.rows
        if rows then
            for _, row in pairs(rows.children) do
                local id = row.tags and row.tags.id
                local factory = id and storage.factories[id]
                if factory and factory.layout then
                    local info = row.children[2]
                    if info then update_status(info.status, factory) end
                    update_power_label(row.power_label, factory)
                end
            end
        end
    else
        build_list(frame, player, state)
    end
    build_details(frame, player, state)
end

local function close(player)
    local frame = get_frame(player)
    if frame then frame.destroy() end
    if storage.dispatch then storage.dispatch.open[player.index] = nil end
end

local function open(player)
    close(player)
    local state = player_state(player)
    local frame = player.gui.screen.add {type = "frame", name = FRAME, direction = "vertical"}
    if state.location then
        frame.location = state.location
    else
        frame.auto_center = true
    end

    local titlebar = frame.add {type = "flow", direction = "horizontal", style = "frame_header_flow"}
    titlebar.drag_target = frame
    titlebar.add {type = "label", caption = {"factorissimo-dispatch.title"}, style = "frame_title", ignored_by_interaction = true}
    local drag = titlebar.add {type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true}
    drag.style.height = 24
    drag.style.horizontally_stretchable = true
    titlebar.add {type = "sprite-button", name = P .. "refresh", sprite = "utility/refresh", style = "frame_action_button",
        tooltip = {"factorissimo-dispatch.refresh"}}
    titlebar.add {type = "sprite-button", name = P .. "close", sprite = "utility/close", style = "frame_action_button",
        tooltip = {"gui.close-instruction"}}

    local body = frame.add {type = "flow", name = "body", direction = "horizontal"}
    body.style.horizontal_spacing = 12

    local left = body.add {type = "frame", name = "left", direction = "vertical", style = "inside_deep_frame"}
    local toolbar = left.add {type = "frame", name = "toolbar", direction = "horizontal", style = "subheader_frame"}
    toolbar.style.horizontally_stretchable = true
    toolbar.style.height = 48
    local bar = toolbar.add {type = "flow", name = "bar", direction = "horizontal"}
    bar.style.vertical_align = "center"
    bar.style.horizontal_spacing = 8
    bar.style.horizontally_stretchable = true
    local scroll = left.add {type = "scroll-pane", name = "scroll", style = "naked_scroll_pane"}
    scroll.horizontal_scroll_policy = "never"
    scroll.style.width = 640
    scroll.style.height = 500
    local footer_frame = left.add {type = "frame", name = "footer", direction = "horizontal", style = "subheader_frame"}
    footer_frame.style.horizontally_stretchable = true
    local footer = footer_frame.add {type = "flow", name = "bar", direction = "horizontal"}
    footer.style.vertical_align = "center"
    footer.style.horizontal_spacing = 8
    footer.style.horizontally_stretchable = true
    footer.add {type = "sprite-button", name = P .. "prev", sprite = "utility/left_arrow", style = "tool_button", tooltip = {"factorissimo-dispatch.previous-page"}}
    footer.add {type = "label", name = "page"}
    footer.add {type = "sprite-button", name = P .. "next", sprite = "utility/right_arrow", style = "tool_button", tooltip = {"factorissimo-dispatch.next-page"}}
    local filler = footer.add {type = "empty-widget"}
    filler.style.horizontally_stretchable = true
    footer.add {type = "label", name = "summary"}

    local details = body.add {type = "frame", name = "details", direction = "vertical", style = "inside_shallow_frame_with_padding"}
    details.style.width = 340
    details.style.vertically_stretchable = true
    local details_scroll = details.add {type = "scroll-pane", name = "scroll", style = "naked_scroll_pane"}
    details_scroll.horizontal_scroll_policy = "never"
    details_scroll.style.height = 560
    details_scroll.style.horizontally_stretchable = true
    local content = details_scroll.add {type = "flow", name = "content", direction = "vertical"}
    content.style.vertical_spacing = 6

    storage.dispatch.open[player.index] = true
    refresh(player)
    player.opened = frame
end

local function toggle(player)
    if get_frame(player) then close(player) else open(player) end
end

-- BUTTON --

local function unlocked(force)
    local technology = force.technologies[UNLOCK_TECHNOLOGY]
    return technology == nil or technology.researched
end

local function update_button(player)
    if not (player and player.valid) then return end
    local flow = mod_gui.get_button_flow(player)
    local button = flow[BUTTON]
    if unlocked(player.force) then
        if not button then
            flow.add {type = "sprite-button", name = BUTTON, sprite = "factorissimo-dispatch-button", style = mod_gui.button_style,
                tooltip = {"factorissimo-dispatch.button-tooltip"}}
        end
    else
        if button then button.destroy() end
        close(player)
    end
end

factorissimo.on_event(factorissimo.events.on_init(), function()
    for _, player in pairs(game.players) do update_button(player) end
end)

factorissimo.on_event(defines.events.on_player_created, function(event)
    update_button(game.get_player(event.player_index))
end)

factorissimo.on_event(defines.events.on_player_changed_force, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end
    close(player)
    update_button(player)
end)

factorissimo.on_event({defines.events.on_research_finished, defines.events.on_research_reversed}, function(event)
    local research = event.research
    if research.name ~= UNLOCK_TECHNOLOGY then return end
    for _, player in pairs(research.force.players) do update_button(player) end
end)

factorissimo.on_event(defines.events.on_player_removed, function(event)
    if not storage.dispatch then return end
    storage.dispatch.players[event.player_index] = nil
    storage.dispatch.open[event.player_index] = nil
end)

factorissimo.on_event("factory-toggle-dispatch", function(event)
    local player = game.get_player(event.player_index)
    if player and unlocked(player.force) then toggle(player) end
end)

-- PERIODIC REFRESH --

factorissimo.on_nth_tick(30, function(event)
    local dispatch = storage.dispatch
    if not (dispatch and next(dispatch.open)) then return end
    local dirty = dispatch.dirty
    local light = event.tick % LIGHT_REFRESH == 0
    if not (dirty or light) then return end
    dispatch.dirty = nil
    for player_index in pairs(dispatch.open) do
        local player = game.get_player(player_index)
        if player and player.connected and get_frame(player) then
            refresh(player, not dirty)
        else
            dispatch.open[player_index] = nil
        end
    end
end)

-- GUI EVENTS --

local function camera_to(player, surface, position)
    if not (surface and surface.valid) then return end
    close(player)
    factorissimo.camera_teleport(player, surface, position)
end

local function factory_of(element, player)
    local id = element.tags and element.tags.id
    local factory = id and storage.factories[id]
    if factory and is_standing(factory, player.force.index) then return factory end
    return nil
end

local function select_factory(player, id)
    local state = player_state(player)
    state.selected = id
    local frame = get_frame(player)
    if not frame then return end
    local rows = frame.body.left.scroll.rows
    if rows then
        for _, row in pairs(rows.children) do
            local picture = row[P .. "select"]
            if picture then picture.toggled = row.tags.id == id end
        end
    end
    build_details(frame, player, state)
end

local function rename(player, factory, field)
    factorissimo.set_factory_name(factory, field.text)
    field.text = factory.name or ""
    local frame = get_frame(player)
    if frame then refresh(player) end
end

local click_actions = {
    close = function(player) close(player) end,
    refresh = function(player) refresh(player) end,
    select = function(player, element)
        local factory = factory_of(element, player)
        if factory then select_factory(player, factory.id) end
    end,
    rename = function(player, element)
        local factory = factory_of(element, player)
        if not factory then return end
        select_factory(player, factory.id)
        local frame = get_frame(player)
        local rename_flow = frame and frame.body.details.scroll.content.rename
        local field = rename_flow and rename_flow[P .. "name"]
        if field then
            field.focus()
            field.select_all()
        end
    end,
    name_confirm = function(player, element)
        local factory = factory_of(element, player)
        local field = element.parent[P .. "name"]
        if factory and field then rename(player, factory, field) end
    end,
    map = function(player, element)
        local factory = factory_of(element, player)
        if factory then camera_to(player, factory.outside_surface, {x = factory.outside_x, y = factory.outside_y}) end
    end,
    inside = function(player, element)
        local factory = factory_of(element, player)
        if factory then camera_to(player, factory.inside_surface, {x = factory.inside_x, y = factory.inside_y}) end
    end,
    tier = function(player, element)
        local state = player_state(player)
        local tier = element.tags.tier
        state.tier = tier ~= "" and tier or nil
        state.page = 1
        local frame = get_frame(player)
        if frame then frame.body.left.toolbar.bar.tags = {} end -- redraw the toggled state of the tier buttons
        refresh(player)
    end,
    prev = function(player)
        local state = player_state(player)
        state.page = state.page - 1
        refresh(player)
    end,
    next = function(player)
        local state = player_state(player)
        state.page = state.page + 1
        refresh(player)
    end,
}

local function own_element(event)
    local element = event.element
    if not (element and element.valid) or element.get_mod() ~= MOD_NAME then return nil end
    local player = game.get_player(event.player_index)
    if not player then return nil end
    return element, player
end

gui_events[defines.events.on_gui_click]["^" .. BUTTON .. "$"] = function(event)
    local element, player = own_element(event)
    if element and unlocked(player.force) then toggle(player) end
end

gui_events[defines.events.on_gui_click]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element then return end
    -- Sibling elements need unique names: "fdisp_<action>/<suffix>".
    local action = click_actions[element.name:sub(#P + 1):match("^[^/]+")]
    if action then action(player, element) end
end

gui_events[defines.events.on_gui_confirmed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element then return end
    if element.name == P .. "name" then
        local factory = factory_of(element, player)
        if factory then rename(player, factory, element) end
    end
end

gui_events[defines.events.on_gui_text_changed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element or element.name ~= P .. "search" then return end
    local state = player_state(player)
    state.search = element.text
    state.page = 1
    local frame = get_frame(player)
    if frame then build_list(frame, player, state) end
end

gui_events[defines.events.on_gui_checked_state_changed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element or element.name ~= P .. "problems" then return end
    local state = player_state(player)
    state.problems = element.state
    state.page = 1
    refresh(player)
end

gui_events[defines.events.on_gui_selection_state_changed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element or element.name ~= P .. "sort" then return end
    local state = player_state(player)
    state.sort = SORTS[element.selected_index] or "id"
    refresh(player)
end

gui_events[defines.events.on_gui_location_changed]["^" .. FRAME .. "$"] = function(event)
    local element, player = own_element(event)
    if element then player_state(player).location = element.location end
end

factorissimo.on_event(defines.events.on_gui_closed, function(event)
    local element = event.element
    if element and element.valid and element.name == FRAME and element.get_mod() == MOD_NAME then
        local player = game.get_player(event.player_index)
        if player then close(player) end
    end
end)
