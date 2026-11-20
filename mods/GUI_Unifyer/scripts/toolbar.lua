local mod_gui = require("mod-gui")
local props = require("scripts/gui-properties")
local logging = require("scripts/logging")
local panel = require("scripts/panel-scan")
local proxies = require("scripts/proxy-buttons")
local mods = script.active_mods -- constant for this control stage (also on reload)
local M = {}

local obsolete_top = {
    "blpflip_flow", "fjei_toggle_button", "Homeworld_btn", "lawful_evil_button", "trashbingui", "pywiki_frame", "usage_detector", "104",
    "spawn", "random", "what_is_missing", "logistics-view-button", "flw_zoom", "stats_show_settings", "teleportation_main_button",
    "personalTeleporter_PersonalTeleportTool", "inserter-throughput-toggle", "b_recexplo", "CTLM_mainbutton", "market_button", "rd_container", "abdgui", "clockGUI", "visual_signals",
}
local obsolete_name = {}
for _, name in ipairs(obsolete_top) do obsolete_name[name] = true end
local adjacent = {"DeleteAdjacentChunk_nw", "DeleteAdjacentChunk_n", "DeleteAdjacentChunk_ne", "DeleteAdjacentChunk_w",
    "DeleteAdjacentChunk_e", "DeleteAdjacentChunk_sw", "DeleteAdjacentChunk_s", "DeleteAdjacentChunk_se"}
local yarm = {"YARM_filter_none", "YARM_filter_warnings", "YARM_filter_all"}
local landfill = mods.LandfillEverythingU or mods.LandfillEverything or mods.LandfillEverythingButTrains or mods.LandfillEverythingAndPumps
local ore = {["iron-ore"]=true, ["copper-ore"]=true, stone=true, coal=true, ["uranium-ore"]=true, ["crude-oil"]=true}

local function set_sprite(button, path, kind)
    path = path or ""
    kind = kind or button.type
    if kind == "sprite-button" then
        props.set(button, "sprite", path)
        props.set(button, "hovered_sprite", path)
        props.set(button, "clicked_sprite", path)
    elseif kind == "button" then
        local child = button.button_sprite
        if path == "" then
            if child then child.destroy() end
        elseif child then
            props.set(child, "sprite", path)
        else
            child = button.add{type="sprite", name="button_sprite", sprite=path, ignored_by_interaction=true}
            child.style.stretch_image_to_widget_size = true
            child.style.size = {32, 32}
        end
    end
end

-- The owner uses a setting, not the button's native toggle. Run both in the
-- setting event (no stale frame) and during reconciliation (new owner elements).
local function throughput(button, ps, style)
    if not (button and button.valid and button.type == "sprite-button") then return end
    local setting = ps["inserter-throughput-enabled"]
    if not setting then return end
    local sprite = setting.value and "inserterthroughput_on_button" or "inserterthroughput_off_button"
    props.set(button, "auto_toggle", false)
    props.set(button, "toggled", false)
    props.style(button, style)
    set_sprite(button, sprite, "sprite-button")
    props.set(button, "tooltip", {"guiu." .. sprite})
end

function M.throughput_changed(player)
    if not mods["inserter-throughput"] then return end
    local ps = settings.get_player_settings(player)
    throughput(mod_gui.get_button_flow(player)["inserter-throughput-toggle"], ps, ps["gu_button_style_setting"].value)
end

local function add(ctx, spec)
    local button = ctx.flow.add(spec)
    ctx.buttons[spec.name] = button
    ctx.added = true
    return button
end

local function reconcile(ctx, enabled, name, sprite, tooltip)
    local button = ctx.buttons[name]
    if enabled then
        if not button then
            button = add(ctx, {type="sprite-button", name=name, sprite=sprite, style=ctx.style, tooltip=tooltip})
            if name == "YARM_filter_none" or name == "YARM_filter_warnings" then button.visible = false end
        end
    elseif button then
        button.destroy()
        ctx.buttons[name] = nil
    end
end

local function create_buttons(ctx)
    if mods["visual-signals"] then
        if ctx.top.visual_signals then
            ctx.top.visual_signals.destroy()
            ctx.top.visual_signals = nil
        end
        reconcile(ctx, true, "visual_signals", "visualsignals_button", {"guiu.visual_signals_button"})
    end
    for _, row in ipairs(proxies) do
        local enabled = mods[row[1]]
        if enabled and type(row[5]) == "string" then
            local setting = ctx.settings[row[5]]
            enabled = setting and setting.value
        else
            enabled = enabled and row[5]
        end
        -- Absent mods can still have legacy controls in a save. Use the live index.
        if enabled or ctx.buttons[row[2]] then reconcile(ctx, enabled, row[2], row[3], row[4]) end
    end
    local advanced = mods["advanced-logistics-system-fork"]
    if advanced or ctx.buttons["logistics-view-button"] then
        local force = ctx.player.force
        local tech = force and force.technologies["advanced-logistics-systems"]
        if tech and tech.researched then
            reconcile(ctx, advanced, "logistics-view-button", "logisticssystemfork_button", {"guiu.logisticssystemfork_button"})
        end
    end
    if mods.clock then
        if not ctx.buttons.clockGUI then
            add(ctx, {type="button", name="clockGUI", style="todo_button_default_snouz", caption=""})
        end
    elseif ctx.buttons.clockGUI then
        ctx.buttons.clockGUI.destroy()
        ctx.buttons.clockGUI = nil
    end
    -- TimedSpawnControl-reforged creates its own spawn/unstuck controls and tags.
    if not mods["TimedSpawnControl-reforged"] then reconcile(ctx, mods.SpawnControl, "spawn", "spawncontrol_button") end
    if mods["inserter-throughput"] then throughput(ctx.buttons["inserter-throughput-toggle"], ctx.settings, ctx.style) end
end

local function factoryplanner_visible(screen, legacy_name)
    if not screen.visible then return false end
    local frame = screen.fp_frame_main_dialog
    if frame then return frame.valid and frame.visible end

    -- Older saves may have the alias on the main frame or on a modal/dimmer.
    frame = screen[legacy_name]
    if not (frame and frame.valid and frame.visible) then return false end
    local tags = frame.tags
    return tags.mod == "fp" and tags.on_gui_closed == "close_main_dialog"
end

local function window_visible(gui, path)
    for _, key in ipairs(path) do
        gui = gui[key]
        if not gui or not gui.valid or not gui.visible then return false end
    end
    return true
end

local function apply_button(button, kind, style, entry, visible)
    props.style(button, style)
    if not entry[5] then set_sprite(button, entry[2], kind) end
    if entry[4] then props.set(button, "tooltip", entry[4]) end
    props.set(button, "visible", visible)
end

local function apply_icon(ctx, button, entry, style, visible)
    if not button.valid then return end
    local kind = button.type
    if kind ~= "button" and kind ~= "sprite-button" then return end
    -- An incompatible third-party button must not stop the rest of the panel.
    local ok, err = pcall(apply_button, button, kind, style, entry, visible)
    if not ok then logging.error("Icons", "Button " .. entry[3] .. ": " .. tostring(err), ctx.player)
    elseif ctx.debug then logging.debug("Icons", "Updated button " .. entry[3], ctx.player) end
end

local function change_icon(ctx, entry)
    local name = entry[3]
    if not name or not entry[2] then return end -- legacy empty registry entry
    local style = ctx.style
    local path = entry[7]
    if path then
        local selected
        if entry[1] == "factoryplanner" then
            selected = factoryplanner_visible(ctx.gui[path[1]], path[2])
        else
            selected = window_visible(ctx.gui, path)
        end
        local key = ctx.prefix .. name
        if storage.window_states[key] ~= selected then storage.window_states[key] = selected end
        if selected then style = ctx.selected end
    end
    local parent = ctx.buttons
    if entry[6] then
        for _, key in ipairs(entry[6]) do
            parent = parent[key]
            if not parent then break end
        end
    end
    local top, nested = ctx.top[name], parent and parent[name]
    if not (top or nested) then return end
    local setting = ctx.settings["gu_button_" .. name]
    local visible = not setting or setting.value
    if top then apply_icon(ctx, top, entry, style, visible) end
    if nested then apply_icon(ctx, nested, entry, style, visible) end
end

local function decorate(ctx)
    local buttons = ctx.buttons
    local nane, atlas = buttons["nan-e-button"], buttons.pd_atlas_toggle
    if nane and nane.type == "sprite-button" then props.style(nane, ctx.style) end
    if atlas and atlas.type == "sprite-button" then
        props.style(atlas, ctx.style)
        set_sprite(atlas, "pd-atlas-bookmark-light", "sprite-button")
    end
    for _, entry in ipairs(storage.gubuttonarray) do change_icon(ctx, entry) end
    if mods.BlackMarket2 then
        local credits = buttons.flw_blkmkt and buttons.flw_blkmkt.but_blkmkt_credits
        local caption = credits and credits.caption
        if caption then props.set(credits, "tooltip", "Credit: " .. caption) end
    end
    if mods.AttilaZoomMod then
        local style = ctx.style == "slot_sized_button_notext" and "slot_sized_button_blacktext" or "slot_button_whitetext"
        for i = 1, 15 do
            local button = buttons["Attila_zm_btn_" .. i]
            if button then
                props.style(button, style)
                props.set(button, "tooltip", {"guiu.attilazoommod_button"})
                set_sprite(button, "attilazoommod_button")
            end
        end
    end
    if mods["Todo-List"] and buttons.todo_maximize_button then
        local button, style = buttons.todo_maximize_button, ctx.style
        local mode = ctx.settings["gu_todolist_style_setting"].value
        if mode == "icon" then set_sprite(button, "todolist_button")
        elseif mode == "longtext" then set_sprite(button); style = "todo_button_default_snouz" end
        local caption = button.caption
        if caption then props.set(button, "tooltip", caption) end
        local frame = ctx.gui.screen.todo_main_frame
        if frame and frame.visible then style = style .. "_selected" end
        props.style(button, style)
    end
    if mods.DeleteAdjacentChunk and buttons.DeleteAdjacentChunk_table then
        for _, name in ipairs(adjacent) do
            local button = buttons.DeleteAdjacentChunk_table[name]
            if button then props.style(button, "adjacentchunks_button"); props.set(button, "sprite", nil) end
        end
    end
    if mods.Factorissimo2 and buttons.factory_camera_toggle_button then
        local b = buttons.factory_camera_toggle_button
        local sprite = b.sprite
        if sprite == "technology/factory-architecture-t1" or sprite == "technology/factory-preview" then
            b.sprite = sprite == "technology/factory-preview" and "factorissimo2_inspect_button" or "factorissimo2_button"
            b.tooltip = {"guiu.factorissimo2_button"}
        end
    end
end

local function destroy(button)
    if button then button.destroy() end
end
local function show(button, wanted)
    if button and button.visible ~= wanted then button.visible = wanted end
end

-- Also runs immediately on cursor changes (other mods may just have recreated a
-- legacy button). In a queued refresh use the existing name indexes. For the
-- cursor-only path do not enumerate the whole toolbar or probe 24 absent names.
local function cleanup(player, buttons, top, ps, blueprint, indexed)
    destroy(buttons.le_flow)
    destroy(buttons.bob_logistics_inserter_button)
    if not blueprint then
        destroy(buttons.le_button)
        destroy(buttons.blueprint_flip_horizontal)
        destroy(buttons.blueprint_flip_vertical)
    end
    if mods["automatic-belt-direction"] and buttons.abdgui then
        local setting = ps["abd-showgui"]
        if setting and not setting.value then destroy(buttons.abdgui) end
    end
    local visible = not ps["gu_mod_enabled_perplayer"].value
    if indexed then
        for _, name in ipairs(obsolete_top) do show(top[name], visible) end
    else
        local names = top.children_names
        if #names > #obsolete_top then names = obsolete_top end
        for _, name in ipairs(names) do
            if obsolete_name[name] then show(top[name], visible) end
        end
    end
    local left = player.gui.left
    if mods["production-monitor"] then
        local holder = left.stats_item_flow or top.stats_item_flow
        local name = holder and holder.children_names[1]
        local grid = name and name ~= "" and holder[name]
        local button = grid and grid.stats_show_settings
        if button and grid.column_count <= 1 then props.set(button, "enabled", false); show(button, false) end
    end
    if mods.YARM then
        local ff = mod_gui.get_frame_flow(player)
        local root = ff and ff.YARM_root
        local row = root and root.buttons
        if row then for _, name in ipairs(yarm) do show(row[name], false) end end
    end
    local lab = left.BPL_Flow
    if lab then show(lab.BPL_LabButton, false) end
    if mods.Spiderissmo then
        show(top.minimap_button, false)
        show(top["108"], false)
        local surface = player.surface
        local away = not surface or surface.name ~= "nauvis"
        show(buttons.minimap_button, away)
        show(buttons["108"], away)
    end
end

local frames = {
    snouz_normal_frame_style = {"frame", "inside_shallow_frame"},
    snouz_barebone_frame_style = {"snouz_invisible_frame", "snouz_barebone_frame"},
    snouz_large_barebone_frame_style = {"snouz_invisible_frame", "snouz_large_barebone_frame"},
    snouz_invisible_frame_style = {"snouz_invisible_frame", "snouz_invisible_frame"},
}
function M.refresh(player)
    local flow = mod_gui.get_button_flow(player)
    local ps = settings.get_player_settings(player)
    local style = ps["gu_button_style_setting"].value or "slot_button_notext"
    local gui = player.gui
    local buttons, ordered = panel.inspect(flow)
    local top = {}
    for _, child in ipairs(gui.top.children) do top[child.name] = child end
    local ctx = {player=player, flow=flow, gui=gui, top=top, buttons=buttons, settings=ps, style=style,
        selected=style .. "_selected", prefix=player.index .. "_", debug=logging.debug_enabled(player)}
    panel.rename_frames(gui.screen, mods)
    create_buttons(ctx)
    decorate(ctx)
    cleanup(player, buttons, top, ps, player.is_cursor_blueprint(), true)
    -- Deletions keep the order of surviving children. Only a disorder or an addition can require swaps.
    if ctx.added or not ordered then panel.sort(flow) end
    local state = storage.player[player.index]
    if state.update_frame then
        local style_pair = frames[ps["gu_frame_style_setting"].value]
        local outer = top.mod_gui_top_frame
        local inner = outer and outer.mod_gui_inner_frame
        if inner and style_pair then
            outer.style = style_pair[1]
            inner.style = style_pair[2]
        end
        state.update_frame = nil
    end
end

function M.cursor_changed(player)
    local flow = mod_gui.get_button_flow(player)
    local blueprint, ps = player.is_cursor_blueprint(), settings.get_player_settings(player)
    cleanup(player, flow, player.gui.top, ps, blueprint, false)
    if blueprint and (mods["blueprint-request"] or landfill or mods.blueprint_flip_and_turn) then
        local style = ps["gu_button_style_setting"].value or "slot_button_notext"
        if mods["blueprint-request"] then
            local button = flow["blueprint-request-button"]
            if button then button.style = style; set_sprite(button, "blueprintrequest_button") end
        end
        if landfill and not flow.le_button then
            flow.add{type="sprite-button", name="le_button", sprite="landfilleverythingu_button", style=style, tooltip={"landfill_everything_tooltip"}}
        end
        if mods.blueprint_flip_and_turn and not flow.blueprint_flip_horizontal and not flow.blueprint_flip_vertical then
            flow.add{type="sprite-button", name="blueprint_flip_horizontal", sprite="blueprint_flip_horizontal_button", style=style, tooltip={"guiu.blueprint_flip_horizontal_button"}}
            flow.add{type="sprite-button", name="blueprint_flip_vertical", sprite="blueprint_flip_vertical_button", style=style, tooltip={"guiu.blueprint_flip_vertical_button"}}
        end
    end
    if mods.SchallOreConversion then
        local stack = player.cursor_stack
        if stack and stack.valid_for_read and stack.valid and ore[stack.name] then
            local button = flow["Schall-OC-mod-button"]
            if button then button.style = ps["gu_button_style_setting"].value; set_sprite(button, "schalloreconversion_button") end
        end
    end
end

return M
