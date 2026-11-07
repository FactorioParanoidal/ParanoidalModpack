-- Paranoidal: factory dispatcher. A button in the mod button bar (styled by GUI Unifier) and the hotkey
-- factory-toggle-dispatch open a window with every factory building of the force that stands in the world:
-- picture of the building, name, place, state and overlay icons; search, filters, sorting and pages; a details
-- panel with a live view of the interior, renaming and remote view of the building or its interior.
-- Open windows share a bounded registry index. Views rebuild only on relevant changes; only the visible
-- page is refreshed every 2 seconds. Rows and details read the same gameplay snapshot, without scanning interiors.

local mod_gui = require("mod-gui")
local model = require("script.dispatch-model")

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
    dispatch.catalog, dispatch.catalog_job, dispatch.jobs, dispatch.watching = nil, nil, nil, {}
    dispatch.shared = {}
    dispatch.revision = (dispatch.revision or 0) + 1
    dispatch.dirty = true
    for _, state in pairs(dispatch.players) do state.result, state.job = nil, nil end
end)

local function player_state(player)
    local players = storage.dispatch.players
    local state = players[player.index]
    if not state then
        state = {search = "", sort = "id", page = 1, problems = false}
        players[player.index] = state
    end
    state.expanded = state.expanded or {}
    state.history = state.history or {}
    state.view = state.view or "list"
    return state
end

--- Invalidates structure, names and overlay presentation, not the gameplay statistics.
function factorissimo.dispatch_changed()
    local dispatch = storage.dispatch
    if dispatch and next(dispatch.open) then
        dispatch.revision = (dispatch.revision or 0) + 1
        dispatch.dirty = true
    end
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
    if parent and parent.force == factory.force then return parent end
    return nil
end

local function depth_of(factory)
    local catalog = storage.dispatch and storage.dispatch.catalog
    local node = catalog and catalog.nodes[factory.id]
    if not node then return {"factorissimo-dispatch.measuring"} end
    return node.cyclic and {"factorissimo-dispatch.cycle-depth"} or tostring(node.depth)
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
    if not factory.built then
        return "utility/status_inactive", {"factorissimo-dispatch.packed"}, false
    end
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
    if factory.active == nil then
        return "utility/status_inactive", {"factorissimo-dispatch.measuring"}, false
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
    if not use then return {"factorissimo-dispatch.none"}, {"factorissimo-dispatch.measuring"}, IMPORT_COLOR end
    local tooltip = gen > 0 and {"factorissimo-dispatch.power-tooltip", format_power(use), format_power(gen)}
        or {"factorissimo-dispatch.power-tooltip-use", format_power(use)}
    if gen == use then return format_power(0), tooltip, IMPORT_COLOR end
    if gen > use then return {"", "+", format_power(gen - use)}, tooltip, EXPORT_COLOR end
    return {"", "−", format_power(use - gen)}, tooltip, IMPORT_COLOR
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

local function describe(factory)
    local force, layout = factory.force, factory.layout
    if not (factory.id and storage.factories[factory.id] == factory and layout and force and force.valid) then return nil end
    local built = is_standing(factory, force.index)
    local parent = built and parent_of(factory)
    local surface = factory.outside_surface
    local _, _, problem = status_of(factory)
    return {id = factory.id, force = force.index, built = built, layout = layout.name, tier = layout.tier or 0,
        name = factory.name and utf8_lower(factory.name), parent = parent and parent.id,
        surface = surface and surface.valid and surface.index or 0, problem = problem,
        power = factory.power_use and (factory.power_gen or 0) - factory.power_use}
end

local function release_idle_cache(dispatch)
    if not next(dispatch.open) then
        dispatch.catalog, dispatch.catalog_job, dispatch.jobs = nil, nil, nil
        dispatch.watching, dispatch.shared = {}, {}
    end
end

local function enqueue(job)
    local dispatch = storage.dispatch
    local queue = dispatch.jobs
    if not queue then
        queue = {head = 1, tail = 0, entries = {}}
        dispatch.jobs = queue
        factorissimo.execute_later("dispatch-work", 1)
    end
    queue.tail = queue.tail + 1
    queue.entries[queue.tail] = job
end

local function request_catalog()
    local dispatch = storage.dispatch
    if not dispatch.catalog_job and (not dispatch.catalog or dispatch.catalog.revision ~= (dispatch.revision or 0)) then
        dispatch.catalog_job = model.catalog(dispatch.revision or 0)
        enqueue(dispatch.catalog_job)
    end
end

-- Called by the existing sampler, not by a second scan of all factories. No work for closed windows.
function factorissimo.dispatch_sampled(factory, tick)
    local dispatch = storage.dispatch
    local catalog = dispatch and dispatch.catalog
    local node = catalog and catalog.nodes[factory.id]
    if not (node and next(dispatch.open)) then return end
    local force = catalog.forces[node.force]
    local power = factory.power_use and (factory.power_gen or 0) - factory.power_use
    if node.power ~= power then node.power = power; force.power_revision = force.power_revision + 1 end
    if dispatch.watching and dispatch.watching[node.force] and (not node.checked or tick - node.checked >= LIGHT_REFRESH) then
        node.checked = tick
        local _, _, problem = status_of(factory)
        if node.problem ~= problem then node.problem = problem; force.problem_revision = force.problem_revision + 1 end
    end
end

factorissimo.register_delayed_function("dispatch-work", function()
    local dispatch = storage.dispatch
    local queue = dispatch and dispatch.jobs
    if not queue then return end
    if dispatch.work_tick == game.tick then return end
    dispatch.work_tick = game.tick
    if not next(dispatch.open) then release_idle_cache(dispatch); return end
    -- At most 256 registry/sort/tree steps per tick globally, with round-robin view jobs.
    for _ = 1, 8 do
        if queue.head > queue.tail then break end
        local job = queue.entries[queue.head]
        queue.entries[queue.head] = nil; queue.head = queue.head + 1
        local valid = job.kind == "catalog" and dispatch.catalog_job == job
        for index in pairs(job.users or {}) do
            local state = dispatch.players[index]
            if state and state.job == job and dispatch.open[index] then valid = true; break end
        end
        if not valid then job.cancelled = true end
        if valid then
            local done
            for _ = 1, 32 do
                if job.kind == "catalog" then done = model.catalog_step(job, storage.factories, describe)
                else done = model.view_step(job) end
                if done then break end
            end
            if done then
                if job.kind == "catalog" then
                    dispatch.catalog = job; dispatch.catalog_job = nil
                else
                    local result = {rows = job.rows, positions = job.positions, counts = job.force.counts,
                        total = job.force.total, matched = #job.matches, key = job.key, revision = job.catalog.revision, tree = job.tree}
                    for index in pairs(job.users) do
                        local state = dispatch.players[index]
                        if state and state.job == job then state.result = result; state.job = nil end
                    end
                    local shared = dispatch.shared and dispatch.shared[job.force_index]
                    if shared and shared.job == job then shared.result = result; shared.job = nil end
                end
                dispatch.ready = true
            else
                queue.tail = queue.tail + 1; queue.entries[queue.tail] = job
            end
        end
    end
    if queue.head <= queue.tail then factorissimo.execute_later("dispatch-work", 1)
    else dispatch.jobs = nil end
end)

local function query_changed(state)
    state.query_revision = (state.query_revision or 0) + 1
    state.job = nil
end

local function collect(player, state)
    request_catalog()
    local catalog = storage.dispatch.catalog
    if catalog and (not state.search_due or game.tick >= state.search_due) then
        state.search_due = nil
        local force = catalog.forces[player.force.index]
        local key = table.concat({catalog.revision, player.force.index, state.view, state.sort, tostring(state.problems),
            state.sort == "power" and force and force.power_revision or 0,
            state.problems and force and force.problem_revision or 0,
            state.view == "tree" and player.index or 0, state.view == "tree" and (state.query_revision or 0) or 0,
            #(state.tier or ""), state.tier or "", #state.search, state.search}, ":")
        if not state.job and (not state.result or state.result.key ~= key) then
            local dispatch = storage.dispatch
            dispatch.shared = dispatch.shared or {}
            local shared = state.view == "list" and dispatch.shared[player.force.index]
            if shared and shared.key == key and shared.result then
                state.result = shared.result
            elseif shared and shared.key == key and shared.job and not shared.job.cancelled then
                state.job = shared.job
                shared.job.users[player.index] = true
            else
                local job = model.view(catalog, player.force.index, state, key, state.search ~= "" and utf8_lower(state.search) or nil)
                job.users = {[player.index] = true}; job.force_index = player.force.index
                state.job = job
                if state.view == "list" then dispatch.shared[player.force.index] = {key = key, job = job} end
                enqueue(job)
            end
        end
    end
    return state.result, state.job ~= nil or storage.dispatch.catalog_job ~= nil or state.search_due ~= nil
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

local function add_row(list_flow, factory, selected, entry, slot, revision)
    local id = factory.id
    local container = list_flow[tostring(slot)]
    if not container then container = list_flow.add {type = "flow", name = tostring(slot), direction = "vertical"} end
    local signature = table.concat({id, revision, entry.depth, entry.children, tostring(entry.tree),
        tostring(entry.filtered), tostring(entry.context), tostring(entry.packed)}, ":")
    if container.tags.signature == signature then
        local row = container.row
        row[P .. "select"].toggled = selected
        if row[P .. "expand"] then row[P .. "expand"].sprite = entry.expanded and "utility/collapse" or "utility/expand" end
        update_status(row.row_info.status, factory)
        update_power_label(row.power_label, factory)
        return
    end
    container.clear()
    container.tags = {id = id, signature = signature}
    local row = container.add {type = "flow", name = "row", direction = "horizontal", tags = {id = id}}
    if entry.tree then
        local indent = row.add {type = "empty-widget"}
        indent.style.width = math.min(entry.depth, 3) * 12
        local expand = tool_button(row, "expand", entry.expanded and "utility/collapse" or "utility/expand",
            {entry.filtered and "factorissimo-dispatch.filtered-path" or "factorissimo-dispatch.expand-tooltip"}, id)
        expand.enabled = entry.children > 0 and not entry.filtered
        expand.visible = entry.children > 0
        if entry.children == 0 then
            local space = row.add {type = "empty-widget"}; space.style.width = 28
        end
    end
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
    picture.enabled = not entry.packed

    local info = row.add {type = "flow", name = "row_info", direction = "vertical"}
    local text_width = entry.tree and 200 - math.min(entry.depth, 3) * 12 or 250
    info.style.width = text_width
    info.style.vertical_spacing = 0
    local name = info.add {type = "label", name = P .. "select/name", tags = {id = id},
        caption = factorissimo.factory_caption(factory), style = "caption_label", tooltip = factorissimo.factory_caption(factory)}
    name.style.maximal_width = text_width
    if entry.context then name.style.font_color = {r = 0.7, g = 0.7, b = 0.7} end
    if not factory.name then name.style.font_color = {r = 0.7, g = 0.7, b = 0.7} end
    local place = info.add {type = "label", caption = location_caption(factory)}
    place.style.font = "default-small"
    place.style.font_color = {r = 0.75, g = 0.75, b = 0.75}
    place.style.maximal_width = text_width
    if entry.cycle then place.caption = {"factorissimo-dispatch.cycle-link", tostring(entry.cycle)} end
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
    for _, button in pairs(buttons.children) do button.enabled = not entry.packed end
    container.add {type = "line", direction = "horizontal"}
end

local function build_toolbar(toolbar, state, counts, total)
    toolbar.clear()
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
    local result, pending = collect(player, state)
    local list, counts, total = result and result.rows or {}, result and result.counts or {}, result and result.total or 0
    if state.reveal and result and not pending and result.positions[state.reveal] then
        state.page = math.floor((result.positions[state.reveal] - 1) / PAGE_SIZE) + 1
        state.reveal = nil
    end
    local pages = math.max(1, math.ceil(#list / PAGE_SIZE))
    if result and state.page > pages then state.page = pages end
    if state.page < 1 then state.page = 1 end

    -- Tier controls rebuild only when counts change; search lives in a separate, stable navigation row.
    local signature = tostring(total)
    for layout_name, count in pairs(counts) do signature = signature .. ";" .. layout_name .. "=" .. count end
    local bar = left.toolbar.bar
    if bar.tags.signature ~= signature or not bar[P .. "sort"] then
        build_toolbar(bar, state, counts, total)
        bar.tags = {signature = signature}
    end

    local footer = left.footer.bar
    footer.page.caption = result and {"factorissimo-dispatch.page", tostring(state.page), tostring(pages)} or ""
    footer[P .. "prev"].enabled = result ~= nil and state.page > 1
    footer[P .. "next"].enabled = result ~= nil and state.page < pages
    footer.summary.caption = pending and {"factorissimo-dispatch.updating"}
        or {"factorissimo-dispatch.summary", tostring(result and result.matched or 0), tostring(total)}
    local nav = left.nav
    if nav then
        nav[P .. "list"].toggled = state.view == "list"
        nav[P .. "tree"].toggled = state.view == "tree"
        nav[P .. "back"].enabled = #state.history > 0
    end

    local first = (state.page - 1) * PAGE_SIZE + 1
    local scroll = left.scroll
    local list_flow = scroll.rows or scroll.add {type = "flow", name = "rows", direction = "vertical"}
    list_flow.style.vertical_spacing = 0
    local hint = scroll.list_hint or scroll.add {type = "label", name = "list_hint"}
    hint.visible = #list == 0
    hint.caption = pending and {"factorissimo-dispatch.updating"}
        or total == 0 and {"factorissimo-dispatch.empty"} or {"factorissimo-dispatch.nothing-found"}
    hint.style.padding = 12
    local slots = 0
    for i = first, math.min(#list, first + PAGE_SIZE - 1) do
        local entry = list[i]
        local factory = storage.factories[entry.id]
        if factory and factory.layout and factory.force == player.force
            and (entry.packed or is_standing(factory, player.force.index)) then
            slots = slots + 1
            entry.tree = result.tree
            add_row(list_flow, factory, factory.id == state.selected, entry, slots, result.revision)
        end
    end
    for i = #list_flow.children, slots + 1, -1 do list_flow.children[i].destroy() end
    scroll.tags = {view_key = result and result.key}
    if state.scroll_selected and not pending then
        for _, row in pairs(list_flow.children) do
            if row.tags.id == state.selected then scroll.scroll_to_element(row, "in-view"); break end
        end
        state.scroll_selected = nil
    end

end

local function same_caption(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return a == b end
    if #a ~= #b then return false end
    for i = 1, #a do if not same_caption(a[i], b[i]) then return false end end
    return true
end

local function add_info(info, key, value, tooltip)
    local label, value_label = info[key .. "-label"], info[key .. "-value"]
    if not label then
        label = info.add {type = "label", name = key .. "-label", caption = {"factorissimo-dispatch." .. key}, style = "bold_label"}
        label.style.minimal_width = 100
        value_label = info.add {type = "label", name = key .. "-value"}
        value_label.style.single_line = false
        value_label.style.maximal_width = 170
    end
    local visible = value ~= nil
    if label.visible ~= visible then label.visible = visible; value_label.visible = visible end
    if not visible then return end
    if not same_caption(value_label.caption, value) then value_label.caption = value end
    tooltip = tooltip or ""
    if not same_caption(value_label.tooltip, tooltip) then value_label.tooltip = tooltip end
end

local CONNECTION_TYPES = {"belt", "chest", "fluid", "heat", "circuit"}

local function fill_info(info, factory, summary)
    summary = summary or info
    local layout = factory.layout
    local status_sprite, status_caption = status_of(factory)
    add_info(summary, "info-state", {"", "[img=" .. status_sprite .. "] ", status_caption})

    local ratio = factory.power_ratio
    local power
    if not factorissimo.is_factory_wired(factory) then
        power = {"factorissimo-dispatch.power-none"}
    elseif ratio then
        power = {"factorissimo-dispatch.percent", tostring(floor(ratio * 100 + 0.5))}
    else
        power = {"factorissimo-dispatch.measuring"}
    end
    add_info(summary, "info-power", power)

    local use, gen = factory.power_use, factory.power_gen or 0
    add_info(info, "info-consumption", use and {"factorissimo-dispatch.approx", format_power(use)} or {"factorissimo-dispatch.measuring"},
        {"factorissimo-dispatch.power-scope"})
    local generators = factory.generators or 0
    local producing = use and (generators > 0 or gen > 0)
    add_info(info, "info-production", producing and format_power(gen) or nil,
        {"", {"factorissimo-dispatch.power-scope"}, "\n", {"factorissimo-dispatch.generators", tostring(factory.generators_working or 0), tostring(generators)}})
    local net = gen - (use or 0)
    local balance = use and (net == 0 and format_power(0) or net > 0 and {"", "[color=#80e080]+", format_power(net), "[/color]"}
        or {"", "−", format_power(-net)}) or nil
    add_info(info, "info-balance", balance, {"factorissimo-dispatch.balance-tooltip"})

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

    add_info(info, "info-machines", factory.active_tick and
        {"factorissimo-dispatch.machines", tostring(factory.machines_working or 0), tostring(factory.machines or 0)}
        or {"factorissimo-dispatch.measuring"}, {"factorissimo-dispatch.own-room"})
    add_info(info, "info-sample", factory.active_tick and
        {"factorissimo-dispatch.sample-age", tostring(math.max(0, floor((game.tick - factory.active_tick) / 60)))}
        or {"factorissimo-dispatch.measuring"}, {"factorissimo-dispatch.sample-tooltip"})

    local children = factory.children or 0
    add_info(info, "info-children", children > 0 and tostring(children) or nil)
    add_info(info, "info-depth", depth_of(factory))

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

local function update_path(details, factory)
    local path = details.path
    local revision = storage.dispatch.revision or 0
    if path.tags.revision == revision then return end
    path.clear(); path.tags = {revision = revision}
    local items, ids, seen = {location_caption(factory)}, {}, {[factory.id] = true}
    local current = factory
    for _ = 1, 32 do
        current = parent_of(current)
        if not current or seen[current.id] then break end
        seen[current.id] = true
        ids[#ids + 1] = current.id
        items[#items + 1] = current.built and factorissimo.factory_caption(current)
            or {"factorissimo-dispatch.packed-parent", factorissimo.factory_caption(current)}
    end
    if #ids == 0 then
        local label = path.add {type = "label", caption = location_caption(factory)}
        label.style.maximal_width = 300
    else
        local dropdown = path.add {type = "drop-down", name = P .. "path", items = items, selected_index = 1,
            tags = {ids = ids}, tooltip = {"factorissimo-dispatch.path-tooltip"}}
        dropdown.style.width = 260
        local parent = storage.factories[ids[1]]
        local up = tool_button(path, "select", "utility/hint_arrow_up", {"factorissimo-dispatch.parent"}, ids[1])
        up.enabled = parent and is_standing(parent, factory.force.index) or false
    end
end

local function build_details(frame, player, state)
    local details = frame.body.details.scroll.content
    local factory = state.selected and storage.factories[state.selected]
    if not (factory and is_standing(factory, player.force.index)) then
        state.selected = nil
        if details.select_hint then return end
        details.clear()
        details.tags = {}
        local label = details.add {type = "label", name = "select_hint", caption = {"factorissimo-dispatch.select-hint"}}
        label.style.single_line = false
        label.style.padding = 12
        label.style.font_color = {r = 0.7, g = 0.7, b = 0.7}
        return
    end

    if details.tags.id == factory.id and details.info then
        fill_info(details.info, factory, details.summary)
        update_path(details, factory)
        details.rename.visible = state.rename_id == factory.id
        local title = details.header.titles.title
        local caption = factorissimo.factory_caption(factory)
        if not same_caption(title.caption, caption) then title.caption = caption end
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

    tool_button(titles, "rename", "utility/rename_icon", {"factorissimo-dispatch.rename-tooltip"}, factory.id)
    details.add {type = "flow", name = "path", direction = "horizontal"}
    update_path(details, factory)

    local rename = details.add {type = "flow", name = "rename", direction = "horizontal"}
    rename.style.vertical_align = "center"
    rename.visible = state.rename_id == factory.id
    local field = rename.add {type = "textfield", name = P .. "name",
        text = state.drafts and state.drafts[factory.id] or factory.name or "", tags = {id = factory.id},
        icon_selector = true, tooltip = {"factorissimo-dispatch.name-tooltip"}}
    field.style.width = 232
    field.lose_focus_on_confirm = true
    local confirm = rename.add {type = "sprite-button", name = P .. "name_confirm", sprite = "utility/check_mark", style = "tool_button_green",
        tags = {id = factory.id}, tooltip = {"factorissimo-dispatch.name-confirm"}}
    confirm.style.size = 28
    tool_button(rename, "name_cancel", "utility/close", {"factorissimo-dispatch.name-cancel"}, factory.id)

    local summary = details.add {type = "table", name = "summary", column_count = 2}
    summary.style.horizontal_spacing = 8
    local buttons = details.add {type = "flow", direction = "horizontal"}
    buttons.style.horizontal_spacing = 4
    for _, action in ipairs({"map", "inside"}) do
        local button = buttons.add {type = "button", name = P .. action, caption = {"factorissimo-dispatch." .. action},
            tags = {id = factory.id}, tooltip = {"factorissimo-dispatch." .. action .. "-tooltip"}}
        button.style.minimal_width = 0
        button.style.font = "default-small-semibold"
        button.style.horizontally_stretchable = true
    end

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
    fill_info(info, factory, summary)
end

local open
local function refresh(player)
    local frame = get_frame(player)
    if not frame then return end
    if frame.tags.schema ~= 2 then open(player); return end
    local state = player_state(player)
    build_list(frame, player, state)
    build_details(frame, player, state)
end

local function close(player)
    local frame = get_frame(player)
    if frame then frame.destroy() end
    local dispatch = storage.dispatch
    if dispatch then
        dispatch.open[player.index] = nil
        local state = dispatch.players[player.index]
        if state then state.result, state.job = nil, nil end
        release_idle_cache(dispatch)
    end
end

open = function(player)
    close(player)
    local state = player_state(player)
    local frame = player.gui.screen.add {type = "frame", name = FRAME, direction = "vertical", tags = {schema = 2}}
    local resolution, scale = player.display_resolution, player.display_scale
    local height = math.max(240, math.min(560, floor(resolution.height / scale) - 100))
    if state.location then
        frame.location = {x = math.max(0, math.min(state.location.x, resolution.width - 1040 * scale)),
            y = math.max(0, math.min(state.location.y, resolution.height - (height + 80) * scale))}
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
    local nav = left.add {type = "flow", name = "nav", direction = "horizontal"}
    nav.style.vertical_align = "center"
    nav.style.horizontal_spacing = 8
    tool_button(nav, "back", "utility/left_arrow", {"factorissimo-dispatch.back"})
    for _, view in ipairs({"list", "tree"}) do
        local button = nav.add {type = "button", name = P .. view, caption = {"factorissimo-dispatch.view-" .. view}, style = "tool_button"}
        button.style.minimal_width = 60
    end
    nav.add {type = "label", caption = {"factorissimo-dispatch.search"}}
    local search = nav.add {type = "textfield", name = P .. "search", text = state.search, tooltip = {"factorissimo-dispatch.search-tooltip"}}
    search.style.width = 180
    search.lose_focus_on_confirm = true
    tool_button(nav, "reset", "utility/reset", {"factorissimo-dispatch.reset-filters"})
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
    scroll.style.height = height - 96
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
    details_scroll.style.height = height
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

factorissimo.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    update_button(player)
    if player and get_frame(player) then
        -- Offline windows are removed from the refresh list, but survive in the player's GUI.
        storage.dispatch.open[player.index] = true
        storage.dispatch.dirty = true
    end
end)

factorissimo.on_event(defines.events.on_player_left_game, function(event)
    local dispatch = storage.dispatch
    if not dispatch then return end
    dispatch.open[event.player_index] = nil
    local state = dispatch.players[event.player_index]
    if state then state.job, state.result = nil, nil end
    release_idle_cache(dispatch)
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
    release_idle_cache(storage.dispatch)
end)

factorissimo.on_event("factory-toggle-dispatch", function(event)
    local player = game.get_player(event.player_index)
    if player and unlocked(player.force) then toggle(player) end
end)

-- PERIODIC REFRESH --

factorissimo.on_nth_tick(30, function(event)
    local dispatch = storage.dispatch
    if not (dispatch and next(dispatch.open)) then return end
    dispatch.watching = {}
    local searching = false
    for index in pairs(dispatch.open) do
        local player = game.get_player(index)
        local state = dispatch.players[index]
        if player and player.connected and state then
            if state.problems then dispatch.watching[player.force.index] = true end
            if state.search_due and state.search_due <= event.tick then searching = true end
        end
    end
    local dirty = dispatch.dirty
    local light = event.tick % LIGHT_REFRESH == 0
    if not (dirty or light or dispatch.ready or searching) then return end
    dispatch.dirty, dispatch.ready = nil, nil
    for player_index in pairs(dispatch.open) do
        local player = game.get_player(player_index)
        if player and player.connected and get_frame(player) then
            refresh(player)
        else
            dispatch.open[player_index] = nil
            local state = dispatch.players[player_index]
            if state then state.job, state.result = nil, nil end
        end
    end
    release_idle_cache(dispatch)
end)

factorissimo.on_event(defines.events.on_forces_merged, function() factorissimo.dispatch_changed() end)
factorissimo.on_event({defines.events.on_player_display_resolution_changed, defines.events.on_player_display_scale_changed}, function(event)
    local player = game.get_player(event.player_index)
    if player and get_frame(player) then open(player) end
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
    if state.selected and state.selected ~= id then
        state.history[#state.history + 1] = state.selected
        if #state.history > 20 then table.remove(state.history, 1) end
    end
    state.selected = id
    state.reveal = id
    state.scroll_selected = true
    if state.view == "tree" and not (state.result and state.result.positions[id]) then query_changed(state) end
    local frame = get_frame(player)
    if not frame then return end
    build_list(frame, player, state)
    build_details(frame, player, state)
end

local function rename(player, factory, field)
    factorissimo.set_factory_name(factory, field.text)
    field.text = factory.name or ""
    local state = player_state(player)
    state.rename_id = nil
    if state.drafts then state.drafts[factory.id] = nil end
    local frame = get_frame(player)
    if frame then refresh(player) end
end

local click_actions = {
    close = function(player) close(player) end,
    refresh = function(player) factorissimo.dispatch_changed(); refresh(player) end,
    list = function(player)
        local state = player_state(player); state.view = "list"; state.page = 1; query_changed(state); refresh(player)
    end,
    tree = function(player)
        local state = player_state(player); state.view = "tree"; state.page = 1
        state.reveal = state.selected; query_changed(state); refresh(player)
    end,
    expand = function(player, element)
        local state = player_state(player)
        local id = element.tags.id
        state.expanded[id] = not state.expanded[id]
        state.reveal = nil
        query_changed(state); refresh(player)
    end,
    back = function(player)
        local state = player_state(player)
        while #state.history > 0 do
            local id = table.remove(state.history)
            local factory = storage.factories[id]
            if factory and is_standing(factory, player.force.index) then
                state.selected = nil; select_factory(player, id); return
            end
        end
        refresh(player)
    end,
    reset = function(player)
        local state = player_state(player)
        state.search, state.tier, state.problems, state.page = "", nil, false, 1
        state.search_due = nil
        query_changed(state)
        local frame = get_frame(player)
        if frame then frame.body.left.nav[P .. "search"].text = ""; frame.body.left.toolbar.bar.tags = {} end
        refresh(player)
    end,
    name_cancel = function(player, element)
        local state = player_state(player)
        state.rename_id = nil
        if state.drafts then state.drafts[element.tags.id] = nil end
        local factory = factory_of(element, player)
        if factory then element.parent[P .. "name"].text = factory.name or "" end
        element.parent.visible = false
    end,
    select = function(player, element)
        local factory = factory_of(element, player)
        if factory then select_factory(player, factory.id) end
    end,
    rename = function(player, element)
        local factory = factory_of(element, player)
        if not factory then return end
        player_state(player).rename_id = factory.id
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
        query_changed(state)
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
    if not element then return end
    local state = player_state(player)
    if element.name == P .. "name" then
        state.drafts = state.drafts or {}; state.drafts[element.tags.id] = element.text
    elseif element.name == P .. "search" then
        state.search = element.text; state.page = 1
        query_changed(state)
        state.search_due = game.tick + 15
    end
end

gui_events[defines.events.on_gui_checked_state_changed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element or element.name ~= P .. "problems" then return end
    local state = player_state(player)
    state.problems = element.state
    state.page = 1
    query_changed(state)
    factorissimo.dispatch_changed() -- populate problem flags when enabling this filter
    refresh(player)
end

gui_events[defines.events.on_gui_selection_state_changed]["^" .. P] = function(event)
    local element, player = own_element(event)
    if not element then return end
    if element.name == P .. "path" then
        local id = element.tags.ids[element.selected_index - 1]
        element.selected_index = 1
        local factory = id and storage.factories[id]
        if factory and is_standing(factory, player.force.index) then select_factory(player, id) end
    elseif element.name == P .. "sort" then
        local state = player_state(player)
        state.sort = SORTS[element.selected_index] or "id"
        query_changed(state)
        refresh(player)
    end
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
