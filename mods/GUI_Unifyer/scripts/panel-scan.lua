-- Only live, per-refresh snapshots. Another mod may replace a child with one of
-- the same name (or reorder the others) before the very next GUI event.
local M = {}
local order = {
    "spawn", "unstuck", "todo_maximize_button", "inserter-throughput-toggle",
    "paranoidal_autofill_button", "WideChests_merge-chest-button", "ptt_toolbar_toggle",
    "bpsb-toggle-gui-sb-toggle-shortcut", "btcharxp", "module_inserter_config_button",
    "fp_button_toggle_interface", "helmod_planner-command",
    -- DORMANT | "space_toggle_button", -- SpaceMod / SpaceModFeorasFork (SpaceX)
    "factorissimo_dispatch_button", "bnl_journal_button", "creative-mod_main-menu-open-button",
}
local rank = {}
for i, name in ipairs(order) do rank[name] = i end
local unlisted = #order + 1

local function rename_anonymous(element)
    local caption = element.caption
    local c = type(caption) == "table" and caption[1]
    --[=[ DORMANT: NonWaveDefense2, SkyWaveDefense, dana
    local tooltip = element.tooltip
    local t = type(tooltip) == "table" and tooltip[1]
    if c == "nwd2.upgrade-button" then element.name = "nwd2_main_gui_button" end
    if t == "upgrade-button-tooltip" then element.name = "swd3_main_gui_button" end
    if t == "dana.longName" then element.name = "dana_main_gui_button" end
    ]=]
    if c == "teams" then element.name = "base_pvp_teams_button" end
    if c == "space_race" then element.name = "base_pvp_space_race_button" end
    if c == "admin" then element.name = "base_pvp_admin_button" end
    return element.name
end

function M.inspect(flow)
    local buttons, ordered, last = {}, true, 0
    for _, element in ipairs(flow.children) do
        local name = element.name
        if name == "" then name = rename_anonymous(element) end
        if name ~= "" then buttons[name] = element end
        local r = rank[name] or unlisted
        if r < last then ordered = false end
        last = r
    end
    return buttons, ordered
end

-- Called only after additions or observed disorder. Cleanup may have removed
-- children since inspect(); resolve the permutation from the current siblings.
function M.sort(flow)
    local ranked, others = {}, {}
    local children = flow.children
    for i, element in ipairs(children) do
        local r = rank[element.name]
        if r then ranked[r] = i else others[#others + 1] = i end
    end
    local target = {}
    for r = 1, #order do
        if ranked[r] then target[#target + 1] = ranked[r] end
    end
    for _, original in ipairs(others) do target[#target + 1] = original end
    -- Original positions identify even unnamed siblings. Track only displaced
    -- slots, so finding the next swap never scans the GUI or the remaining tail.
    local at, where = {}, {}
    for slot, original in ipairs(target) do
        local pos = where[original] or original
        if pos ~= slot then
            flow.swap_children(slot, pos)
            local displaced = at[slot] or slot
            at[pos], where[displaced] = displaced, pos
        end
    end
end

-- Move one existing top-level root without changing the order of other roots.
function M.place_after(parent, element, anchor, children)
    local from, at
    for i, child in ipairs(children or parent.children) do
        if child == anchor then at = i end
        if child == element then from = i end
        if from and at then break end
    end
    if not (from and at) then return end
    if from < at then
        for slot = from, at - 1 do parent.swap_children(slot, slot + 1) end
    else
        for slot = from, at + 2, -1 do parent.swap_children(slot, slot - 1) end
    end
end

--[=[ DORMANT: train-log, Rich_Text_Helper, Not_Enough_Todo
local function missing_aliases(screen, mods)
    return mods["train-log"] and not screen.trainlog_mainframe,
           mods.Rich_Text_Helper and not screen.richtexthelper_mainframe,
           mods.Not_Enough_Todo and not screen.notenoughtodo_mainframe
end

local function todo_title(element)
    for _ = 1, 3 do
        element = element.children[1]
        if not element then return false end
    end
    local caption = element.caption
    return type(caption) == "table" and caption[1] == "Todo.GuiTitle"
end

function M.rename_frames(screen, mods)
    local train, rich, todo = missing_aliases(screen, mods)
    if not (train or rich or todo) then return end
    for _, element in ipairs(screen.children) do
        local name
        if train and element.tags["train-log"] then name = "trainlog_mainframe"
        elseif rich and element.name == "RICH_LOCATION_23_player01" then name = "richtexthelper_mainframe"
        elseif todo and todo_title(element) then name = "notenoughtodo_mainframe" end
        if name then
            -- Same first match and rule priority, including mixed tagged roots.
            element.name = name
            train, rich, todo = missing_aliases(screen, mods)
            if not (train or rich or todo) then break end
        end
    end
end
]=]

return M
