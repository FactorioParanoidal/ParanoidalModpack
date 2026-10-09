-- Builds every panel of the expansion with a strict fake LuaGuiElement: element types and
-- parameters are checked against the Factorio 2.0.77 API, style names against the installed
-- core style list (checked when this test was written), locale keys against locale/en and ru.
-- It catches typos that would crash the GUI; it does not show anything and is not Factorio.
local directory = assert(arg[0]:match("^(.*[/\\])"))
local root = directory .. "../"
package.path = root .. "?.lua;" .. package.path
local mock = dofile(directory .. "mock.lua")

local common = {type = 1, name = 1, caption = 1, tooltip = 1, elem_tooltip = 1, enabled = 1, visible = 1, locked = 1,
    ignored_by_interaction = 1, style = 1, tags = 1, index = 1, anchor = 1, game_controller_interaction = 1,
    raise_hover_events = 1}
local variants = {
    button = {auto_toggle = 1, mouse_button_filter = 1, toggled = 1}, checkbox = {state = 1},
    ["choose-elem-button"] = {elem_type = 1, elem_filters = 1, item = 1, ["item-with-quality"] = 1},
    ["drop-down"] = {items = 1, selected_index = 1}, flow = {direction = 1}, frame = {direction = 1},
    line = {direction = 1}, progressbar = {value = 1}, radiobutton = {state = 1},
    ["scroll-pane"] = {horizontal_scroll_policy = 1, vertical_scroll_policy = 1}, sprite = {sprite = 1, resize_to_sprite = 1},
    ["sprite-button"] = {sprite = 1, number = 1, toggled = 1}, tab = {badge_text = 1},
    table = {column_count = 1, draw_horizontal_line_after_headers = 1, draw_horizontal_lines = 1, draw_vertical_lines = 1},
    textfield = {allow_decimal = 1, allow_negative = 1, numeric = 1, text = 1}, label = {},
    ["tabbed-pane"] = {}, ["empty-widget"] = {},
}
-- Verified to exist in data/core/prototypes/style.lua of the installed 2.0.77.
local styles = {}
for _, name in ipairs({"frame", "inside_shallow_frame_with_padding", "inside_deep_frame", "frame_title",
    "draggable_space_header", "close_button", "caption_label", "bold_label", "naked_scroll_pane", "bordered_table",
    "tool_button", "green_button", "red_button"}) do styles[name] = true end
local sprites = {}
for _, name in ipairs({"utility/close", "utility/status_working", "utility/status_not_working", "utility/status_yellow",
    "utility/gps_map_icon", "utility/left_arrow", "utility/right_arrow", "ic-post-arrow-good", "ic-post-arrow-refine",
    "ic-post-arrow-other"}) do sprites[name] = true end

local function load_locale(language)
    local keys, section = {}, nil
    for line in io.lines(root .. "locale/" .. language .. "/expansion.cfg") do
        local header = line:match("^%[(.+)%]$")
        if header then section = header
        else
            local key = line:match("^([^=]+)=")
            if key and section then keys[section .. "." .. key] = true end
        end
    end
    return keys
end
local locales = {en = load_locale("en"), ru = load_locale("ru")}
local used_keys = {}
local function check_localised(value)
    if type(value) ~= "table" then return end
    local key = value[1]
    if type(key) == "string" and key:find("^ic%-quality%.") then used_keys[key] = true end
    for index = 2, #value do check_localised(value[index]) end
end

-- Factorio calls element methods with a dot (element.add{...}): methods are closures.
local new_element
local function find_child(self, key)
    for _, child in ipairs(rawget(self, "children")) do
        if rawget(child, "name") == key and child.valid then return child end
    end
end
new_element = function(params, parent)
    local element = {style = {}, valid = true, parent = parent, children = {}}
    for key, value in pairs(params) do if key ~= "style" then element[key] = value end end
    element.add = function(child_params)
        local kind = child_params.type
        assert(variants[kind], "Unknown element type " .. tostring(kind))
        for key in pairs(child_params) do
            assert(common[key] or variants[kind][key], "Unknown parameter " .. key .. " for " .. kind)
        end
        if child_params.style then assert(styles[child_params.style], "Unverified style " .. child_params.style) end
        if child_params.sprite then assert(sprites[child_params.sprite], "Unknown sprite " .. child_params.sprite) end
        check_localised(child_params.caption)
        check_localised(child_params.tooltip)
        for _, item in ipairs(child_params.items or {}) do check_localised(item) end
        if child_params.name then assert(not find_child(element, child_params.name), "Duplicate child " .. child_params.name) end
        local child = new_element(child_params, element)
        table.insert(element.children, child)
        return child
    end
    element.clear = function()
        for _, child in ipairs(element.children) do child.valid = false end
        element.children = {}
    end
    element.destroy = function()
        element.valid = false
        if parent then
            for index, child in ipairs(parent.children) do
                if child == element then table.remove(parent.children, index) break end
            end
        end
    end
    element.add_tab = function() end
    element.force_auto_center = function() end
    return setmetatable(element, {__index = function(self, key) return find_child(self, key) end})
end

defines = mock.defines()
defines.relative_gui_type = {furnace_gui = 1, assembling_machine_gui = 2, container_gui = 3}
storage = {}
script = {register_on_object_destroyed = function() end}
settings = {global = {["ic-more-qualities-initial-loss-percent"] = {value = 33}}}
rendering = {draw_sprite = function() return {id = 1} end, get_object_by_id = function() return nil end}
prototypes = {
    quality = {
        normal = {name = "normal", level = 0, order = "a", next_probability = 0.1, localised_name = {"quality-name.normal"}},
        rare = {name = "rare", level = 3, order = "b", localised_name = {"quality-name.rare"}},
        ["ic-defect-3"] = {name = "ic-defect-3", level = 0, order = "0", localised_name = {"quality-name.ic-defect-3"}},
    },
    item = {gear = {}, ["assembling-machine-1"] = {}},
    entity = {["assembling-machine-1"] = {localised_name = {"entity-name.assembling-machine-1"}},
        ["ic-refine-workshop-power"] = {}, ["ic-mode-power-3x3"] = {}},
    mod_data = {
        ["ic-defects-classification"] = {data = {finished = {["assembling-machine-1"] = true}}},
        ["ic-quality-expansion"] = {data = {costs = {gear = {cost = 300, seconds = 2, kinds = 0}},
            reasons = {gear = "ingredient"}, no_quality = {}}},
    },
}
local gui = require("scripts.expansion.gui")
local workshop = require("scripts.expansion.workshop")
local post = require("scripts.expansion.post")
local modes = require("scripts.expansion.modes")

local force = {index = 1, technologies = {}, players = {}}
for level = 1, 3 do force.technologies["ic-defect-control-" .. level] = {researched = true} end
local function surface()
    return {index = 1, name = "nauvis", create_entity = function()
        local e = {valid = true, power_usage = 0, electric_buffer_size = 1, energy = 0}
        function e.destroy() e.valid = false end
        function e.get_wire_connector() return {connect_to = function() return true end} end
        function e.get_or_create_control_behavior() return {get_section = function() return {filters = {}} end} end
        return e
    end, find_entities_filtered = function() return {} end}
end
local function entity(name, kind, unit)
    local e = {valid = true, object_name = "LuaEntity", name = name, type = kind, unit_number = unit,
        position = {x = 0.5, y = 0.5}, direction = 0, force = force, surface = surface(), quality = {name = "normal"},
        effects = {quality = 0.2}, burner = {}, crafting_speed = 1, crafting_progress = 0.3, products_finished = 0,
        prototype = {items_to_place_this = {{name = name}}, get_max_energy_usage = function() return 1000 end,
            collision_box = {left_top = {x = -1.2, y = -1.2}, right_bottom = {x = 1.2, y = 1.2}},
            selection_box = {left_top = {x = -1.5, y = -1.5}, right_bottom = {x = 1.5, y = 1.5}}},
        localised_name = {"entity-name." .. name}}
    e.get_fuel_inventory = function() return {} end
    e.get_inventory = function() return {is_empty = function() return true end, set_bar = function() end} end
    e.is_crafting = function() return true end
    e.get_recipe = function() return {name = "ic-refine-item-gear", products = {{name = "gear"}}}, {name = "ic-defect-3"} end
    e.get_wire_connector = function() return {connect_to = function() return true end} end
    return e
end

local function new_player(index)
    local player = {index = index, force = force, connected = true, toggled = {}}
    player.gui = {screen = new_element({}), relative = new_element({})}
    function player.set_shortcut_toggled(name, value) player.toggled[name] = value end
    function player.print() end
    return player
end
local player = new_player(1)
game = {tick = 600, connected_players = {player}, get_player = function() return player end}

-- Panel: every tab, refresh, lookup and forecast.
for _, tab in ipairs({"production", "refinement", "orders"}) do
    gui.player_settings(1).tab = tab
    gui.open_panel(player)
    assert(player.gui.screen.ic_quality_panel and player.toggled["ic-quality-panel"])
    gui.refresh_panel(player)
end
gui.player_settings(1).lookup = "gear"
gui.player_settings(1).forecast = {name = "gear", quality = "ic-defect-3"}
gui.open_panel(player)
gui.toggle_panel(player)
assert(not player.gui.screen.ic_quality_panel and player.toggled["ic-quality-panel"] == false)

-- Workshop panel with a running refinement and a few statistics.
local ws = entity("ic-refine-workshop", "furnace", 10)
local record = workshop.track(ws)
workshop.step(record, {tick = 1, random = mock.sequence({.5})})
storage.ic_stats = {[1] = {["refine.attempts"] = 4, ["refine.success"] = 3, ["refine.resource"] = 6000}}
player.opened = ws
gui.open_entity(player, ws)
assert(player.gui.relative.ic_quality_relative)
gui.refresh_entity(player)
for _, tab in ipairs({"production", "refinement", "orders"}) do
    gui.player_settings(1).tab = tab
    gui.open_panel(player)
    gui.refresh_panel(player)
end

-- Post panel and its events.
local po = entity("ic-control-post", "container", 20)
player.opened = po
gui.open_entity(player, po)
local precord = post.get(po)
post.set_order(precord, {item = "gear", required = 10})
gui.on_click({player_index = 1, element = {valid = true, tags = {ic = "post-start"}}}, {})
assert(precord.state == "active")
gui.on_click({player_index = 1, element = {valid = true, tags = {ic = "post-rotate", step = 1}}}, {})
assert(precord.facing == 1)
gui.on_selection({player_index = 1, element = {valid = true, tags = {ic = "post-condition"}, selected_index = 2}})
assert(precord.order.condition == "at-least")
gui.on_selection({player_index = 1, element = {valid = true, tags = {ic = "post-quality"}, selected_index = 2}})
assert(precord.order.quality == "rare")
gui.on_text({player_index = 1, element = {valid = true, tags = {ic = "post-required"}, text = "25"}})
assert(precord.order.required == 25)
gui.refresh_entity(player)

-- Production mode panel and selecting a mode by radiobutton.
local am = entity("assembling-machine-1", "assembling-machine", 30)
player.opened = am
gui.open_entity(player, am)
local tracked
gui.on_checked({player_index = 1, element = {valid = true, state = true, tags = {ic = "mode", mode = "careful"}}},
    {track_machine = function(e) tracked = e end})
assert(modes.mode_name(am) == "careful" and tracked == am)
gui.close_entity(player)
assert(not player.gui.relative.ic_quality_relative)

-- Every ic-quality locale key used by the GUI exists in both languages; dynamic families too.
local dynamic = {}
for _, key in ipairs({"workshop-state-working", "workshop-state-no-resource", "workshop-state-low-power",
    "workshop-state-paused", "workshop-state-output-full", "workshop-state-waiting", "workshop-state-idle",
    "workshop-state-reset", "workshop-state-passing", "workshop-status-working", "workshop-status-no-resource",
    "workshop-status-low-power", "workshop-status-paused", "workshop-status-output-full", "workshop-status-waiting",
    "workshop-status-idle", "workshop-status-reset", "workshop-status-passing", "grade-0", "grade-1", "grade-2",
    "grade-3", "grade-4", "grade-5", "kind-refine", "kind-reset", "kind-pass", "mode-normal", "mode-careful",
    "mode-precise", "mode-normal-tooltip", "mode-careful-tooltip", "mode-precise-tooltip", "order-state-idle",
    "order-state-active", "order-state-paused", "order-state-done", "reason-raw", "reason-parameter",
    "reason-material-tile", "reason-material-rail", "reason-material-pipe", "reason-ingredient",
    "route-good", "route-refine", "route-other", "route-good-legend", "route-refine-legend", "route-other-legend",
    "skip-reason-unsupported-speed", "skip-reason-missed-craft", "skip-reason-missed-cycle", "source-hand",
    "source-machine", "source-drill", "source-mining", "post-facing-0", "post-facing-1", "post-facing-2",
    "post-facing-3", "alert-no-resource", "order-done", "status-no-resource", "repair-slot",
    "repair-slot-description", "workshop-cant-refine", "workshop-cant-refine_until", "workshop-input-slot"}) do
    dynamic["ic-quality." .. key] = true
end
for key in pairs(dynamic) do used_keys[key] = true end
local count = 0
for key in pairs(used_keys) do
    count = count + 1
    assert(locales.en[key], "Missing EN locale " .. key)
    assert(locales.ru[key], "Missing RU locale " .. key)
end
for key in pairs(locales.en) do assert(locales.ru[key], "RU lacks " .. key) end
for key in pairs(locales.ru) do assert(locales.en[key], "EN lacks " .. key) end
print("PASS: panel (3 tabs, refresh, lookup, forecast), workshop/post/mode panels and their events built")
print("with API-checked element types/parameters, verified styles and sprites; " .. count .. " locale keys")
print("present in EN and RU, both files have identical keys. Fake GUI: no rendering, not Factorio.")
