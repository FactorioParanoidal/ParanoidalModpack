-- AUTO protocol: the goals of the BnL start, pinned on top of the BnL journal (a new stage is also
-- told in the chat), the AUTO briefing after the
-- landing, one-off AUTO remarks and the closing act of the insurance case. Lines (each only once it
-- matters; most stages rotate between several texts, picked once when the stage begins):
--   * burning wrecks: their number while any burns, with the player's own water barrels;
--   * the flight recorder: find it (bearing) -> decode it (progress) -> done; "nothing to read it
--     with" when the salvaged lab is lost before the decoding;
--   * the antenna, after the antenna briefing: parts found of 3 -> build the beacon -> SOS progress
--     -> waiting for the answer -> done;
--   * the captain's safe, once the note is read or a letter of the lock has clicked: the known
--     digits -> the whole code -> open.
-- The reactor compartment has no line on purpose: it stays a surprise (user decision 2026-10-27).
-- A finished line stays green for config.goals.done_ttl. A part counts as found once it has left its
-- source (a compartment chest, the reactor compartment, the parts thrown out when it blew up).
-- One scheduler job refreshes every config.goals.interval while something can change by itself;
-- config.goals.retire after the landing the unfinished recorder and antenna reminders go into the
-- journal and the job ends (the safe line changes only by events that call M.refresh). Each player
-- can switch the window off (per-user setting bnl-goals).
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local events = require("scripts.events")
local fire = require("scripts.fire")
local trail = require("scripts.trail")
local M = {}
local cfg = config.goals

local FLOW = "bnl_goals"
local SETTING = "bnl-goals"
local RECORDER = "bnl-flight-recorder"
local TECH = "bnl-flight-recorder-decoding"
local PART = "bnl-antenna-part"
local LAB = "salvaged-lab"
local DONE_COLOR = "[color=0.55,0.9,0.5]"
-- Stages that are the same goal for the ear: no objective sound between them.
local QUIET = {burning = "burning", decode = "decode", decoding = "decode"}

local function state()
    return storage.bnl and storage.bnl.goals
end

function M.init()
    storage.bnl.goals = storage.bnl.goals or {stages = {}, done = {}, found = 0, briefed = {}, variants = {},
        keys = {}, water_had = {}, water_warned = {}, remarks = {}}
end

-- Parts --------------------------------------------------------------------------------------------

local function source_found(key)
    local status, entity = trail.placed(key)
    if status == "pending" then return false end
    if status == "valid" then
        if key == "reactor" then return false end -- the part comes with taking it apart
        local inventory = entity.get_inventory(defines.inventory.chest)
        return not (inventory and inventory.get_item_count(PART) > 0)
    end
    if key == "reactor" then
        for _, drop in ipairs(storage.bnl.antenna_drops or {}) do
            if drop.valid then return false end
        end
    end
    return true
end

local function parts_found()
    local n = 0
    for _, key in ipairs(cfg.antenna_sources) do
        if source_found(key) then n = n + 1 end
    end
    return n
end

-- Lines: each returns stage, locale base (without the variant number), parameters; nil: not shown --

local function fires_line()
    local n = fire.burning_count()
    if n <= 0 then return nil end
    return "burning", nil, {n}
end

local function recorder_line(s, force)
    local tech = force.technologies[TECH]
    if tech and tech.researched then return "done", "goal-recorder-done", {} end
    if s.retired then return nil end
    local f = storage.bnl.falling
    if not (f and f.recorder_landed) then return nil end
    local box = f.recorder_box
    if box and box.valid and fire.item_count(box, RECORDER) > 0 then
        return "find", "goal-recorder-find", {util.gps(box.position, box.surface)}
    end
    for _, drop in ipairs(f.recorder_drops or {}) do
        if drop.valid then return "find", "goal-recorder-find", {util.gps(drop.position, drop.surface)} end
    end
    if s.lab_lost then return "lost", "goal-recorder-lost", {} end
    local research = force.current_research
    if research and research.name == TECH then
        return "decoding", "goal-recorder-decoding", {math.floor(force.research_progress * 100)}
    end
    return "decode", "goal-recorder-decode", {}
end

local function antenna_line(s)
    if not s.antenna_briefed then return nil end
    local d = storage.bnl.distress
    if d and d.replied then return "done", "goal-antenna-done", {} end
    if s.retired then return nil end
    if d and d.sent then return "waiting", "goal-antenna-waiting", {} end
    if d and d.beacon and d.beacon.valid then
        return "power", "goal-antenna-power", {math.floor(d.powered or 0), config.distress.transmit_s}
    end
    local found = parts_found()
    if found > (s.found or 0) then
        local base = found > cfg.parts and "antenna-found-extra" or found == cfg.parts and "antenna-all" or "antenna-found"
        util.say(util.joke(base, found, cfg.parts))
    end
    s.found = found
    if found >= cfg.parts then return "build", "goal-antenna-build", {} end
    return "parts", "goal-antenna-parts", {found, cfg.parts}
end

-- Digit i of the safe code known to the players: from the recorder (B, N), the note (L), picked (any).
local function known(sf, i)
    if sf.latched and sf.latched[i] then return sf.code[i] end
    if i <= 2 and storage.bnl.recorder_done then return sf.code[i] end
    if i == 3 and sf.note_read then return sf.code[i] end
    return nil
end

local function safe_line()
    local sf = storage.bnl.safe
    if not (sf and sf.entity and sf.code) then return nil end
    if sf.open or not sf.entity.valid then
        if sf.open then return "done", "goal-safe-done", {} end
        return nil
    end
    local picked = sf.latched and (sf.latched[1] or sf.latched[2] or sf.latched[3])
    if not (sf.note_read or picked) then return nil end
    local digits, all = {}, true
    for i = 1, 3 do
        local digit = known(sf, i)
        if digit == nil then all = false end
        digits[i] = digit or "?"
    end
    if all then return "code", "goal-safe-code", digits end
    return "partial", "goal-safe-partial", digits
end

-- Window ---------------------------------------------------------------------------------------

local function wanted(player)
    local setting = player.mod_settings[SETTING]
    return setting == nil or setting.value ~= false
end

-- Water barrels of a player (nil without a character).
local function water_of(player)
    local character = player.character
    if not (character and character.valid and prototypes.item[cfg.water]) then return nil end
    return character.get_item_count(cfg.water)
end

-- The lines of one player: the fire line carries the player's own water.
local function lines_for(s, player)
    local out = {}
    for _, line in ipairs(s.lines or {}) do
        if type(line) == "table" and line.fire then
            local water = water_of(player)
            if water == nil then
                out[#out + 1] = {"bnl.goal-fires", line.fire}
            elseif water > 0 then
                out[#out + 1] = {"bnl.goal-fires-water", line.fire, water}
                s.water_had[player.index] = true
            else
                out[#out + 1] = {"bnl.goal-fires-dry", line.fire}
                if s.water_had[player.index] and not s.water_warned[player.index] then
                    s.water_warned[player.index] = true
                    util.say(util.joke("water-out"), nil, player)
                end
            end
        else
            out[#out + 1] = line
        end
    end
    return out
end

-- The goals live in the BnL journal (pinned on top); a new stage is also told in the chat.
local function render(s, player, news)
    local root = player.gui.goal
    if root and root[FLOW] then root[FLOW].destroy() end -- the objectives window of the first version
    local key = helpers.table_to_json(lines_for(s, player))
    if s.keys[player.index] ~= key then
        s.keys[player.index] = key
        journal.refresh(player)
    end
    if news and news[1] and wanted(player) then
        for _, caption in ipairs(news) do
            util.say({"bnl.goal-news", caption}, "utility/new_objective", player)
        end
    end
end

journal.goals = function(player)
    local s = state()
    return s and lines_for(s, player) or nil
end

local function lines_now(s)
    local force = util.player_force()
    local tick = game.tick
    local lines, news = {}, {}
    local function add(key, stage, base, params)
        local before = s.stages[key]
        s.stages[key] = stage
        if stage == nil then return end
        if stage ~= before or not s.variants[key] then s.variants[key] = base and util.variant(base) or 1 end
        local caption
        if base then
            local name = util.JOKES[base] and (base .. "-" .. math.min(s.variants[key], util.JOKES[base])) or base
            caption = {"bnl." .. name, table.unpack(params or {})}
        else
            caption = {fire = params[1]} -- the fire line, filled per player
        end
        if stage == "done" then
            if before == nil or before == "done" then
                -- finished before it was ever shown: never shown
                if not s.done[key] then return end
            else
                s.done[key] = tick
                news[#news + 1] = {"", "[virtual-signal=signal-check] ", caption}
            end
            if tick >= s.done[key] + cfg.done_ttl then return end
            lines[#lines + 1] = {"", DONE_COLOR, "[virtual-signal=signal-check] ", caption, "[/color]"}
            return
        end
        -- fires come and go all start long: their line never rings
        if before ~= stage and stage ~= "burning" and (QUIET[before] or before) ~= (QUIET[stage] or stage) then
            news[#news + 1] = caption
        end
        lines[#lines + 1] = caption
    end
    add("fires", fires_line())
    add("recorder", recorder_line(s, force))
    add("antenna", antenna_line(s))
    add("safe", safe_line())
    return lines, news
end

-- One-off AUTO remarks on the first events of the start (fire counters, scripts/fire.lua).
local function remarks(s)
    local stats = fire.stats()
    if (stats.quenched or 0) > 0 and not s.remarks.quench then
        s.remarks.quench = true
        util.say(util.joke("first-quench"))
    end
    if (stats.stacks_lost or 0) > 0 and not s.remarks.stack then
        s.remarks.stack = true
        util.say(util.joke("first-stack-lost"))
    end
end

-- Recounts the goals and rebuilds the windows whose lines changed (silent: no objective sound).
-- `only`: just show the current lines to this player (joined, setting changed), nothing recounted.
function M.refresh(silent, only)
    local s = state()
    if not s then return end
    if only then
        if only.valid then render(s, only) end
        return
    end
    remarks(s)
    local lines, news = lines_now(s)
    trail.update_tags()
    s.lines = lines
    if silent then news = nil end
    for _, player in pairs(game.connected_players) do
        render(s, player, news)
    end
end

-- Closing act ----------------------------------------------------------------------------------

-- {"", a, ", ", b, ...} without hitting the 20 parameters of a localised string.
local function join(list)
    if not list[1] then return {"bnl.act-nobody"} end
    local result = list[#list]
    for i = #list - 1, 1, -1 do result = {"", list[i], ", ", result} end
    return result
end

local function clock(ticks)
    local minutes = math.floor(ticks / 3600)
    return string.format("%d:%02d", math.floor(minutes / 60), minutes % 60)
end

-- The insurance case is closed with the numbers of the start; once per map (open: show the journal).
function M.act(open)
    local s = state()
    if not s or s.act_done then return end
    s.act_done = true
    local stats = fire.stats()
    local quenched, burnt, lost = stats.quenched or 0, stats.burnt_out or 0, stats.stacks_lost or 0
    local d = storage.bnl.distress
    local landing = util.landing_tick()
    local sos = d and d.sent_tick and clock(d.sent_tick - landing) or {"bnl.act-no-sos"}
    local tech = util.player_force().technologies[TECH]
    local decoded = tech and tech.researched
    local people = {}
    local chosen = storage.bnl.professions and storage.bnl.professions.chosen or {}
    for index, key in pairs(chosen) do
        local player = game.get_player(index)
        if player then people[#people + 1] = {"", player.name, " (", {"bnl-profession." .. key}, ")"} end
    end
    local stars = 5
    if lost > 10 then stars = stars - 1 end
    if burnt > quenched then stars = stars - 1 end
    if not (d and d.sent) then stars = stars - 1 end
    if not decoded then stars = stars - 1 end
    local rating = string.rep("★", stars) .. string.rep("☆", 5 - stars)
    journal.add("insurance-act", {quenched, burnt, lost, sos, s.found or parts_found(), cfg.parts,
        {decoded and "bnl.act-yes" or "bnl.act-no"}, join(people), rating}, {open = open})
end

function M.act_later()
    scheduler.after(cfg.act_delay, "goals-act")
end

scheduler.handler("goals-act", function() M.act(true) end)

-- The reminders of the recorder and the antenna end: what is left goes into the journal.
local function retire(s)
    s.retired = true
    local left = {}
    if s.stages.recorder and s.stages.recorder ~= "done" then left[#left + 1] = {"bnl.retired-recorder"} end
    if s.stages.antenna and s.stages.antenna ~= "done" then left[#left + 1] = {"bnl.retired-antenna"} end
    if left[1] then journal.add("reminders-retired", {join(left)}) end
    M.act()
end

-- Job ------------------------------------------------------------------------------------------

-- Something can still change by itself.
local function busy(s)
    if fire.active() or fire.burning_count() > 0 then return true end
    if not s.retired then
        local tech = util.player_force().technologies[TECH]
        if storage.bnl.falling and not (tech and tech.researched) then return true end
        if s.antenna_planned and not (storage.bnl.distress and storage.bnl.distress.replied) then return true end
    end
    for _, tick in pairs(s.done) do
        if game.tick < tick + cfg.done_ttl then return true end
    end
    return false
end

function M.wake()
    local s = state()
    if not s or s.running then return end
    s.running = true
    scheduler.after(cfg.interval, "goals")
end

scheduler.handler("goals", function()
    local s = state()
    if not s then return end
    if not s.retired and util.since_landing() >= cfg.retire then retire(s) end
    M.refresh()
    if busy(s) then
        scheduler.after(cfg.interval, "goals")
    else
        s.running = false
    end
end)

-- Briefing -------------------------------------------------------------------------------------

-- A player has landed (chose a profession, or at the landing when there are none): the fire part
-- of the briefing to that player once the crash cutscene is over, the antenna part to everyone
-- once, config.goals.antenna_delay later (with the whole report in the journal).
function M.brief(player)
    local s = state()
    if not s or s.briefed[player.index] then return end
    s.briefed[player.index] = true
    local at = math.max(game.tick + 120, util.landing_tick() + config.fire.cargo_grace)
    if util.enabled("bnl-start-wreck-fires") then
        scheduler.at(at, "goals-brief-fire", {player = player.index})
    end
    if not s.antenna_planned then
        s.antenna_planned = true
        if util.enabled("bnl-start-debris-trail") then scheduler.at(at + cfg.antenna_delay, "goals-brief-antenna") end
    end
    M.wake()
end

scheduler.handler("goals-brief-fire", function(job)
    local player = game.get_player(job.player)
    if player and player.connected then util.say(util.joke("brief-fire"), nil, player) end
end)

scheduler.handler("goals-brief-antenna", function()
    local s = state()
    if not s then return end
    s.antenna_briefed = true
    s.found = parts_found() -- parts taken before the briefing are not announced one by one
    util.say(util.joke("brief-antenna"))
    journal.add("damage-report")
    M.refresh()
    M.wake()
end)

-- The landing (control.lua): the window shows the fires at once; without professions every
-- player of the landing is briefed now.
function M.on_landing(professions_enabled)
    local s = state()
    if not s then return end
    if not professions_enabled then
        for _, player in pairs(game.players) do M.brief(player) end
    end
    M.refresh(true)
    M.wake()
end

-- The salvaged lab ---------------------------------------------------------------------------------

-- The only lab that reads the recorder died: is any left (built, or carried by a player)?
local function lab_left(dying)
    for _, surface in pairs(game.surfaces) do
        for _, lab in pairs(surface.find_entities_filtered({name = LAB})) do
            if lab ~= dying then return true end
        end
    end
    for _, player in pairs(game.players) do
        local character = player.character
        if character and character.valid and character.get_item_count(LAB) > 0 then return true end
    end
    return false
end

events.on(defines.events.on_entity_died, function(event)
    local entity = event.entity
    local s = state()
    if not (s and entity and entity.valid and entity.name == LAB) or storage.bnl.recorder_done then return end
    if not lab_left(entity) then
        s.lab_lost = true
        M.refresh()
    end
end, {{filter = "name", name = LAB}})

local function on_lab_built(event)
    local s = state()
    local entity = event.entity
    if s and s.lab_lost and entity and entity.valid and entity.name == LAB then
        s.lab_lost = nil
        M.refresh()
    end
end
for _, id in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
    events.on(defines.events[id], on_lab_built, {{filter = "name", name = LAB}})
end

events.on(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    if player and state() then M.refresh(true, player) end
end)

events.on(defines.events.on_runtime_mod_setting_changed, function(event)
    if event.setting ~= SETTING or not event.player_index then return end
    local player = game.get_player(event.player_index)
    if player and state() then M.refresh(true, player) end
end)

return M
