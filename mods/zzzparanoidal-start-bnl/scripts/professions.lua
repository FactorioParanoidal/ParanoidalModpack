-- Professions: right after the landing every new player chooses what they did on board. In single
-- player the game is paused (tick_paused) until the choice. Each profession half-researches a few
-- technologies (saved progress 0.5) and gives its kit; the mechanic also has four defect-control
-- levels researched and doubles the start repair packs; the biologist gets seed recipes and,
-- later, a big bio farm by supply pod. The guards take all the ammo lying in the start wrecks and
-- the ship: in single player at once, in multiplayer shared equally among the guards once every
-- connected player has chosen or a minute after the first guard.
local config = require("bnl-config")
local util = require("scripts.util")
local journal = require("scripts.journal")
local events = require("scripts.events")
local start = require("scripts.start")
local pods = require("scripts.pods")
local scheduler = require("scripts.scheduler")
local quality = require("scripts.quality")
local geology = require("scripts.geology")
local goals = require("scripts.goals")
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

-- The player's character; during the vanilla crash cutscene (the choice opens at once) it is kept
-- aside as cutscene_character and player.character is nil.
local function body(player)
    local character = player.character
    if character and character.valid then return character end
    character = player.cutscene_character
    if character and character.valid then return character end
    return nil
end

local function spill(player, stack)
    local character = body(player)
    local surface = character and character.surface or player.surface
    surface.spill_item_stack({position = character and character.position or player.position, stack = stack,
        enable_looted = true, allow_belts = false})
end

-- Inserts into the character's inventory; returns the count inserted.
local function insert(player, stack)
    local character = body(player)
    return character and character.insert(stack) or 0
end

-- entry: {name, count, quality_steps = {min, max}} (one random step up for the whole entry).
local function give(player, items)
    for _, entry in ipairs(items or {}) do
        if util.item_exists(entry[1]) then
            local q = entry.quality_steps and quality.step_up(util.int(entry.quality_steps)) or "normal"
            local inserted = insert(player, {name = entry[1], count = entry[2], quality = q})
            if inserted < entry[2] then
                spill(player, {name = entry[1], count = entry[2] - inserted, quality = q})
            end
        end
    end
end

local function put_armor(player, name)
    local character = body(player)
    local slot = character and character.get_inventory(defines.inventory.character_armor)
    if slot and slot.is_empty() and util.item_exists(name) and prototypes.item[name].type == "armor" then
        return slot.insert({name = name, count = 1}) > 0
    end
    return false
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

-- Takes every ammo stack out of the start wrecks and the ship (also ammo kept virtually by wrecks
-- without an inventory and the cargo held by the fire of a burning wreck) into a pool {name, count, quality}.
local function collect_wreck_ammo()
    local pool, total = {}, 0
    local function add(name, count, quality_name)
        pool[#pool + 1] = {name = name, count = count, quality = quality_name or "normal"}
        total = total + count
    end
    for _, item in ipairs(start_wrecks()) do
        local entity = item.entity
        if entity.valid then
            local held = item.rec and item.rec.held
            for _, inventory in ipairs({entity.get_inventory(defines.inventory.chest) or false,
                held and held.valid and held or false}) do
                if inventory then
                    for i = 1, #inventory do
                        local stack = inventory[i]
                        if stack.valid_for_read and stack.type == "ammo" then
                            add(stack.name, stack.count, stack.quality.name)
                            stack.clear()
                        end
                    end
                end
            end
            local v = item.rec and item.rec.virtual
            if v and v.count > 0 and prototypes.item[v.name] and prototypes.item[v.name].type == "ammo" then
                add(v.name, v.count)
                item.rec.virtual = nil
            end
        end
    end
    return pool, total
end

-- Returns what did not fit (or nil).
local function give_stack(player, stack)
    if stack.count <= 0 then return nil end
    local inserted = insert(player, stack)
    if inserted < stack.count then
        return {name = stack.name, count = stack.count - inserted, quality = stack.quality}
    end
    return nil
end

-- The pool goes to the guards in equal shares, the remainder to the first one.
local function share_ammo()
    local s = state()
    if not s.ammo_pool or s.ammo_shared then return end
    s.ammo_shared = true
    scheduler.cancel("guard-ammo-share")
    local guards = {}
    for _, index in ipairs(s.guards or {}) do
        local player = game.get_player(index)
        if player and player.valid then guards[#guards + 1] = player end
    end
    local pool = s.ammo_pool
    s.ammo_pool = nil
    if not guards[1] then return end
    local got, rest = {}, {}
    for _, stack in ipairs(pool) do
        local part = math.floor(stack.count / #guards)
        for i, player in ipairs(guards) do
            local count = part + (i == 1 and stack.count - part * #guards or 0)
            local left = give_stack(player, {name = stack.name, count = count, quality = stack.quality})
            got[i] = (got[i] or 0) + count
            if left then
                rest[#rest + 1] = left
                got[i] = got[i] - left.count
            end
        end
    end
    -- what a guard could not take goes to the first guard, only then onto the ground next to him
    for _, stack in ipairs(rest) do
        local left = give_stack(guards[1], stack)
        got[1] = got[1] + stack.count - (left and left.count or 0)
        if left then spill(guards[1], left) end
    end
    for i, player in ipairs(guards) do
        player.print({"bnl.guard-ammo", got[i] or 0}, {color = util.CHAT_COLOR})
    end
end

scheduler.handler("guard-ammo-share", share_ammo)

-- Multiplayer: share once every connected player has chosen (or after config ammo_share_wait).
local function share_if_all_chose()
    local s = state()
    if not (s and s.ammo_pool) then return end
    for _, player in pairs(game.connected_players) do
        if not s.chosen[player.index] then return end
    end
    share_ammo()
end

-- Collects the ammo once there is a guard and the crash site is filled. Single player: at once to
-- the guard; multiplayer: shared among the guards chosen within config.professions.ammo_share_wait.
local function collect_for_guards()
    local s = state()
    if s.ammo_pool or s.ammo_shared or not (s.guards and s.guards[1]) then return end
    if not (storage.shipwreck and storage.shipwreck.filled) then return end
    s.ammo_pool = collect_wreck_ammo()
    if not game.is_multiplayer() then
        share_ammo()
    else
        scheduler.after(cfg.ammo_share_wait, "guard-ammo-share")
        share_if_all_chose()
    end
end

-- The crash site is filled (called by control.lua): a guard who chose before it takes the ammo now.
function M.on_start_ready()
    if state() then collect_for_guards() end
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
    local water = cfg.water_kit and cfg.water_kit[1]
    for _, entry in ipairs(spec.items or {}) do
        -- water goes by M.give_water (at once, also during the probation), not with the kit
        if entry[1] ~= water and not (entry[2] == 1 and put_armor(player, entry[1])) then items[#items + 1] = entry end
    end
    give(player, items)
    -- RPG attribute levels (PMRPGsystem gift_levels: no skill points spent): {attribute, min, max}
    local rpg = remote.interfaces.RPG
    if rpg and rpg.gift_levels then
        for _, entry in ipairs(spec.rpg or {}) do
            remote.call("RPG", "gift_levels", player.index, entry[1], util.int({entry[2], entry[3] or entry[2]}))
        end
    end
    if spec.wreck_ammo then
        local s = state()
        if not s.ammo_shared then
            s.guards = s.guards or {}
            s.guards[#s.guards + 1] = player.index
            collect_for_guards()
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
        -- the first mechanic doubles the start repair packs, every further one adds a fixed number
        local s = state()
        s.mechanics = (s.mechanics or 0) + 1
        if s.mechanics > 1 then
            if ship_state.filled then
                start.add_repair_packs(ship_state, spec.repair_packs_more or 0)
            else
                ship_state.repair_bonus = (ship_state.repair_bonus or 0) + (spec.repair_packs_more or 0)
            end
        elseif ship_state.filled then
            start.add_repair_packs(ship_state, (ship_state.repair_total or 0) * (spec.repair_packs - 1))
        else
            ship_state.repair_multiplier = spec.repair_packs
        end
    end
    if spec.prospect then geology.prospect() end
    if spec.biofarm then pods.schedule_biofarm(player.index) end
end

-- Water for the start fires, ready in hand: the water kit (and the water of a profession's kit, the
-- biologist's) at once, also during the multiplayer probation, to every player whatever burns or not
-- (passengers and players without professions too). Once per player.
function M.give_water(player, key)
    local s = state()
    local kit = cfg.water_kit
    if not (s and kit and util.item_exists(kit[1])) or (s.watered and s.watered[player.index]) then return end
    s.watered = s.watered or {}
    s.watered[player.index] = true
    local count = kit[2]
    local spec = key and cfg.list[key]
    for _, entry in ipairs(spec and spec.items or {}) do
        if entry[1] == kit[1] then count = count + entry[2] end
    end
    give(player, {{kit[1], count}})
    if player.get_quick_bar_slot(1) == nil then player.set_quick_bar_slot(1, kit[1]) end
end

function M.choose(player, key)
    local s = state()
    if not (s and cfg.list[key]) or s.chosen[player.index] then return end
    s.chosen[player.index] = key
    s.open[player.index] = nil
    local frame = player.gui.screen[FRAME]
    if frame then frame.destroy() end
    -- multiplayer: the first player to choose gets everything at once, the later ones after the
    -- probation (an extra quick login must not bring another kit and more research)
    M.give_water(player, key)
    s.first = s.first or player.index
    local wait = s.first ~= player.index and util.probation_left(player) or 0
    if wait > 0 then
        s.pending = s.pending or {}
        s.pending[player.index] = key
        scheduler.after(math.max(60, wait), "profession-probation", {player = player.index})
        player.print({"bnl.probation-profession", math.ceil(wait / 3600)}, {color = util.CHAT_COLOR})
    else
        apply(player, key)
    end
    if s.paused and not next(s.open) then
        s.paused = nil
        game.tick_paused = false
    end
    util.say({"bnl.profession-chosen", player.name, {"bnl-profession." .. key}}, false)
    journal.add("profession-" .. key, {player.name}, {silent = true})
    share_if_all_chose()
    goals.brief(player)
end

scheduler.handler("profession-probation", function(job)
    local s = state()
    local key = s and s.pending and s.pending[job.player]
    if not key then return end
    local player = game.get_player(job.player)
    if not (player and player.valid) or util.since_landing() > config.probation.give_up then
        s.pending[job.player] = nil
        return
    end
    local wait = player.connected and util.probation_left(player) or config.probation.check
    if wait > 0 then
        scheduler.after(math.max(wait, config.probation.check), "profession-probation", job)
        return
    end
    s.pending[job.player] = nil
    apply(player, key)
    player.print({"bnl.probation-done"}, {color = util.CHAT_COLOR})
    share_if_all_chose()
end)

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
    M.give_water(player)
end

commands.add_command("bnl-profession", {"bnl.profession-command"}, function(command)
    local player = command.player_index and game.get_player(command.player_index)
    if player and M.enabled() and not state().chosen[player.index] then M.show(player) end
end)

return M
