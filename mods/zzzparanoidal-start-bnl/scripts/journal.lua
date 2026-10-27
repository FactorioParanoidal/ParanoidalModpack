-- BnL journal: every story message (flight log, letters, notes, reports) is kept here and shown
-- in a window opened by the BnL button (top left) or /bnl-journal. Entries are localised keys.
local mod_gui = require("mod-gui")
local util = require("scripts.util")
local events = require("scripts.events")
local M = {}

local BUTTON = "bnl_journal_button"
local FRAME = "bnl_journal"

local function state()
    return storage.bnl.journal
end

function M.init()
    storage.bnl.journal = storage.bnl.journal or {entries = {}}
end

local function clock(tick)
    local s = math.floor(tick / 60)
    return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
end

local function button(player)
    local flow = mod_gui.get_button_flow(player)
    local b = flow[BUTTON] or flow.add({type = "sprite-button", name = BUTTON, sprite = "bnl-journal",
        style = mod_gui.button_style, tooltip = {"bnl.journal-button"}})
    b.style.padding = 0 -- the logo on its dark plate fills the whole button
end

-- Entries written by the company carry its seal.
local SEALED = {["distress-reply"] = true, ["insurance-start"] = true, ["insurance-end"] = true, ["insurance-cancelled"] = true}

local function sealed(entry)
    local key = type(entry.title) == "table" and entry.title[1] or ""
    key = key:gsub("^bnl%-journal%-title%.", "")
    return SEALED[key] or key:sub(1, 7) == "letter-"
end

-- Current goals of a player (scripts/goals.lua sets it): a list of captions, shown pinned on top.
M.goals = nil

local function fill(frame, player)
    -- child lookup by name sees direct children only: frame > inner frame > scroll pane
    local inner = frame.bnl_journal_inner
    local list = inner and inner.bnl_journal_scroll
    if not list then return end
    list.clear()
    local lines = M.goals and player and M.goals(player)
    if lines and lines[1] then
        local box = list.add({type = "frame", style = "inside_deep_frame", direction = "vertical"})
        box.style.padding = 8
        box.style.horizontally_stretchable = true
        box.add({type = "label", caption = {"bnl.goal-title"}})
        for _, caption in ipairs(lines) do
            local label = box.add({type = "label", caption = caption})
            label.style.single_line = false
            label.style.maximal_width = 560
        end
    end
    local entries = state().entries
    for i = #entries, 1, -1 do
        local entry = entries[i]
        local row = list.add({type = "flow", direction = "horizontal"})
        row.style.top_margin = 6
        row.style.horizontal_spacing = 8
        if sealed(entry) then
            local seal = row.add({type = "sprite", sprite = "bnl-seal", resize_to_sprite = false})
            seal.style.width = 48
            seal.style.height = 48
            seal.style.stretch_image_to_widget_size = true
        end
        local text = row.add({type = "flow", direction = "vertical"})
        text.add({type = "label", caption = {"", "[font=default-bold]", clock(entry.tick), "  ", entry.title, "[/font]"}})
        local body = text.add({type = "label", caption = entry.text})
        body.style.single_line = false
        body.style.maximal_width = sealed(entry) and 504 or 560
    end
end

function M.open(player)
    local screen = player.gui.screen
    if screen[FRAME] then
        if screen[FRAME].bnl_journal_inner then
            fill(screen[FRAME], player)
            return
        end
        screen[FRAME].destroy() -- older layout without the named inner frame
    end
    local frame = screen.add({type = "frame", name = FRAME, direction = "vertical"})
    frame.auto_center = true
    local bar = frame.add({type = "flow", direction = "horizontal"})
    bar.drag_target = frame
    local logo = bar.add({type = "sprite", sprite = "bnl-logo-small", ignored_by_interaction = true})
    logo.style.right_margin = 4
    bar.add({type = "label", caption = {"bnl.journal-title"}, style = "frame_title", ignored_by_interaction = true})
    local drag = bar.add({type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true})
    drag.style.horizontally_stretchable = true
    drag.style.height = 24
    bar.add({type = "sprite-button", name = "bnl_journal_close", sprite = "utility/close", style = "frame_action_button",
        tooltip = {"gui.close-instruction"}})
    local inner = frame.add({type = "frame", name = "bnl_journal_inner", style = "inside_shallow_frame_with_padding",
        direction = "vertical"})
    local list = inner.add({type = "scroll-pane", name = "bnl_journal_scroll", direction = "vertical"})
    list.style.maximal_height = 560
    list.style.minimal_width = 600
    fill(frame, player)
    player.opened = frame
end

-- The goals changed: the button exists, an open journal shows them.
function M.refresh(player)
    button(player)
    local frame = player.gui.screen[FRAME]
    if frame and frame.bnl_journal_inner then fill(frame, player) end
end

function M.close(player)
    local frame = player.gui.screen[FRAME]
    if frame then frame.destroy() end
end

-- New entry: kept, announced in chat, open journals refreshed. Returns the entry.
function M.add(key, params, opts)
    local entry = {
        tick = game.tick,
        title = {"bnl-journal-title." .. key},
        text = {"bnl-journal-text." .. key, table.unpack(params or {})},
    }
    local entries = state().entries
    entries[#entries + 1] = entry
    for _, player in pairs(game.players) do
        button(player)
        if player.gui.screen[FRAME] then fill(player.gui.screen[FRAME], player) end
    end
    if not (opts and opts.silent) then
        util.say({"bnl.journal-new", entry.title})
    end
    if opts and opts.open then
        for _, player in pairs(game.connected_players) do M.open(player) end
    end
    return entry
end

local function on_click(event)
    local element = event.element
    if not (element and element.valid) then return end
    local player = game.get_player(event.player_index)
    if element.name == BUTTON then
        if player.gui.screen[FRAME] then M.close(player) else M.open(player) end
    elseif element.name == "bnl_journal_close" then
        M.close(player)
    end
end

local function on_closed(event)
    local element = event.element
    if element and element.valid and element.name == FRAME then element.destroy() end
end

local function on_joined(event)
    local s = storage.bnl
    if not (s and s.journal and s.journal.entries[1]) then return end
    local player = game.get_player(event.player_index)
    if player then button(player) end
end

events.on(defines.events.on_gui_click, on_click)
events.on(defines.events.on_gui_closed, on_closed)
events.on(defines.events.on_player_joined_game, on_joined)

commands.add_command("bnl-journal", {"bnl.journal-command"}, function(command)
    local player = command.player_index and game.get_player(command.player_index)
    if player and storage.bnl and storage.bnl.journal then M.open(player) end
end)

return M
