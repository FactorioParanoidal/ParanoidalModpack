-- GUI of the quality-control expansion:
--   * the quality-control panel (shortcut / Ctrl+Shift+Q): production, refinement and orders tabs;
--   * panels attached to the vanilla GUI of a workshop, a control post and any assembling machine
--     or furnace (production mode).
-- Elements carry tags.ic = action; dynamic parts are rebuilt only while they are open.
local names = require("scripts.expansion.names")
local rules = require("scripts.expansion.rules")
local model = require("scripts.defects.model")
local workshop = require("scripts.expansion.workshop")
local post = require("scripts.expansion.post")
local modes = require("scripts.expansion.modes")
local stats = require("scripts.stats")

local M = {}
local PANEL = "ic_quality_panel"
local RELATIVE = "ic_quality_relative"

---------------------------------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------------------------------
function M.player_settings(index)
    storage.ic_players = storage.ic_players or {}
    local settings = storage.ic_players[index]
    if not settings then
        settings = {alerts = true, notify = true}
        storage.ic_players[index] = settings
    end
    return settings
end

local function percent(value, digits)
    return string.format("%." .. (digits or 1) .. "f%%", (value or 0) * 100)
end

local function packs(durability)
    return string.format("%.1f", (durability or 0) / rules.PACK_DURABILITY)
end

local function quality_rich(name)
    return "[quality=" .. name .. "]"
end

local function grade_caption(grade)
    if grade == 0 then return {"", quality_rich("normal"), " ", {"ic-quality.grade-0"}} end
    return {"", quality_rich(model.quality_name(grade)), " ", {"ic-quality.grade-" .. tostring(-grade)}}
end

local function label(parent, caption, style, tooltip)
    local element = parent.add({type = "label", caption = caption, style = style, tooltip = tooltip})
    return element
end

local function heading(parent, caption)
    local element = label(parent, caption, "caption_label")
    element.style.top_margin = 6
    return element
end

local function stretch(element)
    element.style.horizontally_stretchable = true
    return element
end

local function progressbar(parent, value, caption, width)
    local bar = parent.add({type = "progressbar", value = math.max(0, math.min(1, value or 0)), caption = caption})
    bar.style.width = width or 260
    return bar
end

local function key_value_table(parent)
    local tbl = parent.add({type = "table", column_count = 2})
    tbl.style.horizontal_spacing = 16
    tbl.style.vertical_spacing = 2
    return tbl
end

local function row(tbl, key, value, tooltip)
    label(tbl, key, nil, tooltip)
    local value_label = label(tbl, value, "bold_label", tooltip)
    return value_label
end

local status_sprites = {
    working = "utility/status_working", reset = "utility/status_working", passing = "utility/status_working",
    ["no-resource"] = "utility/status_not_working",
}
local function status_sprite(key)
    return status_sprites[key] or "utility/status_yellow"
end

local function titlebar(frame, caption, close_action)
    local bar = frame.add({type = "flow", direction = "horizontal"})
    bar.drag_target = frame
    label(bar, caption, "frame_title").ignored_by_interaction = true
    local filler = bar.add({type = "empty-widget", style = "draggable_space_header"})
    filler.style.height = 24
    filler.style.horizontally_stretchable = true
    filler.ignored_by_interaction = true
    bar.add({type = "sprite-button", style = "close_button", sprite = "utility/close",
        tooltip = {"gui.close"}, tags = {ic = close_action}})
end

local function find_entity_by_unit(unit)
    for _, root in ipairs({storage.ic_workshops, storage.ic_posts, storage.ic_modes}) do
        local record = root and root.records[unit]
        if record and record.entity.valid then return record.entity end
    end
end

-- player.opened may also be a gui_type number or another object: only entities count.
local function opened_entity(player)
    local entity = player.opened
    local kind = type(entity)
    if (kind == "userdata" or kind == "table") and entity.object_name == "LuaEntity" and entity.valid then return entity end
end

local function sorted_qualities(include_defects)
    local list = {}
    for name, quality in pairs(prototypes.quality) do
        if not quality.hidden and (include_defects or not model.is_defect(name)) then list[#list + 1] = quality end
    end
    table.sort(list, function(a, b)
        local ga, gb = model.grade_of(a.name), model.grade_of(b.name)
        if ga ~= gb then return ga < gb end
        if a.level ~= b.level then return a.level < b.level end
        return a.order < b.order
    end)
    return list
end

---------------------------------------------------------------------------------------------------
-- Panel: production tab
---------------------------------------------------------------------------------------------------
local function distribution_rows(parent, level)
    local tbl = parent.add({type = "table", column_count = 4, style = "bordered_table"})
    for _, caption in ipairs({{"ic-quality.col-grade"}, {"ic-quality.col-now"}, {"ic-quality.col-next"},
        {"ic-quality.col-careful"}}) do
        label(tbl, caption, "bold_label")
    end
    local now = model.distribution(level)
    local next_level = math.min(10, level + 1)
    local next_d = model.distribution(next_level)
    local careful = model.distribution(rules.effective_level(level, rules.modes.careful))
    for grade = -5, 0 do
        label(tbl, grade_caption(grade))
        label(tbl, percent(now[grade], 2))
        label(tbl, percent(next_d[grade], 2))
        label(tbl, percent(careful[grade], 2))
    end
end

local function warnings_of(force)
    local result = {}
    local s = storage.ic_defects
    local prefix = force.index .. ":"
    for key in pairs(s and s.warnings or {}) do
        if key:sub(1, #prefix) == prefix then
            local status, name = key:sub(#prefix + 1):match("^([^:]+):(.+)$")
            if status and name then result[#result + 1] = {status = status, name = name} end
        end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

local function lookup_result(parent, item)
    if not item then
        label(parent, {"ic-quality.lookup-empty"}).style.single_line = false
        return
    end
    local finished = prototypes.mod_data["ic-defects-classification"]
    finished = finished and finished.data.finished or {}
    local expansion = prototypes.mod_data[names.mod_data]
    local reasons = expansion and expansion.data.reasons or {}
    local text
    if finished[item] then
        text = {"ic-quality.lookup-finished", "[item=" .. item .. "]"}
    else
        local reason = reasons[item]
        text = {"ic-quality.lookup-material", "[item=" .. item .. "]",
            reason and {"ic-quality.reason-" .. reason} or {"ic-quality.reason-intermediate"}}
    end
    local line = label(parent, text)
    line.style.single_line = false
    line.style.maximal_width = 520
    local entry = workshop.costs()[item]
    if entry then
        local tbl = key_value_table(parent)
        row(tbl, {"ic-quality.attempt-cost"}, {"ic-quality.packs-seconds", packs(entry.cost), string.format("%.1f", entry.seconds)})
        row(tbl, {"ic-quality.science-kinds"}, entry.kinds and tostring(entry.kinds) or {"ic-quality.no-research"})
        row(tbl, {"ic-quality.max-health"}, entry.health and tostring(entry.health) or "—")
    end
end

local function production_dynamic(parent, player)
    local force = player.force
    local level = model.completed_level(force.technologies)
    local percent_setting = settings.global["ic-more-qualities-initial-loss-percent"].value
    local top = parent.add({type = "flow", direction = "horizontal"})
    top.style.vertical_align = "center"
    label(top, {"ic-quality.control-level", level}, "caption_label")
    progressbar(top, level / 10, nil, 200)

    local tbl = key_value_table(parent)
    row(tbl, {"ic-quality.loss-now"}, percent(model.loss_probability(level, percent_setting)))
    row(tbl, {"ic-quality.loss-next"}, level < 10 and percent(model.loss_probability(level + 1, percent_setting)) or "—")
    row(tbl, {"ic-quality.loss-careful"}, percent(model.loss_probability(level, percent_setting) * rules.modes.careful.loss))
    row(tbl, {"ic-quality.loss-precise"}, percent(0))

    heading(parent, {"ic-quality.distribution"})
    distribution_rows(parent, level)

    heading(parent, {"ic-quality.counted"})
    local counters = stats.get(force.index)
    local ctbl = parent.add({type = "table", column_count = 3, style = "bordered_table"})
    for _, caption in ipairs({{"ic-quality.col-source"}, {"ic-quality.col-operations"}, {"ic-quality.col-losses"}}) do
        label(ctbl, caption, "bold_label")
    end
    for _, source in ipairs({"hand", "machine", "drill", "mining"}) do
        local ops, losses = counters[source .. ".ops"] or 0, counters[source .. ".loss"] or 0
        label(ctbl, {"ic-quality.source-" .. source})
        label(ctbl, tostring(ops))
        label(ctbl, ops > 0 and {"", tostring(losses), " (", percent(losses / ops), ")"} or tostring(losses))
    end
    local grades = parent.add({type = "flow", direction = "horizontal"})
    label(grades, {"ic-quality.assigned"})
    for grade = -5, 0 do
        label(grades, {"", quality_rich(model.quality_name(grade)), " ", tostring(counters["grade." .. grade] or 0)})
    end
    local mtbl = key_value_table(parent)
    row(mtbl, {"ic-quality.mode-careful-ops"}, tostring(counters["mode.careful"] or 0))
    row(mtbl, {"ic-quality.mode-precise-ops"}, tostring(counters["mode.precise"] or 0))
    row(mtbl, {"ic-quality.mode-boosts"}, tostring(counters["mode.boost"] or 0))

    local skipped = warnings_of(force)
    heading(parent, {"ic-quality.skipped", #skipped})
    if #skipped == 0 then
        label(parent, {"ic-quality.skipped-none"})
    else
        local stbl = parent.add({type = "table", column_count = 2})
        for index = 1, math.min(20, #skipped) do
            local entry = skipped[index]
            local prototype = prototypes.entity[entry.name]
            label(stbl, {"", "[entity=" .. entry.name .. "] ", prototype and prototype.localised_name or entry.name})
            label(stbl, {"ic-quality.skip-reason-" .. entry.status})
        end
    end
end

local function production_tab(content, player)
    local dynamic = content.add({type = "flow", name = "dyn", direction = "vertical"})
    production_dynamic(dynamic, player)
    content.add({type = "line"}).style.top_margin = 6
    heading(content, {"ic-quality.lookup"})
    local settings = M.player_settings(player.index)
    local flow = content.add({type = "flow", direction = "horizontal"})
    local button = flow.add({type = "choose-elem-button", elem_type = "item", tags = {ic = "lookup"}})
    button.elem_value = settings.lookup
    local result = flow.add({type = "flow", name = "lookup_result", direction = "vertical"})
    lookup_result(result, settings.lookup)
end

---------------------------------------------------------------------------------------------------
-- Panel: refinement tab
---------------------------------------------------------------------------------------------------
local function workshops_of(force)
    local list = {}
    local s = storage.ic_workshops
    for _, record in pairs(s and s.records or {}) do
        if record.entity.valid and record.entity.force == force then list[#list + 1] = record end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

local function forecast(parent, value)
    if not (value and value.name) then
        label(parent, {"ic-quality.forecast-empty"}).style.single_line = false
        return
    end
    local grade = model.grade_of(value.quality or "normal")
    local cost, seconds = workshop.cost_of(value.name)
    local tbl = key_value_table(parent)
    row(tbl, {"ic-quality.attempt-cost"}, {"ic-quality.packs-seconds", packs(cost), string.format("%.1f", seconds)})
    if grade >= 0 then
        row(tbl, {"ic-quality.forecast-result"}, {"ic-quality.forecast-not-defect"})
        return
    end
    local expected = rules.expected_attempts(grade)
    row(tbl, {"ic-quality.expected-attempts"}, string.format("%.2f", expected))
    row(tbl, {"ic-quality.expected-resource"}, {"ic-quality.packs", packs(expected * cost)})
    row(tbl, {"ic-quality.expected-time"}, {"ic-quality.seconds", string.format("%.0f", expected * seconds)})
    local d = rules.refine_distribution(grade)
    local flow = parent.add({type = "flow", direction = "horizontal"})
    label(flow, {"ic-quality.one-attempt"})
    for target = grade, 0 do
        if d[target] and d[target] > 0 then label(flow, {"", quality_rich(model.quality_name(target)), " ", percent(d[target], 3)}) end
    end
end

local function refinement_dynamic(parent, player)
    local list = workshops_of(player.force)
    heading(parent, {"ic-quality.workshops", #list})
    if #list == 0 then
        label(parent, {"ic-quality.workshops-none"}).style.single_line = false
    else
        local scroll = parent.add({type = "scroll-pane", style = "naked_scroll_pane"})
        scroll.style.maximal_height = 220
        local tbl = scroll.add({type = "table", column_count = 6, style = "bordered_table"})
        for _, caption in ipairs({"", {"ic-quality.col-item"}, {"ic-quality.col-state"}, {"ic-quality.col-progress"},
            {"ic-quality.col-resource"}, ""}) do
            label(tbl, caption, "bold_label")
        end
        for index = 1, math.min(60, #list) do
            local record = list[index]
            local info = workshop.describe(record)
            tbl.add({type = "sprite", sprite = status_sprite(info.status)})
            if info.item and prototypes.item[info.item] then
                label(tbl, {"", "[item=" .. info.item .. "] ", info.grade and grade_caption(info.grade) or ""})
            else
                label(tbl, "—")
            end
            label(tbl, {"ic-quality.workshop-state-" .. info.status})
            progressbar(tbl, info.kind == "refine" and info.progress or 0, nil, 110)
            label(tbl, {"ic-quality.packs", packs(info.available)})
            tbl.add({type = "sprite-button", style = "tool_button", sprite = "utility/gps_map_icon",
                tooltip = {"ic-quality.show"}, tags = {ic = "show", unit = record.id}})
        end
    end

    local counters = stats.get(player.force.index)
    heading(parent, {"ic-quality.refine-stats"})
    local attempts = counters["refine.attempts"] or 0
    local success = counters["refine.success"] or 0
    local tbl = key_value_table(parent)
    row(tbl, {"ic-quality.attempts"}, tostring(attempts))
    row(tbl, {"ic-quality.success-rate"}, attempts > 0
        and {"ic-quality.success-vs-expected", percent(success / attempts), percent(rules.SUCCESS, 0), attempts}
        or {"ic-quality.success-expected", percent(rules.SUCCESS, 0)})
    row(tbl, {"ic-quality.jumps"}, {"ic-quality.jumps-value", counters["refine.jump1"] or 0,
        counters["refine.jump2"] or 0, counters["refine.jump3"] or 0})
    row(tbl, {"ic-quality.normalized"}, tostring(counters["refine.normalized"] or 0))
    row(tbl, {"ic-quality.resets"}, tostring(counters["refine.resets"] or 0))
    row(tbl, {"ic-quality.passed"}, tostring(counters["refine.passed"] or 0))
    local resource = counters["refine.resource"] or 0
    row(tbl, {"ic-quality.resource-spent"}, {"ic-quality.packs", packs(resource)})
    row(tbl, {"ic-quality.resource-per-success"}, success > 0 and {"ic-quality.packs", packs(resource / success)} or "—")
end

local function refinement_tab(content, player)
    local dynamic = content.add({type = "flow", name = "dyn", direction = "vertical"})
    refinement_dynamic(dynamic, player)
    content.add({type = "line"}).style.top_margin = 6
    heading(content, {"ic-quality.forecast"})
    local settings = M.player_settings(player.index)
    local flow = content.add({type = "flow", direction = "horizontal"})
    local button = flow.add({type = "choose-elem-button", elem_type = "item-with-quality", tags = {ic = "forecast"}})
    if settings.forecast then button.elem_value = settings.forecast end
    local result = flow.add({type = "flow", name = "forecast_result", direction = "vertical"})
    forecast(result, settings.forecast)
    content.add({type = "line"}).style.top_margin = 6
    content.add({type = "checkbox", caption = {"ic-quality.alerts"}, tooltip = {"ic-quality.alerts-tooltip"},
        state = settings.alerts ~= false, tags = {ic = "alerts"}})
    content.add({type = "checkbox", caption = {"ic-quality.notify"}, state = settings.notify ~= false,
        tags = {ic = "notify"}})
end

---------------------------------------------------------------------------------------------------
-- Panel: orders tab
---------------------------------------------------------------------------------------------------
local function order_caption(order)
    if not order.item then return {"ic-quality.order-none"} end
    local condition = order.condition == "strict" and {"ic-quality.condition-strict"}
        or {"", {"ic-quality.condition-at-least"}, " ", quality_rich(order.quality)}
    return {"", "[item=" .. order.item .. "] ", condition}
end

local function orders_dynamic(parent, player)
    local list = {}
    local s = storage.ic_posts
    for _, record in pairs(s and s.records or {}) do
        if record.entity.valid and record.entity.force == player.force then list[#list + 1] = record end
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    heading(parent, {"ic-quality.posts", #list})
    if #list == 0 then
        label(parent, {"ic-quality.posts-none"}).style.single_line = false
        return
    end
    local scroll = parent.add({type = "scroll-pane", style = "naked_scroll_pane"})
    scroll.style.maximal_height = 420
    local tbl = scroll.add({type = "table", column_count = 5, style = "bordered_table"})
    for _, caption in ipairs({{"ic-quality.col-order"}, {"ic-quality.col-state"}, {"ic-quality.col-progress"},
        {"ic-quality.col-batches"}, ""}) do
        label(tbl, caption, "bold_label")
    end
    for _, record in ipairs(list) do
        label(tbl, order_caption(record.order))
        label(tbl, {"ic-quality.order-state-" .. record.state})
        local required = record.order.required or 1
        progressbar(tbl, record.accepted / required, {"", record.accepted, " / ", required}, 140)
        label(tbl, tostring(record.batches or 0))
        tbl.add({type = "sprite-button", style = "tool_button", sprite = "utility/gps_map_icon",
            tooltip = {"ic-quality.show"}, tags = {ic = "show", unit = record.id}})
    end
end

local function orders_tab(content, player)
    local dynamic = content.add({type = "flow", name = "dyn", direction = "vertical"})
    orders_dynamic(dynamic, player)
    content.add({type = "line"}).style.top_margin = 6
    local hint = label(content, {"ic-quality.orders-hint"})
    hint.style.single_line = false
    hint.style.maximal_width = 560
end

---------------------------------------------------------------------------------------------------
-- Panel frame
---------------------------------------------------------------------------------------------------
local tabs = {
    {name = "production", caption = {"ic-quality.tab-production"}, build = production_tab, refresh = production_dynamic},
    {name = "refinement", caption = {"ic-quality.tab-refinement"}, build = refinement_tab, refresh = refinement_dynamic},
    {name = "orders", caption = {"ic-quality.tab-orders"}, build = orders_tab, refresh = orders_dynamic},
}

function M.close_panel(player)
    local frame = player.gui.screen[PANEL]
    if frame then frame.destroy() end
    player.set_shortcut_toggled(names.panel_shortcut, false)
end

function M.open_panel(player)
    M.close_panel(player)
    local settings = M.player_settings(player.index)
    local frame = player.gui.screen.add({type = "frame", name = PANEL, direction = "vertical"})
    titlebar(frame, {"ic-quality.panel-title"}, "panel-close")
    local inside = frame.add({type = "frame", style = "inside_deep_frame", direction = "vertical"})
    local pane = inside.add({type = "tabbed-pane", name = "tabs", tags = {ic = "panel-tab"}})
    for index, tab in ipairs(tabs) do
        local button = pane.add({type = "tab", caption = tab.caption})
        local scroll = pane.add({type = "scroll-pane", name = tab.name})
        scroll.style.maximal_height = 640
        scroll.style.minimal_width = 600
        scroll.style.padding = 10
        tab.build(scroll, player)
        pane.add_tab(button, scroll)
        if settings.tab == tab.name then pane.selected_tab_index = index end
    end
    if not pane.selected_tab_index then pane.selected_tab_index = 1 end
    frame.force_auto_center()
    player.set_shortcut_toggled(names.panel_shortcut, true)
end

function M.toggle_panel(player)
    if player.gui.screen[PANEL] then M.close_panel(player) else M.open_panel(player) end
end

function M.refresh_panel(player)
    local frame = player.gui.screen[PANEL]
    if not frame then return end
    local pane = frame.children[2] and frame.children[2].tabs
    if not pane then return end
    local tab = tabs[pane.selected_tab_index or 1]
    local content = tab and pane[tab.name]
    local dynamic = content and content.dyn
    if not dynamic then return end
    dynamic.clear()
    tab.refresh(dynamic, player)
end

---------------------------------------------------------------------------------------------------
-- Relative panels
---------------------------------------------------------------------------------------------------
local function relative_frame(player, entity, gui_type, caption)
    local old = player.gui.relative[RELATIVE]
    if old then old.destroy() end
    local frame = player.gui.relative.add({
        type = "frame", name = RELATIVE, direction = "vertical", caption = caption,
        anchor = {gui = gui_type, position = defines.relative_gui_position.right, names = {entity.name}},
        tags = {unit = entity.unit_number},
    })
    frame.style.maximal_width = 420
    local inside = frame.add({type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"})
    return inside
end

local function workshop_dynamic(parent, record)
    local info = workshop.describe(record)
    local status = parent.add({type = "flow", direction = "horizontal"})
    status.style.vertical_align = "center"
    status.add({type = "sprite", sprite = status_sprite(info.status)})
    label(status, {"ic-quality.workshop-state-" .. info.status}, "bold_label")

    local tbl = key_value_table(parent)
    if info.item and prototypes.item[info.item] then
        row(tbl, {"ic-quality.current-item"}, {"", "[item=" .. info.item .. "] ",
            info.grade and info.grade < 0 and grade_caption(info.grade) or {"ic-quality.kind-" .. info.kind}})
    else
        row(tbl, {"ic-quality.current-item"}, "—")
    end
    row(tbl, {"ic-quality.resource-available"}, {"ic-quality.packs", packs(info.available)},
        {"ic-quality.resource-available-tooltip"})
    if info.kind == "refine" then
        row(tbl, {"ic-quality.attempt-cost"}, {"ic-quality.packs-seconds", packs(info.cost), string.format("%.1f", info.seconds)})
        row(tbl, {"ic-quality.attempt-number"}, tostring(info.attempts + 1))
        row(tbl, {"ic-quality.affordable"}, string.format("%.1f", info.available / math.max(1, info.cost)))
        progressbar(parent, info.progress, {"ic-quality.attempt-progress", math.floor((info.progress or 0) * 100)}, 360)
        progressbar(parent, info.paid, {"ic-quality.attempt-paid", math.floor((info.paid or 0) * 100)}, 360)
        if info.distribution then
            heading(parent, {"ic-quality.outcomes"})
            local otbl = parent.add({type = "table", column_count = 2, style = "bordered_table"})
            for target = info.grade, 0 do
                local p = info.distribution[target]
                if p and p > 0 then
                    label(otbl, target == info.grade and {"ic-quality.outcome-same", grade_caption(target)} or grade_caption(target))
                    label(otbl, percent(p, 3))
                end
            end
            label(parent, {"ic-quality.expected-to-normal", string.format("%.2f", info.expected),
                packs(info.expected * info.cost)}).style.single_line = false
        end
    end
end

local function workshop_panel(player, entity)
    local record = workshop.track(entity)
    if not record then return end
    local inside = relative_frame(player, entity, defines.relative_gui_type.furnace_gui, {"ic-quality.workshop-title"})
    local dynamic = inside.add({type = "flow", name = "dyn", direction = "vertical"})
    workshop_dynamic(dynamic, record)
    inside.add({type = "line"}).style.top_margin = 6
    inside.add({type = "checkbox", caption = {"ic-quality.reset-positive"}, tooltip = {"ic-quality.reset-positive-tooltip"},
        state = record.settings.reset_positive, tags = {ic = "ws-reset"}})
    inside.add({type = "checkbox", caption = {"ic-quality.circuit-control"}, tooltip = {"ic-quality.workshop-circuit-tooltip"},
        state = record.settings.circuit, tags = {ic = "ws-circuit"}})
    local note = label(inside, {"ic-quality.workshop-note"})
    note.style.single_line = false
    note.style.font_color = {0.75, 0.75, 0.75}
end

local function mode_panel(player, entity, gui_type)
    local inside = relative_frame(player, entity, gui_type, {"ic-quality.mode-title"})
    local current = modes.mode_name(entity)
    local force = entity.force
    local level = model.completed_level(force.technologies)
    local loss = model.loss_probability(level, settings.global["ic-more-qualities-initial-loss-percent"].value)
    local effects = entity.effects
    local quality_effect = effects and effects.quality or 0
    local chance = math.min(1, quality_effect * (prototypes.quality.normal.next_probability or 0.1))

    for _, name in ipairs(rules.mode_order) do
        inside.add({type = "radiobutton", caption = {"ic-quality.mode-" .. name}, tooltip = {"ic-quality.mode-" .. name .. "-tooltip"},
            state = current == name, tags = {ic = "mode", mode = name}})
    end
    local tbl = inside.add({type = "table", column_count = 4, style = "bordered_table"})
    tbl.style.top_margin = 6
    label(tbl, "")
    for _, name in ipairs(rules.mode_order) do label(tbl, {"ic-quality.mode-" .. name}, "bold_label") end
    local function line(caption, values)
        label(tbl, caption)
        for _, value in ipairs(values) do label(tbl, value) end
    end
    local function worst(mode)
        if mode.no_defect then return grade_caption(0) end
        local effective = rules.effective_level(level, mode)
        return grade_caption(-5 + math.floor(effective / 2))
    end
    local m = rules.modes
    line({"ic-quality.row-time"}, {"×1", "×5", "×20"})
    line({"ic-quality.row-energy"}, {"×1", "×10", "×100"})
    line({"ic-quality.row-power"}, {"×1", "×2", "×5"})
    line({"ic-quality.row-loss"}, {percent(loss), percent(loss * m.careful.loss), percent(0)})
    line({"ic-quality.row-worst"}, {worst(m.normal), worst(m.careful), worst(m.precise)})
    line({"ic-quality.row-quality"}, {percent(chance, 2), percent(rules.boosted_chance(chance, m.careful.boost), 2),
        percent(rules.boosted_chance(chance, m.precise.boost), 2)})
    local note = label(inside, {"ic-quality.mode-note"})
    note.style.single_line = false
    note.style.font_color = {0.75, 0.75, 0.75}
end

local function post_dynamic(parent, record)
    local tbl = key_value_table(parent)
    row(tbl, {"ic-quality.col-state"}, {"ic-quality.order-state-" .. record.state})
    local required = record.order.required or 1
    progressbar(parent, record.accepted / required, {"", {"ic-quality.accepted"}, " ", record.accepted, " / ", required}, 360)
    local stbl = key_value_table(parent)
    row(stbl, {"ic-quality.batches"}, tostring(record.batches or 0))
    row(stbl, {"ic-quality.sent-good"}, tostring(record.sent.good or 0))
    row(stbl, {"ic-quality.sent-refine"}, tostring(record.sent.refine or 0))
    row(stbl, {"ic-quality.sent-other"}, tostring(record.sent.other or 0))
    local blocked = {}
    for _, route in ipairs(post.routes) do
        local direction = rules.output_direction(record.facing, route)
        if record.blocked and record.blocked[direction] then blocked[#blocked + 1] = route end
    end
    if #blocked > 0 then
        local caption = {""}
        for _, route in ipairs(blocked) do caption[#caption + 1] = {"ic-quality.route-" .. route}; caption[#caption + 1] = " " end
        local warning = label(parent, {"ic-quality.outputs-blocked", caption})
        warning.style.font_color = {1, 0.75, 0.3}
    end
end

local function post_panel(player, entity)
    local record = post.track(entity)
    if not record then return end
    local inside = relative_frame(player, entity, defines.relative_gui_type.container_gui, {"ic-quality.post-title"})
    local order = record.order

    local item_flow = inside.add({type = "flow", direction = "horizontal"})
    item_flow.style.vertical_align = "center"
    label(item_flow, {"ic-quality.order-item"})
    local chooser = item_flow.add({type = "choose-elem-button", elem_type = "item", tags = {ic = "post-item"}})
    chooser.elem_value = order.item

    local condition_flow = inside.add({type = "flow", direction = "horizontal"})
    condition_flow.style.vertical_align = "center"
    label(condition_flow, {"ic-quality.order-condition"})
    condition_flow.add({type = "drop-down", items = {{"ic-quality.condition-strict"}, {"ic-quality.condition-at-least"}},
        selected_index = order.condition == "strict" and 1 or 2, tags = {ic = "post-condition"}})
    local qualities = sorted_qualities(false)
    local items, selected = {}, 1
    for index, quality in ipairs(qualities) do
        items[index] = {"", quality_rich(quality.name), " ", quality.localised_name}
        if quality.name == order.quality then selected = index end
    end
    local quality_dropdown = condition_flow.add({type = "drop-down", items = items, selected_index = selected,
        tags = {ic = "post-quality"}})
    quality_dropdown.enabled = order.condition ~= "strict"

    local amount_flow = inside.add({type = "flow", direction = "horizontal"})
    amount_flow.style.vertical_align = "center"
    label(amount_flow, {"ic-quality.order-required"})
    local field = amount_flow.add({type = "textfield", text = tostring(order.required), numeric = true,
        allow_decimal = false, allow_negative = false, tags = {ic = "post-required"}})
    field.style.width = 90
    amount_flow.add({type = "checkbox", caption = {"ic-quality.order-repeat"}, state = order.repeating,
        tags = {ic = "post-repeat"}})

    local buttons = inside.add({type = "flow", direction = "horizontal"})
    buttons.add({type = "button", style = "green_button", caption = {"ic-quality.order-start"}, tags = {ic = "post-start"}})
    buttons.add({type = "button", caption = record.state == "paused" and {"ic-quality.order-resume"} or {"ic-quality.order-pause"},
        tags = {ic = "post-pause"}})
    buttons.add({type = "button", style = "red_button", caption = {"ic-quality.order-cancel"}, tags = {ic = "post-cancel"}})

    inside.add({type = "line"}).style.top_margin = 4
    local dynamic = inside.add({type = "flow", name = "dyn", direction = "vertical"})
    post_dynamic(dynamic, record)

    inside.add({type = "line"}).style.top_margin = 4
    local legend = inside.add({type = "table", column_count = 2})
    for _, route in ipairs(post.routes) do
        legend.add({type = "sprite", sprite = "ic-post-arrow-" .. route}).style.size = 20
        label(legend, {"ic-quality.route-" .. route .. "-legend"})
    end
    local rotate = inside.add({type = "flow", direction = "horizontal"})
    rotate.style.vertical_align = "center"
    label(rotate, {"ic-quality.rotate-outputs"})
    rotate.add({type = "sprite-button", sprite = "utility/left_arrow", style = "tool_button",
        tooltip = {"ic-quality.rotate-left"}, tags = {ic = "post-rotate", step = 3}})
    rotate.add({type = "sprite-button", sprite = "utility/right_arrow", style = "tool_button",
        tooltip = {"ic-quality.rotate-right"}, tags = {ic = "post-rotate", step = 1}})
    inside.add({type = "checkbox", caption = {"ic-quality.circuit-control"}, tooltip = {"ic-quality.post-circuit-tooltip"},
        state = record.circuit, tags = {ic = "post-circuit"}})
end

function M.open_entity(player, entity)
    M.close_entity(player)
    if not (entity and entity.valid) then return end
    if entity.name == names.workshop then
        workshop_panel(player, entity)
    elseif entity.name == names.post then
        post_panel(player, entity)
    elseif modes.eligible(entity) then
        mode_panel(player, entity, entity.type == "furnace" and defines.relative_gui_type.furnace_gui
            or defines.relative_gui_type.assembling_machine_gui)
    end
end

function M.close_entity(player)
    local frame = player.gui.relative[RELATIVE]
    if frame then frame.destroy() end
end

function M.refresh_entity(player)
    local frame = player.gui.relative[RELATIVE]
    local entity = opened_entity(player)
    if not (frame and entity) then return end
    local dynamic = frame.children[1] and frame.children[1].dyn
    if not dynamic then return end
    if entity.name == names.workshop then
        local record = workshop.get(entity)
        if record then
            dynamic.clear()
            workshop_dynamic(dynamic, record)
        end
    elseif entity.name == names.post then
        local record = post.get(entity)
        if record then
            dynamic.clear()
            post_dynamic(dynamic, record)
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------


local function reopen(player)
    local entity = opened_entity(player)
    if entity then M.open_entity(player, entity) end
end

function M.on_click(event, hooks)
    local element = event.element
    local tags = element and element.valid and element.tags
    local action = tags and tags.ic
    if not action then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    if action == "panel-close" then
        M.close_panel(player)
    elseif action == "show" then
        local entity = find_entity_by_unit(tags.unit)
        if entity then player.centered_on = entity end
    elseif action:find("^post%-") then
        local entity = opened_entity(player)
        local record = entity and post.get(entity)
        if not record then return end
        if action == "post-start" then
            if not post.start(record) then player.print({"ic-quality.order-need-item"}) end
        elseif action == "post-pause" then
            post.pause(record)
        elseif action == "post-cancel" then
            post.cancel(record)
        elseif action == "post-rotate" then
            post.rotate(record, tags.step or 1)
        else
            return
        end
        reopen(player)
    end
end

function M.on_checked(event, hooks)
    local element = event.element
    local tags = element and element.valid and element.tags
    local action = tags and tags.ic
    if not action then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    local entity = opened_entity(player)
    if action == "alerts" then
        M.player_settings(player.index).alerts = element.state
    elseif action == "notify" then
        M.player_settings(player.index).notify = element.state
    elseif action == "ws-reset" or action == "ws-circuit" then
        local record = entity and workshop.get(entity)
        if not record then return end
        if action == "ws-reset" then record.settings.reset_positive = element.state
        else workshop.set_circuit(record, element.state) end
    elseif action == "mode" then
        if entity and element.state then
            modes.set(entity, tags.mode, hooks and hooks.track_machine)
            reopen(player)
        end
    elseif action == "post-repeat" or action == "post-circuit" then
        local record = entity and post.get(entity)
        if not record then return end
        if action == "post-repeat" then post.set_order(record, {repeating = element.state})
        else post.set_circuit(record, element.state) end
        M.refresh_entity(player)
    end
end

function M.on_elem_changed(event)
    local element = event.element
    local tags = element and element.valid and element.tags
    local action = tags and tags.ic
    if not action then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    local settings = M.player_settings(player.index)
    if action == "lookup" then
        settings.lookup = element.elem_value
        local result = element.parent.lookup_result
        result.clear()
        lookup_result(result, settings.lookup)
    elseif action == "forecast" then
        settings.forecast = element.elem_value
        local result = element.parent.forecast_result
        result.clear()
        forecast(result, settings.forecast)
    elseif action == "post-item" then
        local entity = opened_entity(player)
        local record = entity and post.get(entity)
        if record then
            post.set_order(record, {item = element.elem_value or false})
            if not element.elem_value then record.order.item = nil end
            M.refresh_entity(player)
        end
    end
end

function M.on_selection(event)
    local element = event.element
    local tags = element and element.valid and element.tags
    local action = tags and tags.ic
    if not action then return end
    local player = game.get_player(event.player_index)
    local entity = player and opened_entity(player)
    local record = entity and post.get(entity)
    if not record then return end
    if action == "post-condition" then
        post.set_order(record, {condition = element.selected_index == 1 and "strict" or "at-least"})
        reopen(player)
    elseif action == "post-quality" then
        local quality = sorted_qualities(false)[element.selected_index]
        if quality then post.set_order(record, {quality = quality.name}) end
        M.refresh_entity(player)
    end
end

function M.on_text(event)
    local element = event.element
    local tags = element and element.valid and element.tags
    if not (tags and tags.ic == "post-required") then return end
    local player = game.get_player(event.player_index)
    local entity = player and opened_entity(player)
    local record = entity and post.get(entity)
    local value = tonumber(element.text)
    if record and value and value >= 1 then
        post.set_order(record, {required = value})
        M.refresh_entity(player)
    end
end

function M.on_tab(event)
    local element = event.element
    if not (element and element.valid and element.tags and element.tags.ic == "panel-tab") then return end
    local tab = tabs[element.selected_tab_index or 1]
    if tab then
        M.player_settings(event.player_index).tab = tab.name
        local player = game.get_player(event.player_index)
        if player then M.refresh_panel(player) end
    end
end

-- Called every 10 ticks: refresh only what players have open.
function M.on_refresh(tick)
    for _, player in pairs(game.connected_players) do
        if player.gui.relative[RELATIVE] then M.refresh_entity(player) end
        if tick % 60 == 0 and player.gui.screen[PANEL] then M.refresh_panel(player) end
    end
end

return M
