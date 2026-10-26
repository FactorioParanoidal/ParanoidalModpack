-- Professions: right after the landing every new player chooses what they did on board. In single
-- player the game is paused (tick_paused) until the choice. Each profession half-researches a few
-- technologies (saved progress 0.5) and gives its kit; the mechanic also has four defect-control
-- levels researched and doubles the start repair packs; the biologist gets seed recipes and,
-- later, a big bio farm by supply pod.
local config = require("bnl-config")
local util = require("scripts.util")
local journal = require("scripts.journal")
local events = require("scripts.events")
local start = require("scripts.start")
local pods = require("scripts.pods")
local M = {}
local cfg = config.professions

local FRAME = "bnl_profession"

local function state()
    return storage.bnl and storage.bnl.professions
end

function M.init()
    storage.bnl.professions = storage.bnl.professions or {chosen = {}, open = {}}
end

function M.enabled()
    return state() ~= nil and util.enabled("bnl-start-professions")
end

local function card(parent, key)
    local spec = cfg.list[key]
    local frame = parent.add({type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"})
    frame.style.width = 210
    frame.style.vertically_stretchable = true
    local head = frame.add({type = "flow", direction = "horizontal"})
    head.style.vertical_align = "center"
    local sprite = spec.sprite
    if sprite and not helpers.is_valid_sprite_path(sprite) then sprite = "utility/questionmark" end
    head.add({type = "sprite", sprite = sprite})
    head.add({type = "label", caption = {"bnl-profession." .. key}, style = "caption_label"})
    local text = frame.add({type = "label", caption = {"bnl-profession-description." .. key}})
    text.style.single_line = false
    text.style.width = 190
    local filler = frame.add({type = "empty-widget"})
    filler.style.vertically_stretchable = true
    local button = frame.add({type = "button", caption = {"bnl.profession-pick"}, style = "confirm_button",
        tags = {bnl_profession = key}})
    button.style.horizontally_stretchable = true
end

function M.show(player)
    if not M.enabled() then return end
    local s = state()
    if s.chosen[player.index] then return end
    local screen = player.gui.screen
    if screen[FRAME] then screen[FRAME].destroy() end
    local frame = screen.add({type = "frame", name = FRAME, direction = "vertical", caption = {"bnl.profession-title"}})
    frame.auto_center = true
    local intro = frame.add({type = "label", caption = {"bnl.profession-intro"}})
    intro.style.single_line = false
    intro.style.maximal_width = 1100
    local row = frame.add({type = "flow", direction = "horizontal"})
    row.style.horizontal_spacing = 8
    for _, key in ipairs(cfg.order) do card(row, key) end
    s.open[player.index] = true
    if not game.is_multiplayer() and util.enabled("bnl-start-pause") and not game.tick_paused then
        s.paused = true
        game.tick_paused = true
    end
end

local function half(force, name)
    local tech = force.technologies[name]
    if not (tech and tech.enabled and not tech.researched) then return end
    if force.current_research == tech then
        force.research_progress = math.max(force.research_progress, 0.5)
    else
        tech.saved_progress = math.max(tech.saved_progress or 0, 0.5)
    end
end

local function give(player, items)
    for _, entry in ipairs(items or {}) do
        if util.item_exists(entry[1]) then
            local inserted = player.insert({name = entry[1], count = entry[2]})
            if inserted < entry[2] and player.character then
                player.surface.spill_item_stack({position = player.character.position,
                    stack = {name = entry[1], count = entry[2] - inserted}, enable_looted = true, allow_belts = false})
            end
        end
    end
end

local function apply(player, key)
    local spec = cfg.list[key]
    local force = player.force
    for _, name in ipairs(spec.researched or {}) do
        local tech = force.technologies[name]
        if tech and not tech.researched then tech.researched = true end
    end
    for _, name in ipairs(spec.half or {}) do half(force, name) end
    for _, name in ipairs(spec.recipes or {}) do
        local recipe = force.recipes[name]
        if recipe then recipe.enabled = true end
    end
    give(player, spec.items)
    local ship_state = storage.shipwreck
    local ship = ship_state and ship_state.ship
    for _, entry in ipairs(spec.ship_items or {}) do
        if util.item_exists(entry[1]) then
            if ship and ship.valid then ship.insert({name = entry[1], count = entry[2]}) else give(player, {entry}) end
        end
    end
    if spec.repair_packs and ship_state then
        if ship_state.filled then
            start.add_repair_packs(ship_state, (ship_state.repair_total or 0) * (spec.repair_packs - 1))
        else
            ship_state.repair_multiplier = spec.repair_packs
        end
    end
    if spec.biofarm then pods.schedule_biofarm(player.index) end
end

function M.choose(player, key)
    local s = state()
    if not (s and cfg.list[key]) or s.chosen[player.index] then return end
    s.chosen[player.index] = key
    s.open[player.index] = nil
    local frame = player.gui.screen[FRAME]
    if frame then frame.destroy() end
    apply(player, key)
    if s.paused and not next(s.open) then
        s.paused = nil
        game.tick_paused = false
    end
    util.say({"bnl.profession-chosen", player.name, {"bnl-profession." .. key}}, false)
    journal.add("profession-" .. key, {player.name}, {silent = true})
end

local function on_click(event)
    local element = event.element
    if not (element and element.valid) then return end
    local key = element.tags and element.tags.bnl_profession
    if key then M.choose(game.get_player(event.player_index), key) end
end

events.on(defines.events.on_gui_click, on_click)

-- Players created after the start window are passengers without a choice.
function M.allowed(player)
    return M.enabled() and util.since_landing() <= cfg.window
end

function M.passenger(player)
    local s = state()
    if s and not s.chosen[player.index] then s.chosen[player.index] = "passenger" end
end

commands.add_command("bnl-profession", {"bnl.profession-command"}, function(command)
    local player = command.player_index and game.get_player(command.player_index)
    if player and M.enabled() and not state().chosen[player.index] then M.show(player) end
end)

return M
