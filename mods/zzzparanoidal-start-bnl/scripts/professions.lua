-- Professions: right after the landing every new player chooses what they did on board. In single
-- player the game is paused (tick_paused) until the choice. Each profession half-researches a few
-- technologies (saved progress 0.5) and gives its kit; the mechanic also has four defect-control
-- levels researched and doubles the start repair packs; the biologist gets seed recipes and,
-- later, a big bio farm by supply pod. The guard takes all the ammo lying in the start wrecks and
-- the ship (once per map, the first guard).
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

local function put_armor(player, name)
    local character = player.character
    local slot = character and character.get_inventory(defines.inventory.character_armor)
    if slot and slot.is_empty() and util.item_exists(name) and prototypes.item[name].type == "armor" then
        return slot.insert({name = name, count = 1}) > 0
    end
    return false
end

local function spill(player, stack)
    player.surface.spill_item_stack({position = player.position, stack = stack, enable_looted = true, allow_belts = false})
end

-- Start wrecks of the map: the list kept at the crash fill, for older maps the wrecks tracked by fires.
local function start_wrecks()
    local list = {}
    local bnl = storage.bnl
    for _, entity in ipairs(bnl.start_wrecks or {}) do list[#list + 1] = {entity = entity} end
    if not bnl.start_wrecks and bnl.fire then
        for _, rec in pairs(bnl.fire.wrecks) do list[#list + 1] = {entity = rec.entity} end
    end
    local ship = storage.shipwreck and storage.shipwreck.ship
    if ship then list[#list + 1] = {entity = ship} end
    if bnl.fire then
        for _, item in ipairs(list) do
            local entity = item.entity
            if entity.valid then
                local rec = bnl.fire.wrecks[script.register_on_object_destroyed(entity)]
                item.rec = rec
            end
        end
    end
    return list
end

-- Moves every ammo stack of the start wrecks into the player's inventory (the rest spills at the
-- player); ammo kept virtually by wrecks without an inventory comes too. Returns the item count.
local function take_wreck_ammo(player)
    local total = 0
    for _, item in ipairs(start_wrecks()) do
        local entity = item.entity
        if entity.valid then
            local inventory = entity.get_inventory(defines.inventory.chest)
            if inventory then
                for i = 1, #inventory do
                    local stack = inventory[i]
                    if stack.valid_for_read and stack.type == "ammo" then
                        local count = stack.count
                        local inserted = player.insert(stack)
                        if inserted < count then
                            stack.count = count - inserted
                            spill(player, stack)
                        end
                        stack.clear()
                        total = total + count
                    end
                end
            end
            local v = item.rec and item.rec.virtual
            if v and v.count > 0 and prototypes.item[v.name] and prototypes.item[v.name].type == "ammo" then
                give(player, {{v.name, v.count}})
                total = total + v.count
                item.rec.virtual = nil
            end
        end
    end
    return total
end

-- The guard chose before the crash site was filled: called by control.lua once it is.
function M.on_start_ready()
    local s = state()
    local index = s and s.wreck_ammo_for
    if not index then return end
    s.wreck_ammo_for = nil
    local player = game.get_player(index)
    if player and player.valid then
        s.wreck_ammo_taken = true
        player.print({"bnl.guard-ammo", take_wreck_ammo(player)}, {color = util.CHAT_COLOR})
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
    local items = {}
    for _, entry in ipairs(spec.items or {}) do
        if not (entry[2] == 1 and put_armor(player, entry[1])) then items[#items + 1] = entry end
    end
    give(player, items)
    if spec.wreck_ammo then
        local s = state()
        if not s.wreck_ammo_taken then
            if storage.shipwreck and storage.shipwreck.filled then
                s.wreck_ammo_taken = true
                player.print({"bnl.guard-ammo", take_wreck_ammo(player)}, {color = util.CHAT_COLOR})
            elseif not s.wreck_ammo_for then
                s.wreck_ammo_for = player.index
            end
        end
    end
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
